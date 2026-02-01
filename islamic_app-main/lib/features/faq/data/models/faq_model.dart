import 'package:json_annotation/json_annotation.dart';

part 'faq_model.g.dart';

@JsonSerializable()
class FAQModel {
  final String id;
  final String question;
  final String answer;
  final String category;
  final bool isExpanded;

  FAQModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    this.isExpanded = false,
  });

  factory FAQModel.fromJson(Map<String, dynamic> json) => _$FAQModelFromJson(json);
  Map<String, dynamic> toJson() => _$FAQModelToJson(this);

  FAQModel copyWith({
    String? id,
    String? question,
    String? answer,
    String? category,
    bool? isExpanded,
  }) {
    return FAQModel(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
} 