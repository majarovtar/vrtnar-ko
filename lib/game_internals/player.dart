import 'package:flutter/foundation.dart';

import 'playing_card.dart';
import 'seed.dart';

class Player extends ChangeNotifier {
  static const maxCards = 4;

  final List<PlayingCard> hand = _generateHand();

  static List<PlayingCard> _generateHand() {
    final hand = <PlayingCard>[];
    
    // One of each seed type
    for (int i = 0; i < Seed.values.length; i++) {
      final seed = Seed.values[i];
      hand.add(PlayingCard(seed, 5 + i));
    }
    
    return hand;
  }

  void addCard(PlayingCard card) {
    hand.add(card);
    notifyListeners();
  }

  void removeCard(PlayingCard card) {
    hand.remove(card);
    notifyListeners();
  }
}
