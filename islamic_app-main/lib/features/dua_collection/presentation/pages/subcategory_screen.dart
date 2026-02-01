import 'package:flutter/material.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/dua_collection/domain/models/dua_category.dart';
import 'package:deenhub/features/dua_collection/domain/models/dua_subcategory.dart';
import 'package:deenhub/features/dua_collection/domain/repositories/dua_repository.dart';
import 'package:deenhub/features/dua_collection/presentation/pages/dua_list_screen.dart';
import 'package:deenhub/features/dua_collection/presentation/pages/favorite_duas_screen.dart';
import 'package:deenhub/features/dua_collection/presentation/widgets/subcategory_card.dart';

class SubcategoryScreen extends StatefulWidget {
  final DuaCategory category;

  const SubcategoryScreen({
    super.key,
    required this.category,
  });

  @override
  State<SubcategoryScreen> createState() => _SubcategoryScreenState();
}

class _SubcategoryScreenState extends State<SubcategoryScreen> {
  final DuaRepository _duaRepository = DuaRepository();
  late List<DuaSubcategory> _subcategories;

  @override
  void initState() {
    super.initState();
    _loadSubcategories();
  }

  void _loadSubcategories() {
    _subcategories = _duaRepository.getSubcategories(widget.category.id);
  }

  void _navigateToSubcategory(
      BuildContext context, DuaSubcategory subcategory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DuaListScreen(
          category: widget.category,
          subcategory: subcategory,
        ),
      ),
    );
  }

  void _navigateToCategoryDuas(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DuaListScreen(
          category: widget.category,
        ),
      ),
    );
  }

  void _navigateToFavorites(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FavoriteDuasScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBarScaffold(
      pageTitle: widget.category.name,
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
            _buildCategoryHeader(),
            const SizedBox(height: 24),
            _buildViewAllDuasCard(),
            const SizedBox(height: 24),
            if (_subcategories.isNotEmpty) ...[
              _buildSubcategoriesTitle(),
              const SizedBox(height: 16),
              _buildSubcategoriesGrid(),
            ],
            if (_subcategories.isEmpty) _buildNoSubcategoriesMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.category.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            widget.category.icon,
            color: widget.category.color,
            size: 36,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.category.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.category.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.onSurfaceColor.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "Total duas: ${widget.category.duaCount}",
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.category.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (_subcategories.isNotEmpty)
                      Text(
                        "Subcategories: ${_subcategories.length}",
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.category.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewAllDuasCard() {
    return InkWell(
      onTap: () => _navigateToCategoryDuas(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.category.color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.category.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.view_list,
                color: widget.category.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "View All Duas",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Browse all ${widget.category.duaCount} duas in this category",
                    style: TextStyle(
                      fontSize: 14,
                      color: context.onSurfaceColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: widget.category.color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubcategoriesTitle() {
    return const Text(
      "Browse by Subcategory",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSubcategoriesGrid() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _subcategories.length,
      itemBuilder: (context, index) {
        final subcategory = _subcategories[index];
        return SubcategoryCard(
          subcategory: subcategory,
          categoryColor: widget.category.color,
          onTap: () => _navigateToSubcategory(context, subcategory),
        );
      },
    );
  }

  Widget _buildNoSubcategoriesMessage() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No subcategories available",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "All duas in this category can be viewed directly",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
