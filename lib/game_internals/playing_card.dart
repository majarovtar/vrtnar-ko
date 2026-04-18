import 'package:flutter/foundation.dart';

import 'seed.dart';

@immutable
class PlayingCard {
  final Seed seed;

  final int value;

  const PlayingCard(this.seed, this.value);

  @override
  int get hashCode => Object.hash(seed, value);

  @override
  bool operator ==(Object other) {
    return other is PlayingCard && other.seed == seed && other.value == value;
  }

  @override
  String toString() {
    return '${seed.name} $value';
  }
}
