import 'package:custom_notification_scheduler/custom_notification_scheduler_platform_interface.dart';
import 'package:flutter/services.dart';

class MethodChannelCustomNotificationScheduler extends CustomNotificationSchedulerPlatform {
  static const MethodChannel _channel = MethodChannel('app.vercel.zihadsikder.custom_notification_scheduler');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await _channel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}