part of hid_desk;

abstract class Device {
  int vendorId;
  int productId;
  String serialNumber;
  String productName;
  int? usagePage;
  int? usage;
  StreamController openController = StreamController.broadcast();

  Device(
      {required this.vendorId,
      required this.productId,
      required this.serialNumber,
      required this.productName,
      this.usagePage,
      this.usage});

  Future<bool> open() {
    throw UnimplementedError();
  }
  
  bool getOpen() {
    throw UnimplementedError();
  }

  Future<void> close() {
    throw UnimplementedError();
  }

  Stream<List<int>> read(int length, int duration) {
    throw UnimplementedError();
  }

  Future<void> write(List<int> bytes) {
    throw UnimplementedError();
  }
}
