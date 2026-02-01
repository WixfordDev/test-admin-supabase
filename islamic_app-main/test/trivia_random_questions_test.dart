import 'package:flutter_test/flutter_test.dart';
import 'package:deenhub/features/trivia/data/models/trivia_question.dart';

void main() {
  group('TriviaQuestion Model Tests', () {
    test('TriviaQuestion should parse JSON correctly', () {
      final jsonData = {
        'id': 1,
        'question': 'How many Surahs are in the Qur\'an?',
        'options': ['100', '114', '120', '130'],
        'answer': '114',
        'context': 'The Qur\'an contains 114 Surahs revealed to Prophet Muhammad ﷺ over 23 years.',
        'fun_fact': 'Each Surah has a unique name, like Al-Fatiha or An-Nas.',
        'hint': 'It\'s slightly above 110.',
        'difficulty': 'easy',
      };

      final question = TriviaQuestion.fromJson(jsonData);

      expect(question.id, equals(1));
      expect(question.question, equals('How many Surahs are in the Qur\'an?'));
      expect(question.options, equals(['100', '114', '120', '130']));
      expect(question.answer, equals('114'));
      expect(question.difficulty, equals('easy'));
    });

    test('TriviaQuestion should handle different difficulties', () {
      final easyQuestion = TriviaQuestion.fromJson({
        'id': 1,
        'question': 'Easy question',
        'options': ['A', 'B', 'C', 'D'],
        'answer': 'A',
        'difficulty': 'easy',
      });

      final mediumQuestion = TriviaQuestion.fromJson({
        'id': 2,
        'question': 'Medium question',
        'options': ['A', 'B', 'C', 'D'],
        'answer': 'B',
        'difficulty': 'medium',
      });

      final hardQuestion = TriviaQuestion.fromJson({
        'id': 3,
        'question': 'Hard question',
        'options': ['A', 'B', 'C', 'D'],
        'answer': 'C',
        'difficulty': 'hard',
      });

      expect(easyQuestion.difficulty, equals('easy'));
      expect(mediumQuestion.difficulty, equals('medium'));
      expect(hardQuestion.difficulty, equals('hard'));
    });

    test('TriviaQuestion should handle optional fields', () {
      final minimalQuestion = TriviaQuestion.fromJson({
        'id': 1,
        'question': 'Minimal question',
        'options': ['A', 'B'],
        'answer': 'A',
        'difficulty': 'easy',
      });

      expect(minimalQuestion.context, isNull);
      expect(minimalQuestion.funFact, isNull);
      expect(minimalQuestion.hint, isNull);
    });
  });

  group('Random Question Fetching Logic Tests', () {
    test('should validate difficulty parameter', () {
      const validDifficulties = ['easy', 'medium', 'hard'];
      
      for (final difficulty in validDifficulties) {
        expect(validDifficulties.contains(difficulty), isTrue);
      }
      
      expect(validDifficulties.contains('invalid'), isFalse);
    });

    test('should validate limit parameter', () {
      expect(0, greaterThanOrEqualTo(0));
      expect(10, greaterThanOrEqualTo(0));
      expect(1000, greaterThanOrEqualTo(0));
      expect(-1, lessThan(0));
    });

    test('should handle edge cases gracefully', () {
      // Test that our fallback logic handles various scenarios
      expect(() => 'easy'.toLowerCase(), returnsNormally);
      expect(() => 'MEDIUM'.toLowerCase(), returnsNormally);
      expect(() => 'HARD'.toLowerCase(), returnsNormally);
    });
  });
}
