import '../entities/habit_entity.dart';
import '../entities/habit_checkin_entity.dart';

abstract class HabitRepository {
  /// Lấy danh sách tất cả habits của user
  Future<List<HabitEntity>> getHabits();

  /// Lấy habit theo ID
  Future<HabitEntity?> getHabitById(String id);

  /// Tạo habit mới
  Future<HabitEntity> createHabit({
    required String title,
    String? description,
    String? unit,
    String? color,
    String? icon,
  });

  /// Cập nhật habit
  Future<HabitEntity> updateHabit({
    required String id,
    String? title,
    String? description,
    String? unit,
    String? color,
    String? icon,
  });

  /// Xóa habit
  Future<void> deleteHabit(String id);

  /// Check-in habit (tạo checkin record)
  Future<HabitCheckinEntity> checkinHabit({
    required String habitId,
    DateTime? checkinDate,
    double? quantity,
    String? notes,
  });

  /// Lấy danh sách checkins của một habit
  Future<List<HabitCheckinEntity>> getHabitCheckins(String habitId);

  /// Lấy checkin của habit trong một ngày cụ thể
  Future<HabitCheckinEntity?> getCheckinByDate({
    required String habitId,
    required DateTime date,
  });

  /// Lấy số lượng checkins hôm nay
  Future<int> getTodayCheckinsCount();

  /// Lấy tất cả check-ins hôm nay cho tất cả habits (trả về Map với key là habit_id)
  Future<Map<String, HabitCheckinEntity>> getTodayCheckinsForAllHabits();
}

