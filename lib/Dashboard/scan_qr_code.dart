import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../transactions-via-scanning/sendmoney.dart';

class QrScannerPage extends StatefulWidget {
  final String senderUid; // ✅ changed from username → UID

  const QrScannerPage({Key? key, required this.senderUid}) : super(key: key);

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  String? scannedData;
  bool _navigating = false;

  @override
  void reassemble() {
    super.reassemble();
    if (mounted) {
      controller?.pauseCamera();
      controller?.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) async {
      if (_navigating) return;

      final code = scanData.code;
      if (code == null) return;

      setState(() => scannedData = code);
      controller.pauseCamera();

      // ✅ STEP 1: Extract UID from QR
      String? recipientUid;

      try {
        final uri = Uri.parse(code);
        if (uri.scheme == 'teenpay' && uri.host == 'pay') {
          recipientUid = uri.pathSegments.isNotEmpty
              ? uri.pathSegments.first
              : null;
        }
      } catch (e) {
        recipientUid = null;
      }

      // ✅ STEP 2: Validate QR
      if (recipientUid == null) {
        _showResultDialog('Invalid QR Code');
        return;
      }

      // ✅ STEP 3: Prevent self transfer
      if (recipientUid == widget.senderUid) {
        _showResultDialog("You can't send money to yourself.");
        return;
      }

      // ✅ STEP 4: Fetch user data from Firestore
      String recipientUsername = '';
      String teenPayId = '';

      try {
        final walletDoc = await FirebaseFirestore.instance
            .collection('wallets')
            .doc(recipientUid)
            .get();

        if (!walletDoc.exists) {
          _showResultDialog("Wallet not found");
          return;
        }

        final walletData = walletDoc.data() as Map<String, dynamic>;

        teenPayId = walletData['teenpay_id'] ?? 'unknown_id';
      } catch (e) {
        _showResultDialog("Error fetching user");
        return;
      }

      // ✅ STEP 5: Navigate to SendMoneyScreen
      if (mounted) {
        setState(() => _navigating = true);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SendMoneyScreen(
              senderUid: widget.senderUid,
              recipientUid: recipientUid!,
              teenPayId: teenPayId,
            ),
          ),
        );
      }
    });
  }

  void _showResultDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('QR Code Scan Result'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller?.resumeCamera();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Scan QR Code",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0EA5E9),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: const Color(0xFF0EA5E9),
                borderRadius: 12,
                borderLength: 32,
                borderWidth: 8,
                cutOutSize: 260,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                scannedData == null
                    ? 'Align the QR within the frame'
                    : 'Scanned: $scannedData',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
