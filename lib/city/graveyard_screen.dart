import 'package:flutter/material.dart';

class GraveyardScreen extends StatefulWidget {
  const GraveyardScreen({super.key});

  @override
  State<GraveyardScreen> createState() => _GraveyardScreenState();
}

class _GraveyardScreenState extends State<GraveyardScreen> {
  final List<_DeadFlower> _deadFlowers = [
    const _DeadFlower(name: 'Micka', dateDied: '2026-01-10'),
    const _DeadFlower(name: 'Stanislav', dateDied: '2026-02-12'),
    const _DeadFlower(name: 'Lilijana', dateDied: '2026-03-16'),
  ];

  final List<_PlantSpot> _plantSpots = const [
    _PlantSpot(name: 'Micka', left: 2.6/11, top: 3.7/11, width: 0.15, height: 0.15),
    _PlantSpot(name: 'Stanislav', left: 7.8/11, top: 4.6/11, width: 0.15, height: 0.15),
    _PlantSpot(name: 'Lilijana', left: 7.5/11, top: 8.27/11, width: 0.15, height: 0.15),
  ];

  int? _hoveredPlantIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Graveyard'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Graveyard Garden',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          Image.asset(
                            'images/buildings/g1.png',
                            width: constraints.maxWidth,
                            fit: BoxFit.fitWidth,
                          ),
                          for (var i = 0; i < _plantSpots.length; i++)
                            Positioned(
                              left: constraints.maxWidth * _plantSpots[i].left,
                              top: constraints.maxWidth * _plantSpots[i].top,
                              width: constraints.maxWidth * _plantSpots[i].width,
                              height: constraints.maxWidth * _plantSpots[i].height,
                              child: MouseRegion(
                                onEnter: (_) => setState(() => _hoveredPlantIndex = i),
                                onExit: (_) => setState(() => _hoveredPlantIndex = null),
                                child: Container(
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          if (_hoveredPlantIndex != null)
                            Positioned(
                              left: constraints.maxWidth * _plantSpots[_hoveredPlantIndex!].left,
                              top: constraints.maxWidth * _plantSpots[_hoveredPlantIndex!].top - 28,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.75),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _plantSpots[_hoveredPlantIndex!].name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Dead flowers',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Text(
                  'These are the flowers that died in the graveyard. Each entry shows the flower name and the date it was found gone.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                for (var i = 0; i < _deadFlowers.length; i++)
                  _buildDeadFlowerCard(context, i),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeadFlowerCard(BuildContext context, int index) {
    final flower = _deadFlowers[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              flower.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Died: ${flower.dateDied}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeadFlower {
  final String name;
  final String dateDied;

  const _DeadFlower({
    required this.name,
    required this.dateDied,
  });
}

class _PlantSpot {
  final String name;
  final double left;
  final double top;
  final double width;
  final double height;

  const _PlantSpot({
    required this.name,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}