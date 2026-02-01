import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TriviaSoloLobbyScreen extends StatefulWidget {
  const TriviaSoloLobbyScreen({super.key});

  @override
  State<TriviaSoloLobbyScreen> createState() => _TriviaSoloLobbyScreenState();
}

class _TriviaSoloLobbyScreenState extends State<TriviaSoloLobbyScreen> {
  String _selectedDifficulty = 'easy';
  int _selectedQuestionCount = 10;

  final List<Map<String, dynamic>> _difficultyLevels = [
    {
      'value': 'easy',
      'label': 'Easy',
      'description': 'Perfect for beginners',
      'points': '10 pts per question',
      'color': Colors.green,
      'icon': Icons.sentiment_satisfied,
    },
    {
      'value': 'medium',
      'label': 'Medium',
      'description': 'Test your knowledge',
      'points': '20 pts per question',
      'color': Colors.orange,
      'icon': Icons.sentiment_neutral,
    },
    {
      'value': 'hard',
      'label': 'Hard',
      'description': 'Challenge yourself',
      'points': '30 pts per question',
      'color': Colors.red,
      'icon': Icons.sentiment_dissatisfied,
    },
  ];

  final List<Map<String, dynamic>> _questionCounts = [
    {'count': 5, 'label': 'Quick', 'description': '5 questions'},
    {'count': 10, 'label': 'Standard', 'description': '10 questions'},
    {'count': 15, 'label': 'Extended', 'description': '15 questions'},
    {'count': 20, 'label': 'Marathon', 'description': '20 questions'},
  ];

  @override
  Widget build(BuildContext context) {
    final selectedDifficultyData = _difficultyLevels.firstWhere(
      (level) => level['value'] == _selectedDifficulty,
    );

    return AppBarScaffold(
      pageTitle: 'Solo Mode Setup',
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Hero Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.surfaceContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Personal Challenge',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Customize your solo trivia experience',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    height: 1.4,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Difficulty Selection
            Text(
              'Select Difficulty',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 16),

            ..._difficultyLevels.map(
              (level) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _DifficultyCard(
                  level: level,
                  isSelected: _selectedDifficulty == level['value'],
                  onTap: () =>
                      setState(() => _selectedDifficulty = level['value']),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Question Count Selection
            Text(
              'Question Count',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _questionCounts
                  .map(
                    (count) => SizedBox(
                      width: (MediaQuery.of(context).size.width - 48) / 2,
                      child: _QuestionCountCard(
                        count: count,
                        isSelected: _selectedQuestionCount == count['count'],
                        onTap: () => setState(
                          () => _selectedQuestionCount = count['count'],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 32),

            // Game Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Game Summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SummaryRow(
                    label: 'Difficulty',
                    value: selectedDifficultyData['label'],
                    icon: selectedDifficultyData['icon'],
                    color: selectedDifficultyData['color'],
                  ),
                  const SizedBox(height: 12),
                  _SummaryRow(
                    label: 'Questions',
                    value: '$_selectedQuestionCount questions',
                    icon: Icons.quiz,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  _SummaryRow(
                    label: 'Points per question',
                    value: selectedDifficultyData['points'],
                    icon: Icons.star,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 12),
                  _SummaryRow(
                    label: 'Time limit',
                    value: '30 seconds each',
                    icon: Icons.timer,
                    color: Colors.red,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Start Game Button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.pushNamed(
                  Routes.triviaSolo.name,
                  queryParameters: {
                    'difficulty': _selectedDifficulty,
                    'count': _selectedQuestionCount.toString(),
                  },
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Game'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final Map<String, dynamic> level;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyCard({
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? level['color'].withOpacity(0.1)
              : Theme.of(context).colorScheme.surfaceContainer,
          border: Border.all(
            color: isSelected
                ? level['color']
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: level['color'].withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(level['icon'], color: level['color'], size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level['label'],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    level['description'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    level['points'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: level['color'],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: level['color'], size: 24),
          ],
        ),
      ),
    );
  }
}

class _QuestionCountCard extends StatelessWidget {
  final Map<String, dynamic> count;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuestionCountCard({
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).colorScheme.surfaceContainer,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              count['count'].toString(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              count['label'],
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
