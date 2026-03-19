import '../../domain/entities/vendor_entity.dart';

class VendorModel extends VendorEntity {
  const VendorModel({
    required super.id,
    required super.userId,
    required super.storeName,
    super.storeDescription,
    super.logoUrl,
    super.bannerUrl,
    super.phone,
    super.email,
    required super.status,
    required super.rating,
    required super.reviewCount,
    required super.productCount,
    required super.totalSales,
    required super.totalEarnings,
    required super.pendingPayout,
    required super.isVerified,
    required super.joinedAt,
    super.bankAccountName,
    super.bankAccountNumber,
    super.bankName,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    final isApproved = json['is_approved'] as bool? ?? false;
    final isActive = json['is_active'] as bool? ?? true;

    final VendorStatus status;
    if (isApproved && isActive) {
      status = VendorStatus.approved;
    } else if (!isActive) {
      status = VendorStatus.suspended;
    } else {
      status = VendorStatus.pending;
    }

    final productsData = json['products'] as List<dynamic>?;
    final productCount =
        productsData?.length ?? (json['product_count'] as int? ?? 0);

    return VendorModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      storeName: json['store_name'] as String,
      storeDescription: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      status: status,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      productCount: productCount,
      totalSales: json['sales_count'] as int? ?? 0,
      totalEarnings: 0.0,
      pendingPayout: 0.0,
      isVerified: isApproved,
      joinedAt: DateTime.parse(
          json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }
}
