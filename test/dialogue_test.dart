import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:single_shot/config/lore_dialogue.dart';
import 'package:single_shot/widgets/dialogue_avatar.dart';
import 'package:single_shot/widgets/dialogue_overlay.dart';
import 'package:single_shot/screens/game_board_screen.dart';
import 'package:single_shot/game/game_controller.dart';
import 'package:single_shot/models/galaxy_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Cyberpunk Dialogue System Models & Config Tests', () {
    test('LoreDialogueConfig defines valid pre- and post-mission sequences for lore quests', () {
      expect(LoreDialogueConfig.preMissionDialogues.containsKey('q1'), isTrue);
      expect(LoreDialogueConfig.preMissionDialogues.containsKey('q2'), isTrue);
      expect(LoreDialogueConfig.preMissionDialogues.containsKey('q4'), isTrue);
      expect(LoreDialogueConfig.preMissionDialogues.containsKey('q6'), isTrue);

      expect(LoreDialogueConfig.postMissionDialogues.containsKey('q1'), isTrue);
      expect(LoreDialogueConfig.postMissionDialogues.containsKey('q2'), isTrue);
      expect(LoreDialogueConfig.postMissionDialogues.containsKey('q4'), isTrue);
      expect(LoreDialogueConfig.postMissionDialogues.containsKey('q6'), isTrue);

      final q1Pre = LoreDialogueConfig.preMissionDialogues['q1']!;
      expect(q1Pre.first.speaker, Character.dax);
      expect(q1Pre.first.emotion, Emotion.calm);
      expect(q1Pre.first.isLeft, isTrue);
    });
  });

  group('DialogueAvatar Render Tests', () {
    testWidgets('DialogueAvatar draws premium vector silhouettes for all characters and emotions', (WidgetTester tester) async {
      for (final char in Character.values) {
        for (final emo in Emotion.values) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: DialogueAvatar(
                    character: char,
                    emotion: emo,
                  ),
                ),
              ),
            ),
          );

          expect(find.byType(DialogueAvatar), findsOneWidget);
          expect(find.byType(CustomPaint), findsWidgets);
        }
      }
    });
  });

  group('DialogueOverlay Interaction & Typewriter Tests', () {
    final testSequence = [
      const DialogueNode(
        speaker: Character.dax,
        emotion: Emotion.calm,
        text: "Dreadnought stealth engines online.",
        isLeft: true,
      ),
      const DialogueNode(
        speaker: Character.vance,
        emotion: Emotion.angry,
        text: "Sterling! You are surrounded!",
        isLeft: false,
      ),
    ];

    testWidgets('DialogueOverlay types text and progresses sequence on tap', (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DialogueOverlay(
              dialogueSequence: testSequence,
              onComplete: () {
                completed = true;
              },
            ),
          ),
        ),
      );

      // Verify comlink overlay header text exists
      expect(find.text("SECURE FREQUENCY ESTABLISHED // COMLINK HUD"), findsOneWidget);

      // Verify first node details exist
      expect(find.text("Capt. Dax Sterling // Rebel Dreadnought".toUpperCase()), findsOneWidget);

      // Initially, typewriter has just started. Let's pump time to finish typing
      await tester.pump(const Duration(milliseconds: 1000));

      // Text should be fully typed out now
      expect(find.text("Dreadnought stealth engines online."), findsOneWidget);

      // Tap card or comlink to advance dialogue to next node
      await tester.tap(find.text("Dreadnought stealth engines online."));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100)); // Start typing next

      // Verify second speaker is active
      expect(find.text("Grand Moff Vance // Imperial Fleet Cmd".toUpperCase()), findsOneWidget);

      // Wait for second text to finish typing
      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.text("Sterling! You are surrounded!"), findsOneWidget);

      // Tapping again finishes sequence and calls onComplete
      await tester.tap(find.text("Sterling! You are surrounded!"));
      await tester.pump();

      expect(completed, isTrue);
    });

    testWidgets('Tapping while typing skips typewriter typing and displays full text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DialogueOverlay(
              dialogueSequence: testSequence,
              onComplete: () {},
            ),
          ),
        ),
      );

      // Pump briefly (not long enough to finish the typewriter)
      await tester.pump(const Duration(milliseconds: 40));

      // Text should be incomplete
      expect(find.text("Dreadnought stealth engines online."), findsNothing);

      // Tap the card to skip typewriter animation
      await tester.tap(find.textContaining("TRANSMISSION NODE"));
      await tester.pump();

      // Text should immediately be completed
      expect(find.text("Dreadnought stealth engines online."), findsOneWidget);
    });

    testWidgets('Skip dialogue button triggers onComplete immediately', (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DialogueOverlay(
              dialogueSequence: testSequence,
              onComplete: () {
                completed = true;
              },
            ),
          ),
        ),
      );

      // Tap skip button
      final skipBtn = find.text("SKIP DIALOGUE");
      expect(skipBtn, findsOneWidget);
      await tester.tap(skipBtn);
      await tester.pump();

      expect(completed, isTrue);
    });
  });

  group('GameBoardScreen Dialogue Integration Tests', () {
    late GameController controller;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      controller = GameController();
    });

    testWidgets('Pre-mission dialogue is shown automatically on entering Quest 1', (WidgetTester tester) async {
      // Find quest 1 from preloaded campaign
      final q1 = preloadedGalaxies.expand((g) => g.quests).firstWhere((q) => q.id == 'q1');
      controller.loadQuest(q1);

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

      // The pre-mission DialogueOverlay should be displayed on screen
      expect(find.byType(DialogueOverlay), findsOneWidget);
      expect(find.text("SKIP DIALOGUE"), findsOneWidget);
      
      // Tapping "SKIP DIALOGUE" removes the pre-mission overlay
      await tester.tap(find.text("SKIP DIALOGUE"));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Overlay should be gone and game board should be visible
      expect(find.byType(DialogueOverlay), findsNothing);
    });

    testWidgets('Pre-mission dialogue is NOT shown on re-entering screen (e.g. returning from shop/research)', (WidgetTester tester) async {
      final q1 = preloadedGalaxies.expand((g) => g.quests).firstWhere((q) => q.id == 'q1');
      controller.loadQuest(q1);
      
      // Simulate that dialogue has already been shown/completed
      controller.preMissionDialogueShown = true;

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

      // Verify that the pre-mission DialogueOverlay is NOT displayed
      expect(find.byType(DialogueOverlay), findsNothing);
    });

    testWidgets('Post-mission dialogue intercepts victory screen and shows after victory', (WidgetTester tester) async {
      final q1 = preloadedGalaxies.expand((g) => g.quests).firstWhere((q) => q.id == 'q1');
      controller.loadQuest(q1);

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

      // Dismiss pre-mission dialogue first
      await tester.tap(find.text("SKIP DIALOGUE"));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Trigger victory on the controller manually
      controller.playState = PlayState.victory;
      controller.notifyListeners();
      await tester.pump();

      // Should show post-mission dialogue, NOT the final victory dialogue yet!
      expect(find.byType(DialogueOverlay), findsOneWidget);
      expect(find.text("SECTOR CLEANSED"), findsNothing);

      // Tapping skip dialogue should dismiss it and reveal final victory dialogue
      await tester.tap(find.text("SKIP DIALOGUE"));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Now it should show the victory summary panel
      expect(find.byType(DialogueOverlay), findsNothing);
      expect(find.text("SECTOR CLEANSED"), findsOneWidget);
      expect(find.text("RETURN TO MAP"), findsOneWidget);
    });
  });
}
