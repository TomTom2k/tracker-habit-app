import '../entities/pomodoro_settings_entity.dart';

abstract class PomodoroRepository {
  /// Lấy cài đặt Pomodoro
  Future<PomodoroSettingsEntity> getSettings();

  /// Lưu cài đặt Pomodoro
  Future<void> saveSettings(PomodoroSettingsEntity settings);
}

