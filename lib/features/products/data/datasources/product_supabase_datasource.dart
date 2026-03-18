import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/supabase/supabase_config.dart';

abstract class ProductSupabaseDataSource {
  Future<List<Map<String, dynamic>>> getProducts({
    String? categoryId,
    String? vendorId,
    String? query,
    int page = 1,
    int pageSize = 20,
    String? sortBy,
    double? minPrice,
    double? maxPrice,
  });

  Future<Map<String, dynamic>> getProductById(String id);
  Future<List<Map<String, dynamic>>> getFeaturedProducts();
  Future<List<Map<String, dynamic>>> getBestSellers();
  Future<List<Map<String, dynamic>>> getNewArrivals();
  Future<List<Map<String, dynamic>>> getCategories();
  Future<List<Map<String, dynamic>>> getProductsByCategory(String categoryId);
  Future<List<Map<String, dynamic>>> searchProducts(String query);
  Future<List<Map<String, dynamic>>> getWishlist(String userId);
  Future<void> addToWishlist(String userId, String productId);
  Future<void> removeFromWishlist(String userId, String productId);
  Future<List<Map<String, dynamic>>> getReviews(String productId);
  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data);
  Future<Map<String, dynamic>> updateProduct(
      String id, Map<String, dynamic> data);
  Future<void> deleteProduct(String id);
}

class ProductSupabaseDataSourceImpl implements ProductSupabaseDataSource {
  @override
  Future<List<Map<String, dynamic>>> getProducts({
    String? categoryId,
    String? vendorId,
    String? query,
    int page = 1,
    int pageSize = 20,
    String? sortBy,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      var q = supabase
          .from('products')
          .select('*, vendor:vendors(id, store_name, logo_url), category:categories(id, name)')
          .eq('is_active', true);

      if (categoryId != null) q = q.eq('category_id', categoryId);
      if (vendorId != null) q = q.eq('vendor_id', vendorId);
      if (query != null) q = q.ilike('name', '%$query%');
      if (minPrice != null) q = q.gte('price', minPrice);
      if (maxPrice != null) q = q.lte('price', maxPrice);

      final offset = (page - 1) * pageSize;
      final result = await q
          .order(sortBy ?? 'created_at', ascending: false)
          .range(offset, offset + pageSize - 1);
      return List<Map<String, dynamic>>.from(result);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<Map<String, dynamic>> getProductById(String id) async {
    try {
      final result = await supabase
          .from('products')
          .select('*, vendor:vendors(id, store_name, logo_url, banner_url), category:categories(id, name)')
          .eq('id', id)
          .single();
      return result;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getFeaturedProducts() async {
    try {
      final result = await supabase
          .from('products')
          .select('*, vendor:vendors(id, store_name, logo_url)')
          .eq('is_active', true)
          .eq('is_featured', true)
          .order('created_at', ascending: false)
          .limit(10);
      return List<Map<String, dynamic>>.from(result);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getBestSellers() async {
    try {
      final result = await supabase
          .from('products')
          .select('*, vendor:vendors(id, store_name, logo_url)')
          .eq('is_active', true)
          .order('sales_count', ascending: false)
          .limit(10);
      return List<Map<String, dynamic>>.from(result);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getNewArrivals() async {
    try {
      final result = await supabase
          .from('products')
          .select('*, vendor:vendors(id, store_name, logo_url)')
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(10);
      return List<Map<String, dynamic>>.from(result);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final result = await supabase
          .from('categories')
          .select()
          .isFilter('parent_id', null)
          .order('name');
      return List<Map<String, dynamic>>.from(result);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getProductsByCategory(
      String categoryId) async {
    return getProducts(categoryId: categoryId);
  }

  @override
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    return getProducts(query: query);
  }

  @override
  Future<List<Map<String, dynamic>>> getWishlist(String userId) async {
    try {
      final result = await supabase
          .from('wishlist')
          .select('product:products(*, vendor:vendors(id, store_name, logo_url))')
          .eq('user_id', userId);
      return result
          .map<Map<String, dynamic>>((e) => e['product'] as Map<String, dynamic>)
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<void> addToWishlist(String userId, String productId) async {
    try {
      await supabase.from('wishlist').upsert({
        'user_id': userId,
        'product_id': productId,
      });
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<void> removeFromWishlist(String userId, String productId) async {
    try {
      await supabase
          .from('wishlist')
          .delete()
          .eq('user_id', userId)
          .eq('product_id', productId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getReviews(String productId) async {
    try {
      final result = await supabase
          .from('reviews')
          .select('*, profile:profiles(full_name, avatar_url)')
          .eq('product_id', productId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(result);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<Map<String, dynamic>> createProduct(
      Map<String, dynamic> data) async {
    try {
      final result = await supabase.from('products').insert(data).select().single();
      return result;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<Map<String, dynamic>> updateProduct(
      String id, Map<String, dynamic> data) async {
    try {
      final result = await supabase
          .from('products')
          .update(data)
          .eq('id', id)
          .select()
          .single();
      return result;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await supabase.from('products').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    }
  }
}
