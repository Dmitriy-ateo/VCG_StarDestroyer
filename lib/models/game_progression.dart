import 'dart:math';
import 'device_model.dart';

class GameProgression {
  int credits;
  int researchPoints;
  Set<int> completedLevelIds;
  Set<DeviceType> unlockedDevices;
  Set<double> unlockedSplitterAngles; // Tracks unlocked splitter angle variants
  Map<String, int> purchasedMarketDevices; // Tracks purchased extra items
  Set<String> completedGalaxyIds; // Tracks unlocked/completed galaxies
  Set<String> completedQuestIds; // Tracks cleared campaign quests
  
  // Daily Hard Mission State Fields
  String? dailyHardGalaxyId;
  bool dailyHardCompleted;
  String? dailyHardDateStr;
  String? dailyHardQuestId;
  
  // High-Tech RPG Chassis Progression Tree
  Map<String, String> chassisRanks;
  Map<String, int> chassisStars;
  Map<String, int> chassisSubLevels;
  
  // High-Tech RPG Device Progression Tree (F to SSS ranks, 0-3 stars, 1-5 sub-levels)
  Map<DeviceType, String> deviceRanks;
  Map<DeviceType, int> deviceStars;
  Map<DeviceType, int> deviceSubLevels;

  static const List<String> ranksList = ['F', 'E', 'D', 'C', 'B', 'A', 'S', 'SS', 'SSS'];

  GameProgression({
    this.credits = 100,
    this.researchPoints = 0,
    Set<int>? completedLevelIds,
    Set<DeviceType>? unlockedDevices,
    Set<double>? unlockedSplitterAngles,
    Map<String, int>? purchasedMarketDevices,
    Set<String>? completedGalaxyIds,
    Set<String>? completedQuestIds,
    Map<String, String>? chassisRanks,
    Map<String, int>? chassisStars,
    Map<String, int>? chassisSubLevels,
    Map<DeviceType, String>? deviceRanks,
    Map<DeviceType, int>? deviceStars,
    Map<DeviceType, int>? deviceSubLevels,
    this.dailyHardGalaxyId,
    bool? dailyHardCompleted,
    this.dailyHardDateStr,
    this.dailyHardQuestId,
  })  : completedLevelIds = completedLevelIds ?? {},
        unlockedDevices = unlockedDevices ?? {DeviceType.reflector},
        unlockedSplitterAngles = unlockedSplitterAngles ?? {180.0},
        completedGalaxyIds = completedGalaxyIds ?? {},
        completedQuestIds = completedQuestIds ?? {},
        dailyHardCompleted = dailyHardCompleted ?? false,
        purchasedMarketDevices = purchasedMarketDevices ?? {
          'reflector': 0,
          'bomb': 0,
          'gravityWell': 0,
          'portal': 0,
          'splitter_180': 0,
          'splitter_90': 0,
          'splitter_135': 0,
          'splitter_45': 0,
          'floatingAsteroid': 0,
        },
        chassisRanks = chassisRanks ?? {
          'intensity': 'F',
          'aiming': 'F',
          'chassis': 'F',
        },
        chassisStars = chassisStars ?? {
          'intensity': 0,
          'aiming': 0,
          'chassis': 0,
        },
        chassisSubLevels = chassisSubLevels ?? {
          'intensity': 1,
          'aiming': 1,
          'chassis': 1,
        },
        deviceRanks = deviceRanks ?? {
          DeviceType.reflector: 'F',
          DeviceType.splitter: 'F',
          DeviceType.bomb: 'F',
          DeviceType.gravityWell: 'F',
          DeviceType.portal: 'F',
          DeviceType.floatingAsteroid: 'F',
        },
        deviceStars = deviceStars ?? {
          DeviceType.reflector: 0,
          DeviceType.splitter: 0,
          DeviceType.bomb: 0,
          DeviceType.gravityWell: 0,
          DeviceType.portal: 0,
          DeviceType.floatingAsteroid: 0,
        },
        deviceSubLevels = deviceSubLevels ?? {
          DeviceType.reflector: 1,
          DeviceType.splitter: 1,
          DeviceType.bomb: 1,
          DeviceType.gravityWell: 1,
          DeviceType.portal: 1,
          DeviceType.floatingAsteroid: 1,
        };

  // Effective Sub-System Levels computed via rank and stars (Star Tier Levels, e.g. 1 to 36)
  int get laserIntensityLevel {
    final rank = chassisRanks['intensity'] ?? 'F';
    final stars = chassisStars['intensity'] ?? 0;
    final idx = ranksList.indexOf(rank);
    return (idx != -1 ? idx : 0) * 4 + stars + 1;
  }

  int get aimingComputerLevel {
    final rank = chassisRanks['aiming'] ?? 'F';
    final stars = chassisStars['aiming'] ?? 0;
    final idx = ranksList.indexOf(rank);
    return (idx != -1 ? idx : 0) * 4 + stars + 1;
  }

  int get chassisCapacityLevel {
    final rank = chassisRanks['chassis'] ?? 'F';
    final stars = chassisStars['chassis'] ?? 0;
    final idx = ranksList.indexOf(rank);
    return (idx != -1 ? idx : 0) * 4 + stars + 1;
  }

  int getLaserIntensityScore() {
    final rank = chassisRanks['intensity'] ?? 'F';
    final stars = chassisStars['intensity'] ?? 0;
    final rankIdx = ranksList.indexOf(rank);
    return (rankIdx != -1 ? rankIdx : 0) * 4 + stars;
  }

  int getAimingComputerScore() {
    final rank = chassisRanks['aiming'] ?? 'F';
    final stars = chassisStars['aiming'] ?? 0;
    final rankIdx = ranksList.indexOf(rank);
    return (rankIdx != -1 ? rankIdx : 0) * 4 + stars;
  }

  static int getCumulativeScore(String rank, int stars) {
    final rankIdx = ranksList.indexOf(rank);
    return (rankIdx != -1 ? rankIdx : 0) * 4 + stars;
  }

  static String formatRankAndStars(String rank, int stars) {
    if (stars == 0) return "Rank $rank";
    return "Rank $rank ${'★' * stars}";
  }

  static String formatLevel(int level) {
    if (level <= 0) return "Rank F";
    final rankIdx = (level - 1) ~/ 4;
    final stars = (level - 1) % 4;
    final safeRankIdx = min(rankIdx, ranksList.length - 1);
    final rank = ranksList[safeRankIdx];
    return formatRankAndStars(rank, stars);
  }

  // Effective device levels for standard gameplay physics (Star Tier Levels, e.g. 1 to 36)
  Map<DeviceType, int> get deviceLevels {
    final levels = <DeviceType, int>{};
    deviceRanks.forEach((type, rank) {
      final stars = deviceStars[type] ?? 0;
      final idx = ranksList.indexOf(rank);
      levels[type] = (idx != -1 ? idx : 0) * 4 + stars + 1;
    });
    return levels;
  }

  // Clone progression
  GameProgression clone() {
    return GameProgression(
      credits: credits,
      researchPoints: researchPoints,
      completedLevelIds: Set.from(completedLevelIds),
      unlockedDevices: Set.from(unlockedDevices),
      unlockedSplitterAngles: Set.from(unlockedSplitterAngles),
      purchasedMarketDevices: Map.from(purchasedMarketDevices),
      completedGalaxyIds: Set.from(completedGalaxyIds),
      completedQuestIds: Set.from(completedQuestIds),
      chassisRanks: Map.from(chassisRanks),
      chassisStars: Map.from(chassisStars),
      chassisSubLevels: Map.from(chassisSubLevels),
      deviceRanks: Map.from(deviceRanks),
      deviceStars: Map.from(deviceStars),
      deviceSubLevels: Map.from(deviceSubLevels),
      dailyHardGalaxyId: dailyHardGalaxyId,
      dailyHardCompleted: dailyHardCompleted,
      dailyHardDateStr: dailyHardDateStr,
      dailyHardQuestId: dailyHardQuestId,
    );
  }

  // JSON Serialization
  Map<String, dynamic> toJson() {
    return {
      'credits': credits,
      'researchPoints': researchPoints,
      'completedLevelIds': completedLevelIds.toList(),
      'unlockedDevices': unlockedDevices.map((e) => e.name).toList(),
      'unlockedSplitterAngles': unlockedSplitterAngles.toList(),
      'purchasedMarketDevices': purchasedMarketDevices,
      'completedGalaxyIds': completedGalaxyIds.toList(),
      'completedQuestIds': completedQuestIds.toList(),
      'chassisRanks': chassisRanks,
      'chassisStars': chassisStars,
      'chassisSubLevels': chassisSubLevels,
      'deviceRanks': deviceRanks.map((key, value) => MapEntry(key.name, value)),
      'deviceStars': deviceStars.map((key, value) => MapEntry(key.name, value)),
      'deviceSubLevels': deviceSubLevels.map((key, value) => MapEntry(key.name, value)),
      'dailyHardGalaxyId': dailyHardGalaxyId,
      'dailyHardCompleted': dailyHardCompleted,
      'dailyHardDateStr': dailyHardDateStr,
      'dailyHardQuestId': dailyHardQuestId,
    };
  }

  // JSON Deserialization
  factory GameProgression.fromJson(Map<String, dynamic> json) {
    Set<int> parseSetInt(dynamic value) {
      if (value == null) return {};
      return (value as List<dynamic>).map((e) => e as int).toSet();
    }

    Set<double> parseSetDouble(dynamic value) {
      if (value == null) return {};
      return (value as List<dynamic>).map((e) => (e as num).toDouble()).toSet();
    }

    Set<String> parseSetString(dynamic value) {
      if (value == null) return {};
      return (value as List<dynamic>).map((e) => e as String).toSet();
    }

    Set<DeviceType> parseSetDeviceType(dynamic value) {
      if (value == null) return {};
      return (value as List<dynamic>)
          .map((e) => DeviceType.values.firstWhere((type) => type.name == e))
          .toSet();
    }

    Map<String, int> parseMapStringInt(dynamic value, Map<String, int> defaultValue) {
      if (value == null) return defaultValue;
      return (value as Map<String, dynamic>).map((key, val) => MapEntry(key, val as int));
    }

    Map<String, String> parseMapStringString(dynamic value, Map<String, String> defaultValue) {
      if (value == null) return defaultValue;
      return (value as Map<String, dynamic>).map((key, val) => MapEntry(key, val as String));
    }

    Map<DeviceType, String> parseMapDeviceTypeString(dynamic value, Map<DeviceType, String> defaultValue) {
      if (value == null) return defaultValue;
      return (value as Map<String, dynamic>).map((key, val) {
        final type = DeviceType.values.firstWhere((e) => e.name == key, orElse: () => DeviceType.reflector);
        return MapEntry(type, val as String);
      });
    }

    Map<DeviceType, int> parseMapDeviceTypeInt(dynamic value, Map<DeviceType, int> defaultValue) {
      if (value == null) return defaultValue;
      return (value as Map<String, dynamic>).map((key, val) {
        final type = DeviceType.values.firstWhere((e) => e.name == key, orElse: () => DeviceType.reflector);
        return MapEntry(type, val as int);
      });
    }

    return GameProgression(
      credits: json['credits'] as int? ?? 100,
      researchPoints: json['researchPoints'] as int? ?? 0,
      completedLevelIds: parseSetInt(json['completedLevelIds']),
      unlockedDevices: parseSetDeviceType(json['unlockedDevices']),
      unlockedSplitterAngles: parseSetDouble(json['unlockedSplitterAngles']),
      purchasedMarketDevices: parseMapStringInt(json['purchasedMarketDevices'], {
        'reflector': 0,
        'bomb': 0,
        'gravityWell': 0,
        'portal': 0,
        'splitter_180': 0,
        'splitter_90': 0,
        'splitter_135': 0,
        'splitter_45': 0,
        'floatingAsteroid': 0,
      }),
      completedGalaxyIds: parseSetString(json['completedGalaxyIds']),
      completedQuestIds: parseSetString(json['completedQuestIds']),
      chassisRanks: parseMapStringString(json['chassisRanks'], {
        'intensity': 'F',
        'aiming': 'F',
        'chassis': 'F',
      }),
      chassisStars: parseMapStringInt(json['chassisStars'], {
        'intensity': 0,
        'aiming': 0,
        'chassis': 0,
      }),
      chassisSubLevels: parseMapStringInt(json['chassisSubLevels'], {
        'intensity': 1,
        'aiming': 1,
        'chassis': 1,
      }),
      deviceRanks: parseMapDeviceTypeString(json['deviceRanks'], {
        DeviceType.reflector: 'F',
        DeviceType.splitter: 'F',
        DeviceType.bomb: 'F',
        DeviceType.gravityWell: 'F',
        DeviceType.portal: 'F',
        DeviceType.floatingAsteroid: 'F',
      }),
      deviceStars: parseMapDeviceTypeInt(json['deviceStars'], {
        DeviceType.reflector: 0,
        DeviceType.splitter: 0,
        DeviceType.bomb: 0,
        DeviceType.gravityWell: 0,
        DeviceType.portal: 0,
        DeviceType.floatingAsteroid: 0,
      }),
      deviceSubLevels: parseMapDeviceTypeInt(json['deviceSubLevels'], {
        DeviceType.reflector: 1,
        DeviceType.splitter: 1,
        DeviceType.bomb: 1,
        DeviceType.gravityWell: 1,
        DeviceType.portal: 1,
        DeviceType.floatingAsteroid: 1,
      }),
      dailyHardGalaxyId: json['dailyHardGalaxyId'] as String?,
      dailyHardCompleted: json['dailyHardCompleted'] as bool?,
      dailyHardDateStr: json['dailyHardDateStr'] as String?,
      dailyHardQuestId: json['dailyHardQuestId'] as String?,
    );
  }

  // Rollover checking using local calendar dates. Returns true if rollover occurred.
  bool checkAndRollOverDailyHard(List<String> unlockedGalaxyIds) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (dailyHardDateStr != today || dailyHardGalaxyId == null || dailyHardQuestId == null) {
      dailyHardCompleted = false;
      dailyHardDateStr = today;
      final eligible = unlockedGalaxyIds.where((id) => id != 'galaxy_1').toList();
      if (eligible.isNotEmpty) {
        eligible.shuffle(Random());
        dailyHardGalaxyId = eligible.first;
        dailyHardQuestId = "daily_hard_quest_${dailyHardGalaxyId}_$today";
      } else {
        dailyHardGalaxyId = null;
        dailyHardQuestId = null;
      }
      return true;
    }
    return false;
  }

  static int getMarketItemPrice(String itemId) {
    if (itemId.startsWith('splitter_')) {
      return 200; // Standard price for all splitters
    }
    switch (itemId) {
      case 'reflector':
        return 150;
      case 'bomb':
        return 250;
      case 'gravityWell':
        return 300;
      case 'portal':
        return 400;
      case 'floatingAsteroid':
        return 500;
      default:
        return 9999;
    }
  }

  // Cost calculations for sub-system chassis upgrades paid in Credits (C)
  static int getChassisUpgradeCost(String rank, int stars, int subLevel) {
    if (rank == 'SSS' && stars == 3 && subLevel == 5) return -1; // Max Level reached!
    
    final rankIdx = ranksList.indexOf(rank);
    final cumulativeLevel = rankIdx * 20 + stars * 5 + (subLevel - 1);
    
    // Geometric growth curves
    final costFloat = 80.0 * pow(1.08, cumulativeLevel);
    int cost = costFloat.toInt();
    
    // Linear cap to keep ultimate upgrades viable
    if (cost > 1500) {
      cost = 1500 + (cumulativeLevel - 35) * 15;
    }
    
    return cost;
  }

  // Device technology upgrade costs in RP based on rank index, stars, and sub-levels
  static int getDeviceUpgradeCost(String rank, int stars, int subLevel) {
    if (rank == 'SSS' && stars == 3 && subLevel == 5) return -1; // Max Level reached!
    
    final rankIdx = ranksList.indexOf(rank);
    final cumulativeLevel = rankIdx * 20 + stars * 5 + (subLevel - 1);
    
    // Geometric growth curves
    final costFloat = 30.0 * pow(1.10, cumulativeLevel);
    int cost = costFloat.toInt();
    
    // Smooth linear leveling off at upper RP tiers to prevent astronomical overflow
    if (cost > 1200) {
      cost = 1200 + (cumulativeLevel - 38) * 20;
    }
    
    return cost;
  }

  static int getDeviceResearchCost(DeviceType type) {
    switch (type) {
      case DeviceType.reflector:
        return 0; // Already unlocked
      case DeviceType.splitter:
        return 0; // Base splitter category is unlocked, individual angles are researched
      case DeviceType.bomb:
        return 50;
      case DeviceType.gravityWell:
        return 80;
      case DeviceType.portal:
        return 100;
      case DeviceType.floatingAsteroid:
        return 120;
    }
  }

  static int getSplitterResearchCost(double angle) {
    switch (angle) {
      case 180.0:
        return 0; // Already unlocked by default
      case 90.0:
        return 30;
      case 135.0:
        return 50;
      case 45.0:
        return 70;
      default:
        return 9999;
    }
  }

  bool unlockSplitterAngle(double angle) {
    if (unlockedSplitterAngles.contains(angle)) return false;
    int cost = getSplitterResearchCost(angle);
    if (researchPoints >= cost) {
      researchPoints -= cost;
      unlockedSplitterAngles.add(angle);
      return true;
    }
    return false;
  }

  bool isLevelUnlocked(int levelId) {
    if (levelId == 1) return true;
    if (levelId >= 7) {
      if (!completedGalaxyIds.contains('galaxy_3')) {
        return false;
      }
    }
    return completedLevelIds.contains(levelId - 1);
  }
}
