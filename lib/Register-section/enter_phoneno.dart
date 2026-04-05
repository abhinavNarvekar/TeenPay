// lib/Login-section/enter_phoneno.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Register-section/otp_verify.dart';
import '../login_or_register.dart';

class PhoneNumberEntryScreen extends StatefulWidget {
  final OtpMode mode;

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

    try {
      final firestore = FirebaseFirestore.instance;

      // 🔍 Step 1: Find user by phone
      final existingUserQuery = await firestore
          .collection('users')
          .where('phone', isEqualTo: fullPhoneNumber)
          .limit(1)
          .get();

      if (existingUserQuery.docs.isEmpty) {
        // ❌ No user exists

        if (widget.mode == OtpMode.login) {
          setState(() => _isLoading = false);
          _showErrorDialog('User not registered. Please register first.');
          return;
        }

        // ✅ Registration allowed → proceed to OTP
      } else {
        // ✅ User exists
        final userDoc = existingUserQuery.docs.first;
        final uid = userDoc.id;

        // 🔍 Step 2: Check wallet for tPin
        final walletDoc = await firestore.collection('wallets').doc(uid).get();

        final hasTPin = walletDoc.exists && walletDoc.data()?['tPin'] != null;

        if (hasTPin) {
          // ✅ Fully registered

          if (widget.mode == OtpMode.registration) {
            setState(() => _isLoading = false);
            _showErrorDialog('User already registered. Please login.');
            return;
          }

          // login allowed
        } else {
          // ⚠️ Not fully registered

          if (widget.mode == OtpMode.login) {
            setState(() => _isLoading = false);
            _showErrorDialog('Complete registration first.');
            return;
          }

          // registration allowed (resume onboarding)
        }
      }

      // ✅ Send OTP
      if (kIsWeb) {
        final confirmationResult = await _auth.signInWithPhoneNumber(
          fullPhoneNumber,
        );

        setState(() => _isLoading = false);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
              verificationId: 'web_confirmation',
              phoneNumber: fullPhoneNumber,
              resendToken: null,
              confirmationResult: confirmationResult,
              mode: widget.mode,
            ),
          ),
        );
      } else {
        await _auth.verifyPhoneNumber(
          phoneNumber: fullPhoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _auth.signInWithCredential(credential);
          },
          verificationFailed: (FirebaseAuthException e) {
            setState(() => _isLoading = false);
            _showErrorDialog('Verification failed: ${e.message}');
          },
          codeSent: (String verificationId, int? resendToken) {
            setState(() => _isLoading = false);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OTPVerificationScreen(
                  verificationId: verificationId,
                  phoneNumber: fullPhoneNumber,
                  resendToken: resendToken,
                  mode: widget.mode,
                ),
              ),
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
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Text(
                        '+91',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
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
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter phone number',
                          counterText: '',
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
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
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Continue'),
                ),
              ),
              const Spacer(flex: 4),
            ],
          ),
        ),
      ),
    );
  }
}
