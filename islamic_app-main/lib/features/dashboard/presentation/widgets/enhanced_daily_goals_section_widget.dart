import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:deenhub/core/services/database/enhanced_daily_goals_service.dart';
import 'package:deenhub/core/notification/services/daily_goals_notification_service.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/features/dashboard/presentation/pages/goal_history_screen.dart';
import 'package:deenhub/features/dashboard/presentation/pages/create_custom_goal_screen.dart';
import 'package:deenhub/features/dashboard/presentation/widgets/prayer_selection_bottom_sheet.dart';

class EnhancedDailyGoalsSectionWidget extends StatefulWidget {
  const EnhancedDailyGoalsSectionWidget({super.key});

  @override
  State<EnhancedDailyGoalsSectionWidget> createState() => _EnhancedDailyGoalsSectionWidgetState();
}

class _EnhancedDailyGoalsSectionWidgetState extends State<EnhancedDailyGoalsSectionWidget>
    with TickerProviderStateMixin {
  final EnhancedDailyGoalsService _goalsService = EnhancedDailyGoalsService();
  late final DailyGoalsNotificationService _notificationService;
  
  List<EnhancedDailyGoal> _dailyGoals = [];
  List<GoalPreset> _presets = [];
  bool _isLoading = false;
  bool _isLoadingPresets = false;
  bool _showAllPresets = false;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _notificationService = getIt<DailyGoalsNotificationService>();
    _initializeAnimations();
    _initializeServices();
    _loadTodayGoals();
    _loadPresets();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideController.forward();
    _fadeController.forward();
  }

  Future<void> _initializeServices() async {
    await _goalsService.initialize();
    // Notification service is already initialized in app_injections.dart
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadTodayGoals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final goals = await _goalsService.initializeTodayGoals();
      setState(() {
        _dailyGoals = goals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading goals: $e');
    }
  }

  Future<void> _loadPresets() async {
    setState(() {
      _isLoadingPresets = true;
    });

    try {
      // Check if user has custom presets first
      final hasCustomPresets = await _goalsService.hasUserCustomPresets();
      
      List<GoalPreset> presets;
      if (hasCustomPresets) {
        // Load user's custom presets and remaining system presets
        final userPresets = await _goalsService.getUserCustomPresets();
        final systemPresets = await _goalsService.getActivePresets();
        
        // Filter out system presets that conflict with user presets
        final filteredSystemPresets = systemPresets.where((sysPreset) =>
            !userPresets.any((userPreset) => 
                userPreset.type == sysPreset.type && userPreset.title == sysPreset.title)).toList();
        
        presets = [...userPresets, ...filteredSystemPresets];
      } else {
        presets = await _goalsService.getActivePresets();
      }
      
      setState(() {
        _presets = presets;
        _isLoadingPresets = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPresets = false;
      });
      debugPrint('Error loading presets: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildDailyGoalsContent(),
            const SizedBox(height: 24),
            _buildPresetsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.flag_rounded,
                color: Colors.blue[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Goals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getDailyProgressText(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            _buildActionButton(
              icon: Icons.history_rounded,
              onTap: _showGoalHistory,
              tooltip: 'View History',
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.add_rounded,
              onTap: _showCreateCustomGoal,
              tooltip: 'Create Custom Goal',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  String _getDailyProgressText() {
    if (_dailyGoals.isEmpty) return 'No goals set for today';
    
    final completed = _dailyGoals.where((goal) => goal.isCompleted).length;
    final total = _dailyGoals.length;
    
    if (completed == total) {
      return 'All goals completed! 🎉';
    } else {
      return '$completed of $total completed';
    }
  }

  Widget _buildDailyGoalsContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_dailyGoals.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildOverallProgress(),
        const SizedBox(height: 16),
        _buildGoalsTip(),
        const SizedBox(height: 12),
        _buildGoalsList(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text(
              'Loading your goals...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.flag_outlined,
              size: 32,
              color: Colors.blue[600],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No goals for today',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose from preset goals below or\ncreate your own custom goals',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showCreateCustomGoal,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Create Custom Goal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallProgress() {
    final completed = _dailyGoals.where((goal) => goal.isCompleted).length;
    final total = _dailyGoals.length;
    final progressPercentage = total > 0 ? completed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue[400]!,
            Colors.blue[600]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[200]!.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Progress',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completed/$total Goals',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progressPercentage,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                '${(progressPercentage * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsTip() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[600], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tip: Tap goals to update progress • Long press goals to edit or delete',
              style: TextStyle(
                fontSize: 11,
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _dailyGoals.length,
      itemBuilder: (context, index) {
        final goal = _dailyGoals[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildGoalCard(goal),
        );
      },
    );
  }

  Widget _buildGoalCard(EnhancedDailyGoal goal) {
    return GestureDetector(
      onTap: goal.isCompleted ? null : () => _updateGoalProgress(goal),
      onLongPress: () => _showGoalOptions(goal),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: goal.isCompleted 
                ? Colors.green[300]! 
                : Colors.grey[200]!,
            width: goal.isCompleted ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: goal.isCompleted
                  ? Colors.green[100]!.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
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
                color: goal.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: goal.color.withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Text(
                  goal.icon,
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
                            color: goal.isCompleted 
                                ? Colors.green[700] 
                                : Colors.grey[800],
                            decoration: goal.isCompleted 
                                ? TextDecoration.lineThrough 
                                : null,
                          ),
                        ),
                      ),
                      if (goal.isCompleted)
                        Icon(
                          Icons.check_circle,
                          color: Colors.green[600],
                          size: 18,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    goal.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: goal.progress,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            goal.isCompleted 
                                ? Colors.green[500]! 
                                : goal.color,
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${goal.currentCount}/${goal.targetCount}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: goal.isCompleted 
                              ? Colors.green[600] 
                              : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            if (goal.isCompleted)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.green[600],
                  size: 20,
                ),
              )
            else
              GestureDetector(
                onTap: () => _updateGoalProgress(goal),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: goal.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: goal.color,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.library_books_rounded,
                    color: Colors.orange[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Goal Presets',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: _showCreateCustomGoal,
              child: const Text(
                'Create Custom',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FutureBuilder<bool>(
          future: _goalsService.hasUserCustomPresets(),
          builder: (context, snapshot) {
            final hasCustomPresets = snapshot.data ?? false;
            
            if (hasCustomPresets) {
              return Text(
                'Your personal goal template • Long press personal presets to edit/delete',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose goals to add to your daily routine',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (_dailyGoals.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.blue[600], size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tip: Your goals are automatically saved as a template and will reset daily',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            }
          },
        ),
        const SizedBox(height: 16),
        _buildPresetsList(),
      ],
    );
  }

  Widget _buildPresetsList() {
    if (_isLoadingPresets) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_presets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No preset goals available',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    // Filter out presets that are already added to daily goals
    final availablePresets = _presets.where((preset) {
      return !_dailyGoals.any((goal) => 
          goal.type == preset.type && goal.title == preset.title);
    }).toList();

    if (availablePresets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'All preset goals have been added!\nCreate a custom goal instead.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    // Show only first 5 presets initially, or all if _showAllPresets is true
    final presetsToShow = _showAllPresets 
        ? availablePresets 
        : availablePresets.take(5).toList();

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: presetsToShow.length,
          itemBuilder: (context, index) {
            final preset = presetsToShow[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildPresetCard(preset),
            );
          },
        ),
        // Show "Load More" button if there are more presets to show
        if (!_showAllPresets && availablePresets.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _showAllPresets = true;
                });
              },
              icon: const Icon(Icons.expand_more_rounded, size: 18),
              label: Text('Load More (${availablePresets.length - 5} remaining)'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
        // Show "Show Less" button if all presets are shown and there are more than 5
        if (_showAllPresets && availablePresets.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _showAllPresets = false;
                });
              },
              icon: const Icon(Icons.expand_less_rounded, size: 18),
              label: const Text('Show Less'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPresetCard(GoalPreset preset) {
    // Since we're filtering out already added presets, we don't need to check isAlreadyAdded here
    return InkWell(
      onTap: () => _addGoalFromPreset(preset),
      onLongPress: preset.isCustom ? () => _showPresetOptions(preset) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: preset.color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: preset.color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: preset.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  preset.icon,
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
                          preset.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      if (preset.isRecommended)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            preset.isCustom ? 'Personal' : 'Recommended',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preset.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Target: ${preset.defaultTargetCount}',
                        style: TextStyle(
                          fontSize: 11,
                          color: preset.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (preset.isCustom) ...[
                        const Spacer(),
                        Icon(
                          Icons.more_vert,
                          color: Colors.grey[400],
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.add_circle_outline,
              color: preset.color,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateGoalProgress(EnhancedDailyGoal goal) async {
    HapticFeedback.lightImpact();
    
    // Handle prayer goals specially
    if (goal.type == GoalType.prayer && goal.title.toLowerCase().contains('prayer')) {
      _showPrayerSelectionBottomSheet(goal);
      return;
    }
    
    try {
      final updatedGoal = await _goalsService.updateGoalProgress(
        goal.id,
        goal.currentCount + 1,
        note: 'Progress updated via dashboard',
      );

      setState(() {
        final index = _dailyGoals.indexWhere((g) => g.id == goal.id);
        if (index != -1) {
          _dailyGoals[index] = updatedGoal;
        }
      });

      // Show completion celebration
      if (updatedGoal.isCompleted && !goal.isCompleted) {
        _showCompletionCelebration(updatedGoal);
      }

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Progress updated! ${updatedGoal.currentCount}/${updatedGoal.targetCount}'),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Failed to update goal progress');
    }
  }

  void _showPrayerSelectionBottomSheet(EnhancedDailyGoal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PrayerSelectionBottomSheet(
        goal: goal,
        onPrayersSelected: (selectedPrayers) async {
          await _updatePrayerProgress(goal, selectedPrayers);
        },
      ),
    );
  }

  Future<void> _updatePrayerProgress(EnhancedDailyGoal goal, Map<String, bool> prayerCompletions) async {
    try {
      final completedCount = prayerCompletions.values.where((completed) => completed).length;
      
      final updatedGoal = await _goalsService.updateGoalProgress(
        goal.id,
        completedCount,
        note: 'Prayer progress updated',
        prayerCompletions: prayerCompletions,
      );

      setState(() {
        final index = _dailyGoals.indexWhere((g) => g.id == goal.id);
        if (index != -1) {
          _dailyGoals[index] = updatedGoal;
        }
      });

      // Show completion celebration
      if (updatedGoal.isCompleted && !goal.isCompleted) {
        _showCompletionCelebration(updatedGoal);
      }

      // Show success feedback
      final completedPrayers = prayerCompletions.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Prayers updated: ${completedPrayers.join(', ')} (${updatedGoal.currentCount}/${updatedGoal.targetCount})'),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Failed to update prayer progress');
    }
  }

  void _showCompletionCelebration(EnhancedDailyGoal goal) {
    HapticFeedback.heavyImpact();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              goal.icon,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              '🎉 Goal Completed!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Congratulations on completing\n"${goal.title}"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'May Allah reward you for your efforts! 🤲',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _addGoalFromPreset(GoalPreset preset) async {
    HapticFeedback.selectionClick();
    
    try {
      final today = DateTime.now();
      final newGoal = preset.toDailyGoal(date: today);
      
      await _goalsService.saveDailyGoal(newGoal);
      
      // Add to user's personal presets if it's not already there
      await _goalsService.addToUserPresets(newGoal);
      
      await _loadTodayGoals();
      await _loadPresets(); // Refresh presets to show changes
      
      // Reset preset view to show first 5 after adding a goal
      // This ensures the UI is refreshed and the added preset is filtered out
      setState(() {
        _showAllPresets = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added "${preset.title}" to your daily goals and personal presets'),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Failed to add goal');
    }
  }

  void _showGoalHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const GoalHistoryScreen(),
      ),
    );
  }

  void _showCreateCustomGoal() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateCustomGoalScreen(),
      ),
    ).then((result) {
      if (result == true) {
        _loadTodayGoals();
      }
    });
  }

  void _showGoalOptions(EnhancedDailyGoal goal) {
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
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: goal.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(goal.icon, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildGoalOption(
              icon: Icons.edit_rounded,
              title: 'Edit Goal',
              onTap: () {
                Navigator.of(context).pop();
                _editGoal(goal);
              },
            ),
            _buildGoalOption(
              icon: Icons.delete_rounded,
              title: 'Delete Goal',
              color: Colors.red,
              onTap: () {
                Navigator.of(context).pop();
                _deleteGoal(goal);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color ?? Colors.grey[700],
              size: 20,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color ?? Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editGoal(EnhancedDailyGoal goal) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateCustomGoalScreen(goalToEdit: goal),
      ),
    ).then((result) async {
      if (result == true) {
        // When a goal is edited, update it in user's personal presets too
        await _goalsService.addToUserPresets(goal);
        await _loadTodayGoals();
        await _loadPresets();
      }
    });
  }

  Future<void> _deleteGoal(EnhancedDailyGoal goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${goal.title}"?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will also remove it from your personal presets template.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Delete goal from storage
        await _goalsService.deleteDailyGoal(goal.id, goal.date);
        
        // Remove from user's personal presets
        await _goalsService.removeFromUserPresets(goal.type.name, goal.title);
        
        // Cancel any notifications for this goal
        await _notificationService.cancelGoalReminders(goal.id);
        
        // Update UI by removing from local list
        setState(() {
          _dailyGoals.removeWhere((g) => g.id == goal.id);
        });
        
        // Refresh presets to reflect changes
        await _loadPresets();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${goal.title}" from daily goals and personal presets'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } catch (e) {
        _showErrorSnackBar('Failed to delete goal');
      }
    }
  }

  void _showPresetOptions(GoalPreset preset) {
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
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: preset.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(preset.icon, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        preset.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Personal preset',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildPresetOption(
              icon: Icons.edit_rounded,
              title: 'Edit Preset',
              onTap: () {
                Navigator.of(context).pop();
                _editPreset(preset);
              },
            ),
            _buildPresetOption(
              icon: Icons.delete_rounded,
              title: 'Delete Preset',
              color: Colors.red,
              onTap: () {
                Navigator.of(context).pop();
                _deletePreset(preset);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color ?? Colors.grey[700],
              size: 20,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color ?? Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editPreset(GoalPreset preset) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateCustomGoalScreen(goalToEdit: null), // Will add preset editing later
      ),
    ).then((result) {
      if (result == true) {
        _loadPresets();
        _loadTodayGoals();
      }
    });
  }

  Future<void> _deletePreset(GoalPreset preset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Preset'),
        content: Text(
          'Are you sure you want to delete "${preset.title}" from your personal presets?\n\nThis will also remove it from your daily goals template.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Delete from user presets
        await _goalsService.deleteUserPreset(preset.id);
        
        // Remove from today's goals if it exists
        final todayGoals = await _goalsService.getTodayGoals();
        final goalToRemove = todayGoals.where((goal) => 
            goal.type == preset.type && goal.title == preset.title).firstOrNull;
        
        if (goalToRemove != null) {
          await _goalsService.deleteDailyGoal(goalToRemove.id, goalToRemove.date);
          await _notificationService.cancelGoalReminders(goalToRemove.id);
        }
        
        // Refresh UI
        await _loadPresets();
        await _loadTodayGoals();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${preset.title}" from your presets'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } catch (e) {
        _showErrorSnackBar('Failed to delete preset');
      }
    }
  }

  // Method removed as templates are now auto-saved
} 