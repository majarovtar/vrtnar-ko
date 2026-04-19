import 'package:flutter/foundation.dart';

import 'player.dart';
import 'playing_area.dart';

class BoardState extends ChangeNotifier {
  final VoidCallback onWin;

  final List<PlayingArea> areas = [];

  final Player player = Player();

  BoardState({required this.onWin}) {
    player.addListener(_handlePlayerChange);
  }

  void addArea({double x = 0, double y = 0}) {
    areas.add(PlayingArea(x: x, y: y));
    notifyListeners();
  }

  void removeArea(PlayingArea area) {
    area.dispose();
    areas.remove(area);
    notifyListeners();
  }

  void dispose() {
    player.removeListener(_handlePlayerChange);
    for (final area in areas) {
      area.dispose();
    }
  }

  void _handlePlayerChange() {
    if (player.hand.isEmpty) {
      onWin();
    }
  }
}
