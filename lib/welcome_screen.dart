import 'package:flutter/material.dart';
import 'login_or_register.dart'; // 👈 Import your login/register screen

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0FFFF), // background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Main Wallet Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(
                    'assets/login-icons/logo.png', // main logo
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // App Name
              const Text(
                'TeenPay',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Smart Payments for Smart Teens',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Feature Items
              _buildFeatureItem(
                imagePath: 'assets/login-icons/flash.png',
                backgroundColor: Colors.blue.shade100,
                text: 'Send money instantly',
              ),
              const SizedBox(height: 24),
              _buildFeatureItem(
                imagePath: 'assets/login-icons/security.png',
                backgroundColor: Colors.green.shade100,
                text: 'Safe and Supervised',
              ),
              const SizedBox(height: 24),
              _buildFeatureItem(
                imagePath: 'assets/login-icons/rewards.png',
                backgroundColor: Colors.orange.shade100,
                text: 'Earn Rewards',
              ),

              const Spacer(flex: 3),

              // Get Started Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // 👇 Push navigation (user can go back)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginOrRegisterScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Custom Feature Item Widget
  Widget _buildFeatureItem({
    required String imagePath,
    required Color backgroundColor,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
