import 'package:flutter/material.dart';
import '../api/weather_service.dart';

/// Compact weather panel for the settings screen
class CompactWeatherPanel extends StatefulWidget {
  const CompactWeatherPanel({super.key});

  @override
  State<CompactWeatherPanel> createState() => _CompactWeatherPanelState();
}

class _CompactWeatherPanelState extends State<CompactWeatherPanel> {
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
          return const SizedBox(
            width: 200,
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Container(
            width: 200,
            height: 150,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Weather\nunavailable',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ),
          );
        }

        final weather = snapshot.data!;
        return Container(
          width: 200,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Weather',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildInfoRow('🌡️', '${weather.temperature.toStringAsFixed(1)}°C'),
              _buildInfoRow('💧', '${weather.humidity.toStringAsFixed(0)}% / ${weather.rainfall.toStringAsFixed(1)}mm'),
              _buildInfoRow('💨', '${weather.windSpeed.toStringAsFixed(1)} km/h'),
              _buildInfoRow('🌱', '${(weather.growthMultiplier * 100).toStringAsFixed(0)}%'),
              _buildWateringIndicator(weather.wateringNeeds),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWateringIndicator(double needs) {
    return Row(
      children: [
        const Text('💧', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: List.generate(
              5,
              (index) => Expanded(
                child: Container(
                  height: 6,
                  margin: const EdgeInsets.only(right: 2),
                  decoration: BoxDecoration(
                    color: index < needs * 5
                        ? needs > 0.8
                            ? Colors.red
                            : needs > 0.6
                                ? Colors.orange
                                : Colors.blue
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}