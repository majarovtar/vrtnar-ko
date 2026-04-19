import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game_internals/board_state.dart';
import '../game_internals/playing_area.dart';
import 'playing_area_widget.dart';

/// Drag data for a new vase from the sidebar.
class VaseDragData {
  const VaseDragData();
}

/// Drag data for moving an existing placed vase.
class VaseMoveDragData {
  final PlayingArea area;
  const VaseMoveDragData(this.area);
}

class BoardWidget extends StatefulWidget {
  const BoardWidget({super.key});

  @override
  State<BoardWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget> {
  final GlobalKey _boardKey = GlobalKey();

  Offset _toLocal(Offset global) {
    final renderBox =
        _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return global;
    return renderBox.globalToLocal(global);
  }

  @override
  Widget build(BuildContext context) {
    final boardState = context.watch<BoardState>();

    // We need to accept both VaseDragData and VaseMoveDragData,
    // so we use two overlapping DragTargets.
    return SizedBox.expand(
      key: _boardKey,
      child: Stack(
        children: [
          // DragTarget for new vases from sidebar
          Positioned.fill(
            child: DragTarget<VaseDragData>(
              builder: (context, _, __) => const SizedBox.expand(),
              onWillAcceptWithDetails: (_) => true,
              onAcceptWithDetails: (details) {
                final local = _toLocal(details.offset);
                boardState.addArea(x: local.dx - 32, y: local.dy - 32);
              },
            ),
          ),
          // DragTarget for repositioning existing vases
          Positioned.fill(
            child: DragTarget<VaseMoveDragData>(
              builder: (context, _, __) => const SizedBox.expand(),
              onWillAcceptWithDetails: (_) => true,
              onAcceptWithDetails: (details) {
                final local = _toLocal(details.offset);
                details.data.area.x = local.dx - 32;
                details.data.area.y = local.dy - 32;
                boardState.notifyListeners();
              },
            ),
          ),
          // Placed vases
          for (final area in boardState.areas)
            Positioned(
              left: area.x,
              top: area.y,
              child: PlayingAreaWidget(area, key: ObjectKey(area)),
            ),
        ],
      ),
    );
  }
}
