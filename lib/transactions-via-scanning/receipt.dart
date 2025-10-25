import 'package:flutter/material.dart';
import '../Dashboard/dashboard_temp.dart'; // Import your dashboard screen

class ReceiptScreen extends StatelessWidget {
  final String senderUsername;
  final String recipientUsername;
  final String recipientName;
  final double amount;
  final String note;
  final String transactionId;
  final DateTime verifiedAt;

  const ReceiptScreen({
    Key? key,
    required this.senderUsername,
    required this.recipientUsername,
    required this.recipientName,
    required this.amount,
    required this.note,
    required this.transactionId,
    required this.verifiedAt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        elevation: 0.0,
        toolbarHeight: 80.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'e-Receipt',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(height: 120.0, color: Colors.blue[700]),
          ),
          Positioned(
            top: 100.0,
            left: 16.0,
            right: 16.0,
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20.0),
                    Divider(color: Colors.grey[300]),
                    const SizedBox(height: 20.0),
                    Text(
                      'Transaction Success!',
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      _formatDateTime(verifiedAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 13.0),
                    ),
                    const SizedBox(height: 30.0),
                    Text(
                      '₹ ${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    Divider(color: Colors.grey[300]),
                    const SizedBox(height: 20.0),
                    _buildTransactionDetails(),
                    const SizedBox(height: 30.0),
                    Divider(color: Colors.grey[300]),
                    const SizedBox(height: 20.0),
                    _buildActionButtons(context),
                    const SizedBox(height: 30.0),
                    _buildHomeButton(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(
            Icons.account_balance_wallet,
            color: Colors.blue[700],
            size: 24.0,
          ),
        ),
        const SizedBox(width: 12.0),
        const Text(
          'TeenPay',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionDetails() {
    return Column(
      children: [
        _buildDetailRow('Recipient', recipientName),
        const SizedBox(height: 12.0),
        _buildDetailRow('Sender', senderUsername),
        const SizedBox(height: 12.0),
        _buildDetailRow('Transaction ID', transactionId),
        const SizedBox(height: 12.0),
        _buildDetailRow('Note', note.isEmpty ? '-' : note),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14.0)),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 14.0,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Downloading receipt...')),
          ),
          icon: const Icon(Icons.download, color: Colors.blue),
          label: const Text('Download', style: TextStyle(color: Colors.blue)),
        ),
        TextButton.icon(
          onPressed: () => ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Sharing receipt...'))),
          icon: const Icon(Icons.share, color: Colors.blue),
          label: const Text('Share', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }

  Widget _buildHomeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => TeenPayDashboard(username: senderUsername),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: const Text(
          'HOME',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')} ${_monthName(dt.month)} ${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _monthName(int month) {
    const names = [
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
    return names[month - 1];
  }
}
