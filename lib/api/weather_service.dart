import 'package:http/http.dart' as http;
import 'dart:convert';

/// Weather data retrieved from Open-Meteo API
class WeatherData {
  final double temperature; // in Celsius
  final double humidity; // percentage (0-100)
  final double rainfall; // mm
  final double windSpeed; // km/h
  final int weatherCode; // WMO code
  final double airQuality; // PM2.5 in µg/m³
  final DateTime timestamp;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.rainfall,
    required this.windSpeed,
    required this.weatherCode,
    required this.airQuality,
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

  /// Get air quality level description based on AQI
  /// Returns a user-friendly label (Good, Moderate, Bad)
  String get airQualityLevel {
    if (airQuality <= 50) return 'Good';
    if (airQuality <= 100) return 'Moderate';
    return 'Bad';
  }

  /// Get air quality emoji based on AQI level
  String get airQualityEmoji {
    if (airQuality <= 50) return '😊'; // Good - happy face
    if (airQuality <= 100) return '😐'; // Moderate - neutral face
    return '😷'; // Bad - mask face
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
      // Get weather data from Open-Meteo
      final weatherResponse = await http.get(
        Uri.parse(
          '$_baseUrl?latitude=$latitude&longitude=$longitude&current_weather=true&'
          'hourly=relativehumidity_2m,precipitation&'
          'windspeed_unit=kmh&timezone=auto',
        ),
      ).timeout(const Duration(seconds: 5));

      if (weatherResponse.statusCode != 200) {
        return null;
      }

      final weatherData = jsonDecode(weatherResponse.body) as Map<String, dynamic>;

      // Get air quality data from WAQI
      double airQuality = 0.0;
      try {
        final airQualityResponse = await http.get(
          Uri.parse('https://api.waqi.info/feed/ljubljana/?token=demo'),
        ).timeout(const Duration(seconds: 5));

        if (airQualityResponse.statusCode == 200) {
          final airQualityData = jsonDecode(airQualityResponse.body) as Map<String, dynamic>;
          if (airQualityData['status'] == 'ok') {
            // Try to get PM2.5 directly, fallback to AQI if not available
            final iaqi = airQualityData['data']['iaqi'] as Map<String, dynamic>?;
            airQuality = (iaqi?['pm25']?['v'] as num?)?.toDouble() ?? 
                        (airQualityData['data']['aqi'] as num?)?.toDouble() ?? 0.0;
          }
        }
      } catch (e) {
        // Air quality fetch failed, continue with weather data only
        print('Failed to fetch air quality: $e');
      }

      // Create WeatherData with combined data
      final current = weatherData['current_weather'] as Map<String, dynamic>?;
      final hourly = weatherData['hourly'] as Map<String, dynamic>?;
      
      final timestamp = DateTime.tryParse(current?['time']?.toString() ?? '') ?? DateTime.now();
      final hourlyTimes = (hourly?['time'] as List<dynamic>?)?.map((e) => e?.toString()).toList() ?? [];
      
      // Find the closest hourly time to current weather time
      int findClosestIndex() {
        if (hourlyTimes.isEmpty) return -1;
        final currentTime = DateTime.tryParse(current?['time']?.toString() ?? '');
        if (currentTime == null) return 0;
        
        int closestIndex = 0;
        Duration smallestDiff = Duration(days: 365);
        
        for (int i = 0; i < hourlyTimes.length; i++) {
          final timeString = hourlyTimes[i];
          if (timeString != null) {
            final hourlyTime = DateTime.tryParse(timeString);
            if (hourlyTime != null) {
              final diff = (hourlyTime.difference(currentTime)).abs();
              if (diff < smallestDiff) {
                smallestDiff = diff;
                closestIndex = i;
              }
            }
          }
        }
        return closestIndex;
      }
      
      final index = findClosestIndex();

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
        airQuality: airQuality,
        timestamp: timestamp,
      );
    } catch (e) {
      print('Error fetching weather: $e');
    }
    return null;
  }

  /// Get weather for a default location (Ljubljana, Slovenia)
  /// In a real app, this would use device location or user settings
  Future<WeatherData?> getDefaultLocationWeather() async {
    // Default location: Ljubljana, Slovenia
    return getWeather(latitude: 46.0569, longitude: 14.5058);
  }
}
