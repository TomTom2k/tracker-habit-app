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
          child: InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      // Category icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(widget.goal.category)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getCategoryIcon(widget.goal.category),
                          color: _getCategoryColor(widget.goal.category),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Title and category
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.goal.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    decoration: widget.goal.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  widget.goal.category.displayName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: _getCategoryColor(
                                            widget.goal.category),
                                      ),
                                ),
                                if (widget.goal.targetDate != null) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.calendar_today,
                                    size: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDate(widget.goal.targetDate!),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Expand/collapse icon
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ],
                  ),

                  // Description
                  if (widget.goal.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.goal.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                  ],

                  // Progress bar
                  if (totalCount > 0) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getCategoryColor(widget.goal.category),
                            ),
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$completedCount/$totalCount',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                      ],
                    ),
                  ],

                  // Sub-goals list (expanded)
                  if (_isExpanded) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    // Sub-goals
                    if (subGoals.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.checklist_outlined,
                                size: 32,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Chưa có mục tiêu con',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...subGoals.map((subGoal) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: SubGoalItem(subGoal: subGoal),
                          )),
                    // Add sub-goal button
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _showCreateSubGoalDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Thêm mục tiêu con'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                      ),
                    ),
                    // Actions
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => _confirmDelete(context),
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Xóa'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
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
      return 'Hôm nay';
    } else if (difference == 1) {
      return 'Ngày mai';
    } else if (difference == -1) {
      return 'Hôm qua';
    } else if (difference > 0 && difference <= 7) {
      return '$difference ngày nữa';
    } else if (difference < 0 && difference >= -7) {
      return '${-difference} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
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

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa mục tiêu'),
        content: const Text('Bạn có chắc chắn muốn xóa mục tiêu này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Xóa'),
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

