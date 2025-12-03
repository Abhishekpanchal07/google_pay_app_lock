package com.example.flutter_application_1
import android.os.Build
import android.util.Log
import android.app.Dialog
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.ColorDrawable
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.view.Window
import android.view.WindowManager
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executor

class MainActivity : FlutterFragmentActivity() {

    private val CHANNEL = "com.example.flutter_application_1/auth"
    private var currentDialog: Dialog? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "checkAuthAvailability" -> {
                        result.success(checkAuthAvailability())
                    }
                    "authenticate" -> {
                        authenticate { success -> result.success(success) }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun checkAuthAvailability(): Boolean {
        val biometricManager = BiometricManager.from(this)

        val canAuthenticate = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            biometricManager.canAuthenticate(
                BiometricManager.Authenticators.BIOMETRIC_STRONG or
                        BiometricManager.Authenticators.DEVICE_CREDENTIAL
            )
        } else {
            biometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG)
        }

        return canAuthenticate == BiometricManager.BIOMETRIC_SUCCESS
    }

    private fun authenticate(callback: (Boolean) -> Unit) {
        val executor: Executor = ContextCompat.getMainExecutor(this)

        val promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle("Authenticate")
            .setSubtitle("Please authenticate to continue")
            .apply {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    setDeviceCredentialAllowed(true)
                }
            }
            .build()

        val biometricPrompt = BiometricPrompt(
            this,
            executor,
            object : BiometricPrompt.AuthenticationCallback() {

                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    super.onAuthenticationError(errorCode, errString)
                    Log.d("BiometricAuth", "Error: $errString")

                    if (errorCode == BiometricPrompt.ERROR_CANCELED ||
                        errorCode == BiometricPrompt.ERROR_USER_CANCELED ||
                        errorCode == BiometricPrompt.ERROR_NEGATIVE_BUTTON
                    ) {
                        showNativeAuthDialog(callback)
                    } else {
                        callback(false)
                    }
                }

                override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                    callback(true)
                }
            }
        )

        biometricPrompt.authenticate(promptInfo)
    }

    private fun showNativeAuthDialog(callback: (Boolean) -> Unit) {
    currentDialog?.dismiss()

    val density = resources.displayMetrics.density
    val dialog = Dialog(this)

    dialog.requestWindowFeature(Window.FEATURE_NO_TITLE)
    dialog.setCancelable(false)

    // Main Card Container (Smaller like Google Pay)
    val container = LinearLayout(this).apply {
        orientation = LinearLayout.VERTICAL
        setPadding(
            (24 * density).toInt(),
            (32 * density).toInt(),
            (24 * density).toInt(),
            (20 * density).toInt()
        )
        background = GradientDrawable().apply {
            cornerRadius = 20 * density   // smaller radius like GPay
            setColor(Color.parseColor("#3C4043")) // GPay exact dark tone
        }
    }

    // Blue circular lock icon (Google Pay style)
    

    val lockIcon = ImageView(this).apply {
       setImageDrawable(ContextCompat.getDrawable(context, R.drawable.ic_lock_outline_blue))
       

        layoutParams = LinearLayout.LayoutParams(
            (36 * density).toInt(),
            (36 * density).toInt()
        ).apply {
            gravity = Gravity.CENTER_HORIZONTAL
            bottomMargin = (20 * density).toInt()
        }

       
    }

    // Title
    val title = TextView(this).apply {
        text = "LevUp is locked"
        setTextColor(Color.parseColor("#E8EAED"))
        textSize = 18f  // smaller like GPay
        typeface = Typeface.create("sans-serif-medium", Typeface.NORMAL)
        gravity = Gravity.CENTER
        layoutParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.WRAP_CONTENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        ).apply {
            gravity = Gravity.CENTER_HORIZONTAL
            bottomMargin = (12 * density).toInt()
        }
    }

    // Message
    val message = TextView(this).apply {
        text = "For your security, you can only use\LevUp when it's unlocked"
        setTextColor(Color.parseColor("#9AA0A6"))
        textSize = 14f
        gravity = Gravity.CENTER
        setLineSpacing(4 * density, 1.0f)
        layoutParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.WRAP_CONTENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        ).apply {
            gravity = Gravity.CENTER_HORIZONTAL
            bottomMargin = (24 * density).toInt()
        }
    }

    // Buttons Row
    val buttons = LinearLayout(this).apply {
        orientation = LinearLayout.HORIZONTAL
        gravity = Gravity.END
    }

    // Google Pay style button creator
    fun makeButton(text: String) = TextView(this).apply {
        this.text = text
        textSize = 14f
        setTextColor(Color.parseColor("#8AB4F8"))
        typeface = Typeface.create("sans-serif-medium", Typeface.NORMAL)
        isAllCaps = false
        setPadding(
            (16 * density).toInt(),
            (12 * density).toInt(),
            (16 * density).toInt(),
            (12 * density).toInt()
        )
    }

    val cancelBtn = makeButton("Cancel").apply {
        layoutParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.WRAP_CONTENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        ).apply {
            rightMargin = (4 * density).toInt()
        }

        setOnClickListener {
            dialog.dismiss()
            currentDialog = null
            callback(false)
            finishAffinity()
        }
    }

    val unlockBtn = makeButton("Unlock").apply {
        setOnClickListener {
            dialog.dismiss()
            currentDialog = null
            authenticate(callback)
        }
    }

    buttons.addView(cancelBtn)
    buttons.addView(unlockBtn)

    // Add Components
    container.addView(lockIcon)
    container.addView(title)
    container.addView(message)
    container.addView(buttons)

    dialog.setContentView(container)

    dialog.window?.apply {
        setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        attributes = attributes.apply {
            width = (280 * density).toInt()     // EXACT Google Pay size
            height = WindowManager.LayoutParams.WRAP_CONTENT
            gravity = Gravity.CENTER
        }
        addFlags(WindowManager.LayoutParams.FLAG_DIM_BEHIND)
        setDimAmount(0.60f)
    }

    currentDialog = dialog
    dialog.show()
}


    override fun onDestroy() {
        currentDialog?.dismiss()
        currentDialog = null
        super.onDestroy()
    }
}
