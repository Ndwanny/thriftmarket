import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/extensions/extensions.dart';

class VendorDashboardScreen extends ConsumerWidget {
  const VendorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Dashboard', style: Theme.of(context).textTheme.titleMedium),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stats grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: const [
              _StatCard(label: 'Total Sales', value: '124', icon: Icons.shopping_bag_outlined, color: AppColors.primary),
              _StatCard(label: 'Revenue', value: 'K18,450', icon: Icons.account_balance_wallet_outlined, color: AppColors.success),
              _StatCard(label: 'Products', value: '36', icon: Icons.inventory_2_outlined, color: AppColors.secondary),
              _StatCard(label: 'Pending', value: 'K2,100', icon: Icons.pending_outlined, color: AppColors.warning),
            ],
          ),
          const SizedBox(height: 20),

          // Quick actions
          Text('Quick Actions', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _ActionButton(icon: Icons.add_box_outlined, label: 'Add Product',
                color: AppColors.primary, onTap: () => context.push(RouteNames.addProduct))),
            const SizedBox(width: 10),
            Expanded(child: _ActionButton(icon: Icons.receipt_outlined, label: 'Orders',
                color: AppColors.secondary, onTap: () {})),
            const SizedBox(width: 10),
            Expanded(child: _ActionButton(icon: Icons.bar_chart_rounded, label: 'Analytics',
                color: AppColors.success, onTap: () {})),
            const SizedBox(width: 10),
            Expanded(child: _ActionButton(icon: Icons.local_offer_outlined, label: 'Coupons',
                color: AppColors.warning, onTap: () {})),
          ]),
          const SizedBox(height: 20),

          // Recent orders
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Recent Orders', style: Theme.of(context).textTheme.titleSmall),
            TextButton(onPressed: () {}, child: const Text('See All', style: TextStyle(fontSize: 12))),
          ]),
          const SizedBox(height: 8),
          ...List.generate(4, (i) => _OrderRow(
            orderId: 'ORD-00${i + 1}',
            customer: ['John Banda', 'Mary Tembo', 'Peter Lungu', 'Grace Mwale'][i],
            amount: ['K450', 'K1,200', 'K89', 'K2,340'][i],
            status: ['Pending', 'Shipped', 'Delivered', 'Processing'][i],
            statusColor: [AppColors.warning, AppColors.info, AppColors.success, AppColors.secondary][i],
          )),
          const SizedBox(height: 20),

          // Top products
          Text('Top Products', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...List.generate(3, (i) => _ProductRow(
            name: ['Wireless Earbuds Pro', 'Phone Case Bundle', 'USB-C Charger'][i],
            sold: [42, 38, 29][i],
            revenue: ['K8,400', 'K3,800', 'K2,175'][i],
          )),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(width: 36, height: 36,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18)),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.grey500)),
        ]),
      ]),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final String orderId, customer, amount, status; final Color statusColor;
  const _OrderRow({required this.orderId, required this.customer, required this.amount, required this.status, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(orderId, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          Text(customer, style: const TextStyle(fontSize: 11, color: AppColors.grey500)),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600))),
        const SizedBox(width: 12),
        Text(amount, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      ]),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final String name, revenue; final int sold;
  const _ProductRow({required this.name, required this.sold, required this.revenue});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(children: [
        Container(width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.grey100, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.grey400)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('$sold sold', style: const TextStyle(fontSize: 11, color: AppColors.grey500)),
        ])),
        Text(revenue, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.success)),
      ]),
    );
  }
}
