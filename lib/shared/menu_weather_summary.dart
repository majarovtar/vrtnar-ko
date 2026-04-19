import 'package:flutter/material.dart';
import '../api/weather_service.dart';

class MenuWeatherSummary extends StatefulWidget {
  const MenuWeatherSummary({super.key});

  @override
  State<MenuWeatherSummary> createState() => _MenuWeatherSummaryState();
}

class _MenuWeatherSummaryState extends State<MenuWeatherSummary> {
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
        final theme = Theme.of(context);

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Text(
              'Loading weather...',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
            ),
          );
        }

        final weather = snapshot.data;
        if (snapshot.hasError || weather == null) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Text(
              'Weather unavailable',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: Colors.black54),
            ),
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Weather',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              _menuRow(
                '🌡️',
                '${weather.temperature.toStringAsFixed(1)}°C',
                'Current air temperature',
              ),
              _menuRow(
                '💧',
                '${weather.humidity.toStringAsFixed(0)}% / ${weather.rainfall.toStringAsFixed(1)}mm',
                'Humidity percentage and rainfall amount in mm',
              ),
              _menuRow(
                '💨',
                '${weather.windSpeed.toStringAsFixed(1)} km/h',
                'Current wind speed',
              ),
              _menuRow(
                '🌱',
                '${(weather.growthMultiplier * 100).toStringAsFixed(0)}%',
                'How weather affects plant growth speed',
              ),
              const SizedBox(height: 4),
              Tooltip(
                message: 'Watering need based on temp, humidity, rain, and wind',
                child: Text(
                  'Water ${(weather.wateringNeeds * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _menuRow(String icon, String text, String tooltip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Expanded(
            child: Tooltip(
              message: tooltip,
              child: Text(
                text,
                style: const TextStyle(fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
