import 'package:deenhub/features/dua_collection/data/repositories/dua_service.dart';
import 'package:deenhub/features/dua_collection/domain/models/dua.dart';
import 'package:deenhub/features/dua_collection/domain/models/dua_category.dart';
import 'package:deenhub/features/dua_collection/domain/models/dua_subcategory.dart';

class DuaRepository {
  // Singleton pattern
  static final DuaRepository _instance = DuaRepository._internal();
  
  factory DuaRepository() {
    return _instance;
  }
  
  DuaRepository._internal();
  
  // Service for loading duas from JSON
  final DuaService _duaService = DuaService();
  
  // Get list of categories
  List<DuaCategory> getCategories() {
    return _duaService.getCategories();
  }
  
  // Get subcategories for a specific category
  List<DuaSubcategory> getSubcategories(int categoryId) {
    return _duaService.getSubcategories(categoryId);
  }
  
  // Get duas by category (with optional subcategory filtering)
  List<Dua> getDuasByCategory(int categoryId, {String? subcategoryId}) {
    return _duaService.getDuasByCategory(categoryId, subcategoryId: subcategoryId);
  }
  
  // Get all duas
  List<Dua> getAllDuas() {
    return _duaService.getAllDuas();
  }
  
  // Get favorite duas
  List<Dua> getFavoriteDuas() {
    return _duaService.getFavoriteDuas();
  }
  
  // Toggle favorite status
  Dua toggleFavorite(Dua dua) {
    return _duaService.toggleFavorite(dua);
  }
} 