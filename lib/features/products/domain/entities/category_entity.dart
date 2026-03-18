import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String? iconUrl;
  final String? imageUrl;
  final String? parentId;
  final int productCount;
  final List<CategoryEntity> subcategories;
  final String colorHex;

  const CategoryEntity({
    required this.id,
    required this.name,
    this.iconUrl,
    this.imageUrl,
    this.parentId,
    this.productCount = 0,
    this.subcategories = const [],
    this.colorHex = '#6C3CE1',
  });

  bool get hasSubcategories => subcategories.isNotEmpty;
  bool get isTopLevel => parentId == null;

  @override
  List<Object?> get props => [id, name];
}
