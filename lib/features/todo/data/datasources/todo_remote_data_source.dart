import '../../../../core/api/api_client.dart';
import '../../../../core/exceptions/exceptions.dart' as app_exceptions;
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/error_parser.dart';
import '../models/todo_model.dart';

abstract class TodoRemoteDataSource {
  Future<List<TodoModel>> getTodosByDate(DateTime date);
  Future<TodoModel> createTodo(Map<String, dynamic> data);
  Future<TodoModel> updateTodo(String id, Map<String, dynamic> data);
  Future<void> deleteTodo(String id);
}

class TodoRemoteDataSourceImpl implements TodoRemoteDataSource {
  final ApiClient apiClient;

  TodoRemoteDataSourceImpl({required this.apiClient});

  String get _currentUserId {
    final user = SupabaseService.currentUser;
    if (user == null) {
      throw const app_exceptions.AppAuthException('User not authenticated');
    }
    return user.id;
  }

  @override
  Future<List<TodoModel>> getTodosByDate(DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0]; // YYYY-MM-DD
      
      final response = await apiClient.client
          .from('todos')
          .select()
          .eq('user_id', _currentUserId)
          .eq('date', dateStr)
          .order('created_at', ascending: true);
      
      final data = List<Map<String, dynamic>>.from(response);
      return data.map((json) => TodoModel.fromJson(json)).toList();
    } catch (e) {
      throw ErrorParser.parseError(e);
    }
  }

  @override
  Future<TodoModel> createTodo(Map<String, dynamic> data) async {
    try {
      final todoData = {
        ...data,
        'user_id': _currentUserId,
      };
      final result = await apiClient.post('todos', todoData);
      return TodoModel.fromJson(result);
    } catch (e) {
      throw ErrorParser.parseError(e);
    }
  }

  @override
  Future<TodoModel> updateTodo(String id, Map<String, dynamic> data) async {
    try {
      final result = await apiClient.update('todos', id, data);
      return TodoModel.fromJson(result);
    } catch (e) {
      throw ErrorParser.parseError(e);
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    try {
      await apiClient.delete('todos', id);
    } catch (e) {
      throw ErrorParser.parseError(e);
    }
  }
}

