import '../../../../features/habit/domain/entities/habit_entity.dart';
import 'todo_entity.dart';

/// TodoItem Entity - Unified entity cho cả habit todos và custom todos
/// Dùng để hiển thị trong UI
class TodoItemEntity {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final bool isCompleted;
  final TodoItemType type; // Habit hoặc Custom
  final String? habitId; // Nếu là habit todo
  final HabitEntity? habit; // Thông tin habit nếu có
  final DateTime createdAt;
  final DateTime updatedAt;

  TodoItemEntity({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    required this.isCompleted,
    required this.type,
    this.habitId,
    this.habit,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor từ TodoEntity
  factory TodoItemEntity.fromTodo(TodoEntity todo) {
    return TodoItemEntity(
      id: todo.id,
      title: todo.title,
      description: todo.description,
      date: todo.date,
      isCompleted: todo.isCompleted,
      type: TodoItemType.custom,
      habitId: todo.habitId,
      createdAt: todo.createdAt,
      updatedAt: todo.updatedAt,
    );
  }

  /// Factory constructor từ HabitEntity (cho habit todos)
  factory TodoItemEntity.fromHabit({
    required HabitEntity habit,
    required DateTime date,
    required bool isCompleted,
  }) {
    return TodoItemEntity(
      id: 'habit_${habit.id}_${date.toIso8601String().split('T')[0]}',
      title: habit.title,
      description: habit.description,
      date: date,
      isCompleted: isCompleted,
      type: TodoItemType.habit,
      habitId: habit.id,
      habit: habit,
      createdAt: habit.createdAt,
      updatedAt: habit.updatedAt,
    );
  }
}

enum TodoItemType {
  habit, // Todo từ habit
  custom, // Todo tự tạo
}

