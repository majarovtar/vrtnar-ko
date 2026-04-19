import 'package:flutter/material.dart';
import '../api/soil_humidity_service.dart';
import '../style/palette.dart';

class SoilHumidityAlert extends StatefulWidget {
  const SoilHumidityAlert({super.key});

  @override
  State<SoilHumidityAlert> createState() => _SoilHumidityAlertState();
}

class _SoilHumidityAlertState extends State<SoilHumidityAlert>
    with WidgetsBindingObserver {
  final SoilHumidityService _service = SoilHumidityService();
  int _lastAlertedHumidity = -1;
  DateTime? _lastAlertTime;

  @override
  void initState() {
    super.initState();
    print('[SoilHumidityAlert] Initializing...');
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
    print('[SoilHumidityAlert] Starting humidity checks...');
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
      print('[SoilHumidityAlert] Checking soil humidity...');
      final reading = await _service.getLatestReading();
      
      if (mounted) {
        if (reading != null) {
          print('[SoilHumidityAlert] Got reading: ${reading.humidity}%');
          
          // Show alert if humidity exceeds 20% and we haven't shown it recently
          if (reading.humidity > 20) {
            final now = DateTime.now();
            final shouldShow = _lastAlertTime == null ||
                now.difference(_lastAlertTime!).inSeconds > 60;
            
            if (shouldShow) {
              print('[SoilHumidityAlert] Humidity > 20%, showing alert!');
              _lastAlertTime = now;
              _showAlert(reading.humidity);
            }
          } else if (reading.humidity <= 20) {
            print('[SoilHumidityAlert] Humidity OK (${reading.humidity}%), no alert');
          }
        } else {
          print('[SoilHumidityAlert] No reading received');
        }
      }
    } catch (e) {
      print('[SoilHumidityAlert] Error: $e');
    }
  }

  void _showAlert(int humidity) {
    print('[SoilHumidityAlert] Showing alert dialog...');
    final palette = Theme.of(context).extension<Palette>();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: palette?.backgroundMain ?? Colors.white,
        title: Row(
          children: [
            const Icon(
              Icons.warning_rounded,
              color: Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Soil Too Dry!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current humidity: $humidity%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'The soil humidity exceeds 20%. Your plants may need water soon!',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('[SoilHumidityAlert] Alert dismissed');
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This widget doesn't render anything, it just manages the alert
    return const SizedBox.shrink();
  }
}
