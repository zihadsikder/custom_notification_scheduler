📆 custom_notification_scheduler
A powerful Flutter plugin to schedule custom local notifications on Android and iOS, with support for:

    `⏰ Scheduled delivery
    
    🔁 Repeat intervals
    
    🔊 Custom sounds
    
    📦 Payload support for deep-link or custom logic`

Ideal for task reminders, daily habits, alarms, or calendar events.

🚀 Features
✅ Schedule notifications for a specific DateTime
✅ Supports custom notification sounds (from assets)
✅ Attach payload data for navigation or logic
✅ Supports daily, weekly, and custom repeat intervals
✅ Cancel individual or all scheduled notifications
✅ Android and iOS support

📦 Installation
Add the plugin to your pubspec.yaml:

    dependencies:
    custom_notification_scheduler: ^0.0.1

Then run:
    
    flutter pub get

🛠️ Platform Setup
▶️ Android
Add your custom sound file (e.g. custom_sound.mp3) in:

    android/app/src/main/res/raw/

Ensure your app has the correct permission to post notifications (for Android 13+):

    <!-- AndroidManifest.xml -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

🍎 iOS
Add your sound file (e.g. custom_sound.mp3) to:

    ios/Runner/Resources/

Enable notifications in Info.plist:

    <key>UIBackgroundModes</key>
    <array>
    <string>fetch</string>
    <string>remote-notification</string>
    </array>
📚 Usage
⏰ Schedule a Notification

    import 'package:custom_notification_scheduler/custom_notification_scheduler.dart';
    
    void scheduleNotification() {
    CustomNotificationScheduler.scheduleNotification(
        title: "Reminder",
        body: "Time to take action!",
        scheduledTime: DateTime.now().add(Duration(minutes: 5)),
        sound: "custom_sound.mp3", // Optional: must exist in res/raw or iOS bundle
        payload: {"id": 1}, // Optional: useful for navigation or logic
        repeatInterval: RepeatInterval.daily, // Optional: daily, weekly, etc.
     );
    }
❌ Cancel All Notifications

    void cancelNotifications() {
    CustomNotificationScheduler.cancelAllNotifications();
    }

💡 Why Use This Plugin?
✅ Simplified API: Easy to use with just one method call

✅ Cross-platform: Works consistently across Android and iOS

✅ Customizable: Supports your app’s tone with custom sounds and payloads

✅ Lightweight: Minimal dependency footprint

✅ Ideal for reminders: Health, task, medication, or productivity apps

📌 Coming Soon
Schedule by notification ID

Cancel by ID

Callback support when notification is tapped

🤝 Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

📄 License
MIT © 2025 zihadsikder.vercel.app