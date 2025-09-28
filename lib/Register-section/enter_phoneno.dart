// lib/Login-section/enter_phoneno.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'otp_verify.dart';

class PhoneNumberEntryScreen extends StatefulWidget {
  const PhoneNumberEntryScreen({Key? key}) : super(key: key);

  @override
  State<PhoneNumberEntryScreen> createState() => _PhoneNumberEntryScreenState();
}

class _PhoneNumberEntryScreenState extends State<PhoneNumberEntryScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isButtonEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneNumberChanged);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _onPhoneNumberChanged() {
    setState(() {
      _isButtonEnabled = _phoneController.text.length >= 10;
    });
  }

  bool _validatePhoneNumber(String phoneNumber) {
    final RegExp phoneRegExp = RegExp(r'^[0-9]{10}$');
    return phoneRegExp.hasMatch(phoneNumber);
  }

  void _onContinuePressed() async {
    final phoneNumber = _phoneController.text.trim();

    if (!_validatePhoneNumber(phoneNumber)) {
      _showErrorDialog('Please enter a valid 10-digit phone number');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final fullPhoneNumber = '+91$phoneNumber';

    try {
      if (kIsWeb) {
        // Simplified web flow - let Firebase handle reCAPTCHA automatically
        final confirmationResult = await _auth.signInWithPhoneNumber(fullPhoneNumber);
        
        setState(() {
          _isLoading = false;
        });
        
        _navigateToWebOTPScreen(confirmationResult, fullPhoneNumber);
      } else {
        // Mobile flow
        await _auth.verifyPhoneNumber(
          phoneNumber: fullPhoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _auth.signInWithCredential(credential);
            _navigateToDashboard();
          },
          verificationFailed: (FirebaseAuthException e) {
            setState(() {
              _isLoading = false;
            });
            _showErrorDialog('Verification failed: ${e.message}');
          },
          codeSent: (String verificationId, int? resendToken) {
            setState(() {
              _isLoading = false;
            });
            _navigateToOTPScreen(verificationId, fullPhoneNumber, resendToken);
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
          timeout: const Duration(seconds: 60),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error: ${e.toString()}');
    }
  }

  void _navigateToWebOTPScreen(ConfirmationResult confirmationResult, String phoneNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPVerificationScreen(
          verificationId: 'web_confirmation',
          phoneNumber: phoneNumber,
          resendToken: null,
          confirmationResult: confirmationResult,
        ),
      ),
    );
  }

  void _navigateToOTPScreen(String verificationId, String phoneNumber, int? resendToken) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPVerificationScreen(
          verificationId: verificationId,
          phoneNumber: phoneNumber,
          resendToken: resendToken,
        ),
      ),
    );
  }

  void _navigateToDashboard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success!'),
        content: const Text('Phone number verified successfully!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Welcome Back',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Wallet Logo
              Container(
                width: 120,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4DD0E1),
                      Color(0xFF26C6DA),
                      Color(0xFF00ACC1),
                      Color(0xFF0097A7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 20,
                      left: 12,
                      right: 12,
                      child: Column(
                        children: [
                          Container(
                            height: 2,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 2,
                            width: 80,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              const Text(
                'Enter your Phone',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 24),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: const Text(
                        '+91',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.grey.shade300,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        focusNode: _phoneFocusNode,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          hintText: 'Enter phone number',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.normal,
                          ),
                          counterText: '',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_isButtonEnabled && !_isLoading) ? _onContinuePressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_isButtonEnabled && !_isLoading)
                        ? Colors.blue
                        : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),

              const Spacer(flex: 4),

              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Text(
                  'By continuing, you agree to our Terms of Service and that\nyou have parental approval',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}