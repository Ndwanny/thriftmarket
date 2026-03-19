import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/home_banner.dart';
import '../widgets/section_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final featured = ref.watch(featuredProductsProvider);
    final newArrivals = ref.watch(newArrivalsProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount;
    if (screenWidth >= 1200) {
      crossAxisCount = 4;
    } else if (screenWidth >= 900) {
      crossAxisCount = 3;
    } else if (screenWidth >= 600) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }

    double maxContentWidth = screenWidth >= 1400 ? 1400 : double.infinity;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: CustomScrollView(
              slivers: [
                // Sticky header
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  backgroundColor: AppColors.black,
                  elevation: 0,
                  toolbarHeight: 60,
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        color: AppColors.primary,
                        child: const Text(
                          'TM',
                          style: TextStyle(
                            color: AppColors.black,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'THRIFT MARKET LKS',
                        style: TextStyle(
                          color: AppColors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search, color: AppColors.white),
                      onPressed: () => context.push(RouteNames.search),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: AppColors.white),
                      onPressed: () => context.push(RouteNames.notifications),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),

                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero banner — full width
                      const HomeBanner(),

                      // Categories
                      const SizedBox(height: 24),
                      _SectionLabel(label: 'CATEGORIES'),
                      const SizedBox(height: 12),
                      categories.when(
                        loading: () => _CategorySkeletons(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (cats) => SizedBox(
                          height: 40,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: cats.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (_, i) => _CategoryPill(
                              name: cats[i].name,
                              onTap: () => context.push('${RouteNames.products}/${cats[i].id}'),
                            ),
                          ),
                        ),
                      ),

                      // Featured — horizontal scroll on mobile, grid on desktop
                      const SizedBox(height: 28),
                      _SectionLabel(label: 'FEATURED DROPS'),
                      const SizedBox(height: 12),
                      featured.when(
                        loading: () => _ProductRowSkeleton(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (products) => screenWidth < 600
                            ? SizedBox(
                                height: 240,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: products.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                                  itemBuilder: (_, i) => SizedBox(
                                    width: 160,
                                    child: ProductCard(product: products[i]),
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 0.72,
                                  ),
                                  itemCount: products.length > 8 ? 8 : products.length,
                                  itemBuilder: (_, i) => ProductCard(product: products[i], width: double.infinity),
                                ),
                              ),
                      ),

                      // New arrivals — full grid
                      const SizedBox(height: 32),
                      _SectionLabel(label: 'NEW ARRIVALS'),
                      const SizedBox(height: 12),
                      newArrivals.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (products) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.72,
                            ),
                            itemCount: products.length,
                            itemBuilder: (_, i) => ProductCard(product: products[i], width: double.infinity),
                          ),
                        ),
                      ),

                      // Bottom promo strip
                      const SizedBox(height: 40),
                      Container(
                        width: double.infinity,
                        color: AppColors.black,
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            const Text(
                              'THRIFT MARKET LUSAKA',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Streetwear · Vintage · Culture · Lusaka',
                              style: TextStyle(
                                color: AppColors.grey400,
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                letterSpacing: 2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: 200,
                              child: ElevatedButton(
                                onPressed: () => context.push(RouteNames.search),
                                child: const Text('EXPLORE ALL'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(width: 4, height: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  const _CategoryPill({required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          name.toUpperCase(),
          style: const TextStyle(
            color: AppColors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _CategorySkeletons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, __) => Container(
          width: 90,
          height: 40,
          color: AppColors.grey100,
        ),
      ),
    );
  }
}

class _ProductRowSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, __) => Container(
          width: 160,
          color: AppColors.grey100,
        ),
      ),
    );
  }
}
