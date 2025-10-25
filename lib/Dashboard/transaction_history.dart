import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionHistoryPage extends StatefulWidget {
  final String username;
  const TransactionHistoryPage({Key? key, required this.username})
    : super(key: key);

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  String selectedFilter = 'All';

  // ✅ Stream to fetch user transactions
  Stream<List<Transaction>> getUserTransactions() {
    return FirebaseFirestore.instance
        .collection('transactions')
        .doc(widget.username)
        .collection('userTxns')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();

            final typeStr = (data['type'] ?? '').toString().toLowerCase();
            final note = (data['note'] ?? '').toString();
            final counterparty = data['counterparty'] ?? '';
            final counterpartyName = data['counterpartyName'] ?? '';
            final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;

            // ✅ Determine transaction type
            TransactionType txnType;
            if (typeStr == 'debit') {
              txnType = TransactionType.sent;
            } else if (typeStr == 'credit') {
              txnType = TransactionType.received;
            } else {
              txnType = TransactionType.received; // fallback
            }

            // ✅ Determine display name
            String displayName;
            if (counterpartyName.isNotEmpty) {
              displayName = counterpartyName;
            } else if (counterparty.isNotEmpty) {
              displayName = counterparty;
            } else if (note.toLowerCase().contains('wallet') ||
                note.toLowerCase().contains('add money')) {
              displayName = 'Wallet Top-up';
            } else {
              displayName = txnType == TransactionType.received
                  ? 'Money received'
                  : 'Money sent';
            }

            // ✅ Determine transaction date
            Timestamp? ts = data['verifiedAt'] ?? data['createdAt'];
            final date = ts != null ? ts.toDate() : DateTime.now();

            return Transaction(
              name: displayName,
              description: note.isNotEmpty
                  ? note
                  : (txnType == TransactionType.received
                        ? 'Money received'
                        : 'Money sent'),
              amount: amount,
              type: txnType,
              date: date,
            );
          }).toList();
        });
  }

  double calculateTotal(List<Transaction> transactions, TransactionType type) {
    return transactions
        .where((t) => t.type == type)
        .fold(0, (sum, t) => sum + t.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Transaction History',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: getUserTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No transactions found.'));
          }

          final transactions = snapshot.data!;
          final filteredTransactions = selectedFilter == 'All'
              ? transactions
              : transactions.where((t) {
                  return selectedFilter == 'Received'
                      ? t.type == TransactionType.received
                      : t.type == TransactionType.sent;
                }).toList();

          final totalReceived = calculateTotal(
            transactions,
            TransactionType.received,
          );
          final totalSent = calculateTotal(transactions, TransactionType.sent);

          return Column(
            children: [
              // 🔍 Search + Filter
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    // Search Bar (currently static, you can implement search later)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search transactions',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[400],
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Filter Tabs
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          _buildFilterTab('All'),
                          _buildFilterTab('Received'),
                          _buildFilterTab('Sent'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Summary Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildSummaryCard(
                      'Received',
                      totalReceived,
                      Colors.green,
                      Icons.arrow_downward,
                    ),
                    const SizedBox(width: 12),
                    _buildSummaryCard(
                      'Sent',
                      totalSent,
                      Colors.blue,
                      Icons.arrow_upward,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 🧾 Transaction List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    return _buildTransactionCard(filteredTransactions[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterTab(String title) {
    final isSelected = selectedFilter == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedFilter = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.black87 : Colors.grey[600],
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '₹${amount.toStringAsFixed(0)}',
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final isReceived = transaction.type == TransactionType.received;
    final color = isReceived ? Colors.green : Colors.blue;
    final icon = isReceived ? Icons.arrow_downward : Icons.arrow_upward;
    final sign = isReceived ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.name,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(transaction.date),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$sign₹${transaction.amount}',
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final month = monthNames[date.month - 1];
    final day = date.day;
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'pm' : 'am';

    return '$month $day, ${hour}:${minute}$period';
  }
}

// 📦 Transaction model
enum TransactionType { received, sent }

class Transaction {
  final String name;
  final String description;
  final double amount;
  final TransactionType type;
  final DateTime date;

  Transaction({
    required this.name,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
  });
}
