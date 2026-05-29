import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:single_shot/screens/game_board_screen.dart';
import 'package:single_shot/game/game_controller.dart';
import 'package:single_shot/models/galaxy_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameBoardScreen UI & Interaction Tests', () {
    late GameController controller;
    bool wentToShop = false;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      controller = GameController();
      wentToShop = false;
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
      expect(energyShield.isDestructible, isFalse);
    });
  });
}
