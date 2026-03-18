import 'package:flutter/material.dart';
class VendorStoreScreen extends StatelessWidget {
  final String vendorId;
  const VendorStoreScreen({super.key, required this.vendorId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Store')),
      body: Center(child: Text('Vendor ID: $vendorId')),
    );
  }
}
