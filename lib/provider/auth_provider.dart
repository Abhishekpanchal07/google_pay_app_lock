/* 

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//enum AuthMethod { none, deviceLock, appPin }

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
} */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthProvider with ChangeNotifier {
  static const _channel = MethodChannel('com.example.flutter_application_1/auth');

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  bool _isAuthenticating = false;
  bool get isAuthenticating => _isAuthenticating;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Check if biometrics/PIN lock is available
  Future<void> checkAuthAvailability() async {
    try {
      final result = await _channel.invokeMethod('checkAuthAvailability');
      _isAvailable = result ?? false;
    } catch (e) {
      _isAvailable = false;
      _errorMessage = "Auth availability error: $e";
    }
    notifyListeners();
  }

  /// Start secure authentication process
  Future<void> startAuthentication() async {
    if (_isAuthenticating || _isAuthenticated) return;

    _isAuthenticating = true;
    _isAuthenticated = false;
    notifyListeners();

    await checkAuthAvailability();

    if (!_isAvailable) {
      // No biometrics? Allow access
      _isAuthenticated = true;
      _isAuthenticating = false;
      notifyListeners();
      return;
    }

    try {
      final result = await _channel.invokeMethod('authenticate');
      _isAuthenticated = result ?? false;
    } catch (e) {
      _isAuthenticated = false;
      _errorMessage = "Authentication failed: $e";
    }

    _isAuthenticating = false;
    notifyListeners();
  }

  /// Reset auth state when app moves to background
  void unauthenticate() {
    _isAuthenticated = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

