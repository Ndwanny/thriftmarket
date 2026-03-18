import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';

class VendorCard extends StatelessWidget {
  final String vendorId;
  final String name;
  final String? logoUrl;
  final double rating;
  final int productCount;
  final bool isVerified;

  const VendorCard({
    super.key,
    required this.vendorId,
    required this.name,
    this.logoUrl,
    required this.rating,
    required this.productCount,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('${RouteNames.vendorStore}/$vendorId'),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primaryContainer,
                  backgroundImage: logoUrl != null
                      ? CachedNetworkImageProvider(logoUrl!)
                      : null,
                  child: logoUrl == null
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'V',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
                if (isVerified)
                  Positioned(
                    bottom: 0,
                    right: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: AppColors.vendorBadge,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          size: 11, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded,
                    size: 11, color: AppColors.starFilled),
                const SizedBox(width: 2),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.grey600),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '$productCount products',
              style:
                  const TextStyle(fontSize: 10, color: AppColors.grey400),
            ),
          ],
        ),
      ),
    );
  }
}
