import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../providers/vendor_provider.dart';

class VendorStoreScreen extends ConsumerWidget {
  final String vendorId;
  const VendorStoreScreen({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorAsync = ref.watch(vendorDetailProvider(vendorId));
    final productsAsync = ref.watch(vendorProductsProvider(vendorId));
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

    return Scaffold(
      backgroundColor: AppColors.white,
      body: vendorAsync.when(
        loading: () => const Center(
          child:
              CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.grey400, size: 48),
              const SizedBox(height: 12),
              Text('Failed to load store',
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.grey600,
                      fontSize: 14)),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: () => ref.invalidate(vendorDetailProvider(vendorId)),
                  child: const Text('RETRY')),
            ],
          ),
        ),
        data: (vendor) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Banner + back button
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                stretch: true,
                backgroundColor: AppColors.black,
                elevation: 0,
                leading: IconButton(
                  icon: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Icon(Icons.arrow_back_ios_rounded,
                        color: AppColors.white, size: 16),
                  ),
                  onPressed: () => context.pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: vendor.bannerUrl != null
                      ? CachedNetworkImage(
                          imageUrl: vendor.bannerUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              Container(color: AppColors.grey900),
                        )
                      : Container(color: AppColors.grey900),
                ),
              ),

              // Store profile section
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.black,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo + verified badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _LogoAvatar(
                              logoUrl: vendor.logoUrl,
                              name: vendor.storeName),
                          const SizedBox(width: 12),
                          if (vendor.isVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              color: AppColors.primary,
                              child: const Text(
                                'VERIFIED VENDOR',
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Store name
                      Text(
                        vendor.storeName,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (vendor.storeDescription != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          vendor.storeDescription!,
                          style: const TextStyle(
                            color: AppColors.grey400,
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            height: 1.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Stats row
                      Row(
                        children: [
                          _StatBadge(
                            label: 'RATING',
                            value: vendor.rating.toStringAsFixed(1),
                            icon: Icons.star_rounded,
                          ),
                          const SizedBox(width: 8),
                          _StatBadge(
                            label: 'REVIEWS',
                            value: '${vendor.reviewCount}',
                            icon: Icons.chat_bubble_outline_rounded,
                          ),
                          const SizedBox(width: 8),
                          _StatBadge(
                            label: 'SALES',
                            value: '${vendor.totalSales}',
                            icon: Icons.local_shipping_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Products section label
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Container(width: 4, height: 20, color: AppColors.primary),
                      const SizedBox(width: 10),
                      const Text(
                        'PRODUCTS',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Products grid
              productsAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth: 2),
                    ),
                  ),
                ),
                error: (_, __) => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                        child: Text('Could not load products',
                            style: TextStyle(color: AppColors.grey500))),
                  ),
                ),
                data: (products) {
                  if (products.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.inventory_2_outlined,
                                  size: 48, color: AppColors.grey300),
                              SizedBox(height: 12),
                              Text('No products listed yet',
                                  style: TextStyle(
                                      color: AppColors.grey500,
                                      fontFamily: 'Poppins',
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    sliver: SliverGrid(
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.72,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => ProductCard(
                                product: products[i], width: double.infinity)
                            .animate(
                                delay: Duration(
                                    milliseconds: 50 * (i % 6)))
                            .fadeIn(duration: 400.ms)
                            .slideY(
                                begin: 0.06,
                                end: 0,
                                curve: Curves.easeOutCubic),
                        childCount: products.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LogoAvatar extends StatelessWidget {
  final String? logoUrl;
  final String name;
  const _LogoAvatar({required this.logoUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 3),
        color: AppColors.grey900,
      ),
      clipBehavior: Clip.hardEdge,
      child: logoUrl != null
          ? CachedNetworkImage(
              imageUrl: logoUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => _Initial(name: name),
            )
          : _Initial(name: name),
    );
  }
}

class _Initial extends StatelessWidget {
  final String name;
  const _Initial({required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'V',
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w900,
          fontSize: 28,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatBadge(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey800),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.grey500,
                  fontSize: 8,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
