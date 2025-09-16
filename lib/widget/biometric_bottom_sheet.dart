import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';

class BiometricBottomSheet extends StatelessWidget {
  const BiometricBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Authenticate",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            "Use your fingerprint, face, or device PIN to continue.",
            textAlign: TextAlign.center,
          ),
          if (authProvider.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              authProvider.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.fingerprint),
            label: const Text("Authenticate"),
            onPressed: () async {
              authProvider.clearError();
              final success = await authProvider.authenticate();
              if (success) {
                Navigator.pop(context, true); // Close bottom sheet with success
              } else {
                // Keep the bottom sheet open for retry
              }
            },
          ),
        ],
      ),
    );
  }
}
