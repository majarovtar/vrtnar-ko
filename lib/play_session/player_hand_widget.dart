import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game_internals/board_state.dart';
import 'board_widget.dart';
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
                // Draggable vase
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Draggable<VaseDragData>(
                    data: const VaseDragData(),
                    feedback: Image.asset(
                      'assets/images/supplies/ME_Singles_Garden_48x48_Vase_Full.png',
                      width: 48,
                      height: 48,
                      filterQuality: FilterQuality.none,
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.5,
                      child: _vaseRow(),
                    ),
                    child: _vaseRow(),
                  ),
                ),
                // Seed cards
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
            if (details.data.sourceArea != null) {
              details.data.sourceArea!.removePlant();
            }
            boardState.player.addCard(details.data.card);
            setState(() => isHighlighted = false);
          },
        );
      },
    );
  }

  Widget _vaseRow() {
    return Row(
      children: [
        Image.asset(
          'assets/images/supplies/ME_Singles_Garden_48x48_Vase_Full.png',
          width: 36,
          height: 36,
          filterQuality: FilterQuality.none,
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text('Planter', style: TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}
