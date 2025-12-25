import '../entities/goal_entity.dart';
import '../entities/sub_goal_entity.dart';

abstract class GoalRepository {
  /// Lấy tất cả goals của user
  Future<List<GoalEntity>> getGoals();

  /// Lấy goal theo ID
  Future<GoalEntity?> getGoalById(String goalId);

  /// Tạo goal mới
  Future<GoalEntity> createGoal({
    required String title,
    String? description,
    required GoalCategory category,
    DateTime? targetDate,
  });

  /// Cập nhật goal
  Future<GoalEntity> updateGoal(String goalId, {
    String? title,
    String? description,
    GoalCategory? category,
    DateTime? targetDate,
    bool? isCompleted,
  });

  /// Xóa goal
  Future<void> deleteGoal(String goalId);

  /// Lấy tất cả sub-goals của một goal
  Future<List<SubGoalEntity>> getSubGoals(String goalId);

  /// Tạo sub-goal mới
  Future<SubGoalEntity> createSubGoal({
    required String goalId,
    required String title,
    String? description,
    int? order,
  });

  /// Cập nhật sub-goal
  Future<SubGoalEntity> updateSubGoal(String subGoalId, {
    String? title,
    String? description,
    bool? isCompleted,
    int? order,
  });

  /// Xóa sub-goal
  Future<void> deleteSubGoal(String subGoalId);

  /// Toggle trạng thái completed của sub-goal
  Future<SubGoalEntity> toggleSubGoal(String subGoalId);
}

