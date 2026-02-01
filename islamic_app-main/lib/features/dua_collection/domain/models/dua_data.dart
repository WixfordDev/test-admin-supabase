
class DuaCollectionData {
  final List<DuaCategoryData> categories;
  final Map<String, List<DuaData>> duasByCategory;

  DuaCollectionData({required this.categories, required this.duasByCategory});

  factory DuaCollectionData.fromJson(Map<String, dynamic> json) {
    List<DuaCategoryData> categories = [];
    Map<String, List<DuaData>> duasByCategory = {};
    
    // Parse categories
    if (json['categories'] != null) {
      categories = (json['categories'] as List)
          .map((catJson) => DuaCategoryData.fromJson(catJson))
          .toList();
    }
    
    // Parse duas by category
    if (json['duas'] != null) {
      final Map<String, dynamic> duasMap = json['duas'];
      duasMap.forEach((categoryKey, duasList) {
        duasByCategory[categoryKey] = (duasList as List)
            .map((duaJson) => DuaData.fromJson(duaJson))
            .toList();
      });
    }
    
    return DuaCollectionData(
      categories: categories,
      duasByCategory: duasByCategory,
    );
  }
}

class DuaCategoryData {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String color;
  final List<DuaSubcategoryData> subcategories;

  DuaCategoryData({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.subcategories,
  });

  factory DuaCategoryData.fromJson(Map<String, dynamic> json) {
    List<DuaSubcategoryData> subcategories = [];
    
    if (json['subcategories'] != null) {
      subcategories = (json['subcategories'] as List)
          .map((subJson) => DuaSubcategoryData.fromJson(subJson))
          .toList();
    }
    
    return DuaCategoryData(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'volunteer_activism_outlined',
      color: json['color'] ?? '#9c27b0',
      subcategories: subcategories,
    );
  }
}

class DuaSubcategoryData {
  final String id;
  final String name;
  final String description;

  DuaSubcategoryData({
    required this.id,
    required this.name,
    required this.description,
  });

  factory DuaSubcategoryData.fromJson(Map<String, dynamic> json) {
    return DuaSubcategoryData(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
    );
  }
}

class DuaData {
  final int id;
  final String title;
  final String arabicText;
  final String transliteration;
  final String translation;
  final String reference;
  final String categoryId;
  final String? subcategoryId;

  DuaData({
    required this.id,
    required this.title,
    required this.arabicText,
    required this.transliteration,
    required this.translation,
    required this.reference,
    required this.categoryId,
    this.subcategoryId,
  });

  factory DuaData.fromJson(Map<String, dynamic> json) {
    return DuaData(
      id: json['id'],
      title: json['title'],
      arabicText: json['arabic_text'],
      transliteration: json['transliteration'],
      translation: json['translation'],
      reference: json['reference'] ?? '',
      categoryId: json['category_id'],
      subcategoryId: json['subcategory_id'],
    );
  }
} 