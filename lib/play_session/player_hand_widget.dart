import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/perenual_service.dart';
import '../game_internals/board_state.dart';
import '../game_internals/playing_card.dart';
import '../game_internals/seed.dart';
import 'playing_card_widget.dart';

class PlayerHandWidget extends StatefulWidget {
  const PlayerHandWidget({super.key});

  @override
  State<PlayerHandWidget> createState() => _PlayerHandWidgetState();
}

class _PlayerHandWidgetState extends State<PlayerHandWidget> {
  bool isHighlighted = false;

  final _searchController = TextEditingController();

  String? _selectedSunlight;
  bool? _poisonousFilter;
  bool? _hasPets;
  bool _isLoading = false;

  List<PlantSearchResult> _searchResults = [];
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchPlants({int page = 1}) async {
    setState(() {
      _isLoading = true;
    });

    final results = await PerenualService().searchPlants(
      query: _searchController.text,
      sunlightFilter: _selectedSunlight,
      poisonous: _poisonousFilter,
      edibleOnly: true,
      page: page,
    );

    setState(() {
      _searchResults = results;
      _currentPage = page;
      _hasMore = results.length >= 3;
      _isLoading = false;
    });
  }

  void _nextPage() {
    if (_hasMore && !_isLoading) {
      _searchPlants(page: _currentPage + 1);
    }
  }

  void _previousPage() {
    if (_currentPage > 1 && !_isLoading) {
      _searchPlants(page: _currentPage - 1);
    }
  }

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
                const Text(
                  'Your Seeds',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

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

                const Divider(height: 24),

                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search plants',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedSunlight,
                  decoration: const InputDecoration(
                    labelText: 'Sunlight',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'full_shade',
                      child: Text('Full shade'),
                    ),
                    DropdownMenuItem(
                      value: 'part_shade',
                      child: Text('Part shade'),
                    ),
                    DropdownMenuItem(
                      value: 'sun-part_shade',
                      child: Text('Sun / part shade'),
                    ),
                    DropdownMenuItem(
                      value: 'full_sun',
                      child: Text('Full sun'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSunlight = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Not toxic for pets'),
                  value: _hasPets ?? false,
                  onChanged: (value) {
                    setState(() {
                      _hasPets = value;
                      // If user has pets, filter out poisonous plants
                      _poisonousFilter = value ? false : null;
                    });
                  },
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _searchPlants,
                    child: Text(_isLoading ? 'Searching...' : 'Search'),
                  ),
                ),
                const SizedBox(height: 12),

                if (_searchResults.isNotEmpty) ...[
                  const Text(
                    'Plant Database Results',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  ..._searchResults.map(
                    (plant) => Card(
                      child: ListTile(
                        dense: true,
                        visualDensity: const VisualDensity(vertical: -2),
                        leading: plant.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  plant.imageUrl!,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.local_florist,
                                    size: 48,
                                  ),
                                ),
                              )
                            : const Icon(Icons.local_florist, size: 48),
                        title: Text(
                          plant.commonName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: () {
                            final boardState = context.read<BoardState>();
                            final customSeed = CustomSeed(
                              plantId: plant.id,
                              displayName: plant.commonName,
                              emoji: '🌱',
                              color: SeedColor.green,
                              imageUrl: plant.imageUrl,
                            );
                            final card = PlayingCard(customSeed, 5);
                            boardState.player.addCard(card);
                          },
                        ),
                      ),
                    ),
                  ),

                  const Divider(height: 24),

                  // Pagination controls
                  if (_searchResults.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_currentPage > 1)
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: _previousPage,
                          ),
                        Text('Page $_currentPage'),
                        if (_hasMore)
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: _nextPage,
                          ),
                      ],
                    ),
                ],
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
}