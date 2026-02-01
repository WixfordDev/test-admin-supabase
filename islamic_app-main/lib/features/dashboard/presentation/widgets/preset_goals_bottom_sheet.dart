import 'package:deenhub/core/utils/view_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:deenhub/core/services/database/enhanced_daily_goals_service.dart';
import 'package:uuid/uuid.dart';

class PresetGoalsBottomSheet extends StatefulWidget {
  final List<GoalPreset> presets;
  final Function(GoalPreset) onPresetSelected;

  const PresetGoalsBottomSheet({
    super.key,
    required this.presets,
    required this.onPresetSelected,
  });

  @override
  State<PresetGoalsBottomSheet> createState() => _PresetGoalsBottomSheetState();
}

class _PresetGoalsBottomSheetState extends State<PresetGoalsBottomSheet>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<GoalPreset> _recommendedPresets = [];
  List<GoalPreset> _allPresets = [];
  List<GoalPreset> _customPresets = [];
  final _enhancedDailyGoalsService = EnhancedDailyGoalsService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _categorizePresets();
  }

  void _categorizePresets() {
    _recommendedPresets = widget.presets.where((p) => p.isRecommended).toList();
    _allPresets = widget.presets;
    _customPresets = widget.presets.where((p) => p.isCustom).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
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
                      'Choose Goals',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.blue[600],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[600],
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  tabs: [
                    Tab(text: 'Recommended (${_recommendedPresets.length})'),
                    Tab(text: 'All (${_allPresets.length})'),
                    Tab(text: 'Custom (${_customPresets.length})'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPresetList(_recommendedPresets, scrollController),
                    _buildPresetList(_allPresets, scrollController),
                    _buildCustomPresetList(_customPresets, scrollController),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPresetList(
      List<GoalPreset> presets, ScrollController scrollController) {
    if (presets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No presets available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try creating a custom goal',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: presets.length,
      itemBuilder: (context, index) {
        final preset = presets[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PresetCard(
            preset: preset,
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onPresetSelected(preset);
              Navigator.of(context).pop();
            },
            onEdit: preset.isCustom ? () => _editPreset(preset) : null,
            onDelete: preset.isCustom ? () => _deletePreset(preset) : null,
          ),
        );
      },
    );
  }

  Widget _buildCustomPresetList(
      List<GoalPreset> presets, ScrollController scrollController) {
    return Column(
      children: [
        // Add Custom Preset Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showCreateCustomPresetDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Custom Preset'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),

        // Custom Presets List
        Expanded(
          child: _buildPresetList(presets, scrollController),
        ),
      ],
    );
  }

  void _editPreset(GoalPreset preset) {
    showDialog(
      context: context,
      builder: (context) => EditPresetDialog(
        preset: preset,
        onPresetUpdated: (updatedPreset) async {
          try {
            // Update preset using the service
            await _enhancedDailyGoalsService.updatePreset(updatedPreset);

            // Refresh the presets list
            if (mounted) {
              setState(() {
                // Update the preset in local lists
                final updatedIndex =
                    _customPresets.indexWhere((p) => p.id == updatedPreset.id);
                if (updatedIndex != -1) {
                  _customPresets[updatedIndex] = updatedPreset;
                }

                final allIndex =
                    _allPresets.indexWhere((p) => p.id == updatedPreset.id);
                if (allIndex != -1) {
                  _allPresets[allIndex] = updatedPreset;
                }

                final recommendedIndex = _recommendedPresets
                    .indexWhere((p) => p.id == updatedPreset.id);
                if (recommendedIndex != -1) {
                  _recommendedPresets[recommendedIndex] = updatedPreset;
                }
              });
            }

            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Preset "${updatedPreset.title}" updated successfully'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            // Show error message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error updating preset: $e'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _deletePreset(GoalPreset preset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Preset'),
        content: Text('Are you sure you want to delete "${preset.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              try {
                // Delete preset using the service
                await _enhancedDailyGoalsService.deletePreset(preset.id);

                // Refresh the presets list
                if (mounted) {
                  setState(() {
                    // Remove the preset from local lists
                    _customPresets.removeWhere((p) => p.id == preset.id);
                    _allPresets.removeWhere((p) => p.id == preset.id);
                    _recommendedPresets.removeWhere((p) => p.id == preset.id);
                  });
                }

                // Show success message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Preset "${preset.title}" deleted successfully'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                // Show error message
                if (mounted) {
                  context.showErrorSnackBar('Error deleting preset: $e');
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCreateCustomPresetDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateCustomPresetDialog(
        onPresetCreated: (preset) async {
          try {
            // Add new preset using the service
            await _enhancedDailyGoalsService.savePreset(preset);

            // Refresh the presets list
            if (mounted) {
              setState(() {
                // Add the preset to local lists
                _customPresets.add(preset);
                _allPresets.add(preset);
                if (preset.isRecommended) {
                  _recommendedPresets.add(preset);
                }
              });
            }

            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Preset "${preset.title}" created successfully'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            // Show error message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error creating preset: $e'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        },
      ),
    );
  }
}

class PresetCard extends StatefulWidget {
  final GoalPreset preset;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PresetCard({
    super.key,
    required this.preset,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<PresetCard> createState() => _PresetCardState();
}

class _PresetCardState extends State<PresetCard>
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
      onTap: widget.onTap,
      onLongPress: widget.onEdit != null ? _showOptionsMenu : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.preset.color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.preset.color.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.preset.color.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildPresetIcon(),
              const SizedBox(width: 16),
              Expanded(child: _buildPresetContent()),
              _buildPresetAction(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: widget.preset.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.preset.color.withValues(alpha: 0.3),
        ),
      ),
      child: Center(
        child: Text(
          widget.preset.icon,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  Widget _buildPresetContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.preset.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (widget.preset.isRecommended)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 12,
                      color: Colors.orange[700],
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Recommended',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            if (widget.preset.isCustom)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_rounded,
                      size: 12,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Custom',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          widget.preset.description,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: widget.preset.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Target: ${widget.preset.defaultTargetCount}',
                style: TextStyle(
                  fontSize: 11,
                  color: widget.preset.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _getDifficultyText(widget.preset.difficulty),
                style: TextStyle(
                  fontSize: 11,
                  color: _getDifficultyColor(widget.preset.difficulty),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetAction() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.preset.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.add_circle_outline_rounded,
        color: widget.preset.color,
        size: 24,
      ),
    );
  }

  String _getDifficultyText(GoalDifficulty difficulty) {
    switch (difficulty) {
      case GoalDifficulty.easy:
        return 'Easy';
      case GoalDifficulty.medium:
        return 'Medium';
      case GoalDifficulty.hard:
        return 'Hard';
    }
  }

  Color _getDifficultyColor(GoalDifficulty difficulty) {
    switch (difficulty) {
      case GoalDifficulty.easy:
        return Colors.green[600]!;
      case GoalDifficulty.medium:
        return Colors.orange[600]!;
      case GoalDifficulty.hard:
        return Colors.red[600]!;
    }
  }

  void _showOptionsMenu() {
    if (widget.onEdit == null && widget.onDelete == null) return;

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
            Text(
              widget.preset.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (widget.onEdit != null)
              _buildOptionItem(
                icon: Icons.edit_rounded,
                title: 'Edit Preset',
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onEdit!();
                },
              ),
            if (widget.onDelete != null)
              _buildOptionItem(
                icon: Icons.delete_rounded,
                title: 'Delete Preset',
                color: Colors.red,
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onDelete!();
                },
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
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

// Placeholder dialogs - to be implemented
class EditPresetDialog extends StatefulWidget {
  final GoalPreset preset;
  final Function(GoalPreset) onPresetUpdated;

  const EditPresetDialog({
    super.key,
    required this.preset,
    required this.onPresetUpdated,
  });

  @override
  State<EditPresetDialog> createState() => _EditPresetDialogState();
}

class _EditPresetDialogState extends State<EditPresetDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _targetCountController;
  late GoalType _selectedType;
  late GoalDifficulty _selectedDifficulty;
  late Color _selectedColor;
  late String _selectedIcon;
  bool _isLoading = false;

  final List<String> _availableIcons = [
    '📿',
    '🤲',
    '📖',
    '🕌',
    '⭐',
    '🌙',
    '🌟',
    '💫',
    '✨',
    '🔥',
    '💪',
    '🎯',
    '🏆',
    '👏',
    '❤️',
    '🙏',
    '📚',
    '✅',
    '💡',
    '🌸'
  ];

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.brown,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.preset.title);
    _descriptionController =
        TextEditingController(text: widget.preset.description);
    _targetCountController = TextEditingController(
        text: widget.preset.defaultTargetCount.toString());
    _selectedType = widget.preset.type;
    _selectedDifficulty = widget.preset.difficulty;
    _selectedColor = widget.preset.color;
    _selectedIcon = widget.preset.icon;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleField(),
                      const SizedBox(height: 16),
                      _buildDescriptionField(),
                      const SizedBox(height: 16),
                      _buildTargetCountField(),
                      const SizedBox(height: 16),
                      _buildTypeDropdown(),
                      const SizedBox(height: 16),
                      _buildDifficultyDropdown(),
                      const SizedBox(height: 16),
                      _buildIconSelector(),
                      const SizedBox(height: 16),
                      _buildColorSelector(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _selectedColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _selectedIcon,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Preset',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Customize your goal preset',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Title',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'Enter preset title',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.title),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter preset description',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.description),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTargetCountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Target Count',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _targetCountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter target count',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.numbers),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a target count';
            }
            final count = int.tryParse(value);
            if (count == null || count <= 0) {
              return 'Please enter a valid number greater than 0';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Goal Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<GoalType>(
          value: _selectedType,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.category),
          ),
          items: GoalType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(_getGoalTypeDisplayName(type)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedType = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDifficultyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Difficulty',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<GoalDifficulty>(
          value: _selectedDifficulty,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.trending_up),
          ),
          items: GoalDifficulty.values.map((difficulty) {
            return DropdownMenuItem(
              value: difficulty,
              child: Row(
                children: [
                  Icon(
                    _getDifficultyIcon(difficulty),
                    color: _getDifficultyColor(difficulty),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(_getDifficultyDisplayName(difficulty)),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedDifficulty = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Icon',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableIcons.map((icon) {
              final isSelected = icon == _selectedIcon;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIcon = icon;
                  });
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _selectedColor.withValues(alpha: 0.2)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
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
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _availableColors.map((color) {
              final isSelected = color == _selectedColor;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          isSelected ? Colors.grey[800]! : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _savePreset,
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Save Changes'),
          ),
        ),
      ],
    );
  }

  Future<void> _savePreset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedPreset = widget.preset.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        defaultTargetCount: int.parse(_targetCountController.text),
        type: _selectedType,
        difficulty: _selectedDifficulty,
        color: _selectedColor,
        icon: _selectedIcon,
      );

      widget.onPresetUpdated(updatedPreset);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating preset: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getGoalTypeDisplayName(GoalType type) {
    switch (type) {
      case GoalType.prayer:
        return 'Prayer';
      case GoalType.quranReading:
        return 'Quran Reading';
      case GoalType.quranMemorization:
        return 'Quran Memorization';
      case GoalType.dhikr:
        return 'Dhikr';
      case GoalType.sadaqah:
        return 'Sadaqah';
      case GoalType.fastingMonday:
        return 'Fasting Monday';
      case GoalType.fastingThursday:
        return 'Fasting Thursday';
      case GoalType.surahKahf:
        return 'Surah Kahf';
      case GoalType.duaRecitation:
        return 'Dua Recitation';
      case GoalType.hadithReading:
        return 'Hadith Reading';
      case GoalType.istighfar:
        return 'Istighfar';
      case GoalType.salawat:
        return 'Salawat';
      case GoalType.custom:
        return 'Custom';
    }
  }

  String _getDifficultyDisplayName(GoalDifficulty difficulty) {
    switch (difficulty) {
      case GoalDifficulty.easy:
        return 'Easy';
      case GoalDifficulty.medium:
        return 'Medium';
      case GoalDifficulty.hard:
        return 'Hard';
    }
  }

  IconData _getDifficultyIcon(GoalDifficulty difficulty) {
    switch (difficulty) {
      case GoalDifficulty.easy:
        return Icons.trending_up;
      case GoalDifficulty.medium:
        return Icons.trending_up;
      case GoalDifficulty.hard:
        return Icons.trending_up;
    }
  }

  Color _getDifficultyColor(GoalDifficulty difficulty) {
    switch (difficulty) {
      case GoalDifficulty.easy:
        return Colors.green[600]!;
      case GoalDifficulty.medium:
        return Colors.orange[600]!;
      case GoalDifficulty.hard:
        return Colors.red[600]!;
    }
  }
}

class CreateCustomPresetDialog extends StatefulWidget {
  final Function(GoalPreset) onPresetCreated;

  const CreateCustomPresetDialog({
    super.key,
    required this.onPresetCreated,
  });

  @override
  State<CreateCustomPresetDialog> createState() =>
      _CreateCustomPresetDialogState();
}

class _CreateCustomPresetDialogState extends State<CreateCustomPresetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetCountController = TextEditingController(text: '1');
  GoalType _selectedType = GoalType.custom;
  GoalDifficulty _selectedDifficulty = GoalDifficulty.medium;
  Color _selectedColor = Colors.blue;
  String _selectedIcon = '📿';
  bool _isLoading = false;

  final List<String> _availableIcons = [
    '📿',
    '🤲',
    '📖',
    '🕌',
    '⭐',
    '🌙',
    '🌟',
    '💫',
    '✨',
    '🔥',
    '💪',
    '🎯',
    '🏆',
    '👏',
    '❤️',
    '🙏',
    '📚',
    '✅',
    '💡',
    '🌸'
  ];

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.brown,
    Colors.cyan,
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleField(),
                      const SizedBox(height: 16),
                      _buildDescriptionField(),
                      const SizedBox(height: 16),
                      _buildTargetCountField(),
                      const SizedBox(height: 16),
                      _buildTypeDropdown(),
                      const SizedBox(height: 16),
                      _buildDifficultyDropdown(),
                      const SizedBox(height: 16),
                      _buildIconSelector(),
                      const SizedBox(height: 16),
                      _buildColorSelector(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _selectedColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _selectedIcon,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Custom Preset',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Design your own goal preset',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Title',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'Enter preset title',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.title),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter preset description',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.description),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTargetCountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Target Count',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _targetCountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter target count',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.numbers),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a target count';
            }
            final count = int.tryParse(value);
            if (count == null || count <= 0) {
              return 'Please enter a valid number greater than 0';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Goal Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<GoalType>(
          value: _selectedType,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.category),
          ),
          items: GoalType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(_getGoalTypeDisplayName(type)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedType = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDifficultyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Difficulty',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<GoalDifficulty>(
          value: _selectedDifficulty,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.trending_up),
          ),
          items: GoalDifficulty.values.map((difficulty) {
            return DropdownMenuItem(
              value: difficulty,
              child: Row(
                children: [
                  Icon(
                    _getDifficultyIcon(difficulty),
                    color: _getDifficultyColor(difficulty),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(_getDifficultyDisplayName(difficulty)),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedDifficulty = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Icon',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableIcons.map((icon) {
              final isSelected = icon == _selectedIcon;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIcon = icon;
                  });
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _selectedColor.withValues(alpha: 0.2)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
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
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _availableColors.map((color) {
              final isSelected = color == _selectedColor;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          isSelected ? Colors.grey[800]! : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _createPreset,
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Create Preset'),
          ),
        ),
      ],
    );
  }

  Future<void> _createPreset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final preset = GoalPreset(
        id: const Uuid().v4(),
        type: _selectedType,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        defaultTargetCount: int.parse(_targetCountController.text),
        icon: _selectedIcon,
        color: _selectedColor,
        isCustom: true,
        difficulty: _selectedDifficulty,
        createdAt: DateTime.now(),
      );

      widget.onPresetCreated(preset);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating preset: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getGoalTypeDisplayName(GoalType type) {
    switch (type) {
      case GoalType.prayer:
        return 'Prayer';
      case GoalType.quranReading:
        return 'Quran Reading';
      case GoalType.quranMemorization:
        return 'Quran Memorization';
      case GoalType.dhikr:
        return 'Dhikr';
      case GoalType.sadaqah:
        return 'Sadaqah';
      case GoalType.fastingMonday:
        return 'Fasting Monday';
      case GoalType.fastingThursday:
        return 'Fasting Thursday';
      case GoalType.surahKahf:
        return 'Surah Kahf';
      case GoalType.duaRecitation:
        return 'Dua Recitation';
      case GoalType.hadithReading:
        return 'Hadith Reading';
      case GoalType.istighfar:
        return 'Istighfar';
      case GoalType.salawat:
        return 'Salawat';
      case GoalType.custom:
        return 'Custom';
    }
  }

  String _getDifficultyDisplayName(GoalDifficulty difficulty) {
    switch (difficulty) {
      case GoalDifficulty.easy:
        return 'Easy';
      case GoalDifficulty.medium:
        return 'Medium';
      case GoalDifficulty.hard:
        return 'Hard';
    }
  }

  IconData _getDifficultyIcon(GoalDifficulty difficulty) {
    switch (difficulty) {
      case GoalDifficulty.easy:
        return Icons.trending_up;
      case GoalDifficulty.medium:
        return Icons.trending_up;
      case GoalDifficulty.hard:
        return Icons.trending_up;
    }
  }

  Color _getDifficultyColor(GoalDifficulty difficulty) {
    switch (difficulty) {
      case GoalDifficulty.easy:
        return Colors.green[600]!;
      case GoalDifficulty.medium:
        return Colors.orange[600]!;
      case GoalDifficulty.hard:
        return Colors.red[600]!;
    }
  }
}
