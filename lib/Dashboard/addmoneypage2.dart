import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({Key? key}) : super(key: key);

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isProcessing = false;

  late String uid;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
  }

  Future<double> getBalance() async {
    try {
      final doc = await _db.collection('wallets').doc(uid).get();
      if (!doc.exists) return 0.0;
      return (doc['balance'] as num).toDouble();
    } catch (e) {
      print('Error fetching balance: $e');
      return 0.0;
    }
  }

  Future<void> addMoney(double amount) async {
    final ref = _db.collection('wallets').doc(uid);

    await _db.runTransaction((txn) async {
      final snapshot = await txn.get(ref);

      final current = snapshot.exists
          ? (snapshot['balance'] as num).toDouble()
          : 0.0;

      txn.set(ref, {'balance': current + amount}, SetOptions(merge: true));
    });
  }

  Future<void> logTransaction({
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
      'status': 'completed',
      'counterparty': 'self',
      'counterpartyName': 'Wallet Top-up',
    };

    await _db
        .collection('transactions')
        .doc(uid)
        .collection('userTxns')
        .doc(transactionId)
        .set(transactionData);
  }

  void _simulatePayment() async {
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

    // ✅ limit ₹1000
    if (amount > 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only add up to ₹1000 at a time.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      await addMoney(amount);

      final newBalance = await getBalance();

      await logTransaction(amount: amount, newBalance: newBalance);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment success! New balance: ₹${newBalance.toStringAsFixed(2)}',
          ),
        ),
      );

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
                hintText: 'Enter up to ₹1000',
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
