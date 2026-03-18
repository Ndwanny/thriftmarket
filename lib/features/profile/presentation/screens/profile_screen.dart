import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.profile, style: Theme.of(context).textTheme.titleMedium),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.push(RouteNames.settings)),
        ],
      ),
      body: ListView(
        children: [
          Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primaryContainer,
                  backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                  child: user?.avatarUrl == null
                      ? Text(user?.fullName.initials ?? '?',
                          style: const TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w700))
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(user?.fullName ?? 'Guest', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(user?.email ?? '', style: const TextStyle(color: AppColors.grey500, fontSize: 13)),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => context.push(RouteNames.editProfile),
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      child: const Text('Edit Profile', style: TextStyle(fontSize: 12)),
                    ),
                  ]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(children: [
              _StatItem(label: 'Orders', value: '12'),
              _StatItem(label: 'Wishlist', value: '8'),
              _StatItem(label: 'Reviews', value: '5'),
              _StatItem(label: 'Wallet', value: 'K240'),
            ]),
          ),
          const SizedBox(height: 8),
          _Section(title: 'Shopping', items: [
            _MenuItem(icon: Icons.receipt_long_outlined, label: AppStrings.myOrders,
                onTap: () => context.go(RouteNames.orders)),
            _MenuItem(icon: Icons.favorite_border_rounded, label: AppStrings.wishlist,
                onTap: () => context.push(RouteNames.wishlist)),
            _MenuItem(icon: Icons.location_on_outlined, label: AppStrings.addresses,
                onTap: () => context.push(RouteNames.addresses)),
            _MenuItem(icon: Icons.account_balance_wallet_outlined, label: AppStrings.wallet,
                onTap: () {}),
          ]),
          const SizedBox(height: 8),
          if (user?.isVendor == true)
            _Section(title: 'Vendor', items: [
              _MenuItem(icon: Icons.dashboard_outlined, label: AppStrings.vendorDashboard,
                  onTap: () => context.push(RouteNames.vendorDashboard)),
            ])
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: OutlinedButton.icon(
                onPressed: () => context.push(RouteNames.vendorRegistration),
                icon: const Icon(Icons.storefront_outlined),
                label: const Text(AppStrings.becomeVendor),
              ),
            ),
          const SizedBox(height: 8),
          _Section(title: 'Support', items: [
            _MenuItem(icon: Icons.headset_mic_outlined, label: AppStrings.helpCenter, onTap: () {}),
            _MenuItem(icon: Icons.info_outline, label: AppStrings.about, onTap: () {}),
          ]),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () => _confirmLogout(context, ref),
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
              icon: const Icon(Icons.logout_rounded),
              label: const Text(AppStrings.logout),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Logout', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authStateProvider.notifier).logout();
      if (context.mounted) context.go(RouteNames.login);
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label; final String value;
  const _StatItem({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
    const SizedBox(height: 2),
    Text(label, style: const TextStyle(fontSize: 11, color: AppColors.grey500)),
  ]));
}

class _Section extends StatelessWidget {
  final String title; final List<Widget> items;
  const _Section({required this.title, required this.items});
  @override
  Widget build(BuildContext context) => Container(
    color: Theme.of(context).cardColor,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.grey500))),
      ...items,
    ]),
  );
}

class _MenuItem extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, size: 22, color: AppColors.grey700),
    title: Text(label, style: const TextStyle(fontSize: 14)),
    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.grey400),
    onTap: onTap, dense: true,
  );
}
