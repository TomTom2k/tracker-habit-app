import '../../domain/entities/habit_entity.dart';

class HabitModel extends HabitEntity {
  HabitModel({
    required super.id,
    required super.userId,
    required super.title,
    super.description,
    super.unit,
    super.color,
    super.icon,
    required super.createdAt,
    required super.updatedAt,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse dates với error handling
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

      return HabitModel(
        id: json['id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString(),
        unit: json['unit']?.toString(),
        color: json['color']?.toString() ?? '#3B82F6',
        icon: json['icon']?.toString(),
        createdAt: parseDate(json['created_at']),
        updatedAt: parseDate(json['updated_at']),
      );
    } catch (e) {
      print('Error parsing HabitModel from JSON: $e');
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
      'unit': unit,
      'color': color,
      'icon': icon,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  HabitEntity toEntity() {
    return HabitEntity(
      id: id,
      userId: userId,
      title: title,
      description: description,
      unit: unit,
      color: color,
      icon: icon,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

