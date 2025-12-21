import '../../domain/entities/habit_entity.dart';
import '../../domain/entities/habit_checkin_entity.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/habit_remote_data_source.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitRemoteDataSource remoteDataSource;

  HabitRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<HabitEntity>> getHabits() async {
    final models = await remoteDataSource.getHabits();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<HabitEntity?> getHabitById(String id) async {
    final model = await remoteDataSource.getHabitById(id);
    return model?.toEntity();
  }

  @override
  Future<HabitEntity> createHabit({
    required String title,
    String? description,
    String? unit,
    String? color,
    String? icon,
  }) async {
    final model = await remoteDataSource.createHabit({
      'title': title,
      'description': description,
      'unit': unit,
      'color': color ?? '#3B82F6',
      'icon': icon,
    });
    return model.toEntity();
  }

  @override
  Future<HabitEntity> updateHabit({
    required String id,
    String? title,
    String? description,
    String? unit,
    String? color,
    String? icon,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (unit != null) data['unit'] = unit;
    if (color != null) data['color'] = color;
    if (icon != null) data['icon'] = icon;

    final model = await remoteDataSource.updateHabit(id, data);
    return model.toEntity();
  }

  @override
  Future<void> deleteHabit(String id) async {
    await remoteDataSource.deleteHabit(id);
  }

  @override
  Future<HabitCheckinEntity> checkinHabit({
    required String habitId,
    DateTime? checkinDate,
    double? quantity,
    String? notes,
  }) async {
    final model = await remoteDataSource.checkinHabit({
      'habit_id': habitId,
      'checkin_date': (checkinDate ?? DateTime.now()).toIso8601String().split('T')[0],
      'quantity': quantity ?? 1.0,
      'notes': notes,
    });
    return model.toEntity();
  }

  @override
  Future<List<HabitCheckinEntity>> getHabitCheckins(String habitId) async {
    final models = await remoteDataSource.getHabitCheckins(habitId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<HabitCheckinEntity?> getCheckinByDate({
    required String habitId,
    required DateTime date,
  }) async {
    final model = await remoteDataSource.getCheckinByDate(habitId, date);
    return model?.toEntity();
  }

  @override
  Future<int> getTodayCheckinsCount() async {
    return await remoteDataSource.getTodayCheckinsCount();
  }

  @override
  Future<Map<String, HabitCheckinEntity>> getTodayCheckinsForAllHabits() async {
    final models = await remoteDataSource.getTodayCheckinsForAllHabits();
    return models.map((key, value) => MapEntry(key, value.toEntity()));
  }

  @override
  Future<void> deleteCheckin(String checkinId) async {
    await remoteDataSource.deleteCheckin(checkinId);
  }
}

