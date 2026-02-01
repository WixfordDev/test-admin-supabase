import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:deenhub/core/services/database/enhanced_daily_goals_service.dart';

class CreateCustomGoalScreen extends StatefulWidget {
  final EnhancedDailyGoal? goalToEdit;
  
  const CreateCustomGoalScreen({super.key, this.goalToEdit});

  @override
  State<CreateCustomGoalScreen> createState() => _CreateCustomGoalScreenState();
}

class _CreateCustomGoalScreenState extends State<CreateCustomGoalScreen> 
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController();
  
  final EnhancedDailyGoalsService _goalsService = EnhancedDailyGoalsService();
  
  String _selectedIcon = '⭐';
  Color _selectedColor = const Color(0xFF2196F3);
  GoalDifficulty _selectedDifficulty = GoalDifficulty.medium;
  bool _enableNotifications = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  List<int> _reminderDays = [1, 2, 3, 4, 5, 6, 7];
  bool _isLoading = false;
  
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final List<String> _availableIcons = [
    '⭐', '🎯', '💎', '🔥', '⚡', '🌟', '✨', '💫',
    '🕌', '📖', '📿', '🤲', '🌙', '📜', '📚', '🕊️',
    '💝', '🌸', '🌱', '🏃', '💪', '🧘', '❤️', '🙏',
    '⚖️', '🎨', '🎵', '📝', '💡', '🔮', '🎪', '🎭',
  ];

  final List<Color> _availableColors = [
    const Color(0xFF2196F3), // Blue
    const Color(0xFF4CAF50), // Green
    const Color(0xFFFF9800), // Orange
    const Color(0xFF9C27B0), // Purple
    const Color(0xFFE91E63), // Pink
    const Color(0xFF795548), // Brown
    const Color(0xFF607D8B), // Blue Grey
    const Color(0xFF3F51B5), // Indigo
    const Color(0xFFFF5722), // Deep Orange
    const Color(0xFF009688), // Teal
    const Color(0xFF673AB7), // Deep Purple
    const Color(0xFFF44336), // Red
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadGoalData();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _slideController.forward();
  }

  void _loadGoalData() {
    if (widget.goalToEdit != null) {
      final goal = widget.goalToEdit!;
      _titleController.text = goal.title;
      _descriptionController.text = goal.description;
      _targetController.text = goal.targetCount.toString();
      _selectedIcon = goal.icon;
      _selectedColor = goal.color;
      _selectedDifficulty = goal.difficulty;
      
      if (goal.notificationSettings != null) {
        _enableNotifications = goal.notificationSettings!.isEnabled;
        _reminderTime = goal.notificationSettings!.reminderTime;
        _reminderDays = goal.notificationSettings!.reminderDays;
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goalToEdit != null ? 'Edit Goal' : 'Create Custom Goal'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveGoal,
            child: _isLoading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGoalPreview(),
                const SizedBox(height: 24),
                _buildBasicInfo(),
                const SizedBox(height: 24),
                _buildCustomization(),
                const SizedBox(height: 24),
                _buildNotificationSettings(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalPreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _selectedColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _selectedColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _selectedColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                _selectedIcon,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titleController.text.isEmpty ? 'Goal Title' : _titleController.text,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _selectedColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _descriptionController.text.isEmpty 
                      ? 'Goal description will appear here' 
                      : _descriptionController.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Target: ${_targetController.text.isEmpty ? '0' : _targetController.text}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _selectedColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Goal Title *',
            hintText: 'e.g., Read 10 Pages of Islamic Book',
            prefixIcon: const Icon(Icons.title_rounded),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a goal title';
            }
            if (value.trim().length < 3) {
              return 'Title must be at least 3 characters';
            }
            return null;
          },
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Description *',
            hintText: 'Describe what this goal involves',
            prefixIcon: const Icon(Icons.description_rounded),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLines: 2,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _targetController,
          decoration: InputDecoration(
            labelText: 'Target Count *',
            hintText: 'How many times to complete this goal',
            prefixIcon: const Icon(Icons.numbers_rounded),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a target count';
            }
            final count = int.tryParse(value);
            if (count == null || count <= 0) {
              return 'Please enter a valid number greater than 0';
            }
            if (count > 1000) {
              return 'Target count cannot exceed 1000';
            }
            return null;
          },
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildCustomization() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customization',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Icon Selection
        const Text(
          'Choose an Icon',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _availableIcons.length,
            itemBuilder: (context, index) {
              final icon = _availableIcons[index];
              final isSelected = icon == _selectedIcon;
              
              return GestureDetector(
                onTap: () => setState(() => _selectedIcon = icon),
                child: Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _selectedColor.withValues(alpha: 0.2) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? _selectedColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        
        // Color Selection
        const Text(
          'Choose a Color',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableColors.map((color) {
            final isSelected = color == _selectedColor;
            
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = color),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        
        // Difficulty Selection
        const Text(
          'Difficulty Level',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: GoalDifficulty.values.map((difficulty) {
            final isSelected = difficulty == _selectedDifficulty;
            
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDifficulty = difficulty),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? _selectedColor.withValues(alpha: 0.1) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? _selectedColor : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getDifficultyIcon(difficulty),
                        color: isSelected ? _selectedColor : Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getDifficultyName(difficulty),
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? _selectedColor : Colors.grey[600],
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Notification Reminders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Switch(
              value: _enableNotifications,
              onChanged: (value) => setState(() => _enableNotifications = value),
              activeColor: _selectedColor,
            ),
          ],
        ),
        if (_enableNotifications) ...[
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.access_time_rounded, color: _selectedColor),
            title: const Text('Reminder Time'),
            subtitle: Text(_formatTimeOfDay(_reminderTime)),
            onTap: _selectReminderTime,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          const Text(
            'Reminder Days',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _buildDayChips(),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildDayChips() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return List.generate(7, (index) {
      final dayNumber = index + 1;
      final isSelected = _reminderDays.contains(dayNumber);
      
      return FilterChip(
        label: Text(days[index]),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (selected) {
              _reminderDays.add(dayNumber);
            } else {
              _reminderDays.remove(dayNumber);
            }
          });
        },
        selectedColor: _selectedColor.withValues(alpha: 0.2),
        checkmarkColor: _selectedColor,
      );
    });
  }

  IconData _getDifficultyIcon(GoalDifficulty difficulty) {
    switch (difficulty) {
      case GoalDifficulty.easy:
        return Icons.sentiment_satisfied_rounded;
      case GoalDifficulty.medium:
        return Icons.sentiment_neutral_rounded;
      case GoalDifficulty.hard:
        return Icons.sentiment_very_dissatisfied_rounded;
    }
  }

  String _getDifficultyName(GoalDifficulty difficulty) {
    switch (difficulty) {
      case GoalDifficulty.easy:
        return 'Easy';
      case GoalDifficulty.medium:
        return 'Medium';
      case GoalDifficulty.hard:
        return 'Hard';
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_reminderDays.isEmpty && _enableNotifications) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one reminder day'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final notificationSettings = _enableNotifications
          ? NotificationSettings(
              isEnabled: true,
              reminderTime: _reminderTime,
              reminderDays: _reminderDays,
              customMessage: 'Time to work on: ${_titleController.text.trim()}',
            )
          : null;

      if (widget.goalToEdit != null) {
        // Edit existing goal
        final updatedGoal = widget.goalToEdit!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          targetCount: int.parse(_targetController.text),
          icon: _selectedIcon,
          color: _selectedColor,
          difficulty: _selectedDifficulty,
          notificationSettings: notificationSettings,
        );
        
        await _goalsService.saveDailyGoal(updatedGoal);
        
        // Also update it in user's personal presets so changes persist daily
        await _goalsService.addToUserPresets(updatedGoal);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Goal updated and saved to your personal template!'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        // Create new goal
        final newGoal = EnhancedDailyGoal(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: GoalType.custom,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          targetCount: int.parse(_targetController.text),
          date: DateTime.now(),
          icon: _selectedIcon,
          color: _selectedColor,
          difficulty: _selectedDifficulty,
          createdAt: DateTime.now(),
          notificationSettings: notificationSettings,
        );
        
        await _goalsService.saveDailyGoal(newGoal);
        
        // Automatically add new custom goals to user's personal presets
        await _goalsService.addToUserPresets(newGoal);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Custom goal created and added to your personal template!'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }

      Navigator.of(context).pop(true); // Return true to indicate success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving goal: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
} 