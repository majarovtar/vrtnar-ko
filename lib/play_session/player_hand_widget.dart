import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game_internals/board_state.dart';
import 'playing_card_widget.dart';

class PlayerHandWidget extends StatefulWidget {
  const PlayerHandWidget({super.key});

  @override
  State<PlayerHandWidget> createState() => _PlayerHandWidgetState();
}

class _PlayerHandWidgetState extends State<PlayerHandWidget> {
  bool isHighlighted = false;

  @override
  Widget build(BuildContext context) {
    final boardState = context.watch<BoardState>();

    return ListenableBuilder(
      listenable: boardState.player,
      builder: (context, child) {
        return DragTarget<PlayingCardDragData>(
          builder: (context, candidateData, rejectedData) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                if (isHighlighted)
                  Container(
                    height: 40,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('Drop seed to return'),
                    ),
                  ),
                ...boardState.player.hand.map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        PlayingCardWidget(
                          card,
                          player: boardState.player,
                          compact: true,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            card.seed.name,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          onWillAcceptWithDetails: (details) {
            // Only accept cards from playing areas, not from the hand
            if (details.data.sourceArea != null && details.data.holder == null) {
              setState(() => isHighlighted = true);
              return true;
            }
            return false;
          },
          onLeave: (data) {
            setState(() => isHighlighted = false);
          },
          onAcceptWithDetails: (details) {
            // Remove card from the source area and add back to player hand
            if (details.data.sourceArea != null) {
              details.data.sourceArea!.cards.remove(details.data.card);
            }
            boardState.player.addCard(details.data.card);
            setState(() => isHighlighted = false);
          },
        );
      },
    );
  }
}
