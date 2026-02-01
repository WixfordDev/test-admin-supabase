import 'package:flutter/material.dart';
import 'package:deenhub/config/routes/routes.dart';

class MoreItem {
  final Routes route;
  String? title;
  final dynamic icon;
  final Color iconBgColor;

  MoreItem({
    required this.route,
    this.title,
    required this.icon,
    required this.iconBgColor,
  });
}
