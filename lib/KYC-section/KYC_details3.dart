import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data'; // NEW: For web image byte data
import 'package:flutter/foundation.dart' show kIsWeb; // NEW: For platform check

// Import your provider file
import 'kyc_provider.dart'; 

class KYCLivePhotoPage extends StatefulWidget {
  const KYCLivePhotoPage({super.key});

  @override
  _KYCLivePhotoPageState createState() => _KYCLivePhotoPageState();
}

class _KYCLivePhotoPageState extends State<KYCLivePhotoPage> {
  // --- STATE FOR UI ---
  // We will manage whether the photo has been taken locally for the UI state
  bool _photoTaken = false; 
  bool _isSubmitting = false; 

  // ImagePicker instance
  final ImagePicker _picker = ImagePicker();

  // --- FUNCTIONAL LOGIC FOR LIVE PHOTO CAPTURE (UPDATED FOR WEB) ---
  Future<void> _captureLivePhoto(BuildContext context) async {
    // Open device camera
    final XFile? livePhoto = await _picker.pickImage(
      source: ImageSource.camera, 
      imageQuality: 70,
    );

    if (livePhoto != null) {
      final kycProvider = Provider.of<KycProvider>(context, listen: false);
      String path = livePhoto.path;
      Uint8List? bytes;

      if (kIsWeb) {
        // FIX: Read bytes for web platform and save the byte data
        bytes = await livePhoto.readAsBytes();
        path = 'web_live_photo_uploaded'; // Placeholder path for web
      }
      
      // 1. Save the path/bytes to the provider using the updated method signature
      kycProvider.updateLivePhoto(
        photoPath: path,
        photoBytes: bytes, // Pass bytes (will be null on mobile)
      );

      // 2. Update local UI state
      setState(() {
        _photoTaken = true; 
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Live photo captured and ready for submission!'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF008CFF),
        ),
      );
    } else {
      // User cancelled camera
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Live photo capture cancelled.')),
      );
    }
  }


  // --- FUNCTIONAL LOGIC FOR SUBMISSION (UNCHANGED) ---
  void _handleSubmit(BuildContext context) async {
    if (!_photoTaken) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please take a live photo first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final kycProvider = Provider.of<KycProvider>(context, listen: false);

    await Future.delayed(const Duration(seconds: 2));

    if (kycProvider.isReadyForSubmission) { 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ KYC Submission Successful!'),
          backgroundColor: Color(0xFF008CFF),
        ),
      );
      
      kycProvider.resetKycData();
      
      // Navigate away from KYC flow (e.g., to the main dashboard)
      // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const DashboardScreen()), (route) => false);

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Submission Error: Missing data from previous steps.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    setState(() {
      _isSubmitting = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF008CFF);
    
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
                  _buildStepIndicator('Personal details', true),
                  _buildStepIndicator('ID proof', true),
                  _buildStepIndicator('Your real time photo', true), 
                ],
              ),
            ),
            
            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Title
                    const Text(
                      'Upload Live-photo',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Instructions List
                    _buildInstructionsList(),
                    const SizedBox(height: 32),
                    
                    // Camera Upload Area (Functional)
                    _buildCameraUploadArea(),
                    
                    const Spacer(),
                  ],
                ),
              ),
            ),
            
            // Next Button (Final Submit)
            Container(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _handleSubmit(context),
                  
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Next (Submit)',
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

  // --- Helper Widgets Below ---

  Widget _buildStepIndicator(String title, bool isActive) {
    const Color activeColor = Color(0xFF008CFF);
    const Color inactiveColor = Color(0xFFA0A0A0);
    const Color inactiveBar = Color(0xFFE0E0E0);
    
    return Column(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveBar,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? activeColor : inactiveColor,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildInstructionsList() {
    final instructions = [
      "Make sure your entire face is clearly visible (no cropping).",
      "Use good lighting — avoid shadows or glare.",
      "Keep a neutral background (plain wall is best).",
      "Do not wear hats, sunglasses, or masks.",
      "Face the camera directly — no side angles.",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: instructions.map((instruction) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, right: 12),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF616161),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  instruction,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF616161),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCameraUploadArea() {
    return Center(
      child: GestureDetector(
        // CALLING THE CAPTURE FUNCTION
        onTap: () {
          _captureLivePhoto(context);
        },
        
        child: Container(
          width: double.infinity,
          height: 240,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _photoTaken ? const Color(0xFF008CFF) : const Color(0xFFE0E0E0),
              width: _photoTaken ? 2 : 1, 
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon changes based on photo state
              Icon(
                _photoTaken ? Icons.check_circle : Icons.camera_alt_outlined,
                size: 80,
                color: _photoTaken ? const Color(0xFF008CFF) : const Color(0xFF9E9E9E),
              ),
              const SizedBox(height: 24),
              // Status Text
              Text(
                _photoTaken ? 'Photo Captured' : 'Tap to open camera',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _photoTaken ? const Color(0xFF008CFF) : const Color(0xFF616161),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}