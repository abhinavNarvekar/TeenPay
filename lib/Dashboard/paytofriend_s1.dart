import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String _senderUsername = '';
  String _senderPhone = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserDetails();
  }

  // Fetch sender's username and phone from Firestore
  Future<void> _fetchCurrentUserDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usernames')
          .doc(widget.currentUid)
          .get();

      if (doc.exists) {
        _senderUsername = doc.id;

        // Fetch sender's phone
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.currentUid)
            .get();

        if (userDoc.exists) {
          _senderPhone = userDoc.get('phone') ?? '';
        }
      } else {
        _senderUsername = widget.currentUid;
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
      final firestore = FirebaseFirestore.instance;
      Map<String, String>? result;

      // 1️⃣ Search by username
      final usernameDoc = await firestore
          .collection('usernames')
          .doc(query)
          .get();
      if (usernameDoc.exists && usernameDoc.id != _senderUsername) {
        result = {
          'uid': usernameDoc['uid'],
          'username': usernameDoc.id,
          'phone': '', // will fetch below
        };

        final userDoc = await firestore
            .collection('users')
            .doc(usernameDoc['uid'])
            .get();
        if (userDoc.exists) result['phone'] = userDoc.get('phone') ?? '';
      }

      // 2️⃣ Search by phone number if username search failed
      if (result == null) {
        if (!query.startsWith('+')) query = '+91$query';

        final contactDoc = await firestore
            .collection('contacts')
            .doc(query)
            .get();
        if (contactDoc.exists && contactDoc['uid'] != widget.currentUid) {
          final uid = contactDoc['uid'];

          // Fetch username from usernames collection
          final userQuery = await firestore
              .collection('usernames')
              .where('uid', isEqualTo: uid)
              .limit(1)
              .get();

          String username = '';
          if (userQuery.docs.isNotEmpty) username = userQuery.docs.first.id;

          result = {'uid': uid, 'username': username, 'phone': contactDoc.id};
        }
      }

      if (result != null) {
        _friendResult = result;
      } else {
        _errorMessage = 'No user found for "$query".';
      }
    } catch (e) {
      _errorMessage = 'Error searching user: $e';
    }

    setState(() => _isLoading = false);
  }

  // Navigate to PaymentHistoryScreen with full sender + receiver info
  void _onFriendSelected(Map<String, String> friend) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentHistoryScreen(
          currentUsername: _senderUsername,
          currentPhone: _senderPhone,
          friendUsername: friend['username']!,
          friendPhone: friend['phone'] ?? '',
          recipientUid: friend['uid']!,
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
                      hintText: 'Enter username or phone number',
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
                  _friendResult!['username']!.isNotEmpty
                      ? _friendResult!['username']!
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
