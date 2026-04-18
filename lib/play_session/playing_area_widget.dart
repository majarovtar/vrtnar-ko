import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game_internals/playing_area.dart';
import '../style/palette.dart';
import 'plant_info_dialog.dart';
import 'playing_card_widget.dart';

class PlayingAreaWidget extends StatefulWidget {
  final PlayingArea area;

  const PlayingAreaWidget(this.area, {super.key});

  @override
  State<PlayingAreaWidget> createState() => _PlayingAreaWidgetState();
}

class _PlayingAreaWidgetState extends State<PlayingAreaWidget> {
  bool isHighlighted = false;
  Timer? _growthTimer;

  @override
  void initState() {
    super.initState();
    _startGrowthTimer();
  }

  @override
  void dispose() {
    _growthTimer?.cancel();
    super.dispose();
  }

  void _startGrowthTimer() {
    _growthTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (widget.area.plant != null) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return LimitedBox(
      maxHeight: 120,
      child: AspectRatio(
        aspectRatio: 1 / 1,
        child: DragTarget<PlayingCardDragData>(
          builder: (context, candidateData, rejectedData) => Material(
            color: isHighlighted
                ? palette.accept.withValues(alpha: 0.3)
                : palette.trueWhite.withValues(alpha: 0.15),
            shape: const CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              splashColor: palette.redPen,
              onTap: widget.area.plant != null
                  ? () => showPlantInfoDialog(context, widget.area)
                  : null,
              child: StreamBuilder(
                stream: widget.area.allChanges,
                builder: (context, child) => _buildContent(),
              ),
            ),
          ),
          onWillAcceptWithDetails: _onDragWillAccept,
          onLeave: _onDragLeave,
          onAcceptWithDetails: _onDragAccept,
        ),
      ),
    );
  }

  Widget _buildContent() {
    final plant = widget.area.plant;
    if (plant == null) return const SizedBox.shrink();

    return Center(
      child: Image.asset(
        plant.assetPath,
        width: 48,
        height: 48,
        filterQuality: FilterQuality.none,
      ),
    );
  }

  void _onDragAccept(DragTargetDetails<PlayingCardDragData> details) {
    widget.area.plantSeed(details.data.card.seed);
    setState(() => isHighlighted = false);
  }

  void _onDragLeave(PlayingCardDragData? data) {
    setState(() => isHighlighted = false);
  }

  bool _onDragWillAccept(DragTargetDetails<PlayingCardDragData> details) {
    if (details.data.sourceArea == widget.area) return false;
    if (widget.area.plant != null) return false;
    setState(() => isHighlighted = true);
    return true;
  }
}
