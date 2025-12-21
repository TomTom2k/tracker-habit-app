import 'package:flutter/material.dart';
import '../../domain/entities/todo_item_entity.dart';

class TodoItemWidget extends StatelessWidget {
  final TodoItemEntity todo;
  final VoidCallback onToggle;
  final VoidCallback? onDelete;

  const TodoItemWidget({
    super.key,
    required this.todo,
    required this.onToggle,
    this.onDelete,
  });

  Color _getColorFromHex(String? hexColor) {
    if (hexColor == null) return Colors.blue;
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  IconData _getIconFromName(String? iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'water_drop':
        return Icons.water_drop;
      case 'book':
        return Icons.book;
      case 'local_drink':
        return Icons.local_drink;
      default:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHabit = todo.type == TodoItemType.habit;
    final habitColor = isHabit && todo.habit != null
        ? _getColorFromHex(todo.habit!.color)
        : Colors.blue;
    final habitIcon = isHabit && todo.habit != null
        ? _getIconFromName(todo.habit!.icon)
        : Icons.check_circle_outline;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: todo.isCompleted
                    ? habitColor
                    : Colors.transparent,
                border: Border.all(
                  color: todo.isCompleted
                      ? habitColor
                      : Theme.of(context).colorScheme.secondary,
                  width: 2,
                ),
              ),
              child: todo.isCompleted
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          // Icon (chỉ hiển thị cho habit)
          if (isHabit) ...[
            Icon(
              habitIcon,
              color: habitColor,
              size: 20,
            ),
            const SizedBox(width: 8),
          ],
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        decoration: todo.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: todo.isCompleted
                            ? Theme.of(context).colorScheme.secondary
                            : null,
                      ),
                ),
                if (todo.description != null && todo.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    todo.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                  ),
                ],
                if (isHabit && todo.habit?.unit != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    todo.habit!.unit!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: habitColor,
                        ),
                  ),
                ],
              ],
            ),
          ),
          // Badge cho habit
          if (isHabit)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: habitColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Habit',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: habitColor,
                ),
              ),
            ),
          // Delete button (chỉ cho custom todos)
          if (!isHabit && onDelete != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.red,
              ),
              onPressed: onDelete,
            ),
          ],
        ],
      ),
    );
  }
}

