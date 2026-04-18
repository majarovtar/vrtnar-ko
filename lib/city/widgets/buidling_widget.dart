import 'package:flutter/material.dart';
import '../city_building.dart';

class BuildingWidget extends StatelessWidget {
  final CityBuilding building;
  final VoidCallback onTap;

  const BuildingWidget({
    super.key,
    required this.building,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;

    switch (building.type) {
      case BuildingType.playerHome:
        icon = Icons.home;
        break;
      case BuildingType.friendHome:
        icon = Icons.apartment;
        break;
      case BuildingType.publicGarden:
        icon = Icons.park;
        break;
      case BuildingType.marketplace:
        icon = Icons.store;
        break;
      case BuildingType.cemetery:
        icon = Icons.local_florist;
        break;
    }

    return Positioned(
      left: building.x,
      top: building.y,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 40),
            ),
            const SizedBox(height: 8),
            Text(
              building.name,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}