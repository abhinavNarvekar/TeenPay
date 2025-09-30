import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // REQUIRED for set()
import 'package:firebase_auth/firebase_auth.dart';     // REQUIRED for current user
import 'dart:typed_data'; // Required for Uint8List (Image Bytes)

class KycProvider extends ChangeNotifier {
  // --- Data from Step 1: Personal Details (8 Fields) ---
  String name = '';
  String contact = '';
  String email = '';
  String pincode = '';

  String dateOfBirth = '';
  String gender = '';
  String parentName = '';
  String parentPhone = '';

  // --- Data from Step 2: ID Proof ---
  String documentType = 'ID Card';
  String frontImagePath = '';
  String backImagePath = '';

  Uint8List? frontImageBytes;
  Uint8List? backImageBytes;

  // --- Data from Step 3: Live Photo ---
  String livePhotoPath = '';
  Uint8List? livePhotoBytes;

  // --- Step 1 Update Method (Personal Details) ---
  void updatePersonalDetails({
    required String newName,
    required String newContact,
    required String newEmail,
    required String newPincode,
    required String newDob,
    required String newGender,
    required String newParentName,
    required String newParentPhone,
  }) {
    name = newName;
    contact = newContact;
    email = newEmail;
    pincode = newPincode;
    dateOfBirth = newDob;
    gender = newGender;
    parentName = newParentName;
    parentPhone = newParentPhone;
    notifyListeners();
  }

  // --- Step 2 Update Method (ID Proof) ---
  void updateIDProof({
    required String docType,
    required String frontPath,
    required String backPath,
    required Uint8List? frontBytes,
    required Uint8List? backBytes,
  }) {
    documentType = docType;
    frontImagePath = frontPath;
    backImagePath = backPath;
    frontImageBytes = frontBytes;
    backImageBytes = backBytes;
    notifyListeners();
  }

  // Helper for button toggles in KYC_details2
  void setDocumentType(String type) {
    documentType = type;
    notifyListeners();
  }

  // --- Step 3 Update Method (Live Photo) ---
  void updateLivePhoto({
    required String photoPath,
    required Uint8List? photoBytes,
  }) {
    livePhotoPath = photoPath;
    livePhotoBytes = photoBytes;
    notifyListeners();
  }

  // --- Validation ---
  bool get isReadyForSubmission {
    // Uses contact as unique ID check (must be set by Page 1)
    return contact.isNotEmpty &&
        (frontImagePath.isNotEmpty || frontImageBytes != null) &&
        (livePhotoPath.isNotEmpty || livePhotoBytes != null);
  }

  // --- Firestore Submission (CLEANED UP) ---
  // This method now ACCEPTS the image URLs after they have been uploaded by the UI.
  Future<void> submitKycToFirestore({
    required String frontImageUrl,
    required String? backImageUrl, // backImageUrl is nullable
    required String livePhotoUrl,
  }) async {
    try {
      // Use contact as the unique document ID, or fall back to Firebase Auth UID
      final userId = contact.isNotEmpty 
          ? contact 
          : FirebaseAuth.instance.currentUser?.uid ?? 'no_auth_id';
      
      if (userId == 'no_auth_id') {
        throw Exception("User ID/Contact not available for document creation.");
      }

      await FirebaseFirestore.instance.collection('kyc').doc(userId).set({
        // Step 1: Personal Details
        'name': name,
        'contact': contact,
        'email': email,
        'pincode': pincode,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'parentName': parentName,
        'parentPhone': parentPhone,

        // Step 2 & 3: Image URLs (from Firebase Storage)
        'documentType': documentType,
        'frontImageUrl': frontImageUrl, // Permanent URL
        'backImageUrl': backImageUrl,   // Permanent URL
        'livePhotoUrl': livePhotoUrl,   // Permanent URL

        // Metadata
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint("✅ KYC data uploaded to Firestore for user: $userId");
    } catch (e) {
      debugPrint("❌ Error uploading KYC: $e");
      rethrow;
    }
  }

  // --- Reset ---
  void resetKycData() {
    name = '';
    contact = '';
    email = '';
    pincode = '';
    dateOfBirth = '';
    gender = '';
    parentName = '';
    parentPhone = '';
    documentType = 'ID Card';
    frontImagePath = '';
    backImagePath = '';
    frontImageBytes = null;
    backImageBytes = null;
    livePhotoPath = '';
    livePhotoBytes = null;
    notifyListeners();
  }
}
