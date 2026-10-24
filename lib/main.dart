import 'package:flutter/material.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  runApp(const CluelessClosetApp());
}

class CluelessClosetApp extends StatelessWidget {
  const CluelessClosetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clueless Closet',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

