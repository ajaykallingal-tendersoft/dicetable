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
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }
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
    override func applicationDidBecomeActive(_ application: UIApplication) {
    application.applicationIconBadgeNumber = 0
    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    
    if #available(iOS 16.0, *) {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
  }
   override func applicationDidEnterBackground(_ application: UIApplication) {
    application.applicationIconBadgeNumber = 0
  }
}
