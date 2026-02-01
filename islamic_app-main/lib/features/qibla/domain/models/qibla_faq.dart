class QiblaFaq {
  final String question;
  final String answer;
  bool isExpanded;

  QiblaFaq({
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });

  factory QiblaFaq.fromJson(Map<String, dynamic> json) {
    return QiblaFaq(
      question: json['question'] as String,
      answer: json['answer'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
    };
  }
}