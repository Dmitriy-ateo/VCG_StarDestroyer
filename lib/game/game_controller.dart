import 'dart:async';
import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../models/level_data.dart';
import '../models/game_progression.dart';
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

    // Append market-purchased devices to the inventory pool
    progression.purchasedMarketDevices.forEach((type, count) {
      if (count <= 0) return;
      
      // Portals are bought/sold in pairs!
      if (type == DeviceType.portal) {
        for (int i = 0; i < count; i++) {
          final devId = "market_${type.name}_${idCounter++}";
          final pairIdString = "market_${type.name}_${idCounter++}";
          
          inventory.add(DeviceModel(
            id: devId,
            type: type,
            portalPairId: pairIdString,
            isPlaced: false,
          ));
          inventory.add(DeviceModel(
            id: pairIdString,
            type: type,
            portalPairId: devId,
            isPlaced: false,
          ));
        }
      } else if (type == DeviceType.splitter) {
        // Splitters in market are 180 degree by default
        for (int i = 0; i < count; i++) {
          inventory.add(DeviceModel(
            id: "market_${type.name}_${idCounter++}",
            type: type,
            splitAngleDegrees: 180.0,
            isPlaced: false,
          ));
        }
      } else {
        for (int i = 0; i < count; i++) {
          inventory.add(DeviceModel(
            id: "market_${type.name}_${idCounter++}",
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

  void _completeSimulation() {
    if (traceResult != null) {
      if (traceResult!.success) {
        playState = PlayState.victory;
        
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

  bool buyMarketDevice(DeviceType type) {
    if (!progression.unlockedDevices.contains(type)) return false;

    int cost = GameProgression.getDeviceMarketPrice(type);
    if (progression.credits >= cost) {
      progression.credits -= cost;
      progression.purchasedMarketDevices[type] = (progression.purchasedMarketDevices[type] ?? 0) + 1;
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
