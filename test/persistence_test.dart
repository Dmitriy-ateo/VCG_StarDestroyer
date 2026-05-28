import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:single_shot/models/game_progression.dart';
import 'package:single_shot/models/device_model.dart';
import 'package:single_shot/game/game_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameProgression Serialization & Deserialization Tests', () {
    test('toJson and fromJson correctly serializes and restores progression state', () {
      final origin = GameProgression(
        credits: 540,
        researchPoints: 85,
        dailyHardGalaxyId: 'galaxy_2',
        dailyHardCompleted: true,
        dailyHardDateStr: '2026-05-28',
        dailyHardQuestId: 'daily_hard_quest_galaxy_2_2026-05-28',
      );

      // Mutate some sets and maps to make sure deep nested data serializes
      origin.completedLevelIds.addAll({2, 3, 5});
      origin.unlockedDevices.addAll({DeviceType.bomb, DeviceType.portal});
      origin.unlockedSplitterAngles.addAll({90.0, 45.0});
      origin.purchasedMarketDevices['bomb'] = 3;
      origin.purchasedMarketDevices['portal'] = 2;
      origin.completedGalaxyIds.add('galaxy_1');
      origin.completedQuestIds.addAll({'q1', 'q2', 'q3'});
      
      origin.chassisRanks['intensity'] = 'D';
      origin.chassisStars['intensity'] = 2;
      origin.chassisSubLevels['intensity'] = 4;

      origin.deviceRanks[DeviceType.reflector] = 'C';
      origin.deviceStars[DeviceType.reflector] = 1;
      origin.deviceSubLevels[DeviceType.reflector] = 3;

      // Serialize
      final jsonMap = origin.toJson();

      // Deserialize
      final restored = GameProgression.fromJson(jsonMap);

      // Verify simple values
      expect(restored.credits, 540);
      expect(restored.researchPoints, 85);
      expect(restored.dailyHardGalaxyId, 'galaxy_2');
      expect(restored.dailyHardCompleted, isTrue);
      expect(restored.dailyHardDateStr, '2026-05-28');
      expect(restored.dailyHardQuestId, 'daily_hard_quest_galaxy_2_2026-05-28');

      // Verify sets
      expect(restored.completedLevelIds, containsAll({2, 3, 5}));
      expect(restored.unlockedDevices, containsAll({DeviceType.reflector, DeviceType.bomb, DeviceType.portal}));
      expect(restored.unlockedSplitterAngles, containsAll({180.0, 90.0, 45.0}));
      expect(restored.completedGalaxyIds, contains('galaxy_1'));
      expect(restored.completedQuestIds, containsAll({'q1', 'q2', 'q3'}));

      // Verify maps
      expect(restored.purchasedMarketDevices['bomb'], 3);
      expect(restored.purchasedMarketDevices['portal'], 2);
      expect(restored.chassisRanks['intensity'], 'D');
      expect(restored.chassisStars['intensity'], 2);
      expect(restored.chassisSubLevels['intensity'], 4);
      expect(restored.deviceRanks[DeviceType.reflector], 'C');
      expect(restored.deviceStars[DeviceType.reflector], 1);
      expect(restored.deviceSubLevels[DeviceType.reflector], 3);
    });
  });

  group('GameController SharedPreferences Save/Load Mock Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('GameController successfully auto-saves and auto-loads progress from disk', () async {
      final controller = GameController();
      
      // Mutate progression via controller
      controller.progression.credits = 1200;
      controller.progression.researchPoints = 350;
      controller.progression.completedLevelIds.add(12);

      // Save to disk
      await controller.saveProgressionToDisk();

      // Initialize a new controller instance, which triggers loadProgressionFromDisk inside constructor
      final newController = GameController();
      await newController.loadProgressionFromDisk();

      // Verify state was correctly restored
      expect(newController.progression.credits, 1200);
      expect(newController.progression.researchPoints, 350);
      expect(newController.progression.completedLevelIds, contains(12));
    });
  });
}
