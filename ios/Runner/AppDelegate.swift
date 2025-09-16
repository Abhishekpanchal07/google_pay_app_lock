import UIKit
import Flutter
import LocalAuthentication

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "secure_auth", binaryMessenger: controller.binaryMessenger)

        channel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            switch call.method {
            case "checkAuthMethods":
                let context = LAContext()
                var error: NSError?
                let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
                let canBiometric = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
                result(["biometric": canBiometric, "pin": canEvaluate])
            case "authenticateDevice":
                let context = LAContext()
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Authenticate to access app") { success, _ in
                    DispatchQueue.main.async {
                        result(success)
                    }
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
