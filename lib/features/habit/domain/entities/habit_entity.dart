class HabitEntity {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? unit; // Đơn vị/tần suất: "2l", "10 cái chống đẩy", etc.
  final String color; // Màu sắc cho habit (hex code)
  final String? icon; // Icon name cho habit
  final DateTime createdAt;
  final DateTime updatedAt;

  HabitEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.unit,
    this.color = '#3B82F6',
    this.icon,
    required this.createdAt,
    required this.updatedAt,
  });
}



