import 'dart:convert';
import 'package:deenhub/config/gen/assets.gen.dart';
import 'package:deenhub/main.dart';
import 'package:flutter/services.dart';
import '../models/zakat_faq_model.dart';

class ZakatFAQService {
  static Future<List<ZakatFAQModel>> loadZakatFAQs() async {
    try {
      final String jsonString = await rootBundle.loadString(Assets.jsonZakatFaqs);
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => ZakatFAQModel.fromJson(json)).toList();
    } catch (e) {
      logger.e('Error loading Zakat FAQs: $e');
      return [];
    }
  }

  static List<String> getCategories(List<ZakatFAQModel> faqs) {
    return faqs.map((faq) => faq.category).toSet().toList();
  }

  static List<ZakatFAQModel> getFAQsByCategory(List<ZakatFAQModel> faqs, String category) {
    return faqs.where((faq) => faq.category == category).toList();
  }
}
