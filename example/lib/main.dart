import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hid_demo/constant.dart' as constant;
import 'package:hid_demo/list.dart';
import 'package:hid_demo/show.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'hid调试工具',
    home: const MyApp(),
    builder: EasyLoading.init(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController con = TextEditingController();
  int? vendorId;
  int? productId;
  String content = "";

  @override
  void initState() {
    super.initState();
    readController.stream.listen((event) {
      setState(() {
        content = event;
      });
    });

    deviceController.stream.listen((event) {
      setState(() {
        vendorId = event.vendorId;
        productId = event.productId;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: constant.theme,
        child: Column(children: [
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DevicePage()),
                  );
                  // _showDevice();
                },
                child: Text(
                  "选择HID设备",
                  style: constant.upStyle,
                ),
              ),
              TextButton(
                  onPressed: () {},
                  child: Text(
                    "设置",
                    style: constant.upStyle,
                  )),
              TextButton(
                  onPressed: () {},
                  child: Text(
                    "帮助",
                    style: constant.upStyle,
                  )),
            ],
          ),
          Expanded(
            child: Container(
              // decoration:
              //     BoxDecoration(border: Border.all(color: Colors.black)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: 800,
                            height: 600,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                color: Colors.white
                                // boxShadow: [
                                //   BoxShadow(
                                //       color: Colors.black,
                                //       offset: Offset(22, 22))
                                // ]
                                ),
                            child: Text(content),
                          ),
                        ),
                        Container(
                            height: 60,
                            margin: const EdgeInsets.only(left: 10, top: 10),
                            child: TextField(
                              controller: con,
                              decoration:
                                  InputDecoration(border: OutlineInputBorder()),
                            ))
                      ],
                    ),
                  ),
                  Container(
                    width: 100,
                    // color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 100,
                                  child: const Text("操作",
                                      textAlign: TextAlign.left),
                                ),
                                ShowID(
                                  width: 90,
                                  vendorId: vendorId,
                                  productId: productId,
                                ),
                                TextButton(
                                  onPressed: () {
                                    close();
                                  },
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Color(0xe1e1e1ff)),
                                      shape: MaterialStateProperty.all(
                                          constant.shape1)),
                                  child: Text(
                                    "断开连接",
                                    style: constant.upStyle,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 18, bottom: 60),
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        content = "";
                                      });
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Color(0xe1e1e1ff)),
                                        shape: MaterialStateProperty.all(
                                            constant.shape1)),
                                    child: Text(
                                      "清空",
                                      style: constant.upStyle,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 18, bottom: 10),
                                  child: TextButton(
                                    onPressed: () {
                                      // String text = con.text;
                                      wirteData(con.text);
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Color(0xe1e1e1ff)),
                                        shape: MaterialStateProperty.all(
                                            constant.shape1),
                                        alignment: Alignment.center),
                                    child: Text(
                                      "发送",
                                      style: constant.upStyle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void _showDevice() {
    print("object");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(width: 500, height: 500, child: DevicePage());
      },
    );
  }
}

class FirstRoute extends StatelessWidget {
  const FirstRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Route'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Open route'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SecondRoute()),
            );
          },
        ),
      ),
    );
  }
}

class SecondRoute extends StatelessWidget {
  const SecondRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}
