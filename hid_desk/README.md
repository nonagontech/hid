# hid_desk

这是一个Flutter的HID插件，用于Android平台。

## 安装
### macos

将代码下载到本地引用即可
``` 

    dependencies:
        hid_android:    
            path: hid_android
```  

### windows



## 开始
```dart 
import 'package:hid_android/hid_android.dart';
import 'dart:async';

  StreamSubscription? _usbData;
  StreamSubscription? _usbStatus;
  @override
  void initState() {
    // TODO: implement initState
    super.initState(); 
    init(); 
  }
  void init() async {
    await _hidAndroidPlugin.init();
    await _hidAndroidPlugin.initialize();
  }
  void getData() {
    _usbData?.cancel();
    _usbData = _hidAndroidPlugin.useData().stream.listen((event) {
        //event为usb设备发送的数据
    });

    _usbStatus?.cancel();
    _usbStatus = _hidAndroidPlugin.usbStatus().stream.listen((event) {
         //event为usb设备是否插入手机
    });
  }
```

## Additional information

hidapi: https://github.com/libusb/hidapi