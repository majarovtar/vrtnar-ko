import 'package:flutter/material.dart';

class FriendHomeScreen extends StatefulWidget {
  final String friendName;

  const FriendHomeScreen({
    super.key,
    required this.friendName,
  });

  @override
  State<FriendHomeScreen> createState() => _FriendHomeScreenState();
}

class _FriendHomeScreenState extends State<FriendHomeScreen> {
  final List<_JournalMessage> _messages = [
    _JournalMessage(
      text: 'The sunflower is finally blooming and the yellow petals look amazing.',
      comments: ['I love how bright it looks today.'],
    ),
    _JournalMessage(
      text: 'A rose leaf is turning yellow, so I may need to check the soil and light.',
      comments: ['Maybe it needs less water or more shade.'],
    ),
    _JournalMessage(text: 'The tulip bud is growing taller and should open by tomorrow.'),
    _JournalMessage(text: 'Lily petals opened gently this morning and smell wonderful.'),
    _JournalMessage(text: 'The daisy cluster is small but the flowers are cheerful.'),
  ];

  final List<_PlantSpot> _plantSpots = const [
    _PlantSpot(name: 'Sunflower', left: 0.08, top: 0.16, width: 0.18, height: 0.22),
    _PlantSpot(name: 'Rose', left: 0.50, top: 0.14, width: 0.18, height: 0.22),
    _PlantSpot(name: 'Tulip', left: 0.30, top: 0.55, width: 0.22, height: 0.24),
    _PlantSpot(name: 'Lily', left: 0.72, top: 0.50, width: 0.18, height: 0.24),
  ];

  int? _hoveredPlantIndex;
  late final List<TextEditingController> _commentControllers;
  late final List<bool> _showCommentField;

  @override
  void initState() {
    super.initState();
    _commentControllers = List.generate(
      _messages.length,
      (_) => TextEditingController(),
    );
    _showCommentField = List.generate(_messages.length, (_) => false);
  }

  @override
  void dispose() {
    for (final controller in _commentControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleHeart(int index) {
    setState(() {
      _messages[index].isLoved = !_messages[index].isLoved;
    });
  }

  void _toggleCommentField(int index) {
    setState(() {
      _showCommentField[index] = !_showCommentField[index];
    });
  }

  void _submitComment(int index) {
    final comment = _commentControllers[index].text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something before commenting.'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    setState(() {
      _messages[index].comments.add(comment);
      _commentControllers[index].clear();
      _showCommentField[index] = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Comment posted: "$comment"'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMaria = widget.friendName.toLowerCase() == 'maria';

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.friendName}\'s Home'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.friendName,
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (isMaria) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            Image.asset(
                              'images/buildings/ME_Singles_Garden_48x48_Large_Greenhouse_Layer_1_See_Through.png',
                              width: constraints.maxWidth,
                              fit: BoxFit.fitWidth,
                            ),
                            for (var i = 0; i < _plantSpots.length; i++)
                              Positioned(
                                left: constraints.maxWidth * _plantSpots[i].left,
                                top: constraints.maxWidth * _plantSpots[i].top,
                                width: constraints.maxWidth * _plantSpots[i].width,
                                height: constraints.maxWidth * _plantSpots[i].height,
                                child: MouseRegion(
                                  onEnter: (_) => setState(() => _hoveredPlantIndex = i),
                                  onExit: (_) => setState(() => _hoveredPlantIndex = null),
                                  child: Container(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                            if (_hoveredPlantIndex != null)
                              Positioned(
                                left: constraints.maxWidth * _plantSpots[_hoveredPlantIndex!].left,
                                top: constraints.maxWidth * _plantSpots[_hoveredPlantIndex!].top - 28,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.75),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _plantSpots[_hoveredPlantIndex!].name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Text(
                  'Flower journal',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (isMaria) ...[
                  const Text(
                    'Maria is writing about her garden flowers and their measurements. Scroll through her notes below and tap the heart or comment buttons to write something about the flowers.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  for (var i = 0; i < _messages.length; i++)
                    _buildMessageCard(context, i),
                ] else ...[
                  const Text(
                    'This is your friend\'s home screen. You can add their profile, items, and actions here.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageCard(BuildContext context, int index) {
    final message = _messages[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              message.text,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    message.isLoved ? Icons.favorite : Icons.favorite_border,
                    color: message.isLoved ? Colors.red : Colors.grey.shade700,
                  ),
                  onPressed: () => _toggleHeart(index),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.comment_outlined),
                  label: const Text('Comment'),
                  onPressed: () => _toggleCommentField(index),
                ),
              ],
            ),
            if (_showCommentField[index]) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _commentControllers[index],
                decoration: InputDecoration(
                  hintText: 'Write something about this...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                minLines: 1,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => _submitComment(index),
                  child: const Text('Send'),
                ),
              ),
            ],
            if (message.comments.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text(
                'Comments:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              for (final comment in message.comments)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Text(comment),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _JournalMessage {
  final String text;
  bool isLoved;
  final List<String> comments;

  _JournalMessage({
    required this.text,
    this.isLoved = false,
    List<String>? comments,
  }) : comments = comments ?? [];
}

class _PlantSpot {
  final String name;
  final double left;
  final double top;
  final double width;
  final double height;

  const _PlantSpot({
    required this.name,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}
