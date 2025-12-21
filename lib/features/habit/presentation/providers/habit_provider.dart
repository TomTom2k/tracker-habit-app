import 'package:flutter/foundation.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/entities/habit_checkin_entity.dart';
import '../../domain/repositories/habit_repository.dart';

class HabitProvider extends ChangeNotifier {
  final HabitRepository habitRepository;

  HabitProvider({required this.habitRepository});

  List<HabitEntity> _habits = [];
  bool _isLoading = false;
  String? _error;
  int _todayCheckinsCount = 0;
  Map<String, bool> _checkedInHabits = {}; // Map habit_id -> isCheckedInToday
  Map<String, List<HabitCheckinEntity>> _habitCheckins = {}; // Map habit_id -> list of checkins

  List<HabitEntity> get habits => _habits;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get todayCheckinsCount => _todayCheckinsCount;
  int get totalHabits => _habits.length;
  
  /// Kiểm tra habit đã check-in hôm nay chưa
  bool isCheckedInToday(String habitId) {
    return _checkedInHabits[habitId] ?? false;
  }

  /// Lấy danh sách check-ins của một habit
  List<HabitCheckinEntity> getHabitCheckins(String habitId) {
    return _habitCheckins[habitId] ?? [];
  }

  /// Load check-ins cho một habit cụ thể
  Future<void> loadHabitCheckins(String habitId) async {
    try {
      final checkins = await habitRepository.getHabitCheckins(habitId);
      _habitCheckins[habitId] = checkins;
      notifyListeners();
    } catch (e) {
      print('Error loading checkins for habit $habitId: $e');
    }
  }

  Future<void> loadHabits() async {
    _setLoading(true);
    _error = null;
    notifyListeners(); // Notify để UI biết đang loading

    try {
      // Load tất cả habits của user
      print('Loading all habits for user...');
      final habits = await habitRepository.getHabits();
      print('Loaded ${habits.length} habits');
      
      // Load tất cả check-ins hôm nay
      print('Loading today check-ins...');
      final checkinsMap = await habitRepository.getTodayCheckinsForAllHabits();
      print('Found ${checkinsMap.length} check-ins today');
      
      // Cập nhật habits và check-in status
      _habits = habits;
      
      // Tạo map checkedInHabits: true nếu đã check-in hôm nay, false nếu chưa
      _checkedInHabits = {};
      for (var habit in _habits) {
        _checkedInHabits[habit.id] = checkinsMap.containsKey(habit.id);
        print('Habit ${habit.title}: checkedIn=${_checkedInHabits[habit.id]}');
      }
      
      _setLoading(false);
      notifyListeners(); // Notify sau khi load xong
      
      // Load check-ins cho tất cả habits (lazy, không block UI)
      _loadAllHabitCheckins();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      print('Error loading habits: $e'); // Debug log
      notifyListeners(); // Notify để hiển thị error
    }
  }

  Future<void> loadTodayCheckinsCount() async {
    try {
      _todayCheckinsCount = await habitRepository.getTodayCheckinsCount();
      notifyListeners();
    } catch (e) {
      // Silent fail for stats
    }
  }

  Future<bool> createHabit({
    required String title,
    String? description,
    String? unit,
    String? color,
    String? icon,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final habit = await habitRepository.createHabit(
        title: title,
        description: description,
        unit: unit,
        color: color,
        icon: icon,
      );
      _habits.insert(0, habit);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateHabit({
    required String id,
    String? title,
    String? description,
    String? unit,
    String? color,
    String? icon,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final updatedHabit = await habitRepository.updateHabit(
        id: id,
        title: title,
        description: description,
        unit: unit,
        color: color,
        icon: icon,
      );
      
      final index = _habits.indexWhere((h) => h.id == id);
      if (index != -1) {
        _habits[index] = updatedHabit;
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteHabit(String id) async {
    _setLoading(true);
    _error = null;

    try {
      await habitRepository.deleteHabit(id);
      _habits.removeWhere((h) => h.id == id);
      _setLoading(false);
      await loadTodayCheckinsCount();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> checkinHabit({
    required String habitId,
    DateTime? checkinDate,
    double? quantity,
    String? notes,
  }) async {
    _error = null;

    try {
      final checkin = await habitRepository.checkinHabit(
        habitId: habitId,
        checkinDate: checkinDate,
        quantity: quantity,
        notes: notes,
      );
      
      // Cập nhật checkedInHabits map
      final date = checkinDate ?? DateTime.now();
      final dateOnly = DateTime(date.year, date.month, date.day);
      final today = DateTime.now();
      final todayOnly = DateTime(today.year, today.month, today.day);
      
      if (dateOnly == todayOnly) {
        _checkedInHabits[habitId] = true;
      }
      
      // Cập nhật checkins list
      if (_habitCheckins.containsKey(habitId)) {
        _habitCheckins[habitId]!.add(checkin);
      } else {
        _habitCheckins[habitId] = [checkin];
      }
      
      await loadTodayCheckinsCount();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Toggle check-in cho một ngày cụ thể
  Future<bool> toggleCheckin({
    required String habitId,
    required DateTime date,
  }) async {
    _error = null;

    try {
      // Kiểm tra xem đã có check-in cho ngày này chưa
      final existingCheckin = await habitRepository.getCheckinByDate(
        habitId: habitId,
        date: date,
      );

      if (existingCheckin != null) {
        // Xóa check-in
        await habitRepository.deleteCheckin(existingCheckin.id);
        
        // Cập nhật local state
        if (_habitCheckins.containsKey(habitId)) {
          _habitCheckins[habitId]!.removeWhere((c) => c.id == existingCheckin.id);
        }
        
        // Cập nhật checkedInHabits nếu là hôm nay
        final today = DateTime.now();
        final todayOnly = DateTime(today.year, today.month, today.day);
        final dateOnly = DateTime(date.year, date.month, date.day);
        if (dateOnly == todayOnly) {
          _checkedInHabits[habitId] = false;
        }
      } else {
        // Tạo check-in mới
        await checkinHabit(
          habitId: habitId,
          checkinDate: date,
        );
      }
      
      await loadTodayCheckinsCount();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Load check-ins cho tất cả habits (chạy bất đồng bộ, không block UI)
  Future<void> _loadAllHabitCheckins() async {
    for (var habit in _habits) {
      try {
        final checkins = await habitRepository.getHabitCheckins(habit.id);
        _habitCheckins[habit.id] = checkins;
      } catch (e) {
        print('Error loading checkins for habit ${habit.id}: $e');
        // Bỏ qua lỗi, tiếp tục với habit khác
      }
    }
    notifyListeners(); // Notify sau khi load xong tất cả
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

