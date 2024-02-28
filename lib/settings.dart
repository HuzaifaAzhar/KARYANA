import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';

class DarkModeProvider with ChangeNotifier {
  bool _isDarkModeEnabled = false;

  bool get isDarkModeEnabled => _isDarkModeEnabled;

  void toggleDarkMode(bool value) {
    _isDarkModeEnabled = value;
    notifyListeners();
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBackground(context),
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dark Mode',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Consumer<DarkModeProvider>(
              builder: (context, darkModeProvider, _) {
                return Row(
                  children: [
                    const Text('Enable'),
                    Switch(
                      value: darkModeProvider.isDarkModeEnabled,
                      onChanged: darkModeProvider.toggleDarkMode,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
