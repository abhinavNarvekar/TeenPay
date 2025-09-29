import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../KYC-section/KYC_intro.dart';
import '../KYC-section/kyc_provider.dart';
import '../KYC-section/KYC_details1b.dart';
void main() {
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
      title: 'TeenPay KYC Flow',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      // Start with your first KYC page
      home: const KYCDetails1Page(), // Replace with your actual first page
    );
  }
}
