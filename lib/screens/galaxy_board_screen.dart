import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/galaxy_model.dart';
import '../models/game_progression.dart';
import '../models/level_data.dart';
import '../game/game_controller.dart';
import '../game/sector_generator.dart';
import '../theme/style_guide.dart';

class GalaxyBoardScreen extends StatefulWidget {
  final GameController controller;
  final String galaxyId;
  final Function(QuestModel) onQuestSelected;
  final VoidCallback onBackToMap;
  final VoidCallback onGoToShop;
  final VoidCallback onGoToResearch;

  const GalaxyBoardScreen({
    super.key,
    required this.controller,
    required this.galaxyId,
    required this.onQuestSelected,
    required this.onBackToMap,
    required this.onGoToShop,
    required this.onGoToResearch,
  });

  // Public static accessors for automated testing verification
  static int get completedDailyCount => _GalaxyBoardScreenState._completedDailyCount;
  static set completedDailyCount(int val) => _GalaxyBoardScreenState._completedDailyCount = val;
  static Map<String, List<QuestModel>>? get sessionDailyQuestsMap => _GalaxyBoardScreenState._sessionDailyQuestsMap;
  static set sessionDailyQuestsMap(Map<String, List<QuestModel>>? val) => _GalaxyBoardScreenState._sessionDailyQuestsMap = val;

  @override
  State<GalaxyBoardScreen> createState() => _GalaxyBoardScreenState();
}

class _GalaxyBoardScreenState extends State<GalaxyBoardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  QuestModel? _selectedQuest;

  // Session-persistent daily quests state mapped by galaxyId
  static Map<String, List<QuestModel>>? _sessionDailyQuestsMap;
  static int _completedDailyCount = 0;

  // Session-persistent daily hard quest state mapped by galaxyId
  static Map<String, QuestModel?>? _sessionDailyHardQuestMap;
  static Map<String, String?>? _sessionDailyHardDateStrMap;

  // Session-persistent side quests state mapped by galaxyId
  static Map<String, List<QuestModel>>? _sessionSideQuestsMap;

  // Session-persistent map of stable quest angles to prevent positions shifting when list size/indices change
  static final Map<String, double> _questAngles = {};

  @override
  void initState() {
    super.initState();
    // Continuous slow animation ticker to drive dynamic NPC assets and comets
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Initialize and refresh today's Daily Hard Quest
  void _initializeDailyHardQuest(GameProgression progression) {
    final today = progression.dailyHardDateStr;
    _sessionDailyHardQuestMap ??= {};
    _sessionDailyHardDateStrMap ??= {};

    if (_completedDailyCount >= 10) {
      _sessionDailyHardQuestMap![widget.galaxyId] = null;
      return;
    }

    final currentQuest = _sessionDailyHardQuestMap![widget.galaxyId];
    final currentDateStr = _sessionDailyHardDateStrMap![widget.galaxyId];

    if (currentQuest == null || currentDateStr != today) {
      if (progression.dailyHardGalaxyId == widget.galaxyId && !progression.dailyHardCompleted) {
        final hardLevel = SectorGenerator.generateDailyHardSector(progression, widget.galaxyId);
        _sessionDailyHardQuestMap![widget.galaxyId] = QuestModel(
          id: progression.dailyHardQuestId ?? "daily_hard_quest_${widget.galaxyId}",
          title: hardLevel.name,
          description: hardLevel.description,
          type: QuestType.daily,
          storyLoreSnippet: "TACTICAL INTRUDERS IN SECTOR!\n\n${hardLevel.description}",
          creditsReward: hardLevel.creditsReward,
          rpReward: hardLevel.researchPointsReward,
          levelData: hardLevel,
        );
        _sessionDailyHardDateStrMap![widget.galaxyId] = today;
      } else {
        _sessionDailyHardQuestMap![widget.galaxyId] = null;
        _sessionDailyHardDateStrMap![widget.galaxyId] = today;
      }
    } else {
      if (progression.dailyHardCompleted) {
        _sessionDailyHardQuestMap![widget.galaxyId] = null;
      }
    }
  }

  // Initialize and refresh daily quests list
  void _initializeSessionDailyQuests(GameProgression progression) {
    _sessionDailyQuestsMap ??= {};

    if (_completedDailyCount >= 10) {
      _sessionDailyQuestsMap![widget.galaxyId] = [];
      return;
    }

    if (_sessionDailyQuestsMap![widget.galaxyId] == null) {
      _sessionDailyQuestsMap![widget.galaxyId] = [];
      for (int i = 0; i < 3; i++) {
        _sessionDailyQuestsMap![widget.galaxyId]!.add(_generateUniqueDailyQuest(progression));
      }
    } else {
      // Clean completed procedural daily quests
      final completedIds = progression.completedQuestIds;
      final beforeCount = _sessionDailyQuestsMap![widget.galaxyId]!.length;
      _sessionDailyQuestsMap![widget.galaxyId]!.removeWhere((q) => completedIds.contains(q.id));
      final completedDelta = beforeCount - _sessionDailyQuestsMap![widget.galaxyId]!.length;
      _completedDailyCount = min(_completedDailyCount + completedDelta, 10);

      if (_completedDailyCount >= 10) {
        _sessionDailyQuestsMap![widget.galaxyId] = [];
        return;
      }

      // Spawning new daily sectors up to a maximum limit of 10 completions per session
      if (_completedDailyCount < 10) {
        final int maxToGenerate = 3 - _sessionDailyQuestsMap![widget.galaxyId]!.length;
        for (int i = 0; i < maxToGenerate; i++) {
          if (_completedDailyCount + _sessionDailyQuestsMap![widget.galaxyId]!.length < 10) {
            _sessionDailyQuestsMap![widget.galaxyId]!.add(_generateUniqueDailyQuest(progression));
          }
        }
      }
    }
  }

  QuestModel _generateUniqueDailyQuest(GameProgression progression) {
    final dailyLevel = SectorGenerator.generateDailySector(progression, widget.galaxyId);
    // Generate a secure unique daily quest ID
    final uniqueId = "daily_quest_${widget.galaxyId}_${dailyLevel.id}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}";
    return QuestModel(
      id: uniqueId,
      title: dailyLevel.name,
      description: dailyLevel.description,
      type: QuestType.daily,
      storyLoreSnippet: "A highly volatile stellar surge is warping sector coordinates. Calibrate superlasers to neutralize threat.",
      creditsReward: dailyLevel.creditsReward,
      rpReward: dailyLevel.researchPointsReward,
      levelData: dailyLevel,
    );
  }

  // Initialize and refresh side quests list dynamically refilling up to 7 active targets
  void _initializeSessionSideQuests(GalaxyModel galaxy, GameProgression progression) {
    _sessionSideQuestsMap ??= {};

    if (_sessionSideQuestsMap![galaxy.id] == null) {
      // Seed from campaign side quests that are not completed yet
      final galaxySideQuests = galaxy.quests
          .where((q) => q.type == QuestType.side && !progression.completedQuestIds.contains(q.id))
          .toList();
      _sessionSideQuestsMap![galaxy.id] = galaxySideQuests;

      // Refill to 7 active targets if starting with less
      while (_sessionSideQuestsMap![galaxy.id]!.length < 7) {
        _sessionSideQuestsMap![galaxy.id]!.add(_generateUniqueSideQuest(galaxy, progression));
      }
    } else {
      // Clean completed procedural or static side quests
      final completedIds = progression.completedQuestIds;
      _sessionSideQuestsMap![galaxy.id]!.removeWhere((q) => completedIds.contains(q.id));

      // Refill back to 7 active targets using procedural side quests
      while (_sessionSideQuestsMap![galaxy.id]!.length < 7) {
        _sessionSideQuestsMap![galaxy.id]!.add(_generateUniqueSideQuest(galaxy, progression));
      }
    }
  }

  QuestModel _generateUniqueSideQuest(GalaxyModel galaxy, GameProgression progression) {
    final sideLevel = SectorGenerator.generateDailySector(progression, galaxy.id);
    final uniqueId = "side_quest_${galaxy.id}_${sideLevel.id}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}";

    final List<String> sideTitles = [
      "Tactical Drift",
      "Stellar Anomaly",
      "Quantum Ripple",
      "Supernova Echo",
      "Nebula Skirmish",
      "Stardust Probe",
      "Cosmic Relay",
      "Dark Matter Sync"
    ];
    final title = "${sideTitles[Random().nextInt(sideTitles.length)]} ${10 + Random().nextInt(90)}";

    final galaxyNum = int.tryParse(galaxy.id.replaceAll('galaxy_', '')) ?? 1;

    final customizedLevel = LevelData(
      id: sideLevel.id,
      name: title,
      description: sideLevel.description,
      deathStarX: sideLevel.deathStarX,
      deathStarY: sideLevel.deathStarY,
      deathStarInitialAngle: sideLevel.deathStarInitialAngle,
      planets: sideLevel.planets,
      walls: sideLevel.walls,
      availableInventory: sideLevel.availableInventory,
      presetDevices: sideLevel.presetDevices,
      creditsReward: 150 + galaxyNum * 50 + Random().nextInt(100),
      researchPointsReward: 15 + galaxyNum * 5 + Random().nextInt(15),
    );

    return QuestModel(
      id: uniqueId,
      title: title,
      description: "Perform target calibration on simulated orbital relays to secure deep space lanes. ${sideLevel.description}",
      type: QuestType.side,
      storyLoreSnippet: "A localized gravity distortion has disrupted navigation vectors. Stabilize the sector targets.",
      creditsReward: customizedLevel.creditsReward,
      rpReward: customizedLevel.researchPointsReward,
      levelData: customizedLevel,
    );
  }

  // Helper to generate a stable, non-overlapping pseudo-random angle on an orbit path
  double _getStableQuestAngle(String questId, List<double> existingAngles) {
    if (!_questAngles.containsKey(questId)) {
      final random = Random();
      double angle = random.nextDouble() * 2.0 * pi;

      // Try to find a non-overlapping angle (up to 15 attempts)
      for (int attempt = 0; attempt < 15; attempt++) {
        bool tooClose = false;
        for (final extAngle in existingAngles) {
          final diff = (angle - extAngle).abs();
          final normDiff = min(diff, 2.0 * pi - diff);
          if (normDiff < 0.5) { // Enforce minimum separation to accommodate 7 active nodes
            tooClose = true;
            break;
          }
        }
        if (!tooClose) break;
        angle = random.nextDouble() * 2.0 * pi;
      }

      _questAngles[questId] = angle;
    }
    return _questAngles[questId]!;
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

          // 1. Enforce specific quest selection constraints
          // Lore quests: Max 1 active (incomplete) Lore quest
          final loreQuests = galaxy.quests.where((q) => q.type == QuestType.lore).toList();
          QuestModel? activeLoreQuest;
          for (var q in loreQuests) {
            if (!progression.completedQuestIds.contains(q.id)) {
              activeLoreQuest = q;
              break;
            }
          }

          // Side quests: Max 3 active (incomplete) Side quests (refilled dynamically when completed)
          _initializeSessionSideQuests(galaxy, progression);
          final sideQuests = _sessionSideQuestsMap?[galaxy.id] ?? const <QuestModel>[];

          // Daily quests: Max 3 active (incomplete) Daily quests (10 max total completions, refilled dynamically when completed)
          _initializeSessionDailyQuests(progression);
          final dailyQuests = _sessionDailyQuestsMap?[widget.galaxyId] ?? const <QuestModel>[];

          // Daily Hard Quest: 1 highly challenging mission per day in a random galaxy
          _initializeDailyHardQuest(progression);
          final currentDailyHardQuest = _sessionDailyHardQuestMap?[widget.galaxyId];

          if (_completedDailyCount >= 10 && _selectedQuest != null && _selectedQuest!.type == QuestType.daily) {
            _selectedQuest = null;
          }

          // Collect already-computed angles for both orbits to prevent overlapping
          final List<double> sideAngles = [];
          for (var q in sideQuests) {
            if (_questAngles.containsKey(q.id)) {
              sideAngles.add(_questAngles[q.id]!);
            }
          }

          final List<double> dailyAngles = [];
          for (var q in dailyQuests) {
            if (_questAngles.containsKey(q.id)) {
              dailyAngles.add(_questAngles[q.id]!);
            }
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                children: [
                  // Galaxy Board Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Color(0xFF00ADB5)),
                              onPressed: widget.onBackToMap,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    galaxy.name.toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Text(
                                    "SECTOR SOLAR MAP CONSOLE",
                                    style: TextStyle(
                                      color: Color(0xFF00FFF5),
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Core Resources Chips (Money click -> Shop, RP click -> Research Lab)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              widget.onGoToShop();
                            },
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: _buildStatChip(Icons.monetization_on, "${progression.credits}", Colors.amberAccent),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              widget.onGoToResearch();
                            },
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: _buildStatChip(Icons.science, "${progression.researchPoints} RP", Colors.purpleAccent),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 1,
                    color: const Color(0xFF00ADB5).withOpacity(0.15),
                  ),
                  const SizedBox(height: 8),

                  // Solar System Map Area
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final mapWidth = constraints.maxWidth;
                        final mapHeight = constraints.maxHeight;

                        // Center the solar system map vertically to balance top/bottom space
                        final center = Offset(mapWidth / 2.0, mapHeight * 0.48);

                        // Calculate aspect ratio to dynamically adjust the vertical squish (orbitYRadii multiplier)
                        // If we have excess vertical space (tall screen), we open up the orbits to separate nodes and fill height.
                        final double aspectRatio = mapHeight / mapWidth;
                        final double yMultiplier = (0.35 * aspectRatio).clamp(0.35, 0.65);

                        // Slightly increase horizontal space usage if screen allows, keeping safety margin
                        final double maxRadiusX = mapWidth / 2.0 - 24.0;
                        final orbitXRadii = [maxRadiusX * 0.42, maxRadiusX * 0.73, maxRadiusX * 1.00];
                        final orbitYRadii = [
                          orbitXRadii[0] * yMultiplier,
                          orbitXRadii[1] * yMultiplier,
                          orbitXRadii[2] * yMultiplier,
                        ];

                        return AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            final double animVal = _animationController.value;

                            return Stack(
                              children: [
                                // 1. Deep space vector painter (stellar backdrop + orbits + extra animated NPC ships)
                                Positioned.fill(
                                  child: RepaintBoundary(
                                    child: CustomPaint(
                                      painter: _SolarSystemPainter(
                                        center: center,
                                        orbitXRadii: orbitXRadii,
                                        orbitYRadii: orbitYRadii,
                                        animProgress: animVal,
                                      ),
                                    ),
                                  ),
                                ),

                                // 2. Interactive Orbiting Planet Nodes (Static, stable positioning on tracks)
                                // A. Active Lore Quest Planet Node (Orbit 1, Inner, placed in front foreground)
                                if (activeLoreQuest != null)
                                  _buildOrbitingPlanet(
                                    quest: activeLoreQuest,
                                    center: center,
                                    rx: orbitXRadii[0],
                                    ry: orbitYRadii[0],
                                    theta: pi / 2, // Static frontmost
                                    themeColor: const Color(0xFF00FFF5),
                                    icon: Icons.explore,
                                  ),

                                // B. Active Side Quest Planet Nodes (Orbit 2, Middle)
                                ...List.generate(sideQuests.length, (idx) {
                                  final quest = sideQuests[idx];
                                  final theta = _getStableQuestAngle(quest.id, sideAngles);
                                  if (!sideAngles.contains(theta)) sideAngles.add(theta);
                                  return _buildOrbitingPlanet(
                                    quest: quest,
                                    center: center,
                                    rx: orbitXRadii[1],
                                    ry: orbitYRadii[1],
                                    theta: theta,
                                    themeColor: const Color(0xFFFF2E93),
                                    icon: Icons.assignment,
                                  );
                                }),

                                // C. Active Daily Quest Planet Nodes (Orbit 3, Outer)
                                ...List.generate(dailyQuests.length, (idx) {
                                  final quest = dailyQuests[idx];
                                  final theta = _getStableQuestAngle(quest.id, dailyAngles);
                                  if (!dailyAngles.contains(theta)) dailyAngles.add(theta);
                                  return _buildOrbitingPlanet(
                                    quest: quest,
                                    center: center,
                                    rx: orbitXRadii[2],
                                    ry: orbitYRadii[2],
                                    theta: theta,
                                    themeColor: const Color(0xFFFFB703),
                                    icon: Icons.track_changes,
                                  );
                                }),

                                // D. Active Daily Hard Quest Node (Orbit 3, Outer, opposite rightmost coordinate)
                                if (currentDailyHardQuest != null)
                                  _buildOrbitingPlanet(
                                    quest: currentDailyHardQuest,
                                    center: center,
                                    rx: orbitXRadii[2],
                                    ry: orbitYRadii[2],
                                    theta: 0.0,
                                    themeColor: const Color(0xFFFF1744),
                                    icon: Icons.gps_fixed,
                                    isHardDaily: true,
                                  ),

                                // 3. Centered Tactical Briefing Console Modal (Overlay with dimming & blur click-outside dismiss)
                                if (_selectedQuest != null)
                                  Positioned.fill(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        setState(() {
                                          _selectedQuest = null;
                                        });
                                      },
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                                        child: Container(
                                          color: Colors.black.withOpacity(0.55),
                                          child: Center(
                                            child: GestureDetector(
                                              onTap: () {}, // Prevent taps inside the modal from dismissing it
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                                child: _buildBriefingConsole(context, _selectedQuest!),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
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

  Widget _buildOrbitingPlanet({
    required QuestModel quest,
    required Offset center,
    required double rx,
    required double ry,
    required double theta,
    required Color themeColor,
    required IconData icon,
    bool isHardDaily = false,
  }) {
    // Parametric calculations to find position on the compressed elliptical track
    const double phi = -pi / 4; // -45 degrees rotation for bottom-left to top-right skew
    final double dx = rx * cos(theta);
    final double dy = ry * sin(theta);
    
    // Rotate coordinates around solar system center
    final double px = center.dx + dx * cos(phi) - dy * sin(phi);
    final double py = center.dy + dx * sin(phi) + dy * cos(phi);

    // Dynamic scale map based on Z-depth (sin(theta) ranges from -1.0 to 1.0)
    // Planets at the back (sin(theta) < 0) are smaller; foreground planets (sin(theta) > 0) are larger
    final double depthScale = 0.82 + (sin(theta) * 0.18);
    final double planetSize = 52.0 * depthScale;

    final isSelected = _selectedQuest?.id == quest.id;

    return Positioned(
      left: px - (planetSize * 1.6) / 2,
      top: py - planetSize / 2,
      width: planetSize * 1.6,
      height: planetSize + 32.0 * depthScale, // scale label margin as well
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() {
            if (isSelected) {
              _selectedQuest = null; // Toggle dismiss
            } else {
              _selectedQuest = quest; // Select active briefing
            }
          });
        },
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer Pulsing Orbit Halo Ring
                Container(
                  width: planetSize,
                  height: planetSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: themeColor.withOpacity(isSelected ? 0.35 : 0.12),
                        blurRadius: isSelected ? 16 * depthScale : 8 * depthScale,
                        spreadRadius: isSelected ? 3 * depthScale : 1 * depthScale,
                      )
                    ],
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFFFFFF) : themeColor.withOpacity(0.3),
                      width: isSelected ? 1.5 * depthScale : 1.0 * depthScale,
                    ),
                  ),
                ),

                // Core Planet Body
                Container(
                  width: planetSize - 10.0 * depthScale,
                  height: planetSize - 10.0 * depthScale,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B0E14).withOpacity(0.95),
                    shape: BoxShape.circle,
                    border: Border.all(color: themeColor.withOpacity(0.8), width: 1.5 * depthScale),
                  ),
                  child: Icon(
                    icon,
                    size: 18 * depthScale,
                    color: themeColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Floating responsive planet label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isHardDaily ? const Color(0xFF2C0A0D).withOpacity(0.85) : const Color(0xFF161B22).withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
                border: isHardDaily ? Border.all(color: const Color(0xFFFF1744).withOpacity(0.4), width: 0.8) : null,
              ),
              child: Text(
                isHardDaily
                    ? "⚠️ THREAT: ${quest.title.replaceAll(RegExp(r'^DAILY HARD:\s*', caseSensitive: false), '').toUpperCase()}"
                    : quest.title.replaceAll(RegExp(r'^Daily Sector:\s*', caseSensitive: false), '').toUpperCase(),
                style: TextStyle(
                  color: isSelected 
                      ? const Color(0xFFFFFFFF) 
                      : (isHardDaily ? const Color(0xFFFF1744) : Colors.grey),
                  fontSize: 7.5 * depthScale,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBriefingConsole(BuildContext context, QuestModel quest) {
    final isHardDaily = quest.id == widget.controller.progression.dailyHardQuestId;
    String typeLabel = "STORY EVENT";
    Color typeColor = StyleGuide.tertiary;
    if (isHardDaily) {
      typeLabel = "🚨 DAILY TACTICAL THREAT ALERT 🚨";
      typeColor = const Color(0xFFFF1744);
    } else if (quest.type == QuestType.side) {
      typeLabel = "TACTICAL DRILL";
      typeColor = StyleGuide.secondary;
    } else if (quest.type == QuestType.daily) {
      typeLabel = "DAILY RELAYS SECTOR";
      typeColor = StyleGuide.primary;
    }

    final cleanTitle = quest.title
        .replaceAll(RegExp(r'^Daily Sector:\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'^Daily Target:\s*', caseSensitive: false), '');

    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: StyleGuide.neutralBg.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: typeColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: typeColor.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Slide briefing header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      typeLabel,
                      style: TextStyle(
                        color: typeColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cleanTitle.toUpperCase(),
                      style: const TextStyle(
                        color: StyleGuide.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.close, color: StyleGuide.textGrey, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() {
                    _selectedQuest = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Briefing Lore Snippet
          if (quest.storyLoreSnippet != null) ...[
            Container(
              padding: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: typeColor.withOpacity(0.2), width: 2),
                ),
              ),
              child: Text(
                "\"${quest.storyLoreSnippet}\"",
                style: TextStyle(
                  color: typeColor.withOpacity(0.6),
                  fontSize: 11,
                  fontFamily: 'monospace',
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Equipped Loadout Preview
          Builder(
            builder: (context) {
              final Map<String, int> ownedDevices = {};
              widget.controller.progression.purchasedMarketDevices.forEach((itemId, count) {
                if (count > 0) {
                  ownedDevices[itemId] = count;
                }
              });

              if (ownedDevices.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: StyleGuide.secondary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: StyleGuide.secondary.withOpacity(0.2), width: 1.2),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: StyleGuide.secondary.withOpacity(0.55), size: 24),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          "NO BLUEPRINTS EQUIPPED: VISIT ARMORY",
                          style: TextStyle(
                            color: StyleGuide.secondary.withOpacity(0.55),
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "EQUIPPED BLUEPRINTS:",
                    style: TextStyle(
                      color: StyleGuide.textGrey,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ownedDevices.entries.map((entry) {
                        final itemId = entry.key;
                        final count = entry.value;

                        IconData icon = Icons.construction;
                        Color color = StyleGuide.tertiary;
                        String name = itemId.toUpperCase();

                        if (itemId == 'reflector') {
                          icon = Icons.flip;
                          color = const Color(0xFF00FFF5);
                          name = "REFLECTOR";
                        } else if (itemId == 'portal') {
                          icon = Icons.circle_outlined;
                          color = const Color(0xFFFF9F1C);
                          name = "WARP PORTAL";
                        } else if (itemId == 'gravityWell') {
                          icon = Icons.blur_circular;
                          color = const Color(0xFF7B2CBF);
                          name = "GRAVITY WELL";
                        } else if (itemId == 'bomb') {
                          icon = Icons.brightness_low;
                          color = const Color(0xFFFF3333);
                          name = "BOMB";
                        } else if (itemId.startsWith('splitter_')) {
                          icon = Icons.call_split;
                          color = StyleGuide.secondary;
                          final angleStr = itemId.split('_')[1];
                          name = "SPLIT $angleStr°";
                        }

                        return Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: StyleGuide.neutralCard,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: color.withOpacity(0.35)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon, size: 12, color: color),
                              const SizedBox(width: 6),
                              Text(
                                "$name x$count",
                                style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Rewards Chips Row & Daily Limit
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildModalRewardChip(Icons.monetization_on, "+${quest.creditsReward} CREDITS", Colors.amberAccent),
              const SizedBox(width: 16),
              _buildModalRewardChip(Icons.science, "+${quest.rpReward} RP", StyleGuide.tertiary),
            ],
          ),
          const SizedBox(height: 20),

          // Daily progress track
          if (quest.type == QuestType.daily) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "RELAY PROGRESS",
                  style: TextStyle(
                    color: StyleGuide.textGrey,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  "${min(_completedDailyCount, 10)} / 10 DONE",
                  style: const TextStyle(
                    color: StyleGuide.tertiary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: min(_completedDailyCount, 10) / 10.0,
                minHeight: 4.5,
                backgroundColor: StyleGuide.neutralCard,
                valueColor: const AlwaysStoppedAnimation<Color>(StyleGuide.tertiary),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Deployment Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                final q = _selectedQuest;
                setState(() {
                  _selectedQuest = null; // reset selected drawer state
                });
                if (q != null) {
                  widget.onQuestSelected(q);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: StyleGuide.primary,
                foregroundColor: const Color(0xFF0F1115),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 4,
              ),
              child: const Text(
                "DEPLOY COMMAND DECK",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: 'monospace',
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              "AUTH: ADMIRAL K. STERLING // SECTOR ID: ${quest.id.toUpperCase()}",
              style: TextStyle(
                color: typeColor.withOpacity(0.4),
                fontSize: 7.5,
                fontFamily: 'monospace',
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalRewardChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1115).withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 4,
            spreadRadius: 0.5,
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------
// Solar System Vector Ellipse Painter
// ------------------------------------------------------------------

class _SolarSystemPainter extends CustomPainter {
  final Offset center;
  final List<double> orbitXRadii;
  final List<double> orbitYRadii;
  final double animProgress;

  _SolarSystemPainter({
    required this.center,
    required this.orbitXRadii,
    required this.orbitYRadii,
    required this.animProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw static stellar background field cross patterns deterministically
    for (int i = 0; i < 40; i++) {
      // Stable coordinate values derived from index i so they never jump on repaint
      final double sx = (sin(i * 145.67) * 0.5 + 0.5) * size.width;
      final double sy = (cos(i * 324.89) * 0.5 + 0.5) * size.height;
      final double starOpacity = (sin(i * 777.0) * 0.5 + 0.5) * 0.45 + 0.05;
      
      final starPaint = Paint()
        ..color = const Color(0xFFE2E8F0).withOpacity(starOpacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(sx, sy), 0.8, starPaint);

      // Add a slight star flare glow to every fifth star
      if (i % 5 == 0) {
        final glowPaint = Paint()
          ..color = const Color(0xFF00FFF5).withOpacity(starOpacity * 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
        canvas.drawCircle(Offset(sx, sy), 2.5, glowPaint);
      }
    }

    // Save canvas state before applying rotations
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-pi / 4); // Rotates the system by 45 degrees counter-clockwise

    // 2. Draw concentric dashed vector orbits (Subtle, barely visible at 8% opacity)
    final orbitPaint = Paint()
      ..color = const Color(0xFF00FFF5).withOpacity(0.08) // Cyber Cyan barely visible
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < orbitXRadii.length; i++) {
      final rx = orbitXRadii[i];
      final ry = orbitYRadii[i];
      final path = Path();
      
      path.addOval(Rect.fromCenter(center: Offset.zero, width: rx * 2.0, height: ry * 2.0));
      _drawDashedPath(canvas, path, orbitPaint);
    }

    // 3. Draw central Galaxy Command Core Star (Sun) with tilt shadow
    const double sunRadius = 38.0;
    
    // Core radial solar glow
    final sunGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00FFF5).withOpacity(0.35),
          const Color(0xFFFF2E93).withOpacity(0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: sunRadius * 2.0));
    canvas.drawCircle(Offset.zero, sunRadius * 2.0, sunGlowPaint);

    final sunCorePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFFFFF),
          const Color(0xFF00ADB5),
          const Color(0xFF0B0E14),
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: sunRadius));
    canvas.drawCircle(Offset.zero, sunRadius, sunCorePaint);
    
    // Core command hub tech border ring
    final sunBorderPaint = Paint()
      ..color = const Color(0xFF00FFF5).withOpacity(0.80)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset.zero, sunRadius, sunBorderPaint);

    // 4. Draw extra animated NPC objects (moving scout ships / comets) to keep page alive
    // NPC 1: Tiny glowing Cyber-Green Scout Drone orbiting core star
    final double droneAngle = animProgress * 2.0 * pi * 1.5; // Orbit cycle
    final double ddx = orbitXRadii[1] * 0.9 * cos(droneAngle);
    final double ddy = orbitYRadii[1] * 0.9 * sin(droneAngle);
    // Inclined tilt angle (rotated 20 degrees / 0.35 radians)
    final double droneX = ddx * cos(0.35) - ddy * sin(0.35);
    final double droneY = ddx * sin(0.35) + ddy * cos(0.35);
    final Offset dronePos = Offset(droneX, droneY);

    final dronePaint = Paint()
      ..color = const Color(0xFF00FF87)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(dronePos, 2.5, dronePaint);

    final droneGlow = Paint()
      ..color = const Color(0xFF00FF87).withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawCircle(dronePos, 6.0, droneGlow);

    // NPC 2: Pulsing Hot-Pink Space Probe orbiting on the outer track in reverse
    final double probeAngle = animProgress * 2.0 * pi * -0.6; // Reverse orbit
    final double pdx = orbitXRadii[2] * 0.95 * cos(probeAngle);
    final double pdy = orbitYRadii[2] * 0.95 * sin(probeAngle);
    final Offset probePos = Offset(pdx, pdy);

    final probePaint = Paint()
      ..color = const Color(0xFFFF2E93)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(probePos, 2.0, probePaint);

    final probeGlow = Paint()
      ..color = const Color(0xFFFF2E93).withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    canvas.drawCircle(probePos, 5.0, probeGlow);

    // Restore canvas state
    canvas.restore();
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 5.0;

    final PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double length = min(dashWidth, metric.length - distance);
        final Path extract = metric.extractPath(distance, distance + length);
        canvas.drawPath(extract, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SolarSystemPainter oldDelegate) {
    return oldDelegate.center != center ||
        oldDelegate.orbitXRadii.length != orbitXRadii.length ||
        oldDelegate.animProgress != animProgress;
  }
}
