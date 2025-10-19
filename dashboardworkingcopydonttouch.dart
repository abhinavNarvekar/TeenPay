// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'addmoneypage2.dart'; // <-- import AddMoneyScreen
// import 'entertpin.dart';
// import '../Profile-section/profile_page.dart';

// class TeenPayApp extends StatelessWidget {
//   final String? username;
//   const TeenPayApp({Key? key, this.username}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'TeenPay',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         scaffoldBackgroundColor: const Color(0xFFF0F7FF),
//       ),
//       home: TeenPayDashboard(username: username),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class TeenPayDashboard extends StatefulWidget {
//   final String? username;
//   const TeenPayDashboard({Key? key, this.username}) : super(key: key);

//   @override
//   State<TeenPayDashboard> createState() => _TeenPayDashboardState();
// }

// class _TeenPayDashboardState extends State<TeenPayDashboard> {
//   int _selectedIndex = 0;
//   String displayName = 'User';
//   double walletBalance = 0.0;
//   bool _loading = true;
//   bool _isBalanceVisible = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserDetails();
//   }

//   Future<void> _fetchUserDetails() async {
//     try {
//       String? uid;

//       final currentUser = FirebaseAuth.instance.currentUser;
//       if (currentUser != null) uid = currentUser.uid;

//       final String? loggedInUsername = widget.username;
//       if (uid == null &&
//           loggedInUsername != null &&
//           loggedInUsername.isNotEmpty) {
//         final usernameDoc = await FirebaseFirestore.instance
//             .collection('usernames')
//             .doc(loggedInUsername)
//             .get();
//         if (usernameDoc.exists && usernameDoc.data() != null) {
//           uid = usernameDoc.data()?['uid'] as String?;
//         }
//       }

//       if (uid != null && uid.isNotEmpty) {
//         final kycDoc = await FirebaseFirestore.instance
//             .collection('kyc')
//             .doc(uid)
//             .get();
//         if (kycDoc.exists && kycDoc.data() != null) {
//           final kycData = kycDoc.data()!;
//           final name =
//               kycData['name'] ?? kycData['fullName'] ?? kycData['displayName'];
//           setState(() {
//             displayName = (name ?? 'User') as String;
//           });
//         }
//       }

//       await _refreshBalance();
//     } catch (e) {
//       print('Error fetching user details: $e');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   Future<void> _refreshBalance() async {
//     final loggedInUsername = widget.username;
//     if (loggedInUsername != null && loggedInUsername.isNotEmpty) {
//       final walletDoc = await FirebaseFirestore.instance
//           .collection('wallets')
//           .doc(loggedInUsername)
//           .get();
//       if (walletDoc.exists && walletDoc.data() != null) {
//         final walletData = walletDoc.data()!;
//         setState(() {
//           walletBalance = ((walletData['balance'] ?? 0) as num).toDouble();
//         });
//       }
//     }
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });

//     if (index == 3) {
//       // Navigate to ProfileScreen when profile is tapped
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           // builder: (context) => ProfileScreen(username: widget.username),
//         ),
//       );
//     }
//   }

//   Widget _headerTitle() => const Center(
//     child: Padding(
//       padding: EdgeInsets.symmetric(vertical: 24),
//       child: Text(
//         'TeenPay',
//         style: TextStyle(
//           fontSize: 26,
//           fontWeight: FontWeight.bold,
//           color: Color(0xFF1F2937),
//         ),
//       ),
//     ),
//   );

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: _loading
//             ? const Center(child: CircularProgressIndicator())
//             : SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _headerTitle(),

//                     // Add this state variable in your _TeenPayDashboardState:

//                     // --- Wallet Card ---
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                             colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
//                           ),
//                           borderRadius: BorderRadius.circular(24),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.blue.withOpacity(0.25),
//                               blurRadius: 15,
//                               offset: const Offset(0, 6),
//                             ),
//                           ],
//                         ),
//                         padding: const EdgeInsets.all(28),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Greeting
//                             Text(
//                               'Hello, $displayName',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 16),

//                             // Wallet header + Eye button
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text(
//                                   'Your Wallet',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 15,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 GestureDetector(
//                                   onTap: () async {
//                                     if (_isBalanceVisible) {
//                                       // If balance is visible, hide it
//                                       setState(() {
//                                         _isBalanceVisible = false;
//                                       });
//                                     } else {
//                                       // If balance is hidden, ask for PIN
//                                       final updatedBalance =
//                                           await Navigator.push<double>(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (context) => EnterPinPage(
//                                                 username: widget.username!,
//                                                 navigateToWallet:
//                                                     false, // only reveal balance
//                                               ),
//                                             ),
//                                           );

//                                       if (updatedBalance != null) {
//                                         setState(() {
//                                           walletBalance = updatedBalance;
//                                           _isBalanceVisible = true;
//                                         });
//                                       }
//                                     }
//                                   },
//                                   child: Icon(
//                                     _isBalanceVisible
//                                         ? Icons.visibility_outlined
//                                         : Icons.visibility_off_outlined,
//                                     color: Colors.white,
//                                     size: 22,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 22),

//                             // Balance display
//                             Text(
//                               _isBalanceVisible
//                                   ? '₹${walletBalance.toStringAsFixed(2)} INR'
//                                   : 'XXX',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 36,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 32),
//                     _sectionTitle('Quick Actions'),
//                     _quickActionsRow(),

//                     const SizedBox(height: 36),
//                     _sectionTitle('Recent Contacts'),
//                     _recentContactsSection(),

//                     const SizedBox(height: 36),
//                     _sectionTitle('Offers and Rewards'),
//                     _offersRewardsSection(),

//                     const SizedBox(height: 36),
//                     _sectionTitle('Manage your Money!'),
//                     _manageMoneySection(),

//                     const SizedBox(height: 100),
//                   ],
//                 ),
//               ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.card_giftcard),
//             label: 'Rewards',
//           ),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: const Color(0xFF2563EB),
//         unselectedItemColor: const Color(0xFF9CA3AF),
//         onTap: _onItemTapped,
//         type: BottomNavigationBarType.fixed,
//       ),
//     );
//   }

//   // --- Quick Actions ---
//   Widget _quickActionsRow() => SingleChildScrollView(
//     scrollDirection: Axis.horizontal,
//     padding: const EdgeInsets.symmetric(horizontal: 20),
//     child: Row(
//       children: [
//         _buildQuickAction(
//           Icons.qr_code_scanner,
//           'Scan any\nQR code',
//           // onTap: () {
//           //   Navigator.push(
//           //     context,
//           //     MaterialPageRoute(builder: (context) => ScanQRScreen()),
//           //   );
//           // },
//         ),
//         const SizedBox(width: 22),
//         _buildQuickAction(
//           Icons.people_outline,
//           'Pay to\nFriend',
//           // onTap: () {
//           //   Navigator.push(
//           //     context,
//           //     MaterialPageRoute(builder: (context) => PayToFriendScreen()),
//           //   );
//           // },
//         ),
//         const SizedBox(width: 22),
//         _buildQuickAction(
//           Icons.add_circle_outline,
//           'Add\nMoney',
//           onTap: () async {
//             final updatedBalance = await Navigator.push<double>(
//               context,
//               MaterialPageRoute(
//                 builder: (context) =>
//                     AddMoneyScreen(username: widget.username!),
//               ),
//             );
//             if (updatedBalance != null) {
//               setState(() => walletBalance = updatedBalance);
//             }
//           },
//         ),
//         const SizedBox(width: 22),
//         _buildQuickAction(
//           Icons.notifications_outlined,
//           'Pending\nRequest',
//           // onTap: () {
//           //   Navigator.push(
//           //     context,
//           // MaterialPageRoute(builder: (context) => PendingRequestScreen()),
//           //   );
//           // },
//         ),
//       ],
//     ),
//   );

//   Widget _buildQuickAction(
//     IconData icon,
//     String label, {
//     VoidCallback? onTap,
//   }) => Column(
//     children: [
//       GestureDetector(
//         onTap: onTap,
//         child: Container(
//           width: 65,
//           height: 65,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(18),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.08),
//                 blurRadius: 12,
//                 offset: const Offset(0, 3),
//               ),
//             ],
//           ),
//           child: Icon(icon, color: const Color(0xFF2563EB), size: 26),
//         ),
//       ),
//       const SizedBox(height: 10),
//       SizedBox(
//         width: 80,
//         child: Text(
//           label,
//           textAlign: TextAlign.center,
//           style: const TextStyle(
//             fontSize: 12,
//             color: Color(0xFF4B5563),
//             height: 1.2,
//           ),
//         ),
//       ),
//     ],
//   );

//   // --- Recent Contacts ---
//   Widget _recentContactsSection() => SingleChildScrollView(
//     scrollDirection: Axis.horizontal,
//     padding: const EdgeInsets.symmetric(horizontal: 20),
//     child: Row(
//       children: [
//         _buildContact('Ansh', Colors.blue),
//         const SizedBox(width: 18),
//         _buildContact('Abhinav', Colors.green),
//         const SizedBox(width: 18),
//         _buildContact('Darshani', Colors.purple),
//         const SizedBox(width: 18),
//         _buildContact('Sanat', Colors.orange),
//         const SizedBox(width: 18),
//         _buildMoreButton(),
//       ],
//     ),
//   );

//   Widget _buildContact(String name, Color color) => Column(
//     children: [
//       Container(
//         width: 56,
//         height: 56,
//         decoration: BoxDecoration(
//           color: color,
//           shape: BoxShape.circle,
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.3),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Center(
//           child: Text(
//             name[0],
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ),
//       const SizedBox(height: 8),
//       Text(
//         name,
//         style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
//       ),
//     ],
//   );

//   Widget _buildMoreButton() => Column(
//     children: [
//       Container(
//         width: 56,
//         height: 56,
//         decoration: BoxDecoration(
//           color: const Color(0xFFE5E7EB),
//           shape: BoxShape.circle,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.08),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: const Center(
//           child: Icon(Icons.more_horiz, color: Color(0xFF4B5563), size: 24),
//         ),
//       ),
//       const SizedBox(height: 8),
//       const Text(
//         'More',
//         style: TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
//       ),
//     ],
//   );

//   // --- Offers & Rewards ---
//   Widget _offersRewardsSection() => Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 20),
//     child: Container(
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//           colors: [Color(0xFFFBBF24), Color(0xFFF97316)],
//         ),
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.orange.withOpacity(0.3),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.all(20),
//       child: Row(
//         children: [
//           const Icon(Icons.card_giftcard, color: Colors.white, size: 42),
//           const SizedBox(width: 16),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: const [
//               Text(
//                 'Rewards',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 'Check your latest offers',
//                 style: TextStyle(color: Colors.white, fontSize: 14),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );

//   // --- Manage Money Section ---
//   Widget _manageMoneySection() => Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 20),
//     child: Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           _buildManageOption(Icons.history, 'See transaction history', true),
//           _buildManageOption(
//             Icons.account_balance_wallet_outlined,
//             'View Balance',
//             false,
//             onTap: () async {
//               final balance = await Navigator.push<double>(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => EnterPinPage(
//                     username: widget.username!,
//                     navigateToWallet: true, // true = go to WalletBalancePage
//                   ),
//                 ),
//               );

//               if (balance != null) {
//                 setState(() {
//                   walletBalance = balance;
//                   _isBalanceVisible = true;
//                 });
//               }
//             },
//           ),
//         ],
//       ),
//     ),
//   );

//   Widget _buildManageOption(
//     IconData icon,
//     String label,
//     bool showDivider, {
//     VoidCallback? onTap,
//   }) => InkWell(
//     onTap: onTap,

//     child: Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         border: showDivider
//             ? const Border(
//                 bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
//               )
//             : null,
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: const Color(0xFFEFF6FF),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
//           ),
//           const SizedBox(width: 12),
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.w500,
//               color: Color(0xFF374151),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );

//   // --- Section Title Helper ---
//   Widget _sectionTitle(String title) => Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//     child: Text(
//       title,
//       style: const TextStyle(
//         fontSize: 17,
//         fontWeight: FontWeight.w600,
//         color: Color(0xFF374151),
//       ),
//     ),
//   );
// }
