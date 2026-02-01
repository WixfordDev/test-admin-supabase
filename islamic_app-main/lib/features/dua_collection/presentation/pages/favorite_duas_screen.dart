import 'package:flutter/material.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/dua_collection/domain/models/dua.dart';
import 'package:deenhub/features/dua_collection/domain/repositories/dua_repository.dart';
import 'package:deenhub/features/dua_collection/presentation/pages/dua_detail_screen.dart';
import 'package:deenhub/features/dua_collection/presentation/widgets/dua_card.dart';

class FavoriteDuasScreen extends StatefulWidget {
  const FavoriteDuasScreen({super.key});

  @override
  State<FavoriteDuasScreen> createState() => _FavoriteDuasScreenState();
}

class _FavoriteDuasScreenState extends State<FavoriteDuasScreen> {
  final DuaRepository _duaRepository = DuaRepository();
  List<Dua>? _favoriteDuas; // Change to nullable to track loading state
  
  @override
  void initState() {
    super.initState();
    _loadFavoriteDuasInstantly();
  }
  
  void _loadFavoriteDuasInstantly() {
    // Load immediately without setState to avoid unnecessary builds
    _favoriteDuas = _duaRepository.getFavoriteDuas();
    // Only setState if we actually have data to show
    if (mounted) {
      setState(() {});
    }
  }
  
  void _toggleFavorite(Dua dua) {
    setState(() {
      _duaRepository.toggleFavorite(dua);
      _favoriteDuas = _duaRepository.getFavoriteDuas(); // Reload instantly
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
              // After returning from details screen with toggle, reload instantly
              _favoriteDuas = _duaRepository.getFavoriteDuas();
            });
          },
        ),
      ),
    ).then((_) {
      // Reload favorites when returning from detail screen
      setState(() {
        _favoriteDuas = _duaRepository.getFavoriteDuas();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBarScaffold(
      pageTitle: "Favorite Duas",
      child: _favoriteDuas == null
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator only if data is null
          : _favoriteDuas!.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _favoriteDuas!.length,
                  itemBuilder: (context, index) {
                    final dua = _favoriteDuas![index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: DuaCard(
                        dua: dua,
                        categoryColor: Theme.of(context).primaryColor,
                        onTap: () => _navigateToDuaDetail(dua),
                        onFavoriteToggled: () => _toggleFavorite(dua),
                      ),
                    );
                  },
                ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No favorite duas yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add duas to favorites to easily access them later",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: context.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("Browse Duas"),
          ),
        ],
      ),
    );
  }
} 