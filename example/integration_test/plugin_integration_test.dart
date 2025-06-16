// This is a basic Flutter integration test for custom_notification_scheduler.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:custom_notification_scheduler/custom_notification_scheduler.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('scheduleNotification test', (WidgetTester tester) async {
    // Schedule a notification for 5 seconds from now
    final scheduledTime = DateTime.now().add(const Duration(seconds: 5));
    await CustomNotificationScheduler.scheduleNotification(
      title: "Test Notification",
      body: "This is a test notification",
      scheduledTime: scheduledTime,
      sound: "custom_sound.mp3",
      payload: {"test": "data"},
      repeatInterval: RepeatInterval.daily,
    );

    // Wait for the notification to be scheduled (short delay for setup)
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Note: Verifying the notification delivery requires platform-specific
    // handling (e.g., checking logs or UI interaction), which is complex in
    // integration tests. For now, we assume the method call succeeds.
    // You can enhance this test by adding a mock or platform channel response
    // verification if needed.

    // Clean up by canceling the notification
    await CustomNotificationScheduler.cancelAllNotifications();
  });
}