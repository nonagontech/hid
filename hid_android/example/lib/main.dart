import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:hid_android/hid_android.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _hidAndroidPlugin = HidAndroid();
  StreamSubscription? _usbData;
  StreamSubscription? _usbStatus;
  bool? usbState;
  String usbData = '';

  @override
  void initState() {
    super.initState();

    initPlatformState();
    init();
    getData();
  }

  void init() async {
    await _hidAndroidPlugin.init();
    await _hidAndroidPlugin.initialize();
  }

  getData() {
    _usbData?.cancel();
    _usbData = _hidAndroidPlugin.useData().stream.listen((event) {
      print("USB原始数据：$event");
      setState(() {
        usbData = event;
      });
    });

    _usbStatus?.cancel();
    _usbStatus = _hidAndroidPlugin.usbStatus().stream.listen((event) {
      print("USB的原始状态：$event");
      setState(() {
        usbState = event;
      });
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _hidAndroidPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Running on: $_platformVersion\n'),
              Text('usbState: $usbState\n'),
              Text('usbData: $usbData\n'),
            ],
          ),
        ),
      ),
    );
  }
}
