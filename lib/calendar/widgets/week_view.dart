import 'package:flutter/material.dart';
import 'day_view.dart';

class WeekView extends StatelessWidget {
  final DateTime selectedDate;
  final List<GardenTask> tasks;
  final ValueChanged<GardenTask> onTaskTap;

  const WeekView({
    super.key,
    required this.selectedDate,
    required this.tasks,
    required this.onTaskTap,
  });

  DateTime _startOfWeek(DateTime date) {
    final weekday = date.weekday; // Monday = 1, Sunday = 7
    return DateTime(date.year, date.month, date.day - (weekday - 1));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  String _dayName(DateTime date) {
    const names = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    return names[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final weekStart = _startOfWeek(selectedDate);
    final days = List.generate(
      7,
      (index) => DateTime(
        weekStart.year,
        weekStart.month,
        weekStart.day + index,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Week View',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...days.map((day) {
          final dayTasks = tasks
              .where((task) => _isSameDay(task.dueDate, day))
              .toList();

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_dayName(day)} ${day.day}/${day.month}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (dayTasks.isEmpty)
                    const Text('No tasks')
                  else
                    ...dayTasks.map(
                      (task) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(task.icon),
                        title: Text(task.title),
                        subtitle: Text(task.plantName),
                        trailing: Text('${task.dueDate.day}/${task.dueDate.month}'),
                        onTap: () => onTaskTap(task),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}