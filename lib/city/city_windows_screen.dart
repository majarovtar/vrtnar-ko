import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CityWindowsScreen extends StatefulWidget {
  const CityWindowsScreen({super.key});

  @override
  State<CityWindowsScreen> createState() => _CityWindowsScreenState();
}

class _CityWindowsScreenState extends State<CityWindowsScreen> {
  int? _hoveredWindow;

  static const String _cityAsset =
      'assets/images/buildings/ME_Singles_Generic_Building_48x48_Condo_4_39.png';

  final List<_FriendWindow> _windows = const [
    _FriendWindow(
      id: 'anna',
      name: 'Anna',
      left: 0.12,
      top: 0.24,
      width: 0.18,
      height: 0.22,
    ),
    _FriendWindow(
      id: 'maria',
      name: 'Maria',
      left: 0.42,
      top: 0.18,
      width: 0.18,
      height: 0.22,
    ),
    _FriendWindow(
      id: 'lucas',
      name: 'Lucas',
      left: 0.70,
      top: 0.28,
      width: 0.16,
      height: 0.22,
    ),
  ];

  void _setHovered(int? index) {
    setState(() {
      _hoveredWindow = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const double width = 720;
    const double height = 520;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a friend'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Text(
              'Hover over a window to see your friends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: width,
              height: height,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      _cityAsset,
                      fit: BoxFit.contain,
                    ),
                  ),
                  for (var i = 0; i < _windows.length; i++)
                    _buildWindowOverlay(context, width, height, i),
                  if (_hoveredWindow != null)
                    _buildWindowLabel(width, height, _hoveredWindow!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWindowOverlay(
    BuildContext context,
    double width,
    double height,
    int index,
  ) {
    final window = _windows[index];
    return Positioned(
      left: width * window.left,
      top: height * window.top,
      width: width * window.width,
      height: height * window.height,
      child: MouseRegion(
        onEnter: (_) => _setHovered(index),
        onExit: (_) => _setHovered(null),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => context.go('/friend-home/${window.id}'),
          child: Container(
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _buildWindowLabel(double width, double height, int index) {
    final window = _windows[index];
    final labelLeft = (window.left + window.width / 2) * width;
    final labelTop = (window.top - 0.08) * height;

    return Positioned(
      left: labelLeft.clamp(0.0, width - 140),
      top: labelTop.clamp(0.0, height - 48),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha((0.75 * 255).toInt()),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          window.name,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}

class _FriendWindow {
  final String id;
  final String name;
  final double left;
  final double top;
  final double width;
  final double height;

  const _FriendWindow({
    required this.id,
    required this.name,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}
