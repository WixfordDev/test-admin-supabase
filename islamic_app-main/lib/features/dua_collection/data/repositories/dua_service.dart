import 'dart:convert';
import 'package:deenhub/config/gen/assets.gen.dart';
import 'package:deenhub/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:deenhub/features/dua_collection/domain/models/dua.dart';
import 'package:deenhub/features/dua_collection/domain/models/dua_category.dart';
import 'package:deenhub/features/dua_collection/domain/models/dua_subcategory.dart';
import 'package:deenhub/features/dua_collection/domain/models/dua_data.dart';

class DuaService {
  late DuaCollectionData _duaData;
  final Set<int> _favoriteDuas = {};
  
  // Singleton pattern
  static final DuaService _instance = DuaService._internal();
  factory DuaService() => _instance;
  DuaService._internal();

  Future<void> initialize() async {
    try {
      // Load Dua data from assets
      final String jsonString = await rootBundle.loadString(Assets.jsonDuas);
      final jsonData = json.decode(jsonString);
      _duaData = DuaCollectionData.fromJson(jsonData);
    } catch (e) {
      // Fallback to default data if JSON loading fails
      _duaData = DuaCollectionData(categories: [], duasByCategory: {});
      logger.e('Error loading duas.json: $e');
    }
  }

  // Convert DuaCategoryData to DuaCategory (UI model)
  List<DuaCategory> getCategories() {
    return _duaData.categories.map((cat) {
      // Parse the color string to Color
      Color color = _parseColor(cat.color);
      
      // Get the icon data from the icon string
      IconData icon = _getIconData(cat.icon);
      
      // Count duas in this category
      final duaCount = _duaData.duasByCategory[cat.id]?.length ?? 0;
      
      // Convert subcategories
      final subcategories = cat.subcategories.map((sub) {
        // Count duas in this subcategory
        final subcategoryDuaCount = _duaData.duasByCategory[cat.id]
            ?.where((dua) => dua.subcategoryId == sub.id)
            .length ?? 0;
        
        return DuaSubcategory(
          id: sub.id,
          name: sub.name,
          description: sub.description,
          categoryId: cat.id,
          duaCount: subcategoryDuaCount,
        );
      }).toList();
      
      return DuaCategory(
        id: int.tryParse(cat.id) ?? 0,
        name: cat.name,
        description: cat.description,
        icon: icon,
        color: color,
        duaCount: duaCount,
        subcategories: subcategories,
      );
    }).toList();
  }
  
  // Get subcategories for a specific category
  List<DuaSubcategory> getSubcategories(int categoryId) {
    final categoryIdStr = categoryId.toString();
    final category = _duaData.categories.firstWhere(
      (cat) => cat.id == categoryIdStr,
      orElse: () => DuaCategoryData(
        id: '0',
        name: 'Unknown',
        description: '',
        icon: 'help_outline',
        color: '#9e9e9e',
        subcategories: [],
      ),
    );
    
    return category.subcategories.map((sub) {
      // Count duas in this subcategory
      final subcategoryDuaCount = _duaData.duasByCategory[categoryIdStr]
          ?.where((dua) => dua.subcategoryId == sub.id)
          .length ?? 0;
      
      return DuaSubcategory(
        id: sub.id,
        name: sub.name,
        description: sub.description,
        categoryId: categoryIdStr,
        duaCount: subcategoryDuaCount,
      );
    }).toList();
  }
  
  // Convert DuaData to Dua (UI model) - updated to support subcategory filtering
  List<Dua> getDuasByCategory(int categoryId, {String? subcategoryId}) {
    final categoryIdStr = categoryId.toString();
    final categoryDuas = _duaData.duasByCategory[categoryIdStr] ?? [];
    
    // Filter by subcategory if provided
    final filteredDuas = subcategoryId != null
        ? categoryDuas.where((dua) => dua.subcategoryId == subcategoryId).toList()
        : categoryDuas;
    
    return filteredDuas.map((data) {
      return Dua(
        id: data.id,
        title: data.title,
        arabicText: data.arabicText,
        transliteration: data.transliteration,
        translation: data.translation,
        reference: data.reference,
        category: _getCategoryName(data.categoryId),
        subcategory: _getSubcategoryName(data.categoryId, data.subcategoryId),
        isFavorite: _favoriteDuas.contains(data.id),
      );
    }).toList();
  }
  
  // Get all duas
  List<Dua> getAllDuas() {
    List<Dua> allDuas = [];
    
    _duaData.duasByCategory.forEach((categoryId, duasList) {
      final duas = duasList.map((data) => Dua(
        id: data.id,
        title: data.title,
        arabicText: data.arabicText,
        transliteration: data.transliteration,
        translation: data.translation,
        reference: data.reference,
        category: _getCategoryName(data.categoryId),
        subcategory: _getSubcategoryName(data.categoryId, data.subcategoryId),
        isFavorite: _favoriteDuas.contains(data.id),
      )).toList();
      
      allDuas.addAll(duas);
    });
    
    return allDuas;
  }
  
  // Get favorite duas
  List<Dua> getFavoriteDuas() {
    return getAllDuas().where((dua) => _favoriteDuas.contains(dua.id)).toList();
  }
  
  // Toggle favorite status
  Dua toggleFavorite(Dua dua) {
    if (_favoriteDuas.contains(dua.id)) {
      _favoriteDuas.remove(dua.id);
      return dua.copyWith(isFavorite: false);
    } else {
      _favoriteDuas.add(dua.id);
      return dua.copyWith(isFavorite: true);
    }
  }
  
  // Helper method to get category name from id
  String _getCategoryName(String categoryId) {
    final category = _duaData.categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => DuaCategoryData(
        id: '0',
        name: 'Unknown',
        description: '',
        icon: 'help_outline',
        color: '#9e9e9e',
        subcategories: [],
      ),
    );
    
    return category.name;
  }
  
  // Helper method to get subcategory name from id
  String? _getSubcategoryName(String categoryId, String? subcategoryId) {
    if (subcategoryId == null) return null;
    
    final category = _duaData.categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => DuaCategoryData(
        id: '0',
        name: 'Unknown',
        description: '',
        icon: 'help_outline',
        color: '#9e9e9e',
        subcategories: [],
      ),
    );
    
    final subcategory = category.subcategories.firstWhere(
      (sub) => sub.id == subcategoryId,
      orElse: () => DuaSubcategoryData(
        id: '0',
        name: 'Unknown',
        description: '',
      ),
    );
    
    return subcategory.name;
  }
  
  // Helper method to parse color from string
  Color _parseColor(String colorStr) {
    if (colorStr.startsWith('#')) {
      // Remove the # prefix
      colorStr = colorStr.substring(1);
      
      // Parse the hex color
      var hexColor = int.parse('FF$colorStr', radix: 16);
      return Color(hexColor);
    }
    
    // Default fallback color if parsing fails
    return Colors.purple;
  }
  
  // Helper method to get IconData from string
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'bedtime':
        return Icons.bedtime;
      case 'door_front':
        return Icons.door_front_door;
      case 'water_drop':
        return Icons.water_drop;
      case 'restaurant':
        return Icons.restaurant;
      case 'favorite':
        return Icons.favorite;
      case 'healing':
        return Icons.healing;
      case 'volunteer_activism_outlined':
        return Icons.volunteer_activism_outlined;
      case 'help_outline':
        return Icons.help_outline;
      default:
        return Icons.volunteer_activism_outlined;
    }
  }
} 