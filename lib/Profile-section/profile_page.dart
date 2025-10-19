import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../welcome_screen.dart'; // Adjust path if needed
import 'qr_code_unique.dart'; // ✅ Add correct import path for your QR screen

class ProfileScreen extends StatefulWidget {
  final String? username;

  const ProfileScreen({Key? key, this.username}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String displayName = 'User';
  String contact = 'Not available';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      if (widget.username == null) return;

      // Step 1: Get UID from usernames collection
      final usernameDoc = await FirebaseFirestore.instance
          .collection('usernames')
          .doc(widget.username!)
          .get();

      if (!usernameDoc.exists) return;

      final uid = usernameDoc.data()?['uid'] as String?;
      if (uid == null) return;

      // Step 2: Get user data from kyc collection using UID
      final kycDoc = await FirebaseFirestore.instance
          .collection('kyc')
          .doc(uid)
          .get();

      if (!kycDoc.exists) return;

      final kycData = kycDoc.data();
      setState(() {
        displayName = kycData?['name'] ?? kycData?['fullName'] ?? 'User';
        contact = kycData?['contact'] ?? 'Not available';
        _loading = false;
      });
    } catch (e) {
      print('Error fetching profile data: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            backgroundColor: Colors.grey[50],
            body: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileCard(),
                      _buildMainOptionsList(context),
                      _buildGeneralSection(),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 70,
                  child: Center(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text(
                              'Are you sure you want to logout?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // close dialog
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const WelcomeScreen(),
                                    ),
                                    (route) => false,
                                  );
                                },
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32.0,
                          vertical: 12.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildProfileCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.cyan[100]!, Colors.blue[300]!],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30.0),
          bottomRight: Radius.circular(30.0),
        ),
      ),
      padding: const EdgeInsets.all(24.0),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  color: Colors.black87,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TeenPay ID: ${widget.username ?? 'user'}@teenpay',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    Text(
                      'Contact No: $contact',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 12.0),
                    Chip(
                      backgroundColor: Colors.green[100],
                      avatar: Icon(
                        Icons.check_circle,
                        color: Colors.green[700],
                        size: 18.0,
                      ),
                      label: Text(
                        'Verified account',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontSize: 12.0,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 40.0,
                  backgroundColor: Colors.blue[50],
                  child: Icon(
                    Icons.person,
                    size: 40.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainOptionsList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // ✅ Your QR Code navigation
          ListTile(
            leading: const Icon(Icons.qr_code, size: 28.0),
            title: const Text(
              'Your QR code',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Use to receive money from TeenPay app'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              if (widget.username != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UserQrCodePage(username: widget.username!),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.language, size: 28.0),
            title: const Text(
              'Language',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Switch to different languages'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings, size: 28.0),
            title: const Text(
              'Settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'General',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.article_outlined),
                title: const Text('Terms & Conditions'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.headset_mic_outlined),
                title: const Text('Customer Services'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
