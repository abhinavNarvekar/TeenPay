// lib/Login-section/enter_phoneno.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Register-section/otp_verify.dart';
import '../login_or_register.dart'; // For OtpMode enum
import 'package:cloud_firestore/cloud_firestore.dart';

class PhoneNumberEntryScreen extends StatefulWidget {
  final OtpMode mode; // Login or Registration mode

  const PhoneNumberEntryScreen({Key? key, required this.mode})
    : super(key: key);

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

    setState(() => _isLoading = true);

    final fullPhoneNumber = '+91$phoneNumber';
    String? username;

    try {
      final firestore = FirebaseFirestore.instance;

      if (widget.mode == OtpMode.registration) {
        final existingUserQuery = await firestore
            .collection('users')
            .where('phone', isEqualTo: fullPhoneNumber)
            .limit(1)
            .get();

        if (existingUserQuery.docs.isNotEmpty) {
          final userDoc = existingUserQuery.docs.first;
          final userData = userDoc.data();
          username = userData['username'];

          String? tPin;
          if (username != null) {
            final walletDoc = await firestore
                .collection('wallets')
                .doc(username)
                .get();
            tPin = (walletDoc.data() as Map<String, dynamic>?)?['tPin'];
          }

          if (username != null && tPin != null) {
            setState(() => _isLoading = false);
            _showErrorDialog(
              'This phone number is already registered and has a set tPin.\nPlease log in instead.',
            );
            return;
          }
        }
      } else if (widget.mode == OtpMode.login) {
        final existingUserQuery = await firestore
            .collection('users')
            .where('phone', isEqualTo: fullPhoneNumber)
            .limit(1)
            .get();

        if (existingUserQuery.docs.isEmpty) {
          setState(() => _isLoading = false);
          _showErrorDialog(
            'This phone number is not registered.\nPlease register first.',
          );
          return;
        }

        final userDoc = existingUserQuery.docs.first;
        final userData = userDoc.data();
        username = userData['username'];

        if (username == null) {
          setState(() => _isLoading = false);
          _showErrorDialog(
            'Your account setup is incomplete.\nPlease complete registration first.',
          );
          return;
        }

        final walletDoc = await firestore
            .collection('wallets')
            .doc(username)
            .get();
        final tPin = (walletDoc.data() as Map<String, dynamic>?)?['tPin'];

        if (tPin == null) {
          setState(() => _isLoading = false);
          _showErrorDialog(
            'You have not yet set your transaction PIN.\nPlease complete setup first.',
          );
          return;
        }
      }

      // ✅ Proceed with OTP verification
      if (kIsWeb) {
        final confirmationResult = await _auth.signInWithPhoneNumber(
          fullPhoneNumber,
        );
        setState(() => _isLoading = false);
        _navigateToWebOTPScreen(confirmationResult, fullPhoneNumber, username);
      } else {
        await _auth.verifyPhoneNumber(
          phoneNumber: fullPhoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _auth.signInWithCredential(credential);
            _navigatePostOtp();
          },
          verificationFailed: (FirebaseAuthException e) {
            setState(() => _isLoading = false);
            _showErrorDialog('Verification failed: ${e.message}');
          },
          codeSent: (String verificationId, int? resendToken) {
            setState(() => _isLoading = false);
            _navigateToOTPScreen(
              verificationId,
              fullPhoneNumber,
              resendToken,
              username,
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
          timeout: const Duration(seconds: 60),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Error: ${e.toString()}');
    }
  }

  void _navigateToWebOTPScreen(
    ConfirmationResult confirmationResult,
    String phoneNumber,
    String? username,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPVerificationScreen(
          verificationId: 'web_confirmation',
          phoneNumber: phoneNumber,
          resendToken: null,
          confirmationResult: confirmationResult,
          mode: widget.mode,
          username: username,
        ),
      ),
    );
  }

  void _navigateToOTPScreen(
    String verificationId,
    String phoneNumber,
    int? resendToken,
    String? username,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPVerificationScreen(
          verificationId: verificationId,
          phoneNumber: phoneNumber,
          resendToken: resendToken,
          mode: widget.mode,
          username: username,
        ),
      ),
    );
  }

  void _navigatePostOtp() {
    if (widget.mode == OtpMode.registration) {
      Navigator.pushNamed(context, '/kycPage');
    } else {
      Navigator.pushNamed(context, '/dashboard');
    }
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
          'Enter Phone Number',
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
                  onPressed: (_isButtonEnabled && !_isLoading)
                      ? _onContinuePressed
                      : null,
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
