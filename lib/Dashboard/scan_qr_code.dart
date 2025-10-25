import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import '../transactions-via-scanning/sendmoney.dart'; // Import your SendMoneyScreen here

class QrScannerPage extends StatefulWidget {
  final String senderUsername;

  const QrScannerPage({Key? key, required this.senderUsername})
    : super(key: key);

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scannedData;
  bool _navigating = false; // Prevents multiple navigations

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
      if (_navigating) return; // Avoid duplicate scans
      final code = scanData.code;
      if (code == null) return;

      setState(() => scannedData = code);
      controller.pauseCamera();

      // Parse username from scanned QR
      String? scannedUsername;
      try {
        final uri = Uri.parse(code);
        if (uri.scheme == 'teenpay' && uri.host == 'pay') {
          scannedUsername = uri.pathSegments.isNotEmpty
              ? uri.pathSegments.first.replaceAll('@teenpay', '')
              : null;
        }
      } catch (e) {
        scannedUsername = null;
      }

      // ✅ Check for valid username
      if (scannedUsername == null) {
        _showResultDialog('Invalid QR Code');
        return;
      }

      // ✅ Prevent self-sending
      if (scannedUsername == widget.senderUsername) {
        _showResultDialog("You can't send money to yourself.");
        return;
      }

      // Fetch teenpay_id from Firestore
      String teenPayId = 'unknown_id';
      try {
        final doc = await FirebaseFirestore.instance
            .collection('usernames')
            .doc(scannedUsername)
            .get();
        if (doc.exists) {
          teenPayId = doc['teenpay_id'] ?? 'unknown_id';
        }
      } catch (e) {
        teenPayId = 'unknown_id';
      }

      // Navigate to SendMoneyScreen
      if (mounted) {
        setState(() => _navigating = true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SendMoneyScreen(
              senderUsername: widget.senderUsername,
              recipientUsername: scannedUsername!,
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
// adb pair 192.168.0.108:42365  
// adb connect 192.168.0.108:38619   