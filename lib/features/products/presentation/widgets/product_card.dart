import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/router/route_names.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/product_provider.dart';

class ProductCard extends ConsumerWidget {
  final ProductEntity product;
  final double? width;

  const ProductCard({super.key, required this.product, this.width});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWishlisted =
        ref.watch(wishlistProvider.select((s) => s.contains(product.id)));

    return GestureDetector(
      onTap: () => context.push('${RouteNames.productDetails}/${product.id}'),
      child: Container(
        width: width ?? AppSizes.productCardWidth,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppSizes.radiusLg)),
                  child: product.firstImage != null
                      ? CachedNetworkImage(
                          imageUrl: product.firstImage!,
                          height: AppSizes.productCardImageHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _buildImageSkeleton(),
                          errorWidget: (_, __, ___) => _buildImagePlaceholder(),
                        )
                      : _buildImagePlaceholder(),
                ),
                // Discount badge
                if (product.isOnSale)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.discount,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusXs),
                      ),
                      child: Text(
                        '-${product.discountPercentage}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                // Wishlist button
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () =>
                        ref.read(wishlistProvider.notifier).toggle(product.id),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isWishlisted
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 16,
                        color: isWishlisted
                            ? AppColors.error
                            : AppColors.grey500,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(AppSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 12, color: AppColors.starFilled),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.grey600),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.reviewCount.compact})',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.grey400),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        product.price.currency,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      if (product.compareAtPrice != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          product.compareAtPrice!.currency,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.grey400,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSkeleton() {
    return Shimmer.fromColors(
      baseColor: AppColors.grey200,
      highlightColor: AppColors.grey100,
      child: Container(
        height: AppSizes.productCardImageHeight,
        color: AppColors.grey200,
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: AppSizes.productCardImageHeight,
      color: AppColors.grey100,
      child: const Center(
        child: Icon(Icons.image_outlined, color: AppColors.grey300, size: 40),
      ),
    );
  }
}
