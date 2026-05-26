import 'dart:convert';
import '../config/campaign_config.dart';
import 'device_model.dart';
import 'level_data.dart';
import 'game_progression.dart';

enum QuestType { lore, side, daily }

class QuestModel {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final String? storyLoreSnippet; // Lore narrative displayed before starting the quest
  final int creditsReward;
  final int rpReward;
  final LevelData levelData;
  bool isCompleted;

  QuestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.storyLoreSnippet,
    this.creditsReward = 100,
    this.rpReward = 20,
    required this.levelData,
    this.isCompleted = false,
  });

  QuestModel copyWith({
    String? id,
    String? title,
    String? description,
    QuestType? type,
    String? storyLoreSnippet,
    int? creditsReward,
    int? rpReward,
    LevelData? levelData,
    bool? isCompleted,
  }) {
    return QuestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      storyLoreSnippet: storyLoreSnippet ?? this.storyLoreSnippet,
      creditsReward: creditsReward ?? this.creditsReward,
      rpReward: rpReward ?? this.rpReward,
      levelData: levelData ?? this.levelData,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory QuestModel.fromJson(Map<String, dynamic> json) {
    return QuestModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: QuestType.values.firstWhere((e) => e.name == json['type']),
      storyLoreSnippet: json['storyLoreSnippet'] as String?,
      creditsReward: json['creditsReward'] as int? ?? 100,
      rpReward: json['rpReward'] as int? ?? 20,
      levelData: LevelData.fromJson(json['levelData'] as Map<String, dynamic>),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

class GalaxyModel {
  final String id;
  final String name;
  final String description;
  final String requirementDescription;
  final int minLaserIntensityLevel;
  final int minAimingComputerLevel;
  final List<DeviceType> requiredUnlockedBlueprints;
  final List<String> prerequisiteGalaxyIds;
  final List<QuestModel> quests;

  GalaxyModel({
    required this.id,
    required this.name,
    required this.description,
    required this.requirementDescription,
    this.minLaserIntensityLevel = 1,
    this.minAimingComputerLevel = 1,
    this.requiredUnlockedBlueprints = const [],
    this.prerequisiteGalaxyIds = const [],
    required this.quests,
  });

  bool checkUnlockStatus(GameProgression progression) {
    // Starting Sector Galaxy is always unlocked by default
    if (id == 'galaxy_1') return true;

    final hasRequiredBlueprints = requiredUnlockedBlueprints.every(
      (type) => progression.unlockedDevices.contains(type),
    );
    final hasCompletedPrereqs = prerequisiteGalaxyIds.every(
      (prereqId) => progression.completedGalaxyIds.contains(prereqId),
    );

    return progression.laserIntensityLevel >= minLaserIntensityLevel &&
        progression.aimingComputerLevel >= minAimingComputerLevel &&
        hasRequiredBlueprints &&
        hasCompletedPrereqs;
  }

  factory GalaxyModel.fromJson(Map<String, dynamic> json) {
    return GalaxyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      requirementDescription: json['requirementDescription'] as String? ?? '',
      minLaserIntensityLevel: json['minLaserIntensityLevel'] as int? ?? 1,
      minAimingComputerLevel: json['minAimingComputerLevel'] as int? ?? 1,
      requiredUnlockedBlueprints: (json['requiredUnlockedBlueprints'] as List<dynamic>?)
              ?.map((e) => DeviceType.values.firstWhere((type) => type.name == e))
              .toList() ??
          const [],
      prerequisiteGalaxyIds: (json['prerequisiteGalaxyIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      quests: (json['quests'] as List<dynamic>)
          .map((q) => QuestModel.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}

final List<GalaxyModel> preloadedGalaxies = _loadGalaxiesFromConfig();

List<GalaxyModel> _loadGalaxiesFromConfig() {
  final List<dynamic> list = json.decode(campaignJsonConfig);
  return list.map((jsonMap) => GalaxyModel.fromJson(jsonMap as Map<String, dynamic>)).toList();
}
