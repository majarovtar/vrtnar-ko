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
import 'package:provider/provider.dart';

import '../style/palette.dart';

class CityScreen extends StatefulWidget {
  const CityScreen({super.key});

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  bool _isMenuOpen = true;

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return Scaffold(
      body: Row(
        children: [
          _buildMenuPanel(palette),
          Expanded(
            child: Stack(
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
          )),
        ],
      ),
    );
  }

  Widget _buildMenuPanel(Palette palette) {
    return Container(
      width: _isMenuOpen ? 220 : 56,
      decoration: BoxDecoration(
        color: palette.backgroundMain,
        border: Border(
          right: BorderSide(color: palette.ink.withValues(alpha: 0.15)),
        ),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 56,
              child: _isMenuOpen
                  ? Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text(
                            'Menu',
                            style: TextStyle(
                              fontFamily: 'Permanent Marker',
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () =>
                              setState(() => _isMenuOpen = false),
                        ),
                      ],
                    )
                  : Center(
                      child: IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () =>
                            setState(() => _isMenuOpen = true),
                      ),
                    ),
            ),
            if (_isMenuOpen) ...[
              _menuItem(
                Icons.yard,
                'My balcony',
                () => GoRouter.of(context).go('/play'),
              ),
              _menuItem(Icons.calendar_month, 'Calendar', null),
              _menuItem(
                Icons.location_city,
                'City',
                () => GoRouter.of(context).go('/city'),
              ),
              _menuItem(Icons.settings, 'Settings', null),
            ],
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback? onTap) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      onTap: onTap,
      enabled: onTap != null,
      dense: true,
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