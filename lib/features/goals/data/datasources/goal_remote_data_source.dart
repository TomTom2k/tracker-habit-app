import '../../../../core/api/api_client.dart';
import '../../../../core/exceptions/exceptions.dart' as app_exceptions;
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/error_parser.dart';
import '../models/goal_model.dart';
import '../models/sub_goal_model.dart';

abstract class GoalRemoteDataSource {
  Future<List<GoalModel>> getGoals();
  Future<GoalModel?> getGoalById(String goalId);
  Future<GoalModel> createGoal(Map<String, dynamic> data);
  Future<GoalModel> updateGoal(String id, Map<String, dynamic> data);
  Future<void> deleteGoal(String id);
  Future<List<SubGoalModel>> getSubGoals(String goalId);
  Future<SubGoalModel?> getSubGoalById(String subGoalId);
  Future<SubGoalModel> createSubGoal(Map<String, dynamic> data);
  Future<SubGoalModel> updateSubGoal(String id, Map<String, dynamic> data);
  Future<void> deleteSubGoal(String id);
}

class GoalRemoteDataSourceImpl implements GoalRemoteDataSource {
  final ApiClient apiClient;

  GoalRemoteDataSourceImpl({required this.apiClient});

  String get _currentUserId {
    final user = SupabaseService.currentUser;
    if (user == null) {
      throw const app_exceptions.AppAuthException('User not authenticated');
    }
    return user.id;
  }

  @override
  Future<List<GoalModel>> getGoals() async {
    try {
      final response = await apiClient.client
          .from('goals')
          .select()
          .eq('user_id', _currentUserId)
          .order('created_at', ascending: false);
      
      final data = List<Map<String, dynamic>>.from(response);
      return data.map((json) => GoalModel.fromJson(json)).toList();
    } catch (e) {
      throw ErrorParser.parseError(e);
    }
  }

  @override
  Future<GoalModel?> getGoalById(String goalId) async {
    try {
      final response = await apiClient.client
          .from('goals')
          .select()
          .eq('id', goalId)
          .eq('user_id', _currentUserId)
          .maybeSingle();
      
      if (response == null) return null;
      return GoalModel.fromJson(response);
    } catch (e) {
      throw ErrorParser.parseError(e);
    }
  }

  @override
  Future<GoalModel> createGoal(Map<String, dynamic> data) async {
    try {
      final goalData = {
        ...data,
        'user_id': _currentUserId,
      };
      final result = await apiClient.post('goals', goalData);
      return GoalModel.fromJson(result);
    } catch (e) {
      throw ErrorParser.parseError(e);
    }
  }

  @override
  Future<GoalModel> updateGoal(String id, Map<String, dynamic> data) async {
    try {
      final result = await apiClient.update('goals', id, data);
      return GoalModel.fromJson(result);
    } catch (e) {
      throw ErrorParser.parseError(e);
    }
  }

  @override
  Future<void> deleteGoal(String id) async {
    try {
      await apiClient.delete('goals', id);
    } catch (e) {
      throw ErrorParser.parseError(e);
    }
  }

  @override
  Future<List<SubGoalModel>> getSubGoals(String goalId) async {
    try {
      final response = await apiClient.client
          .from('sub_goals')
          .select()
          .eq('goal_id', goalId)
          .order('order', ascending: true)
          .order('created_at', ascending: true);
      
      final data = List<Map<String, dynamic>>.from(response);
      return data.map((json) => SubGoalModel.fromJson(json)).toList();
    } catch (e) {
      throw ErrorParser.parseError(e);
    }
  }

  @override
  Future<SubGoalModel?> getSubGoalById(String subGoalId) async {
    try {
      final response = await apiClient.client
          .from('sub_goals')
          .select()
          .eq('id', subGoalId)
          .maybeSingle();
      
      if (response == null) return null;
      return SubGoalModel.fromJson(response);
    } catch (e) {
      throw ErrorParser.parseError(e);
    }
  }

  @override
  Future<SubGoalModel> createSubGoal(Map<String, dynamic> data) async {
    try {
      final result = await apiClient.post('sub_goals', data);
      return SubGoalModel.fromJson(result);
    } catch (e) {
      throw ErrorParser.parseError(e);
    }
  }

  @override
  Future<SubGoalModel> updateSubGoal(String id, Map<String, dynamic> data) async {
    try {
      final result = await apiClient.update('sub_goals', id, data);
      return SubGoalModel.fromJson(result);
    } catch (e) {
      throw ErrorParser.parseError(e);
    }
  }

  @override
  Future<void> deleteSubGoal(String id) async {
    try {
      await apiClient.delete('sub_goals', id);
    } catch (e) {
      throw ErrorParser.parseError(e);
    }
  }
}

