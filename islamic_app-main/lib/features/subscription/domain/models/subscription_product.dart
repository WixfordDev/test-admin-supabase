import 'package:in_app_purchase/in_app_purchase.dart';

enum SubscriptionPeriod {
  monthly,
  yearly,
}

enum SubscriptionType {
  barakahAccess,
  quranLite,
  deenhubPro,
}

class SubscriptionProduct {
  final String id;
  final String title;
  final String description;
  final double price;
  final double? originalPrice;
  final String currencyCode;
  final String currencySymbol;
  final SubscriptionPeriod period;
  final SubscriptionType type;
  final ProductDetails? productDetails;
  final bool isPopular;
  final List<String> features;
  final String? specialNote;
  final String? sponsorNote;

  const SubscriptionProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.currencyCode,
    required this.currencySymbol,
    required this.period,
    required this.type,
    this.productDetails,
    this.isPopular = false,
    required this.features,
    this.specialNote,
    this.sponsorNote,
  });

  SubscriptionProduct copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    double? originalPrice,
    String? currencyCode,
    String? currencySymbol,
    SubscriptionPeriod? period,
    SubscriptionType? type,
    ProductDetails? productDetails,
    bool? isPopular,
    List<String>? features,
    String? specialNote,
    String? sponsorNote,
  }) {
    return SubscriptionProduct(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      period: period ?? this.period,
      type: type ?? this.type,
      productDetails: productDetails ?? this.productDetails,
      isPopular: isPopular ?? this.isPopular,
      features: features ?? this.features,
      specialNote: specialNote ?? this.specialNote,
      sponsorNote: sponsorNote ?? this.sponsorNote,
    );
  }
} 