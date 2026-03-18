import 'package:equatable/equatable.dart';

enum UserRole { buyer, vendor, admin, moderator }

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final UserRole role;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final DateTime createdAt;
  final String? vendorId;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatarUrl,
    required this.role,
    required this.isEmailVerified,
    this.isPhoneVerified = false,
    required this.createdAt,
    this.vendorId,
  });

  bool get isVendor => role == UserRole.vendor || vendorId != null;
  bool get isAdmin => role == UserRole.admin;

  UserEntity copyWith({
    String? fullName,
    String? phone,
    String? avatarUrl,
    UserRole? role,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    String? vendorId,
  }) {
    return UserEntity(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      createdAt: createdAt,
      vendorId: vendorId ?? this.vendorId,
    );
  }

  @override
  List<Object?> get props => [
        id, email, fullName, phone, avatarUrl,
        role, isEmailVerified, isPhoneVerified, createdAt, vendorId,
      ];
}

class AuthTokens extends Equatable {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object> get props => [accessToken, refreshToken, expiresAt];
}
