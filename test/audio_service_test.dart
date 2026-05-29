import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:single_shot/services/audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioService Unit & Safety Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'music_enabled': false,
        'sfx_enabled': false,
      });
    });

    test('AudioService acts as a singleton', () {
      final instance1 = AudioService.instance;
      final instance2 = AudioService.instance;
      expect(identical(instance1, instance2), isTrue);
    });

    test('AudioService initialize loads initial settings from SharedPreferences', () async {
      final audioService = AudioService.instance;
      await audioService.initialize();

      expect(audioService.musicEnabled, isFalse);
      expect(audioService.sfxEnabled, isFalse);
    });

    test('toggleMusic changes setting, persists, and is safe in test environment', () async {
      final audioService = AudioService.instance;
      
      // Toggle to true
      await audioService.toggleMusic(true);
      expect(audioService.musicEnabled, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('music_enabled'), isTrue);

      // Verify that calling playBgm is mock-safe and does not fail
      await audioService.playBgm('audio/bridge_music.mp3');

      // Toggle to false
      await audioService.toggleMusic(false);
      expect(audioService.musicEnabled, isFalse);
      expect(prefs.getBool('music_enabled'), isFalse);
      
      // Stop should also be mock-safe
      await audioService.stopBgm();
    });

    test('toggleSfx changes setting, persists, and is safe in test environment', () async {
      final audioService = AudioService.instance;
      
      // Toggle to true
      await audioService.toggleSfx(true);
      expect(audioService.sfxEnabled, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('sfx_enabled'), isTrue);

      // Verify that calling playSfx is mock-safe and does not fail
      await audioService.playSfx('audio/upgrade.mp3');

      // Toggle to false
      await audioService.toggleSfx(false);
      expect(audioService.sfxEnabled, isFalse);
      expect(prefs.getBool('sfx_enabled'), isFalse);
    });
  });
}
