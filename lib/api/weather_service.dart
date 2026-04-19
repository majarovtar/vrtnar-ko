import 'package:http/http.dart' as http;
import 'dart:convert';

/// Weather data retrieved from Open-Meteo API
class WeatherData {
  final double temperature; // in Celsius
  final double humidity; // percentage (0-100)
  final double rainfall; // mm
  final double windSpeed; // km/h
  final int weatherCode; // WMO code
  final DateTime timestamp;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.rainfall,
    required this.windSpeed,
    required this.weatherCode,
    required this.timestamp,
  });

  /// Determine if it's raining based on WMO weather code
  bool get isRaining => weatherCode >= 51 && weatherCode <= 67;

  /// Determine if it's very hot (above 30°C)
  bool get isVeryHot => temperature > 30;

  /// Determine if it's freezing (below 0°C)
  bool get isFreezing => temperature < 0;

  /// Get a growth multiplier based on weather conditions
  /// Used to speed up or slow down plant growth
  double get growthMultiplier {
    double multiplier = 1.0;

    // Temperature impact (optimal: 15-25°C)
    if (temperature < 5 || temperature > 35) {
      multiplier *= 0.5; // Extreme temperatures slow growth
    } else if (temperature < 10 || temperature > 30) {
      multiplier *= 0.8; // Non-ideal but acceptable
    }

    // Humidity impact (optimal: 40-70%)
    if (humidity < 30 || humidity > 85) {
      multiplier *= 0.7; // Too dry or too wet
    }

    // Wind impact (high wind stresses plants)
    if (windSpeed > 30) {
      multiplier *= 0.6;
    }

    // Rainfall (helps plants but too much can cause issues)
    if (rainfall > 50) {
      multiplier *= 0.8; // Heavy rain can damage plants
    }

    return multiplier;
  }

  /// Watering needs based on weather (0.0 to 1.0)
  /// 1.0 means plant needs heavy watering, 0.0 means no watering needed
  double get wateringNeeds {
    double needs = 0.5; // baseline

    // Very hot weather increases water needs
    if (temperature > 25) {
      needs += (temperature - 25) * 0.05;
    }

    // Low humidity increases water needs
    if (humidity < 50) {
      needs += (50 - humidity) * 0.01;
    }

    // Rain reduces watering needs
    if (rainfall > 0) {
      needs -= rainfall * 0.01;
    }

    // High wind increases evaporation, increasing needs
    if (windSpeed > 15) {
      needs += (windSpeed - 15) * 0.02;
    }

    return needs.clamp(0.0, 1.0);
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current_weather'] as Map<String, dynamic>?;
    final hourly = json['hourly'] as Map<String, dynamic>?;

    final timestamp = DateTime.tryParse(current?['time']?.toString() ?? '') ?? DateTime.now();
    final hourlyTimes = (hourly?['time'] as List<dynamic>?)?.map((e) => e?.toString()).toList() ?? [];
    final index = hourlyTimes.indexWhere((time) => time == current?['time']?.toString());

    double hourlyValue(String key) {
      final series = hourly?[key] as List<dynamic>?;
      if (series == null || index < 0 || index >= series.length) {
        return 0.0;
      }
      return (series[index] as num?)?.toDouble() ?? 0.0;
    }

    return WeatherData(
      temperature: (current?['temperature'] as num?)?.toDouble() ?? 0.0,
      humidity: hourlyValue('relativehumidity_2m'),
      rainfall: hourlyValue('precipitation'),
      windSpeed: (current?['windspeed'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (current?['weathercode'] as num?)?.toInt() ?? 0,
      timestamp: timestamp,
    );
  }

  @override
  String toString() => 'WeatherData(temp: ${temperature.toStringAsFixed(1)}°C, '
      'humidity: ${humidity.toStringAsFixed(0)}%, rain: ${rainfall.toStringAsFixed(1)}mm, '
      'wind: ${windSpeed.toStringAsFixed(1)}km/h)';
}

class WeatherService {
  static final WeatherService _instance = WeatherService._();
  factory WeatherService() => _instance;
  WeatherService._();

  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  /// Fetch current weather for a given location
  /// 
  /// [latitude] and [longitude] are required
  /// Example: getWeather(latitude: 48.8566, longitude: 2.3522) for Paris
  Future<WeatherData?> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl?latitude=$latitude&longitude=$longitude&current_weather=true&'
          'hourly=relativehumidity_2m,precipitation&'
          'windspeed_unit=kmh&timezone=auto',
        ),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherData.fromJson(data);
      }
    } catch (e) {
      print('Error fetching weather: $e');
    }
    return null;
  }

  /// Get weather for a default location (currently using Paris as example)
  /// In a real app, this would use device location or user settings
  Future<WeatherData?> getDefaultLocationWeather() async {
    // Default location: Paris, France
    return getWeather(latitude: 48.8566, longitude: 2.3522);
  }
}
