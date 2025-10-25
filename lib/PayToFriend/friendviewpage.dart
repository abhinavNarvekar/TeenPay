import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Payment History',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      home: const PaymentHistoryScreen(
        currentUsername: 'abhinavnarvekar',
        friendUsername: 'friend1',
      ),
    );
  }
}

class PaymentHistoryScreen extends StatefulWidget {
  final String currentUsername;
  final String friendUsername;

  const PaymentHistoryScreen({
    Key? key,
    required this.currentUsername,
    required this.friendUsername,
  }) : super(key: key);

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  String? name;
  String? phone;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFriendDetails();
  }

  Future<void> _fetchFriendDetails() async {
    try {
      // Fetch UID from usernames table
      DocumentSnapshot usernameDoc = await FirebaseFirestore.instance
          .collection('usernames')
          .doc(widget.friendUsername)
          .get();

      if (usernameDoc.exists) {
        String uid = usernameDoc.id;

        // Fetch name from kyc table
        DocumentSnapshot kycDoc = await FirebaseFirestore.instance
            .collection('kyc')
            .doc(uid)
            .get();

        if (kycDoc.exists) {
          name = kycDoc.get('name') ?? 'Unknown';
        }

        // Fetch phone from users table
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        if (userDoc.exists) {
          phone = userDoc.get('phone') ?? 'No phone';
        }
      }
    } catch (e) {
      print('Error fetching friend details: $e');
      name = 'null';
      phone = 'null';
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Stream filtered for transactions between current user and friend
  Stream<QuerySnapshot> _getTransactionsStream() {
    return FirebaseFirestore.instance
        .collection('transactions')
        .doc(widget.currentUsername)
        .collection('userTxns')
        .where('counterparty', isEqualTo: widget.friendUsername)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  String _formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('dd MMM, hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name ?? 'Unknown User',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    phone ?? 'No phone number',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getTransactionsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No transactions found between you and this user',
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            );
          }

          final transactions = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final txn = transactions[index];
              final amount = txn['amount'].toString();
              final type = txn['type'] ?? 'unknown';
              final counterpartyName =
                  txn['counterpartyName'] ?? widget.friendUsername;
              final date = txn['createdAt'] != null
                  ? _formatDate(txn['createdAt'])
                  : 'Unknown date';
              final isReceived = type == 'credit';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    date,
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  TransactionCard(
                    title: isReceived
                        ? 'Payment from $counterpartyName'
                        : 'Payment to $counterpartyName',
                    amount: amount,
                    date: date,
                    isReceived: isReceived,
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F51B5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Pay',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F51B5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Request',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                side: BorderSide(color: Colors.grey[400]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Row(
                children: const [
                  Text(
                    'Message...',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.send, color: Colors.black54, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final String title;
  final String amount;
  final String date;
  final bool isReceived;

  const TransactionCard({
    Key? key,
    required this.title,
    required this.amount,
    required this.date,
    required this.isReceived,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isReceived ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isReceived
              ? Colors.green.shade50
              : Colors.red.shade50, // color based on type
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isReceived ? Colors.green : Colors.red,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '₹$amount',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.check_circle,
                  color: isReceived ? Colors.green : Colors.red,
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isReceived ? 'Received' : 'Paid',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                Text(
                  date,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
