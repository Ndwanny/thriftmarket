import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final double rating;
  final String? comment;
  final List<String> images;
  final bool isVerifiedPurchase;
  final int helpfulCount;
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.rating,
    this.comment,
    this.images = const [],
    this.isVerifiedPurchase = false,
    this.helpfulCount = 0,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, productId, userId, rating];
}
