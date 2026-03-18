import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../providers/product_provider.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final String productId;
  const ProductDetailsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));
    final isWishlisted = ref.watch(
        wishlistProvider.select((s) => s.contains(productId)));

    return productAsync.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
          body: Center(child: Text('Error: $e'))),
      data: (product) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isWishlisted ? AppColors.error : null,
                    ),
                    onPressed: () => ref.read(wishlistProvider.notifier).toggle(productId),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () {},
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: product.firstImage != null
                      ? CachedNetworkImage(
                          imageUrl: product.firstImage!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: AppColors.grey100,
                          child: const Icon(Icons.image_outlined,
                              size: 80, color: AppColors.grey300),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.categoryName,
                          style: const TextStyle(
                              color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Title
                      Text(product.title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      // Rating
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: product.rating,
                            itemBuilder: (_, __) =>
                                const Icon(Icons.star_rounded, color: AppColors.starFilled),
                            itemCount: 5,
                            itemSize: 18,
                          ),
                          const SizedBox(width: 6),
                          Text('${product.rating.toStringAsFixed(1)} (${product.reviewCount} reviews)',
                              style: const TextStyle(color: AppColors.grey500, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Price
                      Row(
                        children: [
                          Text(
                            product.price.currency,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                          if (product.compareAtPrice != null) ...[
                            const SizedBox(width: 10),
                            Text(
                              product.compareAtPrice!.currency,
                              style: const TextStyle(
                                  fontSize: 15, color: AppColors.grey400,
                                  decoration: TextDecoration.lineThrough),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.errorLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '-${product.discountPercentage}%',
                                style: const TextStyle(
                                    color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Stock status
                      Row(
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              color: product.isInStock ? AppColors.success : AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            product.isInStock
                                ? '${product.stock} in stock'
                                : AppStrings.outOfStock,
                            style: TextStyle(
                              color: product.isInStock ? AppColors.success : AppColors.error,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 28),
                      // Vendor
                      GestureDetector(
                        onTap: () => context.push('${RouteNames.vendorStore}/${product.vendorId}'),
                        child: Row(
                          children: [
                            const Icon(Icons.storefront_rounded, size: 18, color: AppColors.grey600),
                            const SizedBox(width: 8),
                            Text(AppStrings.soldBy,
                                style: const TextStyle(color: AppColors.grey500, fontSize: 13)),
                            const SizedBox(width: 4),
                            Text(product.vendorName,
                                style: const TextStyle(
                                    color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                            const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primary),
                          ],
                        ),
                      ),
                      const Divider(height: 28),
                      // Description
                      Text('Description', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Text(product.description,
                          style: const TextStyle(color: AppColors.grey600, height: 1.7, fontSize: 14)),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: product.isInStock ? () {
                        ref.read(cartProvider.notifier).addItem(
                          CartItemEntity(
                            id: '${product.id}_${DateTime.now().millisecondsSinceEpoch}',
                            productId: product.id,
                            title: product.title,
                            imageUrl: product.firstImage,
                            price: product.price,
                            compareAtPrice: product.compareAtPrice,
                            quantity: 1,
                            vendorId: product.vendorId,
                            vendorName: product.vendorName,
                            maxStock: product.stock,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to cart!')),
                        );
                      } : null,
                      child: const Text(AppStrings.addToCart),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: product.isInStock ? () {} : null,
                      child: const Text(AppStrings.buyNow),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
