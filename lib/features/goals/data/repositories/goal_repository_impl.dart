import '../../domain/entities/goal_entity.dart';
import '../../domain/entities/sub_goal_entity.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/goal_remote_data_source.dart';

class GoalRepositoryImpl implements GoalRepository {
  final GoalRemoteDataSource remoteDataSource;

  GoalRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<GoalEntity>> getGoals() async {
    try {
      final models = await remoteDataSource.getGoals();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<GoalEntity?> getGoalById(String goalId) async {
    try {
      final model = await remoteDataSource.getGoalById(goalId);
      return model?.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<GoalEntity> createGoal({
    required String title,
    String? description,
    required GoalCategory category,
    DateTime? targetDate,
  }) async {
    try {
      final data = {
        'title': title,
        if (description != null) 'description': description,
        'category': category.value,
        if (targetDate != null) 'target_date': targetDate.toIso8601String().split('T')[0],
      };
      final model = await remoteDataSource.createGoal(data);
      return model.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<GoalEntity> updateGoal(String goalId, {
    String? title,
    String? description,
    GoalCategory? category,
    DateTime? targetDate,
    bool? isCompleted,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (category != null) data['category'] = category.value;
      if (targetDate != null) {
        data['target_date'] = targetDate.toIso8601String().split('T')[0];
      } else if (targetDate == null && data.containsKey('target_date')) {
        data['target_date'] = null;
      }
      if (isCompleted != null) data['is_completed'] = isCompleted;
      
      final model = await remoteDataSource.updateGoal(goalId, data);
      return model.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    try {
      await remoteDataSource.deleteGoal(goalId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SubGoalEntity>> getSubGoals(String goalId) async {
    try {
      final models = await remoteDataSource.getSubGoals(goalId);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SubGoalEntity> createSubGoal({
    required String goalId,
    required String title,
    String? description,
    int? order,
  }) async {
    try {
      final data = {
        'goal_id': goalId,
        'title': title,
        if (description != null) 'description': description,
        'order': order ?? 0,
      };
      final model = await remoteDataSource.createSubGoal(data);
      return model.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SubGoalEntity> updateSubGoal(String subGoalId, {
    String? title,
    String? description,
    bool? isCompleted,
    int? order,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (isCompleted != null) data['is_completed'] = isCompleted;
      if (order != null) data['order'] = order;
      
      final model = await remoteDataSource.updateSubGoal(subGoalId, data);
      return model.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteSubGoal(String subGoalId) async {
    try {
      await remoteDataSource.deleteSubGoal(subGoalId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SubGoalEntity> toggleSubGoal(String subGoalId) async {
    try {
      // Lấy sub-goal hiện tại để toggle
      final subGoalModel = await remoteDataSource.getSubGoalById(subGoalId);
      if (subGoalModel == null) {
        throw Exception('Sub-goal not found');
      }
      final updated = await updateSubGoal(
        subGoalId,
        isCompleted: !subGoalModel.isCompleted,
      );
      return updated;
    } catch (e) {
      rethrow;
    }
  }
}

