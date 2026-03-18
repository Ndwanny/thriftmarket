import 'package:equatable/equatable.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
}

class OrderItemEntity extends Equatable {
  final String id;
  final String productId;
  final String title;
  final String? imageUrl;
  final double price;
  final int quantity;
  final String vendorId;
  final String vendorName;

  const OrderItemEntity({
    required this.id,
    required this.productId,
    required this.title,
    this.imageUrl,
    required this.price,
    required this.quantity,
    required this.vendorId,
    required this.vendorName,
  });

  double get subtotal => price * quantity;

  @override
  List<Object?> get props => [id, productId];
}

class OrderEntity extends Equatable {
  final String id;
  final String userId;
  final List<OrderItemEntity> items;
  final OrderStatus status;
  final double subtotal;
  final double shippingCost;
  final double discount;
  final double total;
  final String? couponCode;
  final AddressEntity shippingAddress;
  final String paymentMethod;
  final String? paymentReference;
  final String? trackingNumber;
  final DateTime createdAt;
  final DateTime? deliveredAt;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.items,
    required this.status,
    required this.subtotal,
    required this.shippingCost,
    required this.discount,
    required this.total,
    this.couponCode,
    required this.shippingAddress,
    required this.paymentMethod,
    this.paymentReference,
    this.trackingNumber,
    required this.createdAt,
    this.deliveredAt,
  });

  bool get isActive => status != OrderStatus.delivered &&
      status != OrderStatus.cancelled &&
      status != OrderStatus.refunded;

  String get statusLabel {
    switch (status) {
      case OrderStatus.pending:      return 'Pending';
      case OrderStatus.confirmed:    return 'Confirmed';
      case OrderStatus.processing:   return 'Processing';
      case OrderStatus.shipped:      return 'Shipped';
      case OrderStatus.delivered:    return 'Delivered';
      case OrderStatus.cancelled:    return 'Cancelled';
      case OrderStatus.refunded:     return 'Refunded';
    }
  }

  @override
  List<Object?> get props => [id, status];
}

class AddressEntity extends Equatable {
  final String id;
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String province;
  final String country;
  final bool isDefault;

  const AddressEntity({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.province,
    required this.country,
    this.isDefault = false,
  });

  String get formatted => '$street, $city, $province, $country';

  @override
  List<Object?> get props => [id];
}
