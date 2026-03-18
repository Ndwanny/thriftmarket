import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/category_entity.dart';
import '../entities/product_entity.dart';
import '../entities/review_entity.dart';

abstract class ProductRepository {
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
  });

  Future<Either<Failure, ProductEntity>> getProductById(String id);

  Future<Either<Failure, List<ProductEntity>>> getFeaturedProducts();

  Future<Either<Failure, List<ProductEntity>>> getBestSellers();

  Future<Either<Failure, List<ProductEntity>>> getNewArrivals();

  Future<Either<Failure, List<ProductEntity>>> getRelatedProducts(
      String productId);

  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  Future<Either<Failure, List<ReviewEntity>>> getProductReviews(
      String productId,
      {int page = 1});

  Future<Either<Failure, ReviewEntity>> addReview({
    required String productId,
    required double rating,
    String? comment,
    List<String>? images,
  });

  Future<Either<Failure, List<ProductEntity>>> getWishlist();

  Future<Either<Failure, void>> addToWishlist(String productId);

  Future<Either<Failure, void>> removeFromWishlist(String productId);

  // Vendor-specific
  Future<Either<Failure, ProductEntity>> createProduct(
      Map<String, dynamic> data);

  Future<Either<Failure, ProductEntity>> updateProduct(
      String id, Map<String, dynamic> data);

  Future<Either<Failure, void>> deleteProduct(String id);
}
