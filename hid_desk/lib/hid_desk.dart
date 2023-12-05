library hid_desk;



// 如果需要使用import导入其它的库，则该指令只能放在主库文件中，不能放在分库文件中。
// 主库文件中导入的外部库，分库不用重复导入即可直接引用。
// import只能放在 library 和 part指令行之间。
import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
// import 'hid_platform_interface.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'hidapi_bindings_generated.dart';

// 关联分库，可以看作是一个整体
part 'device.dart';

//以'_'开头的成员，仅在库内可见
final _api = HidBindings(Platform.isMacOS
? DynamicLibrary.executable()
: DynamicLibrary.open("hidapi.dll")
);

class HidPluginMacOS //extends HidPlatform
{
  // static void registerWith() {
  //   // HidPlatform.instance =HidPluginMacOS();
  // }

  int init() {
    return _api.hid_init();
  }

  Future<List<Device>> getDeviceList() async {
    List<Device> devices = [];
    final pointer = _api.hid_enumerate(0, 0);
    var current = pointer;
    while (current.address != nullptr.address) {
      final ref = current.ref;
      devices.add(UsbDevice(
        vendorId: ref.vendor_id,
        productId: ref.product_id,
        serialNumber: "",
        productName: "",
        usagePage: ref.usage_page,
        usage: ref.usage,
      ));
      current = ref.next;
    }
    _api.hid_free_enumeration(pointer);
    return devices;
  }
}

class UsbDevice extends Device {
  Pointer<hid_device>? _raw;
  bool isOpen = false;
  UsbDevice({
    required int vendorId,
    required int productId,
    required String serialNumber,
    required String productName,
    required int usagePage,
    required int usage,
  }) : super(
            vendorId: vendorId,
            productId: productId,
            serialNumber: serialNumber,
            productName: productName,
            usagePage: usagePage,
            usage: usage);

  @override
  Future<bool> open() async {
    final pointer = _api.hid_open(vendorId, productId, nullptr);

    if (pointer.address == nullptr.address) {
      print("=========${pointer}");
      print("====${_api.hid_error(pointer).toDartString()}");
      return false;
    }

    final result = _api.hid_set_nonblocking(pointer, 1);
    if (result == -1) return false;
    _raw = pointer;
    isOpen = true;
    openController.sink.add(isOpen);
    return true;
  }

  @override
  Future<void> close() async {
    isOpen = false;
    openController.sink.add(isOpen);
    final raw = _raw;
    if (raw != null) {
      _api.hid_close(raw);
    }
  }

  @override
  Stream<List<int>> read(int length, int duration) async* {
    final raw = _raw;
    if (raw == null) return;
    final pointer = calloc<UnsignedChar>(length);
    var count = 0;
    while (isOpen) {
      count = _api.hid_read(raw, pointer, length);
      if (count == 0) {
        print("没数据 $count");
        print("没数据 ${_api.hid_error(raw).toDartString()} ");

        await Future.delayed(Duration(seconds: duration));
        continue;
      } else if (count == -1) {
        close();
        break;
      }
      yield getList(count, pointer);
      await Future.delayed(Duration(seconds: duration));
    }
    print("终止读进程 $isOpen");
    calloc.free(pointer);
  }

  List<int> getList(int len, Pointer<UnsignedChar> pointer) {
    List<int> list = [];
    for (int i = 0; i < len; i++) {
      list.add(pointer.elementAt(i).value);
    }
    return list;
  }

  void setList(List<int> data, Pointer<UnsignedChar> pointer) {
    for (int i = 0; i < data.length; i++) {
      pointer.elementAt(i).value = data[i];
    }
  }

  @override
  Future<void> write(List<int> bytes) async {
    final raw = _raw;
    if (raw == null) throw Exception();
    final buf = calloc<UnsignedChar>(bytes.length);
    setList(bytes, buf);
    var offset = 0;
    while (isOpen && bytes.length - offset > 0) {
      final count =
          _api.hid_write(raw, buf.elementAt(offset), bytes.length - offset);
      if (count == -1) {
        print("写入失败 ${_api.hid_error(raw).toDartString()} ");
        close();
        break;
      } else {
        offset += count;
        print("写入成功$offset ${_api.hid_error(raw).toDartString()} ");
      }
    }
    calloc.free(buf);
  }

  @override
  bool getOpen() {
    return isOpen;
  }
}

extension PointerToString on Pointer<WChar> {
  String toDartString() {
    final buffer = StringBuffer();
    var i = 0;
    while (true) {
      final char = elementAt(i).value;
      if (char == 0) {
        return buffer.toString();
      }
      buffer.writeCharCode(char);
      i++;
    }
  }
}

extension StringToPointer on String {
  Pointer<Int32> toPointer({Allocator allocator = malloc}) {
    final units = codeUnits;
    final Pointer<Int32> result = allocator<Int32>(units.length + 1);
    final Int32List nativeString = result.asTypedList(units.length + 1);
    nativeString.setRange(0, units.length, units);
    nativeString[units.length] = 0;
    return result.cast();
  }
}


 