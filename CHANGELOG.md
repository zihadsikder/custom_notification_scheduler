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