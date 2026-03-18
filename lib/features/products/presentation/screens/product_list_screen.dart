import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends ConsumerWidget {
  final String categoryId;
  final String categoryName;
  const ProductListScreen({super.key, required this.categoryId, required this.categoryName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(filteredProductsProvider(
        ProductFilterParams(categoryId: categoryId)));
    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: products.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 12,
            mainAxisSpacing: 12, childAspectRatio: 0.72,
          ),
          itemCount: list.length,
          itemBuilder: (_, i) => ProductCard(product: list[i], width: double.infinity),
        ),
      ),
    );
  }
}
