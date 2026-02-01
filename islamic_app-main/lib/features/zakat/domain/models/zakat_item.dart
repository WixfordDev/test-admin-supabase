import 'package:flutter/material.dart';

class ZakatItem {
  final String title;
  final String subtitle;
  final TextEditingController controller;
  final IconData icon;
  final Color color;

  ZakatItem({
    required this.title,
    required this.subtitle,
    required this.controller,
    required this.icon,
    required this.color,
  });
} 