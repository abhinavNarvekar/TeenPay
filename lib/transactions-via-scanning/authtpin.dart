import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'receipt.dart'; // Your ReceiptScreen import

class EnterPinPage extends StatefulWidget {
  final String username; // Sender's username
  final String transactionId; // Transaction ID
  final String? requestId; // Optional request ID to delete after payment

  const EnterPinPage({
    Key? key,
    required this.username,
    required this.transactionId,
    this.requestId,
  }) : super(key: key);

  @override
  State<EnterPinPage> createState() => _EnterPinPageState();
}

class _EnterPinPageState extends State<EnterPinPage> {
  String _enteredPin = '';
  bool _isVerifying = false;

  void _onKeyPressed(String value) {
    setState(() {
      if (value == 'backspace') {
        if (_enteredPin.isNotEmpty) {
          _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        }
      } else if (_enteredPin.length < 6) {
        _enteredPin += value;
      }
    });

    if (_enteredPin.length == 6) _verifyPin();
  }

  Future<void> _verifyPin() async {
    setState(() => _isVerifying = true);

    try {
      // 1. Fetch sender wallet
      final walletRef = FirebaseFirestore.instance
          .collection('wallets')
          .doc(widget.username);
      final walletDoc = await walletRef.get();

      if (!walletDoc.exists) throw 'Wallet not found';
      final storedPin = walletDoc['tPin'];

      if (_enteredPin != storedPin) throw 'Incorrect T-PIN';

      // 2. Fetch transaction
      final senderTxnRef = FirebaseFirestore.instance
          .collection('transactions')
          .doc(widget.username)
          .collection('userTxns')
          .doc(widget.transactionId);

      final senderTxnDoc = await senderTxnRef.get();
      if (!senderTxnDoc.exists) throw 'Transaction not found';

      final txnData = senderTxnDoc.data()!;
      final receiverUsername = txnData['counterparty'];
      final amount = (txnData['amount'] as num).toDouble();

      final receiverWalletRef = FirebaseFirestore.instance
          .collection('wallets')
          .doc(receiverUsername);
      final receiverTxnRef = FirebaseFirestore.instance
          .collection('transactions')
          .doc(receiverUsername)
          .collection('userTxns')
          .doc(widget.transactionId);

      // 3. Atomic money transaction
      await FirebaseFirestore.instance.runTransaction((txn) async {
        final senderSnap = await txn.get(walletRef);
        final receiverSnap = await txn.get(receiverWalletRef);
        final senderBalance = (senderSnap['balance'] as num).toDouble();
        final receiverBalance = (receiverSnap['balance'] as num).toDouble();

        if (senderBalance < amount) throw 'Insufficient balance';

        // Update balances
        txn.update(walletRef, {'balance': senderBalance - amount});
        txn.update(receiverWalletRef, {'balance': receiverBalance + amount});

        // Update transaction statuses
        txn.update(senderTxnRef, {
          'status': 'completed',
          'verifiedAt': FieldValue.serverTimestamp(),
        });
        txn.update(receiverTxnRef, {
          'status': 'completed',
          'verifiedAt': FieldValue.serverTimestamp(),
        });
      });

      // 4. Reward system update
      final rewardsRef = FirebaseFirestore.instance
          .collection('rewards')
          .doc(widget.username);
      final rewardsHistoryRef = rewardsRef.collection('history');

      await FirebaseFirestore.instance.runTransaction((txn) async {
        final rewardsSnap = await txn.get(rewardsRef);
        double currentPoints = 0.0;

        // Initialize rewards doc if not exists
        if (!rewardsSnap.exists) {
          txn.set(rewardsRef, {'totalPoints': 0});
        } else {
          currentPoints = (rewardsSnap['totalPoints'] as num).toDouble();
        }

        // Update total points (+5)
        txn.update(rewardsRef, {'totalPoints': currentPoints + 5});

        // Add history entry
        final newPointRef = rewardsHistoryRef.doc(); // auto pointId
        txn.set(newPointRef, {
          'pointId': newPointRef.id,
          'points': 5,
          'description': 'Earned for successful transaction',
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      // 5. Delete request if exists
      if (widget.requestId != null) {
        await FirebaseFirestore.instance
            .collection('requests')
            .doc(widget.requestId)
            .delete();
      }

      // 6. Navigate to ReceiptScreen
      final updatedSenderTxnDoc = await senderTxnRef.get();
      final verifiedAtTimestamp =
          updatedSenderTxnDoc['verifiedAt'] as Timestamp;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptScreen(
            senderUsername: widget.username,
            recipientUsername: receiverUsername,
            recipientName: txnData['counterpartyName'] ?? receiverUsername,
            amount: amount,
            note: txnData['note'] ?? '',
            transactionId: widget.transactionId,
            verifiedAt: verifiedAtTimestamp.toDate(),
          ),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '✅ PIN verified! Transaction completed & 5 points added',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isVerifying = false;
        _enteredPin = '';
      });
    }
  }

  Widget _buildPinDots() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(6, (i) {
      bool filled = i < _enteredPin.length;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? Colors.blue.shade600 : Colors.grey.shade300,
        ),
      );
    }),
  );

  Widget _buildKeypadButton(String label, {String? sublabel}) => Container(
    margin: const EdgeInsets.all(6),
    child: ElevatedButton(
      onPressed: _isVerifying ? null : () => _onKeyPressed(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        shadowColor: Colors.black26,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          if (sublabel != null)
            Text(
              sublabel,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
        ],
      ),
    ),
  );

  Widget _buildSpecialButton({
    required Widget child,
    required VoidCallback onPressed,
  }) => Container(
    margin: const EdgeInsets.all(6),
    child: ElevatedButton(
      onPressed: _isVerifying ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        shadowColor: Colors.black26,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: child,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 213, 233, 240),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 35, 139, 204),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Enter T-Pin',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                'Welcome ${widget.username},\nPlease enter your T-Pin',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              _buildPinDots(),
              const SizedBox(height: 40),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildKeypadButton('1')),
                        Expanded(
                          child: _buildKeypadButton('2', sublabel: 'ABC'),
                        ),
                        Expanded(
                          child: _buildKeypadButton('3', sublabel: 'DEF'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildKeypadButton('4', sublabel: 'GHI'),
                        ),
                        Expanded(
                          child: _buildKeypadButton('5', sublabel: 'JKL'),
                        ),
                        Expanded(
                          child: _buildKeypadButton('6', sublabel: 'MNO'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildKeypadButton('7', sublabel: 'PQRS'),
                        ),
                        Expanded(
                          child: _buildKeypadButton('8', sublabel: 'TUV'),
                        ),
                        Expanded(
                          child: _buildKeypadButton('9', sublabel: 'WXYZ'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSpecialButton(
                            child: const Icon(
                              Icons.check,
                              color: Colors.blue,
                              size: 24,
                            ),
                            onPressed: _verifyPin,
                          ),
                        ),
                        Expanded(child: _buildKeypadButton('0')),
                        Expanded(
                          child: _buildSpecialButton(
                            child: const Icon(
                              Icons.backspace_outlined,
                              color: Colors.black87,
                              size: 24,
                            ),
                            onPressed: () => _onKeyPressed('backspace'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_isVerifying)
                const CircularProgressIndicator(color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }
}
