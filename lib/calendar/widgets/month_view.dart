import 'package:flutter/material.dart';
import 'day_view.dart';

class MonthView extends StatelessWidget {
  final DateTime selectedDate;
  final List<GardenTask> tasks;
  final ValueChanged<DateTime> onDateTap;

  const MonthView({
    super.key,
    required this.selectedDate,
    required this.tasks,
    required this.onDateTap,
  });

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  String _monthName(DateTime date) {
    const names = [
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
      'December',
    ];
    return names[date.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final daysInMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

    final startWeekday = firstDayOfMonth.weekday; // Monday = 1
    final leadingEmptyCells = startWeekday - 1;

    final totalCells = leadingEmptyCells + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    final cells = List<Widget>.generate(rowCount * 7, (index) {
      final dayNumber = index - leadingEmptyCells + 1;

      if (dayNumber < 1 || dayNumber > daysInMonth) {
        return const SizedBox.shrink();
      }

      final dayDate =
          DateTime(selectedDate.year, selectedDate.month, dayNumber);

      final isSelected = _isSameDay(dayDate, selectedDate);

      final hasTasks = tasks.any((task) => _isSameDay(task.dueDate, dayDate));

      return GestureDetector(
        onTap: () => onDateTap(dayDate),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? Colors.green.shade100 : Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$dayNumber',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 6),
                if (hasTasks)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });

    const weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Month View',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          '${_monthName(selectedDate)} ${selectedDate.year}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: weekdayLabels
              .map(
                (label) => Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: cells,
        ),
      ],
    );
  }
}