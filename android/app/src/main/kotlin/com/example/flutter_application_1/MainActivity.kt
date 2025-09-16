package com.example.flutter_application_1

import android.content.DialogInterface
import android.os.Build
import android.util.Log
import android.app.AlertDialog
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executor


class MainActivity : FlutterFragmentActivity() {

    private val CHANNEL = "com.example.flutter_application_1/auth"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "checkAuthAvailability" -> {
                        val available = checkAuthAvailability()
                        result.success(available)
                    }
                    "authenticate" -> {
                        authenticate { success ->
                            result.success(success)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // Check if device supports biometric or device credential
    private fun checkAuthAvailability(): Boolean {
        val biometricManager = BiometricManager.from(this)
        val canAuthenticate = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            // Android 11+ supports strong biometric or device credential
            biometricManager.canAuthenticate(
                BiometricManager.Authenticators.BIOMETRIC_STRONG or
                        BiometricManager.Authenticators.DEVICE_CREDENTIAL
            )
        } else {
            // Android 10 and below: fallback only to BIOMETRIC_STRONG
            biometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG)
        }
        return canAuthenticate == BiometricManager.BIOMETRIC_SUCCESS
    }

    // Authenticate user (biometric preferred, fallback to PIN/Pattern)
    private fun authenticate(callback: (Boolean) -> Unit) {
        val executor: Executor = ContextCompat.getMainExecutor(this)

        val promptInfoBuilder = BiometricPrompt.PromptInfo.Builder()
            .setTitle("Authenticate")
            .setSubtitle("Please authenticate to continue")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            promptInfoBuilder.setDeviceCredentialAllowed(true)
        }

        val promptInfo = promptInfoBuilder.build()

        val biometricPrompt = BiometricPrompt(
            this,
            executor,
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    super.onAuthenticationError(errorCode, errString)
                    
                    Log.d("BiometricAuth", "Authentication error: code=$errorCode, message=$errString")

                    // Detect if user dismissed by tapping outside, back button, or cancel button
                    when (errorCode) {
                        BiometricPrompt.ERROR_CANCELED, // User tapped outside or pressed back
                        BiometricPrompt.ERROR_USER_CANCELED, // User pressed back button
                        BiometricPrompt.ERROR_NEGATIVE_BUTTON -> { // User pressed cancel button
                            Log.d("BiometricAuth", "User canceled authentication, showing retry dialog")
                            // Instead of showing native dialog, notify Flutter to show custom dialog
                            callback(false) // This will trigger Flutter-side dialog
                        }
                        else -> {
                            // Other errors (like hardware unavailable, too many attempts, etc.)
                            Log.d("BiometricAuth", "Authentication failed with error: $errString")
                            callback(false)
                        }
                    }
                }

                override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                    super.onAuthenticationSucceeded(result)
                    callback(true)
                }

                override fun onAuthenticationFailed() {
                    super.onAuthenticationFailed()
                    // Just ignore, user can retry inside prompt
                }
            }
        )

        biometricPrompt.authenticate(promptInfo)
    }

}