import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/features/dua_collection/domain/models/dua_subcategory.dart';

class SubcategoryCard extends StatelessWidget {
  final DuaSubcategory subcategory;
  final Color categoryColor;
  final VoidCallback onTap;

  const SubcategoryCard({
    super.key,
    required this.subcategory,
    required this.categoryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: categoryColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.library_books,
                    color: categoryColor,
                    size: 20,
                  ),
                ),
                gapW8,
                Text(
                  subcategory.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ).expanded(),
                gapW4,
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${subcategory.duaCount} duas",
                    style: TextStyle(
                      color: categoryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            gapH4,
            Row(
              children: [
                Text(
                  subcategory.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.onSurfaceColor.withValues(alpha: 0.7),
                  ),
                ).expanded(),
                gapW8,
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: categoryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    ).withPadding(py4);
  }
}
