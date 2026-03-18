import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/router/route_names.dart';
import '../providers/cart_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});
  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _step = 0;
  String _paymentMethod = 'card';
  bool _isPlacing = false;

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.checkout),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => _step == 0 ? context.pop() : setState(() => _step--)),
      ),
      body: Column(children: [
        LinearProgressIndicator(value: (_step+1)/3, backgroundColor: AppColors.grey200,
            color: AppColors.primary, minHeight: 3),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _step == 0 ? _buildAddress() : _step == 1 ? _buildPayment() : _buildReview(cart),
        )),
        SafeArea(child: Padding(
          padding: const EdgeInsets.fromLTRB(16,8,16,16),
          child: SizedBox(width: double.infinity,
            child: ElevatedButton(
              onPressed: _isPlacing ? null : _next,
              child: _isPlacing
                  ? const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white))
                  : Text(_step == 2 ? 'Place Order • ${cart.total.currency}' : 'Continue'),
            ),
          ),
        )),
      ]),
    );
  }

  Widget _buildAddress() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Delivery Address', style: Theme.of(context).textTheme.titleSmall),
    const SizedBox(height: 12),
    _AddressTile(isSelected: true, name: 'John Banda', address: '14 Cairo Road, Lusaka Central, Lusaka', phone: '+260 977 000 000'),
    const SizedBox(height: 10),
    OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add_location_outlined),
        label: const Text('Add New Address'), style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48))),
  ]);

  Widget _buildPayment() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Payment Method', style: Theme.of(context).textTheme.titleSmall),
    const SizedBox(height: 12),
    ...[
      ('card', Icons.credit_card_outlined, 'Credit / Debit Card'),
      ('momo_mtn', Icons.phone_android_outlined, 'MTN Mobile Money'),
      ('momo_airtel', Icons.phone_android_outlined, 'Airtel Money'),
      ('wallet', Icons.account_balance_wallet_outlined, 'Marketplace Wallet (K240)'),
    ].map((p) => _PaymentOption(value: p.$1, icon: p.$2, label: p.$3,
        selected: _paymentMethod, onSelect: (v) => setState(() => _paymentMethod = v))),
  ]);

  Widget _buildReview(cart) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Order Review', style: Theme.of(context).textTheme.titleSmall),
    const SizedBox(height: 12),
    ...cart.items.map((item) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(
            color: AppColors.grey100, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.image_outlined, color: AppColors.grey300, size: 20)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          Text('Qty: ${item.quantity}', style: const TextStyle(fontSize: 11, color: AppColors.grey500)),
        ])),
        Text(item.subtotal.currency, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ]),
    )),
    const Divider(height: 24),
    _Row('Subtotal', cart.subtotal.currency),
    const SizedBox(height: 6), _Row('Shipping', cart.shipping == 0 ? 'Free' : cart.shipping.currency),
    if (cart.discount > 0) ...[const SizedBox(height: 6), _Row('Discount', '-${cart.discount.currency}', color: AppColors.success)],
    const Divider(height: 16),
    _Row('Total', cart.total.currency, bold: true, color: AppColors.primary),
  ]);

  Widget _Row(String l, String v, {bool bold=false, Color? color}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(l, style: TextStyle(fontSize: bold?15:13, color: bold ? null : AppColors.grey600, fontWeight: bold ? FontWeight.w700 : null)),
      Text(v, style: TextStyle(fontSize: bold?16:13, color: color, fontWeight: bold ? FontWeight.w700 : FontWeight.w600)),
    ],
  );

  Future<void> _next() async {
    if (_step < 2) { setState(() => _step++); return; }
    setState(() => _isPlacing = true);
    await Future.delayed(const Duration(seconds: 2));
    ref.read(cartProvider.notifier).clearCart();
    setState(() => _isPlacing = false);
    if (mounted) {
      showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
        title: const Text('Order Placed!'),
        content: const Text('Your order has been placed successfully. You will receive a confirmation shortly.'),
        actions: [ElevatedButton(onPressed: () { Navigator.pop(context); context.go(RouteNames.orders); }, child: const Text('View Orders'))],
      ));
    }
  }
}

class _AddressTile extends StatelessWidget {
  final bool isSelected; final String name, address, phone;
  const _AddressTile({required this.isSelected, required this.name, required this.address, required this.phone});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: isSelected ? AppColors.primary : AppColors.grey200, width: isSelected ? 1.5 : 1),
      color: isSelected ? AppColors.primaryContainer : Theme.of(context).cardColor,
    ),
    child: Row(children: [
      Icon(Icons.location_on_rounded, color: isSelected ? AppColors.primary : AppColors.grey400, size: 20),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        Text(address, style: const TextStyle(fontSize: 12, color: AppColors.grey600)),
        Text(phone, style: const TextStyle(fontSize: 12, color: AppColors.grey500)),
      ])),
      if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
    ]),
  );
}

class _PaymentOption extends StatelessWidget {
  final String value, label, selected; final IconData icon; final ValueChanged<String> onSelect;
  const _PaymentOption({required this.value, required this.icon, required this.label, required this.selected, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    final sel = value == selected;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: sel ? AppColors.primary : AppColors.grey200, width: sel ? 1.5 : 1),
          color: sel ? AppColors.primaryContainer : Theme.of(context).cardColor,
        ),
        child: Row(children: [
          Icon(icon, color: sel ? AppColors.primary : AppColors.grey500, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontWeight: sel ? FontWeight.w600 : FontWeight.w400, fontSize: 14))),
          if (sel) const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
        ]),
      ),
    );
  }
}
