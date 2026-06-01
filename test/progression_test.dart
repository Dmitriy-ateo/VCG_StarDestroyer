import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:single_shot/models/game_progression.dart';
import 'package:single_shot/models/device_model.dart';
import 'package:single_shot/game/game_controller.dart';
import 'package:single_shot/models/galaxy_model.dart';
import 'package:single_shot/game/sector_generator.dart';
import 'package:single_shot/game/laser_calculator.dart';
import 'package:single_shot/models/level_data.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  group('GameProgression & Upgrades RPG System Tests', () {
    test('Default constructor sets starting ranks, stars, and sub-levels', () {
      final progression = GameProgression();

      // Verify Chassis
      expect(progression.chassisRanks['intensity'], 'F');
      expect(progression.chassisStars['intensity'], 0);
      expect(progression.chassisSubLevels['intensity'], 1);
      expect(progression.laserIntensityLevel, 1); // Rank F -> level 1

      // Verify Devices
      expect(progression.deviceRanks[DeviceType.reflector], 'F');
      expect(progression.deviceStars[DeviceType.reflector], 0);
      expect(progression.deviceSubLevels[DeviceType.reflector], 1);
      expect(progression.deviceLevels[DeviceType.reflector], 1); // Rank F -> level 1
    });

    test('Chassis cost scaling math matches geometric curves and linear caps', () {
      // Base cost check: Rank F, 0 Stars, sub-level 1
      // cumulative level = 0
      // 80 * 1.08^0 = 80
      expect(GameProgression.getChassisUpgradeCost('F', 0, 1), 80);

      // SSS Maxed-out state returns -1
      expect(GameProgression.getChassisUpgradeCost('SSS', 3, 5), -1);

      // Verify dynamic scaling works
      final cost1 = GameProgression.getChassisUpgradeCost('F', 0, 2); // cumulative level = 1
      expect(cost1, greaterThan(80));

      // Check linear cap threshold (> 1500)
      // Rank B (index 4) -> cumulative level >= 80.
      // B, 0 stars, lvl 1 -> cumulative level = 80
      final highCost = GameProgression.getChassisUpgradeCost('B', 0, 1);
      expect(highCost, greaterThan(1500));
      // Formula at > 1500: 1500 + (cumulativeLevel - 35) * 15
      // 1500 + (80 - 35) * 15 = 1500 + 45 * 15 = 1500 + 675 = 2175
      expect(highCost, 2175);
    });

    test('Device cost scaling math matches geometric curves and linear caps', () {
      // Base cost check: Rank F, 0 Stars, sub-level 1
      // cumulative level = 0
      // 30 * 1.10^0 = 30
      expect(GameProgression.getDeviceUpgradeCost('F', 0, 1), 30);

      // SSS Maxed-out state returns -1
      expect(GameProgression.getDeviceUpgradeCost('SSS', 3, 5), -1);

      // Check linear cap threshold (> 1200)
      // Rank B (index 4), cumulative level = 80
      final highCost = GameProgression.getDeviceUpgradeCost('B', 0, 1);
      expect(highCost, greaterThan(1200));
      // Formula at > 1200: 1200 + (cumulativeLevel - 38) * 20
      // 1200 + (80 - 38) * 20 = 1200 + 42 * 20 = 1200 + 840 = 2040
      expect(highCost, 2040);
    });

    test('buyUpgrade correctly increments sub-levels, wraps to stars and ranks, and deducts credits', () {
      final controller = GameController();
      final progression = controller.progression;
      progression.credits = 5000;

      // First upgrade: costs 80 credits
      final success = controller.buyUpgrade('intensity');
      expect(success, isTrue);
      expect(progression.credits, 5000 - 80);
      expect(progression.chassisSubLevels['intensity'], 2);
      expect(progression.chassisStars['intensity'], 0);
      expect(progression.chassisRanks['intensity'], 'F');

      // Set sub-level to 5 and purchase to wrap to next star (1-star)
      progression.chassisSubLevels['intensity'] = 5;
      final costBeforeWrap = GameProgression.getChassisUpgradeCost('F', 0, 5);
      final creditsBefore = progression.credits;
      final successWrapStar = controller.buyUpgrade('intensity');
      expect(successWrapStar, isTrue);
      expect(progression.credits, creditsBefore - costBeforeWrap);
      expect(progression.chassisSubLevels['intensity'], 1);
      expect(progression.chassisStars['intensity'], 1);
      expect(progression.chassisRanks['intensity'], 'F');

      // Set stars to 3 and sub-level to 5 to wrap to next Rank (E)
      progression.chassisStars['intensity'] = 3;
      progression.chassisSubLevels['intensity'] = 5;
      final successWrapRank = controller.buyUpgrade('intensity');
      expect(successWrapRank, isTrue);
      expect(progression.chassisSubLevels['intensity'], 1);
      expect(progression.chassisStars['intensity'], 0);
      expect(progression.chassisRanks['intensity'], 'E');
      expect(controller.progression.laserIntensityLevel, 5); // E rank maps to level 5
    });

    test('upgradeDevice correctly increments sub-levels, wraps to stars/ranks, and deducts RP', () {
      final controller = GameController();
      final progression = controller.progression;
      progression.researchPoints = 5000;

      // Base device reflector is already unlocked
      final success = controller.upgradeDevice(DeviceType.reflector);
      expect(success, isTrue);
      expect(progression.researchPoints, 5000 - 30);
      expect(progression.deviceSubLevels[DeviceType.reflector], 2);
      expect(progression.deviceStars[DeviceType.reflector], 0);
      expect(progression.deviceRanks[DeviceType.reflector], 'F');

      // Set sub-level to 5 to wrap star
      progression.deviceSubLevels[DeviceType.reflector] = 5;
      final costBeforeWrap = GameProgression.getDeviceUpgradeCost('F', 0, 5);
      final rpBefore = progression.researchPoints;
      final successWrapStar = controller.upgradeDevice(DeviceType.reflector);
      expect(successWrapStar, isTrue);
      expect(progression.researchPoints, rpBefore - costBeforeWrap);
      expect(progression.deviceSubLevels[DeviceType.reflector], 1);
      expect(progression.deviceStars[DeviceType.reflector], 1);

      // Set stars to 3 and sub-level to 5 to wrap rank to E
      progression.deviceStars[DeviceType.reflector] = 3;
      progression.deviceSubLevels[DeviceType.reflector] = 5;
      final successWrapRank = controller.upgradeDevice(DeviceType.reflector);
      expect(successWrapRank, isTrue);
      expect(progression.deviceSubLevels[DeviceType.reflector], 1);
      expect(progression.deviceStars[DeviceType.reflector], 0);
      expect(progression.deviceRanks[DeviceType.reflector], 'E');
      expect(progression.deviceLevels[DeviceType.reflector], 5); // E rank maps to level 5
    });

    test('Galaxy model checks unlocks based on F-to-SSS rank and star scores', () {
      final progression = GameProgression();
      
      final g1 = preloadedGalaxies.firstWhere((g) => g.id == 'galaxy_1');
      final g2 = preloadedGalaxies.firstWhere((g) => g.id == 'galaxy_2');
      final g3 = preloadedGalaxies.firstWhere((g) => g.id == 'galaxy_3');

      // Galaxy 1 is unlocked by default
      expect(g1.checkUnlockStatus(progression), isTrue);

      // Galaxy 2 requires Laser Intensity Rank F ★ (score >= 1)
      // Default: intensity Rank F, 0 Stars (score = 0). Should be locked.
      expect(g2.checkUnlockStatus(progression), isFalse);

      // Upgrade intensity to Rank F ★ (1 Star)
      progression.chassisStars['intensity'] = 1;
      // Also complete Galaxy 1 prereq
      progression.completedGalaxyIds.add('galaxy_1');
      expect(g2.checkUnlockStatus(progression), isTrue);

      // Galaxy 3 requires:
      // Laser Intensity Rank F ★★ (stars >= 2)
      // Aiming Computer Rank F ★ (stars >= 1)
      // Unlocked blueprint 'portal'
      // Completed galaxy_2
      expect(g3.checkUnlockStatus(progression), isFalse);

      progression.chassisStars['intensity'] = 2; // Rank F ★★
      progression.chassisStars['aiming'] = 1; // Rank F ★
      progression.unlockedDevices.add(DeviceType.portal); // Researched portals
      progression.completedGalaxyIds.add('galaxy_2'); // Completed galaxy_2

      expect(g3.checkUnlockStatus(progression), isTrue);

      // Galaxy 4 requires:
      // Laser Intensity Rank F ★★★ (stars >= 3)
      // Aiming Computer Rank F ★★ (stars >= 2)
      // Unlocked blueprint 'gravityWell'
      // Completed galaxy_3
      final g4 = preloadedGalaxies.firstWhere((g) => g.id == 'galaxy_4');
      expect(g4.checkUnlockStatus(progression), isFalse);

      progression.chassisStars['intensity'] = 3; // Rank F ★★★
      progression.chassisStars['aiming'] = 2; // Rank F ★★
      progression.unlockedDevices.add(DeviceType.gravityWell); // Researched gravity wells
      progression.completedGalaxyIds.add('galaxy_3'); // Completed galaxy_3

      expect(g4.checkUnlockStatus(progression), isTrue);

      // Galaxy 5 requires:
      // Laser Intensity Rank F ★★★★ (stars >= 4)
      // Aiming Computer Rank F ★★★ (stars >= 3)
      // Unlocked blueprint 'bomb'
      // Completed galaxy_4
      final g5 = preloadedGalaxies.firstWhere((g) => g.id == 'galaxy_5');
      expect(g5.checkUnlockStatus(progression), isFalse);

      progression.chassisStars['intensity'] = 4; // Rank F ★★★★
      progression.chassisStars['aiming'] = 3; // Rank F ★★★
      progression.unlockedDevices.add(DeviceType.bomb); // Researched bombs
      progression.completedGalaxyIds.add('galaxy_4'); // Completed galaxy_4
      expect(g5.checkUnlockStatus(progression), isTrue);

      // Galaxy 6 requires:
      // Laser Intensity Rank E (Rank E, stars >= 0)
      // Aiming Computer Rank F ★★★★ (stars >= 4)
      // Unlocked blueprint 'splitter'
      // Completed galaxy_5
      final g6 = preloadedGalaxies.firstWhere((g) => g.id == 'galaxy_6');
      expect(g6.checkUnlockStatus(progression), isFalse);

      progression.chassisRanks['intensity'] = 'E';
      progression.chassisStars['intensity'] = 0; // Cumulative Laser Intensity Score 4 (E rank maps to 4)
      progression.chassisStars['aiming'] = 4; // Rank F ★★★★
      progression.unlockedDevices.add(DeviceType.splitter); // Researched splitters
      progression.completedGalaxyIds.add('galaxy_5'); // Completed galaxy_5
      expect(g6.checkUnlockStatus(progression), isTrue);
    });

    test('Daily Hard Mission rollover, generation, boost and reward payout test', () {
      final controller = GameController();
      final progression = controller.progression;
      
      // Initially empty
      expect(progression.dailyHardGalaxyId, isNull);
      expect(progression.dailyHardQuestId, isNull);

      // Roll over with unlocked galaxies list containing only galaxy_1
      progression.checkAndRollOverDailyHard(['galaxy_1']);
      expect(progression.dailyHardGalaxyId, isNull);
      expect(progression.dailyHardQuestId, isNull);

      // Roll over with unlocked galaxies list containing galaxy_1, galaxy_2, and galaxy_3
      // Reset dailyHardDateStr so rollover triggers again
      progression.dailyHardDateStr = null;
      progression.checkAndRollOverDailyHard(['galaxy_1', 'galaxy_2', 'galaxy_3']);
      expect(progression.dailyHardGalaxyId, 'galaxy_3'); // Excludes galaxy_1 & galaxy_2, picks galaxy_3
      expect(progression.dailyHardQuestId, contains('daily_hard_quest_galaxy_3_'));
      expect(progression.dailyHardCompleted, isFalse);

      // Verify sector generation configures rewards, required inventory and isInvader flags correctly
      // We use 'galaxy_1' deterministically to avoid random test flakes with galaxy_2 planet defense values
      final hardLevel = SectorGenerator.generateDailyHardSector(progression, 'galaxy_1');
      expect(hardLevel.creditsReward, 500);
      expect(hardLevel.researchPointsReward, 150);
      expect(hardLevel.planets.every((p) => p.isInvader), isTrue);

      // Ensure we use the rolled over galaxy and quest ID
      progression.dailyHardGalaxyId = 'galaxy_2';
      progression.dailyHardQuestId = 'daily_hard_quest_galaxy_2_test';
      progression.dailyHardCompleted = false;

      // Galaxy 2 has level 4 as a standard level. Let's load level 4.
      controller.loadLevel(4);
      // Let's verify standard level 4 target has received the +1 boost (requiredLaserPower goes from 1/null to 2)
      for (var planet in controller.currentLevel.planets) {
        expect(planet.requiredLaserPower, 2);
      }

      // Now load a Daily Hard Level (e.g. ID 991). Daily Hard levels should NOT receive the boost!
      final hardQuest = QuestModel(
        id: progression.dailyHardQuestId!,
        title: "Test Daily Hard",
        description: "Test",
        type: QuestType.daily,
        storyLoreSnippet: "Test Snippet",
        creditsReward: 500,
        rpReward: 150,
        levelData: hardLevel, // hardLevel has ID 991
      );

      controller.loadQuest(hardQuest);
      // Hard level planets should NOT be boosted (should stay at their original requiredLaserPower value of 2)
      for (var planet in controller.currentLevel.planets) {
        expect(planet.requiredLaserPower, 2);
      }

      // Test successful quest completion payout
      final initialCredits = progression.credits;
      final initialRP = progression.researchPoints;
      
      // Simulate successful simulation completion by mocking traceResult and calling completeSimulation()
      controller.traceResult = LaserTraceResult(
        paths: [],
        hitPlanetIds: {},
        explosions: [],
        audioTriggers: const [],
        success: true,
      );
      
      // Complete simulation
      controller.completeSimulation();
      
      // Verify Daily Hard quest rewards were credited and state marked completed
      expect(progression.dailyHardCompleted, isTrue);
      expect(progression.credits, initialCredits + 500);
      expect(progression.researchPoints, initialRP + 150);
    });

    test('SectorGenerator prevents direct hits for advanced galaxies (Galaxy 2+)', () {
      final progression = GameProgression();
      // Unlock all tools to allow all templates to be generated
      progression.unlockedDevices.addAll([
        DeviceType.reflector,
        DeviceType.splitter,
        DeviceType.bomb,
        DeviceType.portal,
        DeviceType.gravityWell,
      ]);

      // Helper to check if a direct path is unblocked
      bool isDirectPathUnblocked(LevelData level, PlanetTarget planet) {
        final startX = level.deathStarX + 0.5;
        final startY = level.deathStarY + 0.5;
        final targetX = planet.gridX + 0.5;
        final targetY = planet.gridY + 0.5;

        final dx = targetX - startX;
        final dy = targetY - startY;
        final distance = sqrt(dx * dx + dy * dy);
        if (distance == 0) return false;

        final stepX = dx / distance;
        final stepY = dy / distance;

        final Set<String> wallCoords = level.walls.map((w) => "${w.gridX},${w.gridY}").toSet();

        final steps = (distance * 10).toInt();
        for (int i = 1; i < steps; i++) {
          final currentX = startX + stepX * (i * 0.1);
          final currentY = startY + stepY * (i * 0.1);

          final cellX = currentX.floor();
          final cellY = currentY.floor();

          if (cellX == planet.gridX && cellY == planet.gridY) {
            return true;
          }
          if (cellX < 0 || cellX >= 8 || cellY < 0 || cellY >= 12) {
            return false;
          }

          if (wallCoords.contains("$cellX,$cellY")) {
            return false;
          }
        }
        return true;
      }

      // Test 1: Daily Sector Generation (Galaxy 3 is 100% blocked, Galaxy 2 has low direct hits)
      int g2DirectHits = 0;
      for (int i = 0; i < 50; i++) {
        final levelG2 = SectorGenerator.generateDailySector(progression, 'galaxy_2');
        for (var planet in levelG2.planets) {
          if (isDirectPathUnblocked(levelG2, planet)) {
            g2DirectHits++;
          }
        }

        final levelG3 = SectorGenerator.generateDailySector(progression, 'galaxy_3');
        for (var planet in levelG3.planets) {
          expect(isDirectPathUnblocked(levelG3, planet), isFalse,
              reason: "Daily Galaxy 3 level ${levelG3.name} allows direct hit on planet ${planet.name} at (${planet.gridX}, ${planet.gridY})!");
        }
      }
      expect(g2DirectHits, lessThan(25), 
          reason: "Galaxy 2 daily sectors should have low direct hit rates (12% per sector spec, got $g2DirectHits direct hits out of 50 runs)");

      // Test 2: Daily Hard Sector Generation (Galaxy 2 and Galaxy 3)
      final hardG2 = SectorGenerator.generateDailyHardSector(progression, 'galaxy_2');
      for (var planet in hardG2.planets) {
        expect(isDirectPathUnblocked(hardG2, planet), isFalse,
            reason: "Hard Galaxy 2 level allows direct hit on planet ${planet.name}!");
      }

      final hardG3 = SectorGenerator.generateDailyHardSector(progression, 'galaxy_3');
      for (var planet in hardG3.planets) {
        expect(isDirectPathUnblocked(hardG3, planet), isFalse,
            reason: "Hard Galaxy 3 level allows direct hit on planet ${planet.name}!");
      }
    });

    test('Progressive Campaign locks and breakthroughs unlock correct recipes', () {
      final progression = GameProgression();

      // Fresh state: only reflector and intensity unlocked
      expect(progression.isDeviceRecipeUnlocked(DeviceType.reflector), isTrue);
      expect(progression.isDeviceRecipeUnlocked(DeviceType.splitter), isFalse);
      expect(progression.isDeviceRecipeUnlocked(DeviceType.bomb), isFalse);
      expect(progression.isDeviceRecipeUnlocked(DeviceType.gravityWell), isFalse);
      expect(progression.isDeviceRecipeUnlocked(DeviceType.portal), isFalse);
      expect(progression.isDeviceRecipeUnlocked(DeviceType.floatingAsteroid), isFalse);

      expect(progression.isSplitterAngleUnlocked(180.0), isFalse);
      expect(progression.isSplitterAngleUnlocked(90.0), isFalse);

      expect(progression.isSubsystemUnlocked('intensity'), isTrue);
      expect(progression.isSubsystemUnlocked('aiming'), isFalse);
      expect(progression.isSubsystemUnlocked('chassis'), isFalse);

      // Clear Galaxy 1 Lore Quest (q3)
      progression.completedQuestIds.add('q3');
      expect(progression.isDeviceRecipeUnlocked(DeviceType.splitter), isTrue);
      expect(progression.isSplitterAngleUnlocked(180.0), isTrue);
      expect(progression.isSplitterAngleUnlocked(90.0), isFalse); // Variations still locked
      expect(progression.isSubsystemUnlocked('chassis'), isTrue); // Deflector chassis unlocked!

      // Clear Galaxy 2 Lore Quest (q5)
      progression.completedQuestIds.add('q5');
      expect(progression.isSplitterAngleUnlocked(90.0), isTrue);
      expect(progression.isSplitterAngleUnlocked(135.0), isTrue);
      expect(progression.isSplitterAngleUnlocked(45.0), isTrue);
      expect(progression.isSubsystemUnlocked('aiming'), isTrue); // Aiming computer unlocked!

      // Clear subsequent lore quests
      progression.completedQuestIds.add('q6'); // Galaxy 3 Lore
      expect(progression.isDeviceRecipeUnlocked(DeviceType.bomb), isTrue);

      progression.completedQuestIds.add('q7'); // Galaxy 4 Lore
      expect(progression.isDeviceRecipeUnlocked(DeviceType.gravityWell), isTrue);

      progression.completedQuestIds.add('q8'); // Galaxy 5 Lore
      expect(progression.isDeviceRecipeUnlocked(DeviceType.portal), isTrue);

      progression.completedQuestIds.add('q9'); // Galaxy 6 Lore
      expect(progression.isDeviceRecipeUnlocked(DeviceType.floatingAsteroid), isTrue);
    });
  });
}
