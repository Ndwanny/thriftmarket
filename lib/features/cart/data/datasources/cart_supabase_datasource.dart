import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/supabase/supabase_config.dart';

abstract class CartSupabaseDataSource {
  Future<List<Map<String, dynamic>>> getCartItems(String userId);
  Future<Map<String, dynamic>> addToCart(
      String userId, String productId, int quantity);
  Future<Map<String, dynamic>> updateCartItem(String itemId, int quantity);
  Future<void> removeCartItem(String itemId);
  Future<void> clearCart(String userId);
}

class CartSupabaseDataSourceImpl implements CartSupabaseDataSource {
  @override
  Future<List<Map<String, dynamic>>> getCartItems(String userId) async {
    try {
      final result = await supabase
          .from('cart_items')
          .select(
              'id, quantity, product:products(id, name, price, images, stock_quantity, vendor:vendors(id, store_name))')
          .eq('user_id', userId);
      return List<Map<String, dynamic>>.from(result);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<Map<String, dynamic>> addToCart(
      String userId, String productId, int quantity) async {
    try {
      final result = await supabase
          .from('cart_items')
          .upsert(
            {
              'user_id': userId,
              'product_id': productId,
              'quantity': quantity,
            },
            onConflict: 'user_id,product_id',
          )
          .select()
          .single();
      return result;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<Map<String, dynamic>> updateCartItem(
      String itemId, int quantity) async {
    try {
      final result = await supabase
          .from('cart_items')
          .update({'quantity': quantity})
          .eq('id', itemId)
          .select()
          .single();
      return result;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<void> removeCartItem(String itemId) async {
    try {
      await supabase.from('cart_items').delete().eq('id', itemId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<void> clearCart(String userId) async {
    try {
      await supabase.from('cart_items').delete().eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    }
  }
}
