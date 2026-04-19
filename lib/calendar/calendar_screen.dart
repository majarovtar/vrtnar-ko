import 'package:flutter/material.dart';
import 'calendar_view_mode.dart';
import 'widgets/day_view.dart';
import 'widgets/month_view.dart';
import 'widgets/week_view.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarViewMode _viewMode = CalendarViewMode.day;
  DateTime _selectedDate = DateTime.now();

  late List<GardenTask> todayTasks;
  late List<GardenTask> thisWeekTasks;
  late List<GardenTask> overdueTasks;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    todayTasks = [
      GardenTask(
        id: 'task_1',
        title: 'Water basil',
        plantName: 'Basil',
        dueDate: DateTime(now.year, now.month, now.day),
        icon: Icons.water_drop,
        description:
            'Water the basil gently and check if the soil is still moist below the surface.',
      ),
      GardenTask(
        id: 'task_2',
        title: 'Check tomato leaves',
        plantName: 'Tomato',
        dueDate: DateTime(now.year, now.month, now.day),
        icon: Icons.search,
        description: 'Inspect the leaves for yellow spots, dryness, or insects.',
      ),
    ];

    thisWeekTasks = [
      GardenTask(
        id: 'task_3',
        title: 'Fertilize mint',
        plantName: 'Mint',
        dueDate: DateTime(now.year, now.month, now.day + 1),
        icon: Icons.energy_savings_leaf,
        description: 'Use a light fertilizer and avoid overfeeding.',
      ),
      GardenTask(
        id: 'task_4',
        title: 'Rotate rosemary pot',
        plantName: 'Rosemary',
        dueDate: DateTime(now.year, now.month, now.day + 2),
        icon: Icons.rotate_right,
        description: 'Rotate the pot so all sides receive sunlight evenly.',
      ),
      GardenTask(
        id: 'task_5',
        title: 'Repot chili plant',
        plantName: 'Chili',
        dueDate: DateTime(now.year, now.month, now.day + 4),
        icon: Icons.local_florist,
        description:
            'Move the chili plant into a slightly bigger pot with fresh soil.',
      ),
    ];

    overdueTasks = [
      GardenTask(
        id: 'task_6',
        title: 'Water lavender',
        plantName: 'Lavender',
        dueDate: DateTime(now.year, now.month, now.day - 2),
        icon: Icons.warning_amber_rounded,
        description:
            'Check dryness first. Lavender prefers less frequent watering.',
        isOverdue: true,
      ),
    ];
  }

  void _markTaskAsDone(GardenTask task) {
    setState(() {
      todayTasks.removeWhere((item) => item.id == task.id);
      thisWeekTasks.removeWhere((item) => item.id == task.id);
      overdueTasks.removeWhere((item) => item.id == task.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${task.title} marked as done'),
      ),
    );
  }

  Future<void> _openTaskDetail(GardenTask task) async {
    final wasCompleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PlantTaskDetailScreen(task: task),
      ),
    );

    if (wasCompleted == true) {
      _markTaskAsDone(task);
    }
  }

  void _onMonthDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _viewMode = CalendarViewMode.day;
    });
  }

  void _goToPreviousPeriod() {
    setState(() {
      switch (_viewMode) {
        case CalendarViewMode.day:
          _selectedDate = _selectedDate.subtract(const Duration(days: 1));
          break;
        case CalendarViewMode.week:
          _selectedDate = _selectedDate.subtract(const Duration(days: 7));
          break;
        case CalendarViewMode.month:
          _selectedDate = DateTime(
            _selectedDate.year,
            _selectedDate.month - 1,
            _selectedDate.day,
          );
          break;
      }
    });
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
    });
  }

  void _goToNextPeriod() {
    setState(() {
      switch (_viewMode) {
        case CalendarViewMode.day:
          _selectedDate = _selectedDate.add(const Duration(days: 1));
          break;
        case CalendarViewMode.week:
          _selectedDate = _selectedDate.add(const Duration(days: 7));
          break;
        case CalendarViewMode.month:
          _selectedDate = DateTime(
            _selectedDate.year,
            _selectedDate.month + 1,
            _selectedDate.day,
          );
          break;
      }
    });
  }

  String _currentPeriodLabel() {
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

    switch (_viewMode) {
      case CalendarViewMode.day:
        return '${monthNames[_selectedDate.month - 1]} ${_selectedDate.day}, ${_selectedDate.year}';
      case CalendarViewMode.week:
        final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return '${startOfWeek.day}/${startOfWeek.month} - ${endOfWeek.day}/${endOfWeek.month}';
      case CalendarViewMode.month:
        return '${monthNames[_selectedDate.month - 1]} ${_selectedDate.year}';
    }
  }

  Widget _buildCurrentView() {
    final allTasks = [...todayTasks, ...thisWeekTasks, ...overdueTasks];

    switch (_viewMode) {
      case CalendarViewMode.day:
        return DayView(
          selectedDate: _selectedDate,
          tasks: allTasks,
          onTaskTap: _openTaskDetail,
        );
      case CalendarViewMode.week:
        return WeekView(
          selectedDate: _selectedDate,
          tasks: allTasks,
          onTaskTap: _openTaskDetail,
        );
      case CalendarViewMode.month:
        return MonthView(
          selectedDate: _selectedDate,
          tasks: allTasks,
          onDateTap: _onMonthDateSelected,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Garden Calendar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _CalendarHeader(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Day'),
                selected: _viewMode == CalendarViewMode.day,
                onSelected: (_) {
                  setState(() {
                    _viewMode = CalendarViewMode.day;
                  });
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Week'),
                selected: _viewMode == CalendarViewMode.week,
                onSelected: (_) {
                  setState(() {
                    _viewMode = CalendarViewMode.week;
                  });
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Month'),
                selected: _viewMode == CalendarViewMode.month,
                onSelected: (_) {
                  setState(() {
                    _viewMode = CalendarViewMode.month;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                onPressed: _goToPreviousPeriod,
                icon: const Icon(Icons.chevron_left),
              ),
              TextButton(
                onPressed: _goToToday,
                child: const Text('Today'),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    _currentPeriodLabel(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              IconButton(
                onPressed: _goToNextPeriod,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildCurrentView(),
        ],
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Plant Care Plan',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Keep track of watering, repotting, fertilizing, and plant health.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlantTaskDetailScreen extends StatelessWidget {
  final GardenTask task;

  const PlantTaskDetailScreen({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task.plantName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(task.icon, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        task.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Plant: ${task.plantName}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Due: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Task Details',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  task.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Mark as Done'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}