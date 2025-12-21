import '../../domain/entities/todo_entity.dart';

class TodoModel extends TodoEntity {
  TodoModel({
    required super.id,
    required super.userId,
    required super.title,
    super.description,
    required super.date,
    super.isCompleted,
    super.habitId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    try {
      DateTime parseDate(dynamic dateValue) {
        if (dateValue == null) {
          return DateTime.now();
        }
        if (dateValue is String) {
          return DateTime.parse(dateValue);
        }
        if (dateValue is DateTime) {
          return dateValue;
        }
        return DateTime.now();
      }

      return TodoModel(
        id: json['id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString(),
        date: parseDate(json['date']),
        isCompleted: json['is_completed'] == true || json['is_completed'] == 1,
        habitId: json['habit_id']?.toString(),
        createdAt: parseDate(json['created_at']),
        updatedAt: parseDate(json['updated_at']),
      );
    } catch (e) {
      print('Error parsing TodoModel from JSON: $e');
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
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD
      'is_completed': isCompleted,
      'habit_id': habitId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  TodoEntity toEntity() {
    return TodoEntity(
      id: id,
      userId: userId,
      title: title,
      description: description,
      date: date,
      isCompleted: isCompleted,
      habitId: habitId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

