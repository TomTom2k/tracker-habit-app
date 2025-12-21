import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_item_widget.dart';
import '../widgets/create_todo_dialog.dart';
import '../../domain/entities/todo_item_entity.dart';
import '../../../../core/widgets/error_banner.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  @override
  void initState() {
    super.initState();
    // Load todos khi page được mở
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TodoProvider>(context, listen: false);
      provider.loadTodos(DateTime.now());
    });
  }

  Future<void> _selectDate(BuildContext context, TodoProvider provider) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      await provider.selectDate(picked);
    }
  }

  Future<void> _showCreateTodoDialog(
    BuildContext context,
    TodoProvider provider,
  ) async {
    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (context) => CreateTodoDialog(
        selectedDate: provider.selectedDate,
      ),
    );

    if (result != null && mounted) {
      final success = await provider.createTodo(
        title: result['title']!,
        description: result['description'],
        date: provider.selectedDate,
      );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to create todo'),
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
        child: Consumer<TodoProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                // Header với date picker
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
                
                // Todo list
                Expanded(
                  child: provider.isLoading && provider.todos.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : provider.todos.isEmpty
                          ? _buildEmptyState(context)
                          : _buildTodoList(context, provider),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          return FloatingActionButton(
            onPressed: () => _showCreateTodoDialog(context, provider),
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TodoProvider provider) {
    final date = provider.selectedDate;
    final isToday = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Todo',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _selectDate(context, provider),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isToday
                            ? 'Today'
                            : _formatDate(date),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Today button (chỉ hiển thị khi không phải hôm nay)
          if (!isToday) ...[
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () => provider.selectDate(DateTime.now()),
              icon: const Icon(Icons.today, size: 18),
              label: const Text('Today'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
          // Stats
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  '${provider.todos.where((t) => t.isCompleted).length}/${provider.todos.length}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                Text(
                  'Completed',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList(BuildContext context, TodoProvider provider) {
    final completedTodos = provider.todos.where((t) => t.isCompleted).toList();
    final pendingTodos = provider.todos.where((t) => !t.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Pending todos
        if (pendingTodos.isNotEmpty) ...[
          Text(
            'Pending',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...pendingTodos.map((todo) => TodoItemWidget(
                todo: todo,
                onToggle: () => provider.toggleTodo(
                  todo.id,
                  todo.type,
                ),
                onDelete: todo.type == TodoItemType.custom
                    ? () => _confirmDelete(context, provider, todo.id)
                    : null,
              )),
          const SizedBox(height: 24),
        ],
        
        // Completed todos
        if (completedTodos.isNotEmpty) ...[
          Text(
            'Completed',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
          ),
          const SizedBox(height: 12),
          ...completedTodos.map((todo) => TodoItemWidget(
                todo: todo,
                onToggle: () => provider.toggleTodo(
                  todo.id,
                  todo.type,
                ),
                onDelete: todo.type == TodoItemType.custom
                    ? () => _confirmDelete(context, provider, todo.id)
                    : null,
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
            Icons.checklist,
            size: 64,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No todos yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first todo to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    TodoProvider provider,
    String todoId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: const Text('Are you sure you want to delete this todo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await provider.deleteTodo(todoId);
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

