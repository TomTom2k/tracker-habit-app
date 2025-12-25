import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goal_provider.dart';
import '../widgets/goal_card.dart';
import '../widgets/create_goal_dialog.dart';
import '../../domain/entities/goal_entity.dart';
import '../../../../core/widgets/error_banner.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  @override
  void initState() {
    super.initState();
    // Load goals khi page được mở
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<GoalProvider>(context, listen: false);
      provider.loadGoals();
    });
  }

  Future<void> _showCreateGoalDialog(
    BuildContext context,
    GoalProvider provider,
  ) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const CreateGoalDialog(),
    );

    if (result != null && mounted) {
      final success = await provider.createGoal(
        title: result['title'] as String,
        description: result['description'] as String?,
        category: result['category'] as GoalCategory,
        targetDate: result['targetDate'] as DateTime?,
      );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to create goal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<GoalProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                // Header
                _buildHeader(context, provider),
                
                // Error banner
                if (provider.error != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ErrorBanner(
                      message: provider.error!,
                      onDismiss: () => provider.clearError(),
                    ),
                  ),
                
                // Category filter chips
                _buildCategoryFilter(context, provider),
                
                // Goals list
                Expanded(
                  child: provider.isLoading && provider.goals.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : provider.goals.isEmpty
                          ? _buildEmptyState(context)
                          : _buildGoalsList(context, provider),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Consumer<GoalProvider>(
        builder: (context, provider, child) {
          return FloatingActionButton.extended(
            onPressed: () => _showCreateGoalDialog(context, provider),
            icon: const Icon(Icons.add),
            label: const Text('New Goal'),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, GoalProvider provider) {
    final completedCount = provider.allGoals.where((g) => g.isCompleted).length;
    final totalCount = provider.allGoals.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Goals',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedCount/$totalCount completed',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                  ],
                ),
              ),
              // Progress indicator
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, GoalProvider provider) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryChip(
            context,
            provider,
            null,
            'All',
            Icons.all_inclusive,
          ),
          const SizedBox(width: 8),
          ...GoalCategory.values.map((category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildCategoryChip(
                  context,
                  provider,
                  category,
                  category.displayName,
                  _getCategoryIcon(category),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    GoalProvider provider,
    GoalCategory? category,
    String label,
    IconData icon,
  ) {
    final isSelected = provider.selectedCategory == category;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        provider.setCategoryFilter(selected ? category : null);
      },
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  IconData _getCategoryIcon(GoalCategory category) {
    switch (category) {
      case GoalCategory.health:
        return Icons.favorite;
      case GoalCategory.career:
        return Icons.work;
      case GoalCategory.finance:
        return Icons.account_balance;
      case GoalCategory.education:
        return Icons.school;
      case GoalCategory.personal:
        return Icons.person;
      case GoalCategory.relationship:
        return Icons.people;
      case GoalCategory.other:
        return Icons.category;
    }
  }

  Widget _buildGoalsList(BuildContext context, GoalProvider provider) {
    // Separate completed and active goals
    final activeGoals = provider.goals.where((g) => !g.isCompleted).toList();
    final completedGoals = provider.goals.where((g) => g.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // Active goals
        if (activeGoals.isNotEmpty) ...[
          if (completedGoals.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 8),
              child: Text(
                'Active Goals',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
            ),
          ...activeGoals.map((goal) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GoalCard(goal: goal),
              )),
        ],
        // Completed goals
        if (completedGoals.isNotEmpty) ...[
          if (activeGoals.isNotEmpty) const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.only(bottom: 8, top: activeGoals.isEmpty ? 8 : 0),
            child: Text(
              'Completed Goals',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
          ),
          ...completedGoals.map((goal) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GoalCard(goal: goal),
              )),
        ],
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No goals yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first goal to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

