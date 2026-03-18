import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/review_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remote;
  ProductRepositoryImpl(this._remote);

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
      final products = await _remote.getProducts(
        categoryId: categoryId,
        vendorId: vendorId,
        query: query,
        page: page,
        pageSize: pageSize,
        sortBy: sortBy,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minRating: minRating,
        inStock: inStock,
      );
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String id) async {
    try {
      final product = await _remote.getProductById(id);
      return Right(product);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getFeaturedProducts() async {
    try {
      return Right(await _remote.getFeaturedProducts());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getBestSellers() async {
    try {
      return Right(await _remote.getBestSellers());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getNewArrivals() async {
    try {
      return Right(await _remote.getNewArrivals());
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
      return Right(await _remote.getRelatedProducts(productId));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      return Right(await _remote.getCategories());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getProductReviews(
      String productId,
      {int page = 1}) async {
    try {
      final data = await _remote.getProductReviews(productId, page: page);
      return Right(data.map((e) => ReviewModel.fromJson(e)).toList());
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
      final data = await _remote.addReview(
          productId: productId, rating: rating, comment: comment, images: images);
      return Right(ReviewModel.fromJson(data));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getWishlist() async {
    try {
      return Right(await _remote.getWishlist());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToWishlist(String productId) async {
    try {
      await _remote.addToWishlist(productId);
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
      await _remote.removeFromWishlist(productId);
      return const Right(null);
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
      return Right(await _remote.createProduct(data));
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
      return Right(await _remote.updateProduct(id, data));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      await _remote.deleteProduct(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
