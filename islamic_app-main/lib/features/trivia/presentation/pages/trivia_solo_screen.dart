import 'dart:async';

import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/trivia/data/models/trivia_question.dart';
import 'package:deenhub/features/trivia/data/services/trivia_service.dart';
import 'package:deenhub/features/trivia/presentation/widgets/trivia_game_widgets.dart';
import 'package:flutter/material.dart';

class TriviaSoloScreen extends StatefulWidget {
  const TriviaSoloScreen({super.key, required this.queryParams});

  final Map<String, String> queryParams;

  @override
  State<TriviaSoloScreen> createState() => _TriviaSoloScreenState();
}

class _TriviaSoloScreenState extends State<TriviaSoloScreen> {
  late TriviaService _service;
  bool _loading = true;
  List<TriviaQuestion> _questions = const [];
  int _questionIndex = 0;
  int _score = 0;
  int _secondsLeft = 30;
  Timer? _timer;
  int? _selectedOptionIndex;
  int? _correctOptionIndex;
  bool _showExplanation = false;
  bool _canSkip = false;
  bool _gameCompleted = false;
  bool _hintUsed = false;
  late String _difficulty;
  late int _questionCount;

  @override
  void initState() {
    super.initState();
    _service = getIt<TriviaService>();
    _difficulty = widget.queryParams['difficulty'] ?? 'easy';
    _questionCount = int.tryParse(widget.queryParams['count'] ?? '10') ?? 10;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuestions();
    });
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await _service.fetchRandomQuestions(
        difficulty: _difficulty,
        limit: _questionCount,
      );
      if (mounted) {
        setState(() {
          _questions = questions;
          _loading = false;
        });
        _startNewQuestion();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        // Show error dialog or handle error
      }
    }
  }

  void _startNewQuestion() {
    if (!mounted || _gameCompleted) return;
    
    final question = _questions[_questionIndex];
    _correctOptionIndex = null;

    // Find correct answer index
    for (int i = 0; i < question.options.length; i++) {
      if (question.options[i].trim().toLowerCase() == 
          question.answer.trim().toLowerCase()) {
        _correctOptionIndex = i;
        break;
      }
    }

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (!mounted) return;
    
    setState(() => _secondsLeft = 30);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) {
          timer.cancel();
          _onTimeUp();
        }
      });
    });
  }

  void _onTimeUp() {
    if (!mounted || _showExplanation) return;

    setState(() {
      _showExplanation = true;
      _canSkip = true;
    });

    // Ensure consistent 8-second delay before auto-navigation
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted && _canSkip && !_gameCompleted) {
        _nextQuestion();
      }
    });
  }

  void _onAnswer(int index) {
    if (_showExplanation || !mounted) return;

    _timer?.cancel();

    final question = _questions[_questionIndex];
    final selectedOption = question.options[index];
    final isCorrect = selectedOption.trim().toLowerCase() ==
        question.answer.trim().toLowerCase();

    setState(() {
      _selectedOptionIndex = index;
      if (isCorrect) {
        // Award points based on difficulty
        switch (_difficulty) {
          case 'easy':
            _score += 10;
            break;
          case 'medium':
            _score += 20;
            break;
          case 'hard':
            _score += 30;
            break;
        }
      }
      _showExplanation = true;
      _canSkip = true;
    });

    // Ensure consistent 8-second delay before auto-navigation
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted && _canSkip && !_gameCompleted) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (!mounted || _gameCompleted) return;
    
    if (_questionIndex + 1 >= _questions.length) {
      _showGameComplete();
      return;
    }
    
    setState(() {
      _questionIndex++;
      _selectedOptionIndex = null;
      _showExplanation = false;
      _canSkip = false;
      _hintUsed = false; // Reset hint for new question
    });
    
    _startNewQuestion();
  }

  void _onGetClue() {
    if (_hintUsed || _showExplanation || !mounted) return;

    // Deduct points based on difficulty
    final penaltyPoints = _difficulty == 'easy'
        ? 3
        : _difficulty == 'medium'
        ? 6
        : 9;

    setState(() {
      _score = (_score - penaltyPoints).clamp(0, double.infinity).toInt();
      _hintUsed = true;
    });
  }

  int _getHintPenalty() {
    return _difficulty == 'easy'
        ? 3
        : _difficulty == 'medium'
        ? 6
        : 9;
  }

  void _skipToNext() {
    if (_canSkip && mounted) {
      setState(() => _canSkip = false);
      _nextQuestion();
    }
  }

  void _showGameComplete() {
    if (_gameCompleted || !mounted) return;
    
    setState(() => _gameCompleted = true);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text('Game Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Final Score',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$_score',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text('Questions: $_questionCount'),
            Text('Difficulty: ${_difficulty.toUpperCase()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to lobby
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  Color _getTimerColor() {
    if (_secondsLeft > 20) return Colors.green;
    if (_secondsLeft > 10) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: TriviaLoadingScreen(),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Solo Quiz')),
        body: const Center(
          child: Text('No questions available'),
        ),
      );
    }

    final question = _questions[_questionIndex];
    final progress = (_questionIndex + 1) / _questions.length;

    return AppBarScaffold(
      pageTitle: 'Solo Quiz',
      child: TriviaBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with progress and score
              _GameHeader(
                progress: progress,
                score: _score,
                questionNumber: _questionIndex + 1,
                totalQuestions: _questions.length,
                difficulty: _difficulty,
                secondsLeft: _secondsLeft,
                timerColor: _getTimerColor(),
              ),

              const SizedBox(height: 16),

              // Question Section
              TriviaQuestionSection(question: question.question),

              const SizedBox(height: 16),

              // Options Section
              TriviaOptionsSection(
                options: question.options,
                selectedOptionIndex: _selectedOptionIndex,
                correctOptionIndex: _correctOptionIndex,
                showExplanation: _showExplanation,
                onAnswer: _onAnswer,
              ),

              // Hint Section
              TriviaHintSection(
                hint: question.hint,
                hintUsed: _hintUsed,
                penaltyPoints: _getHintPenalty(),
                onGetClue: _onGetClue,
                disabled: _showExplanation,
              ),

              // Skip Button
              if (_canSkip) TriviaSkipButton(onSkip: _skipToNext),

              // Explanation Section
              if (_showExplanation)
                TriviaExplanationSection(
                  explanation: question.context,
                  funFact: question.funFact,
                  isCorrect: _selectedOptionIndex == _correctOptionIndex,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameHeader extends StatelessWidget {
  final double progress;
  final int score;
  final int questionNumber;
  final int totalQuestions;
  final String difficulty;
  final int secondsLeft;
  final Color timerColor;

  const _GameHeader({
    required this.progress,
    required this.score,
    required this.questionNumber,
    required this.totalQuestions,
    required this.difficulty,
    required this.secondsLeft,
    required this.timerColor,
  });

  @override
  Widget build(BuildContext context) {
    Color difficultyColor;
    IconData difficultyIcon;
    String difficultyText;

    switch (difficulty) {
      case 'easy':
        difficultyColor = Colors.green;
        difficultyIcon = Icons.sentiment_satisfied;
        difficultyText = 'Easy';
        break;
      case 'medium':
        difficultyColor = Colors.orange;
        difficultyIcon = Icons.sentiment_neutral;
        difficultyText = 'Medium';
        break;
      case 'hard':
        difficultyColor = Colors.red;
        difficultyIcon = Icons.sentiment_dissatisfied;
        difficultyText = 'Hard';
        break;
      default:
        difficultyColor = Colors.blue;
        difficultyIcon = Icons.help;
        difficultyText = 'Unknown';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top Row: Question count and Score
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: difficultyColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: difficultyColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            difficultyIcon,
                            size: 14,
                            color: difficultyColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            difficultyText,
                            style: TextStyle(
                              color: difficultyColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '$questionNumber/$totalQuestions',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        score.toString(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress and Timer
            Row(
              children: [
                // Progress Bar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            size: 14,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Progress',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Timer
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Time',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: timerColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: timerColor,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          secondsLeft.toString(),
                          style: TextStyle(
                            color: timerColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
