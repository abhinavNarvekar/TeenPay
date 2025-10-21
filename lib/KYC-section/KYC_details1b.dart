import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'kyc_provider.dart';
import 'kyc_details2.dart';

// --- GLOBAL COLORS (Kept for styling) ---
const Color primaryBlue = Color(0xFF2196F3);
const Color fillColor = Color(0xFFE3F2FD);
const Color darkTextColor = Colors.black87;
const Color inactiveColor = Color(0xFFA0A0A0);
const Color inactiveBarColor = Color(0xFFE0E0E0);
// ----------------------------------------

class KycDetails1bPage extends StatefulWidget {
  const KycDetails1bPage({super.key});

  @override
  State<KycDetails1bPage> createState() => _KycDetails1bPageState();
}

class _KycDetails1bPageState extends State<KycDetails1bPage> {
  final _formKey = GlobalKey<FormState>();

  final _dobController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();

  String? _selectedGender; // <-- new variable for gender

  @override
  void dispose() {
    _dobController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    super.dispose();
  }

  // --- DOB Picker with age restriction ---
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2005, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      helpText: 'Select your Date of Birth',
    );

    if (pickedDate != null) {
      // ✅ Calculate age difference
      final today = DateTime.now();
      int age = today.year - pickedDate.year;
      if (today.month < pickedDate.month ||
          (today.month == pickedDate.month && today.day < pickedDate.day)) {
        age--;
      }

      if (age < 14) {
        // ❌ Show error if user is under 14
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be at least 14 years old to continue.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // ✅ If age >= 14, set date
      setState(() {
        _dobController.text =
            "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
      });
    }
  }

  void _handleNext(BuildContext context, KycProvider kycProvider) {
    if (_formKey.currentState!.validate()) {
      if (_selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your gender')),
        );
        return;
      }

      // Save all fields into provider
      kycProvider.updatePersonalDetails(
        newName: kycProvider.name,
        newContact: kycProvider.contact,
        newEmail: kycProvider.email,
        newPincode: kycProvider.pincode,
        newDob: _dobController.text,
        newGender: _selectedGender!,
        newParentName: _parentNameController.text,
        newParentPhone: _parentPhoneController.text,
      );

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
    return Consumer<KycProvider>(
      builder: (context, kycProvider, child) {
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
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
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
                          const Text(
                            'Enter Your Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: darkTextColor,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // --- DOB Field with mini calendar picker ---
                          _buildLabel('Date of Birth'),
                          GestureDetector(
                            onTap: () => _pickDate(context),
                            child: AbsorbPointer(
                              child: _buildInputField(
                                controller: _dobController,
                                hint: 'DD/MM/YYYY',
                                keyboardType: TextInputType.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // --- Gender Dropdown ---
                          _buildLabel('Gender'),
                          Container(
                            height: 56,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: fillColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              hint: const Text('Select Gender'),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Male',
                                  child: Text('Male'),
                                ),
                                DropdownMenuItem(
                                  value: 'Female',
                                  child: Text('Female'),
                                ),
                                DropdownMenuItem(
                                  value: 'Other',
                                  child: Text('Other'),
                                ),
                              ],
                              validator: (value) =>
                                  value == null ? 'Please select gender' : null,
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          _buildLabel('Parent/Guardian name'),
                          _buildInputField(
                            controller: _parentNameController,
                            hint: 'Full Name',
                          ),
                          const SizedBox(height: 20),

                          _buildLabel('Parents Phone No'),
                          _buildInputField(
                            controller: _parentPhoneController,
                            hint: 'Phone No',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _handleNext(context, kycProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkTextColor,
        ),
      ),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primaryBlue, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
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
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? primaryBlue : inactiveColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: isActive ? primaryBlue : inactiveBarColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
