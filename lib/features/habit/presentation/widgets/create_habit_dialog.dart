import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';

class CreateHabitDialog extends StatefulWidget {
  const CreateHabitDialog({super.key});

  @override
  State<CreateHabitDialog> createState() => _CreateHabitDialogState();
}

class _CreateHabitDialogState extends State<CreateHabitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _unitController = TextEditingController();
  String _selectedColor = '#3B82F6'; // Blue default
  String? _selectedIcon;

  final List<Map<String, dynamic>> _colors = [
    {'name': 'Blue', 'value': '#3B82F6'},
    {'name': 'Purple', 'value': '#8B5CF6'},
    {'name': 'Teal', 'value': '#14B8A6'},
    {'name': 'Pink', 'value': '#EC4899'},
    {'name': 'Orange', 'value': '#F97316'},
    {'name': 'Green', 'value': '#10B981'},
  ];

  final List<Map<String, dynamic>> _icons = [
    {'name': 'restaurant', 'icon': Icons.restaurant},
    {'name': 'fitness_center', 'icon': Icons.fitness_center},
    {'name': 'water_drop', 'icon': Icons.water_drop},
    {'name': 'book', 'icon': Icons.book},
    {'name': 'local_drink', 'icon': Icons.local_drink},
    {'name': 'check_circle', 'icon': Icons.check_circle},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<HabitProvider>(context, listen: false);
    
    final success = await provider.createHabit(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      unit: _unitController.text.trim().isEmpty
          ? null
          : _unitController.text.trim(),
      color: _selectedColor,
      icon: _selectedIcon,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Habit created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to create habit'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getColorFromHex(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create New Habit',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  hintText: 'e.g., Morning workout',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Optional description',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              
              // Unit/Frequency
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(
                  labelText: 'Unit / Frequency',
                  hintText: 'e.g., 2l, 10 push-ups, 30 min',
                ),
              ),
              const SizedBox(height: 24),
              
              // Color Selection
              Text(
                'Color',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colors.map((color) {
                  final isSelected = _selectedColor == color['value'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color['value'] as String;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getColorFromHex(color['value'] as String),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: Colors.black,
                                width: 3,
                              )
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              
              // Icon Selection
              Text(
                'Icon (Optional)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  // None option
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = null;
                      });
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _selectedIcon == null
                            ? Colors.black
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedIcon == null
                              ? Colors.black
                              : Colors.grey[300]!,
                          width: _selectedIcon == null ? 2 : 1,
                        ),
                      ),
                      child: Icon(
                        Icons.close,
                        color: _selectedIcon == null
                            ? Colors.white
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                  ..._icons.map((icon) {
                    final isSelected = _selectedIcon == icon['name'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIcon = icon['name'] as String;
                        });
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.black
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Colors.black
                                : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          icon['icon'] as IconData,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey[600],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
              const SizedBox(height: 32),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Consumer<HabitProvider>(
                      builder: (context, provider, child) {
                        return ElevatedButton(
                          onPressed: provider.isLoading ? null : _handleCreate,
                          child: provider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Create'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

