enum Seed implements SeedLike {
  tomato(1, 'Tomato', '🍅', SeedColor.red),
  basil(2, 'Basil', '🌿', SeedColor.green),
  pepper(3, 'Pepper', '🌶️', SeedColor.red),
  lettuce(4, 'Lettuce', '🥬', SeedColor.green);

  @override
  final int internalRepresentation;
  @override
  final String displayName;
  @override
  final String emoji;
  @override
  final SeedColor color;

  const Seed(this.internalRepresentation, this.displayName, this.emoji, this.color);

  @override
  String get asCharacter => emoji;

  @override
  String get name => displayName;

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
