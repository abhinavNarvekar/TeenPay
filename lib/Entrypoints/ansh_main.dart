// main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Firebase config
import '../firebase_options.dart';

// App screens
import '../welcome_screen.dart';

// KYC imports
import '../KYC-section/KYC_intro.dart';
import '../KYC-section/kyc_provider.dart';
import '../KYC-section/KYC_details1b.dart';
import '../KYC-section/KYC_details1b.dart';

// Other app imports
import '../Login_section/email_phone_option_screen.dart';
import '../Post-kyc-registration/setusername_pass.dart';
import '../Register-section/otp_verify.dart';
import '../Register-section/enter_phoneno.dart';

import '../Register-section/set_tpin.dart';

import '../Dashboard/dashboard_temp.dart';
import '../view-balance/view_balance.dart';

void main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Run the app with Provider at the root
  runApp(
    ChangeNotifierProvider(
      create: (context) => KycProvider(),
      child: const TeenPayApp(),
    ),
  );
}

class TeenPayApp extends StatelessWidget {
  const TeenPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TeenPay',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      // Entry screen of your app
      home: const TeenPayApp(),
    );
  }
}
