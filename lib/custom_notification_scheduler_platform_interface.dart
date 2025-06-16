import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'custom_notification_scheduler_method_channel.dart';

abstract class CustomNotificationSchedulerPlatform extends PlatformInterface {
  CustomNotificationSchedulerPlatform() : super(token: _token);
  static final Object _token = Object();

  static CustomNotificationSchedulerPlatform _instance = MethodChannelCustomNotificationScheduler();

  static CustomNotificationSchedulerPlatform get instance => _instance;

  static set instance(CustomNotificationSchedulerPlatform instance) {
    if (instance == null) {
      throw UnsupportedError('Instance cannot be null!');
    }
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion has not been implemented.');
  }
}