import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    super.iconUrl,
    super.imageUrl,
    super.parentId,
    super.productCount,
    super.subcategories,
    super.colorHex,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconUrl: json['icon_url'] as String?,
      imageUrl: json['image_url'] as String?,
      parentId: json['parent_id'] as String?,
      productCount: json['product_count'] as int? ?? 0,
      colorHex: json['color_hex'] as String? ?? '#6C3CE1',
      subcategories: (json['subcategories'] as List<dynamic>?)
              ?.map((e) =>
                  CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon_url': iconUrl,
        'image_url': imageUrl,
        'parent_id': parentId,
        'product_count': productCount,
        'color_hex': colorHex,
        'subcategories':
            subcategories.map((c) => (c as CategoryModel).toJson()).toList(),
      };
}
