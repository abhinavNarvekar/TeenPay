import 'package:flutter/material.dart';
import 'dart:async';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({Key? key}) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  late Timer _timer;
  int _countdown = 53; // 53 seconds as shown in design

  @override
  void initState() {
    super.initState();
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
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (_controllers.every((c) => c.text.isNotEmpty)) _verifyOTP();
  }

  void _onKeyboardTap(String value) {
    int currentIndex = _focusNodes.indexWhere((node) => node.hasFocus);
    if (currentIndex == -1) {
      currentIndex = _controllers.indexWhere(
        (controller) => controller.text.isEmpty,
      );
    }

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

  void _verifyOTP() {
    final otp = _controllers.map((c) => c.text).join();
    _navigateToNextScreen(otp);
  }

  void _navigateToNextScreen(String otp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('OTP Verified'),
        content: Text(
          'Entered 6-digit OTP: $otp\n\nThis is a placeholder. Replace with actual navigation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resendCode() {
    setState(() {
      _countdown = 53;
      for (var controller in _controllers) controller.clear();
    });
    _timer.cancel();
    _startCountdown();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP code resent successfully!')),
    );
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
                  const Text(
                    'OTP code has been sent to +91 9495454393\nEnter the 6-digit code below to continue.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
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
                      'Resend code',
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
