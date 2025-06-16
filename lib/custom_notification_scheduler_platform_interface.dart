import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'custom_notification_scheduler_method_channel.dart';

abstract class CustomNotificationSchedulerPlatform extends PlatformInterface {
  /// Constructs a CustomNotificationSchedulerPlatform.
  CustomNotificationSchedulerPlatform() : super(token: _token);

  static final Object _token = Object();

  static CustomNotificationSchedulerPlatform _instance = MethodChannelCustomNotificationScheduler();

  /// The default instance of [CustomNotificationSchedulerPlatform] to use.
  ///
  /// Defaults to [MethodChannelCustomNotificationScheduler].
  static CustomNotificationSchedulerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CustomNotificationSchedulerPlatform] when
  /// they register themselves.
  static set instance(CustomNotificationSchedulerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
