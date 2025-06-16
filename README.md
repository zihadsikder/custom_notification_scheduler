# custom_notification_scheduler

A Flutter plugin to schedule custom local notifications on Android and iOS with support for custom sounds, payloads, and repeat intervals.

## Installation

Add `custom_notification_scheduler` to your `pubspec.yaml`:
## Usage
    import 'package:custom_notification_scheduler/custom_notification_scheduler.dart';
    
    void scheduleNotification() {
    CustomNotificationScheduler.scheduleNotification(
    title: "Reminder",
    body: "Time to take action!",
    scheduledTime: DateTime.now().add(Duration(minutes: 5)),
    sound: "custom_sound.mp3", // Optional
    payload: {"id": 1}, // Optional
    repeatInterval: RepeatInterval.daily, // Optional
    );
    }
    
    void cancelNotifications() {
    CustomNotificationScheduler.cancelAllNotifications();
    }

```yaml
dependencies:
  custom_notification_scheduler: ^0.0.1