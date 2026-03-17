import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyLunasApp());
}

class MyLunasApp extends StatelessWidget {
  const MyLunasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyLUNAS Mobile',
      home: SplashScreen(),
    );
  }
}
