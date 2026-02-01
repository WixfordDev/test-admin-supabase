import 'package:deenhub/core/widgets/ink_well_view.dart';
import 'package:deenhub/features/dua_collection/presentation/pages/dua_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/dua_collection/domain/models/dua_category.dart';
import 'package:deenhub/features/dua_collection/domain/repositories/dua_repository.dart';
import 'package:deenhub/features/dua_collection/presentation/pages/subcategory_screen.dart';
import 'package:deenhub/features/dua_collection/presentation/pages/favorite_duas_screen.dart';
import 'package:deenhub/features/dua_collection/presentation/widgets/category_card.dart';

class DuaCollectionScreen extends StatefulWidget {
  const DuaCollectionScreen({super.key});

  @override
  State<DuaCollectionScreen> createState() => _DuaCollectionScreenState();
}

class _DuaCollectionScreenState extends State<DuaCollectionScreen> {
  final DuaRepository _duaRepository = DuaRepository();
  late List<DuaCategory> _categories;
  int _favoriteCount = 0;

  @override
  void initState() {
    super.initState();
    _categories = _duaRepository.getCategories();
    _updateFavoriteCount();
  }

  void _updateFavoriteCount() {
    setState(() {
      _favoriteCount = _duaRepository.getFavoriteDuas().length;
    });
  }

  void _navigateToCategory(BuildContext context, DuaCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => category.subcategories.isNotEmpty
            ? SubcategoryScreen(category: category)
            : DuaListScreen(category: category),
      ),
    ).then((_) {
      // Update favorite count when returning from category screen
      _updateFavoriteCount();
    });
  }

  void _navigateToFavorites(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FavoriteDuasScreen(),
      ),
    ).then((_) {
      // Update favorite count when returning from favorites screen
      _updateFavoriteCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBarScaffold(
      pageTitle: "Dua Collection",
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.favorite),
          onPressed: () => _navigateToFavorites(context),
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderInfo(),
            const SizedBox(height: 24),
            _buildCategoriesGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceContainerColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Welcome to the Dua Collection",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Explore authentic duas from the Quran and Sunnah for various occasions in your daily life.",
            style: TextStyle(
              fontSize: 14,
              color: context.onSurfaceColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard(
                context,
                "Categories",
                "${_categories.length}",
                Icons.category_outlined,
              ),
              _buildStatCard(
                context,
                "Total Duas",
                "${_duaRepository.getAllDuas().length}",
                Icons.menu_book_outlined,
              ),
              InkWellView(
                onTap: () => _navigateToFavorites(context),
                child: _buildStatCard(
                  context,
                  "Favorites",
                  "$_favoriteCount",
                  Icons.favorite_outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String count,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: context.primaryColor,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: context.onSurfaceColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            count,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return CategoryCard(
          category: category,
          onTap: () => _navigateToCategory(context, category),
        );
      },
    );
  }
}
