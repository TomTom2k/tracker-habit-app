import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/pomodoro_settings_entity.dart';
import '../../domain/repositories/pomodoro_repository.dart';

enum PomodoroMode { pomodoro, stopwatch }

enum PomodoroState { idle, running, paused, completed }

enum PomodoroPhase { work, shortBreak, longBreak }

class PomodoroProvider extends ChangeNotifier {
  final PomodoroRepository repository;

  PomodoroProvider({required this.repository});

  PomodoroMode _mode = PomodoroMode.pomodoro;
  PomodoroState _state = PomodoroState.idle;
  PomodoroPhase _phase = PomodoroPhase.work;
  PomodoroSettingsEntity _settings = PomodoroSettingsEntity();
  
  int _remainingSeconds = 0; // Cho pomodoro: đếm ngược, cho stopwatch: đếm tăng
  int _currentPomodoroCount = 0;
  Timer? _timer;

  PomodoroMode get mode => _mode;
  PomodoroState get state => _state;
  PomodoroPhase get phase => _phase;
  PomodoroSettingsEntity get settings => _settings;
  int get remainingSeconds => _remainingSeconds;
  int get currentPomodoroCount => _currentPomodoroCount;

  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final hours = minutes ~/ 60;
    final displayMinutes = minutes % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${displayMinutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${displayMinutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress {
    if (_mode == PomodoroMode.stopwatch) {
      // Stopwatch không có progress, luôn return 0
      return 0.0;
    }
    final totalSeconds = _getTotalSecondsForCurrentPhase();
    if (totalSeconds == 0) return 0.0;
    return 1.0 - (_remainingSeconds / totalSeconds);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> loadSettings() async {
    _settings = await repository.getSettings();
    _resetTimer();
    notifyListeners();
  }

  Future<void> saveSettings(PomodoroSettingsEntity newSettings) async {
    _settings = newSettings;
    await repository.saveSettings(_settings);
    _resetTimer();
    notifyListeners();
  }

  void setMode(PomodoroMode mode) {
    if (_state == PomodoroState.running) {
      _stopTimer();
    }
    _mode = mode;
    _resetTimer();
    notifyListeners();
  }

  void start() {
    if (_state == PomodoroState.running) return;

    if (_state == PomodoroState.idle || _state == PomodoroState.completed) {
      _initializeTimer();
    }

    _state = PomodoroState.running;
    _startTimer();
    notifyListeners();
  }

  void pause() {
    if (_state != PomodoroState.running) return;
    _stopTimer();
    _state = PomodoroState.paused;
    notifyListeners();
  }

  void resume() {
    if (_state != PomodoroState.paused) return;
    _state = PomodoroState.running;
    _startTimer();
    notifyListeners();
  }

  void reset() {
    _stopTimer();
    _state = PomodoroState.idle;
    _currentPomodoroCount = 0;
    _phase = PomodoroPhase.work;
    _resetTimer();
    notifyListeners();
  }

  void _initializeTimer() {
    if (_mode == PomodoroMode.pomodoro) {
      _phase = PomodoroPhase.work;
      _remainingSeconds = _settings.pomodoroWorkDuration * 60;
    } else {
      // Stopwatch: bắt đầu từ 0
      _remainingSeconds = 0;
    }
  }

  void _resetTimer() {
    _initializeTimer();
  }

  int _getTotalSecondsForCurrentPhase() {
    switch (_phase) {
      case PomodoroPhase.work:
        return _settings.pomodoroWorkDuration * 60;
      case PomodoroPhase.shortBreak:
        return _settings.pomodoroShortBreak * 60;
      case PomodoroPhase.longBreak:
        return _settings.pomodoroLongBreak * 60;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_mode == PomodoroMode.stopwatch) {
        // Stopwatch: đếm tăng dần
        _remainingSeconds++;
        notifyListeners();
      } else {
        // Pomodoro: đếm ngược
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          notifyListeners();
        } else {
          _onTimerComplete();
        }
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _onTimerComplete() {
    _stopTimer();
    _state = PomodoroState.completed;

    // Chỉ pomodoro mode mới có completion logic
    if (_phase == PomodoroPhase.work) {
      _currentPomodoroCount++;
      if (_currentPomodoroCount % _settings.pomodorosUntilLongBreak == 0) {
        _phase = PomodoroPhase.longBreak;
      } else {
        _phase = PomodoroPhase.shortBreak;
      }
      _remainingSeconds = _getTotalSecondsForCurrentPhase();
    } else {
      // Break completed, start work phase
      _phase = PomodoroPhase.work;
      _remainingSeconds = _settings.pomodoroWorkDuration * 60;
    }

    notifyListeners();
  }
}

