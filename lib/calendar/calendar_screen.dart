import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const todayTasks = [
      GardenTask(
        title: 'Water basil',
        plantName: 'Basil',
        dueLabel: 'Today',
        icon: Icons.water_drop,
        description: 'Water the basil gently and check if the soil is still moist below the surface.',
      ),
      GardenTask(
        title: 'Check tomato leaves',
        plantName: 'Tomato',
        dueLabel: 'Today',
        icon: Icons.search,
        description: 'Inspect the leaves for yellow spots, dryness, or insects.',
      ),
    ];

    const thisWeekTasks = [
      GardenTask(
        title: 'Fertilize mint',
        plantName: 'Mint',
        dueLabel: 'Monday',
        icon: Icons.energy_savings_leaf,
        description: 'Use a light fertilizer and avoid overfeeding.',
      ),
      GardenTask(
        title: 'Rotate rosemary pot',
        plantName: 'Rosemary',
        dueLabel: 'Wednesday',
        icon: Icons.rotate_right,
        description: 'Rotate the pot so all sides receive sunlight evenly.',
      ),
      GardenTask(
        title: 'Repot chili plant',
        plantName: 'Chili',
        dueLabel: 'Friday',
        icon: Icons.local_florist,
        description: 'Move the chili plant into a slightly bigger pot with fresh soil.',
      ),
    ];

    const overdueTasks = [
      GardenTask(
        title: 'Water lavender',
        plantName: 'Lavender',
        dueLabel: '2 days late',
        icon: Icons.warning_amber_rounded,
        description: 'Check dryness first. Lavender prefers less frequent watering.',
        isOverdue: true,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Garden Calendar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _CalendarHeader(),
          const SizedBox(height: 20),
          _TaskSection(
            title: 'Today',
            subtitle: 'Tasks your plants need right now',
            tasks: todayTasks,
          ),
          const SizedBox(height: 20),
          _TaskSection(
            title: 'This Week',
            subtitle: 'Upcoming care reminders',
            tasks: thisWeekTasks,
          ),
          const SizedBox(height: 20),
          _TaskSection(
            title: 'Overdue Plant Tasks',
            subtitle: 'Plants that may need attention soon',
            tasks: overdueTasks,
          ),
        ],
      ),
    );
  }
}

class GardenTask {
  final String title;
  final String plantName;
  final String dueLabel;
  final IconData icon;
  final String description;
  final bool isOverdue;

  const GardenTask({
    required this.title,
    required this.plantName,
    required this.dueLabel,
    required this.icon,
    required this.description,
    this.isOverdue = false,
  });
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

class _TaskSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<GardenTask> tasks;

  const _TaskSection({
    required this.title,
    required this.subtitle,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        if (tasks.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No tasks here yet.'),
            ),
          )
        else
          ...tasks.map((task) => _TaskCard(task: task)),
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  final GardenTask task;

  const _TaskCard({
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(task.icon),
        title: Text(task.title),
        subtitle: Text(task.plantName),
        trailing: Text(task.dueLabel),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlantTaskDetailScreen(task: task),
            ),
          );
        },
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
                  'Due: ${task.dueLabel}',
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${task.title} marked as done'),
                      ),
                    );
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