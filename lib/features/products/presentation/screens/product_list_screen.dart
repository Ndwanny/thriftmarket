import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends ConsumerWidget {
  final String categoryId;
  final String categoryName;

  const ProductListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(
        filteredProductsProvider(ProductFilterParams(categoryId: categoryId)));
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount;
    if (screenWidth >= 900) {
      crossAxisCount = 4;
    } else if (screenWidth >= 600) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: AppColors.white, size: 20),
              onPressed: () => context.pop(),
            ),
            title: Text(
              categoryName.toUpperCase(),
              style: const TextStyle(
                color: AppColors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1,
              ),
            ),
          ),
          products.when(
            loading: () => SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, __) => Shimmer.fromColors(
                    baseColor: AppColors.grey200,
                    highlightColor: AppColors.grey100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.grey200,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(2)),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                            color: AppColors.white,
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    height: 10,
                                    width: double.infinity,
                                    color: AppColors.grey200),
                                const SizedBox(height: 6),
                                Container(
                                    height: 10,
                                    width: 80,
                                    color: AppColors.grey200),
                                const SizedBox(height: 8),
                                Container(
                                    height: 12,
                                    width: 60,
                                    color: AppColors.grey200),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  childCount: 6,
                ),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: AppColors.grey400),
                      const SizedBox(height: 12),
                      Text(
                        'Could not load products',
                        style: const TextStyle(
                          color: AppColors.grey600,
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(
                            filteredProductsProvider(
                                ProductFilterParams(categoryId: categoryId))),
                        child: const Text('RETRY'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            data: (list) {
              if (list.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 48, color: AppColors.grey300),
                        SizedBox(height: 12),
                        Text(
                          'No products in this category',
                          style: TextStyle(
                            color: AppColors.grey500,
                            fontFamily: 'Poppins',
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => ProductCard(
                            product: list[i], width: double.infinity)
                        .animate(
                            delay:
                                Duration(milliseconds: 50 * (i % 6)))
                        .fadeIn(duration: 400.ms)
                        .slideY(
                            begin: 0.06,
                            end: 0,
                            curve: Curves.easeOutCubic),
                    childCount: list.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}
