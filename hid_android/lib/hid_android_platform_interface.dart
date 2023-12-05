import 'dart:async';

import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'hid_android_method_channel.dart';

abstract class HidAndroidPlatform extends PlatformInterface {
  /// Constructs a HidAndroidPlatform.
  HidAndroidPlatform() : super(token: _token);
  static StreamSubscription<dynamic>? listen;

  static final Object _token = Object();

  static HidAndroidPlatform _instance = MethodChannelHidAndroid();
  //定义一个公共的流
  static final StreamController<String> _usbData =
      StreamController<String>.broadcast();
  //提供get方法将StreamController暴露出去
  static StreamController<String> get usbData => _usbData;

  //定义一个公共的流
  static final StreamController<bool> _usbStatus =
      StreamController<bool>.broadcast();
  //提供get方法将StreamController暴露出去
  static StreamController<bool> get usbStatus => _usbStatus;

  /// The default instance of [HidAndroidPlatform] to use.
  ///
  /// Defaults to [MethodChannelHidAndroid].
  static HidAndroidPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [HidAndroidPlatform] when
  /// they register themselves.
  static const eventChannel = EventChannel('hid_android1');
  static const methodChannel = MethodChannel('hid_android');

  static set instance(HidAndroidPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);

    _instance = instance;
  }

  static void init() {
    methodChannel.setMethodCallHandler((call) {
      // 同样也是根据方法名分发不同的函数
      // MethodCall
      var msg = call.arguments;
      switch (call.method) {
        case "onUsbData":
          // print("msg:$msg ----");
          usbData.sink.add(msg);
          return Future(() => null);
        case "onUsbStatus":
          print("usbStatus:$msg ----");
          usbStatus.sink.add(msg);
          return Future(() => null);
      }
      return Future(() => null);
    });
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  initialize() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
