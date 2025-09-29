import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; 
import 'package:image_picker/image_picker.dart'; 
import 'dart:io'; 
import 'dart:typed_data'; 
import 'package:flutter/foundation.dart' show kIsWeb; 

import 'KYC_details3.dart'; 
import 'kyc_provider.dart'; 


class KycIdProofPage extends StatefulWidget { 
  const KycIdProofPage({super.key});

  @override
  State<KycIdProofPage> createState() => _KycIdProofPageState();
}

class _KycIdProofPageState extends State<KycIdProofPage> { 
  // Color constants
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color lightGrey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF424242);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  static const Color uploadButtonBackground = Color(0xFFF8F9FA);

  // Image picker instance
  final ImagePicker _picker = ImagePicker();

  // --- Image Pick Logic (Updated for Web) ---
  Future<void> _pickImage(BuildContext context, bool isFront) async {
    final kycProvider = Provider.of<KycProvider>(context, listen: false);
    
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 70, 
    );

    if (pickedFile != null) {
      String path = pickedFile.path;
      Uint8List? bytes;

      if (kIsWeb) {
        bytes = await pickedFile.readAsBytes();
        path = 'web_file_uploaded'; 
      }
      
      // Update the provider with the new image path/bytes
      if (isFront) {
        kycProvider.updateIDProof(
          docType: kycProvider.documentType,
          frontPath: path,
          backPath: kycProvider.backImagePath,
          frontBytes: bytes, 
          backBytes: kycProvider.backImageBytes, // Preserve
        );
      } else {
        kycProvider.updateIDProof(
          docType: kycProvider.documentType,
          frontPath: kycProvider.frontImagePath, // Preserve
          backPath: path,
          frontBytes: kycProvider.frontImageBytes, // Preserve
          backBytes: bytes,
        );
      }

      setState(() {}); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${isFront ? "Front" : "Back"} ID photo uploaded!'))
      );
    } 
  }
  
  // --- Image Clear Logic ---
  void _clearImage(BuildContext context, bool isFront) {
    final kycProvider = Provider.of<KycProvider>(context, listen: false);

    if (isFront) {
      kycProvider.updateIDProof(
        docType: kycProvider.documentType,
        frontPath: '', 
        backPath: kycProvider.backImagePath,
        frontBytes: null, 
        backBytes: kycProvider.backImageBytes,
      );
    } else {
      kycProvider.updateIDProof(
        docType: kycProvider.documentType,
        frontPath: kycProvider.frontImagePath,
        backPath: '', 
        frontBytes: kycProvider.frontImageBytes,
        backBytes: null, 
      );
    }
    setState(() {}); 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${isFront ? "Front" : "Back"} ID photo cleared.')),
    );
  }
  // -----------------------------

  // --- _handleNext function ---
  void _handleNext(BuildContext context) {
    final kycProvider = Provider.of<KycProvider>(context, listen: false);
    
    // Validate that the Front Image is uploaded (path or web bytes must exist)
    bool isFrontUploaded = kycProvider.frontImagePath.isNotEmpty || kycProvider.frontImageBytes != null;

    if (isFrontUploaded) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const KYCLivePhotoPage(), 
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload the front side of your ID proof before proceeding.'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the provider with listen: true for UI updates (colors, status)
    final kycProvider = Provider.of<KycProvider>(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_ios),
                    color: darkGrey,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.code),
                    color: darkGrey,
                  ),
                ],
              ),
            ),
            
            // Main Title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Upload KYC',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: darkGrey,
                ),
              ),
            ),
            
            // Progress Indicator Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Text(
                          'Personal details',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: lightGrey,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'ID proof',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: primaryBlue,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Your real time photo',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: lightGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Underline indicator
                  Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      Expanded(
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: primaryBlue,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              ),
            ),
            
            // Main Content Card (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Card(
                    elevation: 4,
                    color: cardBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section 1: Choose document type
                          Text(
                            'Choose document type',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: darkGrey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Document type toggle buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    kycProvider.setDocumentType('ID Card');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kycProvider.documentType == 'ID Card' ? primaryBlue : lightBlue,
                                    foregroundColor: kycProvider.documentType == 'ID Card' ? Colors.white : primaryBlue,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'ID Card',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextButton( 
                                  onPressed: () {
                                    kycProvider.setDocumentType('Aadhar Card'); 
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: kycProvider.documentType == 'Aadhar Card' ? primaryBlue : lightBlue,
                                    foregroundColor: kycProvider.documentType == 'Aadhar Card' ? Colors.white : primaryBlue,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Aadhar card',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Section 2: Upload ID proof
                          Text(
                            'Upload ID proof',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: darkGrey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Descriptive caption
                          Text(
                            'Make sure all the corners of the document are visible and add both back and front side',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: lightGrey,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Camera/Upload Buttons
                          Row(
                            children: [
                              Expanded(
                                child: _buildUploadButton(
                                  icon: Icons.camera_alt_outlined,
                                  text: kycProvider.frontImagePath.isNotEmpty || kycProvider.frontImageBytes != null ? 'Front Uploaded' : 'Front', 
                                  onTap: () => _pickImage(context, true), 
                                  imagePath: kycProvider.frontImagePath,
                                  imageBytes: kycProvider.frontImageBytes,
                                  onClear: () => _clearImage(context, true),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildUploadButton(
                                  icon: Icons.camera_alt_outlined,
                                  text: kycProvider.backImagePath.isNotEmpty || kycProvider.backImageBytes != null ? 'Back Uploaded' : 'Back(optional)',
                                  onTap: () => _pickImage(context, false), 
                                  imagePath: kycProvider.backImagePath,
                                  imageBytes: kycProvider.backImageBytes,
                                  onClear: () => _clearImage(context, false),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Next Button (fixed at the bottom)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _handleNext(context), 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
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

  // --- UPDATED Helper widget to build the upload button (Explicit Clear Button) ---
  Widget _buildUploadButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required VoidCallback onClear, // Explicit clear function
    String? imagePath, 
    Uint8List? imageBytes,
  }) {
    // Determine if we have file data (either path for mobile or bytes for web)
    bool hasFile = (imagePath != null && imagePath.isNotEmpty) || imageBytes != null;
    
    // Determine the widget to display
    Widget previewWidget;

    if (hasFile) {
      // --- Image Preview Widget ---
      Widget filePreview;
      if (kIsWeb && imageBytes != null) {
        filePreview = Image.memory(imageBytes, height: 60, width: 60, fit: BoxFit.cover);
      } else if (!kIsWeb && imagePath != null && imagePath.isNotEmpty) {
        filePreview = Image.file(
          File(imagePath),
          height: 60, width: 60, fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(icon, size: 32, color: primaryBlue), 
        );
      } else {
        filePreview = Icon(icon, size: 32, color: primaryBlue); // Fallback icon
      }
      
      // Wrap the preview in a Stack to add the clear button overlay
      previewWidget = Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: primaryBlue, width: 2), // Highlight border
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: filePreview,
            ),
          ),
          
          // The Clear Button (Small Red Circle)
          Positioned(
            top: -10, 
            right: -10,
            child: GestureDetector(
              onTap: onClear, // This calls the explicit clear function
              child: const CircleAvatar(
                radius: 10,
                backgroundColor: Colors.red,
                child: Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      );

    } else {
      // Default Icon when no file is present
      previewWidget = Icon(icon, size: 32, color: primaryBlue);
    }


    return InkWell(
      onTap: onTap, // Tapping always calls _pickImage to re-upload/replace
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: uploadButtonBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasFile ? primaryBlue : lightBlue, // Border changes color when file is present
            width: hasFile ? 2 : 1,
          ),
        ),
        child: Stack( // Use Stack to overlay the clear button
          alignment: Alignment.center, // Center the main content
          children: [
            Column( // Main Column for icon/preview and text
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 70, child: previewWidget), // Give it space for the overlay
                const SizedBox(height: 8),
                Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: darkGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            
            if (hasFile) // Only show clear button if a file is present
              Positioned(
                top: 0, // Position relative to the Container
                right: 0,
                child: GestureDetector(
                  onTap: onClear, // This calls the explicit clear function
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}