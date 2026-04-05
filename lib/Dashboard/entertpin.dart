import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../view-balance/view_balance.dart';

class EnterPinPage extends StatefulWidget {
  final bool navigateToWallet;

  const EnterPinPage({Key? key, this.navigateToWallet = false})
    : super(key: key);

  @override
  State<EnterPinPage> createState() => _EnterPinPageState();
}

class _EnterPinPageState extends State<EnterPinPage> {
  late String uid;
  String _enteredPin = '';
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
  }

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
      final walletDoc = await FirebaseFirestore.instance
          .collection('wallets')
          .doc(uid)
          .get();

      if (!walletDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wallet not found'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        final data = walletDoc.data()!;
        final storedPin = data['tPin'];
        final balance = (data['balance'] ?? 0).toDouble();

        if (_enteredPin == storedPin) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ PIN verified!'),
              backgroundColor: Colors.green,
            ),
          );

          if (widget.navigateToWallet) {
            // Navigate to Wallet page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => WalletBalancePage(uid: uid, balance: balance),
              ),
            );
          } else {
            // Return balance to dashboard
            Navigator.pop(context, balance);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Incorrect PIN'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _enteredPin = '');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error verifying PIN: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        bool isFilled = index < _enteredPin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? Colors.blue.shade600 : Colors.grey.shade300,
          ),
        );
      }),
    );
  }

  Widget _buildKeypadButton(String label, {String? sublabel}) {
    return Container(
      margin: const EdgeInsets.all(6),
      child: ElevatedButton(
        onPressed: _isVerifying ? null : () => _onKeyPressed(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
  }

  Widget _buildSpecialButton({
    required Widget child,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.all(6),
      child: ElevatedButton(
        onPressed: _isVerifying ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          shadowColor: Colors.black26,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: child,
      ),
    );
  }

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
              const Text(
                'Please enter your T-Pin',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                            child: const Icon(Icons.check, color: Colors.blue),
                            onPressed: _verifyPin,
                          ),
                        ),
                        Expanded(child: _buildKeypadButton('0')),
                        Expanded(
                          child: _buildSpecialButton(
                            child: const Icon(Icons.backspace_outlined),
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
