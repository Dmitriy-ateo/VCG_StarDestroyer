import 'device_model.dart';

class GameProgression {
  int credits;
  int researchPoints;
  Set<int> completedLevelIds;
  Set<DeviceType> unlockedDevices;
  Set<double> unlockedSplitterAngles; // Tracks unlocked splitter angle variants
  Map<String, int> purchasedMarketDevices; // Tracks purchased extra items
  
  // Upgrades
  int laserIntensityLevel; // 1 to 5
  int aimingComputerLevel; // 1 to 3 (0 = locked, 1 = short preview, 2 = full preview)
  int chassisCapacityLevel; // 1 to 5 (bonus inventory slots)

  GameProgression({
    this.credits = 100,
    this.researchPoints = 0,
    Set<int>? completedLevelIds,
    Set<DeviceType>? unlockedDevices,
    Set<double>? unlockedSplitterAngles,
    Map<String, int>? purchasedMarketDevices,
    this.laserIntensityLevel = 1,
    this.aimingComputerLevel = 1, // Start with aiming preview enabled level 1
    this.chassisCapacityLevel = 1,
  })  : completedLevelIds = completedLevelIds ?? {},
        unlockedDevices = unlockedDevices ?? {DeviceType.reflector},
        unlockedSplitterAngles = unlockedSplitterAngles ?? {180.0},
        purchasedMarketDevices = purchasedMarketDevices ?? {
          'reflector': 0,
          'bomb': 0,
          'gravityWell': 0,
          'portal': 0,
          'splitter_180': 0,
          'splitter_90': 0,
          'splitter_135': 0,
          'splitter_45': 0,
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
      laserIntensityLevel: laserIntensityLevel,
      aimingComputerLevel: aimingComputerLevel,
      chassisCapacityLevel: chassisCapacityLevel,
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
    if (currentLevel >= 5) return -1; // Maxed out
    switch (type) {
      case 'intensity':
        return currentLevel * 150;
      case 'aiming':
        if (currentLevel >= 3) return -1;
        return currentLevel * 200;
      case 'chassis':
        return currentLevel * 120;
      default:
        return 9999;
    }
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
