import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';
import '../router/route_names.dart';

final currentTabIndexProvider = StateProvider<int>((ref) => 0);

class MainScaffold extends ConsumerWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home', route: RouteNames.home),
    _NavItem(icon: Icons.search_outlined, activeIcon: Icons.search_rounded, label: 'Search', route: RouteNames.search),
    _NavItem(icon: Icons.shopping_bag_outlined, activeIcon: Icons.shopping_bag_rounded, label: 'Cart', route: RouteNames.cart),
    _NavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long_rounded, label: 'Orders', route: RouteNames.orders),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile', route: RouteNames.profile),
  ];

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < _items.length; i++) {
      if (location.startsWith(_items[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _getCurrentIndex(context);
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 600;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            // Side navigation
            Container(
              color: AppColors.black,
              child: SafeArea(
                child: NavigationRail(
                  backgroundColor: AppColors.black,
                  selectedIndex: currentIndex,
                  extended: width >= 1100,
                  labelType: width >= 1100 ? NavigationRailLabelType.none : NavigationRailLabelType.all,
                  minWidth: 72,
                  minExtendedWidth: 200,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: width >= 1100
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  color: AppColors.primary,
                                  child: const Center(
                                    child: Text('TM', style: TextStyle(color: AppColors.black, fontFamily: 'Poppins', fontWeight: FontWeight.w900, fontSize: 14)),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text('THRIFT\nMARKET\nLKS', style: TextStyle(color: AppColors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: -0.5, height: 1.1)),
                              ],
                            ),
                          )
                        : Container(
                            width: 36,
                            height: 36,
                            color: AppColors.primary,
                            child: const Center(
                              child: Text('TM', style: TextStyle(color: AppColors.black, fontFamily: 'Poppins', fontWeight: FontWeight.w900, fontSize: 14)),
                            ),
                          ),
                  ),
                  selectedIconTheme: const IconThemeData(color: AppColors.black, size: 24),
                  unselectedIconTheme: const IconThemeData(color: AppColors.grey600, size: 24),
                  selectedLabelTextStyle: const TextStyle(color: AppColors.primary, fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 11),
                  unselectedLabelTextStyle: const TextStyle(color: AppColors.grey600, fontFamily: 'Poppins', fontWeight: FontWeight.w400, fontSize: 11),
                  indicatorColor: AppColors.primary,
                  indicatorShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                  onDestinationSelected: (i) => context.go(_items[i].route),
                  destinations: _items.map((item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.activeIcon),
                    label: Text(item.label),
                  )).toList(),
                ),
              ),
            ),
            // Vertical divider
            const VerticalDivider(width: 1, thickness: 1, color: AppColors.grey200),
            // Main content
            Expanded(child: child),
          ],
        ),
      );
    }

    // Mobile: bottom nav
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.black,
          border: Border(top: BorderSide(color: AppColors.grey800, width: 1)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                final isActive = index == currentIndex;
                return Expanded(
                  child: InkWell(
                    onTap: () => context.go(item.route),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isActive ? item.activeIcon : item.icon,
                          size: 22,
                          color: isActive ? AppColors.primary : AppColors.grey600,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                            color: isActive ? AppColors.primary : AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.route});
}
