import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/router/route_names.dart';
import '../../domain/entities/cart_entity.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${AppStrings.myCart} (${cart.itemCount})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, ref),
              child: const Text(AppStrings.clearCart,
                  style: TextStyle(color: AppColors.error)),
            ),
        ],
      ),
      body: cart.isEmpty
          ? _buildEmptyCart(context)
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Grouped by vendor
                      ...cart.groupedByVendor.entries.map((entry) {
                        return _VendorGroup(
                          vendorName: entry.value.first.vendorName,
                          items: entry.value,
                        );
                      }),
                      const SizedBox(height: 12),

                      // Coupon
                      _CouponSection(cart: cart),
                      const SizedBox(height: 12),

                      // Order summary
                      _OrderSummary(cart: cart),
                    ],
                  ),
                ),

                // Checkout button
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.push(RouteNames.checkout),
                        child: Text(
                          '${AppStrings.checkout} • ${cart.total.currency}',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_bag_outlined,
                size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text(AppStrings.cartEmpty,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            AppStrings.cartEmptyDesc,
            style: const TextStyle(color: AppColors.grey500),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () => context.go(RouteNames.home),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(180, 48)),
            child: const Text('Browse Products'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cart'),
        content:
            const Text('Remove all items from your cart?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Clear',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(cartProvider.notifier).clearCart();
    }
  }
}

class _VendorGroup extends ConsumerWidget {
  final String vendorName;
  final List<CartItemEntity> items;

  const _VendorGroup({required this.vendorName, required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vendor header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                const Icon(Icons.storefront_rounded,
                    size: 16, color: AppColors.vendorBadge),
                const SizedBox(width: 6),
                Text(
                  vendorName,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Items
          ...items.map((item) => _CartItemTile(item: item)),
        ],
      ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final CartItemEntity item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: item.imageUrl!,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 70,
                    height: 70,
                    color: AppColors.grey100,
                    child: const Icon(Icons.image_outlined,
                        color: AppColors.grey300),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  item.price.currency,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                // Quantity controls
                Row(
                  children: [
                    _QtyButton(
                      icon: Icons.remove,
                      onTap: () => ref
                          .read(cartProvider.notifier)
                          .updateQuantity(item.id, item.quantity - 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                    _QtyButton(
                      icon: Icons.add,
                      onTap: item.quantity < item.maxStock
                          ? () => ref
                              .read(cartProvider.notifier)
                              .updateQuantity(item.id, item.quantity + 1)
                          : null,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => ref
                          .read(cartProvider.notifier)
                          .removeItem(item.id),
                      child: const Icon(Icons.delete_outline,
                          size: 20, color: AppColors.error),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.primaryContainer : AppColors.grey100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            size: 16,
            color: onTap != null ? AppColors.primary : AppColors.grey400),
      ),
    );
  }
}

class _CouponSection extends ConsumerStatefulWidget {
  final CartEntity cart;
  const _CouponSection({required this.cart});

  @override
  ConsumerState<_CouponSection> createState() => _CouponSectionState();
}

class _CouponSectionState extends ConsumerState<_CouponSection> {
  final _couponController = TextEditingController();
  bool _isApplying = false;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cart.couponCode != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 18),
            const SizedBox(width: 8),
            Text(
              '${widget.cart.couponCode} applied',
              style: const TextStyle(
                  color: AppColors.success, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => ref.read(cartProvider.notifier).removeCoupon(),
              child: const Icon(Icons.close, size: 16, color: AppColors.success),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _couponController,
            decoration: const InputDecoration(
              hintText: AppStrings.couponCode,
              prefixIcon: Icon(Icons.local_offer_outlined, size: 18),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _isApplying ? null : _applyCoupon,
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(80, 52)),
          child: const Text(AppStrings.apply),
        ),
      ],
    );
  }

  Future<void> _applyCoupon() async {
    if (_couponController.text.trim().isEmpty) return;
    setState(() => _isApplying = true);
    await Future.delayed(const Duration(seconds: 1));
    // Simulate coupon validation
    ref.read(cartProvider.notifier).applyCoupon(
          _couponController.text.trim().toUpperCase(),
          15.0, // K15 discount
        );
    setState(() => _isApplying = false);
  }
}

class _OrderSummary extends StatelessWidget {
  final CartEntity cart;
  const _OrderSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Summary',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 14),
          _SummaryRow(label: AppStrings.subtotal, value: cart.subtotal.currency),
          if (cart.discount > 0) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Discount',
              value: '-${cart.discount.currency}',
              valueColor: AppColors.success,
            ),
          ],
          const SizedBox(height: 8),
          _SummaryRow(
            label: AppStrings.shipping,
            value: cart.shipping == 0 ? 'Free' : cart.shipping.currency,
            valueColor: cart.shipping == 0 ? AppColors.success : null,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          _SummaryRow(
            label: AppStrings.total,
            value: cart.total.currency,
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? null : AppColors.grey600,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            fontSize: isBold ? 15 : 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? (isBold ? AppColors.primary : null),
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            fontSize: isBold ? 16 : 13,
          ),
        ),
      ],
    );
  }
}
