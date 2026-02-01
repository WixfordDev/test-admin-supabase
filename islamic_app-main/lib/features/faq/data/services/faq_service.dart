import 'dart:convert';
import 'package:deenhub/config/gen/assets.gen.dart';
import 'package:flutter/services.dart';
import '../models/faq_model.dart';

class FAQService {
  static Future<List<FAQModel>> loadFAQs() async {
    try {
      final String jsonString = await rootBundle.loadString(Assets.jsonFaqs);
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => FAQModel.fromJson(json)).toList();
    } catch (e) {
      print('Error loading FAQs: $e');
      return [];
    }
  }

  static List<FAQModel> groupByCategory(List<FAQModel> faqs) {
    final Map<String, List<FAQModel>> grouped = {};

    for (var faq in faqs) {
      if (!grouped.containsKey(faq.category)) {
        grouped[faq.category] = [];
      }
      grouped[faq.category]!.add(faq);
    }

    return grouped.entries
        .map((entry) => FAQModel(
              id: entry.key,
              question: entry.key,
              answer: '',
              category: entry.key,
              isExpanded: false,
            ))
        .toList();
  }
}
