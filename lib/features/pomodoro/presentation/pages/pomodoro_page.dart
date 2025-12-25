import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pomodoro_provider.dart';
import '../widgets/pomodoro_settings_dialog.dart';

class PomodoroPage extends StatelessWidget {
  const PomodoroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<PomodoroProvider>(
          builder: (context, provider, child) {
            // Load settings khi page được mở lần đầu
            if (provider.settings.pomodoroWorkDuration == 25 &&
                provider.state == PomodoroState.idle) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                provider.loadSettings();
              });
            }

            return Column(
              children: [
                // Header với mode selector và settings
                _buildHeader(context, provider),
                
                // Main timer display
                Expanded(
                  child: Center(
                    child: _buildTimerDisplay(context, provider),
                  ),
                ),
                
                // Controls
                _buildControls(context, provider),
                
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PomodoroProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Pomodoro',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay(BuildContext context, PomodoroProvider provider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Mode selector
        _buildModeSelector(context, provider),
        
        const SizedBox(height: 32),
        
        // Phase indicator (chỉ cho Pomodoro mode và không phải work phase)
        if (provider.mode == PomodoroMode.pomodoro &&
            provider.phase != PomodoroPhase.work) ...[
          _buildPhaseIndicator(context, provider),
          const SizedBox(height: 32),
        ],
        
        // Timer circle
        SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Progress circle (chỉ hiển thị cho Pomodoro mode)
              if (provider.mode == PomodoroMode.pomodoro)
                CircularProgressIndicator(
                  value: provider.progress,
                  strokeWidth: 8,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                )
              else
                // Stopwatch: hiển thị circle trống
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.2),
                      width: 8,
                    ),
                  ),
                ),
              // Time display
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.formattedTime,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 56,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Pomodoro count (chỉ cho Pomodoro mode)
        if (provider.mode == PomodoroMode.pomodoro)
          Text(
            'Completed: ${provider.currentPomodoroCount}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
      ],
    );
  }

  Widget _buildModeSelector(BuildContext context, PomodoroProvider provider) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeButton(
            context,
            provider,
            PomodoroMode.pomodoro,
            'Pomodoro',
          ),
          _buildModeButton(
            context,
            provider,
            PomodoroMode.stopwatch,
            'Stopwatch',
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context,
    PomodoroProvider provider,
    PomodoroMode mode,
    String label,
  ) {
    final isSelected = provider.mode == mode;
    return GestureDetector(
      onTap: () => provider.setMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child:           Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
              ),
          ),
      ),
    );
  }

  Widget _buildPhaseIndicator(
    BuildContext context,
    PomodoroProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getPhaseColor(provider.phase).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getPhaseColor(provider.phase),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPhaseIcon(provider.phase),
            color: _getPhaseColor(provider.phase),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _getPhaseText(provider.phase),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getPhaseColor(provider.phase),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, PomodoroProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Reset button
          IconButton(
            icon: const Icon(Icons.refresh),
            iconSize: 32,
            onPressed: provider.state == PomodoroState.idle
                ? null
                : () => provider.reset(),
          ),
          const SizedBox(width: 32),
          
          // Play/Pause button
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary,
            ),
            child: IconButton(
              icon: Icon(
                provider.state == PomodoroState.running
                    ? Icons.pause
                    : Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
              onPressed: () {
                if (provider.state == PomodoroState.running) {
                  provider.pause();
                } else if (provider.state == PomodoroState.paused) {
                  provider.resume();
                } else {
                  provider.start();
                }
              },
            ),
          ),
          const SizedBox(width: 32),
          
          // Skip button (chỉ khi đang chạy hoặc paused)
          IconButton(
            icon: const Icon(Icons.skip_next),
            iconSize: 32,
            onPressed: (provider.state == PomodoroState.running ||
                    provider.state == PomodoroState.paused)
                ? () {
                    // Skip bằng cách set remaining time = 0
                    provider.pause();
                    // Trigger completion
                    // Note: Cần thêm method skip trong provider
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Color _getPhaseColor(PomodoroPhase phase) {
    switch (phase) {
      case PomodoroPhase.work:
        return Colors.red;
      case PomodoroPhase.shortBreak:
        return Colors.green;
      case PomodoroPhase.longBreak:
        return Colors.blue;
    }
  }

  IconData _getPhaseIcon(PomodoroPhase phase) {
    switch (phase) {
      case PomodoroPhase.work:
        return Icons.work;
      case PomodoroPhase.shortBreak:
        return Icons.coffee;
      case PomodoroPhase.longBreak:
        return Icons.restaurant;
    }
  }

  String _getPhaseText(PomodoroPhase phase) {
    switch (phase) {
      case PomodoroPhase.work:
        return 'Work';
      case PomodoroPhase.shortBreak:
        return 'Short Break';
      case PomodoroPhase.longBreak:
        return 'Long Break';
    }
  }

  Future<void> _showSettingsDialog(
    BuildContext context,
    PomodoroProvider provider,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => PomodoroSettingsDialog(provider: provider),
    );
  }
}

