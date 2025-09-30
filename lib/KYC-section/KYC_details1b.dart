import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'KYC_details2.dart';
import 'kyc_provider.dart';

// --- GLOBAL COLORS ---
const Color primaryBlue = Color(0xFF2196F3);
const Color fillColor = Color(0xFFE3F2FD);
const Color darkTextColor = Colors.black87;
const Color inactiveColor = Color(0xFFA0A0A0);
const Color inactiveBarColor = Color(0xFFE0E0E0);

class KycDetails1bPage extends StatefulWidget {
  const KycDetails1bPage({super.key});

  @override
  State<KycDetails1bPage> createState() => _KycDetails1bPageState();
}

class _KycDetails1bPageState extends State<KycDetails1bPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the 4 visible fields
  final _dobController = TextEditingController();
  final _genderController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();

  // Preserved data from previous page
  String _name = '';
  String _contact = '';
  String _email = '';
  String _pincode = '';

  @override
  void initState() {
    super.initState();
    // Load previous data once the widget is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final kycProvider = Provider.of<KycProvider>(context, listen: false);
      setState(() {
        _name = kycProvider.name;
        _contact = kycProvider.contact;
        _email = kycProvider.email;
        _pincode = kycProvider.pincode;
      });
      print('DEBUG: Loaded previous data. Contact: $_contact');
    });
  }

  @override
  void dispose() {
    _dobController.dispose();
    _genderController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    super.dispose();
  }

  void _handleNext(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final kycProvider = Provider.of<KycProvider>(context, listen: false);

      // Update all 8 fields in provider
      kycProvider.updatePersonalDetails(
        newName: _name,
        newContact: _contact,
        newEmail: _email,
        newPincode: _pincode,
        newDob: _dobController.text,
        newGender: _genderController.text,
        newParentName: _parentNameController.text,
        newParentPhone: _parentPhoneController.text,
      );

      // Navigate to next page (ID Proof)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const KycIdProofPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields.')),
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
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildProgressIndicator(),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Date of Birth'),
                      _buildInputField(controller: _dobController, hint: 'DD/MM/YYYY', keyboardType: TextInputType.datetime),
                      const SizedBox(height: 20),

                      _buildLabel('Gender'),
                      _buildInputField(controller: _genderController, hint: 'Gender'),
                      const SizedBox(height: 20),

                      _buildLabel('Parent/Guardian Name'),
                      _buildInputField(controller: _parentNameController, hint: 'Full Name'),
                      const SizedBox(height: 20),

                      _buildLabel('Parent Phone Number'),
                      _buildInputField(controller: _parentPhoneController, hint: 'Phone', keyboardType: TextInputType.phone),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // Next Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _handleNext(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          _StepItem(title: 'Personal details', isActive: true),
          _StepItem(title: 'ID proof', isActive: false),
          _StepItem(title: 'Your real time photo', isActive: false),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: darkTextColor)),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      height: 56,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please enter $hint';
          return null;
        },
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          filled: true,
          fillColor: fillColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: primaryBlue, width: 1)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String title;
  final bool isActive;
  const _StepItem({required this.title, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal, color: isActive ? primaryBlue : inactiveColor)),
          const SizedBox(height: 8),
          Container(height: 3, decoration: BoxDecoration(color: isActive ? primaryBlue : inactiveBarColor, borderRadius: BorderRadius.circular(2))),
        ],
      ),
    );
  }
}
