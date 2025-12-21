import 'package:flutter/material.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/entities/habit_checkin_entity.dart';

/// Full calendar dialog cho phép toggle check-in các ngày
class HabitCalendarDialog extends StatefulWidget {
  final HabitEntity habit;
  final List<HabitCheckinEntity> checkins;
  final Function(DateTime date, bool isCheckedIn) onToggleCheckin;

  const HabitCalendarDialog({
    super.key,
    required this.habit,
    required this.checkins,
    required this.onToggleCheckin,
  });

  @override
  State<HabitCalendarDialog> createState() => _HabitCalendarDialogState();
}

class _HabitCalendarDialogState extends State<HabitCalendarDialog> {
  late DateTime _currentMonth;
  late Set<DateTime> _checkedInDates;
  late Map<DateTime, HabitCheckinEntity> _checkinMap;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _updateCheckinData();
  }

  void _updateCheckinData() {
    _checkedInDates = {};
    _checkinMap = {};
    
    for (var checkin in widget.checkins) {
      final date = checkin.checkinDate;
      final dateOnly = DateTime(date.year, date.month, date.day);
      _checkedInDates.add(dateOnly);
      _checkinMap[dateOnly] = checkin;
    }
  }

  Color _getColorFromHex(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  void _toggleCheckin(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final isCheckedIn = _checkedInDates.contains(dateOnly);
    
    widget.onToggleCheckin(dateOnly, isCheckedIn);
    
    setState(() {
      if (isCheckedIn) {
        _checkedInDates.remove(dateOnly);
        _checkinMap.remove(dateOnly);
      } else {
        _checkedInDates.add(dateOnly);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final habitColor = _getColorFromHex(widget.habit.color);
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstDayOfWeek = firstDayOfMonth.weekday % 7; // 0 = Sunday
    final daysInMonth = lastDayOfMonth.day;
    final weeksNeeded = ((firstDayOfWeek + daysInMonth) / 7).ceil();

    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    final weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                ),
                Text(
                  '${monthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Week day headers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekDays.map((day) {
                return SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      day,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            
            // Calendar grid
            ...List.generate(weeksNeeded, (weekIndex) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (dayIndex) {
                  final globalIndex = weekIndex * 7 + dayIndex;
                  final dayNumber = globalIndex - firstDayOfWeek + 1;
                  
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    // Ngày không thuộc tháng này
                    return const SizedBox(width: 40, height: 40);
                  }
                  
                  final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
                  final dateOnly = DateTime(date.year, date.month, date.day);
                  final isCheckedIn = _checkedInDates.contains(dateOnly);
                  final isToday = date.year == DateTime.now().year &&
                      date.month == DateTime.now().month &&
                      date.day == DateTime.now().day;
                  final isPast = dateOnly.isBefore(DateTime.now().subtract(const Duration(days: 1)));

                  return GestureDetector(
                    onTap: () => _toggleCheckin(date),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isCheckedIn
                            ? habitColor.withOpacity(0.8)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: isToday
                            ? Border.all(
                                color: habitColor,
                                width: 2,
                              )
                            : (isCheckedIn
                                ? Border.all(
                                    color: habitColor,
                                    width: 1,
                                  )
                                : null),
                      ),
                      child: Center(
                        child: Text(
                          '$dayNumber',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: isCheckedIn
                                ? Colors.white
                                : (isToday
                                    ? habitColor
                                    : (isPast
                                        ? Theme.of(context).colorScheme.secondary
                                        : Theme.of(context).colorScheme.secondary.withOpacity(0.5))),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
            const SizedBox(height: 16),
            
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: habitColor.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Checked in',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: habitColor,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Today',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Close button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

