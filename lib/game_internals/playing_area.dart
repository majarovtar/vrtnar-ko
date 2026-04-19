import 'dart:async';

import 'package:async/async.dart';

import 'plant.dart';
import 'seed.dart';

class PlayingArea {
  /// The current plant in this area, if any.
  Plant? plant;

  /// Position on the board (relative to the board's top-left).
  double x;
  double y;

  final StreamController<void> _playerChanges =
      StreamController<void>.broadcast();

  final StreamController<void> _remoteChanges =
      StreamController<void>.broadcast();

  PlayingArea({this.x = 0, this.y = 0});

  /// A [Stream] that fires an event every time any change to this area is made.
  Stream<void> get allChanges =>
      StreamGroup.mergeBroadcast([remoteChanges, playerChanges]);

  /// A [Stream] that fires an event every time a change is made _locally_,
  /// by the player.
  Stream<void> get playerChanges => _playerChanges.stream;

  /// A [Stream] that fires an event every time a change is made _remotely_,
  /// by another player.
  Stream<void> get remoteChanges => _remoteChanges.stream;

  /// Plants a [seed] in this area with an optional [name].
  void plantSeed(SeedLike seed, {String? name}) {
    plant = Plant(seed: seed, name: name);
    _playerChanges.add(null);
  }

  /// Removes the plant from this area.
  void removePlant() {
    plant = null;
    _playerChanges.add(null);
  }

  void dispose() {
    _remoteChanges.close();
    _playerChanges.close();
  }
}
