import 'package:flutter/foundation.dart';
import '../../domain/entities/todo_item_entity.dart';
import '../../domain/repositories/todo_repository.dart';

class TodoProvider extends ChangeNotifier {
  final TodoRepository todoRepository;

  TodoProvider({required this.todoRepository});

  List<TodoItemEntity> _todos = [];
  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateTime.now();

  List<TodoItemEntity> get todos => _todos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;

  /// Load todos cho ngày được chọn
  Future<void> loadTodos(DateTime date) async {
    _setLoading(true);
    _error = null;
    _selectedDate = date;
    notifyListeners();

    try {
      final todos = await todoRepository.getTodosByDate(date);
      _todos = todos;
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      print('Error loading todos: $e');
    }
  }

  /// Tạo todo mới
  Future<bool> createTodo({
    required String title,
    String? description,
    required DateTime date,
  }) async {
    _error = null;

    try {
      await todoRepository.createTodo(
        title: title,
        description: description,
        date: date,
      );
      
      // Reload todos sau khi tạo
      await loadTodos(_selectedDate);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Toggle todo (check/uncheck)
  Future<bool> toggleTodo(String id, TodoItemType type) async {
    _error = null;

    try {
      if (type == TodoItemType.habit) {
        // Toggle habit todo thông qua check-in
        final todo = _todos.firstWhere((t) => t.id == id);
        await todoRepository.toggleHabitTodo(todo.habitId!, _selectedDate);
      } else {
        // Toggle custom todo
        await todoRepository.toggleTodo(id);
      }
      
      // Reload todos sau khi toggle
      await loadTodos(_selectedDate);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Xóa todo
  Future<bool> deleteTodo(String id) async {
    _error = null;

    try {
      await todoRepository.deleteTodo(id);
      
      // Reload todos sau khi xóa
      await loadTodos(_selectedDate);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Thay đổi ngày được chọn
  Future<void> selectDate(DateTime date) async {
    await loadTodos(date);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

