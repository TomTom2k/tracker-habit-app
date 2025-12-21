import '../../domain/entities/pomodoro_settings_entity.dart';
import '../../domain/repositories/pomodoro_repository.dart';
import '../datasources/pomodoro_local_data_source.dart';
import '../models/pomodoro_settings_model.dart';

class PomodoroRepositoryImpl implements PomodoroRepository {
  final PomodoroLocalDataSource localDataSource;

  PomodoroRepositoryImpl({required this.localDataSource});

  @override
  Future<PomodoroSettingsEntity> getSettings() async {
    final model = await localDataSource.getSettings();
    return model.toEntity();
  }

  @override
  Future<void> saveSettings(PomodoroSettingsEntity settings) async {
    final model = PomodoroSettingsModel(
      pomodoroWorkDuration: settings.pomodoroWorkDuration,
      pomodoroShortBreak: settings.pomodoroShortBreak,
      pomodoroLongBreak: settings.pomodoroLongBreak,
      pomodorosUntilLongBreak: settings.pomodorosUntilLongBreak,
    );
    await localDataSource.saveSettings(model);
  }
}

