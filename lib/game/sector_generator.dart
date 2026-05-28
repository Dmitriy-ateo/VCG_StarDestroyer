import 'dart:math';
import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../models/level_data.dart';
import '../models/game_progression.dart';

class SectorGenerator {
  static final Random _random = Random();

  static const List<String> _planetNames = [
    "Aurelia", "Borealis", "Calypso", "Drakon", "Elysium", "Fenix", "Gorgon", "Hyperion",
    "Icarus", "Juno", "Krypton", "Lyra", "Monolith", "Nebula", "Orion", "Pandora",
    "Quasar", "Ragnarok", "Solaris", "Titan", "Uranus", "Vortex", "Wyrm", "Xenon"
  ];

  static const List<String> _planetColors = [
    "0xFF00FFF5", // Cyber Cyan
    "0xFFFF2E93", // Cyber Pink
    "0xFFFFB703", // Tech Amber
    "0xFF64FFDA", // Mint Teal
    "0xFFE040FB", // Synth Purple
    "0xFFFF5252", // Neon Red
    "0xFFFFAB40", // Plasma Orange
    "0xFF69F0AE"  // Laser Green
  ];

  static LevelData generateDailySector(GameProgression progression, String galaxyId) {
    // Collect all unlocked device types
    final unlockedTypes = progression.unlockedDevices;

    // Filter which templates we can use
    final List<String> possibleTemplates = ['reflector']; // Reflector always available
    if (unlockedTypes.contains(DeviceType.splitter)) possibleTemplates.add('splitter');
    if (unlockedTypes.contains(DeviceType.bomb)) possibleTemplates.add('bomb');
    if (unlockedTypes.contains(DeviceType.portal)) possibleTemplates.add('portal');
    if (unlockedTypes.contains(DeviceType.gravityWell)) possibleTemplates.add('gravity');

    // Pick a random template
    final chosenTemplate = possibleTemplates[_random.nextInt(possibleTemplates.length)];

    final LevelData level;
    switch (chosenTemplate) {
      case 'splitter':
        level = _generateSplitterTemplate(progression, galaxyId);
        break;
      case 'bomb':
        level = _generateBombTemplate(progression, galaxyId);
        break;
      case 'portal':
        level = _generatePortalTemplate(progression, galaxyId);
        break;
      case 'gravity':
        level = _generateGravityTemplate(progression, galaxyId);
        break;
      case 'reflector':
      default:
        level = _generateReflectorTemplate(progression, galaxyId);
        break;
    }

    _enforceNoDirectHitForAdvancedGalaxies(level, galaxyId);
    return level;
  }

  static String _getRandomPlanetName() {
    final name = _planetNames[_random.nextInt(_planetNames.length)];
    final numVal = 100 + _random.nextInt(900);
    return "$name $numVal";
  }

  static String _getRandomPlanetColor() {
    return _planetColors[_random.nextInt(_planetColors.length)];
  }

  // Template 1: Reflector redirection (2 mirrors required)
  static LevelData _generateReflectorTemplate(GameProgression progression, String galaxyId) {
    // Death Star fixed at bottom center
    const dsX = 3;
    const dsY = 11;

    // Choose random columns and rows for mirrors to make it procedural
    // Mirror 1 at (3, y1)
    final y1 = 6 + _random.nextInt(3); // Row 6, 7, or 8
    
    // Direction of turn: left or right
    final goRight = _random.nextBool();
    final x2 = goRight ? (5 + _random.nextInt(2)) : (1 + _random.nextInt(2)); // Col 5-6 or Col 1-2
    
    // Planet at (x2, y2)
    final y2 = 1 + _random.nextInt(3); // Row 1, 2, or 3

    final List<PlanetTarget> planets = [
      PlanetTarget(
        id: "daily_p1",
        gridX: x2,
        gridY: y2,
        radius: 20.0,
        name: _getRandomPlanetName(),
        color: Color(int.parse(_getRandomPlanetColor())),
      )
    ];

    // Emitters and mirrors block standard straight lines
    final List<WallBlock> walls = [
      WallBlock(gridX: 3, gridY: y1 - 2), // Block direct laser from going straight up
      WallBlock(gridX: x2, gridY: y1),    // Block other corners
    ];

    // Add extra random clutter walls that don't block our solution path
    // Solution path cells are:
    // (3, 11) up to (3, y1)
    // (3, y1) horizontally to (x2, y1)
    // (x2, y1) up to (x2, y2)
    final Set<String> solutionCells = {};
    for (int y = y1; y <= dsY; y++) {
      solutionCells.add("3,$y");
    }
    final startX = min(3, x2);
    final endX = max(3, x2);
    for (int x = startX; x <= endX; x++) {
      solutionCells.add("$x,$y1");
    }
    for (int y = y2; y <= y1; y++) {
      solutionCells.add("$x2,$y");
    }

    // Add random clutter (breakable elements spawn dynamically from 2nd galaxy)
    _addClutterWalls(walls, solutionCells, galaxyId, dsX, dsY);

    // Available inventory: 2 reflectors
    final List<DeviceModel> availableInventory = [
      DeviceModel(id: "daily_ref1", type: DeviceType.reflector),
      DeviceModel(id: "daily_ref2", type: DeviceType.reflector),
    ];

    return LevelData(
      id: 999,
      name: "Calibrated Bends",
      description: "Atmospheric dust blocks direct fire. Place reflectors at ($dsX, $y1) and ($x2, $y1) to reflect the laser around the barriers.",
      deathStarX: dsX,
      deathStarY: dsY,
      deathStarInitialAngle: -90.0, // Aim straight up
      planets: planets,
      walls: walls,
      availableInventory: availableInventory,
      presetDevices: [],
      creditsReward: 300,
      researchPointsReward: 50,
    );
  }

  // Template 2: Splitter opposite orbits (1 splitter + 2 reflectors required)
  static LevelData _generateSplitterTemplate(GameProgression progression, String galaxyId) {
    const dsX = 3;
    const dsY = 11;

    // Splitter placed at (3, 7)
    const splitterY = 7;
    
    // Left beam goes left, right beam goes right
    // Reflectors at (1, 7) and (6, 7)
    // Planets at (1, 2) and (6, 2)
    final List<PlanetTarget> planets = [
      PlanetTarget(
        id: "daily_sp_p1",
        gridX: 1,
        gridY: 2,
        radius: 20.0,
        name: _getRandomPlanetName(),
        color: Color(int.parse(_getRandomPlanetColor())),
      ),
      PlanetTarget(
        id: "daily_sp_p2",
        gridX: 6,
        gridY: 2,
        radius: 20.0,
        name: _getRandomPlanetName(),
        color: Color(int.parse(_getRandomPlanetColor())),
      ),
    ];

    // Walls block direct lines
    final List<WallBlock> walls = [
      WallBlock(gridX: 3, gridY: 4), // Block straight laser up
      WallBlock(gridX: 1, gridY: 5), // Block straight lines from emitter to planets
      WallBlock(gridX: 6, gridY: 5),
    ];

    // Define solution cells:
    final Set<String> solutionCells = {};
    for (int y = 7; y <= 11; y++) {
      solutionCells.add("3,$y");
    }
    for (int x = 1; x <= 6; x++) {
      solutionCells.add("$x,7");
    }
    for (int y = 2; y <= 7; y++) {
      solutionCells.add("1,$y");
      solutionCells.add("6,$y");
    }

    // Add random clutter (breakable elements spawn dynamically from 2nd galaxy)
    _addClutterWalls(walls, solutionCells, galaxyId, dsX, dsY);

    // Available Inventory: 1 splitter (180 deg) and 2 reflectors
    final List<DeviceModel> availableInventory = [
      DeviceModel(id: "daily_split1", type: DeviceType.splitter, splitAngleDegrees: 180.0),
      DeviceModel(id: "daily_ref1", type: DeviceType.reflector),
      DeviceModel(id: "daily_ref2", type: DeviceType.reflector),
    ];

    return LevelData(
      id: 999,
      name: "Dual Target Ray",
      description: "Synchronized orbits detected. Mount a 180° SPLITTER on slot (3, $splitterY) and redirect the twin beams up with reflectors at (1, $splitterY) and (6, $splitterY).",
      deathStarX: dsX,
      deathStarY: dsY,
      deathStarInitialAngle: -90.0,
      planets: planets,
      walls: walls,
      availableInventory: availableInventory,
      presetDevices: [],
      creditsReward: 300,
      researchPointsReward: 50,
    );
  }

  // Template 3: Bomb chain reaction (1 bomb + 1 reflector required)
  static LevelData _generateBombTemplate(GameProgression progression, String galaxyId) {
    const dsX = 2;
    const dsY = 11;

    // Reflector at (2, 4) reflect right into bomb at (5, 4)
    // Planets clustered around the bomb: (4, 3), (5, 3), (6, 3) - protected behind shielded wall
    final List<PlanetTarget> planets = [
      PlanetTarget(
        id: "daily_b_p1",
        gridX: 4,
        gridY: 2,
        radius: 20.0,
        name: _getRandomPlanetName(),
        color: Color(int.parse(_getRandomPlanetColor())),
      ),
      PlanetTarget(
        id: "daily_b_p2",
        gridX: 5,
        gridY: 2,
        radius: 20.0,
        name: _getRandomPlanetName(),
        color: Color(int.parse(_getRandomPlanetColor())),
      ),
      PlanetTarget(
        id: "daily_b_p3",
        gridX: 6,
        gridY: 2,
        radius: 20.0,
        name: _getRandomPlanetName(),
        color: Color(int.parse(_getRandomPlanetColor())),
      ),
    ];

    // Solid walls block the planets completely, but a gap exists at (5, 4) for the bomb
    final List<WallBlock> walls = [
      WallBlock(gridX: 4, gridY: 3),
      WallBlock(gridX: 5, gridY: 3),
      WallBlock(gridX: 6, gridY: 3),
      WallBlock(gridX: 2, gridY: 2), // Block direct vertical shot to other sides
    ];

    // Define solution cells:
    final Set<String> solutionCells = {};
    for (int y = 4; y <= 11; y++) {
      solutionCells.add("2,$y");
    }
    for (int x = 2; x <= 5; x++) {
      solutionCells.add("$x,4");
    }
    solutionCells.add("4,2");
    solutionCells.add("5,2");
    solutionCells.add("6,2");

    // Add random clutter (breakable elements spawn dynamically from 2nd galaxy)
    _addClutterWalls(walls, solutionCells, galaxyId, dsX, dsY);

    // Available Inventory: 1 reflector, 1 bomb
    final List<DeviceModel> availableInventory = [
      DeviceModel(id: "daily_ref1", type: DeviceType.reflector),
      DeviceModel(id: "daily_bomb1", type: DeviceType.bomb),
    ];

    return LevelData(
      id: 999,
      name: "Chain Blast",
      description: "Target planets are completely shielded by an armored core. Place a volatile BOMB at (5, 4) and reflect the laser into it to detonate the entire system.",
      deathStarX: dsX,
      deathStarY: dsY,
      deathStarInitialAngle: -90.0,
      planets: planets,
      walls: walls,
      availableInventory: availableInventory,
      presetDevices: [],
      creditsReward: 300,
      researchPointsReward: 50,
    );
  }

  // Template 4: Spatial Portal transit (preset portals, requires 1 reflector)
  static LevelData _generatePortalTemplate(GameProgression progression, String galaxyId) {
    const dsX = 3;
    const dsY = 11;

    // Laser goes up into Portal A at (3, 7). Teleports out of Portal B at (6, 5) heading up.
    // A reflector is needed at (6, 2) to reflect left to planet at (2, 2)
    final List<PlanetTarget> planets = [
      PlanetTarget(
        id: "daily_pt_p1",
        gridX: 1,
        gridY: 2,
        radius: 20.0,
        name: _getRandomPlanetName(),
        color: Color(int.parse(_getRandomPlanetColor())),
      )
    ];

    // Armored walls segmenting the board
    final List<WallBlock> walls = [
      WallBlock(gridX: 3, gridY: 3),
      WallBlock(gridX: 4, gridY: 3),
      WallBlock(gridX: 5, gridY: 3),
      WallBlock(gridX: 2, gridY: 2),
    ];

    // Presets: Portal pair A and B
    final List<DeviceModel> presetDevices = [
      DeviceModel(id: "d_port1", type: DeviceType.portal, gridX: 3, gridY: 7, portalPairId: "d_port2", isPlaced: true),
      DeviceModel(id: "d_port2", type: DeviceType.portal, gridX: 6, gridY: 5, portalPairId: "d_port1", isPlaced: true),
    ];

    // Define solution cells:
    final Set<String> solutionCells = {};
    for (int y = 7; y <= 11; y++) {
      solutionCells.add("3,$y");
    }
    for (int y = 2; y <= 5; y++) {
      solutionCells.add("6,$y");
    }
    for (int x = 1; x <= 6; x++) {
      solutionCells.add("$x,2");
    }

    // Add random clutter (breakable elements spawn dynamically from 2nd galaxy)
    _addClutterWalls(walls, solutionCells, galaxyId, dsX, dsY);

    // Available Inventory: 1 reflector
    final List<DeviceModel> availableInventory = [
      DeviceModel(id: "daily_ref1", type: DeviceType.reflector),
    ];

    return LevelData(
      id: 999,
      name: "Folded Dimensions",
      description: "Pre-installed Spatial Relays activated. Let the laser enter Portal A at (3, 7) to teleport to (6, 5). Use a reflector at (6, 2) to hit the target.",
      deathStarX: dsX,
      deathStarY: dsY,
      deathStarInitialAngle: -90.0,
      planets: planets,
      walls: walls,
      availableInventory: availableInventory,
      presetDevices: presetDevices,
      creditsReward: 300,
      researchPointsReward: 50,
    );
  }

  // Template 5: Gravity Well curvature (requires 1 gravity well)
  static LevelData _generateGravityTemplate(GameProgression progression, String galaxyId) {
    const dsX = 2;
    const dsY = 11;

    // Laser aims straight up from (2, 11).
    // Planet is at (5, 2) but is protected by a solid wall blockade at Y=5.
    // Placing a gravity well at (4, 6) will attract the laser beam, curving it around the wall!
    final List<PlanetTarget> planets = [
      PlanetTarget(
        id: "daily_g_p1",
        gridX: 5,
        gridY: 2,
        radius: 20.0,
        name: _getRandomPlanetName(),
        color: Color(int.parse(_getRandomPlanetColor())),
      )
    ];

    // Heavy blocking walls
    final List<WallBlock> walls = [
      WallBlock(gridX: 2, gridY: 5),
      WallBlock(gridX: 3, gridY: 5),
      WallBlock(gridX: 4, gridY: 5),
    ];

    // Define solution cells:
    final Set<String> solutionCells = {};
    for (int y = 5; y <= 11; y++) {
      solutionCells.add("2,$y");
    }
    for (int y = 2; y <= 7; y++) {
      solutionCells.add("5,$y");
    }
    solutionCells.add("4,6");

    // Add random clutter (breakable elements spawn dynamically from 2nd galaxy)
    _addClutterWalls(walls, solutionCells, galaxyId, dsX, dsY);

    // Available Inventory: 1 gravity well
    final List<DeviceModel> availableInventory = [
      DeviceModel(id: "daily_well1", type: DeviceType.gravityWell),
    ];

    return LevelData(
      id: 999,
      name: "Gravitational Curve",
      description: "Armored shields divide the sector. Place a GRAVITY WELL around (4, 6) to curve the laser beam through the gravitational slingshot onto the planet.",
      deathStarX: dsX,
      deathStarY: dsY,
      deathStarInitialAngle: -90.0,
      planets: planets,
      walls: walls,
      availableInventory: availableInventory,
      presetDevices: [],
      creditsReward: 300,
      researchPointsReward: 50,
    );
  }

  static void _addClutterWalls(List<WallBlock> walls, Set<String> solutionCells, String galaxyId, int dsX, int dsY) {
    if (galaxyId == 'galaxy_1') {
      // Just standard asteroid clutter in the first galaxy
      int placedClutter = 0;
      int attempts = 0;
      while (placedClutter < 3 && attempts < 100) {
        attempts++;
        final wx = _random.nextInt(8);
        final wy = 1 + _random.nextInt(9);
        final cellKey = "$wx,$wy";
        
        final isOccupied = solutionCells.contains(cellKey) || 
                           (wx == dsX && wy == dsY) ||
                           walls.any((w) => w.gridX == wx && w.gridY == wy);

        if (!isOccupied) {
          walls.add(WallBlock(gridX: wx, gridY: wy, isDestructible: false, type: 'asteroid'));
          placedClutter++;
        }
      }
      return;
    }

    // 2nd galaxy and beyond: add random breakable energyShields and spaceLitter!
    int placedClutter = 0;
    int attempts = 0;
    while (placedClutter < 3 && attempts < 100) {
      attempts++;
      final wx = _random.nextInt(8);
      final wy = 1 + _random.nextInt(9);
      final cellKey = "$wx,$wy";
      
      final isOccupied = solutionCells.contains(cellKey) || 
                         (wx == dsX && wy == dsY) ||
                         walls.any((w) => w.gridX == wx && w.gridY == wy);

      if (!isOccupied) {
        final rand = _random.nextDouble();
        String wallType = 'asteroid';
        int? reqPower;
        
        if (rand < 0.35) {
          wallType = 'energyShield';
          reqPower = 2;
        } else if (rand < 0.70) {
          wallType = 'spaceLitter';
          reqPower = 1;
        }

        walls.add(WallBlock(
          gridX: wx,
          gridY: wy,
          isDestructible: wallType != 'asteroid',
          type: wallType,
          requiredLaserPower: reqPower,
        ));
        placedClutter++;
      }
    }
  }

  // Generate a highly challenging Daily Hard Mission requiring all items in that galaxy
  static LevelData generateDailyHardSector(GameProgression progression, String galaxyId) {
    final List<PlanetTarget> planets = [];
    final List<WallBlock> walls = [];
    final List<DeviceModel> inventory = [];

    final LevelData level;
    if (galaxyId == 'galaxy_1') {
      // Galaxy 1: Apprentice puzzle requiring 3 Reflectors (detour around core asteroid wall)
      planets.add(PlanetTarget(
        id: "hard_t1",
        gridX: 4,
        gridY: 2,
        name: "SECURITY PATROLLER",
        color: const Color(0xFFFF5252),
        isInvader: true,
        requiredLaserPower: 2,
      ));

      // Blocker obsidian asteroid barrier
      walls.add(WallBlock(gridX: 3, gridY: 5, isDestructible: false, type: 'asteroid'));
      walls.add(WallBlock(gridX: 4, gridY: 5, isDestructible: false, type: 'asteroid'));
      walls.add(WallBlock(gridX: 2, gridY: 5, isDestructible: false, type: 'asteroid'));

      inventory.addAll([
        DeviceModel(id: "hard_ref1", type: DeviceType.reflector),
        DeviceModel(id: "hard_ref2", type: DeviceType.reflector),
        DeviceModel(id: "hard_ref3", type: DeviceType.reflector),
      ]);

      level = LevelData(
        id: 991,
        name: "DAILY HARD: APPRENTICE BLOCKADE",
        description: "Rebel blockade ships have intercepted our inner relays. Route a 3-reflector detour around the central asteroid screen to vaporize the patroller ship!",
        deathStarX: 3,
        deathStarY: 11,
        deathStarInitialAngle: -90.0,
        planets: planets,
        walls: walls,
        availableInventory: inventory,
        creditsReward: 500,
        researchPointsReward: 150,
      );
    } else if (galaxyId == 'galaxy_2') {
      // Galaxy 2: Medium puzzle requiring Reflectors, Splitters, and Bombs!
      planets.add(PlanetTarget(
        id: "hard_t1",
        gridX: 1,
        gridY: 2,
        name: "ESCORT CRUISER",
        color: const Color(0xFFFF7E00),
        isInvader: true,
        requiredLaserPower: 3,
      ));
      planets.add(PlanetTarget(
        id: "hard_t2",
        gridX: 5,
        gridY: 2,
        name: "SECURITY COMMANDER",
        color: const Color(0xFFFF5252),
        isInvader: true,
        requiredLaserPower: 3, // Shielded!
      ));

      // Blocker asteroid screen
      walls.add(WallBlock(gridX: 3, gridY: 4, isDestructible: false, type: 'asteroid'));
      walls.add(WallBlock(gridX: 3, gridY: 5, isDestructible: false, type: 'asteroid'));
      walls.add(WallBlock(gridX: 2, gridY: 2, isDestructible: false, type: 'asteroid'));

      inventory.addAll([
        DeviceModel(id: "hard_ref1", type: DeviceType.reflector),
        DeviceModel(id: "hard_ref2", type: DeviceType.reflector),
        DeviceModel(id: "hard_split1", type: DeviceType.splitter, splitAngleDegrees: 180.0),
        DeviceModel(id: "hard_bomb1", type: DeviceType.bomb),
      ]);

      level = LevelData(
        id: 992,
        name: "DAILY HARD: INTRUDER SQUADRON",
        description: "Rebel cruiser patrols have warped into the nebular sector! Align a 180° splitter and detonate a deployable volatile bomb to defeat the shielded squadron commander and escort cruiser!",
        deathStarX: 3,
        deathStarY: 11,
        deathStarInitialAngle: -90.0,
        planets: planets,
        walls: walls,
        availableInventory: inventory,
        creditsReward: 500,
        researchPointsReward: 150,
      );
    } else {
      // Galaxy 3: Grand Admiral puzzle requiring Portals, Gravity Wells, Splitters, Bombs, Reflectors!
      planets.add(PlanetTarget(
        id: "hard_t1",
        gridX: 2,
        gridY: 1,
        name: "DEFENSIVE FIGHTER",
        color: const Color(0xFFFF7E00),
        isInvader: true,
        requiredLaserPower: 4,
      ));
      planets.add(PlanetTarget(
        id: "hard_t2",
        gridX: 6,
        gridY: 1,
        name: "DREADNOUGHT CORES",
        color: const Color(0xFFFF5252),
        isInvader: true,
        requiredLaserPower: 4,
      ));

      // Asteroid labyrinth layouts
      walls.add(WallBlock(gridX: 3, gridY: 3, isDestructible: false, type: 'asteroid'));
      walls.add(WallBlock(gridX: 4, gridY: 3, isDestructible: false, type: 'asteroid'));
      walls.add(WallBlock(gridX: 3, gridY: 7, isDestructible: false, type: 'asteroid'));

      inventory.addAll([
        DeviceModel(id: "hard_ref1", type: DeviceType.reflector),
        DeviceModel(id: "hard_ref2", type: DeviceType.reflector),
        DeviceModel(id: "hard_split1", type: DeviceType.splitter, splitAngleDegrees: 180.0),
        DeviceModel(id: "hard_well1", type: DeviceType.gravityWell),
        DeviceModel(id: "hard_portal1", type: DeviceType.portal),
        DeviceModel(id: "hard_bomb1", type: DeviceType.bomb),
      ]);

      level = LevelData(
        id: 993,
        name: "DAILY HARD: DREADNOUGHT BREACH",
        description: "An elite dreadnought squadron blocks the outer portal gate! Deploy portal warp points and singular gravity wells to slingshot the superlaser around obsidian clusters to target the security core!",
        deathStarX: 3,
        deathStarY: 11,
        deathStarInitialAngle: -90.0,
        planets: planets,
        walls: walls,
        availableInventory: inventory,
        creditsReward: 500,
        researchPointsReward: 150,
      );
    }

    _enforceNoDirectHitForAdvancedGalaxies(level, galaxyId);
    return level;
  }

  // Ensures no planet can be hit directly by just aiming from the Death Star in Galaxy 2 and beyond
  static void _enforceNoDirectHitForAdvancedGalaxies(LevelData level, String galaxyId) {
    if (galaxyId == 'galaxy_1') return;

    for (var planet in level.planets) {
      final startX = level.deathStarX + 0.5;
      final startY = level.deathStarY + 0.5;
      final targetX = planet.gridX + 0.5;
      final targetY = planet.gridY + 0.5;

      final dx = targetX - startX;
      final dy = targetY - startY;
      final distance = sqrt(dx * dx + dy * dy);
      
      if (distance == 0) continue;

      final stepX = dx / distance;
      final stepY = dy / distance;

      final Set<String> wallCoords = level.walls.map((w) => "${w.gridX},${w.gridY}").toSet();

      bool isDirectPathUnblocked = true;
      final List<Point<int>> pathCells = [];

      // Trace the straight line with steps of 0.1 cells
      final steps = (distance * 10).toInt();
      for (int i = 1; i < steps; i++) {
        final currentX = startX + stepX * (i * 0.1);
        final currentY = startY + stepY * (i * 0.1);

        final cellX = currentX.floor();
        final cellY = currentY.floor();

        if (cellX == planet.gridX && cellY == planet.gridY) {
          break;
        }
        if (cellX < 0 || cellX >= 8 || cellY < 0 || cellY >= 12) {
          break;
        }

        final cellKey = "$cellX,$cellY";
        if (wallCoords.contains(cellKey)) {
          isDirectPathUnblocked = false;
          break;
        }

        if (cellX != level.deathStarX || cellY != level.deathStarY) {
          final pt = Point<int>(cellX, cellY);
          if (!pathCells.contains(pt)) {
            pathCells.add(pt);
          }
        }
      }

      // If the direct ray path to the planet is unblocked, we must block it
      if (isDirectPathUnblocked) {
        Point<int>? blockCell;
        
        // Choose a cell along the path that is a safe distance from both shooter and target
        for (final cell in pathCells) {
          final distFromDS = (cell.x - level.deathStarX).abs() + (cell.y - level.deathStarY).abs();
          final distFromPlanet = (cell.x - planet.gridX).abs() + (cell.y - planet.gridY).abs();
          
          if (distFromDS >= 2 && distFromPlanet >= 1) {
            blockCell = cell;
            break;
          }
        }

        // Fallback to the middle cell if no cells fit the distance margin
        blockCell ??= pathCells.isNotEmpty ? pathCells[pathCells.length ~/ 2] : null;

        if (blockCell != null) {
          level.walls.add(WallBlock(
            gridX: blockCell.x,
            gridY: blockCell.y,
            isDestructible: false,
            type: 'asteroid',
          ));
        }
      }
    }
  }
}
