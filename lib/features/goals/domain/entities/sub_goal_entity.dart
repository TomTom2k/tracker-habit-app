/// SubGoal Entity - Domain layer
/// Represents a sub-goal within a goal
class SubGoalEntity {
  final String id;
  final String goalId;
  final String title;
  final String? description;
  final bool isCompleted;
  final int order; // Thứ tự hiển thị
  final DateTime createdAt;
  final DateTime updatedAt;

  SubGoalEntity({
    required this.id,
    required this.goalId,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.order = 0,
    required this.createdAt,
    required this.updatedAt,
  });
}

