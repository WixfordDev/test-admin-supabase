import 'package:flutter/material.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/dua_collection/domain/models/dua.dart';
import 'package:deenhub/features/dua_collection/domain/models/dua_category.dart';
import 'package:deenhub/features/dua_collection/domain/models/dua_subcategory.dart';
import 'package:deenhub/features/dua_collection/domain/repositories/dua_repository.dart';
import 'package:deenhub/features/dua_collection/presentation/pages/dua_detail_screen.dart';
import 'package:deenhub/features/dua_collection/presentation/pages/favorite_duas_screen.dart';
import 'package:deenhub/features/dua_collection/presentation/widgets/dua_card.dart';

class DuaListScreen extends StatefulWidget {
  final DuaCategory category;
  final DuaSubcategory? subcategory;

  const DuaListScreen({
    super.key,
    required this.category,
    this.subcategory,
  });

  @override
  State<DuaListScreen> createState() => _DuaListScreenState();
}

class _DuaListScreenState extends State<DuaListScreen> {
  final DuaRepository _duaRepository = DuaRepository();
  late List<Dua> _duas;
  
  @override
  void initState() {
    super.initState();
    _loadDuas();
  }
  
  void _loadDuas() {
    _duas = _duaRepository.getDuasByCategory(
      widget.category.id,
      subcategoryId: widget.subcategory?.id,
    );
  }
  
  void _toggleFavorite(Dua dua) {
    setState(() {
      final updatedDua = _duaRepository.toggleFavorite(dua);
      final index = _duas.indexWhere((item) => item.id == dua.id);
      if (index != -1) {
        _duas[index] = updatedDua;
      }
    });
  }
  
  void _navigateToDuaDetail(Dua dua) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DuaDetailScreen(
          dua: dua,
          onFavoriteToggled: (updatedDua) {
            setState(() {
              final index = _duas.indexWhere((item) => item.id == updatedDua.id);
              if (index != -1) {
                _duas[index] = updatedDua;
              }
            });
          },
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

  String get _pageTitle {
    return widget.subcategory?.name ?? widget.category.name;
  }

  @override
  Widget build(BuildContext context) {
    return AppBarScaffold(
      pageTitle: _pageTitle,
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.favorite),
          onPressed: () => _navigateToFavorites(context),
          tooltip: "Favorite Duas",
        ),
        IconButton(
          icon: Icon(
            Icons.info_outline,
            color: widget.category.color,
          ),
          onPressed: () {
            _showInfo(context);
          },
          tooltip: widget.subcategory != null ? "Subcategory Info" : "Category Info",
        ),
      ],
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildDuasList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: widget.category.color.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(
            widget.subcategory != null ? Icons.library_books : widget.category.icon,
            color: widget.category.color,
            size: 36,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _pageTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (widget.subcategory != null) ...[
                  Text(
                    "From ${widget.category.name}",
                    style: TextStyle(
                      fontSize: 12,
                      color: context.onSurfaceColor.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  "${_duas.length} duas ${widget.subcategory != null ? 'in this subcategory' : 'in this category'}",
                  style: TextStyle(
                    fontSize: 14,
                    color: context.onSurfaceColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDuasList() {
    if (_duas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "No duas available",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.subcategory != null
                  ? "This subcategory doesn't contain any duas yet"
                  : "This category doesn't contain any duas yet",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _duas.length,
      itemBuilder: (context, index) {
        final dua = _duas[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DuaCard(
            dua: dua,
            categoryColor: widget.category.color,
            onTap: () => _navigateToDuaDetail(dua),
            onFavoriteToggled: () => _toggleFavorite(dua),
          ),
        );
      },
    );
  }
  
  void _showInfo(BuildContext context) {
    final isSubcategory = widget.subcategory != null;
    final name = isSubcategory ? widget.subcategory!.name : widget.category.name;
    final description = isSubcategory ? widget.subcategory!.description : widget.category.description;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          name,
          style: TextStyle(
            color: widget.category.color,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSubcategory ? Icons.library_books : widget.category.icon,
              color: widget.category.color,
              size: 50,
            ),
            const SizedBox(height: 16),
            if (isSubcategory) ...[
              Text(
                "Category: ${widget.category.name}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(description),
            const SizedBox(height: 8),
            Text(
              "Total duas: ${_duas.length}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
} 