import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.addresses)),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          icon: const Icon(Icons.add_location_alt_outlined),
          label: const Text(AppStrings.addAddress)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _AddressCard(name: 'Home', address: '14 Cairo Road, Lusaka Central, Lusaka', phone: '+260 977 000 000', isDefault: true),
        const SizedBox(height: 12),
        _AddressCard(name: 'Office', address: '22 Independence Ave, Lusaka CBD', phone: '+260 977 000 001', isDefault: false),
      ]),
    );
  }
}
class _AddressCard extends StatelessWidget {
  final String name, address, phone; final bool isDefault;
  const _AddressCard({required this.name, required this.address, required this.phone, required this.isDefault});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: isDefault ? AppColors.primary : AppColors.grey200, width: isDefault ? 1.5 : 1),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(width: 8),
        if (isDefault) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(6)),
            child: const Text('Default', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600))),
        const Spacer(),
        Icon(Icons.edit_outlined, size: 18, color: AppColors.grey400),
      ]),
      const SizedBox(height: 6),
      Text(address, style: const TextStyle(fontSize: 13, color: AppColors.grey600)),
      const SizedBox(height: 4),
      Text(phone, style: const TextStyle(fontSize: 13, color: AppColors.grey500)),
    ]),
  );
}
