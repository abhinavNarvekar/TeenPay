import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scratcher/scratcher.dart';
import 'dart:math';
import 'dashboard_temp.dart'; // ✅ Make sure this points to your dashboard file

class RewardsPage extends StatefulWidget {
  final String senderUsername;
  const RewardsPage({Key? key, required this.senderUsername}) : super(key: key);

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  double totalPoints = 0.0;
  List<Map<String, dynamic>> scratchCards = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRewardsData();
  }

  Future<void> _loadRewardsData() async {
    try {
      final userRewardDoc = await _firestore
          .collection('rewards')
          .doc(widget.senderUsername)
          .get();

      double points = (userRewardDoc.data()?['totalPoints'] ?? 0).toDouble();

      final cardsSnapshot = await _firestore
          .collection('rewards')
          .doc(widget.senderUsername)
          .collection('scratchCards')
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> cards = [];
      for (var doc in cardsSnapshot.docs) {
        cards.add({'id': doc.id, ...doc.data()});
      }

      int availableCards = (points / 10).floor();
      int existingCards = cards.length;

      if (availableCards > existingCards) {
        for (int i = existingCards; i < availableCards; i++) {
          await _firestore
              .collection('rewards')
              .doc(widget.senderUsername)
              .collection('scratchCards')
              .add({
                'claimed': false,
                'createdAt': FieldValue.serverTimestamp(),
                'cardNumber': i + 1,
              });
        }

        final updatedSnapshot = await _firestore
            .collection('rewards')
            .doc(widget.senderUsername)
            .collection('scratchCards')
            .orderBy('createdAt', descending: true)
            .get();

        cards = [];
        for (var doc in updatedSnapshot.docs) {
          cards.add({'id': doc.id, ...doc.data()});
        }
      }

      setState(() {
        totalPoints = points;
        scratchCards = cards;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading rewards: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _claimReward(String cardId, int cashbackAmount) async {
    try {
      await _firestore
          .collection('rewards')
          .doc(widget.senderUsername)
          .collection('scratchCards')
          .doc(cardId)
          .update({
            'claimed': true,
            'claimedAt': FieldValue.serverTimestamp(),
            'cashbackAmount': cashbackAmount,
          });

      final walletDoc = await _firestore
          .collection('wallets')
          .doc(widget.senderUsername)
          .get();
      double currentBalance = (walletDoc.data()?['balance'] ?? 0).toDouble();

      await _firestore.collection('wallets').doc(widget.senderUsername).update({
        'balance': currentBalance + cashbackAmount,
      });

      await _firestore
          .collection('transactions')
          .doc(widget.senderUsername)
          .collection('userTxns')
          .add({
            'amount': cashbackAmount,
            'counterparty': 'system',
            'counterpartyName': 'Scratch Card Reward',
            'createdAt': FieldValue.serverTimestamp(),
            'note': 'Scratch card cashback reward',
            'status': 'completed',
            'type': 'credit',
            'verifiedAt': FieldValue.serverTimestamp(),
          });

      await _firestore
          .collection('rewards')
          .doc(widget.senderUsername)
          .collection('history')
          .add({
            'amount': cashbackAmount,
            'claimedAt': FieldValue.serverTimestamp(),
            'cardId': cardId,
          });

      await _loadRewardsData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 You won ₹$cashbackAmount cashback!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print("Error claiming reward: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to claim reward. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double targetPoints = 1000.0;
    final double progress = (totalPoints / targetPoints).clamp(0.0, 1.0);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TeenPayDashboard(username: widget.senderUsername),
          ),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(progress),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : scratchCards.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: scratchCards.length,
                        itemBuilder: (context, index) {
                          final card = scratchCards[index];
                          final bool isClaimed = card['claimed'] ?? false;
                          return _buildScratchCard(card, isClaimed);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double progress) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF87CEEB), Color(0xFF6BB6D6)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TeenPayDashboard(username: widget.senderUsername),
                      ),
                    );
                  },
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Scratch & Win',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              children: [
                const Text(
                  'Your Points',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      totalPoints.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade400,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Every 10 points = 1 scratch card!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScratchCard(Map<String, dynamic> card, bool isClaimed) {
    final Random random = Random();
    final int cashbackAmount = random.nextInt(20) + 1;
    return Opacity(
      opacity: isClaimed ? 0.5 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isClaimed
                ? [Colors.grey.shade300, Colors.grey.shade400]
                : [
                    const Color(0xFFFF6B6B),
                    const Color(0xFFFFD93D),
                    const Color(0xFF6BCF7F),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isClaimed
                  ? Colors.grey.withOpacity(0.2)
                  : Colors.purple.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isClaimed
            ? _buildClaimedCard(card)
            : _buildUnclaimedCard(card, cashbackAmount),
      ),
    );
  }

  Widget _buildClaimedCard(Map<String, dynamic> card) {
    final cashback = card['cashbackAmount'] ?? 0;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 36),
          const SizedBox(height: 8),
          const Text(
            'CLAIMED',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Won ₹$cashback',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnclaimedCard(Map<String, dynamic> card, int cashbackAmount) {
    bool hasClaimed = false;
    return Stack(
      children: [
        Container(
          height: 200,
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 50)),
                const SizedBox(height: 12),
                const Text(
                  'YOU WON',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹$cashbackAmount',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'CASHBACK',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        Scratcher(
          brushSize: 40,
          threshold: 50,
          color: Colors.grey.shade800,
          onChange: (value) {
            if (value > 50 && !hasClaimed) {
              hasClaimed = true;
              _claimReward(card['id'], cashbackAmount);
            }
          },
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.grey.shade700, Colors.grey.shade900],
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app, color: Colors.white, size: 40),
                  SizedBox(height: 12),
                  Text(
                    'SCRATCH HERE',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.card_giftcard, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No scratch cards yet!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Earn 10 points to get your first card',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
