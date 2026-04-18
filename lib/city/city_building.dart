enum BuildingType {
  playerHome,
  friendHome,
  publicGarden,
  marketplace,
  cemetery,
}

class CityBuilding {
  final String id;
  final String name;
  final BuildingType type;
  final double x;
  final double y;

  const CityBuilding({
    required this.id,
    required this.name,
    required this.type,
    required this.x,
    required this.y,
  });
}