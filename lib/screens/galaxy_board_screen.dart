import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/galaxy_model.dart';
import '../models/game_progression.dart';
import '../game/game_controller.dart';
import '../game/sector_generator.dart';

class GalaxyBoardScreen extends StatefulWidget {
  final GameController controller;
  final String galaxyId;
  final Function(QuestModel) onQuestSelected;
  final VoidCallback onBackToMap;

  const GalaxyBoardScreen({
    super.key,
    required this.controller,
    required this.galaxyId,
    required this.onQuestSelected,
    required this.onBackToMap,
  });

  @override
  State<GalaxyBoardScreen> createState() => _GalaxyBoardScreenState();
}

class _GalaxyBoardScreenState extends State<GalaxyBoardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final galaxy = preloadedGalaxies.firstWhere((g) => g.id == widget.galaxyId);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final progression = widget.controller.progression;
          // Filter quests by type
          final loreQuests = galaxy.quests.where((q) => q.type == QuestType.lore).toList();
          final sideQuests = galaxy.quests.where((q) => q.type == QuestType.side).toList();

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                children: [
                  // Unified Small Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Color(0xFF00ADB5)),
                            onPressed: widget.onBackToMap,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                galaxy.name.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const Text(
                                "SECTOR COMMAND CONSOLE",
                                style: TextStyle(
                                  color: Color(0xFF00FFF5),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Currencies Status
                      Row(
                        children: [
                          _buildStatChip(Icons.monetization_on, "${progression.credits}", Colors.amberAccent),
                          const SizedBox(width: 8),
                          _buildStatChip(Icons.science, "${progression.researchPoints} RP", Colors.purpleAccent),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Divider
                  Container(
                    height: 1,
                    color: const Color(0xFF00ADB5).withOpacity(0.2),
                  ),
                  const SizedBox(height: 12),

                  // Cyberpunk TabBar
                  TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF00FFF5),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFF00ADB5),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: const Color(0xFF00ADB5).withOpacity(0.15),
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.account_tree_outlined, size: 18),
                        text: "LORE STORY",
                      ),
                      Tab(
                        icon: Icon(Icons.assignment_outlined, size: 18),
                        text: "SIDE MISSIONS",
                      ),
                      Tab(
                        icon: Icon(Icons.wb_sunny_outlined, size: 18),
                        text: "DAILY TARGETS",
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tab Views
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Story / Lore Nodes
                        _buildStoryTimeline(context, loreQuests, progression),

                        // Tab 2: Side Quests Grid
                        _buildSideQuestsPanel(context, sideQuests, progression),

                        // Tab 3: Daily Quest Port
                        _buildDailyQuestPanel(context, progression),
                      ],
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

  Widget _buildStoryTimeline(BuildContext context, List<QuestModel> quests, GameProgression progression) {
    if (quests.isEmpty) {
      return const Center(
        child: Text(
          "NO STORYLINE SECURED IN THIS GALAXY",
          style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      itemCount: quests.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final quest = quests[index];
        final isCompleted = progression.completedQuestIds.contains(quest.id);
        
        // Sequence check: Story level N requires level N-1 completed
        bool isUnlocked = true;
        if (index > 0) {
          final prevQuest = quests[index - 1];
          isUnlocked = progression.completedQuestIds.contains(prevQuest.id);
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chronological Node Indicator
              Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.greenAccent.withOpacity(0.08)
                          : (isUnlocked ? const Color(0xFF0B0E14) : Colors.redAccent.withOpacity(0.04)),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? Colors.greenAccent
                            : (isUnlocked ? const Color(0xFF00ADB5) : Colors.redAccent.withOpacity(0.3)),
                        width: 2.0,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        isCompleted ? Icons.check : (isUnlocked ? Icons.play_arrow : Icons.lock),
                        size: 14,
                        color: isCompleted
                            ? Colors.greenAccent
                            : (isUnlocked ? const Color(0xFF00FFF5) : Colors.redAccent.withOpacity(0.4)),
                      ),
                    ),
                  ),
                  if (index < quests.length - 1)
                    Container(
                      width: 2,
                      height: 50,
                      color: isCompleted ? Colors.greenAccent.withOpacity(0.4) : const Color(0xFF393E46),
                    ),
                ],
              ),
              const SizedBox(width: 16),

              // Quest Node Card
              Expanded(
                child: GestureDetector(
                  onTap: isUnlocked ? () => _showQuestDetailsDialog(context, quest, isCompleted) : null,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B22),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCompleted
                            ? Colors.greenAccent.withOpacity(0.3)
                            : (isUnlocked ? const Color(0xFF00ADB5).withOpacity(0.2) : Colors.redAccent.withOpacity(0.1)),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              quest.title.toUpperCase(),
                              style: TextStyle(
                                color: isUnlocked ? Colors.white : Colors.grey,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            if (isCompleted)
                              const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 14),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          quest.description,
                          style: const TextStyle(color: Colors.grey, fontSize: 11, height: 1.4),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildMiniRewardChip(Icons.monetization_on, "+${quest.creditsReward}", Colors.amberAccent),
                            const SizedBox(width: 8),
                            _buildMiniRewardChip(Icons.science, "+${quest.rpReward} RP", Colors.purpleAccent),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSideQuestsPanel(BuildContext context, List<QuestModel> quests, GameProgression progression) {
    if (quests.isEmpty) {
      return const Center(
        child: Text(
          "NO SIDE MISSIONS CURRENTLY LOGGED",
          style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      itemCount: quests.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final quest = quests[index];
        final isCompleted = progression.completedQuestIds.contains(quest.id);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _showQuestDetailsDialog(context, quest, isCompleted),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCompleted
                      ? Colors.greenAccent.withOpacity(0.3)
                      : const Color(0xFF00ADB5).withOpacity(0.2),
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        quest.title.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      if (isCompleted)
                        const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 14),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    quest.description,
                    style: const TextStyle(color: Colors.grey, fontSize: 11, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildMiniRewardChip(Icons.monetization_on, "+${quest.creditsReward}", Colors.amberAccent),
                      const SizedBox(width: 8),
                      _buildMiniRewardChip(Icons.science, "+${quest.rpReward} RP", Colors.purpleAccent),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyQuestPanel(BuildContext context, GameProgression progression) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00ADB5).withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.radar_sharp, color: Color(0xFF00FFF5), size: 48),
          const SizedBox(height: 16),
          const Text(
            "DAILY SECTOR OUTPOST TERMINAL",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "A dynamically generated system cleared by space relays. Refreshes procedural puzzles adapted to your level.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 11, height: 1.4),
          ),
          const SizedBox(height: 24),
          
          // Terminal Info Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0B0E14),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF00ADB5).withOpacity(0.1)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "STATUS: SECTOR DETECTED",
                  style: TextStyle(color: Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
                Text(
                  "EST. YIELD: +300 C / +50 RP",
                  style: TextStyle(color: Colors.amberAccent, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Launch Procedural Daily Quest
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                final dailyLevel = SectorGenerator.generateDailySector(progression);
                final dailyQuest = QuestModel(
                  id: "daily_quest_${DateTime.now().millisecondsSinceEpoch}",
                  title: dailyLevel.name,
                  description: dailyLevel.description,
                  type: QuestType.daily,
                  storyLoreSnippet: "A highly volatile cosmic wave is warping sector coordinates. Calibrate and redirect the superlaser.",
                  creditsReward: dailyLevel.creditsReward,
                  rpReward: dailyLevel.researchPointsReward,
                  levelData: dailyLevel,
                );
                widget.onQuestSelected(dailyQuest);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00ADB5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 4,
              ),
              child: const Text(
                "LAUNCH PROCEDURAL SECTOR",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuestDetailsDialog(BuildContext context, QuestModel quest, bool isCompleted) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161B22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF00ADB5), width: 1.5),
          ),
          title: Row(
            children: [
              Icon(
                quest.type == QuestType.side ? Icons.assignment : Icons.movie_outlined,
                color: const Color(0xFF00FFF5),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  quest.title.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1.0, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Story snippet
                if (quest.storyLoreSnippet != null) ...[
                  const Text(
                    "TACTICAL COMMAND INCOMING BRIEFING:",
                    style: TextStyle(color: Color(0xFF00FFF5), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "\"${quest.storyLoreSnippet}\"",
                    style: const TextStyle(color: Colors.tealAccent, fontSize: 11, fontStyle: FontStyle.italic, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                ],
                const Text(
                  "SECTOR TASK DETAILS:",
                  style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
                const SizedBox(height: 4),
                Text(
                  quest.description,
                  style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 16),
                const Text(
                  "CLEARANCE REWARDS:",
                  style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildMiniRewardChip(Icons.monetization_on, "+${quest.creditsReward} C", Colors.amberAccent),
                    const SizedBox(width: 10),
                    _buildMiniRewardChip(Icons.science, "+${quest.rpReward} RP", Colors.purpleAccent),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("CANCEL", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onQuestSelected(quest);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00ADB5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("DEPLOY DECK", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
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
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniRewardChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0E14),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
