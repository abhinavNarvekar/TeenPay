import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class UserQrCodePage extends StatefulWidget {
  final String username; // app username to fetch TeenPay ID
  final String? avatarUrl;

  const UserQrCodePage({Key? key, required this.username, this.avatarUrl})
    : super(key: key);

  @override
  State<UserQrCodePage> createState() => _UserQrCodePageState();
}

class _UserQrCodePageState extends State<UserQrCodePage> {
  String teenPayId = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchTeenPayId();
  }

  Future<void> _fetchTeenPayId() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usernames')
          .doc(widget.username)
          .get();

      if (!doc.exists) {
        setState(() {
          teenPayId = 'unknown_id';
          _loading = false;
        });
        return;
      }

      final data = doc.data();
      setState(() {
        teenPayId = data?['teenpay_id'] ?? 'unknown_id';
        _loading = false;
      });
    } catch (e) {
      print('Error fetching TeenPay ID: $e');
      setState(() {
        teenPayId = 'unknown_id';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              title: const Text(
                'QR Code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: const Color(0xFF0EA5E9),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          // QR Code Card
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                // User Info Row
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.white,
                                      backgroundImage: widget.avatarUrl != null
                                          ? NetworkImage(widget.avatarUrl!)
                                          : null,
                                      child: widget.avatarUrl == null
                                          ? const Icon(
                                              Icons.person,
                                              color: Color(0xFF0EA5E9),
                                              size: 24,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        teenPayId,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF0F172A),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                // QR Code
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: QrImageView(
                                    data:
                                        'teenpay://pay/$teenPayId', // Unique per user
                                    version: QrVersions.auto,
                                    size: 220.0,
                                    backgroundColor: Colors.white,
                                    errorCorrectionLevel: QrErrorCorrectLevel.H,
                                    embeddedImage: const AssetImage(
                                      'assets/teenpay_logo.png',
                                    ),
                                    embeddedImageStyle:
                                        const QrEmbeddedImageStyle(
                                          size: Size(40, 40),
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Description
                                const Text(
                                  'Scan to pay with the TeenPay app',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF475569),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/scanner');
                                  },
                                  icon: const Icon(
                                    Icons.qr_code_scanner,
                                    size: 20,
                                  ),
                                  label: const Text(
                                    'Open scanner',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF0F172A),
                                    side: const BorderSide(
                                      color: Color(0xFFCBD5E1),
                                      width: 1.5,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Share.share(
                                      'Pay me on TeenPay: teenpay://pay/$teenPayId',
                                      subject: 'My TeenPay QR Code',
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.share_outlined,
                                    size: 20,
                                  ),
                                  label: const Text(
                                    'Share QR code',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0EA5E9),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Footer
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      Text(
                        'POWERED BY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.payment,
                            color: Colors.grey[700],
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'TeenPay',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
