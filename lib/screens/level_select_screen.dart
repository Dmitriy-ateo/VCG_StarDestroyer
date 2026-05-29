import 'package:flutter/material.dart';
import '../models/level_data.dart';
import '../game/game_controller.dart';
import '../services/audio_service.dart';

class LevelSelectScreen extends StatefulWidget {
  final GameController controller;
  final Function(int) onLevelSelected;
  final VoidCallback onBackToMenu;

  const LevelSelectScreen({
    super.key,
    required this.controller,
    required this.onLevelSelected,
    required this.onBackToMenu,
  });

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // Auto-scroll to the last active (highest unlocked) level after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        int activeId = 1;
        for (var level in preloadedLevels) {
          if (widget.controller.progression.isLevelUnlocked(level.id)) {
            activeId = level.id;
          }
        }
        
        // Estimate scroll offset: index * average item height
        final targetIndex = activeId - 1;
        final offset = targetIndex * 164.0;
        final maxScroll = _scrollController.position.maxScrollExtent;
        _scrollController.jumpTo(offset.clamp(0.0, maxScroll));
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final completed = widget.controller.progression.completedLevelIds;
          final levels = preloadedLevels;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Unified One-Row Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Color(0xFF00ADB5)),
                              onPressed: widget.onBackToMenu,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 6),
                            const Expanded(
                              child: Text(
                                "TACTICAL CAMPAIGNS",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Currency Statuses
                      Row(
                        children: [
                          _buildCurrencyStatus(Icons.monetization_on, "${widget.controller.progression.credits}", Colors.amberAccent),
                          const SizedBox(width: 8),
                          _buildCurrencyStatus(Icons.science, "${widget.controller.progression.researchPoints} RP", Colors.purpleAccent),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Divider line
                  Container(
                    height: 1,
                    color: const Color(0xFF00ADB5).withOpacity(0.3),
                  ),
                  const SizedBox(height: 20),

                  // Scrollable Campaigns List with Level 1 starting on screen at the bottom
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      itemCount: levels.length,
                      itemBuilder: (context, index) {
                        final level = levels[index];
                        final isCompleted = completed.contains(level.id);
                        final isUnlocked = widget.controller.progression.isLevelUnlocked(level.id);
                        final isTutorial = level.id <= 5;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            onTap: isUnlocked ? () {
                              AudioService.instance.playSfx('audio/hud_click.mp3');
                              widget.onLevelSelected(level.id);
                            } : null,
                            borderRadius: BorderRadius.circular(12),
                            child: Opacity(
                              opacity: isUnlocked ? 1.0 : 0.4,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF161B22),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isCompleted
                                        ? Colors.greenAccent.withOpacity(0.6)
                                        : (isUnlocked ? const Color(0xFF00ADB5).withOpacity(0.4) : Colors.redAccent.withOpacity(0.2)),
                                    width: 1.5,
                                  ),
                                  boxShadow: isUnlocked
                                      ? [
                                          BoxShadow(
                                            color: (isCompleted ? Colors.greenAccent : const Color(0xFF00ADB5)).withOpacity(0.05),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Row 1: Left Badge + Main Content Details
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 1. Left Badge (Index / Lock status)
                                        Container(
                                          width: 52,
                                          height: 52,
                                          decoration: BoxDecoration(
                                            color: isCompleted
                                                ? Colors.greenAccent.withOpacity(0.08)
                                                : (isUnlocked ? const Color(0xFF0B0E14) : Colors.redAccent.withOpacity(0.04)),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isCompleted
                                                  ? Colors.greenAccent.withOpacity(0.8)
                                                  : (isUnlocked ? const Color(0xFF00ADB5) : Colors.redAccent.withOpacity(0.3)),
                                              width: 1.5,
                                            ),
                                            boxShadow: isUnlocked
                                                ? [
                                                    BoxShadow(
                                                      color: (isCompleted ? Colors.greenAccent : const Color(0xFF00ADB5)).withOpacity(0.15),
                                                      blurRadius: 8,
                                                    )
                                                  ]
                                                : null,
                                          ),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Text(
                                                "${level.id}",
                                                style: TextStyle(
                                                  color: isCompleted
                                                      ? Colors.greenAccent
                                                      : (isUnlocked ? const Color(0xFF00FFF5) : Colors.grey),
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              if (isCompleted)
                                                Positioned(
                                                  right: 1,
                                                  bottom: 1,
                                                  child: Container(
                                                    padding: const EdgeInsets.all(1.5),
                                                    decoration: const BoxDecoration(
                                                      color: Color(0xFF161B22),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.check_circle,
                                                      color: Colors.greenAccent,
                                                      size: 14,
                                                    ),
                                                  ),
                                                ),
                                              if (!isUnlocked)
                                                Positioned(
                                                  right: 1,
                                                  bottom: 1,
                                                  child: Container(
                                                    padding: const EdgeInsets.all(1.5),
                                                    decoration: const BoxDecoration(
                                                      color: Color(0xFF161B22),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.lock,
                                                      color: Colors.redAccent,
                                                      size: 12,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),

                                        // 2. Middle Content (Details)
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    isTutorial ? "TRAINING SECTOR" : "TACTICAL SECTOR",
                                                    style: TextStyle(
                                                      color: isTutorial ? Colors.tealAccent : Colors.orangeAccent,
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 1.2,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  if (isCompleted)
                                                    const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 12),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                level.name.split(':').last.trim().toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.0,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                level.description,
                                                style: const TextStyle(color: Colors.grey, fontSize: 11, height: 1.4),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Subtle Divider
                                    Container(
                                      height: 1,
                                      color: const Color(0xFF00ADB5).withOpacity(0.12),
                                    ),
                                    const SizedBox(height: 10),
                                    // Row 2: Horizontal Clear Rewards Strip
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "CLEAR REWARDS",
                                          style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                                        ),
                                        Row(
                                          children: [
                                            if (completed.contains(level.id)) ...[
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: Colors.greenAccent.withOpacity(0.08),
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: Colors.greenAccent.withOpacity(0.3), width: 0.8),
                                                ),
                                                child: const Text(
                                                  "✓ CLAIMED",
                                                  style: TextStyle(
                                                    color: Colors.greenAccent,
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                            ] else ...[
                                              _buildSmallStatChip(Icons.monetization_on, "+${level.creditsReward ~/ 10}", Colors.amberAccent),
                                              const SizedBox(width: 10),
                                              _buildSmallStatChip(Icons.science, "+${level.researchPointsReward ~/ 10} RP", Colors.purpleAccent),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrencyStatus(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0E14),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
