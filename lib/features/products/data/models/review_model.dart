import '../../domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.productId,
    required super.userId,
    required super.userName,
    super.userAvatarUrl,
    required super.rating,
    super.comment,
    super.images,
    super.isVerifiedPurchase,
    super.helpfulCount,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String? ?? 'Anonymous',
      userAvatarUrl: json['user_avatar_url'] as String?,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isVerifiedPurchase: json['is_verified_purchase'] as bool? ?? false,
      helpfulCount: json['helpful_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
