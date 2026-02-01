import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/features/dua_collection/domain/models/dua.dart';

class DuaCard extends StatelessWidget {
  final Dua dua;
  final Color categoryColor;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggled;

  const DuaCard({
    super.key,
    required this.dua,
    required this.categoryColor,
    required this.onTap,
    required this.onFavoriteToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: categoryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildCategoryTags(context).expanded(),
                  IconButton(
                    icon: Icon(
                      dua.isFavorite ? Icons.favorite : Icons.favorite_outline,
                      color: dua.isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: onFavoriteToggled,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                dua.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dua.arabicText,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily:
                      'Amiri', // Make sure a suitable Arabic font is available
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dua.transliteration,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Reference: ${dua.reference}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ).expanded(),
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
      ),
    );
  }

  Widget _buildCategoryTags(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: categoryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            dua.category,
            style: TextStyle(
              color: categoryColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (dua.subcategory != null)
          Container(
            margin: EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: categoryColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              dua.subcategory!,
              style: TextStyle(
                color: categoryColor.withValues(alpha: 0.8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
