import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final String id;
  final String productId;
  final String title;
  final String? imageUrl;
  final double price;
  final double? compareAtPrice;
  final int quantity;
  final String vendorId;
  final String vendorName;
  final int maxStock;
  final Map<String, dynamic>? selectedAttributes;

  const CartItemEntity({
    required this.id,
    required this.productId,
    required this.title,
    this.imageUrl,
    required this.price,
    this.compareAtPrice,
    required this.quantity,
    required this.vendorId,
    required this.vendorName,
    required this.maxStock,
    this.selectedAttributes,
  });

  double get subtotal => price * quantity;

  CartItemEntity copyWith({int? quantity}) {
    return CartItemEntity(
      id: id,
      productId: productId,
      title: title,
      imageUrl: imageUrl,
      price: price,
      compareAtPrice: compareAtPrice,
      quantity: quantity ?? this.quantity,
      vendorId: vendorId,
      vendorName: vendorName,
      maxStock: maxStock,
      selectedAttributes: selectedAttributes,
    );
  }

  @override
  List<Object?> get props => [id, productId, quantity, vendorId];
}

class CartEntity extends Equatable {
  final List<CartItemEntity> items;
  final String? couponCode;
  final double? discountAmount;

  const CartEntity({
    this.items = const [],
    this.couponCode,
    this.discountAmount,
  });

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.subtotal);

  double get discount => discountAmount ?? 0;

  double get shipping => subtotal >= 200 ? 0 : 25;

  double get total => subtotal - discount + shipping;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  Map<String, List<CartItemEntity>> get groupedByVendor {
    final Map<String, List<CartItemEntity>> grouped = {};
    for (final item in items) {
      grouped.putIfAbsent(item.vendorId, () => []).add(item);
    }
    return grouped;
  }

  CartEntity copyWith({
    List<CartItemEntity>? items,
    String? couponCode,
    double? discountAmount,
    bool clearCoupon = false,
  }) {
    return CartEntity(
      items: items ?? this.items,
      couponCode: clearCoupon ? null : (couponCode ?? this.couponCode),
      discountAmount:
          clearCoupon ? null : (discountAmount ?? this.discountAmount),
    );
  }

  @override
  List<Object?> get props => [items, couponCode, discountAmount];
}
