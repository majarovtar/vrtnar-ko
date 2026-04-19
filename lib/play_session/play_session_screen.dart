import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart' hide Level;
import 'package:provider/provider.dart';

import '../shared/menu_weather_summary.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../game_internals/board_state.dart';
import '../game_internals/score.dart';
import '../style/confetti.dart';
import '../style/palette.dart';
import 'board_widget.dart';
import 'player_hand_widget.dart';
import 'soil_humidity_alert.dart';
import 'watering_reminder.dart';

class PlaySessionScreen extends StatefulWidget {
  const PlaySessionScreen({super.key});

  @override
  State<PlaySessionScreen> createState() => _PlaySessionScreenState();
}

class _PlaySessionScreenState extends State<PlaySessionScreen> {
  static final _log = Logger('PlaySessionScreen');

  static const _celebrationDuration = Duration(milliseconds: 2000);

  static const _preCelebrationDuration = Duration(milliseconds: 500);

  bool _duringCelebration = false;

  late DateTime _startOfPlay;

  late final BoardState _boardState;

  bool _isMenuOpen = true;
  bool _isSeedBoxOpen = true;

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: _boardState)],
      child: IgnorePointer(
        ignoring: _duringCelebration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/zahod.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              Row(
                children: [
                  _buildMenuPanel(palette),
                  Expanded(child: _buildGarden()),
                  _buildSeedBox(palette),
                ],
              ),
              SizedBox.expand(
                child: Visibility(
                  visible: _duringCelebration,
                  child: IgnorePointer(
                    child: Confetti(isStopped: !_duringCelebration),
                  ),
                ),
              ),
              const SoilHumidityAlert(),
              const WateringReminder(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuPanel(Palette palette) {
    return Container(
      width: _isMenuOpen ? 220 : 56,
      decoration: BoxDecoration(
        color: palette.backgroundMain.withValues(alpha: 0.85),
        border: Border(
          right: BorderSide(color: palette.ink.withValues(alpha: 0.15)),
        ),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 56,
              child: _isMenuOpen
                  ? Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text(
                            'Menu',
                            style: TextStyle(
                              fontFamily: 'Permanent Marker',
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () =>
                              setState(() => _isMenuOpen = false),
                        ),
                      ],
                    )
                  : Center(
                      child: IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () =>
                            setState(() => _isMenuOpen = true),
                      ),
                    ),
            ),
            if (_isMenuOpen) ...[
              _menuItem(
                Icons.yard,
                'My balcony',
                () => GoRouter.of(context).go('/home'),
              ),
              _menuItem(
                Icons.calendar_month,
                'Calendar',
                () => GoRouter.of(context).go('/home/calendar'),),
              _menuItem(
                Icons.location_city,
                'City',
                () => GoRouter.of(context).go('/home/city'),
              ),
              _menuItem(Icons.settings, 'Settings', null),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: MenuWeatherSummary(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback? onTap) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      onTap: onTap,
      enabled: onTap != null,
      dense: true,
    );
  }

  Widget _buildGarden() {
    return Stack(
        children: [
          Positioned.fill(
            child: Transform.scale(
              scale: 1.0,
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                'assets/images/buildings/balkonF1.png',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.none,
              ),
            ),
          ),
          SafeArea(
            left: false,
            right: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Expanded(child: BoardWidget()),
                const Text('Drag seeds into the garden above.'),
              ],
            ),
        ),
      ],
    );
  }

  Widget _buildSeedBox(Palette palette) {
    return Container(
      width: _isSeedBoxOpen ? 320 : 56,
      decoration: BoxDecoration(
        color: palette.backgroundLevelSelection.withValues(alpha: 0.85),
        border: Border(
          left: BorderSide(color: palette.ink.withValues(alpha: 0.15)),
        ),
      ),
      child: SafeArea(
        left: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 56,
              child: _isSeedBoxOpen
                  ? Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text(
                            'Seeds',
                            style: TextStyle(
                              fontFamily: 'Permanent Marker',
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () =>
                              setState(() => _isSeedBoxOpen = false),
                        ),
                      ],
                    )
                  : Center(
                      child: IconButton(
                        icon: const Icon(Icons.eco),
                        onPressed: () =>
                            setState(() => _isSeedBoxOpen = true),
                      ),
                    ),
            ),
            if (_isSeedBoxOpen)
              const Expanded(child: PlayerHandWidget()),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _boardState.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _startOfPlay = DateTime.now();
    _boardState = BoardState(onWin: _playerWon);
  }

  Future<void> _playerWon() async {
    _log.info('Player won');

    final score = Score(1, 1, DateTime.now().difference(_startOfPlay));

    await Future<void>.delayed(_preCelebrationDuration);
    if (!mounted) return;

    setState(() {
      _duringCelebration = true;
    });

    final audioController = context.read<AudioController>();
    audioController.playSfx(SfxType.congrats);

    await Future<void>.delayed(_celebrationDuration);
    if (!mounted) return;

    GoRouter.of(context).go('/home/won', extra: {'score': score});
  }
}
