import Flutter
import UIKit
import UserNotifications

@objc public class CustomNotificationSchedulerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "app.vercel.zihadsikder.custom_notification_scheduler", binaryMessenger: registrar.messenger())
    let instance = CustomNotificationSchedulerPlugin()
    channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      instance.handle(call, result: result)
    }
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "scheduleNotification":
      guard let args = call.arguments as? [String: Any],
            let title = args["title"] as? String,
            let body = args["body"] as? String,
            let scheduledTimeStr = args["scheduledTime"] as? String,
            let scheduledTime = ISO8601DateFormatter().date(from: scheduledTimeStr) else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        return
      }
      let sound = args["sound"] as? String
      let payload = args["payload"] as? [String: Any] ?? [:]
      let repeatInterval = args["repeatInterval"] as? String

      scheduleNotification(title: title, body: body, scheduledTime: scheduledTime, sound: sound, payload: payload, repeatInterval: repeatInterval, result: result)
    case "cancelAllNotifications":
      cancelAllNotifications(result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func scheduleNotification(title: String, body: String, scheduledTime: Date, sound: String?, payload: [String: Any], repeatInterval: String?, result: @escaping FlutterResult) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = sound.map { UNNotificationSound(named: UNNotificationSoundName(rawValue: $0)) } ?? UNNotificationSound.default
    content.userInfo = payload

    let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: scheduledTime)
    let trigger: UNNotificationTrigger
    if let interval = repeatInterval {
      switch interval {
      case "RepeatInterval.daily":
        trigger = UNTimeIntervalNotificationTrigger(timeInterval: 86400, repeats: true)
      case "RepeatInterval.weekly":
        trigger = UNTimeIntervalNotificationTrigger(timeInterval: 604800, repeats: true)
      default:
        trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
      }
    } else {
      trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
    }

    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request) { error in
      if let error = error {
        result(FlutterError(code: "SCHEDULING_ERROR", message: error.localizedDescription, details: nil))
      } else {
        result(nil)
      }
    }
  }

  private func cancelAllNotifications(_ result: @escaping FlutterResult) {
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    result(nil)
  }
}