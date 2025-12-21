import '../../domain/entities/pomodoro_settings_entity.dart';

class PomodoroSettingsModel extends PomodoroSettingsEntity {
  PomodoroSettingsModel({
    super.pomodoroWorkDuration,
    super.pomodoroShortBreak,
    super.pomodoroLongBreak,
    super.pomodorosUntilLongBreak,
  });

  factory PomodoroSettingsModel.fromJson(Map<String, dynamic> json) {
    return PomodoroSettingsModel(
      pomodoroWorkDuration: json['pomodoro_work_duration'] as int? ?? 25,
      pomodoroShortBreak: json['pomodoro_short_break'] as int? ?? 5,
      pomodoroLongBreak: json['pomodoro_long_break'] as int? ?? 15,
      pomodorosUntilLongBreak: json['pomodoros_until_long_break'] as int? ?? 4,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pomodoro_work_duration': pomodoroWorkDuration,
      'pomodoro_short_break': pomodoroShortBreak,
      'pomodoro_long_break': pomodoroLongBreak,
      'pomodoros_until_long_break': pomodorosUntilLongBreak,
    };
  }

  PomodoroSettingsEntity toEntity() {
    return PomodoroSettingsEntity(
      pomodoroWorkDuration: pomodoroWorkDuration,
      pomodoroShortBreak: pomodoroShortBreak,
      pomodoroLongBreak: pomodoroLongBreak,
      pomodorosUntilLongBreak: pomodorosUntilLongBreak,
    );
  }
}

