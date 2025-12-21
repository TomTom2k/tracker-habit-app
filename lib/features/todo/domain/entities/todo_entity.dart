/// Todo Entity - Domain layer
/// Represents a todo item in the domain
class TodoEntity {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime date; // Ngày của todo
  final bool isCompleted;
  final String? habitId; // Nếu todo này là từ habit, có habitId
  final DateTime createdAt;
  final DateTime updatedAt;

  TodoEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.date,
    this.isCompleted = false,
    this.habitId,
    required this.createdAt,
    required this.updatedAt,
  });
}

