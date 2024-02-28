import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  String _message = '';

  Future<void> _changePassword() async {
    final String currentPassword = _currentPasswordController.text.trim();
    final String newPassword = _newPasswordController.text.trim();
    final String message = await changePassword(currentPassword, newPassword);
    setState(() {
      _message = message;
    });
  }

  Future<String> changePassword(
      String currentPassword, String newPassword) async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final User user = firebaseAuth.currentUser!;
      final credentials = EmailAuthProvider.credential(
          email: user.email.toString(), password: currentPassword);
      await user.reauthenticateWithCredential(credentials);

      await user.updatePassword(newPassword);
      return "Password changed successfully!";
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBackground(context),
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    prefixIcon: const Icon(Icons.lock_outlined),
                    labelText: 'Current Password',
                    hintText: 'Enter Your Current Password',
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    prefixIcon: const Icon(Icons.lock_reset_outlined),
                    labelText: 'New Password',
                    hintText: 'Enter Your New Password',
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                height: 40,
                width: 120,
                child: ElevatedButton(
                  onPressed: _changePassword,
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                  child: const Text(
                    'Change Password',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Text(_message),
            ],
          ),
        ),
      ),
    );
  }
}
