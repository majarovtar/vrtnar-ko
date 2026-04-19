import 'dart:async';

import 'package:flutter/material.dart';

import '../game_internals/playing_area.dart';
import 'board_widget.dart';
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
    _growthTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (widget.area.plant != null) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _growthTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      width: 64,
      height: 64,
      child: DragTarget<PlayingCardDragData>(
        builder: (context, candidateData, rejectedData) => GestureDetector(
          onTap: widget.area.plant != null
              ? () => showPlantInfoDialog(context, widget.area)
              : null,
          child: StreamBuilder(
            stream: widget.area.allChanges,
            builder: (context, _) => _buildContent(),
          ),
        ),
        onWillAcceptWithDetails: _onDragWillAccept,
        onLeave: _onDragLeave,
        onAcceptWithDetails: _onDragAccept,
      ),
    );

    return LongPressDraggable<VaseMoveDragData>(
      delay: const Duration(milliseconds: 150),
      data: VaseMoveDragData(widget.area),
      feedback: Opacity(
        opacity: 0.8,
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: 64,
            height: 64,
            child: _buildContent(),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: content),
      child: content,
    );
  }

  Widget _buildContent() {
    final plant = widget.area.plant;

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: 0,
          child: Image.asset(
            'assets/images/supplies/ME_Singles_Garden_48x48_Vase_Full.png',
            width: 48,
            height: 48,
            filterQuality: FilterQuality.none,
            opacity: AlwaysStoppedAnimation(isHighlighted ? 0.7 : 1.0),
          ),
        ),
        if (plant != null)
          Positioned(
            top: 0,
            child: Image.asset(
              plant.assetPath,
              width: 56,
              height: 56,
              filterQuality: FilterQuality.none,
            ),
          ),
      ],
    );
  }

  void _onDragAccept(DragTargetDetails<PlayingCardDragData> details) async {
    final seed = details.data.card.seed;
    setState(() => isHighlighted = false);

    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text('Name your ${seed.name}'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter a name'),
            onSubmitted: (value) => Navigator.pop(context, value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Skip'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    final trimmed = name?.trim();
    widget.area.plantSeed(seed, name: trimmed != null && trimmed.isNotEmpty ? trimmed : null);
  }

  void _onDragLeave(PlayingCardDragData? data) {
    setState(() => isHighlighted = false);
  }

  bool _onDragWillAccept(DragTargetDetails<PlayingCardDragData> details) {
    if (widget.area.plant != null) return false;
    setState(() => isHighlighted = true);
    return true;
  }
}
