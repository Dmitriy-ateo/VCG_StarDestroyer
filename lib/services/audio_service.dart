import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  AudioService._privateConstructor() {
    // Automatically detect unit test environment to safely bypass native player initialization
    _isTestEnv = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (_isTestEnv) {
      debugPrint("AudioService: Test environment detected. Native players disabled.");
    }
  }

  static final AudioService instance = AudioService._privateConstructor();

  late final bool _isTestEnv;
  
  AudioPlayer? _bgmPlayer;
  final List<AudioPlayer> _sfxPool = [];
  int _nextSfxIndex = 0;
  static const int _sfxPoolSize = 4;

  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  String? _currentBgmAsset;

  bool get musicEnabled => _musicEnabled;
  bool get sfxEnabled => _sfxEnabled;

  /// Initialize state from SharedPreferences and pre-load players
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _musicEnabled = prefs.getBool('music_enabled') ?? true;
      _sfxEnabled = prefs.getBool('sfx_enabled') ?? true;
    } catch (e) {
      debugPrint("AudioService: Failed to load settings: $e");
    }

    if (_isTestEnv) return;

    try {
      // Initialize BGM Player
      _bgmPlayer = AudioPlayer();
      await _bgmPlayer!.setReleaseMode(ReleaseMode.loop);
      
      // Initialize SFX Players Pool
      for (int i = 0; i < _sfxPoolSize; i++) {
        _sfxPool.add(AudioPlayer());
      }
      debugPrint("AudioService: Successfully initialized BGM and pooled SFX players.");
    } catch (e) {
      debugPrint("AudioService: Native players initialization error: $e");
    }
  }

  /// Play background music looping
  Future<void> playBgm(String assetName) async {
    if (_currentBgmAsset == assetName) return;
    _currentBgmAsset = assetName;
    if (!_musicEnabled) return;
    if (_isTestEnv) {
      debugPrint("AudioService: [MOCK BGM PLAY] $assetName");
      return;
    }

    try {
      if (_bgmPlayer == null) return;
      await _bgmPlayer!.stop();
      await _bgmPlayer!.play(AssetSource(assetName));
      debugPrint("AudioService: Playing BGM: $assetName");
    } catch (e) {
      debugPrint("AudioService: BGM Play error: $e");
    }
  }

  /// Stop background music
  Future<void> stopBgm() async {
    _currentBgmAsset = null;
    if (_isTestEnv) {
      debugPrint("AudioService: [MOCK BGM STOP]");
      return;
    }

    try {
      if (_bgmPlayer == null) return;
      await _bgmPlayer!.stop();
      debugPrint("AudioService: Stopped BGM");
    } catch (e) {
      debugPrint("AudioService: BGM Stop error: $e");
    }
  }

  /// Play a sound effect from the polyphonic pool
  Future<void> playSfx(String assetName) async {
    if (!_sfxEnabled) return;
    if (_isTestEnv) {
      debugPrint("AudioService: [MOCK SFX PLAY] $assetName");
      return;
    }

    try {
      if (_sfxPool.isEmpty) return;
      
      // Cycle through pooled players
      final player = _sfxPool[_nextSfxIndex];
      _nextSfxIndex = (_nextSfxIndex + 1) % _sfxPoolSize;

      await player.stop();
      await player.play(AssetSource(assetName));
      debugPrint("AudioService: Playing SFX: $assetName (Player Index: $_nextSfxIndex)");
    } catch (e) {
      debugPrint("AudioService: SFX Play error: $e");
    }
  }

  /// Enable or disable background music
  Future<void> toggleMusic(bool enabled) async {
    _musicEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('music_enabled', enabled);
    } catch (e) {
      debugPrint("AudioService: Error saving music preference: $e");
    }

    if (!enabled) {
      if (_isTestEnv) {
        debugPrint("AudioService: [MOCK BGM STOP]");
      } else {
        try {
          if (_bgmPlayer != null) {
            await _bgmPlayer!.stop();
            debugPrint("AudioService: Stopped BGM");
          }
        } catch (e) {
          debugPrint("AudioService: BGM Stop error: $e");
        }
      }
    } else {
      if (_currentBgmAsset != null) {
        final asset = _currentBgmAsset!;
        _currentBgmAsset = null; // Reset to allow playBgm to run
        await playBgm(asset);
      }
    }
  }

  /// Enable or disable sound effects
  Future<void> toggleSfx(bool enabled) async {
    _sfxEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sfx_enabled', enabled);
    } catch (e) {
      debugPrint("AudioService: Error saving sfx preference: $e");
    }
  }
}
