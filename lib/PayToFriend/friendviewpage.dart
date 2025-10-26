import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:teenpay/transactions-via-scanning/sendmoney.dart';
import 'reqmoneywithamt.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final String currentUsername;
  final String currentPhone;
  final String friendUsername;
  final String friendPhone;
  final String recipientUid; // UID of friend for sending money

  const PaymentHistoryScreen({
    Key? key,
    required this.currentUsername,
    required this.currentPhone,
    required this.friendUsername,
    required this.friendPhone,
    required this.recipientUid,
  }) : super(key: key);

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  String? friendName; // fetched from KYC table

  @override
  void initState() {
    super.initState();
    _fetchFriendName();
  }

  Future<void> _fetchFriendName() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('usernames')
          .doc(widget.friendUsername)
          .get();

      if (userDoc.exists) {
        final friendUid = userDoc['uid'];
        final kycDoc = await FirebaseFirestore.instance
            .collection('kyc')
            .doc(friendUid)
            .get();

        if (kycDoc.exists) {
          setState(() {
            friendName = kycDoc['name'];
          });
        }
      }
    } catch (e) {
      print('Error fetching friend name: $e');
    }
  }

  Stream<QuerySnapshot> _getTransactionsStream() {
    return FirebaseFirestore.instance
        .collection('transactions')
        .doc(widget.currentUsername)
        .collection('userTxns')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('dd MMM, hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final displayName = friendName ?? widget.friendUsername;

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
                    displayName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.friendPhone.isNotEmpty
                        ? widget.friendPhone
                        : 'No phone number',
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
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getTransactionsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allTxns = snapshot.data?.docs ?? [];
          // Filter transactions: related to friend AND status == "completed"
          final transactions = allTxns
              .where(
                (txn) =>
                    (txn['counterparty'] ?? '') == widget.friendUsername &&
                    (txn['status'] ?? '') == 'completed',
              )
              .toList()
              .reversed
              .toList(); // Reverse to show newest at bottom

          if (transactions.isEmpty) {
            return const Center(
              child: Text(
                'No transactions found between you and this user',
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            );
          }

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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SendMoneyScreen(
                      senderUsername: widget.currentUsername,
                      recipientUsername: widget.friendUsername,
                      teenPayId: widget.recipientUid,
                    ),
                  ),
                );
              },
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RequestMoneyScreen(
                      senderUsername: widget.currentUsername,
                      receiverUsername: widget.friendUsername,
                    ),
                  ),
                );
              },
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
          color: isReceived ? Colors.green.shade50 : Colors.red.shade50,
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
              style: const TextStyle(color: Colors.black87, fontSize: 15),
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
