import '../entities/todo_entity.dart';
import '../entities/todo_item_entity.dart';

abstract class TodoRepository {
  /// Lấy tất cả todos của user cho một ngày cụ thể
  /// Bao gồm cả habit todos và custom todos
  Future<List<TodoItemEntity>> getTodosByDate(DateTime date);

  /// Tạo todo mới
  Future<TodoEntity> createTodo({
    required String title,
    String? description,
    required DateTime date,
  });

  /// Cập nhật todo (chủ yếu là toggle completed)
  Future<TodoEntity> updateTodo({
    required String id,
    bool? isCompleted,
    String? title,
    String? description,
  });

  /// Xóa todo
  Future<void> deleteTodo(String id);

  /// Toggle completed status của custom todo
  /// Note: Habit todos được toggle thông qua habit check-in
  Future<TodoEntity> toggleTodo(String id);
  
  /// Toggle habit todo (check-in hoặc xóa check-in)
  Future<void> toggleHabitTodo(String habitId, DateTime date);
}

