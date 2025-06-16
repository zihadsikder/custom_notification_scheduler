import 'package:flutter_test/flutter_test.dart';
import 'package:custom_notification_scheduler/custom_notification_scheduler.dart';
import 'package:custom_notification_scheduler/custom_notification_scheduler_platform_interface.dart';
import 'package:custom_notification_scheduler/custom_notification_scheduler_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';


class MockCustomNotificationSchedulerPlatform
    with MockPlatformInterfaceMixin
    implements CustomNotificationSchedulerPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final CustomNotificationSchedulerPlatform initialPlatform = CustomNotificationSchedulerPlatform.instance;

  setUp(() {
    // Reset the instance before each test
    CustomNotificationSchedulerPlatform.instance = MethodChannelCustomNotificationScheduler();
  });

  test('$MethodChannelCustomNotificationScheduler is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCustomNotificationScheduler>());
  });

  test('getPlatformVersion', () async {
    // Set up the mock platform
    final fakePlatform = MockCustomNotificationSchedulerPlatform();
    CustomNotificationSchedulerPlatform.instance = fakePlatform;

    // Call the static method
    expect(await CustomNotificationScheduler.getPlatformVersion(), '42');
  });
}