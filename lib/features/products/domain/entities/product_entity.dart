import 'package:equatable/equatable.dart';

enum ProductStatus { active, inactive, pending, rejected, outOfStock }

class ProductEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final double price;
  final double? compareAtPrice;
  final double? discountPercent;
  final String categoryId;
  final String categoryName;
  final String vendorId;
  final String vendorName;
  final String? vendorLogoUrl;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final int stock;
  final ProductStatus status;
  final bool isFeatured;
  final Map<String, dynamic>? attributes;
  final List<String>? tags;
  final DateTime createdAt;
  final bool isWishlisted;

  const ProductEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.compareAtPrice,
    this.discountPercent,
    required this.categoryId,
    required this.categoryName,
    required this.vendorId,
    required this.vendorName,
    this.vendorLogoUrl,
    required this.images,
    required this.rating,
    required this.reviewCount,
    required this.stock,
    required this.status,
    this.isFeatured = false,
    this.attributes,
    this.tags,
    required this.createdAt,
    this.isWishlisted = false,
  });

  bool get isOnSale =>
      compareAtPrice != null && compareAtPrice! > price;

  bool get isInStock => stock > 0 && status == ProductStatus.active;

  String? get firstImage => images.isNotEmpty ? images.first : null;

  int get discountPercentage {
    if (compareAtPrice == null || compareAtPrice! <= price) return 0;
    return (((compareAtPrice! - price) / compareAtPrice!) * 100).round();
  }

  ProductEntity copyWith({
    String? title,
    String? description,
    double? price,
    double? compareAtPrice,
    int? stock,
    ProductStatus? status,
    bool? isFeatured,
    bool? isWishlisted,
    List<String>? images,
    double? rating,
    int? reviewCount,
    Map<String, dynamic>? attributes,
  }) {
    return ProductEntity(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
      discountPercent: discountPercent,
      categoryId: categoryId,
      categoryName: categoryName,
      vendorId: vendorId,
      vendorName: vendorName,
      vendorLogoUrl: vendorLogoUrl,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      stock: stock ?? this.stock,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      attributes: attributes ?? this.attributes,
      tags: tags,
      createdAt: createdAt,
      isWishlisted: isWishlisted ?? this.isWishlisted,
    );
  }

  @override
  List<Object?> get props => [
        id, title, price, vendorId, stock, status, rating, isWishlisted,
      ];
}
