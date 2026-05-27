import 'dart:convert';
import 'package:flutter/material.dart';
import '../config/levels_config.dart';
import 'device_model.dart';

class PlanetTarget {
  final String id;
  final int gridX;
  final int gridY;
  final double radius;
  final String name;
  final Color color;
  bool isDestroyed;
  final int? requiredLaserPower; // Power level needed to destroy/penetrate it.

  PlanetTarget({
    required this.id,
    required this.gridX,
    required this.gridY,
    this.radius = 20.0,
    required this.name,
    required this.color,
    this.isDestroyed = false,
    this.requiredLaserPower,
  });

  PlanetTarget copyWith({
    String? id,
    int? gridX,
    int? gridY,
    double? radius,
    String? name,
    Color? color,
    bool? isDestroyed,
    int? requiredLaserPower,
  }) {
    return PlanetTarget(
      id: id ?? this.id,
      gridX: gridX ?? this.gridX,
      gridY: gridY ?? this.gridY,
      radius: radius ?? this.radius,
      name: name ?? this.name,
      color: color ?? this.color,
      isDestroyed: isDestroyed ?? this.isDestroyed,
      requiredLaserPower: requiredLaserPower ?? this.requiredLaserPower,
    );
  }

  factory PlanetTarget.fromJson(Map<String, dynamic> json) {
    return PlanetTarget(
      id: json['id'] as String,
      gridX: json['gridX'] as int,
      gridY: json['gridY'] as int,
      radius: (json['radius'] as num? ?? 20.0).toDouble(),
      name: json['name'] as String,
      color: Color(int.parse(json['color'] as String)),
      isDestroyed: json['isDestroyed'] as bool? ?? false,
      requiredLaserPower: json['requiredLaserPower'] as int?,
    );
  }
}

class WallBlock {
  final int gridX;
  final int gridY;
  final bool isDestructible; // Can be blown up by a bomb
  final String type; // 'asteroid', 'energyShield', 'crystal', 'scrapMetal'
  final int? requiredLaserPower; // Power level needed to bypass/destroy it.

  WallBlock({
    required this.gridX,
    required this.gridY,
    this.isDestructible = false,
    this.type = 'asteroid',
    this.requiredLaserPower,
  });

  factory WallBlock.fromJson(Map<String, dynamic> json) {
    return WallBlock(
      gridX: json['gridX'] as int,
      gridY: json['gridY'] as int,
      isDestructible: json['isDestructible'] as bool? ?? false,
      type: json['type'] as String? ?? 'asteroid',
      requiredLaserPower: json['requiredLaserPower'] as int?,
    );
  }
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

  factory LevelData.fromJson(Map<String, dynamic> json) {
    return LevelData(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      deathStarX: json['deathStarX'] as int,
      deathStarY: json['deathStarY'] as int,
      deathStarInitialAngle: (json['deathStarInitialAngle'] as num? ?? -90.0).toDouble(),
      planets: (json['planets'] as List<dynamic>).map((p) => PlanetTarget.fromJson(p as Map<String, dynamic>)).toList(),
      walls: (json['walls'] as List<dynamic>).map((w) => WallBlock.fromJson(w as Map<String, dynamic>)).toList(),
      availableInventory: (json['availableInventory'] as List<dynamic>).map((d) => DeviceModel.fromJson(d as Map<String, dynamic>)).toList(),
      presetDevices: (json['presetDevices'] as List<dynamic>?)?.map((d) => DeviceModel.fromJson(d as Map<String, dynamic>)).toList() ?? const [],
      creditsReward: json['creditsReward'] as int? ?? 100,
      researchPointsReward: json['researchPointsReward'] as int? ?? 20,
    );
  }
}

// Preloaded vertical level database (Grid dimensions: X: 0-7, Y: 0-11)
final List<LevelData> preloadedLevels = _loadLevelsFromConfig();

List<LevelData> _loadLevelsFromConfig() {
  final List<dynamic> list = json.decode(levelsJsonConfig);
  return list.map((jsonMap) => LevelData.fromJson(jsonMap as Map<String, dynamic>)).toList();
}
