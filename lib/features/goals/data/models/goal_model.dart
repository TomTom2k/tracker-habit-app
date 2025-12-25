import '../../domain/entities/goal_entity.dart';

class GoalModel extends GoalEntity {
  GoalModel({
    required super.id,
    required super.userId,
    required super.title,
    super.description,
    required super.category,
    super.targetDate,
    super.isCompleted,
    required super.createdAt,
    required super.updatedAt,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    try {
      DateTime? parseDate(dynamic dateValue) {
        if (dateValue == null) return null;
        if (dateValue is String) {
          return DateTime.parse(dateValue);
        }
        if (dateValue is DateTime) {
          return dateValue;
        }
        return null;
      }

      return GoalModel(
        id: json['id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString(),
        category: GoalCategoryStatic.fromString(
          json['category']?.toString() ?? 'other',
        ),
        targetDate: parseDate(json['target_date']),
        isCompleted: json['is_completed'] == true || json['is_completed'] == 1,
        createdAt: parseDate(json['created_at']) ?? DateTime.now(),
        updatedAt: parseDate(json['updated_at']) ?? DateTime.now(),
      );
    } catch (e) {
      print('Error parsing GoalModel from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category.value,
      'target_date': targetDate?.toIso8601String().split('T')[0],
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  GoalEntity toEntity() {
    return GoalEntity(
      id: id,
      userId: userId,
      title: title,
      description: description,
      category: category,
      targetDate: targetDate,
      isCompleted: isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

