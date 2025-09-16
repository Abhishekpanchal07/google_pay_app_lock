/* import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AuthMethod { none, deviceLock, appPin }

class AuthProvider with ChangeNotifier {
  static const _channel = MethodChannel(
    'com.example.flutter_application_1/auth',
  );

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> checkAuthAvailability() async {
    try {
      final result = await _channel.invokeMethod('checkAuthAvailability');
      _isAvailable = result ?? false;
      notifyListeners();
    } catch (e) {
      _isAvailable = false;
      _errorMessage = 'Error checking auth availability: $e';
      notifyListeners();
    }
  }

  Future<bool> authenticate() async {
    try {
      final result = await _channel.invokeMethod('authenticate');
      return result ?? false;
    } on PlatformException catch (e) {
      _errorMessage = 'Authentication error: ${e.message}';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AuthMethod { none, deviceLock, appPin }

class AuthProvider with ChangeNotifier {
  static const _channel = MethodChannel(
    'com.example.flutter_application_1/auth',
  );

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> checkAuthAvailability() async {
    try {
      final result = await _channel.invokeMethod('checkAuthAvailability');
      _isAvailable = result ?? false;
      notifyListeners();
    } catch (e) {
      _isAvailable = false;
      _errorMessage = 'Error checking auth availability: $e';
      notifyListeners();
    }
  }

  Future<bool> authenticate([BuildContext? context]) async {
    try {
      final result = await _channel.invokeMethod('authenticate');
      
      // If authentication failed (user dismissed), show custom dialog
      if (result == false && context != null) {
         await _showCustomAuthDialog(context);
      }
      
      return result ?? false;
    } on PlatformException catch (e) {
      _errorMessage = 'Authentication error: ${e.message}';
      notifyListeners();
      
      // Show custom dialog if context is available
      if (context != null) {
        return await _showCustomAuthDialog(context);
      }
      
      return false;
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> _showCustomAuthDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.black87, // Dark background like Google Pay
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Google Pay is locked",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  "For your security, you can only use\nGoogle Pay when it’s unlocked",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () =>Navigator.of(context).pop(false),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                        // Add unlock logic here
                      },
                      child: const Text(
                        "Unlock",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    
    if (result == true) {
      // User tapped "Unlock", retry authentication
      return await authenticate(context);
    } else {
      // User tapped "Cancel", exit app
      SystemNavigator.pop();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
} 




