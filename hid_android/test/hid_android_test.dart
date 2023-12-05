import 'package:flutter_test/flutter_test.dart';
import 'package:hid_android/hid_android.dart';
import 'package:hid_android/hid_android_platform_interface.dart';
import 'package:hid_android/hid_android_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockHidAndroidPlatform
    with MockPlatformInterfaceMixin
    implements HidAndroidPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final HidAndroidPlatform initialPlatform = HidAndroidPlatform.instance;

  test('$MethodChannelHidAndroid is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelHidAndroid>());
  });

  test('getPlatformVersion', () async {
    HidAndroid hidAndroidPlugin = HidAndroid();
    MockHidAndroidPlatform fakePlatform = MockHidAndroidPlatform();
    HidAndroidPlatform.instance = fakePlatform;

    expect(await hidAndroidPlugin.getPlatformVersion(), '42');
  });
}
