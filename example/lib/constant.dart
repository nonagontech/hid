import 'package:flutter/material.dart';
import 'package:hid_demo/show.dart';

TextStyle upStyle = const TextStyle(
    fontSize: 12, color: Colors.black, fontFamily: "PingFang SC");

TextStyle deviceStyle = const TextStyle(
    fontSize: 16, color: Colors.black, fontFamily: "PingFang SC");

//shape1
BeveledRectangleBorder shape1 = const BeveledRectangleBorder(
    // borderRadius: BorderRadius.circular(20.0),
    side: BorderSide(
  style: BorderStyle.none,
));

//shape2   一个 圆形的shape
CircleBorder shape2 = const CircleBorder(
  side: BorderSide(
    //设置 界面效果
    color: Colors.brown,
    width: 3.0,
    style: BorderStyle.solid,
  ),
);

//shape3   一个 类似足球场的shape  圆角不能调 ,最大圆角显示
StadiumBorder shape3 = const StadiumBorder(
    side: BorderSide(
  style: BorderStyle.solid,
  color: Color(0xffFF7F24),
));

Color theme = const Color(0xf2f2f2ff);
