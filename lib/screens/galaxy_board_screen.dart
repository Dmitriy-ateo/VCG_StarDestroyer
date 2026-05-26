import 'dart:math';
import 'dart:ui';
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
  late AnimationController _animationController;
  QuestModel? _selectedQuest;

  // Session-persistent daily quests state
  static List<QuestModel>? _sessionDailyQuests;
  static int _completedDailyCount = 0;

  @override
  void initState() {
    super.initState();
    // Continuous slow planetary rotation loop (repeats infinitely)
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

  // Initialize and refresh daily quests list
  void _initializeSessionDailyQuests(GameProgression progression) {
    if (_sessionDailyQuests == null) {
      _sessionDailyQuests = [];
      for (int i = 0; i < 3; i++) {
        _sessionDailyQuests!.add(_generateUniqueDailyQuest(progression));
      }
    } else {
      // Clean completed procedural daily quests
      final completedIds = progression.completedQuestIds;
      final beforeCount = _sessionDailyQuests!.length;
      _sessionDailyQuests!.removeWhere((q) => completedIds.contains(q.id));
      final completedDelta = beforeCount - _sessionDailyQuests!.length;
      _completedDailyCount += completedDelta;

      // Spawning new daily sectors up to a maximum limit of 10 completions per session
      if (_completedDailyCount < 10) {
        final int maxToGenerate = 3 - _sessionDailyQuests!.length;
        for (int i = 0; i < maxToGenerate; i++) {
          if (_completedDailyCount + _sessionDailyQuests!.length < 10) {
            _sessionDailyQuests!.add(_generateUniqueDailyQuest(progression));
          }
        }
      }
    }
  }

  QuestModel _generateUniqueDailyQuest(GameProgression progression) {
    final dailyLevel = SectorGenerator.generateDailySector(progression);
    // Generate a secure unique daily quest ID
    final uniqueId = "daily_quest_${dailyLevel.id}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}";
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

          // Side quests: Max 3 active (incomplete) Side quests
          final sideQuests = galaxy.quests
              .where((q) => q.type == QuestType.side && !progression.completedQuestIds.contains(q.id))
              .take(3)
              .toList();

          // Daily quests: Max 3 active (incomplete) Daily quests (10 max total completions)
          _initializeSessionDailyQuests(progression);
          final dailyQuests = _sessionDailyQuests ?? const <QuestModel>[];

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                children: [
                  // Galaxy Board Header
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
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const Text(
                                "SECTOR SOLAR MAP CONSOLE",
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
                      // Core Resources Chips
                      Row(
                        children: [
                          _buildStatChip(Icons.monetization_on, "${progression.credits}", Colors.amberAccent),
                          const SizedBox(width: 8),
                          _buildStatChip(Icons.science, "${progression.researchPoints} RP", Colors.purpleAccent),
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

                        final center = Offset(mapWidth / 2.0, mapHeight * 0.42);

                        // Responsive elliptical orbit diameters
                        final orbitXRadii = [mapWidth * 0.20, mapWidth * 0.35, mapWidth * 0.48];
                        final orbitYRadii = [mapWidth * 0.15, mapWidth * 0.26, mapWidth * 0.36];

                        // Spacers for Side and Daily planet distributions
                        final sideAngles = [pi / 4, pi / 4 + (2 * pi / 3), pi / 4 + (4 * pi / 3)];
                        final dailyAngles = [pi / 6, pi / 6 + (2 * pi / 3), pi / 6 + (4 * pi / 3)];

                        return AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            final double animVal = _animationController.value;

                            return Stack(
                              children: [
                                // 1. Custom Painted orbits & core command Hub
                                Positioned.fill(
                                  child: RepaintBoundary(
                                    child: CustomPaint(
                                      painter: _SolarSystemPainter(
                                        center: center,
                                        orbitXRadii: orbitXRadii,
                                        orbitYRadii: orbitYRadii,
                                      ),
                                    ),
                                  ),
                                ),

                                // 2. Interactive Orbiting Planet Nodes
                                // A. Active Lore Quest Planet Node (Orbit 1, Inner)
                                if (activeLoreQuest != null)
                                  _buildOrbitingPlanet(
                                    quest: activeLoreQuest,
                                    center: center,
                                    rx: orbitXRadii[0],
                                    ry: orbitYRadii[0],
                                    theta0: 0.0,
                                    speedFactor: 1.8,
                                    animProgress: animVal,
                                    themeColor: const Color(0xFF00FFF5),
                                    icon: Icons.explore,
                                  ),

                                // B. Active Side Quest Planet Nodes (Orbit 2, Middle)
                                ...List.generate(sideQuests.length, (idx) {
                                  final quest = sideQuests[idx];
                                  return _buildOrbitingPlanet(
                                    quest: quest,
                                    center: center,
                                    rx: orbitXRadii[1],
                                    ry: orbitYRadii[1],
                                    theta0: sideAngles[idx % 3],
                                    speedFactor: 1.2,
                                    animProgress: animVal,
                                    themeColor: const Color(0xFFFF2E93),
                                    icon: Icons.assignment,
                                  );
                                }),

                                // C. Active Daily Quest Planet Nodes (Orbit 3, Outer)
                                ...List.generate(dailyQuests.length, (idx) {
                                  final quest = dailyQuests[idx];
                                  return _buildOrbitingPlanet(
                                    quest: quest,
                                    center: center,
                                    rx: orbitXRadii[2],
                                    ry: orbitYRadii[2],
                                    theta0: dailyAngles[idx % 3],
                                    speedFactor: -0.7, // Rotate in opposite direction
                                    animProgress: animVal,
                                    themeColor: const Color(0xFFFFB703),
                                    icon: Icons.track_changes,
                                  );
                                }),

                                // 3. Glassmorphic Slide-Up Tactical Briefing Console Drawer (Absolute overlay)
                                if (_selectedQuest != null)
                                  Positioned(
                                    left: 4,
                                    right: 4,
                                    bottom: 4,
                                    child: _buildBriefingConsole(context, _selectedQuest!),
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
    required double theta0,
    required double speedFactor,
    required double animProgress,
    required Color themeColor,
    required IconData icon,
  }) {
    // Parametric calculations to find position on the responsive elliptical track
    final double theta = theta0 + (animProgress * 2 * pi * speedFactor);
    final double px = center.dx + rx * cos(theta);
    final double py = center.dy + ry * sin(theta);
    const double planetSize = 52.0;

    final isSelected = _selectedQuest?.id == quest.id;

    return Positioned(
      left: px - planetSize / 2,
      top: py - planetSize / 2,
      width: planetSize,
      height: planetSize + 22.0, // extra height for bottom planet label tag
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
                        blurRadius: isSelected ? 16 : 8,
                        spreadRadius: isSelected ? 3 : 1,
                      )
                    ],
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFFFFFF) : themeColor.withOpacity(0.3),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                ),

                // Core Planet Body
                Container(
                  width: planetSize - 10.0,
                  height: planetSize - 10.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B0E14).withOpacity(0.95),
                    shape: BoxShape.circle,
                    border: Border.all(color: themeColor.withOpacity(0.8), width: 1.5),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: themeColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Floating responsive planet label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22).withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                quest.title.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? const Color(0xFFFFFFFF) : Colors.grey,
                  fontSize: 7.5,
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
    String typeLabel = "STORY MISSION";
    Color typeColor = const Color(0xFF00FFF5);
    if (quest.type == QuestType.side) {
      typeLabel = "TACTICAL DRILL";
      typeColor = const Color(0xFFFF2E93);
    } else if (quest.type == QuestType.daily) {
      typeLabel = "DAILY RELAYS SECTOR";
      typeColor = const Color(0xFFFFB703);
    }

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22).withOpacity(0.88),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: typeColor.withOpacity(0.7), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: typeColor.withOpacity(0.12),
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
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeLabel,
                      style: TextStyle(
                        color: typeColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      quest.title.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                  onPressed: () {
                    setState(() {
                      _selectedQuest = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Briefing Lore Snippet
            if (quest.storyLoreSnippet != null) ...[
              Text(
                "\"${quest.storyLoreSnippet}\"",
                style: TextStyle(
                  color: typeColor.withOpacity(0.8),
                  fontSize: 10.5,
                  fontStyle: FontStyle.italic,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Quest Mission Objective Description
            const Text(
              "DIRECTIVE OBJECTIVE:",
              style: TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            const SizedBox(height: 2),
            Text(
              quest.description,
              style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 11.5, height: 1.4),
            ),
            const SizedBox(height: 10),

            // Rewards Chips Row & Daily Limit
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildMiniRewardChip(Icons.monetization_on, "+${quest.creditsReward}", Colors.amberAccent),
                    const SizedBox(width: 8),
                    _buildMiniRewardChip(Icons.science, "+${quest.rpReward} RP", Colors.purpleAccent),
                  ],
                ),
                if (quest.type == QuestType.daily)
                  Text(
                    "RELAY PROGRESS: $_completedDailyCount/10 DONE",
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Deployment Button
            SizedBox(
              width: double.infinity,
              height: 42,
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
                  backgroundColor: typeColor,
                  foregroundColor: const Color(0xFF0B0E14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 4,
                ),
                child: const Text(
                  "DEPLOY COMMAND DECK",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
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

// ------------------------------------------------------------------
// Solar System Vector Ellipse Painter
// ------------------------------------------------------------------

class _SolarSystemPainter extends CustomPainter {
  final Offset center;
  final List<double> orbitXRadii;
  final List<double> orbitYRadii;

  _SolarSystemPainter({
    required this.center,
    required this.orbitXRadii,
    required this.orbitYRadii,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw concentric dashed vector orbits
    final orbitPaint = Paint()
      ..color = const Color(0xFF132238).withOpacity(0.35)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < orbitXRadii.length; i++) {
      final rx = orbitXRadii[i];
      final ry = orbitYRadii[i];
      final path = Path();
      
      path.addOval(Rect.fromCenter(center: center, width: rx * 2, height: ry * 2));
      _drawDashedPath(canvas, path, orbitPaint);
    }

    // 2. Draw glowing central Galaxy Command Core Star (Sun)
    const double sunRadius = 38.0;
    
    // Core radial solar glow
    final sunGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00FFF5).withOpacity(0.35),
          const Color(0xFFFF2E93).withOpacity(0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: sunRadius * 2.0));
    canvas.drawCircle(center, sunRadius * 2.0, sunGlowPaint);

    final sunCorePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFFFFF),
          const Color(0xFF00ADB5),
          const Color(0xFF0B0E14),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: sunRadius));
    canvas.drawCircle(center, sunRadius, sunCorePaint);
    
    // Core command hub tech border ring
    final sunBorderPaint = Paint()
      ..color = const Color(0xFF00FFF5).withOpacity(0.80)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, sunRadius, sunBorderPaint);
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
        oldDelegate.orbitXRadii.length != orbitXRadii.length;
  }
}
