import 'package:http/http.dart' as http;
import 'dart:convert';

class SoilHumidityService {
  static const String _baseUrl = 'http://127.0.0.1:5000/api';

  static final SoilHumidityService _instance = SoilHumidityService._();
  factory SoilHumidityService() => _instance;
  SoilHumidityService._();

  /// Fetch the latest soil humidity reading
  Future<SoilReading?> getLatestReading() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/soil-humidity/latest'),
      ).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['reading'] != null) {
          return SoilReading.fromJson(
            data['reading'] as Map<String, dynamic>,
          );
        }
      }
      return null;
    } catch (e) {
      print('Error fetching soil humidity: $e');
      return null;
    }
  }

  /// Get average humidity over recent readings
  Future<double?> getAverageHumidity({int count = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/soil-humidity/average?count=$count'),
      ).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return (data['average_humidity'] as num?)?.toDouble();
      }
      return null;
    } catch (e) {
      print('Error fetching average humidity: $e');
      return null;
    }
  }
}

class SoilReading {
  final int id;
  final int humidity;
  final int? deviceTimestamp;
  final String serverTimestamp;
  final String receivedAt;

  SoilReading({
    required this.id,
    required this.humidity,
    this.deviceTimestamp,
    required this.serverTimestamp,
    required this.receivedAt,
  });

  factory SoilReading.fromJson(Map<String, dynamic> json) {
    return SoilReading(
      id: json['id'] as int,
      humidity: (json['humidity'] as num).toInt(),
      deviceTimestamp: json['device_timestamp'] as int?,
      serverTimestamp: json['server_timestamp'] as String,
      receivedAt: json['received_at'] as String,
    );
  }
}
