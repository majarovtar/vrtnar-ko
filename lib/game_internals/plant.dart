import '../api/perenual_service.dart';
import '../api/weather_service.dart';
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
  final SeedLike seed;
  final String? name;
  final DateTime plantedAt;
  PlantDetails? details;
  late final Future<PlantDetails?> detailsFuture;
  bool watered = false;
  WeatherData? _lastWeather;
  DateTime? _lastWeatherFetch;

  Plant({required this.seed, this.name, DateTime? plantedAt})
      : plantedAt = plantedAt ?? DateTime.now() {
    detailsFuture = _loadDetails();
  }

  Future<PlantDetails?> _loadDetails() async {
    // Only fetch details for custom seeds (which have plantId)
    if (seed is CustomSeed) {
      details = await PerenualService().fetchPlantDetails(seed.name);
    }
    return details;
  }

  /// Get current weather data (cached for 5 minutes)
  Future<WeatherData?> _getWeather() async {
    final now = DateTime.now();
    if (_lastWeather != null && _lastWeatherFetch != null) {
      if (now.difference(_lastWeatherFetch!).inMinutes < 5) {
        return _lastWeather;
      }
    }

    _lastWeather = await WeatherService().getDefaultLocationWeather();
    _lastWeatherFetch = now;
    return _lastWeather;
  }

  /// Calculate elapsed time adjusted by weather conditions
  /// This simulates how weather affects plant growth
  Future<int> _getWeatherAdjustedElapsed() async {
    final baseElapsed = DateTime.now().difference(plantedAt).inSeconds;
    final weather = await _getWeather();

    if (weather == null) {
      return baseElapsed;
    }

    // Apply weather growth multiplier to accelerate or decelerate growth
    final adjustedElapsed = (baseElapsed * weather.growthMultiplier).toInt();
    return adjustedElapsed;
  }

  GrowthStage get growthStage {
    final elapsed = DateTime.now().difference(plantedAt).inSeconds;
    if (elapsed < 10) return GrowthStage.seedling;
    if (elapsed < 20) return GrowthStage.sprout;
    if (elapsed < 30) return GrowthStage.flowering;
    return GrowthStage.mature;
  }

  /// Get growth stage adjusted by current weather conditions
  /// This is an async version that considers weather impact
  Future<GrowthStage> getWeatherAdjustedGrowthStage() async {
    final elapsed = await _getWeatherAdjustedElapsed();
    if (elapsed < 10) return GrowthStage.seedling;
    if (elapsed < 20) return GrowthStage.sprout;
    if (elapsed < 30) return GrowthStage.flowering;
    return GrowthStage.mature;
  }

  /// Get watering recommendation based on current weather
  Future<String> getWateringRecommendation() async {
    final weather = await _getWeather();
    if (weather == null) return 'Unable to fetch weather data';

    // Recommend watering based on humidity and recent rainfall
    final waterIndex = (1 - weather.humidity / 100) * 0.6 + (1 - weather.rainfall.clamp(0, 10) / 10) * 0.4;
    final recommendation = switch (waterIndex) {
      < 0.2 => '💧 No watering needed (sufficient moisture)',
      < 0.4 => '💧 Light watering',
      < 0.6 => '💧💧 Moderate watering',
      < 0.8 => '💧💧💧 Heavy watering',
      _ => '💧💧💧💧 Frequent watering (very dry)',
    };

    return '$recommendation\n${weather.toString()}';
  }

String get assetPath => switch (seed) {
    Seed.cauliflower => switch (growthStage) {
      GrowthStage.seedling => 'assets/maja/b1.png',
      GrowthStage.sprout => 'assets/maja/b2.png',
      GrowthStage.flowering => 'assets/maja/b3.png',
      GrowthStage.mature => 'assets/maja/b4.png',
    },
    Seed.carrot => switch (growthStage) {
      GrowthStage.seedling => 'assets/maja/f1.png',
      GrowthStage.sprout => 'assets/maja/f2.png',
      GrowthStage.flowering || GrowthStage.mature => 'assets/maja/f3.png',
    },
    Seed.cucumber => switch (growthStage) {
      GrowthStage.seedling => 'assets/maja/e1.png',
      GrowthStage.sprout => 'assets/maja/e2.png',
      GrowthStage.flowering => 'assets/maja/e3.png',
      GrowthStage.mature => 'assets/maja/e4.png',
    },
    _ => switch (growthStage) {
      GrowthStage.seedling => 'assets/maja/tile000.png',
      GrowthStage.sprout => 'assets/maja/tile001.png',
      GrowthStage.flowering => 'assets/maja/tile002.png',
      GrowthStage.mature => 'assets/maja/tile003.png',
    },
  };

  String get growthInfo {
    final elapsed = DateTime.now().difference(plantedAt).inSeconds;
    final stage = growthStage;
    final weatherStatus = _lastWeather != null
        ? '\nWeather impact: ${(_lastWeather!.growthMultiplier * 100).toStringAsFixed(0)}%'
        : '';
    return '${seed.asCharacter} ${seed.name}\n'
        'Stage: ${stage.displayName}\n'
        'Planted ${elapsed}s ago$weatherStatus';
  }
}
