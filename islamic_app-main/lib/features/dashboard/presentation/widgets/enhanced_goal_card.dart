import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:deenhub/core/services/database/enhanced_daily_goals_service.dart';

class EnhancedGoalCard extends StatefulWidget {
  final EnhancedDailyGoal goal;
  final VoidCallback onProgressUpdate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EnhancedGoalCard({
    super.key,
    required this.goal,
    required this.onProgressUpdate,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<EnhancedGoalCard> createState() => _EnhancedGoalCardState();
}

class _EnhancedGoalCardState extends State<EnhancedGoalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

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
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _scaleController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _scaleController.reverse();
        if (!widget.goal.isCompleted) {
          widget.onProgressUpdate();
        }
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _scaleController.reverse();
      },
      onLongPress: _showOptionsBottomSheet,
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
                  : widget.goal.color.withValues(alpha: 0.3),
              width: widget.goal.isCompleted ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.goal.isCompleted
                    ? Colors.green[100]!.withValues(alpha: 0.5)
                    : widget.goal.color.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildGoalIcon(),
                  const SizedBox(width: 16),
                  Expanded(child: _buildGoalHeader()),
                  _buildActionButton(),
                ],
              ),
              const SizedBox(height: 12),
              _buildProgressSection(),
              if (widget.goal.progressEntries.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildProgressIndicators(),
              ],
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              widget.goal.icon,
              style: const TextStyle(fontSize: 20),
            ),
            if (widget.goal.isCompleted)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green[600],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalHeader() {
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
            if (widget.goal.isStreak && widget.goal.streakCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 12,
                      color: Colors.orange[700],
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${widget.goal.streakCount}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
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
      ],
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

  Widget _buildProgressSection() {
    return Column(
      children: [
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
                    : widget.goal.color,
              ),
            ),
          ],
        ),
        if (widget.goal.currentCount > 0 && !widget.goal.isCompleted) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.trending_up,
                size: 12,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Text(
                '${((widget.goal.progress) * 100).toInt()}% complete',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
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
            gradient: LinearGradient(
              colors: widget.goal.isCompleted 
                  ? [Colors.green[400]!, Colors.green[600]!]
                  : [widget.goal.color.withValues(alpha: 0.7), widget.goal.color],
            ),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicators() {
    return Row(
      children: [
        ...List.generate(widget.goal.targetCount, (index) {
          final isCompleted = index < widget.goal.currentCount;
          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: isCompleted 
                  ? (widget.goal.isCompleted ? Colors.green[500] : widget.goal.color)
                  : Colors.grey[300],
              shape: BoxShape.circle,
            ),
          );
        }).take(10), // Limit to 10 indicators
        if (widget.goal.targetCount > 10)
          Text(
            '+${widget.goal.targetCount - 10}',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
      ],
    );
  }

  void _showOptionsBottomSheet() {
    HapticFeedback.mediumImpact();
    
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
              widget.goal.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildOptionItem(
              icon: Icons.edit_rounded,
              title: 'Edit Goal',
              onTap: () {
                Navigator.of(context).pop();
                widget.onEdit();
              },
            ),
            _buildOptionItem(
              icon: Icons.bar_chart_rounded,
              title: 'View Progress',
              onTap: () {
                Navigator.of(context).pop();
                _showProgressDetails();
              },
            ),
            _buildOptionItem(
              icon: Icons.delete_rounded,
              title: 'Delete Goal',
              color: Colors.red,
              onTap: () {
                Navigator.of(context).pop();
                widget.onDelete();
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

  void _showProgressDetails() {
    showDialog(
      context: context,
      builder: (context) => ProgressDetailsDialog(goal: widget.goal),
    );
  }
}

class ProgressDetailsDialog extends StatelessWidget {
  final EnhancedDailyGoal goal;

  const ProgressDetailsDialog({
    super.key,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: goal.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    goal.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),
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
                      Text(
                        goal.description,
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
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Progress'),
                      Text(
                        '${goal.currentCount}/${goal.targetCount}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: goal.progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(goal.color),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(goal.progress * 100).toInt()}% Complete',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (goal.progressEntries.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...goal.progressEntries.take(3).map((entry) => ListTile(
                leading: Icon(
                  Icons.check_circle,
                  color: goal.color,
                  size: 20,
                ),
                title: Text(
                  '+${entry.incrementValue}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  _formatTime(entry.timestamp),
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: entry.note != null
                    ? Tooltip(
                        message: entry.note!,
                        child: Icon(
                          Icons.note,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                      )
                    : null,
              )),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: goal.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
} 