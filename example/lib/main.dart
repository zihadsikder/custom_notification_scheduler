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
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      status = await Permission.notification.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notification permission is required to proceed.')),
        );
      }
    }
  }

  Future<void> _scheduleNotification() async {
    var status = await Permission.notification.status;
    if (status.isGranted) {
      // Set scheduledTime to 10 seconds from now
      final scheduledTime = DateTime.now().add(Duration(seconds: 10));
      print('Scheduling notification for: $scheduledTime');
      try {
        await CustomNotificationScheduler.scheduleNotification(
          title: "Test",
          body: "This is a test notification",
          scheduledTime: scheduledTime,
          sound: "custom_sound.mp3", // Ensure this file exists
          payload: {"test": "data"},
          repeatInterval: null, // Remove repeat for one-time test
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notification scheduled for ${scheduledTime.toIso8601String()}!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to schedule notification: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification permission denied')),
      );
      await openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notification Example')),
      body: Builder( // Use Builder to avoid BuildContext access across async gaps
        builder: (context) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _scheduleNotification(),
                child: Text('Schedule Notification'),
              ),
              ElevatedButton(
                onPressed: () {
                  CustomNotificationScheduler.cancelAllNotifications();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('All notifications canceled!')),
                  );
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