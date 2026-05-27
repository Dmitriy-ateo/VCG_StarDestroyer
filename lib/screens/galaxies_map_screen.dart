import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/galaxy_model.dart';
import '../models/game_progression.dart';
import '../game/game_controller.dart';

class GalaxiesMapScreen extends StatefulWidget {
  final GameController controller;
  final Function(String) onGalaxySelected;
  final VoidCallback onBackToMenu;
  final VoidCallback onGoToShop;
  final VoidCallback onGoToResearch;

  const GalaxiesMapScreen({
    super.key,
    required this.controller,
    required this.onGalaxySelected,
    required this.onBackToMenu,
    required this.onGoToShop,
    required this.onGoToResearch,
  });

  @override
  State<GalaxiesMapScreen> createState() => _GalaxiesMapScreenState();
}

class _GalaxiesMapScreenState extends State<GalaxiesMapScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Scroll automatically to the bottom on load to highlight the latest active unlocked galaxy
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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
          final progression = widget.controller.progression;
          final galaxies = preloadedGalaxies;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Block
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
                              onPressed: widget.onBackToMenu,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "GALACTIC COMMAND",
                                    style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "COSMIC SECTOR MAPPING SYSTEM",
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
                  const SizedBox(height: 12),

                  // Responsive Scrolling Snake Path Layout
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final mapWidth = constraints.maxWidth;
                        final double nodeSize = (mapWidth * 0.60).clamp(120.0, 240.0);
                        final double segmentH = nodeSize * 1.25;
                        final double totalH = segmentH * galaxies.length + 80.0;
                        const double bottomMargin = 40.0;

                        // Calculate mathematical coordinates for each galaxy center
                        final List<Offset> centers = [];
                        for (int i = 0; i < galaxies.length; i++) {
                          final bool isLeft = (i % 2 == 0);
                          final double gx = isLeft ? mapWidth * 0.28 : mapWidth * 0.72;
                          final double gy = totalH - bottomMargin - (i * segmentH) - (segmentH / 2);
                          centers.add(Offset(gx, gy));
                        }

                        return SingleChildScrollView(
                          controller: _scrollController,
                          child: SizedBox(
                            width: mapWidth,
                            height: totalH,
                            child: Stack(
                              children: [
                                // 1. Space Grid Background
                                Positioned.fill(
                                  child: RepaintBoundary(
                                    child: CustomPaint(
                                      painter: _CosmicGridPainter(),
                                    ),
                                  ),
                                ),

                                // 2. Connecting Snake Dotted Path Line
                                Positioned.fill(
                                  child: RepaintBoundary(
                                    child: CustomPaint(
                                      painter: _SnakePathPainter(
                                        centers: centers,
                                        completedGalaxyIds: progression.completedGalaxyIds,
                                        galaxies: galaxies,
                                      ),
                                    ),
                                  ),
                                ),

                                // 3. Interactive Procedural Galaxy Node Widgets
                                ...List.generate(galaxies.length, (index) {
                                  final galaxy = galaxies[index];
                                  final center = centers[index];
                                  final isUnlocked = galaxy.checkUnlockStatus(progression);
                                  final isCompleted = progression.completedGalaxyIds.contains(galaxy.id);
                                  final activeLoreGalaxyId = _getActiveLoreGalaxyId(progression);
                                  final isTargetLoreGalaxy = activeLoreGalaxyId == galaxy.id;
                                  
                                  return Positioned(
                                    left: center.dx - nodeSize / 2,
                                    top: center.dy - nodeSize / 2,
                                    width: nodeSize,
                                    height: nodeSize,
                                    child: GestureDetector(
                                      onTap: () => _showGalaxyTravelModal(context, galaxy, isUnlocked, progression),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Outer Glowing Halo
                                          Container(
                                            width: nodeSize * 0.85,
                                            height: nodeSize * 0.85,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: (isUnlocked
                                                      ? const Color(0xFF00ADB5)
                                                      : Colors.redAccent).withOpacity(0.08),
                                                  blurRadius: 20,
                                                  spreadRadius: 2,
                                                )
                                              ],
                                            ),
                                          ),
                                          
                                          // Procedural Custom Painted Disk
                                          SizedBox(
                                            width: nodeSize * 0.95,
                                            height: nodeSize * 0.95,
                                            child: RepaintBoundary(
                                              child: CustomPaint(
                                                painter: _buildGalaxyPainter(galaxy.id, isUnlocked),
                                              ),
                                            ),
                                          ),

                                          // Central Status Center Icon Badge
                                          _buildCenterIconBadge(isUnlocked, isCompleted),

                                          // Active Lore Guidance Indicator Badge
                                          if (isTargetLoreGalaxy && isUnlocked)
                                            Positioned(
                                              top: nodeSize * 0.08,
                                              right: nodeSize * 0.08,
                                              child: _buildLoreGuidanceBadge(),
                                            ),

                                          // Floating Galaxy Tag Banner (Underneath Node)
                                          Positioned(
                                            bottom: 0,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF161B22).withOpacity(0.85),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: isUnlocked
                                                      ? const Color(0xFF00ADB5).withOpacity(0.3)
                                                      : Colors.redAccent.withOpacity(0.2),
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: Text(
                                                galaxy.name.toUpperCase(),
                                                style: TextStyle(
                                                  color: isUnlocked ? const Color(0xFFFFFFFF) : Colors.grey,
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
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

  CustomPainter _buildGalaxyPainter(String galaxyId, bool isUnlocked) {
    switch (galaxyId) {
      case 'galaxy_2':
        return _NebularDepthsPainter(isUnlocked: isUnlocked);
      case 'galaxy_3':
        return _OuterHorizonPainter(isUnlocked: isUnlocked);
      case 'galaxy_1':
      default:
        return _CoreOutpostPainter(isUnlocked: isUnlocked);
    }
  }

  String? _getActiveLoreGalaxyId(GameProgression progression) {
    for (var galaxy in preloadedGalaxies) {
      for (var quest in galaxy.quests) {
        if (quest.type == QuestType.lore && !progression.completedQuestIds.contains(quest.id)) {
          return galaxy.id;
        }
      }
    }
    return null;
  }

  Widget _buildLoreGuidanceBadge() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFF0B0E14).withOpacity(0.9),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF00FFF5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFF5).withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: const Icon(
        Icons.explore,
        color: Color(0xFF00FFF5),
        size: 13,
      ),
    );
  }

  Widget _buildCenterIconBadge(bool isUnlocked, bool isCompleted) {
    if (isCompleted) {
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: Color(0xFF00FF87),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Color(0xFFFFFFFF), size: 14),
      );
    }

    if (!isUnlocked) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFF0B0E14).withOpacity(0.9),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.redAccent, width: 1.0),
        ),
        child: const Icon(Icons.lock, color: Colors.redAccent, size: 12),
      );
    }

    // Active unlocked, show pulsing pointer
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF00ADB5),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFF5).withOpacity(0.4),
            blurRadius: 8,
          )
        ],
      ),
      child: const Icon(Icons.gps_fixed, color: Color(0xFFFFFFFF), size: 14),
    );
  }

  void _showGalaxyTravelModal(BuildContext context, GalaxyModel galaxy, bool isUnlocked, GameProgression progression) {
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: AlertDialog(
            backgroundColor: const Color(0xFF161B22).withOpacity(0.95),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.5),
              side: BorderSide(
                color: isUnlocked ? const Color(0xFF00ADB5) : Colors.redAccent,
                width: 1.5,
              ),
            ),
            title: Row(
              children: [
                Icon(
                  isUnlocked ? Icons.travel_explore : Icons.lock_outline,
                  color: isUnlocked ? const Color(0xFF00FFF5) : Colors.redAccent,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    galaxy.name.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "GALAXY DIRECTIVE & LORE:",
                    style: TextStyle(
                      color: Color(0xFF00FFF5),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    galaxy.description,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Bullet Requirements List
                  Text(
                    isUnlocked ? "SYSTEM SPECIFICATIONS MET:" : "LOCK REQUIREMENTS CHECKLIST:",
                    style: TextStyle(
                      color: isUnlocked ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (isUnlocked)
                    Row(
                      children: const [
                        Icon(
                          Icons.check_circle_outline,
                          size: 12,
                          color: Colors.greenAccent,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Access key cleared. Sector open.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  else
                    ..._buildLockBullets(galaxy, progression),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  "DISMISS",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: isUnlocked
                    ? () {
                        Navigator.of(context).pop();
                        widget.onGalaxySelected(galaxy.id);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00ADB5),
                  disabledBackgroundColor: const Color(0xFF222831),
                  foregroundColor: const Color(0xFFFFFFFF),
                  disabledForegroundColor: Colors.grey.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isUnlocked ? Colors.transparent : const Color(0xFF393E46),
                    ),
                  ),
                ),
                child: Text(
                  isUnlocked ? "TRAVEL TO SECTOR" : "SECTOR GATED",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildLockBullets(GalaxyModel galaxy, GameProgression progression) {
    final List<Widget> bullets = [];

    // 1. Prerequisite galaxies check
    for (var prereqId in galaxy.prerequisiteGalaxyIds) {
      final met = progression.completedGalaxyIds.contains(prereqId);
      final prereqName = preloadedGalaxies.firstWhere((g) => g.id == prereqId, orElse: () => galaxy).name;
      bullets.add(
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Icon(
                met ? Icons.check_circle_outline : Icons.lock_outline,
                size: 11,
                color: met ? Colors.greenAccent : Colors.redAccent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Requires clearance of $prereqName Base",
                  style: TextStyle(
                    color: met ? Colors.grey : Colors.amberAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Laser Intensity check
    if (galaxy.minLaserIntensityLevel > 1) {
      final met = progression.laserIntensityLevel >= galaxy.minLaserIntensityLevel;
      bullets.add(
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Icon(
                met ? Icons.check_circle_outline : Icons.lock_outline,
                size: 11,
                color: met ? Colors.greenAccent : Colors.redAccent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Requires Laser Intensity Level ${galaxy.minLaserIntensityLevel} (Current: ${progression.laserIntensityLevel})",
                  style: TextStyle(
                    color: met ? Colors.grey : Colors.amberAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Aiming Computer check
    if (galaxy.minAimingComputerLevel > 1) {
      final met = progression.aimingComputerLevel >= galaxy.minAimingComputerLevel;
      bullets.add(
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Icon(
                met ? Icons.check_circle_outline : Icons.lock_outline,
                size: 11,
                color: met ? Colors.greenAccent : Colors.redAccent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Requires Aiming Computer Level ${galaxy.minAimingComputerLevel} (Current: ${progression.aimingComputerLevel})",
                  style: TextStyle(
                    color: met ? Colors.grey : Colors.amberAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 4. Blueprints check
    for (var blueprintType in galaxy.requiredUnlockedBlueprints) {
      final met = progression.unlockedDevices.contains(blueprintType);
      final blueprintName = blueprintType.name.toUpperCase();
      bullets.add(
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Icon(
                met ? Icons.check_circle_outline : Icons.lock_outline,
                size: 11,
                color: met ? Colors.greenAccent : Colors.redAccent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Requires Researched Blueprint: $blueprintName",
                  style: TextStyle(
                    color: met ? Colors.grey : Colors.amberAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If empty for some reason, fallback
    if (bullets.isEmpty && galaxy.requirementDescription.isNotEmpty) {
      bullets.add(
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              const Icon(
                Icons.lock_outline,
                size: 11,
                color: Colors.redAccent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  galaxy.requirementDescription,
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return bullets;
  }
}

// ------------------------------------------------------------------
// Track Path Painters
// ------------------------------------------------------------------

class _SnakePathPainter extends CustomPainter {
  final List<Offset> centers;
  final Set<String> completedGalaxyIds;
  final List<GalaxyModel> galaxies;

  _SnakePathPainter({
    required this.centers,
    required this.completedGalaxyIds,
    required this.galaxies,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (centers.length < 2) return;

    final linePaint = Paint()
      ..color = const Color(0xFF1E2633)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final activePaint = Paint()
      ..color = const Color(0xFF00ADB5)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    // Draw curvy snake connections between node centers
    for (int i = 0; i < centers.length - 1; i++) {
      final p1 = centers[i];
      final p2 = centers[i + 1];

      // Path is active if the current galaxy is cleared
      final isPathActive = completedGalaxyIds.contains(galaxies[i].id);

      final path = Path();
      path.moveTo(p1.dx, p1.dy);

      // Interpolate with a curved bezier logic to form a beautiful snake curve
      final double controlX = p1.dx;
      final double controlY = p2.dy;
      path.quadraticBezierTo(controlX, controlY, p2.dx, p2.dy);

      _drawDashedPath(canvas, path, isPathActive ? activePaint : linePaint);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 8.0;
    const dashSpace = 6.0;

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
  bool shouldRepaint(covariant _SnakePathPainter oldDelegate) {
    return oldDelegate.centers.length != centers.length ||
        oldDelegate.completedGalaxyIds.length != completedGalaxyIds.length;
  }
}

class _CosmicGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF132238).withOpacity(0.12)
      ..strokeWidth = 0.8;

    const spacing = 44.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double j = 0; j < size.height; j += spacing) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ------------------------------------------------------------------
// Procedural Vector Galaxy Painters
// ------------------------------------------------------------------

// Galaxy 1: Core Outpost (Cyan base, circular orbits)
class _CoreOutpostPainter extends CustomPainter {
  final bool isUnlocked;
  _CoreOutpostPainter({required this.isUnlocked});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2.0, size.height / 2.0);
    final coreColor = isUnlocked ? const Color(0xFF00ADB5) : const Color(0xFF556070);
    final double scale = size.width / 110.0;

    // Orbit Ring 1
    final orbitPaint = Paint()
      ..color = coreColor.withOpacity(0.15)
      ..strokeWidth = 1.0 * scale
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, 24.0 * scale, orbitPaint);

    // Orbit Ring 2
    canvas.drawCircle(center, 38.0 * scale, orbitPaint);

    // Inner Glowing Core
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          coreColor.withOpacity(1.0),
          coreColor.withOpacity(0.5),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 18.0 * scale));
    canvas.drawCircle(center, 18.0 * scale, corePaint);

    // Mini Orbiting Moons
    final moonPaint = Paint()
      ..color = coreColor.withOpacity(isUnlocked ? 0.85 : 0.4)
      ..style = PaintingStyle.fill;
    
    // Moon 1 on Ring 1 (static coordinates)
    const angle1 = 45 * pi / 180.0;
    canvas.drawCircle(Offset(center.dx + 24.0 * scale * cos(angle1), center.dy + 24.0 * scale * sin(angle1)), 3.0 * scale, moonPaint);

    // Moon 2 on Ring 2
    const angle2 = 210 * pi / 180.0;
    canvas.drawCircle(Offset(center.dx + 38.0 * scale * cos(angle2), center.dy + 38.0 * scale * sin(angle2)), 4.0 * scale, moonPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Galaxy 2: Nebular Depths (Pink-purple spiral, double arms)
class _NebularDepthsPainter extends CustomPainter {
  final bool isUnlocked;
  _NebularDepthsPainter({required this.isUnlocked});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2.0, size.height / 2.0);
    final baseColor = isUnlocked ? const Color(0xFFFF2E93) : const Color(0xFF556070);
    final secondaryColor = isUnlocked ? const Color(0xFF00FFF5) : const Color(0xFF3A4454);
    final double scale = size.width / 110.0;

    // Draw central disk glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          baseColor.withOpacity(0.5),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 24.0 * scale));
    canvas.drawCircle(center, 24.0 * scale, glowPaint);

    // Draw Logarithmic Spiral arms
    final dotPaint = Paint()
      ..style = PaintingStyle.fill;

    for (int arm = 0; arm < 2; arm++) {
      final double startAngleOffset = arm * pi;
      
      // Plot dots along logarithmic spiral: r = a * e^(b * theta)
      for (double theta = 0; theta < 4.5; theta += 0.15) {
        final double r = (6.0 + 7.5 * theta) * scale;
        if (r > size.width / 2.1) break;

        final double x = center.dx + r * cos(theta + startAngleOffset);
        final double y = center.dy + r * sin(theta + startAngleOffset);

        // Mix arm colors
        final color = Color.lerp(baseColor, secondaryColor, theta / 4.5)!;
        dotPaint.color = color.withOpacity((1.0 - (theta / 5.5)).clamp(0.1, 0.95));

        canvas.drawCircle(Offset(x, y), max(1.2 * scale, (3.5 - (theta * 0.4)) * scale), dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Galaxy 3: Outer Horizon (Warped high-gravity orange black hole accretion disk)
class _OuterHorizonPainter extends CustomPainter {
  final bool isUnlocked;
  _OuterHorizonPainter({required this.isUnlocked});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2.0, size.height / 2.0);
    final themeColor = isUnlocked ? const Color(0xFFFFB703) : const Color(0xFF556070);
    final double scale = size.width / 110.0;

    // Accretion Ring glow (large, faint oval/disk)
    final ringPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          themeColor.withOpacity(0.65),
          themeColor.withOpacity(0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 46.0 * scale));
    canvas.drawCircle(center, 46.0 * scale, ringPaint);

    // Warped Gravitational Accretion Disk (horizontal-leaning vector ring)
    final warpedPaint = Paint()
      ..color = themeColor.withOpacity(isUnlocked ? 0.75 : 0.3)
      ..strokeWidth = 3.5 * scale
      ..style = PaintingStyle.stroke;
    
    // Draw an elliptical warped vector ring
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 78.0 * scale, height: 26.0 * scale),
      warpedPaint,
    );

    // Center Event Horizon (The absolute black hole void)
    final blackHolePaint = Paint()
      ..color = const Color(0xFF0B0E14)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 12.0 * scale, blackHolePaint);

    // Glowing border around black hole
    final borderPaint = Paint()
      ..color = themeColor.withOpacity(isUnlocked ? 0.95 : 0.4)
      ..strokeWidth = 1.5 * scale
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, 12.0 * scale, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
