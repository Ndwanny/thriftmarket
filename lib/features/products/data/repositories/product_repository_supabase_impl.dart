import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/supabase/supabase_config.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_supabase_datasource.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';

class ProductRepositorySupabaseImpl implements ProductRepository {
  final ProductSupabaseDataSource _dataSource;

  ProductRepositorySupabaseImpl(this._dataSource);

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
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
      final data = await _dataSource.getProducts(
        categoryId: categoryId,
        vendorId: vendorId,
        query: query,
        page: page,
        pageSize: pageSize,
        sortBy: sortBy,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
      return Right(data.map(ProductModel.fromJson).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String id) async {
    try {
      final data = await _dataSource.getProductById(id);
      return Right(ProductModel.fromJson(data));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getFeaturedProducts() async {
    try {
      final data = await _dataSource.getFeaturedProducts();
      return Right(data.map(ProductModel.fromJson).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getBestSellers() async {
    try {
      final data = await _dataSource.getBestSellers();
      return Right(data.map(ProductModel.fromJson).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getNewArrivals() async {
    try {
      final data = await _dataSource.getNewArrivals();
      return Right(data.map(ProductModel.fromJson).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final data = await _dataSource.getCategories();
      return Right(data.map(CategoryModel.fromJson).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(
      String categoryId) async {
    try {
      final data = await _dataSource.getProductsByCategory(categoryId);
      return Right(data.map(ProductModel.fromJson).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> searchProducts(
      String query) async {
    try {
      final data = await _dataSource.searchProducts(query);
      return Right(data.map(ProductModel.fromJson).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getWishlist() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return const Right([]);
      final data = await _dataSource.getWishlist(userId);
      return Right(data.map(ProductModel.fromJson).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToWishlist(String productId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return Left(const ServerFailure(message: 'Not logged in'));
      await _dataSource.addToWishlist(userId, productId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromWishlist(String productId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return Left(const ServerFailure(message: 'Not logged in'));
      await _dataSource.removeFromWishlist(userId, productId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getProductReviews(
      String productId, {int page = 1}) async {
    try {
      final data = await _dataSource.getReviews(productId);
      return Right(data.map(ReviewModel.fromJson).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReviewEntity>> addReview({
    required String productId,
    required double rating,
    String? comment,
    List<String>? images,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return Left(const ServerFailure(message: 'Not logged in'));
      final data = await supabase.from('reviews').insert({
        'product_id': productId,
        'user_id': userId,
        'rating': rating.toInt(),
        'comment': comment,
        'images': images ?? [],
      }).select('*, profile:profiles(full_name, avatar_url)').single();
      return Right(ReviewModel.fromJson(data));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getRelatedProducts(
      String productId) async {
    try {
      // Get product's category then fetch others in same category
      final product = await _dataSource.getProductById(productId);
      final categoryId = product['category_id'] as String?;
      if (categoryId == null) return const Right([]);
      final data = await supabase
          .from('products')
          .select('*, vendor:vendors(id, store_name, logo_url)')
          .eq('category_id', categoryId)
          .eq('is_active', true)
          .neq('id', productId)
          .limit(8);
      return Right(List<Map<String, dynamic>>.from(data)
          .map(ProductModel.fromJson)
          .toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> createProduct(
      Map<String, dynamic> data) async {
    try {
      final result = await _dataSource.createProduct(data);
      return Right(ProductModel.fromJson(result));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProduct(
      String id, Map<String, dynamic> data) async {
    try {
      final result = await _dataSource.updateProduct(id, data);
      return Right(ProductModel.fromJson(result));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      await _dataSource.deleteProduct(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

}
