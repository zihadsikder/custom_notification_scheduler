import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'custom_notification_scheduler_platform_interface.dart';

/// An implementation of [CustomNotificationSchedulerPlatform] that uses method channels.
class MethodChannelCustomNotificationScheduler extends CustomNotificationSchedulerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('custom_notification_scheduler');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
