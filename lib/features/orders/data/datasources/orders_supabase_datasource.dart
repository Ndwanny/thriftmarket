import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/supabase/supabase_config.dart';

abstract class OrdersSupabaseDataSource {
  Future<List<Map<String, dynamic>>> getOrders(String userId);
  Future<Map<String, dynamic>> getOrderById(String orderId);
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData,
      List<Map<String, dynamic>> items);
  Future<Map<String, dynamic>> updateOrderStatus(
      String orderId, String status);
  Future<void> cancelOrder(String orderId);
}

class OrdersSupabaseDataSourceImpl implements OrdersSupabaseDataSource {
  @override
  Future<List<Map<String, dynamic>>> getOrders(String userId) async {
    try {
      final result = await supabase
          .from('orders')
          .select('*, items:order_items(*, product:products(id, name, images))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(result);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    try {
      final result = await supabase
          .from('orders')
          .select(
              '*, items:order_items(*, product:products(id, name, images, vendor:vendors(id, store_name)))')
          .eq('id', orderId)
          .single();
      return result;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<Map<String, dynamic>> createOrder(
    Map<String, dynamic> orderData,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      // Insert order
      final order = await supabase
          .from('orders')
          .insert(orderData)
          .select()
          .single();

      // Insert order items
      final orderId = order['id'] as String;
      final orderItems =
          items.map((item) => {...item, 'order_id': orderId}).toList();
      await supabase.from('order_items').insert(orderItems);

      // Clear cart
      if (orderData['user_id'] != null) {
        await supabase
            .from('cart_items')
            .delete()
            .eq('user_id', orderData['user_id'] as String);
      }

      return getOrderById(orderId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<Map<String, dynamic>> updateOrderStatus(
      String orderId, String status) async {
    try {
      final result = await supabase
          .from('orders')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId)
          .select()
          .single();
      return result;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await updateOrderStatus(orderId, 'cancelled');
  }
}
