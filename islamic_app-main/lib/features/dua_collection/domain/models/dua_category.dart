import 'package:flutter/material.dart';
import 'package:deenhub/features/dua_collection/domain/models/dua_subcategory.dart';

class DuaCategory {
  final int id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int duaCount;
  final List<DuaSubcategory> subcategories;

  DuaCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.duaCount,
    required this.subcategories,
  });
} 