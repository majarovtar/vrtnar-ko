enum Seed {
  grapes(1),
  cauliflower(2),
  carrot(3),
  cucumber(4);

  @override
  final int internalRepresentation;

  const Seed(this.internalRepresentation);

  String get asCharacter => switch (this) {
    Seed.cauliflower => '🥦',
    Seed.carrot => '🥕',
    Seed.grapes => '🍇',
    Seed.cucumber => '🥒',
  };

  SeedColor get color => switch (this) {
    Seed.cauliflower || Seed.cucumber => SeedColor.green,
    Seed.grapes || Seed.carrot => SeedColor.red,
  };

  String get name => switch (this) {
    Seed.grapes => 'Grapes',
    Seed.cauliflower => 'Cauliflower',
    Seed.carrot => 'Carrot',
    Seed.cucumber => 'Cucumber',
  };

  String get seedImageAsset => switch (this) {
    Seed.grapes => 'assets/maja/grapes.png',
    Seed.cauliflower => 'assets/maja/cauliflowe.png',
    Seed.carrot => 'assets/maja/carrot.png',
    Seed.cucumber => 'assets/maja/cucumber.png',
  };

  @override
  String toString() => asCharacter;
}

abstract class SeedLike {
  int get internalRepresentation;
  String get displayName;
  String get emoji;
  SeedColor get color;
  String get name;
  String get asCharacter;
}

class CustomSeed implements SeedLike {
  @override
  final int internalRepresentation;

  @override
  final String displayName;

  @override
  final String emoji;

  @override
  final SeedColor color;

  final int plantId;
  final String? imageUrl;

  CustomSeed({
    required this.plantId,
    required this.displayName,
    this.emoji = '🌱',
    this.color = SeedColor.green,
    this.imageUrl,
  }) : internalRepresentation = plantId + 1000;

  @override
  String get asCharacter => emoji;

  @override
  String get name => displayName;

  @override
  int get hashCode => Object.hash(plantId, displayName);

  @override
  bool operator ==(Object other) {
    return other is CustomSeed && other.plantId == plantId;
  }

  @override
  String toString() => emoji;
}

enum SeedColor { green, red }
