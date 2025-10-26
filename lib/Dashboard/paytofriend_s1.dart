import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:teenpay/transactions-via-scanning/sendmoney.dart'; // Your SendMoneyScreen

class PayToFriendPage extends StatefulWidget {
  final String currentUid;
  const PayToFriendPage({super.key, required this.currentUid});

  @override
  State<PayToFriendPage> createState() => _PayToFriendPageState();
}

class _PayToFriendPageState extends State<PayToFriendPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _suggestions = [];
  bool _isLoading = false;
  List<String> _phoneContacts = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadPhoneContacts();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _fetchSuggestions(_searchController.text.trim());
  }

  Future<void> _loadPhoneContacts() async {
    // Request permission and load contacts
    if (await FlutterContacts.requestPermission()) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      List<String> phoneNumbers = [];
      for (var contact in contacts) {
        for (var phone in contact.phones) {
          String number = _normalizeNumber(phone.number);
          if (number.isNotEmpty) phoneNumbers.add(number);
        }
      }
      setState(() => _phoneContacts = phoneNumbers);
    }
  }

  String _normalizeNumber(String number) {
    // Remove +, spaces, -, etc.
    return number.replaceAll(RegExp(r'\D'), '');
  }

  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty || _phoneContacts.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final firestore = FirebaseFirestore.instance;
      final results = <Map<String, String>>[];

      String searchNumber = _normalizeNumber(query);

      // Get current user's phone number (to skip self)
      final currentUserDoc =
          await firestore.collection('contacts').doc(widget.currentUid).get();
      String? currentUserNumber;
      if (currentUserDoc.exists) {
        currentUserNumber =
            currentUserDoc.id.replaceAll(RegExp(r'\D'), ''); // digits only
      }

      // Fetch all registered contacts once (for efficiency)
      final registeredContacts = await firestore.collection('contacts').get();

      for (var doc in registeredContacts.docs) {
        String firestoreNumber = doc.id.replaceAll(RegExp(r'\D'), '');

        // Check if the number exists in the user's phone contacts
        bool isInPhoneContacts = _phoneContacts.any((num) {
          String cleaned = _normalizeNumber(num);
          return cleaned.endsWith(firestoreNumber);
        });

        // Apply filters
        if (isInPhoneContacts &&
            firestoreNumber.contains(searchNumber) &&
            firestoreNumber != currentUserNumber) {
          results.add({
            'uid': doc['uid'],
            'username': doc.data().containsKey('username') ? doc['username'] : '',
            'phone': doc.id,
          });
        }
      }

      setState(() => _suggestions = results);
    } catch (e) {
      print('Error fetching suggestions: $e');
    }

    setState(() => _isLoading = false);
  }

  void _onFriendSelected(Map<String, String> friend) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SendMoneyScreen(
          senderUsername: widget.currentUid,
          recipientUsername:
              friend['username']!.isNotEmpty ? friend['username']! : friend['phone']!,
          teenPayId: friend['uid']!,
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
          // Search Bar
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
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by contact number',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF6C63FF), size: 24),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _suggestions = []);
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 15),
            ),
          ),

          // Suggestions List
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
                )
              : Expanded(
                  child: _suggestions.isEmpty
                      ? const Center(child: Text('No friends found'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _suggestions.length,
                          itemBuilder: (context, index) {
                            final friend = _suggestions[index];
                            final displayName = friend['username']!.isNotEmpty
                                ? friend['username']!
                                : friend['phone']!;
                            final displayPhone = friend['phone'] ?? '';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF6C63FF),
                                  child: Text(
                                    displayName[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(displayName),
                                subtitle:
                                    displayPhone.isNotEmpty ? Text(displayPhone) : null,
                                trailing:
                                    const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () => _onFriendSelected(friend),
                              ),
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }
}
