import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../products/presentation/widgets/product_card.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistIds = ref.watch(wishlistProvider);
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.wishlist, style: Theme.of(context).textTheme.titleMedium)),
      body: wishlistIds.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.favorite_border_rounded, size: 64, color: AppColors.grey300),
              const SizedBox(height: 16),
              Text('Your wishlist is empty', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const Text('Save items you love to your wishlist.', style: TextStyle(color: AppColors.grey500)),
            ]))
          : const Center(child: Text('Wishlist items appear here')),
    );
  }
}
