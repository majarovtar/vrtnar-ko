import 'package:flutter/foundation.dart';

import 'seed.dart';

@immutable
class PlayingCard {
  final SeedLike seed;

  final int value;

  PlayingCard(this.seed, this.value) : assert(value >= 1 && value <= 10);

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
