import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'authtpin.dart'; // import your EnterPinPage

class SendMoneyScreen extends StatefulWidget {
  final String senderUsername; // logged-in user
  final String recipientUsername; // from scanned QR
  final String teenPayId; // from scanned QR

  // Optional fields for prefilled request
  final double? prefillAmount;
  final String? prefillNote;
  final String? requestId;

  const SendMoneyScreen({
    Key? key,
    required this.senderUsername,
    required this.recipientUsername,
    required this.teenPayId,
    this.prefillAmount,
    this.prefillNote,
    this.requestId,
  }) : super(key: key);

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String recipientName = 'Loading...';
  String senderName = 'Loading...';
  bool _isCreatingTransaction = false;

  @override
  void initState() {
    super.initState();
    _fetchRecipientName();
    _fetchSenderName();

    // Prefill amount/note if coming from request
    if (widget.prefillAmount != null) {
      _amountController.text = widget.prefillAmount!.toStringAsFixed(0);
    }
    if (widget.prefillNote != null) {
      _noteController.text = widget.prefillNote!;
    }
  }

  // Fetch recipient display name from KYC
  Future<void> _fetchRecipientName() async {
    try {
      final usernameDoc = await FirebaseFirestore.instance
          .collection('usernames')
          .doc(widget.recipientUsername)
          .get();

      if (!usernameDoc.exists) {
        setState(() => recipientName = widget.recipientUsername);
        return;
      }

      final uid = usernameDoc['uid'];
      final kycDoc = await FirebaseFirestore.instance
          .collection('kyc')
          .doc(uid)
          .get();

      setState(() {
        recipientName = kycDoc.exists
            ? kycDoc['name'] ?? widget.recipientUsername
            : widget.recipientUsername;
      });
    } catch (e) {
      print('Error fetching recipient name: $e');
      setState(() => recipientName = widget.recipientUsername);
    }
  }

  // Fetch sender display name from KYC
  Future<void> _fetchSenderName() async {
    try {
      final usernameDoc = await FirebaseFirestore.instance
          .collection('usernames')
          .doc(widget.senderUsername)
          .get();

      if (!usernameDoc.exists) {
        setState(() => senderName = widget.senderUsername);
        return;
      }

      final uid = usernameDoc['uid'];
      final kycDoc = await FirebaseFirestore.instance
          .collection('kyc')
          .doc(uid)
          .get();

      setState(() {
        senderName = kycDoc.exists
            ? kycDoc['name'] ?? widget.senderUsername
            : widget.senderUsername;
      });
    } catch (e) {
      print('Error fetching sender name: $e');
      setState(() => senderName = widget.senderUsername);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _createTransactionAndEnterPin() async {
    final parsedAmount =
        widget.prefillAmount ?? double.tryParse(_amountController.text) ?? 0.0;
    final note = widget.prefillNote ?? _noteController.text;

    if (parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isCreatingTransaction = true);

    try {
      final txnRef = FirebaseFirestore.instance
          .collection('transactions')
          .doc(widget.senderUsername)
          .collection('userTxns')
          .doc(); // unique txn ID

      final txnDataSender = {
        'type': 'debit',
        'amount': parsedAmount,
        'counterparty': widget.recipientUsername,
        'counterpartyName': recipientName, // recipient display name
        'note': note,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Credit transaction for receiver now has sender's display name
      final txnDataReceiver = {
        'type': 'credit',
        'amount': parsedAmount,
        'counterparty': widget.senderUsername,
        'counterpartyName': senderName, // ✅ sender display name
        'note': note,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // 1. Write transaction for sender
      await txnRef.set(txnDataSender);

      // 2. Write transaction for receiver
      final receiverRef = FirebaseFirestore.instance
          .collection('transactions')
          .doc(widget.recipientUsername)
          .collection('userTxns')
          .doc(txnRef.id);

      await receiverRef.set(txnDataReceiver);

      // 3. Navigate to EnterPinPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EnterPinPage(
            username: widget.senderUsername,
            transactionId: txnRef.id,
            requestId: widget.requestId,
          ),
        ),
      );
    } catch (e) {
      print('Error creating transaction: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create transaction'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isCreatingTransaction = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Enter Amount',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildRecipientCard(),
            const SizedBox(height: 60),
            _buildAmountSection(),
            const SizedBox(height: 40),
            _buildNoteSection(),
            const Spacer(),
            _isCreatingTransaction
                ? const CircularProgressIndicator()
                : _buildContinueButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: CircleAvatar(
          radius: 30.0,
          backgroundColor: Colors.white,
          child: Icon(Icons.person, size: 35.0, color: Colors.grey[600]),
        ),
        title: Text(
          recipientName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          widget.recipientUsername,
          style: const TextStyle(color: Colors.black54, fontSize: 14.0),
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    return Column(
      children: [
        Text(
          'Amount to Send',
          style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
        ),
        const SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '₹',
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: IntrinsicWidth(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.left,
                  autofocus: true,
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400],
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add a note (optional)',
          style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteController,
          decoration: InputDecoration(
            hintText: "What's this for?",
            hintStyle: TextStyle(color: Colors.grey[500]),
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _createTransactionAndEnterPin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: const StadiumBorder(),
          elevation: 2,
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
