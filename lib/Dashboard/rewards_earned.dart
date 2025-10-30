// import 'package:flutter/material.dart';
// import 'dart:math' as math;

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Reward Claim',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         fontFamily: 'Roboto',
//       ),
//       home: const RewardClaimPage(),
//     );
//   }
// }

// class RewardClaimPage extends StatefulWidget {
//   const RewardClaimPage({Key? key}) : super(key: key);

//   @override
//   State<RewardClaimPage> createState() => _RewardClaimPageState();
// }

// class _RewardClaimPageState extends State<RewardClaimPage>
//     with TickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late AnimationController _confettiController;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();
    
//     _scaleController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );

//     _confettiController = AnimationController(
//       duration: const Duration(seconds: 3),
//       vsync: this,
//     )..repeat();

//     _scaleAnimation = CurvedAnimation(
//       parent: _scaleController,
//       curve: Curves.elasticOut,
//     );

//     _scaleController.forward();
//   }

//   @override
//   void dispose() {
//     _scaleController.dispose();
//     _confettiController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFE8F4F8),
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildHeader(),
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 40),
//                       _buildCongratulationsText(),
//                       const SizedBox(height: 24),
//                       _buildRewardCard(),
//                       const SizedBox(height: 24),
//                       _buildHelpSection(),
//                       const SizedBox(height: 16),
//                       _buildWalletIcon(),
//                       const SizedBox(height: 32),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             _buildClaimButton(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         children: [
//           IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.black87),
//             onPressed: () {
//               Navigator.pop(context); // ✅ Back arrow now works
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCongratulationsText() {
//     return const Text(
//       'Congratulations u earned a new reward!',
//       textAlign: TextAlign.center,
//       style: TextStyle(
//         fontSize: 22,
//         fontWeight: FontWeight.bold,
//         color: Colors.black87,
//         height: 1.3,
//       ),
//     );
//   }

//   Widget _buildRewardCard() {
//     return ScaleTransition(
//       scale: _scaleAnimation,
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(24),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.blue.withOpacity(0.3),
//               spreadRadius: 2,
//               blurRadius: 20,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: Stack(
//           children: [
//             AnimatedBuilder(
//               animation: _confettiController,
//               builder: (context, child) {
//                 return CustomPaint(
//                   painter: ConfettiPainter(_confettiController.value),
//                   size: const Size(double.infinity, 300),
//                 );
//               },
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24),
//               child: Column(
//                 children: [
//                   _buildFireworksDecoration(),
//                   const SizedBox(height: 20),
//                   _buildTrophy(),
//                   const SizedBox(height: 20),
//                   _buildFireworksDecoration(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFireworksDecoration() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         _buildFirework(Colors.orange),
//         const SizedBox(width: 40),
//         _buildFirework(Colors.yellow),
//       ],
//     );
//   }

//   Widget _buildFirework(Color color) {
//     return SizedBox(
//       width: 60,
//       height: 60,
//       child: Stack(
//         alignment: Alignment.center,
//         children: List.generate(8, (index) {
//           final angle = (index * 45) * math.pi / 180;
//           return Transform.rotate(
//             angle: angle,
//             child: Container(
//               width: 3,
//               height: 15,
//               decoration: BoxDecoration(
//                 color: color,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }

//   Widget _buildTrophy() {
//     return Stack(
//       alignment: Alignment.center,
//       clipBehavior: Clip.none,
//       children: [
//         Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 120,
//               height: 140,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Colors.amber.shade400, Colors.orange.shade600],
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                 ),
//                 borderRadius: const BorderRadius.only(
//                   bottomLeft: Radius.circular(20),
//                   bottomRight: Radius.circular(20),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     spreadRadius: 2,
//                     blurRadius: 8,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Stack(
//                 children: [
//                   Positioned(
//                     top: 40,
//                     left: 0,
//                     right: 0,
//                     child: Icon(
//                       Icons.star,
//                       size: 40,
//                       color: Colors.white.withOpacity(0.9),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               width: 80,
//               height: 15,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Colors.amber.shade400, Colors.orange.shade600],
//                 ),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ),
//             const SizedBox(height: 4),
//             Container(
//               width: 100,
//               height: 20,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Colors.amber.shade400, Colors.orange.shade600],
//                 ),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ),
//           ],
//         ),
//         Positioned(
//           left: -30,
//           top: 30,
//           child: Container(
//             width: 40,
//             height: 60,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.amber.shade400, Colors.orange.shade600],
//               ),
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(30),
//                 bottomLeft: Radius.circular(30),
//               ),
//             ),
//           ),
//         ),
//         Positioned(
//           right: -30,
//           top: 30,
//           child: Container(
//             width: 40,
//             height: 60,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.amber.shade400, Colors.orange.shade600],
//               ),
//               borderRadius: const BorderRadius.only(
//                 topRight: Radius.circular(30),
//                 bottomRight: Radius.circular(30),
//               ),
//             ),
//           ),
//         ),
//         Positioned(
//           top: -20,
//           child: Container(
//             width: 70,
//             height: 70,
//             decoration: BoxDecoration(
//               color: Colors.lightBlue.shade200,
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.white, width: 3),
//             ),
//             child: Center(
//               child: Text(
//                 '😊',
//                 style: TextStyle(fontSize: 35),
//               ),
//             ),
//           ),
//         ),
//         Positioned(
//           left: 15,
//           bottom: 30,
//           child: _buildRibbon(Colors.blue.shade300),
//         ),
//         Positioned(
//           right: 15,
//           bottom: 30,
//           child: _buildRibbon(Colors.lightBlue.shade200),
//         ),
//       ],
//     );
//   }

//   Widget _buildRibbon(Color color) {
//     return Column(
//       children: [
//         Container(
//           width: 20,
//           height: 40,
//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(4),
//               topRight: Radius.circular(4),
//             ),
//           ),
//         ),
//         CustomPaint(
//           size: const Size(20, 15),
//           painter: RibbonTailPainter(color),
//         ),
//       ],
//     );
//   }

//   Widget _buildHelpSection() {
//     return GestureDetector(
//       onTap: () {},
//       child: Text(
//         'For any help go to TeenPay help',
//         style: TextStyle(
//           fontSize: 14,
//           color: Colors.blue.shade700,
//           decoration: TextDecoration.underline,
//         ),
//       ),
//     );
//   }

//   Widget _buildWalletIcon() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.teal.shade300,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.teal.withOpacity(0.3),
//             spreadRadius: 1,
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: const Icon(
//         Icons.account_balance_wallet,
//         size: 32,
//         color: Colors.white,
//       ),
//     );
//   }

//   Widget _buildClaimButton() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24.0),
//       child: ElevatedButton(
//         onPressed: () {},
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xFF2196F3),
//           foregroundColor: Colors.white,
//           padding: const EdgeInsets.symmetric(vertical: 18),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           elevation: 4,
//           shadowColor: Colors.blue.withOpacity(0.5),
//         ),
//         child: const Text(
//           'Claim',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             letterSpacing: 0.5,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ConfettiPainter extends CustomPainter {
//   final double animationValue;

//   ConfettiPainter(this.animationValue);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..style = PaintingStyle.fill;
    
//     final particles = [
//       {'x': 0.2, 'y': 0.3, 'color': Colors.orange, 'size': 6.0},
//       {'x': 0.8, 'y': 0.25, 'color': Colors.yellow, 'size': 5.0},
//       {'x': 0.15, 'y': 0.6, 'color': Colors.blue.shade300, 'size': 4.0},
//       {'x': 0.85, 'y': 0.65, 'color': Colors.lightBlue.shade200, 'size': 5.0},
//       {'x': 0.3, 'y': 0.8, 'color': Colors.orange.shade300, 'size': 4.0},
//       {'x': 0.7, 'y': 0.75, 'color': Colors.yellow.shade300, 'size': 6.0},
//       {'x': 0.5, 'y': 0.2, 'color': Colors.white, 'size': 3.0},
//       {'x': 0.4, 'y': 0.5, 'color': Colors.white, 'size': 3.0},
//       {'x': 0.6, 'y': 0.45, 'color': Colors.white, 'size': 3.0},
//     ];

//     for (var particle in particles) {
//       final x = (particle['x'] as double) * size.width;
//       final y = (particle['y'] as double) * size.height + 
//                 (math.sin(animationValue * 2 * math.pi + x) * 10);
//       final color = particle['color'] as Color;
//       final particleSize = particle['size'] as double;
      
//       paint.color = color.withOpacity(0.6 + math.sin(animationValue * 2 * math.pi) * 0.4);
//       canvas.drawCircle(Offset(x, y), particleSize, paint);
//     }
//   }

//   @override
//   bool shouldRepaint(ConfettiPainter oldDelegate) => true;
// }

// class RibbonTailPainter extends CustomPainter {
//   final Color color;

//   RibbonTailPainter(this.color);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..style = PaintingStyle.fill;

//     final path = Path()
//       ..moveTo(0, 0)
//       ..lineTo(size.width, 0)
//       ..lineTo(size.width / 2, size.height)
//       ..close();

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
