import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Dashboard/dashboard_temp.dart'; // import your TeenPayDashboard page

class RequestMoneyScreen extends StatefulWidget {
  final String senderUid;
  final String receiverUid;
  const RequestMoneyScreen({
    Key? key,
    required this.senderUid,
    required this.receiverUid,
  }) : super(key: key);
  @override
  State<RequestMoneyScreen> createState() => _RequestMoneyScreenState();
}

class _RequestMoneyScreenState extends State<RequestMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String receiverName = 'Loading...';
  bool _isSendingRequest = false;
  String senderName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchReceiverName();
    _fetchSenderName();
  }

  Future<void> _fetchSenderName() async {
    try {
      final kycDoc = await FirebaseFirestore.instance
          .collection('kyc')
          .doc(widget.senderUid)
          .get();

      setState(() {
        senderName = kycDoc.exists ? kycDoc['name'] ?? 'User' : 'User';
      });
    } catch (e) {
      setState(() => senderName = 'User');
    }
  }

  Future<void> _fetchReceiverName() async {
    try {
      final kycDoc = await FirebaseFirestore.instance
          .collection('kyc')
          .doc(widget.receiverUid)
          .get();

      setState(() {
        receiverName = kycDoc.exists ? kycDoc['name'] ?? 'User' : 'User';
      });
    } catch (e) {
      setState(() => receiverName = 'User');
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _onContinuePressed() async {
    final amountText = _amountController.text.trim();
    final parsedAmount = double.tryParse(amountText);

    if (parsedAmount == null || parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSendingRequest = true);

    try {
      // Create request in top-level Firestore collection
      final requestRef = FirebaseFirestore.instance
          .collection('requests')
          .doc(); // auto-generated requestId

      await requestRef.set({
        'requestId': requestRef.id, // optional, store ID inside document
        'senderUid': widget.senderUid,
        'receiverUid': widget.receiverUid,
        'senderName': senderName,
        'receiverName': receiverName,
        'amount': parsedAmount,
        'note': _noteController.text.trim(),
        'status': 'pending', // pending, paid
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Show alert dialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Request Sent'),
          content: const Text('Your money request has been sent successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => TeenPayDashboard()),
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error creating request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send request'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSendingRequest = false);
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
          'Enter amount to Request',
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
            _isSendingRequest
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
          receiverName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(widget.receiverUid.substring(0, 10)),
      ),
    );
  }

  Widget _buildAmountSection() {
    return Column(
      children: [
        Text(
          'Amount to Request',
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
        onPressed: _onContinuePressed,
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
