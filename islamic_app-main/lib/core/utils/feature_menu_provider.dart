import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/config/routes/routes.dart';

class FeatureMenuItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  FeatureMenuItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class FeatureMenuProvider {
  /// Returns the list of features for the home screen grid
  static List<FeatureMenuItem> getHomeFeatures(BuildContext context) {
    return [
      FeatureMenuItem(
        title: 'Quran',
        icon: Icons.auto_stories_rounded,
        color: const Color(0xFF4CAF50),
        onTap: () => context.push('/${Routes.quran.name}'),
      ),
      FeatureMenuItem(
        title: 'Prayer Times',
        icon: Icons.access_time_rounded,
        color: const Color(0xFF2196F3),
        onTap: () => context.pushNamed(Routes.prayers.name),
      ),
      FeatureMenuItem(
        title: 'Qibla',
        icon: Icons.explore_outlined,
        color: const Color(0xFF9C27B0),
        onTap: () => context.push('/${Routes.qibla.name}'),
      ),
      FeatureMenuItem(
        title: 'Duas',
        icon: Icons.favorite_outline_rounded,
        color: const Color(0xFFE91E63),
        onTap: () => context.push('/${Routes.duaCollection.name}'),
      ),
      FeatureMenuItem(
        title: 'Hadith',
        icon: Icons.menu_book_rounded,
        color: const Color(0xFFFF9800),
        onTap: () => context.push('/${Routes.hadith.name}'),
      ),
      FeatureMenuItem(
        title: 'Mosques',
        icon: Icons.location_on_outlined,
        color: const Color(0xFF795548),
        onTap: () => context.pushNamed(Routes.mosque.name),
      ),
    ];
  }
}
