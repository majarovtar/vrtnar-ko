import 'package:flutter/foundation.dart';

import 'seed.dart';

class DeadPlant {
  final SeedLike seed;
  final String? name;
  final DateTime removedAt;

  const DeadPlant({required this.seed, this.name, required this.removedAt});
}

class Graveyard extends ChangeNotifier {
  final List<DeadPlant> _plants = [];

  List<DeadPlant> get plants => List.unmodifiable(_plants);

  void add(DeadPlant plant) {
    _plants.add(plant);
    notifyListeners();
  }
}
