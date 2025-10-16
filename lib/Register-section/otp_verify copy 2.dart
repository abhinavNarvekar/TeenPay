// lib/Login-section/otp_verify.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../login_or_register.dart'; // For OtpMode enum
import '../KYC-section/KYC_intro.dart'; // For OtpMode enum
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Post-kyc-registration/setusername_pass.dart';
import '../Dashboard/dashboard_temp.dart';

// TODO: Import your actual dashboard page here
// import '../Dashboard/dashboard_page.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final int? resendToken;
  final ConfirmationResult? confirmationResult; // For web
  final OtpMode mode; // Login or Registration mode

  const OTPVerificationScreen({
    Key? key,
    required this.verificationId,
    required this.phoneNumber,
    this.resendToken,
    this.confirmationResult,
    required this.mode,
  }) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late Timer _timer;
  int _countdown = 60;
  bool _isVerifying = false;
  String _currentVerificationId = '';

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId;
    _startCountdown();
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var controller in _controllers) controller.dispose();
    for (var node in _focusNodes) node.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _formattedTime {
    final minutes = _countdown ~/ 60;
    final seconds = _countdown % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) _focusNodes[index + 1].requestFocus();
    if (_controllers.every((c) => c.text.isNotEmpty)) _verifyOTP();
  }

  void _onKeyboardTap(String value) {
    int currentIndex = _focusNodes.indexWhere((node) => node.hasFocus);
    if (currentIndex == -1)
      currentIndex = _controllers.indexWhere((c) => c.text.isEmpty);

    if (currentIndex != -1 && currentIndex < 6) {
      if (value == '⌫') {
        if (_controllers[currentIndex].text.isNotEmpty) {
          _controllers[currentIndex].clear();
        } else if (currentIndex > 0) {
          _controllers[currentIndex - 1].clear();
          _focusNodes[currentIndex - 1].requestFocus();
        }
      } else {
        _controllers[currentIndex].text = value;
        if (currentIndex < 5) _focusNodes[currentIndex + 1].requestFocus();
      }

      if (_controllers.every((c) => c.text.isNotEmpty)) _verifyOTP();
    }
  }

  void _verifyOTP() async {
    final otp = _controllers.map((c) => c.text).join();
    setState(() => _isVerifying = true);

    try {
      if (kIsWeb && widget.confirmationResult != null) {
        await widget.confirmationResult!.confirm(otp);
        _navigatePostOtp();
      } else {
        final credential = PhoneAuthProvider.credential(
          verificationId: _currentVerificationId,
          smsCode: otp,
        );
        await _auth.signInWithCredential(credential);
        _navigatePostOtp();
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isVerifying = false);
      String errorMessage;

      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'Invalid OTP code. Please try again.';
          break;
        case 'session-expired':
        case 'code-expired':
          errorMessage = 'OTP code has expired. Please resend code.';
          break;
        default:
          errorMessage = 'Verification failed: ${e.message}';
      }

      _showErrorDialog(errorMessage);
      _clearOTP();
    } catch (e) {
      setState(() => _isVerifying = false);
      _showErrorDialog('An error occurred: ${e.toString()}');
      _clearOTP();
    }
  }

  void _clearOTP() {
    for (var controller in _controllers) controller.clear();
    _focusNodes[0].requestFocus();
  }

  void _navigatePostOtp() async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (widget.mode == OtpMode.login) {
      bool userExists = false;

      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        userExists = userDoc.exists;
      } catch (e) {
        print('Firestore read error: $e');
        userExists = false; // fallback if read fails
      }

      setState(() => _isVerifying = false);

      if (userExists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TeenPayApp()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const KycPage()),
        );
      }
    } else if (widget.mode == OtpMode.registration) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TeenPayApp()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const KycPage()),
          );
        }
      } catch (e) {
        setState(() => _isVerifying = false);
        _showErrorDialog('Failed to fetch user data: $e');
      }

      setState(() => _isVerifying = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const KycPage()),
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verification Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resendCode() async {
    try {
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please go back and request a new code'),
          ),
        );
        Navigator.pop(context);
      } else {
        await _auth.verifyPhoneNumber(
          phoneNumber: widget.phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _auth.signInWithCredential(credential);
            _navigatePostOtp();
          },
          verificationFailed: (FirebaseAuthException e) {
            _showErrorDialog('Resend failed: ${e.message}');
          },
          codeSent: (String verificationId, int? resendToken) {
            setState(() {
              _currentVerificationId = verificationId;
              _countdown = 60;
              for (var controller in _controllers) controller.clear();
            });
            _timer.cancel();
            _startCountdown();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP code resent successfully!')),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
          forceResendingToken: widget.resendToken,
          timeout: const Duration(seconds: 60),
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to resend code: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Enter OTP Code',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'OTP code has been sent to ${widget.phoneNumber}\nEnter the 6-digit code below to continue.',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  if (_isVerifying)
                    Column(
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Verifying OTP...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return Container(
                          width: 45,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              counterText: '',
                            ),
                            onChanged: (value) => _onDigitChanged(index, value),
                            readOnly: true,
                          ),
                        );
                      }),
                    ),
                  const SizedBox(height: 30),
                  Text(
                    _formattedTime,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _countdown == 0 ? _resendCode : null,
                    child: Text(
                      kIsWeb ? 'Request new code' : 'Resend code',
                      style: TextStyle(
                        fontSize: 16,
                        color: _countdown == 0 ? Colors.blue : Colors.grey,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Custom Numeric Keyboard
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildKeyboardButton('1', letters: 'ABC'),
                    _buildKeyboardButton('2', letters: 'DEF'),
                    _buildKeyboardButton('3'),
                  ],
                ),
                Row(
                  children: [
                    _buildKeyboardButton('4', letters: 'GHI'),
                    _buildKeyboardButton('5', letters: 'JKL'),
                    _buildKeyboardButton('6', letters: 'MNO'),
                  ],
                ),
                Row(
                  children: [
                    _buildKeyboardButton('7', letters: 'PQRS'),
                    _buildKeyboardButton('8', letters: 'TUV'),
                    _buildKeyboardButton('9', letters: 'WXYZ'),
                  ],
                ),
                Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    _buildKeyboardButton('0'),
                    _buildKeyboardButton('⌫', isBackspace: true),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildKeyboardButton(
    String number, {
    String? letters,
    bool isBackspace = false,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        height: 60,
        child: ElevatedButton(
          onPressed: () => _onKeyboardTap(number),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 1,
          ),
          child: isBackspace
              ? const Icon(Icons.backspace_outlined, size: 24)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      number,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (letters != null && letters.isNotEmpty)
                      Text(
                        letters,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
//workign was