import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data'; 
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'dart:io'; 

// --- FIREBASE IMPORTS ---
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
// --------------------------

// Import your provider file
import 'kyc_provider.dart'; 

class KYCLivePhotoPage extends StatefulWidget {
  const KYCLivePhotoPage({super.key});

  @override
  _KYCLivePhotoPageState createState() => _KYCLivePhotoPageState();
}

class _KYCLivePhotoPageState extends State<KYCLivePhotoPage> {
  // --- STATE FOR UI ---
  bool _photoTaken = false; 
  bool _isSubmitting = false; 

  final ImagePicker _picker = ImagePicker();
  
  static const Color primaryBlue = Color(0xFF008CFF);


  // --- Helper Function for Firebase Storage Upload ---
  Future<String?> _uploadImage(String path, Uint8List? bytes, String storagePath) async {
    // Check if we have data to upload (either a real path OR bytes)
    if (path.isEmpty && bytes == null) return null;

    final ref = FirebaseStorage.instance.ref().child('kyc_uploads').child(storagePath);
    
    final UploadTask uploadTask;
    
    if (kIsWeb && bytes != null) {
      // Web/Desktop Upload
      uploadTask = ref.putData(bytes);
    } else if (path.isNotEmpty) {
      // Mobile Upload
      uploadTask = ref.putFile(File(path));
    } else {
      return null;
    }
    
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }


  // --- FUNCTIONAL LOGIC FOR LIVE PHOTO CAPTURE ---
  Future<void> _captureLivePhoto(BuildContext context) async {
    final XFile? livePhoto = await _picker.pickImage(
      source: ImageSource.camera, 
      imageQuality: 70,
    );

    if (livePhoto != null) {
      final kycProvider = Provider.of<KycProvider>(context, listen: false);
      String path = livePhoto.path;
      Uint8List? bytes;

      if (kIsWeb) {
        bytes = await livePhoto.readAsBytes();
        path = 'web_live_photo_uploaded';
      }
      
      kycProvider.updateLivePhoto(photoPath: path, photoBytes: bytes);

      setState(() {
        _photoTaken = true; 
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Live photo captured and ready for submission!'),
          duration: Duration(seconds: 2),
          backgroundColor: primaryBlue,
        ),
      );
    } 
  }


  // --- FINAL SUBMISSION LOGIC (Updated to pull all 8 fields) ---
  void _handleSubmit(BuildContext context) async {
    if (!_photoTaken) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please take a live photo first.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final kycProvider = Provider.of<KycProvider>(context, listen: false);
    
    // CRITICAL: Get User ID/Contact
    // Using contact as the document ID because it must be unique and is available from the form.
    final userId = kycProvider.contact.isNotEmpty ? kycProvider.contact : 'kyc_doc_${DateTime.now().millisecondsSinceEpoch}';

    // Validation Check (Will fail if fields on page 1 or 2 were skipped)
    if (!kycProvider.isReadyForSubmission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submission Error: Missing data from previous steps.'), backgroundColor: Colors.red),
      );
      setState(() { _isSubmitting = false; });
      return;
    }
    
    try {
      // 1. Upload Images to Firebase Storage (Uploading all three potential files)
      final frontImageUrl = await _uploadImage(kycProvider.frontImagePath, kycProvider.frontImageBytes, '$userId/front_id');
      final livePhotoUrl = await _uploadImage(kycProvider.livePhotoPath, kycProvider.livePhotoBytes, '$userId/live_photo');
      
      String? backImageUrl;
      if (kycProvider.backImagePath.isNotEmpty || kycProvider.backImageBytes != null) {
          backImageUrl = await _uploadImage(kycProvider.backImagePath, kycProvider.backImageBytes, '$userId/back_id');
      }

      // 2. Prepare the COMPLETE Data Map for the Firestore KYC collection
      final kycData = {
          // Identifiers & Status
          'userId': userId,
          'submissionDate': FieldValue.serverTimestamp(),
          'kycStatus': 'Pending Verification',
          
          // --- ALL 8 PERSONAL DETAILS (Now saved from KYC_details1b) ---
          'name': kycProvider.name,
          'contact': kycProvider.contact,
          'email': kycProvider.email,
          'pincode': kycProvider.pincode,
          'dateOfBirth': kycProvider.dateOfBirth, 
          'gender': kycProvider.gender,         
          'parentName': kycProvider.parentName, 
          'parentPhone': kycProvider.parentPhone,
          
          // --- DOCUMENT & IMAGE DATA ---
          'documentType': kycProvider.documentType,
          'frontImageUrl': frontImageUrl,
          'backImageUrl': backImageUrl, 
          'livePhotoUrl': livePhotoUrl,
      };

      // 3. Write Data to Firestore
      await FirebaseFirestore.instance
          .collection('KYC') 
          .doc(userId)
          .set(kycData);

      // 4. Success & Cleanup
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ KYC Submission Successful! Document created in Firestore.'), backgroundColor: primaryBlue),
      );
      kycProvider.resetKycData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission Failed: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() { _isSubmitting = false; });
    }
  }


  @override
  Widget build(BuildContext context) {
    // ... (rest of the build method is unchanged)
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Upload KYC', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600)),
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
                    const Text('Upload Live-photo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 24),
                    
                    _buildInstructionsList(),
                    const SizedBox(height: 32),
                    
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : const Text('Next (Submit)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets Below (Unchanged) ---

  Widget _buildStepIndicator(String title, bool isActive) {
    const Color activeColor = Color(0xFF008CFF);
    const Color inactiveColor = Color(0xFFA0A0A0);
    const Color inactiveBar = Color(0xFFE0E0E0);
    
    return Expanded(
      child: Column(
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
      ),
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
                width: 6, height: 6,
                decoration: const BoxDecoration(color: Color(0xFF616161), shape: BoxShape.circle),
              ),
              Expanded(
                child: Text(
                  instruction,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF616161), height: 1.5),
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
              Icon(
                _photoTaken ? Icons.check_circle : Icons.camera_alt_outlined,
                size: 80,
                color: _photoTaken ? const Color(0xFF008CFF) : const Color(0xFF9E9E9E),
              ),
              const SizedBox(height: 24),
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