import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game_internals/board_state.dart';
import '../game_internals/playing_area.dart';

class WateringReminder extends StatefulWidget {
  const WateringReminder({super.key});

  @override
  State<WateringReminder> createState() => _WateringReminderState();
}

class _WateringReminderState extends State<WateringReminder> {
  final Map<PlayingArea, Timer> _wateringTimers = {};
  final Map<PlayingArea, StreamSubscription<void>> _areaSubscriptions = {};
  final Set<PlayingArea> _showingNotification = {};
  late final BoardState _boardState;

  @override
  void initState() {
    super.initState();
    _boardState = context.read<BoardState>();
    _boardState.addListener(_onBoardChanged);
    _onBoardChanged();
  }

  @override
  void dispose() {
    _boardState.removeListener(_onBoardChanged);
    for (final timer in _wateringTimers.values) {
      timer.cancel();
    }
    for (final sub in _areaSubscriptions.values) {
      sub.cancel();
    }
    _wateringTimers.clear();
    _areaSubscriptions.clear();
    _showingNotification.clear();
    super.dispose();
  }

  void _onBoardChanged() {
    final currentAreas = _boardState.areas.toSet();

    // Subscribe to new areas.
    for (final area in currentAreas) {
      if (!_areaSubscriptions.containsKey(area)) {
        _areaSubscriptions[area] = area.allChanges.listen((_) {
          _syncTimerForArea(area);
        });
        // Check initial state.
        _syncTimerForArea(area);
      }
    }

    // Clean up removed areas.
    for (final area in _areaSubscriptions.keys.toList()) {
      if (!currentAreas.contains(area)) {
        _areaSubscriptions[area]?.cancel();
        _areaSubscriptions.remove(area);
        _wateringTimers[area]?.cancel();
        _wateringTimers.remove(area);
        _showingNotification.remove(area);
      }
    }
  }

  void _syncTimerForArea(PlayingArea area) {
    if (area.plant != null && !area.plant!.watered &&
        !_wateringTimers.containsKey(area)) {
      // Plant was added and not yet watered — start a watering timer.
      _wateringTimers[area] = Timer.periodic(
        const Duration(seconds: 10),
        (_) => _showReminder(area),
      );
    } else if ((area.plant == null || area.plant!.watered) &&
        _wateringTimers.containsKey(area)) {
      // Plant was removed or watered — cancel the timer.
      _wateringTimers[area]?.cancel();
      _wateringTimers.remove(area);
      _showingNotification.remove(area);
    }
  }

  void _showReminder(PlayingArea area) {
    if (!mounted) return;
    if (area.plant == null || area.plant!.watered) {
      _wateringTimers[area]?.cancel();
      _wateringTimers.remove(area);
      _showingNotification.remove(area);
      return;
    }
    // Don't stack notifications for the same plant.
    if (_showingNotification.contains(area)) return;

    _showingNotification.add(area);
    final seed = area.plant!.seed;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${seed.asCharacter} ${seed.name} needs watering!'),
        duration: const Duration(days: 365),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        action: SnackBarAction(
          label: 'I watered',
          onPressed: () {
            area.plant?.watered = true;
            _wateringTimers[area]?.cancel();
            _wateringTimers.remove(area);
            _showingNotification.remove(area);
          },
        ),
      ),
    ).closed.then((_) {
      _showingNotification.remove(area);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
