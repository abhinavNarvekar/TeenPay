import 'package:flutter/material.dart';
import 'Login-section/welcome_screen.dart'; // import your file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TeenPay',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WelcomeScreen(), // 👈 your screen here
    );
  }
}
