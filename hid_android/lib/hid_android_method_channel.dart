import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'hid_android_platform_interface.dart';

/// An implementation of [HidAndroidPlatform] that uses method channels.
class MethodChannelHidAndroid extends HidAndroidPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('hid_android');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  initialize() async {
    await methodChannel.invokeMethod<String>('initialize');
  }
}
