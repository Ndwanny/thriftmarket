import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    super.compareAtPrice,
    super.discountPercent,
    required super.categoryId,
    required super.categoryName,
    required super.vendorId,
    required super.vendorName,
    super.vendorLogoUrl,
    required super.images,
    required super.rating,
    required super.reviewCount,
    required super.stock,
    required super.status,
    super.isFeatured,
    super.attributes,
    super.tags,
    required super.createdAt,
    super.isWishlisted,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Support both Supabase column names and legacy API field names
    final vendor = json['vendor'] as Map<String, dynamic>?;
    final category = json['category'] as Map<String, dynamic>?;

    return ProductModel(
      id: json['id'] as String,
      title: (json['name'] ?? json['title']) as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      compareAtPrice: (json['original_price'] ?? json['compare_at_price']) != null
          ? ((json['original_price'] ?? json['compare_at_price']) as num).toDouble()
          : null,
      discountPercent: json['discount_percent'] != null
          ? (json['discount_percent'] as num).toDouble()
          : null,
      categoryId: json['category_id'] as String,
      categoryName: category?['name'] as String? ?? json['category_name'] as String? ?? '',
      vendorId: json['vendor_id'] as String,
      vendorName: vendor?['store_name'] as String? ?? json['vendor_name'] as String? ?? '',
      vendorLogoUrl: vendor?['logo_url'] as String? ?? json['vendor_logo_url'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      stock: (json['stock_quantity'] ?? json['stock']) as int? ?? 0,
      status: _statusFromString(json['status'] as String? ?? 'active'),
      isFeatured: json['is_featured'] as bool? ?? false,
      attributes: (json['specifications'] ?? json['attributes']) as Map<String, dynamic>?,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      createdAt: DateTime.parse(
          json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      isWishlisted: json['is_wishlisted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'compare_at_price': compareAtPrice,
        'discount_percent': discountPercent,
        'category_id': categoryId,
        'category_name': categoryName,
        'vendor_id': vendorId,
        'vendor_name': vendorName,
        'vendor_logo_url': vendorLogoUrl,
        'images': images,
        'rating': rating,
        'review_count': reviewCount,
        'stock': stock,
        'status': status.name,
        'is_featured': isFeatured,
        'attributes': attributes,
        'tags': tags,
        'created_at': createdAt.toIso8601String(),
        'is_wishlisted': isWishlisted,
      };

  static ProductStatus _statusFromString(String status) {
    switch (status) {
      case 'inactive':
        return ProductStatus.inactive;
      case 'pending':
        return ProductStatus.pending;
      case 'rejected':
        return ProductStatus.rejected;
      case 'out_of_stock':
        return ProductStatus.outOfStock;
      default:
        return ProductStatus.active;
    }
  }
}
