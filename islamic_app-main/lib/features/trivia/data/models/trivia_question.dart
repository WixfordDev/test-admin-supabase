import 'dart:convert';

class TriviaQuestion {
  final int id;
  final String question;
  final List<String> options;
  final String answer;
  final String? context;
  final String? funFact;
  final String? hint;
  final String difficulty; // easy, medium, hard

  const TriviaQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.answer,
    this.context,
    this.funFact,
    this.hint,
    required this.difficulty,
  });

  factory TriviaQuestion.fromJson(Map<String, dynamic> json) {
    final dynamic rawOptions = json['options'];
    List<String> parsedOptions;
    if (rawOptions is List) {
      parsedOptions = rawOptions.map((e) => e.toString()).toList(growable: false);
    } else if (rawOptions is String) {
      // In case it's a JSON string
      final decoded = jsonDecode(rawOptions) as List<dynamic>;
      parsedOptions = decoded.map((e) => e.toString()).toList(growable: false);
    } else {
      parsedOptions = const [];
    }

    // Handle answer that might be an int (index) or string (text)
    String answerText;
    final rawAnswer = json['answer'];
    if (rawAnswer is int && rawAnswer >= 0 && rawAnswer < parsedOptions.length) {
      answerText = parsedOptions[rawAnswer];
    } else {
      answerText = rawAnswer.toString();
    }

    return TriviaQuestion(
      id: (json['id'] as num).toInt(),
      question: json['question'] as String,
      options: parsedOptions,
      answer: answerText,
      context: json['context'] as String?,
      funFact: json['fun_fact'] as String?,
      hint: json['hint'] as String?,
      difficulty: (json['difficulty'] ?? 'easy') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'answer': answer,
      'context': context,
      'fun_fact': funFact,
      'hint': hint,
      'difficulty': difficulty,
    };
  }
}





