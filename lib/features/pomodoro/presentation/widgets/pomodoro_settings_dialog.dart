import 'package:flutter/material.dart';
import '../providers/pomodoro_provider.dart';

class PomodoroSettingsDialog extends StatefulWidget {
  final PomodoroProvider provider;

  const PomodoroSettingsDialog({
    super.key,
    required this.provider,
  });

  @override
  State<PomodoroSettingsDialog> createState() => _PomodoroSettingsDialogState();
}

class _PomodoroSettingsDialogState extends State<PomodoroSettingsDialog> {
  late int _workDuration;
  late int _shortBreak;
  late int _longBreak;
  late int _pomodorosUntilLongBreak;

  @override
  void initState() {
    super.initState();
    final settings = widget.provider.settings;
    _workDuration = settings.pomodoroWorkDuration;
    _shortBreak = settings.pomodoroShortBreak;
    _longBreak = settings.pomodoroLongBreak;
    _pomodorosUntilLongBreak = settings.pomodorosUntilLongBreak;
  }

  void _saveSettings() {
    final newSettings = widget.provider.settings.copyWith(
      pomodoroWorkDuration: _workDuration,
      pomodoroShortBreak: _shortBreak,
      pomodoroLongBreak: _longBreak,
      pomodorosUntilLongBreak: _pomodorosUntilLongBreak,
    );
    widget.provider.saveSettings(newSettings);
    Navigator.of(context).pop();
  }

  void _resetToDefaults() {
    setState(() {
      _workDuration = 25;
      _shortBreak = 5;
      _longBreak = 15;
      _pomodorosUntilLongBreak = 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              
              // Pomodoro Settings
              Text(
                'Pomodoro Mode',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              
              _buildTimeSetting(
                context,
                'Work Duration',
                _workDuration,
                (value) => setState(() => _workDuration = value),
                min: 1,
                max: 60,
              ),
              const SizedBox(height: 16),
              
              _buildTimeSetting(
                context,
                'Short Break',
                _shortBreak,
                (value) => setState(() => _shortBreak = value),
                min: 1,
                max: 30,
              ),
              const SizedBox(height: 16),
              
              _buildTimeSetting(
                context,
                'Long Break',
                _longBreak,
                (value) => setState(() => _longBreak = value),
                min: 1,
                max: 60,
              ),
              const SizedBox(height: 16),
              
              _buildNumberSetting(
                context,
                'Pomodoros Until Long Break',
                _pomodorosUntilLongBreak,
                (value) => setState(() => _pomodorosUntilLongBreak = value),
                min: 1,
                max: 10,
              ),
              
              const SizedBox(height: 24),
              
              // Buttons
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _resetToDefaults,
                    child: const Text('Reset to Defaults'),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _saveSettings,
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSetting(
    BuildContext context,
    String label,
    int value,
    ValueChanged<int> onChanged, {
    required int min,
    required int max,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: value > min
                  ? () => onChanged(value - 1)
                  : null,
            ),
            Container(
              width: 60,
              alignment: Alignment.center,
              child: Text(
                '$value min',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: value < max
                  ? () => onChanged(value + 1)
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberSetting(
    BuildContext context,
    String label,
    int value,
    ValueChanged<int> onChanged, {
    required int min,
    required int max,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: value > min
                  ? () => onChanged(value - 1)
                  : null,
            ),
            Container(
              width: 60,
              alignment: Alignment.center,
              child: Text(
                '$value',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: value < max
                  ? () => onChanged(value + 1)
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}

