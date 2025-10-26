import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'addmoneypage2.dart'; // <-- import AddMoneyScreen
import 'entertpin.dart';
import 'scan_qr_code.dart';
import '../Profile-section/profile_page.dart';
import 'transaction_history.dart'; // <-- import TransactionHistoryPage
import 'seependingreq.dart';
import 'paytofriend_s1.dart'; // <-- PayToFriendPage
import '../PayToFriend/friendviewpage.dart';
import 'rewardspage.dart'; // <-- import RewardsPage

class TeenPayApp extends StatelessWidget {
  final String? username;
  const TeenPayApp({Key? key, this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeenPay',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF0F7FF),
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

class _TeenPayDashboardState extends State<TeenPayDashboard> {
  int _selectedIndex = 0;
  String displayName = 'User';
  double walletBalance = 0.0;
  bool _loading = true;
  bool _isBalanceVisible = false;

  bool _showAllContacts = false;
  List<Map<String, String>> _recentContacts = []; // {username, name}

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _fetchRecentContacts();
  }

  // ---------------------- BODY SWITCHING ----------------------
  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return _homeContent();
      case 1:
        return TransactionHistoryPage(username: widget.username ?? '');
      case 2:
        return RewardsPage(); // <-- Navigate to RewardsPage
      case 3:
        return ProfileScreen(username: widget.username);
      default:
        return _homeContent();
    }
  }

  // ---------------------- FETCH USER DETAILS ----------------------
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

  // ---------------------- FETCH WALLET ----------------------
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

  // ---------------------- NAVIGATION ----------------------
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // ---------------------- HEADER TITLE ----------------------
  Widget _headerTitle() => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'TeenPay',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
      );

  // ---------------------- DASHBOARD CONTENT ----------------------
  Widget _homeContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerTitle(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $displayName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Wallet',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (_isBalanceVisible) {
                            setState(() {
                              _isBalanceVisible = false;
                            });
                          } else {
                            final updatedBalance = await Navigator.push<double>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EnterPinPage(
                                  username: widget.username!,
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
                        child: Icon(
                          _isBalanceVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    _isBalanceVisible
                        ? '₹${walletBalance.toStringAsFixed(2)} INR'
                        : 'XXX',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          _sectionTitle('Quick Actions'),
          _quickActionsRow(),
          const SizedBox(height: 36),
          _sectionTitle('Recent Contacts'),
          _recentContactsSection(),
          const SizedBox(height: 36),
          _sectionTitle('Offers and Rewards'),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RewardsPage()),
              );
            },
            child: _offersRewardsSection(),
          ),
          const SizedBox(height: 36),
          _sectionTitle('Manage your Money!'),
          _manageMoneySection(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ---------------------- QUICK ACTIONS ----------------------
  Widget _quickActionsRow() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            _buildQuickAction(
              Icons.qr_code_scanner,
              'Scan any\nQR code',
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
            const SizedBox(width: 22),
            _buildQuickAction(
              Icons.people_outline,
              'Pay to\nFriend',
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
            const SizedBox(width: 22),
            _buildQuickAction(
              Icons.add_circle_outline,
              'Add\nMoney',
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
            const SizedBox(width: 22),
            _buildQuickAction(
              Icons.notifications_outlined,
              'Pending\nRequest',
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
          IconData icon, String label, {VoidCallback? onTap}) =>
      Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: const Color(0xFF2563EB), size: 26),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 80,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF4B5563),
                height: 1.2,
              ),
            ),
          ),
        ],
      );

  // ---------------------- FETCH RECENT CONTACTS ----------------------
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
          .where((data) => data['status'] == 'completed')
          .toList();

      allTxns.sort((a, b) {
        final tsA = a['createdAt'] as Timestamp?;
        final tsB = b['createdAt'] as Timestamp?;
        return tsB!.compareTo(tsA!);
      });

      final uniqueContactsMap = <String, String>{};

      for (var data in allTxns) {
        final counterpartyUsername = data['counterparty'] as String? ?? '';
        final counterpartyName =
            data['counterpartyName'] as String? ?? counterpartyUsername;

        if (counterpartyUsername.isNotEmpty &&
            !uniqueContactsMap.containsKey(counterpartyUsername)) {
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

  // ---------------------- RECENT CONTACTS SECTION ----------------------
  Widget _recentContactsSection() {
    final contactsToShow =
        _showAllContacts ? _recentContacts : _recentContacts.take(4).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          ...contactsToShow.map((contact) {
            final counterpartyUsername = contact['username']!;
            final name = contact['name'] ?? counterpartyUsername;
            final color =
                Colors.primaries[counterpartyUsername.hashCode % Colors.primaries.length];

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
          GestureDetector(
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
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 60,
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
            ),
          ),
        ],
      );

  Widget _buildMoreButton({VoidCallback? onTap}) => Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  _showAllContacts ? Icons.expand_less : Icons.more_horiz,
                  color: const Color(0xFF4B5563),
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _showAllContacts ? 'Less' : 'More',
            style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
          ),
        ],
      );

  // ---------------------- OFFERS & REWARDS ----------------------
  Widget _offersRewardsSection() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFFFBBF24), Color(0xFFF97316)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(Icons.card_giftcard, color: Colors.white, size: 42),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Rewards',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Check your latest offers',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  // ---------------------- MANAGE MONEY ----------------------
  Widget _manageMoneySection() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildManageOption(
                Icons.history,
                'See transaction history',
                true,
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
                Icons.account_balance_wallet_outlined,
                'View Balance',
                false,
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

  Widget _buildManageOption(IconData icon, String label, bool showDivider,
          {VoidCallback? onTap}) =>
      InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      );

  // ---------------------- SECTION TITLE ----------------------
  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
      );

  // ---------------------- BUILD ----------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _getBody(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Rewards',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: const Color(0xFF9CA3AF),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
