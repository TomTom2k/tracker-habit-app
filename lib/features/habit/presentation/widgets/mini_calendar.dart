import 'package:flutter/material.dart';
import '../../domain/entities/habit_checkin_entity.dart';

/// Mini calendar widget hiển thị các ngày đã check-in
/// Click vào sẽ mở full calendar dialog
class MiniCalendar extends StatelessWidget {
  final List<HabitCheckinEntity> checkins;
  final Color habitColor;
  final VoidCallback onTap;

  const MiniCalendar({
    super.key,
    required this.checkins,
    required this.habitColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Tạo set các ngày đã check-in (chỉ lấy date, bỏ qua time)
    final checkedInDates = checkins.map((checkin) {
      final date = checkin.checkinDate;
      return DateTime(date.year, date.month, date.day);
    }).toSet();

    // Lấy tháng hiện tại
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    
    // Tìm ngày đầu tiên của tuần (Chủ nhật = 0)
    final firstDayOfWeek = firstDayOfMonth.weekday % 7;
    
    // Tính số tuần cần hiển thị
    final daysInMonth = lastDayOfMonth.day;
    final weeksNeeded = ((firstDayOfWeek + daysInMonth) / 7).ceil();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: Tháng/Năm
            Text(
              '${now.month}/${now.year}',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 2),
            // Calendar grid
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                ),
                itemCount: weeksNeeded * 7,
                itemBuilder: (context, index) {
                  // Tính ngày tương ứng với index
                  final dayIndex = index - firstDayOfWeek;
                  
                  if (dayIndex < 0 || dayIndex >= daysInMonth) {
                    // Ngày không thuộc tháng này
                    return const SizedBox.shrink();
                  }
                  
                  final day = dayIndex + 1;
                  final date = DateTime(now.year, now.month, day);
                  final isCheckedIn = checkedInDates.contains(date);
                  final isToday = date.year == now.year &&
                      date.month == now.month &&
                      date.day == now.day;

                  return Container(
                    decoration: BoxDecoration(
                      color: isCheckedIn
                          ? habitColor.withOpacity(0.7)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(1),
                      border: isToday
                          ? Border.all(
                              color: habitColor,
                              width: 1,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 6,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          color: isCheckedIn
                              ? Colors.white
                              : (isToday
                                  ? habitColor
                                  : Theme.of(context).colorScheme.secondary.withOpacity(0.5)),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

