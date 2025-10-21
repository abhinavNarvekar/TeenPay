import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TeenPay',
      theme: ThemeData(
        primaryColor: const Color(0xFF6C63FF),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF6C63FF),
        ),
      ),
      home: const PayToFriendPage(),
    );
  }
}

class PayToFriendPage extends StatefulWidget {
  const PayToFriendPage({super.key});

  @override
  State<PayToFriendPage> createState() => _PayToFriendPageState();
}

class _PayToFriendPageState extends State<PayToFriendPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Fallback dummy users
  final List<Map<String, String>> dummyUsers = [
    {'username': 'Alice', 'phone': '1234567890'},
    {'username': 'Bob', 'phone': '9876543210'},
    {'username': 'Charlie', 'phone': '5555555555'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Fetch users from Firestore, search by usernameLower and phone
  Future<List<Map<String, String>>> _fetchUsers() async {
    try {
      final usersCollection = FirebaseFirestore.instance.collection('users');

      if (_searchQuery.isEmpty) {
        // Return all users (limit 20)
        final snapshot = await usersCollection.limit(20).get();
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          return {
            'username': (data['username'] ?? 'Unknown').toString(),
            'phone': (data['phone'] ?? 'No phone').toString(),
          };
        }).toList();
      }

      final searchLower = _searchQuery.toLowerCase();

      // Search by usernameLower field
      final usernameSnap = await usersCollection
          .where('usernameLower', isGreaterThanOrEqualTo: searchLower)
          .where('usernameLower', isLessThanOrEqualTo: '${searchLower}z')
          .get();

      // Search by phone
      final phoneSnap = await usersCollection
          .where('phone', isGreaterThanOrEqualTo: _searchQuery)
          .where('phone', isLessThanOrEqualTo: '${_searchQuery}z')
          .get();

      // Combine results and remove duplicates
      final combined = <QueryDocumentSnapshot>{};
      combined.addAll(usernameSnap.docs);
      combined.addAll(phoneSnap.docs);

      return combined.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return {
          'username': (data['username'] ?? 'Unknown').toString(),
          'phone': (data['phone'] ?? 'No phone').toString(),
        };
      }).toList();
    } catch (e) {
      print('Firestore error: $e');
      return dummyUsers; // fallback
    }
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
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by username or phone number',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 15,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF6C63FF),
                  size: 24,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(fontSize: 15),
            ),
          ),

          // Users List
          Expanded(
            child: FutureBuilder<List<Map<String, String>>>(
              future: _fetchUsers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6C63FF),
                    ),
                  );
                }

                final users = snapshot.data!;

                if (users.isEmpty) {
                  return Center(
                    child: Text(
                      'No users found',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final username = users[index]['username']!;
                    final phone = users[index]['phone']!;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF6C63FF),
                          child: Text(
                            username[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(username),
                        subtitle: Text(phone),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ConfirmPaymentPage(username: username, uid: phone),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ConfirmPaymentPage extends StatelessWidget {
  final String username;
  final String uid;

  const ConfirmPaymentPage({super.key, required this.username, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Payment'),
        backgroundColor: const Color(0xFF6C63FF),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.payment, size: 80, color: Color(0xFF6C63FF)),
            const SizedBox(height: 24),
            Text(
              'Pay to: $username',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'UID: $uid',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
