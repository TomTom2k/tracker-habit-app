import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goal_provider.dart';
import '../../domain/entities/goal_entity.dart';
import 'sub_goal_item.dart';
import 'create_sub_goal_dialog.dart';

class GoalCard extends StatefulWidget {
  final GoalEntity goal;

  const GoalCard({super.key, required this.goal});

  @override
  State<GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, provider, child) {
        final subGoals = provider.getSubGoals(widget.goal.id);
        final progress = provider.getGoalProgress(widget.goal.id);
        final completedCount = subGoals.where((sg) => sg.isCompleted).length;
        final totalCount = subGoals.length;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Header with check button and title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Large check button
                    GestureDetector(
                      onTap: () => _toggleGoal(context, provider),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.goal.isCompleted
                              ? _getCategoryColor(widget.goal.category)
                              : Colors.transparent,
                          border: Border.all(
                            color: widget.goal.isCompleted
                                ? _getCategoryColor(widget.goal.category)
                                : Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                            width: 2.5,
                          ),
                        ),
                        child: widget.goal.isCompleted
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 32,
                              )
                            : Icon(
                                _getCategoryIcon(widget.goal.category),
                                color: _getCategoryColor(widget.goal.category).withOpacity(0.5),
                                size: 24,
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title and metadata
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.goal.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  decoration: widget.goal.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: widget.goal.isCompleted
                                      ? Theme.of(context).colorScheme.secondary
                                      : null,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              // Category badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(widget.goal.category).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getCategoryIcon(widget.goal.category),
                                      size: 14,
                                      color: _getCategoryColor(widget.goal.category),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.goal.category.displayName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: _getCategoryColor(widget.goal.category),
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              // Target date
                              if (widget.goal.targetDate != null)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: Theme.of(context).colorScheme.secondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDate(widget.goal.targetDate!),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context).colorScheme.secondary,
                                          ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Expand/collapse button
                    IconButton(
                      icon: Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                // Description
                if (widget.goal.description != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.goal.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                          height: 1.4,
                        ),
                  ),
                ],

                // Progress bar (only show if there are sub-goals)
                if (totalCount > 0) ...[
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                          Text(
                            '$completedCount/$totalCount',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getCategoryColor(widget.goal.category),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getCategoryColor(widget.goal.category),
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ],

                // Sub-goals list (expanded)
                if (_isExpanded) ...[
                  const SizedBox(height: 20),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  ),
                  const SizedBox(height: 16),
                  // Sub-goals header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sub-goals',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (subGoals.isNotEmpty)
                        Text(
                          '$completedCount/$totalCount',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Sub-goals list
                  if (subGoals.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.checklist_outlined,
                              size: 40,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.4),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No sub-goals yet',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Break down your goal into smaller steps',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.7),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...subGoals.map((subGoal) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SubGoalItem(subGoal: subGoal),
                        )),
                  // Add sub-goal button
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _showCreateSubGoalDialog(context),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add Sub-goal'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  // Delete action
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _confirmDelete(context),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete Goal'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }


  Color _getCategoryColor(GoalCategory category) {
    switch (category) {
      case GoalCategory.health:
        return Colors.red;
      case GoalCategory.career:
        return Colors.blue;
      case GoalCategory.finance:
        return Colors.green;
      case GoalCategory.education:
        return Colors.purple;
      case GoalCategory.personal:
        return Colors.orange;
      case GoalCategory.relationship:
        return Colors.pink;
      case GoalCategory.other:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(GoalCategory category) {
    switch (category) {
      case GoalCategory.health:
        return Icons.favorite;
      case GoalCategory.career:
        return Icons.work;
      case GoalCategory.finance:
        return Icons.account_balance;
      case GoalCategory.education:
        return Icons.school;
      case GoalCategory.personal:
        return Icons.person;
      case GoalCategory.relationship:
        return Icons.people;
      case GoalCategory.other:
        return Icons.category;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final difference = target.difference(today).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 0 && difference <= 7) {
      return 'In $difference days';
    } else if (difference < 0 && difference >= -7) {
      return '${-difference} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  Future<void> _showCreateSubGoalDialog(BuildContext context) async {
    final provider = Provider.of<GoalProvider>(context, listen: false);
    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (context) => CreateSubGoalDialog(goalId: widget.goal.id),
    );

    if (result != null && mounted) {
      final success = await provider.createSubGoal(
        goalId: widget.goal.id,
        title: result['title']!,
        description: result['description'],
      );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to create sub-goal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleGoal(BuildContext context, GoalProvider provider) async {
    await provider.updateGoal(
      widget.goal.id,
      isCompleted: !widget.goal.isCompleted,
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = Provider.of<GoalProvider>(context, listen: false);
      await provider.deleteGoal(widget.goal.id);
    }
  }
}

