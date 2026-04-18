import 'city_building.dart';

class CityState {
  final List<CityBuilding> buildings;

  const CityState({
    required this.buildings,
  });

  factory CityState.initial() {
    return const CityState(
      buildings: [
        CityBuilding(
          id: 'home',
          name: 'Your Building',
          type: BuildingType.playerHome,
          x: 80,
          y: 260,
        ),
        CityBuilding(
          id: 'friend_1',
          name: 'Maya\'s Balcony',
          type: BuildingType.friendHome,
          x: 220,
          y: 230,
        ),
        CityBuilding(
          id: 'public_1',
          name: 'Community Garden',
          type: BuildingType.publicGarden,
          x: 360,
          y: 210,
        ),
        CityBuilding(
          id: 'market',
          name: 'Marketplace',
          type: BuildingType.marketplace,
          x: 120,
          y: 80,
        ),
        CityBuilding(
          id: 'cemetery',
          name: 'Plant Cemetery',
          type: BuildingType.cemetery,
          x: 320,
          y: 90,
        ),
      ],
    );
  }
}