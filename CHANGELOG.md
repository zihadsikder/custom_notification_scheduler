## 0.0.5 (June 18, 2025)
- Improved release with enhanced compatibility and bug fixes.
- **Features**:
  - Upgraded to `flutter_local_notifications` 19.2.1 for improved notification handling.
- **Improvements**:
  - Ensured null safety compatibility with Dart SDK 3.8.1 and Flutter 3.3.0+.
  - Optimized iOS build process by removing deprecated `uiLocalNotificationDateInterpretation` parameter.
  - Enhanced Android build configuration with Java 11 desugaring support.
- **Bug Fixes**:
  - Resolved dependency conflict causing version solving failures.
  - Fixed iOS build errors related to outdated notification API parameters.
- **Breaking Changes**:
  - Removed support for older `flutter_local_notifications` APIs incompatible with version 19.2.1.
- Supports Android and iOS.

## 0.0.2 (June 17, 2025)
- Enhanced release with additional features and bug fixes.
- **Features**:
    - Added support for custom notification sounds (from assets or raw resources).
    - Introduced FCM (Firebase Cloud Messaging) token retrieval for push notifications.
    - Added payload support for deep-linking or custom logic in notifications.
    - Implemented repeat intervals (daily and weekly) for recurring notifications.
- **Improvements**:
    - Improved iOS compatibility with updated CocoaPods configuration.
    - Enhanced error handling for scheduling and permission requests.
    - Updated documentation for sound file placement and usage.
- **Bug Fixes**:
    - Fixed invalid `podspec` file issue causing CocoaPods install failures.
    - Resolved context safety issues with `ScaffoldMessenger` in async operations.
- **Breaking Changes**:
    - Removed `AlarmManager`-based scheduling in favor of `flutter_local_notifications`.
- Supports Android and iOS.

## 0.0.1
- Initial release.
- Supports Android and iOS.
- Schedule and cancel notifications.