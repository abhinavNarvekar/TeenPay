import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Needed for data saving (Step 2)
import 'package:teenpay/KYC-section/KYC_details1b.dart';

// Assuming the file for the next step is named 'KYC_details2.dart'
import 'KYC_details2.dart';

// Assuming your Provider class is named 'KycProvider' and is in 'kyc_provider.dart' in the same folder
import 'kyc_provider.dart';

class KYCUploadPage extends StatefulWidget {
  // NOTE: I'm assuming KYCUploadPage is the class name for KYC_details1.dart
  const KYCUploadPage({super.key});

  @override
  _KYCUploadPageState createState() => _KYCUploadPageState();
}

class _KYCUploadPageState extends State<KYCUploadPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _pincodeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  // --- FUNCTIONAL NAVIGATION & DATA SAVE LOGIC START ---
  void _handleNext(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // --- START: Data Saving (Temporarily Commented Out) ---
      // This section is commented out for now, but ready when you implement the data flow!
      /*
      final kycProvider = Provider.of<KycProvider>(context, listen: false);
      kycProvider.updatePersonalDetails(
        newName: _nameController.text,
        newContact: _contactController.text,
        newEmail: _emailController.text,
        newPincode: _pincodeController.text,
      );
      */
      // --- END: Data Saving ---

      // --- Navigation to the next page (KYC_details2.dart) ---
      Navigator.push(
        context,
        MaterialPageRoute(
          // Ensure KYCDetails2Page is the class name inside your KYC_details2.dart file
          builder: (context) => const KYCDetails1Page(),
        ),
      );
    } else {
      // Optional: Show a message if validation fails (form field validators handle the visual errors)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct the errors in the form.')),
      );
    }
  }
  // --- FUNCTIONAL NAVIGATION & DATA SAVE LOGIC END ---

  @override
  Widget build(BuildContext context) {
    // ... (rest of your build method)
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Upload KYC',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step Indicators
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStepIndicator('Personal details', true, 0),
                  ),
                  Expanded(child: _buildStepIndicator('ID proof', false, 1)),
                  Expanded(
                    child: _buildStepIndicator(
                      'Your real time photo',
                      false,
                      2,
                    ),
                  ),
                ],
              ),
            ),

            // Form Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Title
                      const Text(
                        'Enter Your Details',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Input Fields
                      _buildInputField(
                        controller: _nameController,
                        hintText: 'Name',
                        textInputType: TextInputType.text,
                      ),
                      const SizedBox(height: 20),

                      _buildInputField(
                        controller: _contactController,
                        hintText: 'Contact no.',
                        textInputType: TextInputType.phone,
                      ),
                      const SizedBox(height: 20),

                      _buildInputField(
                        controller: _emailController,
                        hintText: 'email...',
                        textInputType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),

                      _buildInputField(
                        controller: _pincodeController,
                        hintText: 'Pincode..',
                        textInputType: TextInputType.number,
                      ),

                      // Spacer to push button to bottom
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),

            // Next Button
            Container(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  // <--- CALLING THE NEW FUNCTION HERE --->
                  onPressed: () => _handleNext(context),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008CFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets Below (No changes needed here) ---

  Widget _buildStepIndicator(String title, bool isActive, int stepIndex) {
    // ... (your existing _buildStepIndicator code) ...
    return Column(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF008CFF) : const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? const Color(0xFF008CFF) : const Color(0xFFA0A0A0),
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType textInputType,
  }) {
    // ... (your existing _buildInputField code) ...
    return SizedBox(
      height: 56,
      child: TextFormField(
        controller: controller,
        keyboardType: textInputType,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
          filled: true,
          fillColor: const Color(0xFFE6F8FF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF008CFF), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          if (hintText.contains('email') && !value.contains('@')) {
            return 'Please enter a valid email';
          }
          return null;
        },
      ),
    );
  }
}
