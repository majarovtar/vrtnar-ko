import 'package:flutter/material.dart';

class GardenTask {
  final String id;
  final String title;
  final String plantName;
  final DateTime dueDate;
  final IconData icon;
  final String description;
  final bool isOverdue;

  const GardenTask({
    required this.id,
    required this.title,
    required this.plantName,
    required this.dueDate,
    required this.icon,
    required this.description,
    this.isOverdue = false,
  });
}

class DayView extends StatelessWidget {
  final DateTime selectedDate;
  final List<GardenTask> tasks;
  final ValueChanged<GardenTask> onTaskTap;

  const DayView({
    super.key,
    required this.selectedDate,
    required this.tasks,
    required this.onTaskTap,
  });

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  String _formatDate(DateTime date) {
    const monthNames = [
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

    return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final dayTasks = tasks
        .where((task) => _isSameDay(task.dueDate, selectedDate))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Day View',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          _formatDate(selectedDate),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 12),
        if (dayTasks.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No tasks for this day.'),
            ),
          )
        else
          ...dayTasks.map(
            (task) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Icon(task.icon),
                title: Text(task.title),
                subtitle: Text(task.plantName),
                trailing: Text(
                  '${task.dueDate.day}/${task.dueDate.month}',
                ),
                onTap: () => onTaskTap(task),
              ),
            ),
          ),
      ],
    );
  }
}