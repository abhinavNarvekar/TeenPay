import 'package:flutter/material.dart';

class TeenPayApp extends StatelessWidget {
  const TeenPayApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeenPay',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF0F7FF),
      ),
      home: const TeenPayDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TeenPayDashboard extends StatefulWidget {
  const TeenPayDashboard({Key? key}) : super(key: key);

  @override
  State<TeenPayDashboard> createState() => _TeenPayDashboardState();
}

class _TeenPayDashboardState extends State<TeenPayDashboard> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Center(
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
                    ),

                    // Wallet Card
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
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  'Your Wallet',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  Icons.visibility_outlined,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            const Text(
                              '₹5,450 INR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF86EFAC),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '+1,250 this week',
                                  style: TextStyle(
                                    color: Color(0xFF86EFAC),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Quick Actions
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Quick Actions',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                _buildQuickAction(
                                  Icons.qr_code_scanner,
                                  'Scan any\nQR code',
                                ),
                                const SizedBox(width: 22),
                                _buildQuickAction(
                                  Icons.people_outline,
                                  'Pay to\nFriend',
                                ),
                                const SizedBox(width: 22),
                                _buildQuickAction(
                                  Icons.add_circle_outline,
                                  'Add\nMoney',
                                ),
                                const SizedBox(width: 22),
                                _buildQuickAction(
                                  Icons.notifications_outlined,
                                  'Pending\nRequest',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Recent Contacts
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Recent Contacts',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                _buildContact('Ansh', Colors.blue),
                                const SizedBox(width: 18),
                                _buildContact('Abhinav', Colors.green),
                                const SizedBox(width: 18),
                                _buildContact('Darshani', Colors.purple),
                                const SizedBox(width: 18),
                                _buildContact('Sanat', Colors.orange),
                                const SizedBox(width: 18),
                                _buildMoreButton(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Offers and Rewards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Offers and Rewards',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
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
                                const Icon(
                                  Icons.card_giftcard,
                                  color: Colors.white,
                                  size: 42,
                                ),
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
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Manage Your Money
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Manage your Money!',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
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
                                ),
                                _buildManageOption(
                                  Icons.account_balance_wallet_outlined,
                                  'View Balance',
                                  false,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
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
          backgroundColor: Colors.white,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Container(
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
      ),
    );
  }

  Widget _buildContact(String name, Color color) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Container(
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
                name[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreButton() {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Container(
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
            child: const Center(
              child: Icon(Icons.more_horiz, color: Color(0xFF4B5563), size: 24),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'More',
            style: TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
          ),
        ],
      ),
    );
  }

  Widget _buildManageOption(IconData icon, String label, bool showDivider) {
    return InkWell(
      onTap: () {},
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
  }
}
