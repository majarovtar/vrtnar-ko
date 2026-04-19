import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game_internals/graveyard.dart';

class GraveyardScreen extends StatelessWidget {
  const GraveyardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final graveyard = context.watch<Graveyard>();
    final plants = graveyard.plants;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Graveyard'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Graveyard Garden',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'images/buildings/g1.png',
                    fit: BoxFit.fitWidth,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Dead plants',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (plants.isEmpty)
                  const Text(
                    'No plants have been removed yet.',
                    textAlign: TextAlign.center,
                  )
                else
                  for (final plant in plants)
                    _buildGravestoneCard(context, plant),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGravestoneCard(BuildContext context, DeadPlant plant) {
    final date = plant.removedAt;
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            Text(
              plant.seed.asCharacter,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.name ?? plant.seed.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Removed: $dateStr',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
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
