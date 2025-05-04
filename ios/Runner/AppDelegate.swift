import UIKit
import Flutter
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // إعداد أزرار التفاعل للإشعارات
    let takenAction = UNNotificationAction(identifier: "taken", title: "تم التناول", options: [.foreground])
    let skippedAction = UNNotificationAction(identifier: "skipped", title: "تخطي", options: [.destructive])

    let category = UNNotificationCategory(
      identifier: "med_category",
      actions: [takenAction, skippedAction],
      intentIdentifiers: [],
      options: []
    )

    UNUserNotificationCenter.current().setNotificationCategories([category])

    // تفعيل إعدادات Flutter
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
