import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hid_demo/constant.dart' as constant;
import 'package:hid_macos/hid_macos.dart';

StreamController<String> readController = StreamController.broadcast();
StreamController<Device> deviceController = StreamController.broadcast();

Device? currentDevice;
bool isOpen = false;

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});
  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  // int _counter = 0;

  late HidPluginMacOS hidPlatform;
  //血氧仪
  // final int vendorId = 0x483;
  // final int productId = 0x5750;
  //底座
  // final int vendorId = 0x1a86;
  // final int productId = 0x5722;
  //键盘
  // final int vendorId = 0x5ac;
  // final int productId = 0x24f;
  //扫描枪
  final int vendorId = 0x2010;
  final int productId = 0x7638;
  List<Device> list = [];

  List<Widget> listView() {
    return list.map((e) {
      return Container(
          margin: EdgeInsets.only(bottom: 16.0, left: 16.0),
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () {
              setDevice(e.vendorId, e.productId);
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xe1e1e1ff)),
                shape: MaterialStateProperty.all(constant.shape1),
                alignment: Alignment.center),
            child: Text(
              'VID: ${e.vendorId}  PID: ${e.productId}  productName: ${e.productName}  serialNumber: ${e.serialNumber}',
              style: constant.deviceStyle,
            ),
          ));
    }).toList();
  }

  String getVendorId() {
    return currentDevice == null ? "" : currentDevice!.vendorId.toString();
  }

  String getProductId() {
    return currentDevice == null ? "" : currentDevice!.productId.toString();
  }

  @override
  void initState() {
    super.initState();
    hidPlatform = HidPluginMacOS();
    int state = hidPlatform.init();
    print("初始化结果：${state == 0 ? "成功" : "失败"}");
    // resolveData([
    //   237,
    //   72,
    //   101,
    //   97,
    //   100,
    //   101,
    //   114,
    //   32,
    //   69,
    //   114,
    //   114,
    //   111,
    //   114,
    //   33,
    //   0,
    //   0
    // ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: constant.theme,
        child: Column(children: [
          Container(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xe1e1e1ff)),
                  shape: MaterialStateProperty.all(constant.shape1)),
              child: Text(
                "Back",
                style: constant.upStyle,
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
              child: ListView(
                children: listView(),
              ),
            ),
          ),

          // []) {
          //   return ListTile(title: Text('$index'));
          // })),
          Container(
            height: 200,
            margin: const EdgeInsets.only(top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "找到HID设备数: ${list.length}",
                  style: constant.deviceStyle,
                ),
                Column(
                  children: [
                    Text(
                      "当前选择",
                      style: constant.deviceStyle,
                    ),
                    Text(
                      "VID: ${getVendorId()}",
                      style: constant.deviceStyle,
                    ),
                    Text(
                      "PID: ${getProductId()}",
                      style: constant.deviceStyle,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 50),
                      child: TextButton(
                        onPressed: () {
                          connectDevice(context);
                        },
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Color(0xe1e1e1ff)),
                            shape: MaterialStateProperty.all(constant.shape1)),
                        child: Text(
                          "连接",
                          style: constant.upStyle,
                        ),
                      ),
                    ),
                    Container(
                      child: TextButton(
                        onPressed: listDevices,
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Color(0xe1e1e1ff)),
                            shape: MaterialStateProperty.all(constant.shape1),
                            alignment: Alignment.center),
                        child: Text(
                          "刷新",
                          style: constant.upStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ]));
  }

  Future<void> listDevices() async {
    print("mounted: $mounted");
    if (isOpen) {
      print("断开连接");
      currentDevice?.close();
    }

    final hidDevices = await hidPlatform.getDeviceList();
    print("设备个数：${hidDevices.length} ");
    setState(() {
      list.clear();
      list.addAll(hidDevices);

      // print(list.length);
    });
    // if (!mounted) return;
  }

  void setDevice(vendorId, productId) {
    list.forEach((device) {
      if (device.productId == productId && device.vendorId == vendorId) {
        // if (device.serialNumber.toNativeUtf8().toDartString() == "") {
        //   return;
        // }
        // if (device.usagePage != usagePage) {
        //   return;
        // }
        print("找到设备");
        setState(() {
          currentDevice = device;
          deviceController.sink.add(device);
        });
      }
    });
  }

  void connectDevice(context) {
    if (currentDevice == null) {
      return;
    }
    print("连接设备");
    currentDevice!.openController.stream.listen((event) {
      print("listen: $event");
      isOpen = event;
    });
    var value = currentDevice!.open();
    value.then((event) {
      print(event);
      isOpen = event;
      if (event) {
        EasyLoading.showSuccess("连接成功！");
        Navigator.of(context).pop();
        currentDevice!.read(1024, 1).listen((event) {
          resolveData(event);
        });
      } else {
        //  showConnectFail();
        EasyLoading.showError("连接失败！\n此设备无法连接");
      }
    });
  }

  void showConnectFail() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('错误'),
            actions: [
              TextButton(
                child: Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('确定'),
                onPressed: () {
                  // printf
                  Navigator.of(context).pop();
                },
              )
            ],
            content: Text('连接失败！\n此设备无法连接'),
          );
        });
  }

  void resolveData(List<int> data) {
    print("接受到的数据====${data.length}");
    if (data.isEmpty) {
      return;
    }
    String str = "";
    // List<int> data1 = [];
    data.forEach((element) {
      String a = element.toRadixString(16);
      if (a.length == 1) {
        a = '0$a';
      }
      str += a;
      // str += String.fromCharCode(element);
    });
    readController.sink.add(str);
    // print("${ascii.decode(data, allowInvalid: true)}");
  }
}

void wirteData(String data) async {
  print("写数据====");
  if (data.isEmpty || currentDevice == null) {
    return;
  }
  List<int> arr = [];

  for (int i = 0; i < data.length; i += 2) {
    arr.add(int.parse(data[i] + data[i + 1], radix: 16));
  }

  // 打开mella pro底座通信 自定义指令 【0xaa, 0x04, 0x36, 0x11, 0x23, 0x55】
  currentDevice?.openController.stream.listen((event) {
    if (!event) {
      EasyLoading.showError("设备写入失败！连接断开");
    }
  });
  currentDevice?.write(arr);

  return;
}

void close() async {
  if (!isOpen) {
    return;
  }
  print("关闭连接====");
  currentDevice?.close();
  isOpen = false;
  EasyLoading.showSuccess("断开成功");
  return;
}
  // _getUsagePageIcon(int? usagePage, int? usage) {
  //   switch (usagePage) {
  //     case 0x01:
  //       switch (usage) {
  //         case 0x01:
  //           return Icons.north_west;
  //         case 0x02:
  //           return Icons.mouse;
  //         case 0x04:
  //         case 0x05:
  //           return Icons.gamepad;
  //         case 0x06:
  //           return Icons.keyboard;
  //       }
  //       return Icons.computer;
  //     case 0x0b:
  //       switch (usage) {
  //         case 0x04:
  //         case 0x05:
  //           return Icons.headset_mic;
  //       }
  //       return Icons.phone;
  //     case 0x0c:
  //       return Icons.toggle_on;
  //     case 0x0d:
  //       return Icons.touch_app;
  //     case 0xf1d0:
  //       return Icons.security;
  //   }
  //   return Icons.usb;
  // } 
  //   return MaterialApp(
  //     home: Scaffold(
  //       appBar: AppBar(
  //         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
  //         title: Text("fsf"),
  //       ),
  //       body: Center(
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: <Widget>[
  //             TextButton(
  //                 onPressed: () {
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(builder: (context) => DevicePage()),
  //                   );
  //                 },
  //                 // style: const ButtonStyle(
  //                 //     textStyle:MaterialStateProperty(const TextStyle(fontSize: 12,color: Colors.black))

  //                 // ),
  //                 child: const Text("发送测试数据")),
  //             Text(
  //               'test2',
  //               style: Theme.of(context).textTheme.headlineMedium,
  //             ),
  //           ],
  //         ),
  //       ),
  //       floatingActionButton: FloatingActionButton(
  //         onPressed: _listDevices,
  //         tooltip: isOpen ? "断开连接" : "开始连接",
  //         // backgroundColor: Colors.white,
  //         // foregroundColor: Colors.grey,
  //         child: isOpen
  //             ? const Icon(Icons.usb_outlined)
  //             : const Icon(Icons.usb_off),
  //       ), // This trailing comma makes auto-formatting nicer for build methods.
  //     ),
  //   );
  // }
