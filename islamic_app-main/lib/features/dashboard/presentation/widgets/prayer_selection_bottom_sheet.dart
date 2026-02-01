import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:deenhub/core/services/database/enhanced_daily_goals_service.dart';

class PrayerSelectionBottomSheet extends StatefulWidget {
  final EnhancedDailyGoal goal;
  final Function(Map<String, bool>) onPrayersSelected;

  const PrayerSelectionBottomSheet({
    super.key,
    required this.goal,
    required this.onPrayersSelected,
  });

  @override
  State<PrayerSelectionBottomSheet> createState() => _PrayerSelectionBottomSheetState();
}

class _PrayerSelectionBottomSheetState extends State<PrayerSelectionBottomSheet> {
  final Map<String, bool> _prayerCompletions = {
    'Fajr': false,
    'Dhuhr': false,
    'Asr': false,
    'Maghrib': false,
    'Isha': false,
  };

  final Map<String, IconData> _prayerIcons = {
    'Fajr': Icons.wb_sunny_outlined,
    'Dhuhr': Icons.wb_sunny,
    'Asr': Icons.wb_twilight,
    'Maghrib': Icons.brightness_3,
    'Isha': Icons.nightlight,
  };

  final Map<String, String> _prayerTimes = {
    'Fajr': 'Dawn Prayer',
    'Dhuhr': 'Noon Prayer',
    'Asr': 'Afternoon Prayer',
    'Maghrib': 'Sunset Prayer',
    'Isha': 'Night Prayer',
  };

  @override
  void initState() {
    super.initState();
    _initializePrayerStates();
  }

  void _initializePrayerStates() {
    // Parse existing prayer completions from goal progress entries
    final latestEntry = widget.goal.progressEntries.isNotEmpty 
        ? widget.goal.progressEntries.last 
        : null;
    
    if (latestEntry?.note != null && latestEntry!.note!.contains('Completed prayers:')) {
      final completedPrayersString = latestEntry.note!.split('Completed prayers: ')[1];
      final completedPrayers = completedPrayersString.split(', ');
      
      for (final prayer in completedPrayers) {
        if (_prayerCompletions.containsKey(prayer.trim())) {
          _prayerCompletions[prayer.trim()] = true;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: widget.goal.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.goal.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.goal.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Select the prayers you have completed',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Prayer List
                  Column(
                    children: _prayerCompletions.keys.map((prayer) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildPrayerTile(prayer),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Progress Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Progress: ${_getCompletedCount()}/${_prayerCompletions.length} prayers completed',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveProgress,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.goal.color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save Progress',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrayerTile(String prayer) {
    final isCompleted = _prayerCompletions[prayer] ?? false;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _prayerCompletions[prayer] = !isCompleted;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted 
              ? widget.goal.color.withValues(alpha: 0.1) 
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted 
                ? widget.goal.color 
                : Colors.grey[300]!,
            width: isCompleted ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Prayer Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted 
                    ? widget.goal.color.withValues(alpha: 0.2) 
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _prayerIcons[prayer],
                color: isCompleted 
                    ? widget.goal.color 
                    : Colors.grey[600],
                size: 20,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Prayer Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prayer,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isCompleted 
                          ? widget.goal.color 
                          : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _prayerTimes[prayer] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted 
                    ? widget.goal.color 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isCompleted 
                      ? widget.goal.color 
                      : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  int _getCompletedCount() {
    return _prayerCompletions.values.where((completed) => completed).length;
  }

  void _saveProgress() {
    HapticFeedback.lightImpact();
    widget.onPrayersSelected(_prayerCompletions);
    Navigator.of(context).pop();
  }
} 