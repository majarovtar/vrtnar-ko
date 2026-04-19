import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/summer5.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none,
            ),
          ),
          Positioned(
            top: 20,
            left: 35,
            right: 65,
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 700,
                  filterQuality: FilterQuality.none,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Click to play',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => context.go('/home'),
                    child: Image.asset(
                      'assets/images/play.png',
                      width: 200,
                      filterQuality: FilterQuality.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
