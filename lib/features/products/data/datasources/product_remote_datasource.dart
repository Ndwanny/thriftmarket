import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    String? categoryId,
    String? vendorId,
    String? query,
    int page = 1,
    int pageSize = 20,
    String? sortBy,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool? inStock,
  });

  Future<ProductModel> getProductById(String id);
  Future<List<ProductModel>> getFeaturedProducts();
  Future<List<ProductModel>> getBestSellers();
  Future<List<ProductModel>> getNewArrivals();
  Future<List<ProductModel>> getRelatedProducts(String productId);
  Future<List<CategoryModel>> getCategories();
  Future<List<Map<String, dynamic>>> getProductReviews(String productId,
      {int page = 1});
  Future<Map<String, dynamic>> addReview({
    required String productId,
    required double rating,
    String? comment,
    List<String>? images,
  });
  Future<List<ProductModel>> getWishlist();
  Future<void> addToWishlist(String productId);
  Future<void> removeFromWishlist(String productId);
  Future<ProductModel> createProduct(Map<String, dynamic> data);
  Future<ProductModel> updateProduct(String id, Map<String, dynamic> data);
  Future<void> deleteProduct(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio _dio;
  ProductRemoteDataSourceImpl(this._dio);

  @override
  Future<List<ProductModel>> getProducts({
    String? categoryId,
    String? vendorId,
    String? query,
    int page = 1,
    int pageSize = 20,
    String? sortBy,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool? inStock,
  }) async {
    try {
      final response = await _dio.get('/products', queryParameters: {
        if (categoryId != null) 'category_id': categoryId,
        if (vendorId != null) 'vendor_id': vendorId,
        if (query != null) 'q': query,
        'page': page,
        'page_size': pageSize,
        if (sortBy != null) 'sort_by': sortBy,
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
        if (minRating != null) 'min_rating': minRating,
        if (inStock != null) 'in_stock': inStock,
      });
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to load products');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await _dio.get('/products/$id');
      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to load product');
    }
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final response = await _dio.get('/products/featured');
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Failed');
    }
  }

  @override
  Future<List<ProductModel>> getBestSellers() async {
    try {
      final response = await _dio.get('/products/best-sellers');
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Failed');
    }
  }

  @override
  Future<List<ProductModel>> getNewArrivals() async {
    try {
      final response = await _dio.get('/products/new-arrivals');
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Failed');
    }
  }

  @override
  Future<List<ProductModel>> getRelatedProducts(String productId) async {
    try {
      final response =
          await _dio.get('/products/$productId/related');
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Failed');
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to load categories');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getProductReviews(String productId,
      {int page = 1}) async {
    try {
      final response = await _dio.get(
        '/products/$productId/reviews',
        queryParameters: {'page': page},
      );
      final list = response.data['data'] as List<dynamic>;
      return list.map((e) => e as Map<String, dynamic>).toList();
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Failed');
    }
  }

  @override
  Future<Map<String, dynamic>> addReview({
    required String productId,
    required double rating,
    String? comment,
    List<String>? images,
  }) async {
    try {
      final response = await _dio.post(
        '/products/$productId/reviews',
        data: {
          'rating': rating,
          if (comment != null) 'comment': comment,
          if (images != null) 'images': images,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to add review');
    }
  }

  @override
  Future<List<ProductModel>> getWishlist() async {
    try {
      final response = await _dio.get('/wishlist');
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Failed');
    }
  }

  @override
  Future<void> addToWishlist(String productId) async {
    try {
      await _dio.post('/wishlist', data: {'product_id': productId});
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Failed');
    }
  }

  @override
  Future<void> removeFromWishlist(String productId) async {
    try {
      await _dio.delete('/wishlist/$productId');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Failed');
    }
  }

  @override
  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.post('/vendor/products', data: data);
      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to create product');
    }
  }

  @override
  Future<ProductModel> updateProduct(
      String id, Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.put('/vendor/products/$id', data: data);
      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to update product');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await _dio.delete('/vendor/products/$id');
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to delete product');
    }
  }
}
