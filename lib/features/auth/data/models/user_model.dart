import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.phone,
    super.avatarUrl,
    required super.role,
    required super.isEmailVerified,
    super.isPhoneVerified,
    required super.createdAt,
    super.vendorId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: _roleFromString(json['role'] as String? ?? 'buyer'),
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      isPhoneVerified: json['is_phone_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      vendorId: json['vendor_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'role': role.name,
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'created_at': createdAt.toIso8601String(),
      'vendor_id': vendorId,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      fullName: entity.fullName,
      phone: entity.phone,
      avatarUrl: entity.avatarUrl,
      role: entity.role,
      isEmailVerified: entity.isEmailVerified,
      isPhoneVerified: entity.isPhoneVerified,
      createdAt: entity.createdAt,
      vendorId: entity.vendorId,
    );
  }

  static UserRole _roleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'vendor':
        return UserRole.vendor;
      case 'admin':
        return UserRole.admin;
      case 'moderator':
        return UserRole.moderator;
      default:
        return UserRole.buyer;
    }
  }
}
