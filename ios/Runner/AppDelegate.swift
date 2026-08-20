import UIKit
import Flutter
import FirebaseCore
import GoogleMaps
import FirebaseAuth
import awesome_notifications
import FirebaseMessaging
import FBSDKCoreKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyBgKBEjpogvomINJ6uutsUQrHntz4g4PUQ")
    GeneratedPluginRegistrant.register(with: self)
      
      SwiftAwesomeNotificationsPlugin.setPluginRegistrantCallback { registry in
               SwiftAwesomeNotificationsPlugin.register(
                 with: registry.registrar(forPlugin: "io.flutter.plugins.awesomenotifications.AwesomeNotificationsPlugin")!)
           }
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "com.pt.sellspoint/meta_sdk",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { call, result in
        switch call.method {
        case "configure":
          guard
            let args = call.arguments as? [String: Any],
            let appId = args["appId"] as? String,
            let clientToken = args["clientToken"] as? String,
            !appId.isEmpty,
            !clientToken.isEmpty
          else {
            result(FlutterError(
              code: "INVALID_ARGUMENT",
              message: "appId and clientToken are required",
              details: nil
            ))
            return
          }
          Settings.shared.appID = appId
          Settings.shared.clientToken = clientToken
          AppEvents.shared.activateApp()
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
 override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
  }

}

