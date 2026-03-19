import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
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
    final isWishlisted = ref.watch(wishlistProvider.select((s) => s.contains(product.id)));

    return GestureDetector(
      onTap: () => context.push('${RouteNames.productDetails}/${product.id}'),
      child: Container(
        width: width ?? 160,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.grey200, width: 1),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                  child: product.firstImage != null
                      ? CachedNetworkImage(
                          imageUrl: product.firstImage!,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Shimmer.fromColors(
                            baseColor: AppColors.grey200,
                            highlightColor: AppColors.grey100,
                            child: Container(height: 160, color: AppColors.grey200),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            height: 160,
                            color: AppColors.grey100,
                            child: const Center(child: Icon(Icons.image_outlined, color: AppColors.grey300, size: 32)),
                          ),
                        )
                      : Container(
                          height: 160,
                          color: AppColors.grey100,
                          child: const Center(child: Icon(Icons.image_outlined, color: AppColors.grey300, size: 32)),
                        ),
                ),
                // Sale badge
                if (product.isOnSale)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      color: AppColors.black,
                      child: Text(
                        '-${product.discountPercentage}%',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                // Wishlist
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => ref.read(wishlistProvider.notifier).toggle(product.id),
                    child: Container(
                      width: 28,
                      height: 28,
                      color: AppColors.white,
                      child: Icon(
                        isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 14,
                        color: isWishlisted ? AppColors.error : AppColors.grey400,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 10, color: AppColors.primary),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 10, color: AppColors.grey600, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          product.price.currency,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      if (product.compareAtPrice != null)
                        Text(
                          product.compareAtPrice!.currency,
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.grey400,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
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
}
