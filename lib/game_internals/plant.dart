import '../api/perenual_service.dart';
import 'seed.dart';

enum GrowthStage {
  seedling,
  sprout,
  flowering,
  mature;

  String get displayName => switch (this) {
    GrowthStage.seedling => 'Seedling',
    GrowthStage.sprout => 'Sprout',
    GrowthStage.flowering => 'Flowering',
    GrowthStage.mature => 'Mature',
  };
}

class Plant {
  final Seed seed;
  final DateTime plantedAt;
  PlantDetails? details;
  late final Future<PlantDetails?> detailsFuture;

  Plant({required this.seed, DateTime? plantedAt})
      : plantedAt = plantedAt ?? DateTime.now() {
    detailsFuture = _loadDetails();
  }

  Future<PlantDetails?> _loadDetails() async {
    details = await PerenualService().fetchPlantDetails(seed.name);
    return details;
  }

  GrowthStage get growthStage {
    final elapsed = DateTime.now().difference(plantedAt).inSeconds;
    if (elapsed < 10) return GrowthStage.seedling;
    if (elapsed < 20) return GrowthStage.sprout;
    if (elapsed < 30) return GrowthStage.flowering;
    return GrowthStage.mature;
  }

  String get assetPath => switch (growthStage) {
    GrowthStage.seedling => 'assets/maja/tile000.png',
    GrowthStage.sprout => 'assets/maja/tile001.png',
    GrowthStage.flowering => 'assets/maja/tile002.png',
    GrowthStage.mature => 'assets/maja/tile003.png',
  };

  String get growthInfo {
    final elapsed = DateTime.now().difference(plantedAt).inSeconds;
    final stage = growthStage;
    return '${seed.asCharacter} ${seed.name}\n'
        'Stage: ${stage.displayName}\n'
        'Planted ${elapsed}s ago';
  }
}
