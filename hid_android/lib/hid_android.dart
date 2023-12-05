import 'dart:async';

import 'hid_android_platform_interface.dart';

class HidAndroid {
  Future<String?> getPlatformVersion() {
    return HidAndroidPlatform.instance.getPlatformVersion();
  }

  initialize() {
    return HidAndroidPlatform.instance.initialize();
  }

  StreamController<String> useData() {
    return HidAndroidPlatform.usbData;
  }

  StreamController<bool> usbStatus() {
    return HidAndroidPlatform.usbStatus;
  }

  init() {
    return HidAndroidPlatform.init();
  }
}
