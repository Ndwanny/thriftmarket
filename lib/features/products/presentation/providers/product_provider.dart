import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/datasources/product_supabase_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/product_repository_supabase_impl.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

// Repository — uses Supabase when configured, falls back to REST API
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  if (AppConfig.isSupabaseConfigured) {
    return ProductRepositorySupabaseImpl(ProductSupabaseDataSourceImpl());
  }
  return ProductRepositoryImpl(
    ProductRemoteDataSourceImpl(ref.watch(dioProvider)),
  );
});

// Featured products
final featuredProductsProvider =
    FutureProvider<List<ProductEntity>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final result = await repo.getFeaturedProducts();
  return result.fold((f) => throw Exception(f.message), (p) => p);
});

// Best sellers
final bestSellersProvider =
    FutureProvider<List<ProductEntity>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final result = await repo.getBestSellers();
  return result.fold((f) => throw Exception(f.message), (p) => p);
});

// New arrivals
final newArrivalsProvider =
    FutureProvider<List<ProductEntity>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final result = await repo.getNewArrivals();
  return result.fold((f) => throw Exception(f.message), (p) => p);
});

// Categories
final categoriesProvider =
    FutureProvider<List<CategoryEntity>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final result = await repo.getCategories();
  return result.fold((f) => throw Exception(f.message), (c) => c);
});

// Single product
final productDetailProvider =
    FutureProvider.family<ProductEntity, String>((ref, id) async {
  final repo = ref.watch(productRepositoryProvider);
  final result = await repo.getProductById(id);
  return result.fold((f) => throw Exception(f.message), (p) => p);
});

// Products by category/filter params
class ProductFilterParams {
  final String? categoryId;
  final String? vendorId;
  final String? query;
  final int page;
  final String? sortBy;
  final double? minPrice;
  final double? maxPrice;

  const ProductFilterParams({
    this.categoryId,
    this.vendorId,
    this.query,
    this.page = 1,
    this.sortBy,
    this.minPrice,
    this.maxPrice,
  });
}

final filteredProductsProvider =
    FutureProvider.family<List<ProductEntity>, ProductFilterParams>(
        (ref, params) async {
  final repo = ref.watch(productRepositoryProvider);
  final result = await repo.getProducts(
    categoryId: params.categoryId,
    vendorId: params.vendorId,
    query: params.query,
    page: params.page,
    sortBy: params.sortBy,
    minPrice: params.minPrice,
    maxPrice: params.maxPrice,
  );
  return result.fold((f) => throw Exception(f.message), (p) => p);
});

// Wishlist
final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, Set<String>>((ref) {
  return WishlistNotifier(ref.watch(productRepositoryProvider));
});

class WishlistNotifier extends StateNotifier<Set<String>> {
  final ProductRepository _repo;
  WishlistNotifier(this._repo) : super({}) {
    _load();
  }

  Future<void> _load() async {
    final result = await _repo.getWishlist();
    result.fold((_) {}, (products) {
      state = products.map((p) => p.id).toSet();
    });
  }

  Future<void> toggle(String productId) async {
    if (state.contains(productId)) {
      state = {...state}..remove(productId);
      await _repo.removeFromWishlist(productId);
    } else {
      state = {...state, productId};
      await _repo.addToWishlist(productId);
    }
  }

  bool isWishlisted(String productId) => state.contains(productId);
}
