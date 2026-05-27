import 'dart:async';
import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../models/level_data.dart';
import '../models/game_progression.dart';
import '../models/galaxy_model.dart';
import 'laser_calculator.dart';

enum PlayState {
  editing,
  firing,
  victory,
  defeat,
}

class GameController extends ChangeNotifier {
  // Progression State
  final GameProgression progression = GameProgression();

  // Active Level State
  late LevelData currentLevel;
  PlayState playState = PlayState.editing;
  QuestModel? activeQuest;

  // Active Level Rewards Earned
  int creditsEarned = 0;
  int researchPointsEarned = 0;
  
  // Placed and inventory devices
  List<DeviceModel> placedDevices = [];
  List<DeviceModel> inventory = [];
  DeviceModel? selectedInventoryDevice;

  // Aiming controls
  double aimingAngle = 0.0; // Firing angle in degrees

  // Ray tracing result
  LaserTraceResult? traceResult;

  // Firing Animation State
  double animationProgress = 0.0;
  Timer? _animationTimer;

  GameController() {
    loadLevel(1);
  }

  // Load level configuration
  void loadLevel(int levelId) {
    // Stop any animations
    _cleanupAnimation();

    activeQuest = null;

    final baseLevel = preloadedLevels.firstWhere(
      (l) => l.id == levelId,
      orElse: () => preloadedLevels.first,
    );

    currentLevel = baseLevel.clone();
    aimingAngle = currentLevel.deathStarInitialAngle;
    playState = PlayState.editing;
    traceResult = null;
    animationProgress = 0.0;
    selectedInventoryDevice = null;
    placedDevices = [];
    creditsEarned = 0;
    researchPointsEarned = 0;

    // Initialize inventory from level data templates
    inventory = [];
    int idCounter = 0;
    for (var template in currentLevel.availableInventory) {
      // Check if device type is unlocked in shop
      // Note: for tutorial/training levels, allow it anyway to educate the player
      final isTutorial = currentLevel.id <= 5;
      final type = template.type;
      final isUnlocked = progression.unlockedDevices.contains(type);

      // Check if specific splitter variant angle is unlocked
      bool isSplitterVariantUnlocked = true;
      if (type == DeviceType.splitter && template.splitAngleDegrees != null) {
        isSplitterVariantUnlocked = progression.unlockedSplitterAngles.contains(template.splitAngleDegrees!);
      }

      if (isTutorial || (isUnlocked && isSplitterVariantUnlocked)) {
        String devId = "inv_${type.name}_${idCounter++}";

        // If portal, handle pair creation
        if (type == DeviceType.portal) {
          final pairIdString = "inv_${type.name}_${idCounter++}";
          inventory.add(template.copyWith(
            id: devId,
            portalPairId: pairIdString,
            isPlaced: false,
          ));
          inventory.add(template.copyWith(
            id: pairIdString,
            portalPairId: devId,
            isPlaced: false,
          ));
        } else {
          inventory.add(template.copyWith(
            id: devId,
            isPlaced: false,
          ));
        }
      }
    }

    notifyListeners();
  }

  // Load campaign quest configuration
  void loadQuest(QuestModel quest) {
    _cleanupAnimation();
    activeQuest = quest;
    currentLevel = quest.levelData.clone();
    aimingAngle = currentLevel.deathStarInitialAngle;
    playState = PlayState.editing;
    traceResult = null;
    animationProgress = 0.0;
    selectedInventoryDevice = null;
    placedDevices = [];
    creditsEarned = 0;
    researchPointsEarned = 0;

    // Initialize inventory (Only storefront purchased devices)
    inventory = [];
    int idCounter = 0;

    // Append market-purchased devices to the inventory pool
    progression.purchasedMarketDevices.forEach((itemId, count) {
      if (count <= 0) return;
      
      if (itemId == 'portal') {
        for (int i = 0; i < count; i++) {
          final devId = "market_portal_${idCounter++}";
          final pairIdString = "market_portal_${idCounter++}";
          
          inventory.add(DeviceModel(
            id: devId,
            type: DeviceType.portal,
            portalPairId: pairIdString,
            isPlaced: false,
          ));
          inventory.add(DeviceModel(
            id: pairIdString,
            type: DeviceType.portal,
            portalPairId: devId,
            isPlaced: false,
          ));
        }
      } else if (itemId.startsWith('splitter_')) {
        final angleStr = itemId.split('_')[1];
        final angle = double.tryParse(angleStr) ?? 180.0;
        for (int i = 0; i < count; i++) {
          inventory.add(DeviceModel(
            id: "market_${itemId}_${idCounter++}",
            type: DeviceType.splitter,
            splitAngleDegrees: angle,
            isPlaced: false,
          ));
        }
      } else {
        final type = DeviceType.values.firstWhere((e) => e.name == itemId, orElse: () => DeviceType.reflector);
        for (int i = 0; i < count; i++) {
          inventory.add(DeviceModel(
            id: "market_${itemId}_${idCounter++}",
            type: type,
            isPlaced: false,
          ));
        }
      }
    });

    notifyListeners();
  }

  // Aiming Controls
  void setAimingAngle(double angle) {
    if (playState != PlayState.editing) return;
    aimingAngle = angle.clamp(-180.0, 0.0);
    notifyListeners();
  }

  // Device Placement Actions
  void selectInventoryDevice(DeviceModel? device) {
    if (playState != PlayState.editing) return;
    selectedInventoryDevice = device;
    notifyListeners();
  }

  bool placeDevice(int x, int y) {
    if (playState != PlayState.editing || selectedInventoryDevice == null) return false;
    
    // Check occupancy collisions
    if (!isCellEmpty(x, y)) return false;

    final dev = selectedInventoryDevice!;
    
    // Remove from active inventory list selection, set position
    dev.gridX = x;
    dev.gridY = y;
    dev.isPlaced = true;

    placedDevices.add(dev);
    
    // If it was a portal pair and the pair is not placed yet, don't auto-deselect
    // but typically we can deselect now
    selectedInventoryDevice = null;
    notifyListeners();
    return true;
  }

  void removeDevice(DeviceModel device) {
    if (playState != PlayState.editing) return;
    device.isPlaced = false;
    placedDevices.remove(device);
    notifyListeners();
  }

  void rotateDevice(DeviceModel device) {
    if (playState != PlayState.editing) return;
    // Rotate 45 degrees clockwise
    device.angleDegrees = (device.angleDegrees + 45.0) % 360.0;
    notifyListeners();
  }

  bool isCellEmpty(int x, int y) {
    // Out of bounds checks
    if (x < 0 || x >= 8 || y < 0 || y >= 12) return false;

    // Death Star cell collision
    if (x == currentLevel.deathStarX && y == currentLevel.deathStarY) return false;

    // Planets collision
    for (var planet in currentLevel.planets) {
      if (planet.gridX == x && planet.gridY == y) return false;
    }

    // Walls collision
    for (var wall in currentLevel.walls) {
      if (wall.gridX == x && wall.gridY == y) return false;
    }

    // Placed devices collision
    for (var dev in placedDevices) {
      if (dev.isPlaced && dev.gridX == x && dev.gridY == y) return false;
    }

    // Preset level devices collision
    for (var dev in currentLevel.presetDevices) {
      if (dev.isPlaced && dev.gridX == x && dev.gridY == y) return false;
    }

    return true;
  }

  // Firing Sequence
  void fireLaser() {
    if (playState != PlayState.editing) return;

    playState = PlayState.firing;
    animationProgress = 0.0;

    // Compute Ray Trace
    traceResult = LaserCalculator.traceLaser(
      level: currentLevel,
      devices: placedDevices,
      startAngleDegrees: aimingAngle,
      laserIntensity: progression.laserIntensityLevel,
      deviceLevels: progression.deviceLevels,
    );

    notifyListeners();

    // Start propagation animation using periodic timer
    _cleanupAnimation();
    
    const tickMs = 16;
    const durationMs = 1500;
    double elapsedMs = 0;

    _animationTimer = Timer.periodic(const Duration(milliseconds: tickMs), (timer) {
      if (playState != PlayState.firing) {
        timer.cancel();
        return;
      }
      
      elapsedMs += tickMs;
      animationProgress = (elapsedMs / durationMs).clamp(0.0, 1.0);
      notifyListeners();

      if (animationProgress >= 1.0) {
        timer.cancel();
        _completeSimulation();
      }
    });
  }

  String? _getMarketItemId(DeviceModel device) {
    if (!device.id.startsWith("market_")) return null;
    if (device.type == DeviceType.portal) return 'portal';
    if (device.type == DeviceType.splitter && device.splitAngleDegrees != null) {
      return 'splitter_${device.splitAngleDegrees!.toStringAsFixed(0)}';
    }
    return device.type.name;
  }

  void _completeSimulation() {
    if (traceResult != null) {
      if (traceResult!.success) {
        playState = PlayState.victory;
        
        if (activeQuest != null) {
          // Consume the placed market devices from permanent inventory
          final Set<String> consumedPortalIds = {};
          for (var device in placedDevices) {
            if (device.type == DeviceType.portal) {
              if (consumedPortalIds.contains(device.id)) continue;
              const itemId = 'portal';
              final currentCount = progression.purchasedMarketDevices[itemId] ?? 0;
              if (currentCount > 0) {
                progression.purchasedMarketDevices[itemId] = currentCount - 1;
              }
              consumedPortalIds.add(device.id);
              if (device.portalPairId != null) {
                consumedPortalIds.add(device.portalPairId!);
              }
            } else {
              final itemId = _getMarketItemId(device);
              if (itemId != null) {
                final currentCount = progression.purchasedMarketDevices[itemId] ?? 0;
                if (currentCount > 0) {
                  progression.purchasedMarketDevices[itemId] = currentCount - 1;
                }
              }
            }
          }

          final questId = activeQuest!.id;
          final alreadyCompleted = progression.completedQuestIds.contains(questId);
          if (!alreadyCompleted) {
            creditsEarned = activeQuest!.creditsReward;
            researchPointsEarned = activeQuest!.rpReward;
            
            progression.credits += creditsEarned;
            progression.researchPoints += researchPointsEarned;
            progression.completedQuestIds.add(questId);
            
            // Check if all lore quests of the galaxy are completed
            for (var galaxy in preloadedGalaxies) {
              final hasQuest = galaxy.quests.any((q) => q.id == questId);
              if (hasQuest) {
                final allLoreCompleted = galaxy.quests
                    .where((q) => q.type == QuestType.lore)
                    .every((q) => progression.completedQuestIds.contains(q.id));
                if (allLoreCompleted) {
                  progression.completedGalaxyIds.add(galaxy.id);
                }
                break;
              }
            }
          } else {
            creditsEarned = 0;
            researchPointsEarned = 0;
          }
        } else {
          final alreadyCompleted = progression.completedLevelIds.contains(currentLevel.id);
          if (!alreadyCompleted) {
            // Credits and RP rewards reduced by 10x
            creditsEarned = currentLevel.creditsReward ~/ 10;
            researchPointsEarned = currentLevel.researchPointsReward ~/ 10;
            
            progression.credits += creditsEarned;
            progression.researchPoints += researchPointsEarned;
            progression.completedLevelIds.add(currentLevel.id);
          } else {
            creditsEarned = 0;
            researchPointsEarned = 0;
          }
        }
      } else {
        playState = PlayState.defeat;
        creditsEarned = 0;
        researchPointsEarned = 0;
      }
      notifyListeners();
    }
  }

  void resetLaser() {
    _cleanupAnimation();
    playState = PlayState.editing;
    traceResult = null;
    animationProgress = 0.0;
    notifyListeners();
  }

  // Shop actions
  bool buyUpgrade(String upgradeType) {
    int currentLvl = 1;
    if (upgradeType == 'intensity') currentLvl = progression.laserIntensityLevel;
    if (upgradeType == 'aiming') currentLvl = progression.aimingComputerLevel;
    if (upgradeType == 'chassis') currentLvl = progression.chassisCapacityLevel;

    int cost = GameProgression.getUpgradeCost(upgradeType, currentLvl);
    if (cost > 0 && progression.credits >= cost) {
      progression.credits -= cost;
      if (upgradeType == 'intensity') progression.laserIntensityLevel++;
      if (upgradeType == 'aiming') progression.aimingComputerLevel++;
      if (upgradeType == 'chassis') progression.chassisCapacityLevel++;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool unlockDeviceBlueprint(DeviceType type) {
    if (progression.unlockedDevices.contains(type)) return false;

    int cost = GameProgression.getDeviceResearchCost(type);
    if (progression.researchPoints >= cost) {
      progression.researchPoints -= cost;
      progression.unlockedDevices.add(type);
      notifyListeners();
      return true;
    }
    return false;
  }

  bool unlockSplitterVariant(double angle) {
    final unlocked = progression.unlockSplitterAngle(angle);
    if (unlocked) {
      notifyListeners();
      return true;
    }
    return false;
  }

  bool upgradeDevice(DeviceType type) {
    if (!progression.unlockedDevices.contains(type)) return false;
    final currentLvl = progression.deviceLevels[type] ?? 1;
    final cost = GameProgression.getDeviceUpgradeCost(type, currentLvl);
    if (cost > 0 && progression.researchPoints >= cost) {
      progression.researchPoints -= cost;
      progression.deviceLevels[type] = currentLvl + 1;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool buyMarketDevice(String itemId) {
    // Check if the item is unlocked/researched
    bool isUnlocked = false;
    if (itemId.startsWith('splitter_')) {
      final angleStr = itemId.split('_')[1];
      final angle = double.tryParse(angleStr) ?? 180.0;
      isUnlocked = progression.unlockedSplitterAngles.contains(angle);
    } else {
      final type = DeviceType.values.firstWhere((e) => e.name == itemId, orElse: () => DeviceType.reflector);
      isUnlocked = progression.unlockedDevices.contains(type);
    }

    if (!isUnlocked) return false;

    int cost = GameProgression.getMarketItemPrice(itemId);
    if (progression.credits >= cost) {
      progression.credits -= cost;
      progression.purchasedMarketDevices[itemId] = (progression.purchasedMarketDevices[itemId] ?? 0) + 1;

      // Dynamic Active Quest Inventory Injection: 
      // If currently inside an active campaign quest, add the newly purchased device count instantly to active inventory!
      if (activeQuest != null) {
        final idCounter = inventory.length + placedDevices.length + 100;
        
        if (itemId == 'portal') {
          final devId = "market_portal_${idCounter}";
          final pairIdString = "market_portal_${idCounter + 1}";
          
          inventory.add(DeviceModel(
            id: devId,
            type: DeviceType.portal,
            portalPairId: pairIdString,
            isPlaced: false,
          ));
          inventory.add(DeviceModel(
            id: pairIdString,
            type: DeviceType.portal,
            portalPairId: devId,
            isPlaced: false,
          ));
        } else if (itemId.startsWith('splitter_')) {
          final angleStr = itemId.split('_')[1];
          final angle = double.tryParse(angleStr) ?? 180.0;
          inventory.add(DeviceModel(
            id: "market_${itemId}_${idCounter}",
            type: DeviceType.splitter,
            splitAngleDegrees: angle,
            isPlaced: false,
          ));
        } else {
          final type = DeviceType.values.firstWhere((e) => e.name == itemId, orElse: () => DeviceType.reflector);
          inventory.add(DeviceModel(
            id: "market_${itemId}_${idCounter}",
            type: type,
            isPlaced: false,
          ));
        }
      }

      notifyListeners();
      return true;
    }
    return false;
  }

  void _cleanupAnimation() {
    _animationTimer?.cancel();
    _animationTimer = null;
  }

  @override
  void dispose() {
    _cleanupAnimation();
    super.dispose();
  }
}
