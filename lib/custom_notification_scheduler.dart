import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart'; // Timezone data initialization
import 'package:timezone/timezone.dart' as tz;
import 'package:custom_notification_scheduler/custom_notification_scheduler_platform_interface.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart' as platform;
import 'package:get/get.dart'; // For navigation

/// Enum for supported notification repeat intervals.
enum RepeatInterval { daily, weekly }

/// Maps [RepeatInterval] to the platform-specific repeat interval.
platform.RepeatInterval _mapToPlatformRepeatInterval(RepeatInterval interval) {
  switch (interval) {
    case RepeatInterval.daily:
      return platform.RepeatInterval.daily;
    case RepeatInterval.weekly:
      return platform.RepeatInterval.weekly;
    default:
      throw ArgumentError("Unsupported repeat interval: $interval");
  }
}

/// A Flutter plugin for scheduling local notifications with custom sounds and FCM token retrieval.
class CustomNotificationScheduler {
  static const MethodChannel _channel = MethodChannel('app.vercel.zihadsikder.custom_notification_scheduler');
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static String? _currentSoundPath;

  /// Initializes the notification scheduler with platform-specific settings.
  /// - Creates an Android notification channel.
  /// - Requests permissions on iOS.
  /// - Sets up notification response handling with navigation.
  static Future<void> initialize() async {
    try {
      // Android notification channel
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'Channel for high-priority notifications',
        importance: Importance.max,
      );

      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(channel);
      print("Android notification channel created: high_importance_channel");

      // Platform initialization settings
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize with navigation on tap
      await _flutterLocalNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          print("User tapped on notification with payload: \${response.payload}");
          if (response.payload != null) {
            try {
              final payloadData = response.payload!.split(':');
              final route = payloadData[0].trim(); // e.g., '/home'
              final id = payloadData.length > 1 ? payloadData[1].trim() : null; // e.g., '123'

              if (route.isNotEmpty) {
                if (id != null) {
                  await Get.toNamed(route, arguments: {'id': id});
                } else {
                  await Get.toNamed(route);
                }
                print("Navigated to route: $route with arguments: $id");
              } else {
                print("No valid route in payload");
              }
            } catch (e) {
              print("Error navigating from notification: $e");
            }
          }
        },
      );

      // Set up method call handler
      _channel.setMethodCallHandler(_handleMethodCalls);

      // Initialize timezone
      await _initializeTimeZone();
    } catch (e) {
      print("Error initializing notification scheduler: $e");
      rethrow;
    }
  }

  /// Initializes timezone data and sets the local timezone based on device settings.
  static Future<void> _initializeTimeZone() async {
    try {
      initializeTimeZones(); // Load timezone data from assets
      tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));
      print("Local timezone set to: Asia/Dhaka");
    } catch (e) {
      print("Error initializing timezone: $e");
      tz.setLocalLocation(tz.getLocation('UTC')); // Fallback to UTC
      print("Fallback to UTC due to error");
    }
  }

  /// Handles method calls from the native platform.
  static Future<dynamic> _handleMethodCalls(MethodCall call) async {
    try {
      switch (call.method) {
        case 'updateSound':
          final soundPath = call.arguments['soundPath'] as String?;
          if (soundPath != null && soundPath.isNotEmpty) {
            _currentSoundPath = soundPath;
            print("Notification sound updated to: $soundPath");
            return null;
          } else {
            throw PlatformException(
              code: 'INVALID_SOUND',
              message: 'Sound path is required and cannot be empty',
            );
          }

        default:
          throw PlatformException(code: 'UNIMPLEMENTED', message: 'Method not implemented');
      }
    } catch (e) {
      print('Error in method call: $e');
      throw PlatformException(
        code: 'METHOD_ERROR',
        message: 'Failed to handle method: \${call.method}',
        details: e.toString(),
      );
    }
  }

  /// Schedules a notification with the given parameters.
  /// - [title] and [body] are required.
  /// - [scheduledTime] must be in the future.
  /// - [sound] and [payload] are optional.
  /// - [repeatInterval] supports daily or weekly repetition.
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? sound,
    Map<String, dynamic>? payload,
    RepeatInterval? repeatInterval,
  }) async {
    try {
      final scheduledTimeMillis = scheduledTime.millisecondsSinceEpoch;
      if (scheduledTimeMillis < DateTime.now().millisecondsSinceEpoch) {
        throw ArgumentError("Scheduled time must be in the future");
      }

      final soundToUse = sound ?? _currentSoundPath ?? 'default_sound';
      final androidSound = soundToUse.startsWith('asset:')
          ? RawResourceAndroidNotificationSound(soundToUse.replaceFirst('asset:', '').replaceAll('.mp3', ''))
          : null;

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'Channel for high-priority notifications',
        importance: Importance.max,
        priority: Priority.high,
        sound: androidSound,
      );

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
      print('Scheduled notification: $title at $scheduledTimeMillis');
    } catch (e) {
      print('Error scheduling notification: $e');
      rethrow;
    }
  }

  /// Sets a custom sound for notifications.
  static Future<void> setNotificationSound(String soundPath) async {
    if (soundPath.isNotEmpty) {
      _currentSoundPath = soundPath;
      await _channel.invokeMethod('setNotificationSound', {'soundPath': soundPath});
    } else {
      throw ArgumentError("Sound path cannot be empty");
    }
  }

  /// Cancels all scheduled notifications.
  static Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      await _channel.invokeMethod('cancelAllNotifications');
      print('All notifications canceled');
    } catch (e) {
      print('Error canceling notifications: $e');
      rethrow;
    }
  }

  /// Retrieves the FCM token for push notifications.
  static Future<String?> getFcmToken() async {
    try {
      return await _channel.invokeMethod('getFcmToken');
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  /// Retrieves the platform version.
  static Future<String?> getPlatformVersion() async {
    try {
      return CustomNotificationSchedulerPlatform.instance.getPlatformVersion();
    } catch (e) {
      print('Error getting platform version: $e');
      return null;
    }
  }

  /// Retrieves the app package name.
  static Future<String> getAppPackageName() async {
    try {
      const platform = MethodChannel('samples.flutter.dev/package');
      return await platform.invokeMethod('getPackageName') ?? 'com.example.app';
    } catch (e) {
      print('Error getting package name: $e');
      return 'com.example.app';
    }
  }
}
