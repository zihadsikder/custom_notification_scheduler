import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:custom_notification_scheduler/custom_notification_scheduler_platform_interface.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart' as platform;

enum RepeatInterval { daily, weekly }

// Map your custom RepeatInterval to flutter_local_notifications_platform_interface RepeatInterval
platform.RepeatInterval _mapToPlatformRepeatInterval(RepeatInterval interval) {
  switch (interval) {
    case RepeatInterval.daily:
      return platform.RepeatInterval.daily;
    case RepeatInterval.weekly:
      return platform.RepeatInterval.weekly;
    default:
      throw ArgumentError("Unsupported repeat interval");
  }
}

class CustomNotificationScheduler {
  static const MethodChannel _channel = MethodChannel('app.vercel.zihadsikder.custom_notification_scheduler');
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static String? _currentSoundPath; // Store the current sound path

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("User tapped on notification with payload: ${response.payload}");
      },
    );

    // Set up method channel for sound updates
    _channel.setMethodCallHandler(_handleMethodCalls);
  }

  static Future<void> _handleMethodCalls(MethodCall call) async {
    if (call.method == "updateSound") {
      final soundPath = call.arguments["soundPath"] as String?;
      if (soundPath != null) {
        _currentSoundPath = soundPath;
        print("Notification sound updated to: $soundPath");
      }
    }
  }

  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? sound,
    Map<String, dynamic>? payload,
    RepeatInterval? repeatInterval,
  }) async {
    final scheduledTimeMillis = scheduledTime.millisecondsSinceEpoch;
    print('Scheduling notification: $title at $scheduledTimeMillis');

    final soundToUse = sound ?? _currentSoundPath ?? 'default_sound';
    final androidSound = soundToUse.startsWith('asset:')
        ? RawResourceAndroidNotificationSound(soundToUse.replaceFirst('asset:', '').replaceAll('.mp3', ''))
        : null;

    final AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails('high_importance_channel', 'High Importance Notifications',
        channelDescription: 'Channel for high-priority notifications',
        importance: Importance.max,
        priority: Priority.high,
        sound: androidSound);

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: soundToUse.isNotEmpty ? soundToUse : null,
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final id = scheduledTimeMillis ~/ 1000;

    if (scheduledTimeMillis < DateTime.now().millisecondsSinceEpoch) {
      throw Exception("Scheduled time must be in the future");
    }

    if (repeatInterval == null) {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        platformDetails,
        payload: payload?.toString(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } else {
      await _flutterLocalNotificationsPlugin.periodicallyShow(
        id,
        title,
        body,
        _mapToPlatformRepeatInterval(repeatInterval),
        platformDetails,
        payload: payload?.toString(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  static Future<void> setNotificationSound(String soundPath) async {
    if (soundPath.isNotEmpty) {
      _currentSoundPath = soundPath;
      await _channel.invokeMethod('setNotificationSound', {'soundPath': soundPath});
    } else {
      throw ArgumentError("Sound path cannot be empty");
    }
  }

  static Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    await _channel.invokeMethod('cancelAllNotifications');
  }

  static Future<String?> getFcmToken() async {
    return await _channel.invokeMethod('getFcmToken');
  }

  static Future<String?> getPlatformVersion() async {
    return CustomNotificationSchedulerPlatform.instance.getPlatformVersion();
  }

  static Future<String> getAppPackageName() async {
    const platform = MethodChannel('samples.flutter.dev/package');
    return await platform.invokeMethod('getPackageName') ?? 'com.example.app';
  }
}