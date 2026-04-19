import 'package:flutter/material.dart';
import '../api/weather_service.dart';

/// Example widget showing how to use the WeatherService
/// 
/// This demonstrates:
/// - Fetching weather data
/// - Displaying weather information
/// - Using weather data to affect gameplay
class WeatherInfoWidget extends StatefulWidget {
  const WeatherInfoWidget({super.key});

  @override
  State<WeatherInfoWidget> createState() => _WeatherInfoWidgetState();
}

class _WeatherInfoWidgetState extends State<WeatherInfoWidget> {
  late Future<WeatherData?> weatherFuture;

  @override
  void initState() {
    super.initState();
    weatherFuture = WeatherService().getDefaultLocationWeather();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeatherData?>(
      future: weatherFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Text('Failed to load weather: ${snapshot.error}'),
          );
        }

        final weather = snapshot.data!;
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Weather',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                _buildWeatherCard(
                  icon: '🌡️',
                  label: 'Temperature',
                  value: '${weather.temperature.toStringAsFixed(1)}°C',
                ),
                _buildWeatherCard(
                  icon: '💧',
                  label: 'Humidity',
                  value: '${weather.humidity.toStringAsFixed(0)}%',
                ),
                _buildWeatherCard(
                  icon: '🌧️',
                  label: 'Rainfall',
                  value: '${weather.rainfall.toStringAsFixed(1)} mm',
                ),
                _buildWeatherCard(
                  icon: '💨',
                  label: 'Wind Speed',
                  value: '${weather.windSpeed.toStringAsFixed(1)} km/h',
                ),
                const SizedBox(height: 24),
                Text(
                  'Plant Growth Impact',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Growth Multiplier: ${(weather.growthMultiplier * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        weather.growthMultiplier >= 0.95
                            ? '✅ Optimal growth conditions'
                            : weather.growthMultiplier >= 0.75
                                ? '⚠️ Good conditions'
                                : weather.growthMultiplier >= 0.5
                                    ? '⚠️ Suboptimal conditions'
                                    : '❌ Poor growth conditions',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.purple),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Air Quality:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${weather.airQuality.toStringAsFixed(1)} µg/m³ PM2.5',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        weather.airQualityEmoji,
                        style: const TextStyle(fontSize: 20, fontFamily: 'Noto Color Emoji'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.grey[200],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'How it Works:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '• Growth multiplier affects plant growth speed\n'
                        '  - Optimal temp: 15-25°C\n'
                        '  - Extreme temps or weather slow growth\n\n'
                        '• Air quality (AQI) indicates pollution level\n'
                        '  - 😊 Good: 0-50 (safe)\n'
                        '  - 😐 Moderate: 51-100 (acceptable)\n'
                        '  - 😷 Bad: 101+ (unhealthy)\n'
                        '  - Shows only emoji + number\n\n'
                        '• Weather data is cached for 5 minutes\n'
                        '  to avoid excessive API calls',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherCard({
    required String icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Text(label),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
