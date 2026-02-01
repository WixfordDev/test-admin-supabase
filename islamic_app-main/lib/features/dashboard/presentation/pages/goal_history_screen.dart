import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:deenhub/core/services/database/enhanced_daily_goals_service.dart';

class GoalHistoryScreen extends StatefulWidget {
  const GoalHistoryScreen({super.key});

  @override
  State<GoalHistoryScreen> createState() => _GoalHistoryScreenState();
}

class _GoalHistoryScreenState extends State<GoalHistoryScreen>
    with TickerProviderStateMixin {
  final EnhancedDailyGoalsService _goalsService = EnhancedDailyGoalsService();
  
  List<GoalHistory> _history = [];
  Map<GoalType, GoalStatistics> _statistics = {};
  bool _isLoading = true;
  GoalType? _selectedFilter;
  DateTimeRange? _dateRange;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadHistory();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final history = await _goalsService.getGoalHistory(
        startDate: _dateRange?.start,
        endDate: _dateRange?.end,
        goalType: _selectedFilter,
      );
      
      final Map<GoalType, GoalStatistics> stats = {};
      for (final type in GoalType.values) {
        stats[type] = await _goalsService.getGoalStatistics(type);
      }

      setState(() {
        _history = history;
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _isLoading ? _buildLoadingState() : _buildContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading your goal history...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_history.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatisticsOverview(),
          const SizedBox(height: 24),
          _buildFilterChips(),
          const SizedBox(height: 16),
          _buildHistoryList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Goal History Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete some goals to see your\nspiritual journey progress here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.flag_rounded, size: 18),
            label: const Text('Start Setting Goals'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsOverview() {
    final totalGoals = _history.length;
    final completedGoals = _history.where((h) => h.wasCompleted).length;
    final completionRate = totalGoals > 0 ? (completedGoals / totalGoals * 100) : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[200]!.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Your Progress Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Goals',
                  totalGoals.toString(),
                  Icons.flag_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  completedGoals.toString(),
                  Icons.check_circle_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Success Rate',
                  '${completionRate.toInt()}%',
                  Icons.trending_up_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All', null),
          const SizedBox(width: 8),
          ...GoalType.values.map((type) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildFilterChip(_getGoalTypeName(type), type),
          )),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, GoalType? type) {
    final isSelected = _selectedFilter == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? type : null;
        });
        _loadHistory();
      },
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue[600],
    );
  }

  Widget _buildHistoryList() {
    final groupedHistory = _groupHistoryByDate(_history);
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupedHistory.length,
      itemBuilder: (context, index) {
        final entry = groupedHistory.entries.elementAt(index);
        final date = entry.key;
        final goals = entry.value;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _formatDateHeader(date),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ...goals.map((goal) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildHistoryCard(goal),
            )),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildHistoryCard(GoalHistory goal) {
    final progressPercentage = goal.targetCount > 0 
        ? (goal.achievedCount / goal.targetCount * 100).clamp(0, 100)
        : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: goal.wasCompleted ? Colors.green[300]! : Colors.grey[200]!,
          width: goal.wasCompleted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: goal.wasCompleted 
                ? Colors.green[100]!.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _goalsService.getGoalColor(goal.goalType).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _goalsService.getGoalIcon(goal.goalType),
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goal.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: goal.wasCompleted ? Colors.green[700] : Colors.grey[800],
                          decoration: goal.wasCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    if (goal.wasCompleted)
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[600],
                        size: 18,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${goal.achievedCount}/${goal.targetCount} completed',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progressPercentage / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          goal.wasCompleted ? Colors.green[500]! : _goalsService.getGoalColor(goal.goalType),
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${progressPercentage.toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: goal.wasCompleted ? Colors.green[600] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                if (goal.note != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    goal.note!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<DateTime, List<GoalHistory>> _groupHistoryByDate(List<GoalHistory> history) {
    final Map<DateTime, List<GoalHistory>> grouped = {};
    
    for (final goal in history) {
      final date = DateTime(goal.date.year, goal.date.month, goal.date.day);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(goal);
    }
    
    // Sort by date descending
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    
    return Map.fromEntries(sortedEntries);
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE, MMM d, y').format(date);
    }
  }

  String _getGoalTypeName(GoalType type) {
    switch (type) {
      case GoalType.prayer:
        return 'Prayer';
      case GoalType.quranReading:
        return 'Quran';
      case GoalType.dhikr:
        return 'Dhikr';
      case GoalType.duaRecitation:
        return 'Dua';
      case GoalType.sadaqah:
        return 'Sadaqah';
      case GoalType.fastingMonday:
      case GoalType.fastingThursday:
        return 'Fasting';
      case GoalType.surahKahf:
        return 'Surah Kahf';
      case GoalType.hadithReading:
        return 'Hadith';
      case GoalType.istighfar:
        return 'Istighfar';
      case GoalType.salawat:
        return 'Salawat';
      case GoalType.quranMemorization:
        return 'Memorization';
      case GoalType.custom:
        return 'Custom';
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.date_range_rounded),
              title: const Text('Date Range'),
              subtitle: _dateRange != null 
                  ? Text('${DateFormat('MMM d').format(_dateRange!.start)} - ${DateFormat('MMM d').format(_dateRange!.end)}')
                  : const Text('All dates'),
              onTap: _selectDateRange,
            ),
            ListTile(
              leading: const Icon(Icons.clear_rounded),
              title: const Text('Clear Filters'),
              onTap: () {
                setState(() {
                  _selectedFilter = null;
                  _dateRange = null;
                });
                _loadHistory();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
      _loadHistory();
      Navigator.of(context).pop();
    }
  }
} 