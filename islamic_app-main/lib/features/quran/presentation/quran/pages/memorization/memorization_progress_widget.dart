// lib/widgets/memorization_progress_widget.dart
import 'package:flutter/material.dart';
import 'package:deenhub/features/quran/domain/models/memorization_model.dart';

class MemorizationProgressWidget extends StatelessWidget {
  final MemorizationProgress progress;
  final VoidCallback onContinuePressed;

  const MemorizationProgressWidget({
    super.key,
    required this.progress, 
    required this.onContinuePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title moved outside the card
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(
                Icons.auto_stories,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Your Memorization Journey',
                style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall text and percentage
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overall Progress',
                      style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      '${progress.overallProgress.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.overallProgress / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Progress info
                Text(
                  '${progress.memorizedCount} of ${progress.totalVerses} verses memorized',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Stats grid - Two rows
                _buildStatsRow(
                  context,
                  [
                    StatInfo('Memorized', progress.memorizedCount.toString(), Colors.green),
                    StatInfo('Reviewing', progress.reviewingCount.toString(), Colors.blue),
                  ],
                ),
                const SizedBox(height: 12),
                _buildStatsRow(
                  context,
                  [
                    StatInfo('Learning', progress.learningCount.toString(), Colors.orange),
                    StatInfo('Total', progress.totalInProgress.toString(), theme.colorScheme.primary),
                  ],
                ),
                
                // Continue button
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onContinuePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Start Memorizing',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, List<StatInfo> stats) {
    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 32,
                  decoration: BoxDecoration(
                    color: stat.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat.title,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      stat.value,
                      style: TextStyle(
                        color: Colors.grey[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList().separate(const SizedBox(width: 8)),
    );
  }
}

class StatInfo {
  final String title;
  final String value;
  final Color color;

  StatInfo(this.title, this.value, this.color);
}

extension ListExtension<T> on List<T> {
  List<Widget> separate(Widget separator) {
    if (length <= 1) return List<Widget>.from(this);
    
    final result = <Widget>[];
    for (int i = 0; i < length; i++) {
      result.add(this[i] as Widget);
      if (i < length - 1) result.add(separator);
    }
    return result;
  }
}
