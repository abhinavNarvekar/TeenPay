import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'addmoneypage2.dart';
import 'entertpin.dart';
import 'scan_qr_code.dart';
import '../Profile-section/profile_page.dart';
import 'transaction_history.dart';
import 'seependingreq.dart';
import 'paytofriend_s1.dart';
import '../PayToFriend/friendviewpage.dart';
import 'rewardspage.dart';

class TeenPayApp extends StatelessWidget {
  final String? username;
  const TeenPayApp({Key? key, this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeenPay',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: TeenPayDashboard(username: username),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TeenPayDashboard extends StatefulWidget {
  final String? username;
  const TeenPayDashboard({Key? key, this.username}) : super(key: key);

  @override
  State<TeenPayDashboard> createState() => _TeenPayDashboardState();
}

class _TeenPayDashboardState extends State<TeenPayDashboard>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  String displayName = 'User';
  double walletBalance = 0.0;
  bool _loading = true;
  bool _isBalanceVisible = false;

  bool _showAllContacts = false;
  List<Map<String, String>> _recentContacts = [];

  late AnimationController _cardAnimController;
  late Animation<double> _cardScale;
  late Animation<double> _cardRotation;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _fetchRecentContacts();

    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _cardScale = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _cardAnimController, curve: Curves.easeInOut),
    );

    _cardRotation = Tween<double>(begin: 0.0, end: 0.01).animate(
      CurvedAnimation(parent: _cardAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _cardAnimController.dispose();
    super.dispose();
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return _homeContent();
      case 1:
        return TransactionHistoryPage(username: widget.username ?? '');
      case 2:
        return RewardsPage(senderUsername: widget.username ?? '');
      case 3:
        return ProfileScreen(username: widget.username);
      default:
        return _homeContent();
    }
  }

  Future<void> _fetchUserDetails() async {
    setState(() {
      displayName = 'Loading...';
    });

    try {
      final String? loggedInUsername = widget.username;
      if (loggedInUsername == null || loggedInUsername.isEmpty) {
        setState(() {
          displayName = 'Unknown User';
        });
        return;
      }

      final usernameDoc = await FirebaseFirestore.instance
          .collection('usernames')
          .doc(loggedInUsername)
          .get(const GetOptions(source: Source.server));

      if (!usernameDoc.exists || usernameDoc.data() == null) {
        setState(() {
          displayName = loggedInUsername;
        });
        return;
      }

      final uid = usernameDoc.data()?['uid'] as String?;
      if (uid == null || uid.isEmpty) {
        setState(() {
          displayName = loggedInUsername;
        });
        return;
      }

      final kycDoc = await FirebaseFirestore.instance
          .collection('kyc')
          .doc(uid)
          .get(const GetOptions(source: Source.server));

      if (!kycDoc.exists || kycDoc.data() == null) {
        setState(() {
          displayName = loggedInUsername;
        });
        return;
      }

      final kycData = kycDoc.data()!;
      final String? name =
          kycData['name'] ?? kycData['fullName'] ?? kycData['displayName'];

      setState(() {
        displayName = (name != null && name.isNotEmpty)
            ? name
            : loggedInUsername;
      });

      await _refreshBalance();
    } catch (e) {
      print('❌ Error fetching user details: $e');
      setState(() {
        displayName = 'Error';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _refreshBalance() async {
    final loggedInUsername = widget.username;
    if (loggedInUsername != null && loggedInUsername.isNotEmpty) {
      final walletDoc = await FirebaseFirestore.instance
          .collection('wallets')
          .doc(loggedInUsername)
          .get();
      if (walletDoc.exists && walletDoc.data() != null) {
        final walletData = walletDoc.data()!;
        setState(() {
          walletBalance = ((walletData['balance'] ?? 0) as num).toDouble();
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _headerTitle() => Container(
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color.fromARGB(255, 109, 164, 227),
          const Color.fromARGB(255, 86, 187, 189),
        ],
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TeenPay',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Your Smart Wallet',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(
            'assets/login-icons/logo.png',
            height: 26,
            width: 26,
            fit: BoxFit.contain,
          ),
        ),
      ],
    ),
  );

  Widget _homeContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerTitle(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AnimatedBuilder(
              animation: _cardAnimController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _cardScale.value,
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(_cardRotation.value)
                      ..rotateY(_cardRotation.value),
                    alignment: FractionalOffset.center,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF667EEA),
                            const Color.fromARGB(255, 86, 209, 211),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667EEA).withOpacity(0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                            spreadRadius: -4,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hello,',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      displayName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () async {
                                        if (_isBalanceVisible) {
                                          setState(() {
                                            _isBalanceVisible = false;
                                          });
                                        } else {
                                          final updatedBalance =
                                              await Navigator.push<double>(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EnterPinPage(
                                                        username:
                                                            widget.username!,
                                                        navigateToWallet: false,
                                                      ),
                                                ),
                                              );
                                          if (updatedBalance != null) {
                                            setState(() {
                                              walletBalance = updatedBalance;
                                              _isBalanceVisible = true;
                                            });
                                          }
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Icon(
                                          _isBalanceVisible
                                              ? Icons.visibility_rounded
                                              : Icons.visibility_off_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            Text(
                              'Total Balance',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isBalanceVisible ? '₹' : '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _isBalanceVisible
                                      ? walletBalance.toStringAsFixed(2)
                                      : '••••••',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isBalanceVisible ? 'INR' : '',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          _sectionTitle('Quick Actions'),
          const SizedBox(height: 12),
          _quickActionsRow(),
          const SizedBox(height: 36),
          _sectionTitle('Recent Contacts'),
          const SizedBox(height: 12),
          _recentContactsSection(),
          const SizedBox(height: 36),
          _sectionTitle('Offers and Rewards'),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RewardsPage(senderUsername: widget.username!),
                ),
              );
            },
            child: _offersRewardsSection(),
          ),
          const SizedBox(height: 36),
          _sectionTitle('Manage your Money'),
          const SizedBox(height: 12),
          _manageMoneySection(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _quickActionsRow() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: [
        _buildQuickAction(
          Icons.qr_code_scanner_rounded,
          'Scan any\nQR code',
          const Color(0xFF667EEA),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    QrScannerPage(senderUsername: widget.username!),
              ),
            );
          },
        ),
        const SizedBox(width: 16),
        _buildQuickAction(
          Icons.people_rounded,
          'Pay to\nFriend',
          const Color(0xFFEC4899),
          onTap: () {
            if (widget.username != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PayToFriendPage(currentUid: widget.username!),
                ),
              );
            }
          },
        ),
        const SizedBox(width: 16),
        _buildQuickAction(
          Icons.add_card_rounded,
          'Add\nMoney',
          const Color(0xFF10B981),
          onTap: () async {
            final updatedBalance = await Navigator.push<double>(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AddMoneyScreen(username: widget.username!),
              ),
            );
            if (updatedBalance != null) {
              setState(() => walletBalance = updatedBalance);
            }
          },
        ),
        const SizedBox(width: 16),
        _buildQuickAction(
          Icons.notifications_active_rounded,
          'Pending\nRequest',
          const Color(0xFFF59E0B),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PendingRequestsPage(username: widget.username!),
              ),
            );
          },
        ),
      ],
    ),
  );

  Widget _buildQuickAction(
    IconData icon,
    String label,
    Color color, {
    VoidCallback? onTap,
  }) => Column(
    children: [
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: 90,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF374151),
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
      ),
    ],
  );
  //recent contacts
  Future<void> _fetchRecentContacts() async {
    final username = widget.username;
    if (username == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .doc(username)
          .collection('userTxns')
          .limit(100)
          .get();

      final List<Map<String, dynamic>> allTxns = querySnapshot.docs
          .map((doc) => doc.data())
          .where((data) {
            // ✅ Only include completed transactions with real users
            final status = data['status'] == 'completed';
            final counterparty = data['counterparty'] ?? '';
            final counterpartyName = data['counterpartyName'] ?? '';
            final type = data['type'] ?? '';

            return status &&
                counterparty.isNotEmpty &&
                counterparty != 'system' && // exclude system rewards
                counterpartyName != 'Scratch Card Reward' &&
                type != 'credit'; // exclude cashback credits
          })
          .toList();

      // Sort by recent first
      allTxns.sort((a, b) {
        final tsA = a['createdAt'] as Timestamp?;
        final tsB = b['createdAt'] as Timestamp?;
        return tsB!.compareTo(tsA!);
      });

      // Get unique last 10 contacts
      final uniqueContactsMap = <String, String>{};
      for (var data in allTxns) {
        final counterpartyUsername = data['counterparty'] as String? ?? '';
        final counterpartyName =
            data['counterpartyName'] as String? ?? counterpartyUsername;

        if (!uniqueContactsMap.containsKey(counterpartyUsername)) {
          uniqueContactsMap[counterpartyUsername] = counterpartyName;
        }

        if (uniqueContactsMap.length >= 10) break;
      }

      setState(() {
        _recentContacts = uniqueContactsMap.entries
            .map((e) => {'username': e.key, 'name': e.value})
            .toList();
      });
    } catch (e) {
      print('Error fetching recent contacts: $e');
    }
  }

  Widget _recentContactsSection() {
    final contactsToShow = _showAllContacts
        ? _recentContacts
        : _recentContacts.take(4).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          ...contactsToShow.map((contact) {
            final counterpartyUsername = contact['username']!;
            final name = contact['name'] ?? counterpartyUsername;
            final color =
                Colors.primaries[counterpartyUsername.hashCode %
                    Colors.primaries.length];

            return Padding(
              padding: const EdgeInsets.only(right: 18),
              child: _buildContact(name, counterpartyUsername, color),
            );
          }).toList(),
          if (_recentContacts.length > 4)
            _buildMoreButton(
              onTap: () {
                setState(() {
                  _showAllContacts = !_showAllContacts;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildContact(String name, String counterpartyUsername, Color color) =>
      Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                final currentUsername = widget.username!;
                final currentUidDoc = await FirebaseFirestore.instance
                    .collection('usernames')
                    .doc(currentUsername)
                    .get();
                final currentUid = currentUidDoc.data()?['uid'] as String?;
                if (currentUid == null) return;

                final currentUserDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUid)
                    .get();
                final currentPhone =
                    currentUserDoc.data()?['phone'] as String? ?? '';

                final friendUsernameDoc = await FirebaseFirestore.instance
                    .collection('usernames')
                    .doc(counterpartyUsername)
                    .get();
                final friendUid = friendUsernameDoc.data()?['uid'] as String?;
                if (friendUid == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Friend UID not found')),
                  );
                  return;
                }

                final friendUserDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(friendUid)
                    .get();
                final friendPhone =
                    friendUserDoc.data()?['phone'] as String? ?? '';

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentHistoryScreen(
                      currentUsername: currentUsername,
                      currentPhone: currentPhone,
                      friendUsername: counterpartyUsername,
                      friendPhone: friendPhone,
                      recipientUid: friendUid,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 70,
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF374151),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );

  Widget _buildMoreButton({VoidCallback? onTap}) => Column(
    children: [
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                _showAllContacts
                    ? Icons.expand_less_rounded
                    : Icons.more_horiz_rounded,
                color: const Color(0xFF6B7280),
                size: 28,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 10),
      Text(
        _showAllContacts ? 'Less' : 'More',
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF374151),
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );

  Widget _offersRewardsSection() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white.withOpacity(0.1), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Rewards & Offers',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Check your latest offers',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.8),
              size: 18,
            ),
          ],
        ),
      ),
    ),
  );

  Widget _manageMoneySection() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildManageOption(
            Icons.history_rounded,
            'Transaction History',
            true,
            const Color(0xFF667EEA),
            onTap: () {
              if (widget.username != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TransactionHistoryPage(username: widget.username!),
                  ),
                );
              }
            },
          ),
          _buildManageOption(
            Icons.account_balance_wallet_rounded,
            'View Balance',
            false,
            const Color(0xFF10B981),
            onTap: () async {
              final balance = await Navigator.push<double>(
                context,
                MaterialPageRoute(
                  builder: (context) => EnterPinPage(
                    username: widget.username!,
                    navigateToWallet: true,
                  ),
                ),
              );
              if (balance != null) {
                setState(() {
                  walletBalance = balance;
                  _isBalanceVisible = true;
                });
              }
            },
          ),
        ],
      ),
    ),
  );

  Widget _buildManageOption(
    IconData icon,
    String label,
    bool showDivider,
    Color color, {
    VoidCallback? onTap,
  }) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(showDivider ? 0 : 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(
                  bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: const Color(0xFF9CA3AF),
              size: 16,
            ),
          ],
        ),
      ),
    ),
  );

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2937),
        letterSpacing: 0.3,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _loading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667EEA).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Loading TeenPay...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              )
            : _getBody(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard_rounded),
              label: 'Rewards',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF667EEA),
          unselectedItemColor: const Color(0xFF9CA3AF),
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
