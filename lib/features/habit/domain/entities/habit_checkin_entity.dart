class HabitCheckinEntity {
  final String id;
  final String habitId;
  final String userId;
  final DateTime checkinDate;
  final double quantity; // Số lượng (ví dụ: 2 lít, 10 cái)
  final String? notes; // Ghi chú thêm
  final DateTime createdAt;

  HabitCheckinEntity({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.checkinDate,
    this.quantity = 1.0,
    this.notes,
    required this.createdAt,
  });
}



