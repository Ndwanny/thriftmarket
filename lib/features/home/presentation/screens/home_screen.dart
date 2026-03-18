import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/home_banner.dart';
import '../widgets/section_header.dart';
import '../widgets/vendor_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final categories = ref.watch(categoriesProvider);
    final featured = ref.watch(featuredProductsProvider);
    final bestSellers = ref.watch(bestSellersProvider);
    final newArrivals = ref.watch(newArrivalsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              titleSpacing: 16,
              title: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.storefront_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good ${_greeting()},',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.grey500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        user?.fullName.split(' ').first ?? 'Shopper',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => context.push(RouteNames.notifications),
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  onPressed: () => context.push(RouteNames.chatList),
                ),
                const SizedBox(width: 8),
              ],
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: GestureDetector(
                      onTap: () => context.push(RouteNames.search),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.grey200),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            const Icon(Icons.search,
                                color: AppColors.grey400, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              AppStrings.searchProducts,
                              style: const TextStyle(
                                color: AppColors.grey400,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hero banner
                  const HomeBanner(),
                  const SizedBox(height: 24),

                  // Categories
                  SectionHeader(
                    title: AppStrings.categories,
                    onSeeAll: () {},
                  ),
                  const SizedBox(height: 12),
                  categories.when(
                    loading: () => _buildCategorySkeletons(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (cats) => SizedBox(
                      height: 92,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: cats.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 12),
                        itemBuilder: (_, i) => CategoryChip(category: cats[i]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Featured products
                  SectionHeader(
                    title: AppStrings.topDeals,
                    onSeeAll: () {},
                  ),
                  const SizedBox(height: 12),
                  featured.when(
                    loading: () => _buildProductSkeletons(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (products) => SizedBox(
                      height: 230,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: products.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 12),
                        itemBuilder: (_, i) =>
                            ProductCard(product: products[i]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Best sellers
                  SectionHeader(
                    title: AppStrings.bestSellers,
                    onSeeAll: () {},
                  ),
                  const SizedBox(height: 12),
                  bestSellers.when(
                    loading: () => _buildProductSkeletons(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (products) => SizedBox(
                      height: 230,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: products.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 12),
                        itemBuilder: (_, i) =>
                            ProductCard(product: products[i]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // New arrivals
                  SectionHeader(
                    title: AppStrings.newArrivals,
                    onSeeAll: () {},
                  ),
                  const SizedBox(height: 12),
                  newArrivals.when(
                    loading: () => _buildProductSkeletons(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (products) => GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: products.length,
                      itemBuilder: (_, i) => ProductCard(
                        product: products[i],
                        width: double.infinity,
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  Widget _buildProductSkeletons() {
    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => _ProductCardSkeleton(),
      ),
    );
  }

  Widget _buildCategorySkeletons() {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => _CategorySkeleton(),
      ),
    );
  }
}

class _ProductCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _CategorySkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
