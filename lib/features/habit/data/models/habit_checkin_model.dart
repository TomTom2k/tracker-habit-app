import '../../domain/entities/habit_checkin_entity.dart';

class HabitCheckinModel extends HabitCheckinEntity {
  HabitCheckinModel({
    required super.id,
    required super.habitId,
    required super.userId,
    required super.checkinDate,
    super.quantity,
    super.notes,
    required super.createdAt,
  });

  factory HabitCheckinModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse dates với error handling
      DateTime parseDate(dynamic dateValue) {
        if (dateValue == null) {
          return DateTime.now();
        }
        if (dateValue is String) {
          // Nếu là date string (YYYY-MM-DD), parse đúng format
          if (dateValue.length == 10) {
            return DateTime.parse('${dateValue}T00:00:00');
          }
          return DateTime.parse(dateValue);
        }
        if (dateValue is DateTime) {
          return dateValue;
        }
        return DateTime.now();
      }

      return HabitCheckinModel(
        id: json['id']?.toString() ?? '',
        habitId: json['habit_id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        checkinDate: parseDate(json['checkin_date']),
        quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
        notes: json['notes']?.toString(),
        createdAt: parseDate(json['created_at']),
      );
    } catch (e) {
      print('Error parsing HabitCheckinModel from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habit_id': habitId,
      'user_id': userId,
      'checkin_date': checkinDate.toIso8601String().split('T')[0], // YYYY-MM-DD
      'quantity': quantity,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  HabitCheckinEntity toEntity() {
    return HabitCheckinEntity(
      id: id,
      habitId: habitId,
      userId: userId,
      checkinDate: checkinDate,
      quantity: quantity,
      notes: notes,
      createdAt: createdAt,
    );
  }
}

