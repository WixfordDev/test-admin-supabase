import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/features/hadith/domain/models/hadith_book.dart';
import 'package:deenhub/features/hadith/domain/services/hadith_content_service.dart';

class HadithBookCard extends StatelessWidget {
  final HadithBook book;
  final HadithContentService _contentService = HadithContentService.instance;

  HadithBookCard({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Check if the book has chapters or should go directly to hadith list
        if (_contentService.hasChapters(book.id)) {
          // Navigate to hadith chapters screen
          context.pushNamed(
            Routes.hadithChapters.name,
            queryParameters: {'bookId': book.id.toString()},
          );
        } else {
          // Navigate directly to hadith list screen with default chapter ID 1
          context.pushNamed(
            Routes.hadithList.name,
            queryParameters: {
              'bookId': book.id.toString(),
              'chapterId': '0', // Default chapter ID for forties collections
            },
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: p16,
              decoration: BoxDecoration(
                color: context.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  // Enhanced book avatar with gradient
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.3),
                          Colors.white.withValues(alpha: 0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.menu_book,
                      color: context.onPrimaryColor,
                      size: 24,
                    ),
                  ),
                  gapW16,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.onPrimaryColor,
                          ),
                        ),
                        gapH4,
                        Text(
                          book.author,
                          style: TextStyle(
                            fontSize: 14,
                            color: context.onPrimaryColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: context.onPrimaryColor,
                  ),
                ],
              ),
            ),
            Padding(
              padding: p16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.onSurfaceColor.withValues(alpha: 0.8),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  gapH16,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoChip(
                        context,
                        _contentService.hasChapters(book.id) ? '${book.totalChapters} Chapters' : 'Collection',
                        Icons.folder_outlined,
                      ),
                      _buildInfoChip(
                        context,
                        '${book.totalHadiths} Hadiths',
                        Icons.format_quote_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, IconData icon) {
    return Container(
      padding: p8,
      decoration: BoxDecoration(
        color: context.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: context.primaryColor,
          ),
          gapW8,
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: context.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
} 