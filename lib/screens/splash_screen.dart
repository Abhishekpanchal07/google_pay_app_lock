import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/provider/auth_provider.dart';
import 'package:flutter_application_1/widget/biometric_bottom_sheet.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.authenticate();
    if (success) {
      Navigator.pop(context, true); // Close bottom sheet with success
    } else {
      // Keep the bottom sheet open for retry
    }
  }

  Future<void> _showBiometricSheet() async {
    final authProvider = context.read<AuthProvider>();

    bool? success = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false, // prevent dismiss by tap outside
      enableDrag: false,
      builder: (_) => const BiometricBottomSheet(),
    );

    // If user dismissed by system (rare) or failed, show alert dialog
    if (success != true) {
      _showUnlockDialog();
    } else {
      _goToHome();
    }
  }

  void _showUnlockDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // prevent tap outside
      builder: (_) => AlertDialog(
        title: const Text("Authentication Required"),
        content: const Text("To use this app, you need to authenticate first."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              _showBiometricSheet(); // show bottom sheet again
            },
            child: const Text("Unlock"),
          ),
          TextButton(
            onPressed: () {
              exit(0); // exit app
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Home Screen")));
  }
}
