import 'dart:async';

import 'package:flutter/services.dart';

class CustomNotificationScheduler {
  static const MethodChannel _channel =
  MethodChannel('app.vercel.zihadsikder.custom_notification_scheduler');

  /// Schedules a notification with optional custom sound, payload, and repeat interval.
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? sound, // Custom sound file name (e.g., "custom_sound.mp3")
    Map<String, dynamic>? payload, // Custom data payload
    RepeatInterval? repeatInterval, // Repeat option
  }) async {
    final args = {
      'title': title,
      'body': body,
      'scheduledTime': scheduledTime.toIso8601String(),
      'sound': sound,
      'payload': payload ?? {},
      'repeatInterval': repeatInterval?.toString(),
    };
    await _channel.invokeMethod('scheduleNotification', args);
  }

  /// Cancels all scheduled notifications.
  static Future<void> cancelAllNotifications() async {
    await _channel.invokeMethod('cancelAllNotifications');
  }
  /// Returns the platform version (e.g., Android or iOS version).
  static Future<String?> getPlatformVersion() async {
    final version = await _channel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}

/// Enum for repeat intervals.
enum RepeatInterval {
  none,
  daily,
  weekly,
}