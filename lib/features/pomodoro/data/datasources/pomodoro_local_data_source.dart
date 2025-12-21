import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/pomodoro_settings_model.dart';

abstract class PomodoroLocalDataSource {
  Future<PomodoroSettingsModel> getSettings();
  Future<void> saveSettings(PomodoroSettingsModel settings);
}

class PomodoroLocalDataSourceImpl implements PomodoroLocalDataSource {
  static const String _settingsKey = 'pomodoro_settings';

  @override
  Future<PomodoroSettingsModel> getSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        final json = jsonDecode(settingsJson) as Map<String, dynamic>;
        return PomodoroSettingsModel.fromJson(json);
      }
      
      // Return default settings nếu chưa có
      return PomodoroSettingsModel();
    } catch (e) {
      print('Error loading pomodoro settings: $e');
      // Return default settings nếu có lỗi
      return PomodoroSettingsModel();
    }
  }

  @override
  Future<void> saveSettings(PomodoroSettingsModel settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(settings.toJson());
      await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      print('Error saving pomodoro settings: $e');
      rethrow;
    }
  }
}

