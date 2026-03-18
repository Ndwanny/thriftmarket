import 'package:equatable/equatable.dart';

enum VendorStatus { pending, approved, suspended, rejected }

class VendorEntity extends Equatable {
  final String id;
  final String userId;
  final String storeName;
  final String? storeDescription;
  final String? logoUrl;
  final String? bannerUrl;
  final String? phone;
  final String? email;
  final String? website;
  final VendorStatus status;
  final double rating;
  final int reviewCount;
  final int productCount;
  final int totalSales;
  final double totalEarnings;
  final double pendingPayout;
  final bool isVerified;
  final DateTime joinedAt;
  final String? bankAccountName;
  final String? bankAccountNumber;
  final String? bankName;

  const VendorEntity({
    required this.id,
    required this.userId,
    required this.storeName,
    this.storeDescription,
    this.logoUrl,
    this.bannerUrl,
    this.phone,
    this.email,
    this.website,
    required this.status,
    required this.rating,
    required this.reviewCount,
    required this.productCount,
    required this.totalSales,
    required this.totalEarnings,
    required this.pendingPayout,
    required this.isVerified,
    required this.joinedAt,
    this.bankAccountName,
    this.bankAccountNumber,
    this.bankName,
  });

  bool get isActive => status == VendorStatus.approved;
  String get initials => storeName.isNotEmpty ? storeName[0].toUpperCase() : 'V';

  @override
  List<Object?> get props => [id, userId, storeName, status];
}
