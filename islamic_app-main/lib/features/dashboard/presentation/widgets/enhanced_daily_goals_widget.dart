import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:deenhub/core/services/database/enhanced_daily_goals_service.dart';

class EnhancedDailyGoalsWidget extends StatefulWidget {
  const EnhancedDailyGoalsWidget({super.key});

  @override
  State<EnhancedDailyGoalsWidget> createState() => _EnhancedDailyGoalsWidgetState();
}

class _EnhancedDailyGoalsWidgetState extends State<EnhancedDailyGoalsWidget>
    with TickerProviderStateMixin {
  final EnhancedDailyGoalsService _goalsService = EnhancedDailyGoalsService();
  
  List<EnhancedDailyGoal> _dailyGoals = [];
  bool _isLoading = false;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadTodayGoals();
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

  Future<void> _updateGoalProgress(EnhancedDailyGoal goal) async {
    HapticFeedback.lightImpact();
    
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
    } catch (e) {
      _showErrorSnackBar('Failed to update goal progress');
    }
  }

  void _showCompletionCelebration(EnhancedDailyGoal goal) {
    HapticFeedback.heavyImpact();
    
    showDialog(
      context: context,
      builder: (context) => CompletionCelebrationDialog(goal: goal),
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

  void _showGoalPresets() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GoalPresetsBottomSheet(
        onPresetSelected: (preset) {
          _addGoalFromPreset(preset);
        },
      ),
    );
  }

  Future<void> _addGoalFromPreset(GoalPreset preset) async {
    final today = DateTime.now();
    final newGoal = preset.toDailyGoal(date: today);
    
    await _goalsService.saveDailyGoal(newGoal);
    await _loadTodayGoals();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${preset.title}" to today\'s goals'),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showGoalHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const GoalHistoryScreen(),
      ),
    );
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
              onTap: _showGoalPresets,
              tooltip: 'Add Goal',
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
            'Tap the + button to add spiritual goals\nfor today and start your journey',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showGoalPresets,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Your First Goal'),
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

  Widget _buildGoalsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _dailyGoals.length,
      itemBuilder: (context, index) {
        final goal = _dailyGoals[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: EnhancedGoalCard(
            goal: goal,
            onProgressUpdate: () => _updateGoalProgress(goal),
            onLongPress: () => _showGoalOptions(goal),
          ),
        );
      },
    );
  }

  void _showGoalOptions(EnhancedDailyGoal goal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GoalOptionsBottomSheet(
        goal: goal,
        onEdit: () => _editGoal(goal),
        onDelete: () => _deleteGoal(goal),
        onViewProgress: () => _viewGoalProgress(goal),
      ),
    );
  }

  void _editGoal(EnhancedDailyGoal goal) {
    // Implementation for editing goal
  }

  void _deleteGoal(EnhancedDailyGoal goal) {
    // Implementation for deleting goal
  }

  void _viewGoalProgress(EnhancedDailyGoal goal) {
    // Implementation for viewing detailed progress
  }
}

class EnhancedGoalCard extends StatefulWidget {
  final EnhancedDailyGoal goal;
  final VoidCallback onProgressUpdate;
  final VoidCallback onLongPress;

  const EnhancedGoalCard({
    super.key,
    required this.goal,
    required this.onProgressUpdate,
    required this.onLongPress,
  });

  @override
  State<EnhancedGoalCard> createState() => _EnhancedGoalCardState();
}

class _EnhancedGoalCardState extends State<EnhancedGoalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      onTap: widget.goal.isCompleted ? null : widget.onProgressUpdate,
      onLongPress: widget.onLongPress,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.goal.isCompleted 
                  ? Colors.green[300]! 
                  : Colors.grey[200]!,
              width: widget.goal.isCompleted ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.goal.isCompleted
                    ? Colors.green[100]!.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildGoalIcon(),
              const SizedBox(width: 16),
              Expanded(child: _buildGoalContent()),
              const SizedBox(width: 16),
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: widget.goal.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.goal.color.withValues(alpha: 0.3),
        ),
      ),
      child: Center(
        child: Text(
          widget.goal.icon,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget _buildGoalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.goal.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: widget.goal.isCompleted 
                      ? Colors.green[700] 
                      : Colors.grey[800],
                  decoration: widget.goal.isCompleted 
                      ? TextDecoration.lineThrough 
                      : null,
                ),
              ),
            ),
            if (widget.goal.isCompleted)
              Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 18,
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          widget.goal.description,
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
            Expanded(child: _buildProgressBar()),
            const SizedBox(width: 12),
            Text(
              '${widget.goal.currentCount}/${widget.goal.targetCount}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: widget.goal.isCompleted 
                    ? Colors.green[600] 
                    : Colors.grey[700],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        widthFactor: widget.goal.progress,
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: widget.goal.isCompleted 
                ? Colors.green[500] 
                : widget.goal.color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    if (widget.goal.isCompleted) {
      return Container(
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
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.goal.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.add_rounded,
        color: widget.goal.color,
        size: 20,
      ),
    );
  }
}

class CompletionCelebrationDialog extends StatefulWidget {
  final EnhancedDailyGoal goal;

  const CompletionCelebrationDialog({
    super.key,
    required this.goal,
  });

  @override
  State<CompletionCelebrationDialog> createState() => _CompletionCelebrationDialogState();
}

class _CompletionCelebrationDialogState extends State<CompletionCelebrationDialog>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _confettiController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated confetti
              SizedBox(
                height: 60,
                child: AnimatedBuilder(
                  animation: _confettiController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ConfettiPainter(_confettiController.value),
                      size: const Size(200, 60),
                    );
                  },
                ),
              ),
              
              // Goal icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Text(
                  widget.goal.icon,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
              const SizedBox(height: 16),
              
              // Celebration text
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
                'Congratulations on completing\n"${widget.goal.title}"',
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
              
              // Close button
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
      ),
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final double animationValue;
  
  ConfettiPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42); // Fixed seed for consistent animation
    
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ];

    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final y = baseY + (animationValue * 50) - 25; // Fall animation
      
      final rotation = animationValue * math.pi * 2 * (i % 2 == 0 ? 1 : -1);
      
      paint.color = colors[i % colors.length];
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      
      // Draw small rectangles as confetti
      canvas.drawRect(
        const Rect.fromLTWH(-2, -1, 4, 2),
        paint,
      );
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GoalPresetsBottomSheet extends StatefulWidget {
  final Function(GoalPreset) onPresetSelected;

  const GoalPresetsBottomSheet({
    super.key,
    required this.onPresetSelected,
  });

  @override
  State<GoalPresetsBottomSheet> createState() => _GoalPresetsBottomSheetState();
}

class _GoalPresetsBottomSheetState extends State<GoalPresetsBottomSheet> {
  final EnhancedDailyGoalsService _goalsService = EnhancedDailyGoalsService();
  List<GoalPreset> _presets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    try {
      final presets = await _goalsService.getActivePresets();
      setState(() {
        _presets = presets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Text(
                      'Choose a Goal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        itemCount: _presets.length,
                        itemBuilder: (context, index) {
                          final preset = _presets[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: PresetCard(
                              preset: preset,
                              onTap: () {
                                widget.onPresetSelected(preset);
                                Navigator.of(context).pop();
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class PresetCard extends StatelessWidget {
  final GoalPreset preset;
  final VoidCallback onTap;

  const PresetCard({
    super.key,
    required this.preset,
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
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
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
                            'Recommended',
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
                  Text(
                    'Target: ${preset.defaultTargetCount}',
                    style: TextStyle(
                      fontSize: 11,
                      color: preset.color,
                      fontWeight: FontWeight.w500,
                    ),
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
}

class GoalOptionsBottomSheet extends StatelessWidget {
  final EnhancedDailyGoal goal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewProgress;

  const GoalOptionsBottomSheet({
    super.key,
    required this.goal,
    required this.onEdit,
    required this.onDelete,
    required this.onViewProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            goal.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildOption(
            icon: Icons.visibility_rounded,
            title: 'View Progress',
            onTap: () {
              Navigator.of(context).pop();
              onViewProgress();
            },
          ),
          _buildOption(
            icon: Icons.edit_rounded,
            title: 'Edit Goal',
            onTap: () {
              Navigator.of(context).pop();
              onEdit();
            },
          ),
          _buildOption(
            icon: Icons.delete_rounded,
            title: 'Delete Goal',
            color: Colors.red,
            onTap: () {
              Navigator.of(context).pop();
              onDelete();
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildOption({
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
}

class GoalHistoryScreen extends StatelessWidget {
  const GoalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Goal History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'View your past achievements and progress',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 