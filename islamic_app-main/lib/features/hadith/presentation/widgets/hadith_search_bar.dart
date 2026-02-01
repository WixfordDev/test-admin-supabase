import 'package:flutter/material.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/utils/view_utils.dart';

class HadithSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;

  const HadithSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: p8,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onSearch,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search hadith, book, chapter, or number',
          prefixIcon: Icon(
            Icons.search,
            color: context.onSurfaceColor.withValues(alpha: 0.6),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        style: TextStyle(
          fontSize: 16,
          color: context.onSurfaceColor,
        ),
      ),
    );
  }
} 