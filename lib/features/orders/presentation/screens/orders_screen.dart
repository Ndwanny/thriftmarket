import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';

// Stub order state - in production would be a full provider
class _StubOrder {
  final String id, title, vendorName, statusLabel, date, total;
  final Color statusColor;
  const _StubOrder({required this.id, required this.title, required this.vendorName,
    required this.statusLabel, required this.statusColor, required this.date, required this.total});
}

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = [
      _StubOrder(id:'ORD-001', title:'Samsung Galaxy A14 + 2 items', vendorName:'TechHub ZM',
          statusLabel:'Delivered', statusColor: AppColors.success, date:'Mar 10, 2026', total:'K2,450'),
      _StubOrder(id:'ORD-002', title:'Nike Air Force 1', vendorName:'SneakerWorld',
          statusLabel:'Shipped', statusColor: AppColors.info, date:'Mar 14, 2026', total:'K890'),
      _StubOrder(id:'ORD-003', title:'Grocery Bundle x6', vendorName:'FreshMart',
          statusLabel:'Processing', statusColor: AppColors.warning, date:'Mar 16, 2026', total:'K345'),
    ];

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.myOrders, style: Theme.of(context).textTheme.titleMedium),
          bottom: const TabBar(tabs: [
            Tab(text: 'All'), Tab(text: 'Active'), Tab(text: 'Completed'), Tab(text: 'Cancelled'),
          ]),
        ),
        body: TabBarView(children: [
          _OrderList(orders: orders),
          _OrderList(orders: orders.where((o) => o.statusLabel != 'Delivered').toList()),
          _OrderList(orders: orders.where((o) => o.statusLabel == 'Delivered').toList()),
          _OrderList(orders: const []),
        ]),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<_StubOrder> orders;
  const _OrderList({required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.grey300),
        const SizedBox(height: 16),
        Text(AppStrings.noOrders, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const Text(AppStrings.noOrdersDesc, style: TextStyle(color: AppColors.grey500)),
      ]));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _OrderCard(order: orders[i]),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final _StubOrder order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('${RouteNames.orderDetails}/${order.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(order.id, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: order.statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(order.statusLabel,
                  style: TextStyle(color: order.statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(order.title, style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.storefront_outlined, size: 13, color: AppColors.grey400),
            const SizedBox(width: 4),
            Text(order.vendorName, style: const TextStyle(fontSize: 12, color: AppColors.grey500)),
          ]),
          const Divider(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(order.date, style: const TextStyle(fontSize: 12, color: AppColors.grey500)),
            Text(order.total, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 14)),
          ]),
        ]),
      ),
    );
  }
}
