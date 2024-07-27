import 'package:flutter/material.dart';
import 'home_screen.dart'; // Import the HomeScreen widget

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme

  void toggleTheme(bool isOn) {
    setState(() {
      _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode, // Use the current theme mode
      home: HomeScreen(
        title: 'Routine List',
        onToggleTheme:
            toggleTheme, // Pass the toggle function to the HomeScreen
      ),
    );
  }
}
