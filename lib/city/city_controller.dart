import 'package:flutter/material.dart';
import 'city_building.dart';
import 'city_state.dart';

class CityController extends ChangeNotifier {
  CityState state = CityState.initial();

  void onBuildingTapped(BuildContext context, CityBuilding building) {
    switch (building.type) {
      case BuildingType.playerHome:
        Navigator.pushNamed(context, '/balcony');
        break;
      case BuildingType.friendHome:
        Navigator.pushNamed(
          context,
          '/friend-balcony',
          arguments: building.id,
        );
        break;
      case BuildingType.publicGarden:
        Navigator.pushNamed(
          context,
          '/public-garden',
          arguments: building.id,
        );
        break;
      case BuildingType.marketplace:
        Navigator.pushNamed(context, '/marketplace');
        break;
      case BuildingType.cemetery:
        Navigator.pushNamed(context, '/cemetery');
        break;
    }
  }
}