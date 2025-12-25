import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/habit_entity.dart';
import '../providers/habit_provider.dart';
import 'mini_calendar.dart';
import 'habit_calendar_dialog.dart';

class HabitCard extends StatefulWidget {
  final HabitEntity habit;
  final VoidCallback onCheckin;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onCheckin,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  // Không cần state riêng nữa, sẽ lấy từ provider

  Color _getColorFromHex(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  IconData _getIconFromName(String? iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'water_drop':
        return Icons.water_drop;
      case 'book':
        return Icons.book;
      case 'local_drink':
        return Icons.local_drink;
      default:
        return Icons.check_circle_outline;
    }
  }

  void _openCalendarDialog(BuildContext context) async {
    final provider = Provider.of<HabitProvider>(context, listen: false);
    
    // Load check-ins cho habit này
    await provider.loadHabitCheckins(widget.habit.id);
    
    if (!context.mounted) return;
    
    final checkins = provider.getHabitCheckins(widget.habit.id);
    
    await showDialog(
      context: context,
      builder: (context) => HabitCalendarDialog(
        habit: widget.habit,
        checkins: checkins,
        onToggleCheckin: (date, isCheckedIn) async {
          await provider.toggleCheckin(
            habitId: widget.habit.id,
            date: date,
          );
          // Reload check-ins sau khi toggle
          if (context.mounted) {
            await provider.loadHabitCheckins(widget.habit.id);
          }
        },
      ),
    );
    
    // Reload check-ins sau khi đóng dialog
    if (context.mounted) {
      await provider.loadHabitCheckins(widget.habit.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HabitProvider>(context);
    final isCheckedInToday = provider.isCheckedInToday(widget.habit.id);
    final habitColor = _getColorFromHex(widget.habit.color);
    final habitIcon = _getIconFromName(widget.habit.icon);
    final checkins = provider.getHabitCheckins(widget.habit.id);

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
          // Mini Calendar và Habit Info
          Row(
            children: [
              // Mini Calendar
              MiniCalendar(
                checkins: checkins,
                habitColor: habitColor,
                onTap: () => _openCalendarDialog(context),
              ),
              const SizedBox(width: 16),
              
              // Habit Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title với Edit và Delete buttons
                    Row(
                      children: [
                        Icon(habitIcon, color: habitColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.habit.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        // Edit button
                        GestureDetector(
                          onTap: widget.onEdit,
                          child: Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Delete button
                        GestureDetector(
                          onTap: widget.onDelete,
                          child: Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    if (widget.habit.unit != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.habit.unit!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Day Indicators (Su Mo Tu We Th Fr Sa)
          _buildDayIndicators(habitColor),
          const SizedBox(height: 16),
          
          // Check in Button
          // Chỉ hiển thị nút check-in nếu chưa check-in hôm nay
          if (!isCheckedInToday)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onCheckin();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: habitColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Check in',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // Nếu đã check-in, hiển thị badge thay vì button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Checked In',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildDayIndicators(Color color) {
    final days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    final today = DateTime.now().weekday; // 1 = Monday, 7 = Sunday
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.asMap().entries.map((entry) {
        final index = entry.key;
        final day = entry.value;
        // Convert to match: 0 = Sunday, 1 = Monday, etc.
        final dayIndex = index == 0 ? 7 : index;
        final isToday = dayIndex == today;
        final isActive = index >= 2 && index <= 6; // Tu We Th Fr Sa active
        
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive
                ? (isToday ? color : color.withOpacity(0.3))
                : Colors.transparent,
            shape: BoxShape.circle,
            border: isToday
                ? Border.all(color: color, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isActive
                    ? (isToday ? Colors.white : color)
                    : Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

