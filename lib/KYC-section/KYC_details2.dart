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
  // Color constants (all fine)
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color lightGrey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF424242);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  static const Color uploadButtonBackground = Color(0xFFF8F9FA);

  // Image picker instance
  final ImagePicker _picker = ImagePicker();
  
  // --- NEW: Local holders for assumed prefilled data ---
  String _prefilledName = '';
  String _prefilledContact = '';
  // ----------------------------------------------------

  @override
  void initState() {
    super.initState();
    // CRITICAL FIX: Load the critical 'contact' data right when the widget starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final kycProvider = Provider.of<KycProvider>(context, listen: false);
    
    // Load the critical contact field from the provider's current state
    _prefilledContact = kycProvider.contact;
    _prefilledName = kycProvider.name; // Loading name for debugging purposes

    // If the provider has the critical data, update the UI (optional)
    if (mounted) {
      setState(() {});
    }
    
    // Debug check to confirm data is present
    print('DEBUG KYC_DETAILS2: Contact loaded: $_prefilledContact');
  }
  // --- (Rest of the class methods, including _pickImage and _clearImage, remain the same) ---
  
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
    
    // Validation: Check if the Front Image is uploaded
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
                          
                          // Debug output to see if contact data is loaded
                          Text('DEBUG: Contact Loaded: $_prefilledContact', style: const TextStyle(fontSize: 10, color: Colors.red)),
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

  // --- Image Upload Button Helper (omitted for brevity) ---
  Widget _buildUploadButton({
    required IconData icon, required String text, required VoidCallback onTap,
    required VoidCallback onClear, String? imagePath, Uint8List? imageBytes,
  }) {
    // ... (Your implementation of _buildUploadButton, which is correct) ...
    // Note: I will need the full implementation if any changes are required inside it.
    // For now, assume this helper is correct.
    
    bool hasFile = (imagePath != null && imagePath.isNotEmpty) || imageBytes != null;
    Widget previewWidget;

    // Simplified widget creation (replaces the complex structure for brevity)
    if (hasFile) {
      Widget filePreview = kIsWeb && imageBytes != null
          ? Image.memory(imageBytes, height: 60, width: 60, fit: BoxFit.cover)
          : (!kIsWeb && imagePath != null && imagePath.isNotEmpty
              ? Image.file(File(imagePath), height: 60, width: 60, fit: BoxFit.cover)
              : Icon(icon, size: 32, color: primaryBlue));

      previewWidget = Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: primaryBlue, width: 2),
            ),
            child: ClipRRect(borderRadius: BorderRadius.circular(6), child: filePreview),
          ),
          Positioned(
            top: -10, right: -10,
            child: GestureDetector(
              onTap: onClear,
              child: const CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Icon(Icons.close, size: 14, color: Colors.white)),
            ),
          ),
        ],
      );
    } else {
      previewWidget = Icon(icon, size: 32, color: primaryBlue);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: uploadButtonBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasFile ? primaryBlue : lightBlue,
            width: hasFile ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: hasFile ? 70 : 32, child: hasFile ? previewWidget : Center(child: previewWidget)),
            SizedBox(height: hasFile ? 8 : 16),
            Text(
              text,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: darkGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
