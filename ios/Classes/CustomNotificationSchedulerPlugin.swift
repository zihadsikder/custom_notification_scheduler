import Flutter
import UIKit
import UserNotifications

public class CustomNotificationSchedulerPlugin: NSObject, FlutterPlugin {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "custom_notification_scheduler", binaryMessenger: registrar.messenger())
    let instance = CustomNotificationSchedulerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)

    case "scheduleNotification":
      guard let args = call.arguments as? [String: Any],
            let title = args["title"] as? String,
            let body = args["body"] as? String,
            let timestamp = args["timestamp"] as? Double else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing arguments", details: nil))
        return
      }

      scheduleNotification(title: title, body: body, timestamp: timestamp)
      result("Notification scheduled")

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func scheduleNotification(title: String, body: String, timestamp: Double) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = .default

    let triggerDate = Date(timeIntervalSince1970: timestamp)
    let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate)
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
      if let error = error {
        print("Error scheduling notification: \(error)")
      } else {
        print("Notification scheduled successfully")
      }
    }
  }
}
