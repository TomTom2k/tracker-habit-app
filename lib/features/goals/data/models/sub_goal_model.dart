import '../../domain/entities/sub_goal_entity.dart';

class SubGoalModel extends SubGoalEntity {
  SubGoalModel({
    required super.id,
    required super.goalId,
    required super.title,
    super.description,
    super.isCompleted,
    super.order,
    required super.createdAt,
    required super.updatedAt,
  });

  factory SubGoalModel.fromJson(Map<String, dynamic> json) {
    try {
      DateTime? parseDate(dynamic dateValue) {
        if (dateValue == null) return DateTime.now();
        if (dateValue is String) {
          return DateTime.parse(dateValue);
        }
        if (dateValue is DateTime) {
          return dateValue;
        }
        return DateTime.now();
      }

      return SubGoalModel(
        id: json['id']?.toString() ?? '',
        goalId: json['goal_id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString(),
        isCompleted: json['is_completed'] == true || json['is_completed'] == 1,
        order: json['order'] is int ? json['order'] : (json['order'] as num?)?.toInt() ?? 0,
        createdAt: parseDate(json['created_at']) ?? DateTime.now(),
        updatedAt: parseDate(json['updated_at']) ?? DateTime.now(),
      );
    } catch (e) {
      print('Error parsing SubGoalModel from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goal_id': goalId,
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'order': order,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  SubGoalEntity toEntity() {
    return SubGoalEntity(
      id: id,
      goalId: goalId,
      title: title,
      description: description,
      isCompleted: isCompleted,
      order: order,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

