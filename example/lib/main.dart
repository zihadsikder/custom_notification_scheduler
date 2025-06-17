import 'package:flutter/material.dart';
import 'dart:async';
import 'package:custom_notification_scheduler/custom_notification_scheduler.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NotificationExample(),
    );
  }
}

class NotificationExample extends StatefulWidget {
  @override
  _NotificationExampleState createState() => _NotificationExampleState();
}

class _NotificationExampleState extends State<NotificationExample> {
  String? _fcmToken; // To store and display the FCM token

  @override
  void initState() {
    super.initState();
    _initializePlugin();
  }

  Future<void> _initializePlugin() async {
    try {
      await CustomNotificationScheduler.initialize();
      await _requestPermissions();
      await CustomNotificationScheduler.setNotificationSound('asset:custom_sound');
      _fcmToken = await CustomNotificationScheduler.getFcmToken();
      if (_fcmToken != null && mounted) {
        print('FCM Token: $_fcmToken');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('FCM Token: $_fcmToken')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize plugin: $e')),
        );
      }
    }
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      status = await Permission.notification.request();
      if (!status.isGranted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notification permission is required to proceed.')),
        );
      }
    }
  }

  Future<void> _scheduleNotification() async {
    var status = await Permission.notification.status;
    if (status.isGranted) {
      final scheduledTime = DateTime.now().add(Duration(seconds: 10));
      print('Scheduling notification for: $scheduledTime');
      try {
        await CustomNotificationScheduler.scheduleNotification(
          title: "Test",
          body: "This is a test notification",
          scheduledTime: scheduledTime,
          payload: {"test": "data"},
          repeatInterval: null,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Notification scheduled for ${scheduledTime.toIso8601String()}!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to schedule notification: $e')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notification permission denied')),
        );
        await openAppSettings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notification Example')),
      body: Builder(
        builder: (context) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('FCM Token: ${_fcmToken ?? "Loading..."}'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _scheduleNotification,
                child: Text('Schedule Notification'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await CustomNotificationScheduler.cancelAllNotifications();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('All notifications canceled!')),
                    );
                  }
                },
                child: Text('Cancel All'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}