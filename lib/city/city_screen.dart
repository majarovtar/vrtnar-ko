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

import '../shared/menu_weather_summary.dart';
import '../style/palette.dart';

class CityScreen extends StatefulWidget {
  const CityScreen({super.key});

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  bool _isMenuOpen = true;

  final List<_FriendWindow> _cityWindows = [
    _FriendWindow(
      id: 'maria',
      name: 'Maria',
      left: 0.66,
      top: 0.45,
      width: 0.18,
      height: 0.12,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/pixel-art-city-game-level-600nw.webp',
              fit: BoxFit.cover,
            ),
          ),
          Row(
            children: [
              _buildMenuPanel(palette),
              Expanded(
                child: Stack(
                  children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 80,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Visit a location',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _DestinationTile(
                            label: 'Marketplace',
                            assetName:
                                'images/buildings/ME_Singles_Shopping_Center_and_Markets_48x48_Market_Medium_3.png',
                            onTap: () => context.go('/home/marketplace'),
                            imageHeight: 180,
                          ),
                          const SizedBox(width: 60),
                          _DestinationTile(
                            label: 'City',
                            assetName:
                                'images/buildings/ME_Singles_Generic_Building_48x48_Condo_4_39.png',
                            onTap: () => context.go('/home/city'),
                            windows: _cityWindows,
                            onWindowTap: (window) => context.go('/home/friend-home/${window.id}'),
                            imageHeight: 180,
                          ),
                          const SizedBox(width: 60),
                          _DestinationTile(
                            label: 'Graveyard',
                            assetName:
                                'images/buildings/ME_Singles_Graveyard_48x48_Big_Gate.png',
                            onTap: () => context.go('/home/cemetery'),
                            imageHeight: 180,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
        ],
      ),
    );
  }

  Widget _buildMenuPanel(Palette palette) {
    return Container(
      width: _isMenuOpen ? 220 : 56,
      decoration: BoxDecoration(
        color: palette.backgroundMain.withValues(alpha: 0.85),
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
                () => GoRouter.of(context).go('/home'),
              ),
              _menuItem(
                Icons.calendar_month,
                'Calendar',
                () => GoRouter.of(context).go('/home/calendar'),),
              _menuItem(
                Icons.location_city,
                'City',
                () => GoRouter.of(context).go('/home/city'),
              ),
              _menuItem(Icons.settings, 'Settings', null),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: MenuWeatherSummary(),
              ),
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


class _FriendWindow {
  final String id;
  final String name;
  double left;
  double top;
  final double width;
  final double height;

  _FriendWindow({
    required this.id,
    required this.name,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}

class _DestinationTile extends StatefulWidget {
  final String label;
  final String assetName;
  final VoidCallback? onTap;
  final double imageHeight;
  final double? imageWidth;
  final List<_FriendWindow>? windows;
  final void Function(_FriendWindow)? onWindowTap;

  const _DestinationTile({
    required this.label,
    required this.assetName,
    this.onTap,
    this.imageHeight = 180,
    this.imageWidth,
    this.windows,
    this.onWindowTap,
  });

  @override
  State<_DestinationTile> createState() => _DestinationTileState();
}

class _DestinationTileState extends State<_DestinationTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int? _hoveredWindowIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setHoveredWindow(int? index) {
    setState(() {
      _hoveredWindowIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onTap != null;

    return MouseRegion(
      onEnter: (_) {
        if (_animationController.isCompleted == false) {
          _animationController.forward();
        }
      },
      onExit: (_) {
        if (_animationController.isCompleted == true) {
          _animationController.reverse();
        }
      },
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.translucent,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Opacity(
            opacity: isEnabled ? 1.0 : 0.6,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: widget.imageWidth ?? widget.imageHeight,
                  height: widget.imageHeight,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          widget.assetName,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                      if (widget.windows != null)
                        for (var i = 0; i < widget.windows!.length; i++)
                          _buildWindowOverlay(widget.imageWidth ?? widget.imageHeight, widget.imageHeight, i),
                      if (_hoveredWindowIndex != null && widget.windows != null)
                        _buildWindowLabel(widget.imageWidth ?? widget.imageHeight, widget.imageHeight, _hoveredWindowIndex!),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWindowOverlay(double width, double height, int index) {
    final window = widget.windows![index];
    return Positioned(
      left: width * window.left,
      top: height * window.top,
      width: width * window.width,
      height: height * window.height,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => _setHoveredWindow(index),
        onExit: (_) => _setHoveredWindow(null),
        child: GestureDetector(
          onTap: () => widget.onWindowTap?.call(window),
          onPanUpdate: (details) {
            setState(() {
              window.left += details.delta.dx / width;
              window.top += details.delta.dy / height;
              // Clamp to stay within the building image
              window.left = window.left.clamp(0.0, 1.0 - window.width);
              window.top = window.top.clamp(0.0, 1.0 - window.height);
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: _hoveredWindowIndex == index
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.transparent,
              border: _hoveredWindowIndex == index
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWindowLabel(double width, double height, int index) {
    final window = widget.windows![index];
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