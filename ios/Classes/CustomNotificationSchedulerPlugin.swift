import Flutter
import UIKit
import UserNotifications
import FirebaseMessaging

@objc public class CustomNotificationSchedulerPlugin: NSObject, FlutterPlugin, UNUserNotificationCenterDelegate {
  private var channel: FlutterMethodChannel?
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "app.vercel.zihadsikder.custom_notification_scheduler", binaryMessenger: registrar.messenger())
    let instance = CustomNotificationSchedulerPlugin()
    instance.channel = channel
    channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      instance.handle(call, result: result)
    }
    UNUserNotificationCenter.current().delegate = instance
  }


  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "scheduleNotification":
      guard let args = call.arguments as? [String: Any],
            let title = args["title"] as? String,
            let body = args["body"] as? String,
            let scheduledTimeStr = args["scheduledTime"] as? String,
            let scheduledTime = ISO8601DateFormatter().date(from: scheduledTimeStr) else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for scheduleNotification", details: nil))
        return
      }
      let sound = args["sound"] as? String
      let payload = args["payload"] as? [String: Any] ?? [:]
      let repeatInterval = args["repeatInterval"] as? String

      scheduleNotification(title: title, body: body, scheduledTime: scheduledTime, sound: sound, payload: payload, repeatInterval: repeatInterval, result: result)
    case "cancelAllNotifications":
      cancelAllNotifications(result)
    case "getFcmToken":
      getFcmToken(result)
    case "setNotificationSound":
      guard let args = call.arguments as? [String: Any],
            let soundPath = args["soundPath"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid sound path", details: nil))
        return
      }
      setNotificationSound(soundPath, result)
    case "getDeviceTimezone":
          let timezone = TimeZone.current.identifier // e.g., "Asia/Dhaka"
          result(timezone)
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func scheduleNotification(title: String, body: String, scheduledTime: Date, sound: String?, payload: [String: Any], repeatInterval: String?, result: @escaping FlutterResult) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.userInfo = payload // Support for deep-linking or custom logic

    // Handle custom sound
    if let sound = sound, !sound.isEmpty {
      content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: sound))
    } else {
      content.sound = UNNotificationSound.default
    }

    let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: scheduledTime)
    let trigger: UNNotificationTrigger
    if let interval = repeatInterval {
      switch interval {
      case "daily":
        trigger = UNTimeIntervalNotificationTrigger(timeInterval: 86400, repeats: true) // 24 hours
      case "weekly":
        trigger = UNTimeIntervalNotificationTrigger(timeInterval: 604800, repeats: true) // 7 days
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

  private func getFcmToken(_ result: @escaping FlutterResult) {
    Messaging.messaging().token { token, error in
      if let error = error {
        result(FlutterError(code: "FCM_ERROR", message: "Failed to get FCM token", details: error.localizedDescription))
      } else if let token = token {
        result(token)
      } else {
        result(nil)
      }
    }
  }

  private func setNotificationSound(_ soundPath: String, _ result: @escaping FlutterResult) {
    channel?.invokeMethod("updateSound", arguments: ["soundPath": soundPath])
    result(true)
  }
}