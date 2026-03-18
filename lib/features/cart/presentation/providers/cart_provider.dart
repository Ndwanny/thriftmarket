import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/cart_entity.dart';

final cartProvider =
    StateNotifierProvider<CartNotifier, CartEntity>((ref) {
  return CartNotifier(ref.watch(localStorageProvider));
});

class CartNotifier extends StateNotifier<CartEntity> {
  final LocalStorage _storage;

  CartNotifier(this._storage) : super(const CartEntity()) {
    _loadCart();
  }

  void _loadCart() {
    try {
      final json = _storage.getList(AppConstants.cartKey);
      if (json != null) {
        final items = json
            .map((e) => _cartItemFromJson(e as Map<String, dynamic>))
            .toList();
        state = CartEntity(items: items);
      }
    } catch (_) {}
  }

  Future<void> _saveCart() async {
    await _storage.setList(
      AppConstants.cartKey,
      state.items.map(_cartItemToJson).toList(),
    );
  }

  void addItem(CartItemEntity item) {
    final existingIndex =
        state.items.indexWhere((i) => i.productId == item.productId);

    if (existingIndex >= 0) {
      final existing = state.items[existingIndex];
      final newQty = (existing.quantity + item.quantity)
          .clamp(1, existing.maxStock);
      final updatedItems = [...state.items];
      updatedItems[existingIndex] = existing.copyWith(quantity: newQty);
      state = state.copyWith(items: updatedItems);
    } else {
      state = state.copyWith(items: [...state.items, item]);
    }
    _saveCart();
  }

  void removeItem(String cartItemId) {
    state = state.copyWith(
      items: state.items.where((i) => i.id != cartItemId).toList(),
    );
    _saveCart();
  }

  void updateQuantity(String cartItemId, int quantity) {
    if (quantity <= 0) {
      removeItem(cartItemId);
      return;
    }
    final updated = state.items.map((item) {
      if (item.id == cartItemId) {
        return item.copyWith(quantity: quantity.clamp(1, item.maxStock));
      }
      return item;
    }).toList();
    state = state.copyWith(items: updated);
    _saveCart();
  }

  void clearCart() {
    state = const CartEntity();
    _storage.remove(AppConstants.cartKey);
  }

  void applyCoupon(String code, double discount) {
    state = state.copyWith(couponCode: code, discountAmount: discount);
  }

  void removeCoupon() {
    state = state.copyWith(clearCoupon: true);
  }

  bool isInCart(String productId) {
    return state.items.any((i) => i.productId == productId);
  }

  CartItemEntity? getItem(String productId) {
    try {
      return state.items.firstWhere((i) => i.productId == productId);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _cartItemToJson(CartItemEntity item) => {
        'id': item.id,
        'product_id': item.productId,
        'title': item.title,
        'image_url': item.imageUrl,
        'price': item.price,
        'compare_at_price': item.compareAtPrice,
        'quantity': item.quantity,
        'vendor_id': item.vendorId,
        'vendor_name': item.vendorName,
        'max_stock': item.maxStock,
        'selected_attributes': item.selectedAttributes != null
            ? jsonEncode(item.selectedAttributes)
            : null,
      };

  CartItemEntity _cartItemFromJson(Map<String, dynamic> json) =>
      CartItemEntity(
        id: json['id'] as String,
        productId: json['product_id'] as String,
        title: json['title'] as String,
        imageUrl: json['image_url'] as String?,
        price: (json['price'] as num).toDouble(),
        compareAtPrice: json['compare_at_price'] != null
            ? (json['compare_at_price'] as num).toDouble()
            : null,
        quantity: json['quantity'] as int,
        vendorId: json['vendor_id'] as String,
        vendorName: json['vendor_name'] as String,
        maxStock: json['max_stock'] as int? ?? 99,
        selectedAttributes: json['selected_attributes'] != null
            ? jsonDecode(json['selected_attributes'] as String)
                as Map<String, dynamic>
            : null,
      );
}

// Convenience providers
final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).itemCount;
});

final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).total;
});
