📆 custom_notification_scheduler
A powerful Flutter plugin to schedule local notifications, retrieve FCM tokens, and manage custom sounds. on Android and iOS, with support for:

## Overview
- ⏰ **Scheduled Delivery**: Schedule notifications for a specific `DateTime`.
- 🔁 **Repeat Intervals**: Supports daily and weekly repeating notifications.
- 🔊 **Custom Sounds**: Use custom notification sounds from app assets.
- 📦 **Payload Support**: Attach payload data for deep-linking or custom logic.

## 🚀 Features
- ✅ **Schedule Notifications**: Set notifications for a specific `DateTime`.
- ✅ **Custom Notification Sounds**: Load sounds from app assets (e.g., `assets/sounds/`).
- ✅ **Payload Support**: Include payload data for navigation or custom app logic.
- ✅ **Repeat Intervals**: Configure daily or weekly repetitions.
- ✅ **Cancel Notifications**: Cancel individual or all scheduled notifications.
- ✅ **Cross-Platform**: Fully supports Android and iOS.
- ✅ **FCM Token Retrieval**: Get the Firebase Cloud Messaging (FCM) token for push notifications.


📦 Installation
Add the plugin to your pubspec.yaml:
- ```yaml

    dependencies:
        custom_notification_scheduler: ^0.0.3
        flutter_local_notifications: ^15.1.1
        timezone: ^0.9.2
    flutter:
        assets:
            - assets/sounds/  # Add custom sound files (e.g., custom_sound.mp3)

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

## Setup
1. Initialize the plugin in main.dart:

        await CustomNotificationScheduler.initialize();

2. Ensure Firebase is configured for FCM (add google-services.json for Android and GoogleService-Info.plist for iOS).
3. Place sound files in the assets/sounds/ directory and update pubspec.yaml.

4.

## Usage
## Get FCM Token

    final fcmToken = await CustomNotificationScheduler.getFcmToken();
    print('FCM Token: $fcmToken');

## Set Notification Sound

    await CustomNotificationScheduler.setNotificationSound('asset:custom_sound.mp3'); // From assets
    // or
    await CustomNotificationScheduler.setNotificationSound('path/to/sound.mp3'); // From file system

## Schedule Notification

    await CustomNotificationScheduler.scheduleNotification(
        title: 'Reminder',
        body: 'Take your medicine!',
        scheduledTime: DateTime.now().add(Duration(minutes: 5)),
        payload: {'route': '/medicine'},
        repeatInterval: RepeatInterval.daily,
    );

## Cancel All Notifications

    await CustomNotificationScheduler.cancelAllNotifications();

## API Request Example
Use the FCM token in your backend requests:

    final requestBody = {
        'email': 'user@example.com',
        'password': 'password123',
        'fcmToken': await CustomNotificationScheduler.getFcmToken(),
    };

## Notes
* Ensure notification permissions are granted.
* For repeating notifications, use RepeatInterval.daily or RepeatInterval.weekly.
* Payloads can include navigation routes for deep linking.
* Custom sounds can be asset files (e.g., asset:custom_sound.mp3) or file paths.

## Future Enhancements
* Add cancellation by ID.
* Implement priority levels for notifications.
* Support sound file selection from device storage.


#### 5. Additional Configuration
- **Android**: Place sound files in `android/app/src/main/res/raw/` (e.g., `custom_sound.mp3`) and reference them as `asset:custom_sound` in Dart.
- **iOS**: Add sound files to `ios/Runner/Assets.xcassets/` and reference them by filename (e.g., `custom_sound.mp3`).

#### 6. Verification
- Test sound updates by calling `setNotificationSound` with a valid asset path.
- Schedule a notification and verify the custom sound plays.
- Ensure the sound updates persist across app restarts.

### Additional Needs
- **Device Storage Access**: Add a method to pick sounds from the device using `file_picker` package.
- **Sound Preview**: Implement a preview feature to play the sound before setting it.
- **Error Handling**: Add validation for unsupported sound formats.


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