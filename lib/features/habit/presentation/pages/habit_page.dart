import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../widgets/habit_card.dart';
import '../widgets/create_habit_dialog.dart';

class HabitPage extends StatefulWidget {
  const HabitPage({super.key});

  @override
  State<HabitPage> createState() => _HabitPageState();
}

class _HabitPageState extends State<HabitPage> with WidgetsBindingObserver {
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Load habits khi page được mở lần đầu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHabits();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reload khi app quay lại foreground
    if (state == AppLifecycleState.resumed) {
      _loadHabits();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload habits khi page được focus lại (khi navigate từ page khác quay lại)
    // Chỉ reload nếu đã load ít nhất 1 lần trước đó
    if (_hasLoaded) {
      _loadHabits();
    }
  }

  void _loadHabits() {
    final provider = Provider.of<HabitProvider>(context, listen: false);
    // Chỉ load nếu chưa đang loading
    if (!provider.isLoading) {
      provider.clearError(); // Clear error trước khi load lại
      // Load habits và statistics
      provider.loadHabits().then((_) {
        provider.loadTodayCheckinsCount();
      });
      _hasLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<HabitProvider>(
          builder: (context, provider, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  _buildHeader(context, provider),
                  const SizedBox(height: 32),
                  
                  // Statistics
                  _buildStatistics(context, provider),
                  const SizedBox(height: 24),
                  
                  // Create New Habit Button
                  _buildCreateHabitButton(context, provider),
                  const SizedBox(height: 24),
                  
                  // Error message
                  if (provider.error != null && provider.habits.isEmpty && !provider.isLoading)
                    _buildErrorState(context, provider),
                  
                  // Habits List
                  if (provider.isLoading && provider.habits.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (provider.habits.isEmpty && provider.error == null)
                    _buildEmptyState(context)
                  else if (provider.habits.isNotEmpty)
                    ...provider.habits.map((habit) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: HabitCard(
                            habit: habit,
                            onCheckin: () => _handleCheckin(context, provider, habit.id),
                            onDelete: () => _handleDelete(context, provider, habit.id),
                          ),
                        )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, HabitProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Habits',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildStatistics(BuildContext context, HabitProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            value: provider.totalHabits.toString(),
            label: 'Total Habits',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            value: provider.todayCheckinsCount.toString(),
            label: 'Completed Today',
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
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
      ),
    );
  }

  Widget _buildCreateHabitButton(
    BuildContext context,
    HabitProvider provider,
  ) {
    return InkWell(
      onTap: () => _showCreateHabitDialog(context, provider),
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
            Icon(
              Icons.add_circle_outline,
              color: Colors.blue,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Create New Habit',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No habits yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first habit to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, HabitProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Error loading habits',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            provider.error ?? 'Unknown error',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red[600],
                ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              provider.clearError();
              _loadHabits();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateHabitDialog(
    BuildContext context,
    HabitProvider provider,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CreateHabitDialog(),
    );

    if (result == true && mounted) {
      provider.loadHabits();
    }
  }

  Future<void> _handleCheckin(
    BuildContext context,
    HabitProvider provider,
    String habitId,
  ) async {
    final success = await provider.checkinHabit(habitId: habitId);
    
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Habit checked in successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to check in'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleDelete(
    BuildContext context,
    HabitProvider provider,
    String habitId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: const Text('Are you sure you want to delete this habit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await provider.deleteHabit(habitId);
      
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Habit deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to delete habit'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
