import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teenpay/PayToFriend/friendviewpage.dart'; // PaymentHistoryScreen

class PayToFriendPage extends StatefulWidget {
  final String currentUid;
  const PayToFriendPage({super.key, required this.currentUid});

  @override
  State<PayToFriendPage> createState() => _PayToFriendPageState();
}

class _PayToFriendPageState extends State<PayToFriendPage> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, String>? _friendResult;
  bool _isLoading = false;
  String _errorMessage = '';
  String _senderPhone = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserDetails();
  }

  // Fetch sender's username and phone from Firestore
  Future<void> _fetchCurrentUserDetails() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUid)
          .get();

      if (userDoc.exists) {
        _senderPhone = userDoc.get('phone') ?? '';
      }
    } catch (e) {
      print('Error fetching sender details: $e');
    }
  }

  Future<void> _searchFriend() async {
    String query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _friendResult = null;
    });

    try {
      if (!query.startsWith('+')) query = '+91$query';

      final contactDoc = await FirebaseFirestore.instance
          .collection('contacts')
          .doc(query)
          .get();

      if (contactDoc.exists && contactDoc['uid'] != widget.currentUid) {
        final uid = contactDoc['uid'];

        // Fetch name from KYC
        final kycDoc = await FirebaseFirestore.instance
            .collection('kyc')
            .doc(uid)
            .get();

        final name = kycDoc.exists
            ? kycDoc['name'] ?? 'Unknown User'
            : 'Unknown User';

        _friendResult = {'uid': uid, 'name': name, 'phone': query};
      } else {
        _errorMessage = 'No user found';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    }

    setState(() => _isLoading = false);
  }

  // Navigate to PaymentHistoryScreen with full sender + receiver info
  void _onFriendSelected(Map<String, String> friend) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentHistoryScreen(
          senderUid: widget.currentUid,
          currentPhone: _senderPhone,
          recipientUid: friend['uid']!,
          recipientName: friend['name']!, // from KYC
          friendPhone: friend['phone'] ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Pay to Friend',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF6C63FF),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Enter  phone number',
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.search,
                        color: Color(0xFF6C63FF),
                        size: 22,
                      ),
                    ),
                    onSubmitted: (_) => _searchFriend(),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_forward,
                    color: Color(0xFF6C63FF),
                  ),
                  onPressed: _searchFriend,
                ),
              ],
            ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            ),

          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),

          if (_friendResult != null)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF6C63FF),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  _friendResult!['name']!.isNotEmpty
                      ? _friendResult!['name']!
                      : _friendResult!['phone']!,
                ),
                subtitle: _friendResult!['phone']!.isNotEmpty
                    ? Text(_friendResult!['phone']!)
                    : null,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _onFriendSelected(_friendResult!),
              ),
            ),
        ],
      ),
    );
  }
}
