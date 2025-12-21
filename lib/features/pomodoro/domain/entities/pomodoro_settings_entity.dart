/// Pomodoro Settings Entity
/// Chứa cài đặt thời gian cho Pomodoro
class PomodoroSettingsEntity {
  // Pomodoro mode settings (theo phương pháp chuẩn)
  final int pomodoroWorkDuration; // 25 phút (mặc định)
  final int pomodoroShortBreak; // 5 phút (mặc định)
  final int pomodoroLongBreak; // 15 phút (mặc định)
  final int pomodorosUntilLongBreak; // 4 pomodoros (mặc định)

  PomodoroSettingsEntity({
    this.pomodoroWorkDuration = 25,
    this.pomodoroShortBreak = 5,
    this.pomodoroLongBreak = 15,
    this.pomodorosUntilLongBreak = 4,
  });

  PomodoroSettingsEntity copyWith({
    int? pomodoroWorkDuration,
    int? pomodoroShortBreak,
    int? pomodoroLongBreak,
    int? pomodorosUntilLongBreak,
  }) {
    return PomodoroSettingsEntity(
      pomodoroWorkDuration: pomodoroWorkDuration ?? this.pomodoroWorkDuration,
      pomodoroShortBreak: pomodoroShortBreak ?? this.pomodoroShortBreak,
      pomodoroLongBreak: pomodoroLongBreak ?? this.pomodoroLongBreak,
      pomodorosUntilLongBreak:
          pomodorosUntilLongBreak ?? this.pomodorosUntilLongBreak,
    );
  }
}

