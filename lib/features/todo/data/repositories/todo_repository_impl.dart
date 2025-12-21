import '../../domain/entities/todo_entity.dart';
import '../../domain/entities/todo_item_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../../../habit/domain/repositories/habit_repository.dart';
import '../datasources/todo_remote_data_source.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource remoteDataSource;
  final HabitRepository habitRepository;

  TodoRepositoryImpl({
    required this.remoteDataSource,
    required this.habitRepository,
  });

  @override
  Future<List<TodoItemEntity>> getTodosByDate(DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final List<TodoItemEntity> todos = [];

    // 1. Lấy custom todos từ database
    final customTodos = await remoteDataSource.getTodosByDate(dateOnly);
    todos.addAll(customTodos.map((todo) => TodoItemEntity.fromTodo(todo.toEntity())));

    // 2. Lấy habits và tạo habit todos
    final habits = await habitRepository.getHabits();
    
    // 3. Lấy check-in cho ngày cụ thể
    for (var habit in habits) {
      final checkin = await habitRepository.getCheckinByDate(
        habitId: habit.id,
        date: dateOnly,
      );
      
      final isCompleted = checkin != null;
      
      todos.add(TodoItemEntity.fromHabit(
        habit: habit,
        date: dateOnly,
        isCompleted: isCompleted,
      ));
    }

    // Sắp xếp: habits trước, custom todos sau, và theo thời gian tạo
    todos.sort((a, b) {
      // Habits trước
      if (a.type != b.type) {
        return a.type == TodoItemType.habit ? -1 : 1;
      }
      // Sau đó sắp xếp theo thời gian tạo
      return a.createdAt.compareTo(b.createdAt);
    });

    return todos;
  }

  @override
  Future<TodoEntity> createTodo({
    required String title,
    String? description,
    required DateTime date,
  }) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final model = await remoteDataSource.createTodo({
      'title': title,
      'description': description,
      'date': dateOnly.toIso8601String().split('T')[0],
      'is_completed': false,
    });
    return model.toEntity();
  }

  @override
  Future<TodoEntity> updateTodo({
    required String id,
    bool? isCompleted,
    String? title,
    String? description,
  }) async {
    final data = <String, dynamic>{};
    if (isCompleted != null) data['is_completed'] = isCompleted;
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;

    final model = await remoteDataSource.updateTodo(id, data);
    return model.toEntity();
  }

  @override
  Future<void> deleteTodo(String id) async {
    await remoteDataSource.deleteTodo(id);
  }

  @override
  Future<TodoEntity> toggleTodo(String id) async {
    // Note: Method này chỉ dùng cho custom todos
    // Habit todos sẽ được toggle thông qua habit check-in logic
    final todos = await remoteDataSource.getTodosByDate(DateTime.now());
    final todo = todos.firstWhere((t) => t.id == id);
    
    return await updateTodo(
      id: id,
      isCompleted: !todo.isCompleted,
    );
  }

  @override
  Future<void> toggleHabitTodo(String habitId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    // Kiểm tra xem đã có check-in chưa
    final existingCheckin = await habitRepository.getCheckinByDate(
      habitId: habitId,
      date: dateOnly,
    );
    
    if (existingCheckin != null) {
      // Xóa check-in (uncheck)
      await habitRepository.deleteCheckin(existingCheckin.id);
    } else {
      // Tạo check-in (check)
      await habitRepository.checkinHabit(
        habitId: habitId,
        checkinDate: dateOnly,
      );
    }
  }
}

