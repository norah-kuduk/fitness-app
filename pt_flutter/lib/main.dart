// this file creates the home screen for the app

import 'package:flutter/material.dart';
import 'home_screen.dart'; // Import the HomeScreen widget

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PT MVP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 113, 139, 209)),
        useMaterial3: true,
      ),
      home: const HomeScreen(title: 'PT Routine Options'),
    );
  }
}
