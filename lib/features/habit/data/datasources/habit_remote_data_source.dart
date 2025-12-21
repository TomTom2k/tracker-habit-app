import '../../../../core/api/api_client.dart';
import '../../../../core/exceptions/exceptions.dart' as app_exceptions;
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/error_parser.dart';
import '../models/habit_model.dart';
import '../models/habit_checkin_model.dart';

abstract class HabitRemoteDataSource {
  Future<List<HabitModel>> getHabits();
  Future<HabitModel?> getHabitById(String id);
  Future<HabitModel> createHabit(Map<String, dynamic> data);
  Future<HabitModel> updateHabit(String id, Map<String, dynamic> data);
  Future<void> deleteHabit(String id);
  Future<HabitCheckinModel> checkinHabit(Map<String, dynamic> data);
  Future<List<HabitCheckinModel>> getHabitCheckins(String habitId);
  Future<HabitCheckinModel?> getCheckinByDate(String habitId, DateTime date);
  Future<int> getTodayCheckinsCount();
  Future<Map<String, HabitCheckinModel>> getTodayCheckinsForAllHabits();
  Future<void> deleteCheckin(String checkinId);
}

class HabitRemoteDataSourceImpl implements HabitRemoteDataSource {
  final ApiClient apiClient;

  HabitRemoteDataSourceImpl({required this.apiClient});

  String get _currentUserId {
    final user = SupabaseService.currentUser;
    if (user == null) {
      throw const app_exceptions.AppAuthException('User not authenticated');
    }
    return user.id;
  }

  @override
  Future<List<HabitModel>> getHabits() async {
    try {
      final userId = _currentUserId;
      print('Loading habits for user: $userId'); // Debug log
      
      // Sử dụng Supabase client trực tiếp để tránh lỗi type
      final response = await apiClient.client
          .from('habits')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      final data = List<Map<String, dynamic>>.from(response);
      print('Loaded ${data.length} habits from database'); // Debug log
      
      // Parse từng habit với error handling
      final List<HabitModel> habits = [];
      for (var json in data) {
        try {
          print('Parsing habit: ${json['id']} - ${json['title']}');
          final habit = HabitModel.fromJson(json);
          habits.add(habit);
        } catch (e) {
          print('Error parsing habit ${json['id']}: $e');
          print('Habit data: $json');
          // Bỏ qua habit lỗi, tiếp tục với habit khác
          continue;
        }
      }
      
      print('Successfully parsed ${habits.length} habits'); // Debug log
      return habits;
    } catch (e) {
      print('Error in getHabits: $e'); // Debug log
      print('Error stack trace: ${e.toString()}');
      throw ErrorParser.parseError(e);
    }
  }

  @override
  Future<HabitModel?> getHabitById(String id) async {
    try {
      final data = await apiClient.getById('habits', id);
      if (data == null) return null;
      return HabitModel.fromJson(data);
    } catch (e) {
      throw ErrorParser.parseError(e);
    }
  }

  @override
  Future<HabitModel> createHabit(Map<String, dynamic> data) async {
    try {
      // Thêm user_id vào data
      final habitData = {
        ...data,
        'user_id': _currentUserId,
      };
      final result = await apiClient.post('habits', habitData);
      return HabitModel.fromJson(result);
    } catch (e) {
      throw ErrorParser.parseError(e);
    }
  }

  @override
  Future<HabitModel> updateHabit(String id, Map<String, dynamic> data) async {
    try {
      final result = await apiClient.update('habits', id, data);
      return HabitModel.fromJson(result);
    } catch (e) {
      throw ErrorParser.parseError(e);
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    try {
      await apiClient.delete('habits', id);
    } catch (e) {
      throw ErrorParser.parseError(e);
    }
  }

  @override
  Future<HabitCheckinModel> checkinHabit(Map<String, dynamic> data) async {
    try {
      // Thêm user_id vào data
      final checkinData = {
        ...data,
        'user_id': _currentUserId,
      };
      final result = await apiClient.post('habit_checkins', checkinData);
      return HabitCheckinModel.fromJson(result);
    } catch (e) {
      throw ErrorParser.parseError(e);
    }
  }

  @override
  Future<List<HabitCheckinModel>> getHabitCheckins(String habitId) async {
    try {
      // Sử dụng Supabase client trực tiếp
      final response = await apiClient.client
          .from('habit_checkins')
          .select()
          .eq('habit_id', habitId)
          .order('checkin_date', ascending: false);
      
      final data = List<Map<String, dynamic>>.from(response);
      return data.map((json) => HabitCheckinModel.fromJson(json)).toList();
    } catch (e) {
      throw ErrorParser.parseError(e);
    }
  }

  @override
  Future<HabitCheckinModel?> getCheckinByDate(String habitId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0]; // YYYY-MM-DD
      
      // Query với cả habit_id và checkin_date
      final data = await apiClient.client
          .from('habit_checkins')
          .select()
          .eq('habit_id', habitId)
          .eq('checkin_date', dateStr)
          .maybeSingle();
      
      if (data == null) return null;
      return HabitCheckinModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      // Nếu không tìm thấy, return null thay vì throw error
      if (e.toString().contains('PGRST116')) {
        return null;
      }
      throw ErrorParser.parseError(e);
    }
  }

  @override
  Future<int> getTodayCheckinsCount() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      // Sử dụng Supabase client trực tiếp
      final response = await apiClient.client
          .from('habit_checkins')
          .select()
          .eq('user_id', _currentUserId);
      
      final data = List<Map<String, dynamic>>.from(response);
      
      // Filter by today's date
      final todayCheckins = data.where((json) {
        final checkinDate = json['checkin_date']?.toString() ?? '';
        final checkinDateOnly = checkinDate.split('T')[0].split(' ')[0];
        return checkinDateOnly == today;
      }).toList();
      
      return todayCheckins.length;
    } catch (e) {
      throw ErrorParser.parseError(e);
    }
  }

  /// Lấy tất cả check-ins hôm nay cho tất cả habits của user
  Future<Map<String, HabitCheckinModel>> getTodayCheckinsForAllHabits() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      print('Loading today check-ins for date: $today');
      
      // Sử dụng Supabase client trực tiếp để lấy tất cả check-ins của user
      final response = await apiClient.client
          .from('habit_checkins')
          .select()
          .eq('user_id', _currentUserId);
      
      final data = List<Map<String, dynamic>>.from(response);
      print('Loaded ${data.length} total check-ins from database');
      
      // Filter theo ngày hôm nay và convert thành Map với key là habit_id
      final Map<String, HabitCheckinModel> checkinsMap = {};
      for (var json in data) {
        try {
          final checkinDate = json['checkin_date']?.toString() ?? '';
          // So sánh date (có thể là YYYY-MM-DD hoặc full datetime)
          final checkinDateOnly = checkinDate.split('T')[0].split(' ')[0];
          
          if (checkinDateOnly == today) {
            print('Found check-in for habit: ${json['habit_id']}');
            final checkin = HabitCheckinModel.fromJson(json);
            checkinsMap[checkin.habitId] = checkin;
          }
        } catch (e) {
          print('Error parsing check-in ${json['id']}: $e');
          print('Check-in data: $json');
          // Bỏ qua check-in lỗi, tiếp tục với check-in khác
          continue;
        }
      }
      
      print('Successfully parsed ${checkinsMap.length} check-ins for today');
      return checkinsMap;
    } catch (e) {
      print('Error loading today checkins: $e');
      print('Error stack trace: ${e.toString()}');
      return {};
    }
  }

  @override
  Future<void> deleteCheckin(String checkinId) async {
    try {
      await apiClient.delete('habit_checkins', checkinId);
    } catch (e) {
      throw ErrorParser.parseError(e);
    }
  }
}

