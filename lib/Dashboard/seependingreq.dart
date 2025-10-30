import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../transactions-via-scanning/sendmoney.dart'; // Your SendMoneyScreen import

class PendingRequestsPage extends StatefulWidget {
  final String username;

  const PendingRequestsPage({Key? key, required this.username})
    : super(key: key);

  @override
  State<PendingRequestsPage> createState() => _PendingRequestsPageState();
}

class _PendingRequestsPageState extends State<PendingRequestsPage> {
  bool isReceivedSelected = true;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Pending Requests',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildToggleButtons(),
              ],
            ),
          ),
          Expanded(child: _buildRequestsList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search requests',
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildToggleButton('Received', isReceivedSelected, () {
            setState(() {
              isReceivedSelected = true;
            });
          }),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildToggleButton('Sent', !isReceivedSelected, () {
            setState(() {
              isReceivedSelected = false;
            });
          }),
        ),
      ],
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey[200],
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getRequestsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No ${isReceivedSelected ? "received" : "sent"} requests',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        List<QueryDocumentSnapshot> filteredDocs = snapshot.data!.docs.where((
          doc,
        ) {
          if (searchQuery.isEmpty) return true;
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String otherUsername = isReceivedSelected
              ? (data['senderUsername'] ?? '').toLowerCase()
              : (data['receiverUsername'] ?? '').toLowerCase();
          String note = (data['note'] ?? '').toLowerCase();
          return otherUsername.contains(searchQuery) ||
              note.contains(searchQuery);
        }).toList();

        filteredDocs.sort((a, b) {
          Timestamp t1 = a['createdAt'] ?? Timestamp.now();
          Timestamp t2 = b['createdAt'] ?? Timestamp.now();
          return t2.compareTo(t1);
        });

        if (filteredDocs.isEmpty) {
          return Center(
            child: Text(
              'No results found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> data =
                filteredDocs[index].data() as Map<String, dynamic>;
            data['requestId'] = filteredDocs[index].id;
            return RequestCard(
              data: data,
              isReceived: isReceivedSelected,
              currentUser: widget.username,
            );
          },
        );
      },
    );
  }

  Stream<QuerySnapshot> _getRequestsStream() {
    if (isReceivedSelected) {
      return FirebaseFirestore.instance
          .collection('requests')
          .where('receiverUsername', isEqualTo: widget.username)
          .where('status', isEqualTo: 'pending')
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('requests')
          .where('senderUsername', isEqualTo: widget.username)
          .where('status', isEqualTo: 'pending')
          .snapshots();
    }
  }
}

class RequestCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isReceived;
  final String currentUser;

  const RequestCard({
    Key? key,
    required this.data,
    required this.isReceived,
    required this.currentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String otherUsername = isReceived
        ? data['senderUsername'] ?? 'Unknown'
        : data['receiverUsername'] ?? 'Unknown';
    double amount = (data['amount'] ?? 0).toDouble();
    String note = data['note'] ?? '';
    Timestamp? timestamp = data['createdAt'];
    String requestId = data['requestId'];
    bool isCompleted = (data['status'] ?? '') == 'completed';

    String displayAmount = isReceived
        ? '₹${amount.toStringAsFixed(0)}'
        : '- ₹${amount.toStringAsFixed(0)}';
    String formattedDate = _formatDate(timestamp);

    return GestureDetector(
      onTap: isCompleted
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SendMoneyScreen(
                    senderUsername: currentUser,
                    recipientUsername: otherUsername,
                    teenPayId: '',
                    prefillAmount: amount,
                    prefillNote: note,
                    requestId: requestId,
                  ),
                ),
              );
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isCompleted ? Colors.grey[100] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.blue[100],
            child: Text(
              otherUsername.isNotEmpty ? otherUsername[0].toUpperCase() : '?',
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            otherUsername,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          subtitle: Text(
            note,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                displayAmount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isReceived ? Colors.black : Colors.red[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedDate,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '';
    DateTime dateTime = timestamp.toDate();
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));
    DateTime messageDate = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );
    String timeStr = DateFormat('h:mm a').format(dateTime);

    if (messageDate == today) return 'Today • $timeStr';
    if (messageDate == yesterday) return 'Yesterday • $timeStr';
    return '${DateFormat('MMM d').format(dateTime)} • $timeStr';
  }
}
