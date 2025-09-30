import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 1. Import the next page (the Personal Details form)
import 'KYC_details1.dart'; 
// NOTE: Assuming the class inside KYC_details1.dart is KYCUploadPage

class KycPage extends StatelessWidget {
  const KycPage({super.key});

  // Define the primary blue used in the ElevatedButton (for clarity)
  static const Color primaryBlue = Color(0xFF3B82F6); 
  static const Color darkTextColor = Color(0xFF1F2937); // A dark gray/blue for text contrast

  // --- New function to handle navigation ---
  void _startVerification(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // Navigate to the first form step
        builder: (context) => const KYCUploadPage(), 
      ),
    );
  }
  // ----------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F8FF), // Very light blue
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Top content: Back arrow, title, and illustration
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Back arrow
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        
                        const SizedBox(height: 16),

                        // Title (Changed color to a more neutral dark text)
                        Text(
                          'Verify yourself first!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue, // Using the primary blue color
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Illustration card
                        Card(
                          elevation: 4,
                          shadowColor: Colors.black.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Image.asset(
                              'assets/KYC-icons/kyc.png', 
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Caption text
                        Text(
                          'Just a student ID and a quick selfie — you\'ll be ready in under 2 minutes.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6B7280), // Medium gray
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Start Verification button (positioned at the bottom)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    // 2. Call the navigation function on press
                    onPressed: () => _startVerification(context), 
                    
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: Colors.black.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Start Verification',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

