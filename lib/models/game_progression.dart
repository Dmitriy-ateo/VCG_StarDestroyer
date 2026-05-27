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
  
  // Upgrades
  int laserIntensityLevel; // 1 to 5
  int aimingComputerLevel; // 1 to 10 (each adds 10% preview length, 10 = 100% full preview)
  int chassisCapacityLevel; // 1 to 5 (bonus inventory slots)
  Map<DeviceType, int> deviceLevels; // Researched device tech levels (1 to 5)

  GameProgression({
    this.credits = 100,
    this.researchPoints = 0,
    Set<int>? completedLevelIds,
    Set<DeviceType>? unlockedDevices,
    Set<double>? unlockedSplitterAngles,
    Map<String, int>? purchasedMarketDevices,
    Set<String>? completedGalaxyIds,
    Set<String>? completedQuestIds,
    this.laserIntensityLevel = 1,
    this.aimingComputerLevel = 1, // Start with aiming preview enabled level 1
    this.chassisCapacityLevel = 1,
    Map<DeviceType, int>? deviceLevels,
  })  : completedLevelIds = completedLevelIds ?? {},
        unlockedDevices = unlockedDevices ?? {DeviceType.reflector},
        unlockedSplitterAngles = unlockedSplitterAngles ?? {180.0},
        completedGalaxyIds = completedGalaxyIds ?? {},
        completedQuestIds = completedQuestIds ?? {},
        purchasedMarketDevices = purchasedMarketDevices ?? {
          'reflector': 0,
          'bomb': 0,
          'gravityWell': 0,
          'portal': 0,
          'splitter_180': 0,
          'splitter_90': 0,
          'splitter_135': 0,
          'splitter_45': 0,
        },
        deviceLevels = deviceLevels ?? {
          DeviceType.reflector: 1,
          DeviceType.splitter: 1,
          DeviceType.bomb: 1,
          DeviceType.gravityWell: 1,
          DeviceType.portal: 1,
        };

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
      laserIntensityLevel: laserIntensityLevel,
      aimingComputerLevel: aimingComputerLevel,
      chassisCapacityLevel: chassisCapacityLevel,
      deviceLevels: Map.from(deviceLevels),
    );
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
      default:
        return 9999;
    }
  }

  // Cost calculations for Shop
  static int getUpgradeCost(String type, int currentLevel) {
    switch (type) {
      case 'intensity':
        if (currentLevel >= 5) return -1; // Maxed out
        return currentLevel * 150;
      case 'aiming':
        if (currentLevel >= 10) return -1; // Maxed out (10 levels)
        return currentLevel * 100;
      case 'chassis':
        if (currentLevel >= 5) return -1; // Maxed out
        return currentLevel * 120;
      default:
        return 9999;
    }
  }

  // Device technology upgrade costs in RP
  static int getDeviceUpgradeCost(DeviceType type, int currentLevel) {
    if (currentLevel >= 5) return -1; // Max Level 5
    return currentLevel * 40; // level 1->2 is 40 RP, 2->3 is 80 RP, 3->4 is 120 RP, 4->5 is 160 RP
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
    return completedLevelIds.contains(levelId - 1);
  }
}
