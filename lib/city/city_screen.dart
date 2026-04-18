// import 'package:flutter/material.dart';

// class CityScreen extends StatelessWidget {
//   const CityScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('City'),
//       ),
//       body: const Center(
//         child: Text('City page works'),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CityScreen extends StatelessWidget {
  const CityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('City'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(color: const Color(0xFFBFE3FF)),
          ),
          Positioned(
            left: 40,
            bottom: 60,
            child: _BuildingButton(
              label: 'Your Building',
              onTap: () => context.go('/play'),
            ),
          ),
          Positioned(
            left: 180,
            bottom: 90,
            child: _BuildingButton(
              label: 'Friend Building',
              onTap: () => context.go('/friend-balcony'),
            ),
          ),
          Positioned(
            right: 40,
            bottom: 70,
            child: _BuildingButton(
              label: 'Marketplace',
              onTap: () => context.go('/marketplace'),
            ),
          ),
          Positioned(
            right: 60,
            top: 80,
            child: _BuildingButton(
              label: 'Cemetery',
              onTap: () => context.go('/cemetery'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildingButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _BuildingButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}