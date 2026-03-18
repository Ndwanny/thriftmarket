import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NData(icon: Icons.local_shipping_rounded, color: AppColors.info,
          title: 'Your order shipped!', body: 'ORD-002 is on its way.', time: '2h ago', unread: true),
      _NData(icon: Icons.local_offer_rounded, color: AppColors.secondary,
          title: 'Flash Sale - 50% Off!', body: 'Limited time deal on electronics.', time: '5h ago', unread: true),
      _NData(icon: Icons.check_circle_rounded, color: AppColors.success,
          title: 'Order Delivered', body: 'ORD-001 has been delivered.', time: 'Yesterday', unread: false),
      _NData(icon: Icons.star_rounded, color: AppColors.starFilled,
          title: 'Rate your purchase', body: 'How was Samsung Galaxy A14?', time: 'Yesterday', unread: false),
      _NData(icon: Icons.storefront_rounded, color: AppColors.primary,
          title: 'New vendor joined', body: 'TechWorld ZM is now on Marketplace.', time: '3 days ago', unread: false),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.allNotifications, style: Theme.of(context).textTheme.titleMedium),
        actions: [TextButton(onPressed: () {}, child: const Text(AppStrings.markAllRead, style: TextStyle(fontSize: 12)))],
      ),
      body: items.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.notifications_none_rounded, size: 64, color: AppColors.grey300),
              const SizedBox(height: 16),
              Text(AppStrings.noNotifications, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const Text(AppStrings.noNotificationsDesc, style: TextStyle(color: AppColors.grey500)),
            ]))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _NotifTile(data: items[i]),
            ),
    );
  }
}

class _NData { final IconData icon; final Color color; final String title, body, time; final bool unread;
  const _NData({required this.icon, required this.color, required this.title, required this.body, required this.time, required this.unread});
}

class _NotifTile extends StatelessWidget {
  final _NData data;
  const _NotifTile({required this.data});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: data.unread ? data.color.withOpacity(0.05) : Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: data.unread ? data.color.withOpacity(0.2) : AppColors.grey200),
    ),
    child: Row(children: [
      Container(width: 44, height: 44,
          decoration: BoxDecoration(color: data.color.withOpacity(0.12), shape: BoxShape.circle),
          child: Icon(data.icon, color: data.color, size: 22)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(data.title, style: TextStyle(fontWeight: data.unread ? FontWeight.w600 : FontWeight.w500, fontSize: 13)),
        const SizedBox(height: 2),
        Text(data.body, style: const TextStyle(fontSize: 12, color: AppColors.grey600), maxLines: 2, overflow: TextOverflow.ellipsis),
      ])),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(data.time, style: const TextStyle(fontSize: 10, color: AppColors.grey400)),
        if (data.unread) ...[const SizedBox(height: 6),
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle))],
      ]),
    ]),
  );
}
