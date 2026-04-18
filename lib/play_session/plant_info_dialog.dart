import 'package:flutter/material.dart';

import '../api/perenual_service.dart';
import '../game_internals/playing_area.dart';

void showPlantInfoDialog(BuildContext context, PlayingArea area) {
  showGeneralDialog(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) =>
        PlantInfoDialog(animation: animation, area: area),
  );
}

class PlantInfoDialog extends StatelessWidget {
  final Animation<double> animation;
  final PlayingArea area;

  const PlantInfoDialog({
    required this.animation,
    required this.area,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final plant = area.plant;
    if (plant == null) {
      Navigator.pop(context);
      return const SizedBox.shrink();
    }

    final elapsed = DateTime.now().difference(plant.plantedAt).inSeconds;

    return ScaleTransition(
      scale: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ),
      child: SimpleDialog(
        title: Text('${plant.seed.asCharacter} ${plant.seed.name}'),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    plant.assetPath,
                    width: 64,
                    height: 64,
                    filterQuality: FilterQuality.none,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Stage: ${plant.growthStage.displayName}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    'Planted ${elapsed}s ago',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                FutureBuilder<PlantDetails?>(
                  future: plant.detailsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final details = snapshot.data;
                    if (details == null) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 24),
                        _infoRow('Scientific', details.scientificName),
                        _infoRow('Cycle', details.cycle),
                        _infoRow('Watering', details.watering),
                        _infoRow('Sunlight', details.sunlight.join(', ')),
                        _infoRow('Growth rate', details.growthRate),
                        _infoRow('Soil', details.soil),
                        _infoRow('Flowering', details.floweringSeason),
                        _infoRow(
                          'Toxic to pets',
                          details.poisonousToAnimals ? 'Yes' : 'No',
                        ),
                        if (details.pestSusceptibility.isNotEmpty)
                          _infoRow('Pests', details.pestSusceptibility.join(', ')),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              area.removePlant();
              Navigator.pop(context);
            },
            child: const Text('Remove'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
