import 'package:flutter/material.dart';

class ShowID extends StatefulWidget {
  const ShowID({super.key, required this.width, this.vendorId, this.productId});
  final double width;
  final int? vendorId;
  final int? productId;

  @override
  State<ShowID> createState() => _ShowIDState();
}

class _ShowIDState extends State<ShowID> {
  String getVendorId() {
    return widget.productId == null ? "" : widget.vendorId.toString();
  }

  String getProductId() {
    return widget.productId == null ? "" : widget.productId.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: widget.width,
        margin: const EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Container(
                width: 90,
                margin: const EdgeInsets.only(top: 5),
                child: Text("VID: ${getVendorId()}")),
            Container(
                width: 90,
                margin: const EdgeInsets.only(top: 5),
                child: Text("PID: ${getProductId()}")),
          ],
        ));
  }
}
