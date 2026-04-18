import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../game_internals/player.dart';
import '../game_internals/playing_card.dart';
import '../style/palette.dart';

class PlayingCardWidget extends StatelessWidget {
  // A standard playing card is 57.1mm x 88.9mm.
  static const double width = 57.1;

  static const double height = 88.9;

  final PlayingCard card;

  final Player? player;

  const PlayingCardWidget(this.card, {this.player, super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    final cardWidget = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: palette.trueWhite,
        border: Border.all(color: palette.ink),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Image.asset(
        'assets/maja/tile000.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
      ),
    );

    /// Cards that aren't in a player's hand are not draggable.
    if (player == null) return cardWidget;

    return Draggable(
      feedback: Transform.rotate(angle: 0.1, child: cardWidget),
      data: PlayingCardDragData(card, player!),
      childWhenDragging: Opacity(opacity: 0.5, child: cardWidget),
      onDragStarted: () {
        final audioController = context.read<AudioController>();
        audioController.playSfx(SfxType.huhsh);
      },
      onDragEnd: (details) {
        final audioController = context.read<AudioController>();
        audioController.playSfx(SfxType.wssh);
      },
      child: cardWidget,
    );
  }
}

@immutable
class PlayingCardDragData {
  final PlayingCard card;

  final Player holder;

  const PlayingCardDragData(this.card, this.holder);
}
