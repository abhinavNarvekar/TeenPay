import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMoneyScreen extends StatefulWidget {
  final String username;

  const AddMoneyScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isProcessing = false;

  // Fetch current balance for the user
  Future<double> getBalance(String username) async {
    try {
      final doc = await _db.collection('wallets').doc(username).get();
      if (!doc.exists) return 0.0;
      return (doc['balance'] as num).toDouble();
    } catch (e) {
      print('Error fetching balance: $e');
      return 0.0;
    }
  }

  // Add money to the wallet (atomic update)
  Future<void> addMoney(String username, double amount) async {
    final ref = _db.collection('wallets').doc(username);
    await _db.runTransaction((txn) async {
      final snapshot = await txn.get(ref);
      final current = snapshot.exists
          ? (snapshot['balance'] as num).toDouble()
          : 0.0;
      txn.set(ref, {'balance': current + amount}, SetOptions(merge: true));
    });
  }

  // Record the transaction inside transactions/{username}/userTxns
  Future<void> logTransaction({
    required String username,
    required double amount,
    required double newBalance,
  }) async {
    final transactionId = DateTime.now().millisecondsSinceEpoch.toString();
    final transactionData = {
      'transactionId': transactionId,
      'type': 'credit',
      'amount': amount,
      'description': 'Money added to wallet',
      'timestamp': FieldValue.serverTimestamp(),
      'balanceAfter': newBalance,
      'mode': 'manual add',
      'status': 'success',
    };

    await _db
        .collection('transactions')
        .doc(username)
        .collection('userTxns')
        .doc(transactionId)
        .set(transactionData);
  }

  // Simulated payment and Firestore update
  void _simulatePayment() async {
    final username = widget.username;
    final amountInput = _amountController.text.trim();

    if (amountInput.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter amount')));
      return;
    }

    final amount = double.tryParse(amountInput);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Simulate delay like a payment gateway
      await Future.delayed(const Duration(seconds: 2));

      // Update wallet balance
      await addMoney(username, amount);

      // Get updated balance
      final newBalance = await getBalance(username);

      // Log transaction in Firestore
      await logTransaction(
        username: username,
        amount: amount,
        newBalance: newBalance,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment success! New balance for $username: ₹${newBalance.toStringAsFixed(2)}',
          ),
        ),
      );

      // Return to dashboard with updated balance
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context, newBalance);
      });
    } catch (e) {
      print('Payment failed: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Money')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount (INR)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            _isProcessing
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _simulatePayment,
                    child: const Text('Add Money'),
                  ),
          ],
        ),
      ),
    );
  }
}
