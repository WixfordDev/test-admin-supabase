import 'package:flutter/material.dart';

/// Lightweight background for trivia games
class TriviaBackground extends StatelessWidget {
  final Widget child;

  const TriviaBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: child,
    );
  }
}

/// Lightweight loading screen for trivia games
class TriviaLoadingScreen extends StatelessWidget {
  const TriviaLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TriviaBackground(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading Questions...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern and attractive question display component
class TriviaQuestionSection extends StatelessWidget {
  final String question;

  const TriviaQuestionSection({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.help_outline_rounded,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Question',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Question text with better styling
          Text(
            question,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.4,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Lightweight options section
class TriviaOptionsSection extends StatelessWidget {
  final List<String> options;
  final int? selectedOptionIndex;
  final int? correctOptionIndex;
  final bool showExplanation;
  final Function(int) onAnswer;

  const TriviaOptionsSection({
    super.key,
    required this.options,
    required this.selectedOptionIndex,
    required this.correctOptionIndex,
    required this.showExplanation,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;

        Color? backgroundColor;
        Color? textColor;
        bool isCorrect = false;
        bool isWrong = false;

        if (showExplanation) {
          if (index == correctOptionIndex) {
            backgroundColor = Colors.green.withOpacity(0.2);
            textColor = Colors.green.shade700;
            isCorrect = true;
          } else if (index == selectedOptionIndex &&
              index != correctOptionIndex) {
            backgroundColor = Colors.red.withOpacity(0.2);
            textColor = Colors.red.shade700;
            isWrong = true;
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TriviaOptionButton(
            option: option,
            index: index,
            onTap: () => onAnswer(index),
            backgroundColor: backgroundColor,
            textColor: textColor,
            disabled: showExplanation,
            isCorrect: isCorrect,
            isWrong: isWrong,
          ),
        );
      }).toList(),
    );
  }
}

/// Modern and attractive option button with enhanced UI
class TriviaOptionButton extends StatefulWidget {
  final String option;
  final int index;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final bool disabled;
  final bool isCorrect;
  final bool isWrong;

  const TriviaOptionButton({
    super.key,
    required this.option,
    required this.index,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
    this.disabled = false,
    this.isCorrect = false,
    this.isWrong = false,
  });

  @override
  State<TriviaOptionButton> createState() => _TriviaOptionButtonState();
}

class _TriviaOptionButtonState extends State<TriviaOptionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final optionLabels = ['A', 'B', 'C', 'D'];

    Color getOptionColor() {
      if (widget.isCorrect) return Colors.green.shade600;
      if (widget.isWrong) return Colors.red.shade600;
      return Theme.of(context).colorScheme.primary;
    }

    Color getBackgroundColor() {
      if (widget.isCorrect) return Colors.green.shade50;
      if (widget.isWrong) return Colors.red.shade50;
      if (_isPressed) {
        return Theme.of(context).colorScheme.primary.withOpacity(0.1);
      }
      return Colors.white;
    }

    return InkWell(
      onTap: widget.disabled ? null : widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      borderRadius: BorderRadius.circular(10),
      splashColor: Colors.white.withOpacity(0.1),
      highlightColor: Colors.white.withOpacity(0.05),
      child: Container(
        decoration: BoxDecoration(
          color: getBackgroundColor(),
          border: Border.all(
            color: widget.isCorrect || widget.isWrong
                ? widget.isCorrect
                      ? Colors.green.shade300
                      : Colors.red.shade300
                : Colors.white.withOpacity(0.5),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              // Option Label Circle
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: getOptionColor(),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    optionLabels[widget.index],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Option Text
              Expanded(
                child: Text(
                  widget.option,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        widget.textColor ??
                        Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ),

              // Status Icon with better styling
              if (widget.isCorrect || widget.isWrong)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: widget.isCorrect
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.isCorrect
                          ? Colors.green.shade300
                          : Colors.red.shade300,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    widget.isCorrect ? Icons.check : Icons.close,
                    color: widget.isCorrect
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    size: 14,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact and clean explanation and fun fact section
class TriviaExplanationSection extends StatelessWidget {
  final String? explanation;
  final String? funFact;
  final bool isCorrect;

  const TriviaExplanationSection({
    super.key,
    required this.explanation,
    required this.funFact,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Result Header with better styling
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                    isCorrect ? Colors.green.shade100 : Colors.red.shade100,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCorrect
                      ? Colors.green.shade200
                      : Colors.red.shade200,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isCorrect ? Colors.green : Colors.red).withOpacity(
                      0.1,
                    ),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isCorrect ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCorrect ? Icons.check : Icons.close,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isCorrect ? 'Correct Answer!' : 'Incorrect Answer!',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isCorrect
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            if (explanation != null && explanation!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Explanation',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      explanation!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (funFact != null && funFact!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Theme.of(context).colorScheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Fun Fact',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      funFact!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Hint/Clue section for trivia games
class TriviaHintSection extends StatelessWidget {
  final String? hint;
  final bool hintUsed;
  final int penaltyPoints;
  final VoidCallback onGetClue;
  final bool disabled;

  const TriviaHintSection({
    super.key,
    required this.hint,
    required this.hintUsed,
    required this.penaltyPoints,
    required this.onGetClue,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show anything if there's no hint available
    if (hint == null || hint!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Get Clue Button
          if (!hintUsed)
            OutlinedButton.icon(
              onPressed: disabled ? null : onGetClue,
              icon: const Icon(Icons.lightbulb_outline, size: 18),
              label: Text(
                'Get Clue (-$penaltyPoints pts)',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

          // Hint Display
          if (hintUsed)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.amber.shade300,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: Colors.amber.shade700,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Hint',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.amber.shade700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.shade300,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '-$penaltyPoints pts',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hint!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                      color: Colors.amber.shade900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Modern skip button for trivia games
class TriviaSkipButton extends StatelessWidget {
  final VoidCallback onSkip;

  const TriviaSkipButton({super.key, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.secondary.withOpacity(0.8),
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: onSkip,
          icon: const Icon(Icons.skip_next_rounded, size: 18),
          label: const Text(
            'Next Question',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
