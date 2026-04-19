import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/soil_humidity_service.dart';
import '../game_internals/board_state.dart';

class SoilHumidityAlert extends StatefulWidget {
  const SoilHumidityAlert({super.key});

  @override
  State<SoilHumidityAlert> createState() => _SoilHumidityAlertState();
}

class _SoilHumidityAlertState extends State<SoilHumidityAlert>
    with WidgetsBindingObserver {
  final SoilHumidityService _service = SoilHumidityService();
  DateTime? _lastAlertTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _startChecking();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startChecking() {
    _checkSoilHumidity();
    _scheduleNextCheck();
  }

  void _scheduleNextCheck() {
    Future.delayed(const Duration(minutes: 30), () {
      if (mounted) {
        _checkSoilHumidity();
        _scheduleNextCheck();
      }
    });
  }

  void _checkSoilHumidity() async {
    try {
      final reading = await _service.getLatestReading();

      if (mounted && reading != null && reading.humidity < 10) {
        final boardState = context.read<BoardState>();
        final hasPlant = boardState.areas.any((area) => area.plant != null);

        if (hasPlant) {
          final now = DateTime.now();
          final shouldShow = _lastAlertTime == null ||
              now.difference(_lastAlertTime!).inSeconds > 60;

          if (shouldShow) {
            _lastAlertTime = now;
            _showAlert(reading.humidity);
          }
        }
      }
    } catch (e) {
      print('[SoilHumidityAlert] Error: $e');
    }
  }

  void _showAlert(int humidity) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Soil Too Dry! Humidity: $humidity% — your plants may need water!',
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
