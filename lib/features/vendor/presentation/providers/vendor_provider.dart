import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/supabase/supabase_config.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../data/models/vendor_model.dart';
import '../../domain/entities/vendor_entity.dart';

// All active vendors
final allVendorsProvider = FutureProvider<List<VendorEntity>>((ref) async {
  final result = await supabase
      .from('vendors')
      .select()
      .eq('is_active', true)
      .order('rating', ascending: false);
  return (result as List)
      .map((e) => VendorModel.fromJson(e as Map<String, dynamic>))
      .toList();
});

// Single vendor by id
final vendorDetailProvider =
    FutureProvider.family<VendorEntity, String>((ref, id) async {
  final result =
      await supabase.from('vendors').select().eq('id', id).single();
  return VendorModel.fromJson(result as Map<String, dynamic>);
});

// Products belonging to a vendor
final vendorProductsProvider =
    FutureProvider.family<List<ProductEntity>, String>((ref, vendorId) async {
  final result = await supabase
      .from('products')
      .select(
          '*, vendor:vendors(id, store_name, logo_url), category:categories(id, name)')
      .eq('vendor_id', vendorId)
      .eq('is_active', true)
      .order('created_at', ascending: false);
  return (result as List)
      .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
      .toList();
});

// Search query state
class VendorSearchNotifier extends StateNotifier<String> {
  VendorSearchNotifier() : super('');
  void search(String query) => state = query;
  void clear() => state = '';
}

final vendorSearchQueryProvider =
    StateNotifierProvider.autoDispose<VendorSearchNotifier, String>(
        (ref) => VendorSearchNotifier());
