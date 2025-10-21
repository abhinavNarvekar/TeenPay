import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Dashboard/dashboard_temp.dart';
import 'package:teenpay/login_or_register.dart';

class SetNewPinScreen extends StatefulWidget {
  const SetNewPinScreen({Key? key}) : super(key: key);

  @override
  State<SetNewPinScreen> createState() => _SetNewPinScreenState();
}

class _SetNewPinScreenState extends State<SetNewPinScreen> {
  String _firstPin = '';
  String _secondPin = '';
  bool _isFirstPinComplete = false;
  bool _isSecondPinActive = false;
  bool _isSubmitting = false;

  String? _username; // will fetch from users collection

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (doc.exists) {
      setState(() {
        _username = doc['username']; // assumes 'username' field exists
      });
    }
  }

  void _onKeyPressed(String value) {
    setState(() {
      if (!_isFirstPinComplete) {
        if (value == 'backspace') {
          if (_firstPin.isNotEmpty)
            _firstPin = _firstPin.substring(0, _firstPin.length - 1);
        } else if (_firstPin.length < 6) {
          _firstPin += value;
          if (_firstPin.length == 6) {
            _isFirstPinComplete = true;
            _isSecondPinActive = true;
          }
        }
      } else {
        if (value == 'backspace') {
          if (_secondPin.isNotEmpty) {
            _secondPin = _secondPin.substring(0, _secondPin.length - 1);
          } else if (_firstPin.isNotEmpty) {
            _isFirstPinComplete = false;
            _isSecondPinActive = false;
            _firstPin = _firstPin.substring(0, _firstPin.length - 1);
          }
        } else if (_secondPin.length < 6) {
          _secondPin += value;
        }
      }
    });
  }

  Future<void> _onSubmit() async {
    if (_username == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username not loaded yet. Please wait.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_firstPin.length == 6 && _secondPin.length == 6) {
      if (_firstPin == _secondPin) {
        setState(() => _isSubmitting = true);
        try {
          final walletRef = FirebaseFirestore.instance
              .collection('wallets')
              .doc(_username);

          await walletRef.set({
            'username': _username,
            'tPin': _firstPin,
            'balance': 0.0,
            'createdAt': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ T-Pin set successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to dashboard after a short delay
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginOrRegisterScreen(),
              ),
            );
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving T-Pin: $e'),
              backgroundColor: Colors.red,
            ),
          );
        } finally {
          setState(() => _isSubmitting = false);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PINs do not match. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _firstPin = '';
          _secondPin = '';
          _isFirstPinComplete = false;
          _isSecondPinActive = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete both PIN entries.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Widget _buildPinDots(String pin, bool isActive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        bool isFilled = index < pin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled
                ? (isActive ? Colors.blue.shade600 : Colors.grey.shade600)
                : Colors.grey.shade300,
            border: isActive && index == pin.length
                ? Border.all(color: Colors.blue.shade600, width: 2)
                : null,
          ),
          child: isFilled
              ? const Center(
                  child: Icon(Icons.circle, size: 8, color: Colors.white),
                )
              : null,
        );
      }),
    );
  }

  Widget _buildKeypadButton(
    String label, {
    String? sublabel,
    VoidCallback? onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.all(6),
      child: ElevatedButton(
        onPressed: onPressed,
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
            const SizedBox(height: 4),
            Text(
              sublabel ?? '',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialButton({
    required Widget child,
    required VoidCallback onPressed,
    Color? backgroundColor,
  }) {
    return Container(
      margin: const EdgeInsets.all(6),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.white,
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Set New Pin',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Text(
                _username != null
                    ? 'Welcome back $_username,\nPlease set a new T-Pin'
                    : 'Loading username...',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),
              _buildPinDots(_firstPin, !_isFirstPinComplete),
              const SizedBox(height: 40),
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.black87, width: 1),
                  ),
                ),
                child: const Text(
                  'Re-enter the entered T-pin',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildPinDots(_secondPin, _isSecondPinActive),
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => print('Forgot PIN tapped'),
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.black87, width: 1),
                      ),
                    ),
                    child: const Text(
                      'Forgot PIN ?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'It will be used to log in securely\nand must be kept private.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildKeypadButton(
                            '1',
                            onPressed: () => _onKeyPressed('1'),
                          ),
                        ),
                        Expanded(
                          child: _buildKeypadButton(
                            '2',
                            sublabel: 'ABC',
                            onPressed: () => _onKeyPressed('2'),
                          ),
                        ),
                        Expanded(
                          child: _buildKeypadButton(
                            '3',
                            sublabel: 'DEF',
                            onPressed: () => _onKeyPressed('3'),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildKeypadButton(
                            '4',
                            sublabel: 'GHI',
                            onPressed: () => _onKeyPressed('4'),
                          ),
                        ),
                        Expanded(
                          child: _buildKeypadButton(
                            '5',
                            sublabel: 'JKL',
                            onPressed: () => _onKeyPressed('5'),
                          ),
                        ),
                        Expanded(
                          child: _buildKeypadButton(
                            '6',
                            sublabel: 'MNO',
                            onPressed: () => _onKeyPressed('6'),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildKeypadButton(
                            '7',
                            sublabel: 'PQRS',
                            onPressed: () => _onKeyPressed('7'),
                          ),
                        ),
                        Expanded(
                          child: _buildKeypadButton(
                            '8',
                            sublabel: 'TUV',
                            onPressed: () => _onKeyPressed('8'),
                          ),
                        ),
                        Expanded(
                          child: _buildKeypadButton(
                            '9',
                            sublabel: 'WXYZ',
                            onPressed: () => _onKeyPressed('9'),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSpecialButton(
                            backgroundColor: const Color(0xFF3F51B5),
                            onPressed: _onSubmit,
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                          ),
                        ),
                        Expanded(
                          child: _buildKeypadButton(
                            '0',
                            onPressed: () => _onKeyPressed('0'),
                          ),
                        ),
                        Expanded(
                          child: _buildSpecialButton(
                            onPressed: () => _onKeyPressed('backspace'),
                            child: const Icon(
                              Icons.backspace_outlined,
                              color: Colors.black87,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
