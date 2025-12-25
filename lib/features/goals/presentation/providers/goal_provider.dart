import 'package:flutter/foundation.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/entities/sub_goal_entity.dart';
import '../../domain/repositories/goal_repository.dart';

class GoalProvider extends ChangeNotifier {
  final GoalRepository goalRepository;

  GoalProvider({required this.goalRepository});

  List<GoalEntity> _goals = [];
  Map<String, List<SubGoalEntity>> _subGoalsMap = {}; // Map goalId -> list of sub-goals
  bool _isLoading = false;
  String? _error;
  GoalCategory? _selectedCategory; // Filter theo category

  List<GoalEntity> get goals {
    if (_selectedCategory == null) {
      return _goals;
    }
    return _goals.where((g) => g.category == _selectedCategory).toList();
  }

  List<GoalEntity> get allGoals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;
  GoalCategory? get selectedCategory => _selectedCategory;

  /// Lấy sub-goals của một goal
  List<SubGoalEntity> getSubGoals(String goalId) {
    return _subGoalsMap[goalId] ?? [];
  }

  /// Tính progress của một goal (số sub-goals đã hoàn thành / tổng số)
  double getGoalProgress(String goalId) {
    final subGoals = getSubGoals(goalId);
    if (subGoals.isEmpty) return 0.0;
    final completed = subGoals.where((sg) => sg.isCompleted).length;
    return completed / subGoals.length;
  }

  /// Load tất cả goals
  Future<void> loadGoals() async {
    _setLoading(true);
    _error = null;
    notifyListeners();

    try {
      final goals = await goalRepository.getGoals();
      _goals = goals;
      
      // Load sub-goals cho tất cả goals
      for (var goal in _goals) {
        await _loadSubGoals(goal.id);
      }
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      print('Error loading goals: $e');
      notifyListeners();
    }
  }

  /// Load sub-goals cho một goal
  Future<void> _loadSubGoals(String goalId) async {
    try {
      final subGoals = await goalRepository.getSubGoals(goalId);
      _subGoalsMap[goalId] = subGoals;
      notifyListeners();
    } catch (e) {
      print('Error loading sub-goals for goal $goalId: $e');
    }
  }

  /// Tạo goal mới
  Future<bool> createGoal({
    required String title,
    String? description,
    required GoalCategory category,
    DateTime? targetDate,
  }) async {
    _error = null;

    try {
      final goal = await goalRepository.createGoal(
        title: title,
        description: description,
        category: category,
        targetDate: targetDate,
      );
      _goals.insert(0, goal);
      _subGoalsMap[goal.id] = [];
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Cập nhật goal
  Future<bool> updateGoal(String goalId, {
    String? title,
    String? description,
    GoalCategory? category,
    DateTime? targetDate,
    bool? isCompleted,
  }) async {
    _error = null;

    try {
      final updatedGoal = await goalRepository.updateGoal(
        goalId,
        title: title,
        description: description,
        category: category,
        targetDate: targetDate,
        isCompleted: isCompleted,
      );
      
      final index = _goals.indexWhere((g) => g.id == goalId);
      if (index != -1) {
        _goals[index] = updatedGoal;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Xóa goal
  Future<bool> deleteGoal(String goalId) async {
    _error = null;

    try {
      await goalRepository.deleteGoal(goalId);
      _goals.removeWhere((g) => g.id == goalId);
      _subGoalsMap.remove(goalId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Tạo sub-goal mới
  Future<bool> createSubGoal({
    required String goalId,
    required String title,
    String? description,
  }) async {
    _error = null;

    try {
      final subGoals = getSubGoals(goalId);
      final order = subGoals.length;
      
      final subGoal = await goalRepository.createSubGoal(
        goalId: goalId,
        title: title,
        description: description,
        order: order,
      );
      
      if (_subGoalsMap.containsKey(goalId)) {
        _subGoalsMap[goalId]!.add(subGoal);
      } else {
        _subGoalsMap[goalId] = [subGoal];
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Cập nhật sub-goal
  Future<bool> updateSubGoal(String subGoalId, {
    String? title,
    String? description,
    bool? isCompleted,
  }) async {
    _error = null;

    try {
      final updatedSubGoal = await goalRepository.updateSubGoal(
        subGoalId,
        title: title,
        description: description,
        isCompleted: isCompleted,
      );
      
      // Tìm và cập nhật trong map
      for (var goalId in _subGoalsMap.keys) {
        final index = _subGoalsMap[goalId]!.indexWhere((sg) => sg.id == subGoalId);
        if (index != -1) {
          _subGoalsMap[goalId]![index] = updatedSubGoal;
          break;
        }
      }
      
      // Nếu sub-goal được toggle, có thể cần cập nhật goal completion
      if (isCompleted != null) {
        // Tìm goal chứa sub-goal này
        for (var goalId in _subGoalsMap.keys) {
          if (_subGoalsMap[goalId]!.any((sg) => sg.id == subGoalId)) {
            // Reload goal để cập nhật completion status
            await updateGoal(goalId, isCompleted: _areAllSubGoalsCompleted(goalId));
            break;
          }
        }
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Toggle sub-goal
  Future<bool> toggleSubGoal(String subGoalId) async {
    _error = null;

    try {
      final updatedSubGoal = await goalRepository.toggleSubGoal(subGoalId);
      
      // Tìm và cập nhật trong map
      String? goalId;
      for (var gId in _subGoalsMap.keys) {
        final index = _subGoalsMap[gId]!.indexWhere((sg) => sg.id == subGoalId);
        if (index != -1) {
          _subGoalsMap[gId]![index] = updatedSubGoal;
          goalId = gId;
          break;
        }
      }
      
      // Cập nhật goal completion status nếu tất cả sub-goals đã hoàn thành
      if (goalId != null) {
        final allCompleted = _areAllSubGoalsCompleted(goalId);
        await updateGoal(goalId, isCompleted: allCompleted);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Xóa sub-goal
  Future<bool> deleteSubGoal(String subGoalId) async {
    _error = null;

    try {
      await goalRepository.deleteSubGoal(subGoalId);
      
      // Xóa khỏi map
      for (var goalId in _subGoalsMap.keys) {
        _subGoalsMap[goalId]!.removeWhere((sg) => sg.id == subGoalId);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Kiểm tra xem tất cả sub-goals đã hoàn thành chưa
  bool _areAllSubGoalsCompleted(String goalId) {
    final subGoals = getSubGoals(goalId);
    if (subGoals.isEmpty) return false;
    return subGoals.every((sg) => sg.isCompleted);
  }

  /// Set filter category
  void setCategoryFilter(GoalCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

