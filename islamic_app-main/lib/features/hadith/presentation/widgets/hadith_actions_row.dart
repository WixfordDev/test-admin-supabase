import 'package:flutter/material.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/utils/view_utils.dart';

class HadithActionsRow extends StatelessWidget {
  final bool showArabic;
  final bool showTranslation;
  final VoidCallback onToggleArabic;
  final VoidCallback onToggleTranslation;
  final VoidCallback onShare;
  final VoidCallback onBookmark;
  final VoidCallback onCopy;

  const HadithActionsRow({
    super.key,
    required this.showArabic,
    required this.showTranslation,
    required this.onToggleArabic,
    required this.onToggleTranslation,
    required this.onShare,
    required this.onBookmark,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: px16,
      padding: p8,
      decoration: BoxDecoration(
        color: context.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            context: context,
            icon: Icons.language,
            label: 'Arabic',
            isActive: showArabic,
            onTap: onToggleArabic,
          ),
          _buildActionButton(
            context: context,
            icon: Icons.translate,
            label: 'Translation',
            isActive: showTranslation,
            onTap: onToggleTranslation,
          ),
          _buildActionButton(
            context: context,
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: onShare,
          ),
          _buildActionButton(
            context: context,
            icon: Icons.bookmark_outline,
            label: 'Save',
            onTap: onBookmark,
          ),
          _buildActionButton(
            context: context,
            icon: Icons.copy_outlined,
            label: 'Copy',
            onTap: onCopy,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive
                    ? context.primaryColor
                    : context.onSurfaceColor.withValues(alpha: 0.4),
              ),
              gapH4,
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isActive
                      ? context.primaryColor
                      : context.onSurfaceColor.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 