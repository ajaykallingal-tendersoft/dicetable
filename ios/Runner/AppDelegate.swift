import Flutter
import UIKit
import GoogleMaps
import FirebaseCore
import FirebaseMessaging


@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
      UNUserNotificationCenter.current().delegate = self

       let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
       UNUserNotificationCenter.current().requestAuthorization(
         options: authOptions,
         completionHandler: { _, _ in }
       )
       application.registerForRemoteNotifications()
    GMSServices.provideAPIKey("AIzaSyA1ykJA5q4OYpvR1h7Bx5BaicxgKuKhqVg")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  
  }
}
