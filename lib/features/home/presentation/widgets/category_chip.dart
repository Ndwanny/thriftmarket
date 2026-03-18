import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../products/domain/entities/category_entity.dart';

class CategoryChip extends StatelessWidget {
  final CategoryEntity category;

  const CategoryChip({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(category.colorHex);

    return GestureDetector(
      onTap: () => context.push(
        '${RouteNames.productList}/${category.id}',
        extra: {'name': category.name},
      ),
      child: SizedBox(
        width: 70,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: category.iconUrl != null
                  ? Image.network(category.iconUrl!, width: 28, height: 28)
                  : Icon(_getCategoryIcon(category.name),
                      color: color, size: 26),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF6C3CE1);
    }
  }

  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('electronic')) return Icons.devices_rounded;
    if (lower.contains('fashion') || lower.contains('cloth'))
      return Icons.checkroom_rounded;
    if (lower.contains('food') || lower.contains('grocery'))
      return Icons.local_grocery_store_rounded;
    if (lower.contains('health') || lower.contains('beauty'))
      return Icons.spa_rounded;
    if (lower.contains('sport')) return Icons.sports_basketball_rounded;
    if (lower.contains('home') || lower.contains('furniture'))
      return Icons.chair_rounded;
    if (lower.contains('book')) return Icons.menu_book_rounded;
    if (lower.contains('toy')) return Icons.toys_rounded;
    if (lower.contains('auto') || lower.contains('car'))
      return Icons.directions_car_rounded;
    return Icons.category_rounded;
  }
}
