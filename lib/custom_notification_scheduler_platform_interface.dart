import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'custom_notification_scheduler_method_channel.dart';

abstract class CustomNotificationSchedulerPlatform extends PlatformInterface {
  /// Constructs a CustomNotificationSchedulerPlatform.
  CustomNotificationSchedulerPlatform() : super(token: _token);

  static final Object _token = Object();

  static CustomNotificationSchedulerPlatform _instance = MethodChannelCustomNotificationScheduler();

  /// The default instance of the CustomNotificationSchedulerPlatform.
  static CustomNotificationSchedulerPlatform get instance => _instance;

  /// Sets the instance of the CustomNotificationSchedulerPlatform.
  static set instance(CustomNotificationSchedulerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Gets the platform version.
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion has not been implemented.');
  }
}