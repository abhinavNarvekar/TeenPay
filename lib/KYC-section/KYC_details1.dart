import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teenpay/KYC-section/KYC_details1b.dart'; 
import 'kyc_provider.dart';

class KYCUploadPage extends StatefulWidget {
  const KYCUploadPage({super.key});

  @override
  _KYCUploadPageState createState() => _KYCUploadPageState();
}

class _KYCUploadPageState extends State<KYCUploadPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
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

  // --- Save Step 1 data + Navigate to Step 1b ---
  void _handleNext(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      
      final kycProvider = Provider.of<KycProvider>(context, listen: false);
      
      // CRITICAL FIX: Save the 4 fields from THIS page, and initialize the next 4 
      // with empty strings. This prevents the next page from overwriting them with NULLs.
      kycProvider.updatePersonalDetails(
        newName: _nameController.text,
        newContact: _contactController.text, // CRITICAL: This is the UserId source
        newEmail: _emailController.text,
        newPincode: _pincodeController.text,
        
        // Initializing the next 4 fields with empty strings
        newDob: '', 
        newGender: '',
        newParentName: '',
        newParentPhone: '',
      );

      // Navigate to Step 1b (Extra personal details)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const KycDetails1bPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct the errors in the form.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            // --- Step Indicator ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStepIndicator('Personal details', true),
                  ),
                  Expanded(
                    child: _buildStepIndicator('ID proof', false),
                  ),
                  Expanded(
                    child: _buildStepIndicator('Your real time photo', false),
                  ),
                ],
              ),
            ),

            // --- Form Section (Scrollable Area) ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enter Your Details',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 32),

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
                        hintText: 'Email...',
                        textInputType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),

                      _buildInputField(
                        controller: _pincodeController,
                        hintText: 'Pincode..',
                        textInputType: TextInputType.number,
                      ),

                      const SizedBox(height: 32), 
                    ],
                  ),
                ),
              ),
            ),

            // --- Next Button ---
            Container(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
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

  // --- Step Indicator Helper (unchanged) ---
  Widget _buildStepIndicator(String title, bool isActive) {
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

  // --- Input Field Helper (unchanged) ---
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType textInputType,
  }) {
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
          if (hintText.toLowerCase().contains('email') && !value.contains('@')) {
            return 'Please enter a valid email';
          }
          return null;
        },
      ),
    );
  }
}
