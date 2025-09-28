// import 'package:flutter/material.dart';

// class SetDetailsScreen extends StatefulWidget {
//   const SetDetailsScreen({Key? key}) : super(key: key);

//   @override
//   State<SetDetailsScreen> createState() => _SetDetailsScreenState();
// }

// class _SetDetailsScreenState extends State<SetDetailsScreen> {
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//       TextEditingController();

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6FA),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header with back arrow and title
//               Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.of(context).pop(),
//                     child: const Icon(
//                       Icons.arrow_back,
//                       size: 24,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const Expanded(
//                     child: Center(
//                       child: Text(
//                         'Welcome Back',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 24), // Balance the back arrow
//                 ],
//               ),

//               const SizedBox(height: 40),

//               // Wallet icon placeholder
//               // Logo image
//               Center(
//                 child: Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     gradient: const LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Image.asset(
//                       'assets/login-icons/logo.png',
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 50),

//               // Set new username section
//               const Text(
//                 'Set new username',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87,
//                 ),
//               ),

//               const SizedBox(height: 12),

//               // Username text field
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 10,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: TextField(
//                   controller: _usernameController,
//                   decoration: const InputDecoration(
//                     hintText: 'username',
//                     hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(12)),
//                       borderSide: BorderSide.none,
//                     ),
//                     contentPadding: EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 16,
//                     ),
//                     filled: true,
//                     fillColor: Colors.white,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 30),

//               // Password requirements
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFFF5F5),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: const Color(0xFFFFE6E6), width: 1),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Password Requirements',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFFE53E3E),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       '1. Length: Minimum 8–12 characters (some apps may enforce 6, but 12+ is strongly recommended).',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Color(0xFFE53E3E),
//                         height: 1.4,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     const Text(
//                       '2. Complexity: Use a mix of Uppercase, Lowercase, numbers, and special characters.',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Color(0xFFE53E3E),
//                         height: 1.4,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 30),

//               // Enter new password
//               const Text(
//                 'Enter new password',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87,
//                 ),
//               ),

//               const SizedBox(height: 12),

//               // Password text field
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 10,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: TextField(
//                   controller: _passwordController,
//                   obscureText: true,
//                   decoration: const InputDecoration(
//                     hintText: 'Password',
//                     hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(12)),
//                       borderSide: BorderSide.none,
//                     ),
//                     contentPadding: EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 16,
//                     ),
//                     filled: true,
//                     fillColor: Colors.white,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               // Confirm password
//               const Text(
//                 'Confirm your password',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87,
//                 ),
//               ),

//               const SizedBox(height: 12),

//               // Confirm password text field
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 10,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: TextField(
//                   controller: _confirmPasswordController,
//                   obscureText: true,
//                   decoration: const InputDecoration(
//                     hintText: 'Re-enter the password',
//                     hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(12)),
//                       borderSide: BorderSide.none,
//                     ),
//                     contentPadding: EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 16,
//                     ),
//                     filled: true,
//                     fillColor: Colors.white,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 40),

//               // Continue button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Add your continue logic here
//                     print('Username: ${_usernameController.text}');
//                     print('Password: ${_passwordController.text}');
//                     print(
//                       'Confirm Password: ${_confirmPasswordController.text}',
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF5B73FF),
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                     elevation: 2,
//                   ),
//                   child: const Text(
//                     'Continue',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 30),

//               // Footer text
//               Center(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Text(
//                     'By continuing, you agree to our Terms of Service and that you have parental approval',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey.shade600,
//                       height: 1.4,
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
