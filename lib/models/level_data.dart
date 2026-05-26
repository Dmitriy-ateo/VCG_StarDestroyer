import 'package:flutter/material.dart';
import 'device_model.dart';

class PlanetTarget {
  final String id;
  final int gridX;
  final int gridY;
  final double radius;
  final String name;
  final Color color;
  bool isDestroyed;

  PlanetTarget({
    required this.id,
    required this.gridX,
    required this.gridY,
    this.radius = 20.0,
    required this.name,
    required this.color,
    this.isDestroyed = false,
  });

  PlanetTarget copyWith({
    String? id,
    int? gridX,
    int? gridY,
    double? radius,
    String? name,
    Color? color,
    bool? isDestroyed,
  }) {
    return PlanetTarget(
      id: id ?? this.id,
      gridX: gridX ?? this.gridX,
      gridY: gridY ?? this.gridY,
      radius: radius ?? this.radius,
      name: name ?? this.name,
      color: color ?? this.color,
      isDestroyed: isDestroyed ?? this.isDestroyed,
    );
  }
}

class WallBlock {
  final int gridX;
  final int gridY;
  final bool isDestructible; // Can be blown up by a bomb

  WallBlock({
    required this.gridX,
    required this.gridY,
    this.isDestructible = false,
  });
}

class LevelData {
  final int id;
  final String name;
  final String description;
  final int deathStarX;
  final int deathStarY;
  final double deathStarInitialAngle;
  final List<PlanetTarget> planets;
  final List<WallBlock> walls;
  final List<DeviceModel> availableInventory; // Devices the player can drag onto the field
  final List<DeviceModel> presetDevices; // Devices already locked on the board
  final int creditsReward;
  final int researchPointsReward;

  LevelData({
    required this.id,
    required this.name,
    required this.description,
    required this.deathStarX,
    required this.deathStarY,
    this.deathStarInitialAngle = -90.0, // Firing straight up by default in vertical mode
    required this.planets,
    required this.walls,
    required this.availableInventory,
    this.presetDevices = const [],
    this.creditsReward = 100,
    this.researchPointsReward = 20,
  });

  // Get a clone of this level with fresh mutable targets
  LevelData clone() {
    return LevelData(
      id: id,
      name: name,
      description: description,
      deathStarX: deathStarX,
      deathStarY: deathStarY,
      deathStarInitialAngle: deathStarInitialAngle,
      planets: planets.map((p) => p.copyWith()).toList(),
      walls: List.from(walls),
      availableInventory: availableInventory.map((d) => d.copyWith()).toList(),
      presetDevices: presetDevices.map((d) => d.copyWith()).toList(),
      creditsReward: creditsReward,
      researchPointsReward: researchPointsReward,
    );
  }
}

// Preloaded vertical level database (Grid dimensions: X: 0-7, Y: 0-11)
final List<LevelData> preloadedLevels = [
  // LEVEL 1: Core Calibration
  LevelData(
    id: 1,
    name: "Level 1: Core Calibration",
    description: "Aim directly at the rebel base planet Alderaan at the top and press FIRE to test the superlaser. Drag gesture on screen or use bottom dial adjustment to aim.",
    deathStarX: 3,
    deathStarY: 11,
    deathStarInitialAngle: -90.0, // Pointing straight up
    planets: [
      PlanetTarget(id: "p1", gridX: 3, gridY: 2, name: "Alderaan", color: Colors.blueAccent),
    ],
    walls: [],
    availableInventory: [],
    creditsReward: 100,
    researchPointsReward: 20,
  ),

  // LEVEL 2: Orbital Reflection
  LevelData(
    id: 2,
    name: "Level 2: Orbital Reflection",
    description: "Impending asteroids block direct sight. Drag a REFLECTOR onto grid slot (3, 2) and tap once to rotate it 135° to reflect the laser right to Chandrila.",
    deathStarX: 3,
    deathStarY: 11,
    deathStarInitialAngle: -90.0,
    planets: [
      PlanetTarget(id: "p1", gridX: 6, gridY: 2, name: "Chandrila", color: Colors.tealAccent),
    ],
    walls: [
      WallBlock(gridX: 3, gridY: 6),
      WallBlock(gridX: 4, gridY: 6),
      WallBlock(gridX: 5, gridY: 6),
    ],
    availableInventory: [
      DeviceModel(id: "t_ref1", type: DeviceType.reflector),
    ],
    creditsReward: 150,
    researchPointsReward: 30,
  ),

  // LEVEL 3: Split Sector
  LevelData(
    id: 3,
    name: "Level 3: Split Sector",
    description: "Two rebel planets sit in opposite orbits. Place the SPLITTER 180° blueprint on slot (3, 3) at rotation 0° to split the laser left and right.",
    deathStarX: 3,
    deathStarY: 11,
    deathStarInitialAngle: -90.0,
    planets: [
      PlanetTarget(id: "p1", gridX: 1, gridY: 3, name: "Corellia Prime", color: Colors.orangeAccent),
      PlanetTarget(id: "p2", gridX: 6, gridY: 3, name: "Corellia Secundus", color: Colors.redAccent),
    ],
    walls: [
      WallBlock(gridX: 3, gridY: 2), // Block direct vertical path
    ],
    availableInventory: [
      DeviceModel(id: "t_split1", type: DeviceType.splitter, splitAngleDegrees: 180.0),
    ],
    creditsReward: 200,
    researchPointsReward: 40,
  ),

  // LEVEL 4: Chain Reaction
  LevelData(
    id: 4,
    name: "Level 4: Chain Reaction",
    description: "Planets are shielded, but a volatile bomb core rests at (5, 3). Place a reflector at (2, 3) at rotation 135° to reflect the laser into the bomb for an explosion!",
    deathStarX: 2,
    deathStarY: 11,
    deathStarInitialAngle: -90.0,
    planets: [
      PlanetTarget(id: "p1", gridX: 4, gridY: 2, name: "Mon Calamari Alpha", color: Colors.lightBlue),
      PlanetTarget(id: "p2", gridX: 6, gridY: 2, name: "Mon Calamari Beta", color: Colors.purpleAccent),
      PlanetTarget(id: "p3", gridX: 5, gridY: 1, name: "Mon Calamari Gamma", color: Colors.indigoAccent),
    ],
    walls: [
      WallBlock(gridX: 2, gridY: 1),
      WallBlock(gridX: 5, gridY: 4), // Guard the bomb from below
    ],
    availableInventory: [
      DeviceModel(id: "t_ref1", type: DeviceType.reflector),
      DeviceModel(id: "t_bomb1", type: DeviceType.bomb),
    ],
    creditsReward: 250,
    researchPointsReward: 50,
  ),

  // LEVEL 5: Gravitational Slingshot
  LevelData(
    id: 5,
    name: "Level 5: Gravitational Slingshot",
    description: "Mon Gazza is blocked by asteroids. Drag a GRAVITY WELL near slot (4, 7) to generate a pull that curves the upward laser around the asteroid wall.",
    deathStarX: 2,
    deathStarY: 11,
    deathStarInitialAngle: -90.0,
    planets: [
      PlanetTarget(id: "p1", gridX: 5, gridY: 2, name: "Mon Gazza", color: Colors.greenAccent),
    ],
    walls: [
      WallBlock(gridX: 2, gridY: 5),
      WallBlock(gridX: 3, gridY: 5),
      WallBlock(gridX: 4, gridY: 5),
    ],
    availableInventory: [
      DeviceModel(id: "t_well1", type: DeviceType.gravityWell),
    ],
    creditsReward: 300,
    researchPointsReward: 60,
  ),

  // LEVEL 6: Portal Transit
  LevelData(
    id: 6,
    name: "Level 6: Portal Transit",
    description: "Einstein-Rosen portal transits link the system. The laser shoots up, enters Portal A at (3, 8), teleports out of Portal B at (6, 4) to destroy Kessel.",
    deathStarX: 3,
    deathStarY: 11,
    deathStarInitialAngle: -90.0,
    planets: [
      PlanetTarget(id: "p1", gridX: 6, gridY: 1, name: "Kessel", color: Colors.yellowAccent),
    ],
    walls: [
      WallBlock(gridX: 3, gridY: 3),
      WallBlock(gridX: 3, gridY: 4),
      WallBlock(gridX: 3, gridY: 5),
      WallBlock(gridX: 4, gridY: 3),
      WallBlock(gridX: 4, gridY: 4),
      WallBlock(gridX: 4, gridY: 5),
    ],
    availableInventory: [
      DeviceModel(id: "t_ref1", type: DeviceType.reflector),
    ],
    presetDevices: [
      DeviceModel(id: "port1", type: DeviceType.portal, gridX: 3, gridY: 8, portalPairId: "port2", isPlaced: true),
      DeviceModel(id: "port2", type: DeviceType.portal, gridX: 6, gridY: 4, portalPairId: "port1", isPlaced: true),
    ],
    creditsReward: 400,
    researchPointsReward: 80,
  ),
];
