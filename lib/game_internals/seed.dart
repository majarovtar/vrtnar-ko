enum Seed {
  tomato(1),
  basil(2),
  pepper(3),
  lettuce(4);

  final int internalRepresentation;

  const Seed(this.internalRepresentation);

  String get asCharacter => switch (this) {
    Seed.basil => '🌿',
    Seed.pepper => '🌶️',
    Seed.tomato => '🍅',
    Seed.lettuce => '🥬',
  };

  SeedColor get color => switch (this) {
    Seed.basil || Seed.lettuce => SeedColor.green,
    Seed.tomato || Seed.pepper => SeedColor.red,
  };

  String get name => switch (this) {
    Seed.tomato => 'Tomato',
    Seed.basil => 'Basil',
    Seed.pepper => 'Pepper',
    Seed.lettuce => 'Lettuce',
  };

  @override
  String toString() => asCharacter;
}

enum SeedColor { green, red }
