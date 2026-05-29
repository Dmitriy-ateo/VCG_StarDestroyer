import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:single_shot/screens/game_board_screen.dart';
import 'package:single_shot/screens/galaxy_board_screen.dart';
import 'package:single_shot/game/game_controller.dart';
import 'package:single_shot/models/galaxy_model.dart';
import 'package:single_shot/models/level_data.dart';
import 'package:single_shot/models/device_model.dart';
import 'package:single_shot/models/game_progression.dart';
import 'package:single_shot/game/sector_generator.dart';
import 'package:single_shot/game/laser_calculator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameBoardScreen UI & Interaction Tests', () {
    late GameController controller;
    bool wentToShop = false;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      controller = GameController();
      wentToShop = false;
      GalaxyBoardScreen.sessionDailyQuestsMap = null;
      GalaxyBoardScreen.completedDailyCount = 0;
    });

    testWidgets('Toolbox button is always visible in editing mode even when inventory is empty', (WidgetTester tester) async {
      // Clear inventory to verify empty inventory state behavior
      controller.inventory.clear();
      expect(controller.inventory.isEmpty, isTrue);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameBoardScreen(
              controller: controller,
              onBackToMenu: () {},
              onGoToShop: () {
                wentToShop = true;
              },
              onGoToResearch: () {},
            ),
          ),
        ),
      );

      // Verify the construction toolbox toggle button icon is present
      final toolboxButton = find.byIcon(Icons.construction);
      expect(toolboxButton, findsOneWidget);

      // Tap the toolbox button to slide open the empty inventory drawer
      await tester.tap(toolboxButton);
      await tester.pump(); // Start the state transition and rebuild
      await tester.pump(const Duration(milliseconds: 350)); // Wait for slide-in animation to complete

      // Verify that the empty state "GO TO MARKET" button is shown
      final marketBtn = find.text("GO TO MARKET");
      expect(marketBtn, findsOneWidget);

      // Tap "GO TO MARKET" to verify the callback triggers properly
      await tester.tap(marketBtn);
      await tester.pump(); // Start rebuild to trigger callback and close drawer
      await tester.pump(const Duration(milliseconds: 350)); // Wait for animation

      expect(wentToShop, isTrue);
    });

    test('Quest 6 (The Quantum Paradox) has blocking walls at (3, 7) and (3, 8) to force portals', () {
      final quest6 = preloadedGalaxies.expand((g) => g.quests).firstWhere((q) => q.id == 'q6');
      controller.loadQuest(quest6);
      final walls = controller.currentLevel.walls;

      // Verify we have the crystal wall at (3, 8) requiring power 3
      final crystalWall = walls.firstWhere(
        (w) => w.gridX == 3 && w.gridY == 8,
      );
      expect(crystalWall.type, 'crystal');
      expect(crystalWall.requiredLaserPower, 3);
      expect(crystalWall.isDestructible, isFalse);

      // Verify we have the energy shield at (3, 7) requiring power 2
      final energyShield = walls.firstWhere(
        (w) => w.gridX == 3 && w.gridY == 7,
      );
      expect(energyShield.type, 'energyShield');
      expect(energyShield.requiredLaserPower, 2);
    });

    test('Campaign Level 6 (Portal Transit) has blocking walls at (5, 3), (5, 4), and (5, 5) to block direct hit exploit', () {
      final level6 = preloadedLevels.firstWhere((l) => l.id == 6);
      final walls = level6.walls;

      for (int y in [3, 4, 5]) {
        final wall = walls.firstWhere(
          (w) => w.gridX == 5 && w.gridY == y,
        );
        expect(wall.isDestructible, isFalse);
        expect(wall.requiredLaserPower, isNull);
      }
    });

    test('Campaign Level 7 (Double Portal Reflection) has blocking walls at (5, 5), (5, 6), and (5, 7) to block direct hit exploit', () {
      final level7 = preloadedLevels.firstWhere((l) => l.id == 7);
      final walls = level7.walls;

      for (int y in [5, 6, 7]) {
        final wall = walls.firstWhere(
          (w) => w.gridX == 5 && w.gridY == y,
        );
        expect(wall.isDestructible, isFalse);
        expect(wall.requiredLaserPower, isNull);
      }
    });

    test('Campaign Level 8 (Prismatic Gravity Sling) has blocking walls at (5, 6), (5, 7), and (5, 8) to block direct hit exploit', () {
      final level8 = preloadedLevels.firstWhere((l) => l.id == 8);
      final walls = level8.walls;

      for (int y in [5, 6, 7, 8]) {
        final wall = walls.firstWhere(
          (w) => w.gridX == 5 && w.gridY == y,
        );
        expect(wall.isDestructible, isFalse);
        expect(wall.requiredLaserPower, isNull);
      }
    });

    test('Campaign Level 9 has blocking walls at (4, 6) and (5, 6) to block direct hit to bomb', () {
      final walls = preloadedLevels.firstWhere((l) => l.id == 9).walls;
      expect(walls.any((w) => w.gridX == 4 && w.gridY == 6 && !w.isDestructible), isTrue);
      expect(walls.any((w) => w.gridX == 5 && w.gridY == 6 && !w.isDestructible), isTrue);
    });

    test('Campaign Level 11 has blocking walls at (4, 6), (4, 7), and (4, 8) to force gravity well loop', () {
      final walls = preloadedLevels.firstWhere((l) => l.id == 11).walls;
      for (int y in [6, 7, 8]) {
        expect(walls.any((w) => w.gridX == 4 && w.gridY == y && !w.isDestructible), isTrue);
      }
    });

    test('Campaign Level 12 has blocking walls at (1, 8) and (2, 8) to force right-side 3-reflector route', () {
      final walls = preloadedLevels.firstWhere((l) => l.id == 12).walls;
      expect(walls.any((w) => w.gridX == 1 && w.gridY == 8 && !w.isDestructible), isTrue);
      expect(walls.any((w) => w.gridX == 2 && w.gridY == 8 && !w.isDestructible), isTrue);
    });

    test('Campaign Level 13 has blocking walls at (2, 4) and (4, 4) to force bomb detonation chain', () {
      final walls = preloadedLevels.firstWhere((l) => l.id == 13).walls;
      expect(walls.any((w) => w.gridX == 2 && w.gridY == 4 && !w.isDestructible), isTrue);
      expect(walls.any((w) => w.gridX == 4 && w.gridY == 4 && !w.isDestructible), isTrue);
    });

    test('Campaign Level 14 has blocking walls at (5, 6), (5, 7), and (5, 8) to block direct hit to Yavin Base', () {
      final walls = preloadedLevels.firstWhere((l) => l.id == 14).walls;
      for (int y in [6, 7, 8]) {
        expect(walls.any((w) => w.gridX == 5 && w.gridY == y && !w.isDestructible), isTrue);
      }
    });

    test('Campaign Level 15 has blocking walls at (5, 4), (5, 5), and (5, 6) to block direct hit to Coruscant Rebel Core', () {
      final walls = preloadedLevels.firstWhere((l) => l.id == 15).walls;
      for (int y in [4, 5, 6]) {
        expect(walls.any((w) => w.gridX == 5 && w.gridY == y && !w.isDestructible), isTrue);
      }
    });

    testWidgets('GalaxyBoardScreen clamps completed daily count progress and renders at 9 completions', (WidgetTester tester) async {
      // Setup a custom controller
      final controller = GameController();
      
      // Inject a procedural daily quest into Galaxy 1
      final quest = QuestModel(
        id: 'daily_quest_test_1',
        title: 'Daily Sector: Dual Target Ray',
        description: 'Test Daily Quest',
        type: QuestType.daily,
        storyLoreSnippet: 'Stellar surge detected.',
        creditsReward: 300,
        rpReward: 50,
        levelData: preloadedLevels.first.clone(),
      );

      // Inject daily quests map & force completed count to 9
      GalaxyBoardScreen.sessionDailyQuestsMap = {
        'galaxy_1': [quest],
      };
      GalaxyBoardScreen.completedDailyCount = 9;

      // Pump GalaxyBoardScreen
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GalaxyBoardScreen(
              controller: controller,
              galaxyId: 'galaxy_1',
              onQuestSelected: (q) {},
              onBackToMap: () {},
              onGoToShop: () {},
              onGoToResearch: () {},
            ),
          ),
        ),
      );

      // Find the daily quest node/text in the star-map list
      final questNode = find.text("DUAL TARGET RAY");
      expect(questNode, findsOneWidget);

      // Tap on the daily quest node to show the briefing details modal
      await tester.tap(questNode, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300)); // Wait for dialog slide-in / selection state

      // Assert that progress text renders as "9 / 10 DONE"
      expect(find.text("9 / 10 DONE"), findsOneWidget);

      // Assert that LinearProgressIndicator value is 0.9 (90% full)
      final progressIndicatorFinder = find.byType(LinearProgressIndicator);
      expect(progressIndicatorFinder, findsOneWidget);
      final LinearProgressIndicator progressIndicator = tester.widget(progressIndicatorFinder);
      expect(progressIndicator.value, 0.9);
    });

    testWidgets('GalaxyBoardScreen daily missions disappear completely when completed count is 10 or greater', (WidgetTester tester) async {
      // Setup a custom controller
      final controller = GameController();
      
      // Inject a procedural daily quest into Galaxy 1
      final quest = QuestModel(
        id: 'daily_quest_test_1',
        title: 'Daily Sector: Dual Target Ray',
        description: 'Test Daily Quest',
        type: QuestType.daily,
        storyLoreSnippet: 'Stellar surge detected.',
        creditsReward: 300,
        rpReward: 50,
        levelData: preloadedLevels.first.clone(),
      );

      // Inject daily quests map & force completed count to 10
      GalaxyBoardScreen.sessionDailyQuestsMap = {
        'galaxy_1': [quest],
      };
      GalaxyBoardScreen.completedDailyCount = 10;

      // Pump GalaxyBoardScreen
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GalaxyBoardScreen(
              controller: controller,
              galaxyId: 'galaxy_1',
              onQuestSelected: (q) {},
              onBackToMap: () {},
              onGoToShop: () {},
              onGoToResearch: () {},
            ),
          ),
        ),
      );

      // Daily quest should NOT be rendered on screen (should disappear completely)
      final questNode = find.text("DUAL TARGET RAY");
      expect(questNode, findsNothing);
    });

    testWidgets('Long-pressing a placed device triggers Holographic Radial HUD and RECLAIM removes it', (WidgetTester tester) async {
      final controller = GameController();
      controller.loadLevel(1);
      
      // Inject a placed device at (2, 2)
      final device = DeviceModel(
        id: 'test_reflector',
        type: DeviceType.reflector,
        gridX: 2,
        gridY: 2,
        isPlaced: true,
        splitAngleDegrees: null,
      );
      controller.placedDevices.add(device);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameBoardScreen(
              controller: controller,
              onBackToMenu: () {},
              onGoToShop: () {},
              onGoToResearch: () {},
            ),
          ),
        ),
      );

      // Verify the device exists in controller
      expect(controller.placedDevices.length, 1);

      // Verify HUD starts closed (no ROTATE/RECLAIM buttons visible)
      expect(find.text("ROTATE"), findsNothing);
      expect(find.text("RECLAIM"), findsNothing);

      // Long press on the board coordinates corresponding to (2, 2)
      // We trigger the onLongPressStart callback directly on the GestureDetector for absolute test stability
      final gestureFinder = find.byWidgetPredicate(
        (widget) => widget is GestureDetector && widget.onLongPressStart != null,
      );
      expect(gestureFinder, findsOneWidget);
      final gestureDetector = tester.widget<GestureDetector>(gestureFinder);
      gestureDetector.onLongPressStart!(
        LongPressStartDetails(
          localPosition: const Offset(343.5, 94.16),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200)); // wait for scale/fade animation

      // Verify that the Holographic Capsule is now visible with ROTATE and RECLAIM
      expect(find.text("ROTATE"), findsOneWidget);
      expect(find.text("RECLAIM"), findsOneWidget);

      // Tap on ROTATE to verify it rotates the device
      final initialAngle = device.angleDegrees;
      await tester.tap(find.text("ROTATE"));
      await tester.pump();

      // Device angle should have changed
      expect(device.angleDegrees, isNot(initialAngle));

      // Tap on RECLAIM to verify it removes the device and closes the HUD
      await tester.tap(find.text("RECLAIM"));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200)); // Wait for exit animation

      // Placed devices list should now be empty
      expect(controller.placedDevices.isEmpty, isTrue);

      // HUD should be closed
      expect(find.text("ROTATE"), findsNothing);
      expect(find.text("RECLAIM"), findsNothing);
    });

    testWidgets('GalaxyBoardScreen initializes and refuels exactly 7 side quests in Galaxy 1', (WidgetTester tester) async {
      final controller = GameController();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GalaxyBoardScreen(
              controller: controller,
              galaxyId: 'galaxy_1',
              onQuestSelected: (q) {},
              onBackToMap: () {},
              onGoToShop: () {},
              onGoToResearch: () {},
            ),
          ),
        ),
      );
      
      // Verify that exactly 7 active side quest planets are rendered on Orbit 2 (represented by Icons.assignment)
      expect(find.byIcon(Icons.assignment), findsNWidgets(7));
    });

    test('Galaxy 4 side quest has planet targets with shield level 4', () {
      final progression = GameProgression(unlockedDevices: {
        DeviceType.reflector,
        DeviceType.splitter,
        DeviceType.bomb,
        DeviceType.portal,
        DeviceType.gravityWell,
      });

      // Generate multiple sectors to cover all possible templates
      for (int i = 0; i < 50; i++) {
        final level = SectorGenerator.generateDailySector(progression, 'galaxy_4');
        for (final planet in level.planets) {
          expect(planet.requiredLaserPower, equals(4));
        }
      }
    });

    test('Galaxy 5 side quest generates higher clutter wall counts than Galaxy 1', () {
      final progression = GameProgression(unlockedDevices: {
        DeviceType.reflector,
        DeviceType.splitter,
        DeviceType.bomb,
        DeviceType.portal,
        DeviceType.gravityWell,
      });

      double totalWallsG1 = 0;
      double totalWallsG5 = 0;
      const samples = 100;
      for (int i = 0; i < samples; i++) {
        final levelG1 = SectorGenerator.generateDailySector(progression, 'galaxy_1');
        final levelG5 = SectorGenerator.generateDailySector(progression, 'galaxy_5');
        totalWallsG1 += levelG1.walls.length;
        totalWallsG5 += levelG5.walls.length;
      }
      final avgG1 = totalWallsG1 / samples;
      final avgG5 = totalWallsG5 / samples;
      
      // Galaxy 5 clutter density is strictly and significantly higher than Galaxy 1
      expect(avgG5, greaterThan(avgG1 + 3.0));
    });

    test('LaserCalculator.traceLaser correctly deflects a laser beam hit on floatingAsteroid', () {
      final level = LevelData(
        id: 100,
        name: 'Asteroid Test',
        description: 'Test asteroid deflection',
        deathStarX: 2,
        deathStarY: 8,
        deathStarInitialAngle: 0.0, // Fires horizontally rightwards
        planets: [
          PlanetTarget(
            id: 'p1',
            gridX: 4,
            gridY: 4, // Target is above the deflection path
            radius: 15.0,
            name: 'Target Planet',
            color: Colors.blue,
          ),
        ],
        walls: [],
        availableInventory: [],
      );

      // Place a floating asteroid at (4, 8) with deflection angle -90 degrees (deflecting up)
      final asteroid = DeviceModel(
        id: 'ast1',
        type: DeviceType.floatingAsteroid,
        gridX: 4,
        gridY: 8,
        angleDegrees: -90.0,
        isPlaced: true,
      );

      final result = LaserCalculator.traceLaser(
        level: level,
        devices: [asteroid],
        startAngleDegrees: 0.0,
        laserIntensity: 5,
        deviceLevels: {
          DeviceType.floatingAsteroid: 1,
        },
      );

      // The asteroid triggers an explosion
      final explosion = result.explosions.firstWhere((e) => e.targetId == 'ast1');
      expect(explosion.isBomb, isTrue);

      // The path should have deflected upwards (decreasing Y coordinate)
      expect(result.paths, isNotEmpty);
      final mainPath = result.paths.first;
      expect(mainPath.length, greaterThanOrEqualTo(2));
      
      final lastPoint = mainPath.last;
      expect((lastPoint.dx - 4.5).abs(), lessThan(0.1));
      expect(lastPoint.dy, lessThan(8.5));
    });

    test('Galaxy 7 (Asteroid Frontier) and its levels are successfully parsed and loaded', () {
      final galaxy7 = preloadedGalaxies.firstWhere((g) => g.id == 'galaxy_7');
      expect(galaxy7.name, equals('Asteroid Frontier'));
      expect(galaxy7.quests.length, equals(2));

      final q19 = galaxy7.quests.firstWhere((q) => q.id == 'q19');
      expect(q19.title, equals('Drifting Vectors'));
      expect(q19.levelData.id, equals(19));

      // Verify it loads in GameController
      final controller = GameController();
      controller.loadQuest(q19);
      expect(controller.currentLevel.id, equals(19));
      expect(controller.currentLevel.name, equals('Drifting Vectors'));

      // Check available inventory contains floatingAsteroid
      final hasAsteroid = controller.currentLevel.availableInventory.any((d) => d.type == DeviceType.floatingAsteroid);
      expect(hasAsteroid, isTrue);
    });

    test('Deflector Sub-Chassis capacity limit restricts placing all device types based on progression level', () {
      final controller = GameController();
      controller.progression.chassisRanks['chassis'] = 'F';
      controller.progression.chassisStars['chassis'] = 0; // level = 1, capacity = 1 + 1 = 2
      
      // Clear placed devices
      controller.placedDevices.clear();
      
      // Inject different devices into inventory
      final ref1 = DeviceModel(id: 'ref_t1', type: DeviceType.reflector);
      final split = DeviceModel(id: 'split_t1', type: DeviceType.splitter, splitAngleDegrees: 180.0);
      final bomb = DeviceModel(id: 'bomb_t1', type: DeviceType.bomb);
      
      // Place reflector (should succeed)
      controller.selectedInventoryDevice = ref1;
      bool placed1 = controller.placeDevice(2, 2);
      expect(placed1, isTrue);
      expect(controller.placedDevices.length, 1);
      
      // Place splitter (should succeed, meets max capacity of 2)
      controller.selectedInventoryDevice = split;
      bool placed2 = controller.placeDevice(3, 3);
      expect(placed2, isTrue);
      expect(controller.placedDevices.length, 2);
      
      // Place bomb (should fail, exceeds capacity of 2)
      controller.selectedInventoryDevice = bomb;
      bool placed3 = controller.placeDevice(4, 4);
      expect(placed3, isFalse);
      expect(controller.placedDevices.length, 2);
      
      // Upgrade Deflector Sub-Chassis to Level 2 (F, 1 Star) -> capacity = 3
      controller.progression.chassisStars['chassis'] = 1;
      expect(controller.progression.chassisCapacityLevel, 2);
      
      // Place bomb (should now succeed!)
      bool placed3AfterUpgrade = controller.placeDevice(4, 4);
      expect(placed3AfterUpgrade, isTrue);
      expect(controller.placedDevices.length, 3);
    });
  });
}
