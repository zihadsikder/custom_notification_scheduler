import 'dart:async';

import 'package:flutter/services.dart';

import 'package:custom_notification_scheduler/custom_notification_scheduler_platform_interface.dart';

enum RepeatInterval { daily, weekly }

class CustomNotificationScheduler {
  static const MethodChannel _channel = MethodChannel('app.vercel.zihadsikder.custom_notification_scheduler');

  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? sound,
    Map<String, dynamic>? payload,
    RepeatInterval? repeatInterval,
  }) async {
    final scheduledTimeStr = scheduledTime.toIso8601String();
    print('Sending scheduledTime: $scheduledTimeStr'); // Debug log
    await _channel.invokeMethod('scheduleNotification', {
      'title': title,
      'body': body,
      'scheduledTime': scheduledTimeStr,
      if (sound != null) 'sound': sound,
      if (payload != null) 'payload': payload,
      if (repeatInterval != null) 'repeatInterval': repeatInterval.toString().split('.').last,
    });
  }

  static Future<void> cancelAllNotifications() async {
    await _channel.invokeMethod('cancelAllNotifications');
  }

  static Future<String?> getPlatformVersion() async {
    return CustomNotificationSchedulerPlatform.instance.getPlatformVersion();
  }
}