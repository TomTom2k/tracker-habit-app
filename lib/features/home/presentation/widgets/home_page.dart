import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good ${_getGreeting()}!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Let\'s make today count',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
            const SizedBox(height: 32),
            _buildStatsCard(context),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildRecentHabits(context),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _buildStatsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context, '7', 'Day Streak'),
          Container(
            width: 1,
            height: 40,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          ),
          _buildStatItem(context, '12', 'Habits'),
          Container(
            width: 1,
            height: 40,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          ),
          _buildStatItem(context, '85%', 'Complete'),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                Icons.add_circle_outline,
                'Add Habit',
                () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                Icons.schedule_outlined,
                'New Routine',
                () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentHabits(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Habits',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildHabitItem(context, 'Morning Exercise', true),
        const SizedBox(height: 12),
        _buildHabitItem(context, 'Read 30 minutes', false),
        const SizedBox(height: 12),
        _buildHabitItem(context, 'Drink 8 glasses of water', true),
      ],
    );
  }

  Widget _buildHabitItem(BuildContext context, String title, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
                width: 2,
              ),
              color: isCompleted
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
            ),
            child: isCompleted
                ? Icon(
                    Icons.check,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimary,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: isCompleted
                        ? Theme.of(context).colorScheme.secondary
                        : null,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

