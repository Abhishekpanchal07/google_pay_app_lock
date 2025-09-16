import 'package:flutter/services.dart';

class PlatformAuth {
  static const _channel = MethodChannel('secure_auth');

  /// Check available methods on device
  static Future<Map<String, bool>> checkAvailableMethods() async {
    final result = await _channel.invokeMethod('checkAuthMethods');
    return Map<String, bool>.from(result);
  }

  /// Trigger device lock (biometric / PIN fallback)
  static Future<bool> authenticateDevice() async {
    final result = await _channel.invokeMethod('authenticateDevice');
    return result == true;
  }

  /// Trigger app PIN entry (handled in Flutter)
  static Future<bool> authenticateAppPin() async {
    // Placeholder: actual validation happens on PIN entry screen
    return true;
  }
}
