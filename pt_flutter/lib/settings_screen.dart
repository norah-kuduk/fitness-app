import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onToggleTheme;

  const SettingsScreen(
      {Key? key, required this.onToggleTheme, required this.isDarkMode})
      : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
              title: Text('Toggle Dark Mode'),
              trailing: Switch(
                value: widget.isDarkMode,
                onChanged: (bool value) {
                  widget.onToggleTheme(value);
                },
                activeThumbImage: AssetImage('assets/moon.png'),
                inactiveThumbImage: AssetImage('assets/sun.png'),
              )),
        ],
      ),
    );
  }
}
