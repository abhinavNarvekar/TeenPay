import 'package:flutter/material.dart';
import 'dart:typed_data'; // NEW: Required for Uint8List

class KycProvider extends ChangeNotifier {
  // Data from Step 1: Personal Details
  String name = '';
  String contact = '';
  String email = '';
  String pincode = '';

  // Data from Step 2: ID Proof (File paths and byte data for web)
  String documentType = 'ID Card'; 
  String frontImagePath = '';
  String backImagePath = '';
  
  // --- FIX: New Fields for Web/Mobile Preview Data ---
  Uint8List? frontImageBytes; // Stores image data for web preview
  Uint8List? backImageBytes;  // Stores image data for web preview
  // ----------------------------------------------------

  // Data from Step 3: Live Photo
  String livePhotoPath = '';
  Uint8List? livePhotoBytes; // Optional: To preview the live photo on web/mobile

  // --- Step 1 Update Method (Personal Details) ---
  void updatePersonalDetails({
    required String newName, 
    required String newContact, 
    required String newEmail, 
    required String newPincode,
  }) {
    name = newName;
    contact = newContact;
    email = newEmail;
    pincode = newPincode;
    notifyListeners();
  }


  // --- Step 2 Update Method (ID Proof) ---
  void updateIDProof({
    required String docType,
    required String frontPath,
    required String backPath, 
    // --- FIX: Added Byte parameters for web compatibility ---
    required Uint8List? frontBytes, 
    required Uint8List? backBytes, 
    // --------------------------------------------------------
  }) {
    documentType = docType;
    frontImagePath = frontPath;
    backImagePath = backPath;
    frontImageBytes = frontBytes; // NEW
    backImageBytes = backBytes;   // NEW
    notifyListeners();
  }
  
  // Helper method for the button toggles in KYC_details2.dart
  void setDocumentType(String type) {
    documentType = type;
    notifyListeners();
  }


  // --- Step 3 Update Method (Live Photo) ---
  void updateLivePhoto({
    required String photoPath,
    required Uint8List? photoBytes, // Added byte parameter
  }) {
    livePhotoPath = photoPath;
    livePhotoBytes = photoBytes;
    notifyListeners();
  }


  // --- Final Status and Reset Methods ---

  @override
  bool get isReadyForSubmission {
    // For submission, we check if the required paths have been set.
    return name.isNotEmpty && (frontImagePath.isNotEmpty || frontImageBytes != null) && (livePhotoPath.isNotEmpty || livePhotoBytes != null);
  }

  // Method to reset all data
  void resetKycData() {
    name = '';
    contact = '';
    email = '';
    pincode = '';
    documentType = 'ID Card';
    frontImagePath = '';
    backImagePath = '';
    frontImageBytes = null; // NEW
    backImageBytes = null;  // NEW
    livePhotoPath = '';
    livePhotoBytes = null;  // NEW
    notifyListeners();
  }
}