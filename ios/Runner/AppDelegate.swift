import UIKit
import Flutter
import LocalAuthentication

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {

    private let channel = "com.example.flutter_application_1/auth"
    private var currentDialog: UIAlertController?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // IMPORTANT — register all Flutter plugins
        GeneratedPluginRegistrant.register(with: self)

        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController

        let methodChannel = FlutterMethodChannel(
            name: channel,
            binaryMessenger: controller.binaryMessenger
        )

        methodChannel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }

            switch call.method {

            case "checkAuthAvailability":
                result(self.checkAuthAvailability())

            case "authenticate":
                self.authenticate { success in
                    result(success)
                }

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: - Check biometric / device lock availability
    private func checkAuthAvailability() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
    }

    // MARK: - Authenticate user
    private func authenticate(callback: @escaping (Bool) -> Void) {
        let context = LAContext()
        context.localizedFallbackTitle = "Use Passcode"

        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            callback(false)
            return
        }

        context.evaluatePolicy(.deviceOwnerAuthentication,
            localizedReason: "Please authenticate to continue") { success, authError in

            DispatchQueue.main.async {
                if success {
                    callback(true)

                } else {
                    if let err = authError as? LAError {
                        if err.code == .userCancel ||
                            err.code == .systemCancel ||
                            err.code == .appCancel {

                            self.showNativeAuthDialog(callback: callback)
                            return
                        }
                    }
                    callback(false)
                }
            }
        }
    }

    // MARK: - Custom security dialog
    private func showNativeAuthDialog(callback: @escaping (Bool) -> Void) {
        currentDialog?.dismiss(animated: false)

        let dialog = UIAlertController(title: nil, message: nil, preferredStyle: .alert)

        let title = "LevUP is locked"
        let message = "For your security, you can only use LevUP when it's unlocked."

        dialog.setValue(NSAttributedString(
            string: title,
            attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .semibold)]
        ), forKey: "attributedTitle")

        dialog.setValue(NSAttributedString(
            string: message,
            attributes: [.font: UIFont.systemFont(ofSize: 14)]
        ), forKey: "attributedMessage")

        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { _ in
            callback(false)
            exit(0)  // Same as finishAffinity()
        }

        let unlock = UIAlertAction(title: "Unlock", style: .default) { _ in
            dialog.dismiss(animated: true)
            self.authenticate(callback: callback)
        }

        dialog.addAction(cancel)
        dialog.addAction(unlock)

        currentDialog = dialog
        window?.rootViewController?.present(dialog, animated: true)
    }

    override func applicationWillTerminate(_ application: UIApplication) {
        currentDialog?.dismiss(animated: false)
        currentDialog = nil
    }
}
