import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/device_model.dart';
import '../models/level_data.dart';
import '../models/game_progression.dart';
import '../models/galaxy_model.dart';
import '../config/lore_dialogue.dart';
import '../game/game_controller.dart';
import '../widgets/board_painter.dart';
import '../widgets/dialogue_overlay.dart';
import '../services/audio_service.dart';

class GameBoardScreen extends StatefulWidget {
  final GameController controller;
  final VoidCallback onBackToMenu;
  final VoidCallback onGoToShop;
  final VoidCallback onGoToResearch;

  const GameBoardScreen({
    super.key,
    required this.controller,
    required this.onBackToMenu,
    required this.onGoToShop,
    required this.onGoToResearch,
  });

  @override
  State<GameBoardScreen> createState() => _GameBoardScreenState();
}

class _GameBoardScreenState extends State<GameBoardScreen> with TickerProviderStateMixin {
  bool _isInventoryOpen = false;
  late AnimationController _bgAnimationController;
  late AnimationController _aimAnimationController;
  Offset? _hoverPosition;
  String? _activeTooltipText;
  Offset? _tooltipPosition;

  // Holographic Radial HUD State
  DeviceModel? _selectedHudDevice;
  late AnimationController _hudAnimationController;

  // Cyberpunk Dialogue System State
  bool _isDialogueOverlayVisible = false;
  bool _hasShownPostMissionDialogue = false;
  bool _hasShownBlueprintUnlock = false;
  List<DialogueNode>? _dialogueSequence;
  VoidCallback? _onDialogueComplete;
  PlayState? _lastPlayState;

  @override
  void initState() {
    super.initState();
    AudioService.instance.playBgm('audio/battle_music.mp3');
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();

    _aimAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _hudAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    // Initialize pre-mission lore dialogues if applicable
    final quest = widget.controller.activeQuest;
    if (quest != null && quest.type == QuestType.lore && !widget.controller.preMissionDialogueShown) {
      final seq = LoreDialogueConfig.preMissionDialogues[quest.id];
      if (seq != null) {
        _isDialogueOverlayVisible = true;
        _dialogueSequence = seq;
        _onDialogueComplete = () {
          widget.controller.preMissionDialogueShown = true;
          setState(() {
            _isDialogueOverlayVisible = false;
            _dialogueSequence = null;
            _onDialogueComplete = null;
          });
        };
      }
    }
    _lastPlayState = widget.controller.playState;
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    AudioService.instance.playBgm('audio/bridge_music.mp3');
    _bgAnimationController.dispose();
    _aimAnimationController.dispose();
    _hudAnimationController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    final currentPlayState = widget.controller.playState;
    if (_lastPlayState != currentPlayState) {
      if (currentPlayState == PlayState.victory) {
        final quest = widget.controller.activeQuest;
        if (quest != null && quest.type == QuestType.lore) {
          final postSeq = LoreDialogueConfig.postMissionDialogues[quest.id];
          if (postSeq == null) {
            AudioService.instance.playSfx('audio/victory.mp3');
          }
        }
      }
      _lastPlayState = currentPlayState;
    }
  }

  void _showTooltipAt(int x, int y, Offset localPos) {
    if (x < 0 || x >= 8 || y < 0 || y >= 12) {
      _hideTooltip();
      return;
    }

    String? text;

    // 1. Check Planets
    for (var planet in widget.controller.currentLevel.planets) {
      if (planet.gridX == x && planet.gridY == y) {
        final reqPower = planet.requiredLaserPower ?? 1;
        final currentRank = widget.controller.progression.chassisRanks['intensity'] ?? 'F';
        final currentStars = widget.controller.progression.chassisStars['intensity'] ?? 0;
        final currentText = GameProgression.formatRankAndStars(currentRank, currentStars);

        if (reqPower > 1) {
          final isSufficient = widget.controller.progression.laserIntensityLevel >= reqPower;
          final reqText = GameProgression.formatLevel(reqPower);

          final statusText = isSufficient 
              ? "⚠️ PENETRATED ($currentText >= $reqText)" 
              : "❌ BLOCKED (Requires Laser Intensity $reqText, Current: $currentText)";
          text = "🪐 [Shielded Planet: ${planet.name}]\n$statusText\nDefense Level: $reqPower. Laser power decreases by 1 on penetration (if Laser Power > $reqPower).";
        } else {
          final canPenetrate = widget.controller.progression.laserIntensityLevel > 1;
          final statusText = canPenetrate
              ? "⚠️ PENETRATED (Current: $currentText, will pass through)"
              : "🎯 DESTROYED (Current: $currentText, will absorb)";
          text = "🪐 [Planet: ${planet.name}]\n$statusText\nDirect the superlaser here to destroy it. If Laser Power > 1, it will penetrate and continue propagating (losing 1 power).";
        }
        break;
      }
    }

    // 2. Check Walls
    if (text == null) {
      for (var wall in widget.controller.currentLevel.walls) {
        if (wall.gridX == x && wall.gridY == y) {
          final reqPower = wall.requiredLaserPower ?? 1;
          final currentRank = widget.controller.progression.chassisRanks['intensity'] ?? 'F';
          final currentStars = widget.controller.progression.chassisStars['intensity'] ?? 0;
          final currentText = GameProgression.formatRankAndStars(currentRank, currentStars);

          if (wall.type == 'energyShield') {
            final isPenetrated = widget.controller.progression.laserIntensityLevel >= reqPower;
            final reqText = GameProgression.formatLevel(reqPower);
            final statusText = isPenetrated 
                ? "⚠️ PENETRATED ($currentText >= $reqText)" 
                : "❌ BLOCKED (Requires Laser Intensity $reqText, Current: $currentText)";
            text = "🛡️ [Energy Shield]\n$statusText\nLaser power decreases by 1 on penetration.";
          } else if (wall.type == 'spaceLitter') {
            final isPenetrated = widget.controller.progression.laserIntensityLevel >= reqPower;
            final reqText = GameProgression.formatLevel(reqPower);
            final statusText = isPenetrated 
                ? "⚠️ PENETRATED ($currentText >= $reqText)" 
                : "❌ BLOCKED (Requires Laser Intensity $reqText, Current: $currentText)";
            text = "🪰 [Space Debris Litter]\n$statusText\nLaser power decreases by 1 on penetration.";
          } else if (wall.type == 'crystal') {
            final isPenetrated = widget.controller.progression.laserIntensityLevel >= reqPower;
            final reqText = GameProgression.formatLevel(reqPower);
            final statusText = isPenetrated 
                ? "⚠️ PENETRATED ($currentText >= $reqText)" 
                : "❌ BLOCKED (Requires Laser Intensity $reqText, Current: $currentText)";
            text = "💎 [Crystal Matrix]\n$statusText\nLaser power decreases by 1 on penetration.";
          } else if (wall.type == 'scrapMetal') {
            final isPenetrated = widget.controller.progression.laserIntensityLevel >= reqPower;
            final reqText = GameProgression.formatLevel(reqPower);
            final statusText = isPenetrated 
                ? "⚠️ PENETRATED ($currentText >= $reqText)" 
                : "❌ BLOCKED (Requires Laser Intensity $reqText, Current: $currentText)";
            text = "⚙️ [Scrap Metal]\n$statusText\nLaser power decreases by 1 on penetration.";
          } else {
            text = "🪨 [Asteroid Block]\nIndestructible static barrier. Completely blocks the laser.";
          }
          break;
        }
      }
    }

    // 3. Check Placed Devices
    if (text == null) {
      for (var dev in widget.controller.placedDevices) {
        if (dev.isPlaced && dev.gridX == x && dev.gridY == y) {
          text = _getDeviceDescription(dev);
          break;
        }
      }
    }

    // 4. Check Preset Devices
    if (text == null) {
      for (var dev in widget.controller.currentLevel.presetDevices) {
        if (dev.isPlaced && dev.gridX == x && dev.gridY == y) {
          text = _getDeviceDescription(dev);
          break;
        }
      }
    }

    if (text != null) {
      setState(() {
        _activeTooltipText = text;
        _tooltipPosition = localPos;
      });
      HapticFeedback.selectionClick();
    } else {
      _hideTooltip();
    }
  }

  String _getDeviceDescription(DeviceModel dev) {
    final level = widget.controller.progression.deviceLevels[dev.type] ?? 1;

    switch (dev.type) {
      case DeviceType.reflector:
        return "🪞 [Reflector - Level $level]\nBounces the laser at 90° angles. Tap to rotate.";
      case DeviceType.splitter:
        final status = (level == 1) 
            ? "⚠️ UNSTABLE: Drains 1 laser power on bifurcation." 
            : "✓ STABLE: Lossless splitting.";
        return "📐 [Splitter (${dev.splitAngleDegrees?.toStringAsFixed(0)}°) - Level $level]\n$status\nSplits the laser into twin beams. Tap to rotate.";
      case DeviceType.portal:
        final status = (level == 1) 
            ? "⚠️ UNSTABLE: Drains 1 laser power on teleportation." 
            : "✓ STABLE: Lossless teleportation.";
        return "🌀 [Quantum Portal - Level $level]\n$status\nTeleports the laser instantly to its paired portal.";
      case DeviceType.gravityWell:
        final range = (2.5 + 0.3 * level).toStringAsFixed(1);
        final pull = (0.10 + 0.03 * level).toStringAsFixed(2);
        return "🕳️ [Gravity Well - Level $level]\nAttraction Range: $range units. Pull Strength: $pull.\nContinuously curves the laser beam path.";
      case DeviceType.bomb:
        return "💣 [Tactical Bomb - Level $level]\nExplosion radius: 2.2 units.\nDetonates on hit. Can destroy shielded planets up to Defense Level $level.";
      case DeviceType.floatingAsteroid:
        return "☄️ [Floating Asteroid - Level $level]\nBeatable! Shatters on hit, deflecting the laser by exactly its rotation angle (${dev.angleDegrees.toStringAsFixed(0)}°).";
    }
  }

  void _hideTooltip() {
    if (_activeTooltipText != null) {
      setState(() {
        _activeTooltipText = null;
        _tooltipPosition = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final level = widget.controller.currentLevel;
          final state = widget.controller.playState;

          return SafeArea(
            child: Stack(
              children: [
                // Underlying active game dashboard column
                Column(
                  children: [
                    // 1. Top Panel (Title, Stats, Actions)
                    _buildTopPanel(level),

                    // 2. Main Game Workspace (Grid Board occupying full height)
                    Expanded(
                      child: _buildGameBoard(),
                    ),

                    // 3. Firing & Aiming Control Panel (Bottom)
                    _buildBottomControlPanel(),
                  ],
                ),

                // 5. Sliding Glassmorphic Inventory Drawer Overlay
                if (state == PlayState.editing)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    left: 12,
                    right: 12,
                    bottom: _isInventoryOpen ? 88 : -220,
                    height: 175,
                    child: _buildGlassmorphicDrawer(),
                  ),

                // 7. Floating Overlay States (Victory/Defeat Dialog Modals)
                if (state == PlayState.victory || state == PlayState.defeat)
                  Positioned.fill(
                    child: _buildOverlayDialog(state),
                  ),

                // 8. Cyberpunk Dialogue Overlay (Pre-mission / Lore Dialogue)
                if (_isDialogueOverlayVisible && _dialogueSequence != null && _onDialogueComplete != null)
                  Positioned.fill(
                    child: DialogueOverlay(
                      dialogueSequence: _dialogueSequence!,
                      onComplete: _onDialogueComplete!,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopPanel(LevelData level) {
    final isEditing = widget.controller.playState == PlayState.editing;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        border: Border(bottom: BorderSide(color: Color(0xFF00ADB5), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF00ADB5), size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    AudioService.instance.playSfx('audio/hud_click.mp3');
                    widget.onBackToMenu();
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          level.name.split(':').last.trim().toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          AudioService.instance.playSfx('audio/hud_click.mp3');
                          _showLevelInfoDialog(context, level);
                        },
                        child: const MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Icon(
                            Icons.help_outline_rounded,
                            color: Color(0xFF00ADB5),
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Currency indicators side-by-side (Clickable HUD button dials)
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: isEditing ? () {
                  HapticFeedback.lightImpact();
                  AudioService.instance.playSfx('audio/hud_click.mp3');
                  widget.onGoToShop();
                } : null,
                child: MouseRegion(
                  cursor: isEditing ? SystemMouseCursors.click : SystemMouseCursors.basic,
                  child: Opacity(
                    opacity: isEditing ? 1.0 : 0.6,
                    child: _buildStatChip(Icons.monetization_on, "${widget.controller.progression.credits}", Colors.amberAccent),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: isEditing ? () {
                  HapticFeedback.lightImpact();
                  AudioService.instance.playSfx('audio/hud_click.mp3');
                  widget.onGoToResearch();
                } : null,
                child: MouseRegion(
                  cursor: isEditing ? SystemMouseCursors.click : SystemMouseCursors.basic,
                  child: Opacity(
                    opacity: isEditing ? 1.0 : 0.6,
                    child: _buildStatChip(Icons.science, "${widget.controller.progression.researchPoints} RP", Colors.purpleAccent),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLevelInfoDialog(BuildContext context, LevelData level) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor: const Color(0xFF0B0E14).withOpacity(0.95),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF00ADB5), width: 1.5),
            ),
            title: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFF00ADB5), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    level.name.split(':').last.trim().toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "SECTOR BRIEFING",
                  style: TextStyle(
                    color: Color(0xFF00FFF5),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  level.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF00ADB5),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text(
                  "DISMISS",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 4,
            spreadRadius: 0.5,
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gridAspectRatio = 8.0 / 12.0;
        double gridW;
        double gridH;
        double offsetX = 0.0;
        double offsetY = 0.0;
        
        final sizeW = constraints.maxWidth;
        final sizeH = constraints.maxHeight;
        
        if (sizeW / sizeH > gridAspectRatio) {
          gridH = sizeH;
          gridW = gridH * gridAspectRatio;
          offsetX = (sizeW - gridW) / 2.0;
        } else {
          gridW = sizeW;
          gridH = gridW / gridAspectRatio;
          offsetY = (sizeH - gridH) / 2.0;
        }
        
        final cellW = gridW / 8.0;
        final cellH = gridH / 12.0;

        final isPlacing = widget.controller.playState == PlayState.editing && widget.controller.selectedInventoryDevice != null;

        return MouseRegion(
          cursor: isPlacing ? SystemMouseCursors.none : MouseCursor.defer,
          onHover: (details) {
            setState(() {
              _hoverPosition = details.localPosition;
            });
          },
          onExit: (details) {
            setState(() {
              _hoverPosition = null;
            });
          },
          child: GestureDetector(
            onPanStart: (details) {
              _hideTooltip();
              if (widget.controller.playState != PlayState.editing) return;
              _aimAnimationController.forward();
            },
            onPanUpdate: (details) {
              if (widget.controller.playState != PlayState.editing) return;
              // Horizontal drag delta determines laser aiming rotation
              final deltaX = details.delta.dx;
              final newAngle = widget.controller.aimingAngle + (deltaX * 0.35);
              widget.controller.setAimingAngle(newAngle);
            },
            onPanEnd: (details) {
              _aimAnimationController.reverse();
            },
            onPanCancel: () {
              _aimAnimationController.reverse();
            },
            onTapUp: (details) {
              _hideTooltip();
              if (widget.controller.playState != PlayState.editing) return;
              
              if (_selectedHudDevice != null) {
                setState(() {
                  _selectedHudDevice = null;
                });
                _hudAnimationController.reverse();
                HapticFeedback.lightImpact();
                return;
              }

              final x = ((details.localPosition.dx - offsetX) / cellW).floor();
              final y = ((details.localPosition.dy - offsetY) / cellH).floor();

              // Check if selecting to place a device
              if (widget.controller.selectedInventoryDevice != null) {
                final totalPlacedDevicesCount = widget.controller.placedDevices.length;
                final maxDevices = 1 + widget.controller.progression.chassisCapacityLevel;
                if (totalPlacedDevicesCount >= maxDevices) {
                  HapticFeedback.heavyImpact();
                  AudioService.instance.playSfx('audio/defeat.mp3');
                  final messenger = ScaffoldMessenger.of(context);
                  messenger.clearSnackBars();
                  final screenHeight = MediaQuery.of(context).size.height;
                  messenger.showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.only(
                        bottom: (screenHeight - 120).clamp(0.0, double.infinity),
                        left: 24,
                        right: 24,
                      ),
                      backgroundColor: const Color(0xFF161B22),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Color(0xFFFF3333), width: 1.5),
                      ),
                      content: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Color(0xFFFF3333), size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "SUB-CHASSIS LIMIT EXCEEDED!\nMax Devices: $maxDevices. Upgrade in Research Lab.",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  return;
                }

                widget.controller.placeDevice(x, y);
                // Clear hover position after placing
                setState(() {
                  _hoverPosition = null;
                });
              } else {
                // Check if tapping a placed device to rotate it
                DeviceModel? clickedDevice;
                for (var dev in widget.controller.placedDevices) {
                  if (dev.isPlaced && dev.gridX == x && dev.gridY == y) {
                    clickedDevice = dev;
                    break;
                  }
                }
                if (clickedDevice != null) {
                  widget.controller.rotateDevice(clickedDevice);
                  HapticFeedback.lightImpact();
                }
              }
            },
            onLongPressStart: (details) {
              if (widget.controller.playState != PlayState.editing) return;
              _hideTooltip();

              final x = ((details.localPosition.dx - offsetX) / cellW).floor();
              final y = ((details.localPosition.dy - offsetY) / cellH).floor();

              DeviceModel? clickedDevice;
              for (var dev in widget.controller.placedDevices) {
                if (dev.isPlaced && dev.gridX == x && dev.gridY == y) {
                  clickedDevice = dev;
                  break;
                }
              }

              if (clickedDevice != null) {
                setState(() {
                  _selectedHudDevice = clickedDevice;
                });
                _hudAnimationController.forward(from: 0.0);
                HapticFeedback.mediumImpact();
              } else {
                _showTooltipAt(x, y, details.localPosition);
              }
            },
            onLongPressEnd: (details) {
              _hideTooltip();
            },
            onLongPressCancel: () {
              _hideTooltip();
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Centered custom paint grid board
                AnimatedBuilder(
                  animation: Listenable.merge([_bgAnimationController, _aimAnimationController]),
                  builder: (context, child) {
                    return RepaintBoundary(
                      child: CustomPaint(
                        painter: BoardPainter(
                          level: widget.controller.currentLevel,
                          placedDevices: widget.controller.placedDevices,
                          aimingAngle: widget.controller.aimingAngle,
                          playState: widget.controller.playState,
                          traceResult: widget.controller.traceResult,
                          animationProgress: widget.controller.animationProgress,
                          aimingComputerLevel: widget.controller.progression.aimingComputerLevel,
                          selectedInventoryDevice: widget.controller.selectedInventoryDevice,
                          bgAnimationValue: _bgAnimationController.value,
                          aimAnimationValue: _aimAnimationController.value,
                          laserIntensity: widget.controller.progression.laserIntensityLevel,
                          deviceLevels: widget.controller.progression.deviceLevels,
                        ),
                        child: Container(),
                      ),
                    );
                  },
                ),

                // 2. High-Tech Floating Cursor Preview Item
                if (isPlacing && _hoverPosition != null)
                  Positioned(
                    left: _hoverPosition!.dx - 22,
                    top: _hoverPosition!.dy - 22,
                    child: IgnorePointer(
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF111424).withOpacity(0.85),
                          border: Border.all(color: const Color(0xFFFF2E93), width: 2.0),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF2E93).withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 1,
                            )
                          ],
                        ),
                        alignment: Alignment.center,
                        child: _buildDeviceIcon(
                          widget.controller.selectedInventoryDevice!.type,
                          widget.controller.selectedInventoryDevice!.splitAngleDegrees,
                        ),
                      ),
                    ),
                  ),

                // 3. High-Tech Floating Tooltip Description Box
                if (_activeTooltipText != null && _tooltipPosition != null)
                  Positioned(
                    left: (_tooltipPosition!.dx - 100).clamp(16.0, sizeW - 216.0),
                    top: (_tooltipPosition!.dy - 95).clamp(16.0, sizeH - 140.0),
                    child: IgnorePointer(
                      child: Container(
                        width: 200,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xE60F1115),
                          border: Border.all(color: const Color(0xFF00FFF5), width: 1.5),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x3300FFF5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: Text(
                          _activeTooltipText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.0,
                            height: 1.4,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                    ),
                  ),

                // 4. Holographic Radial HUD Popup (for device rotation/removal)
                if (_selectedHudDevice != null)
                  _buildHolographicRadialHud(
                    _selectedHudDevice!,
                    offsetX + (_selectedHudDevice!.gridX + 0.5) * cellW,
                    offsetY + (_selectedHudDevice!.gridY + 0.5) * cellH,
                    cellW,
                    cellH,
                    sizeW,
                    sizeH,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomToolboxButton() {
    final hasSelection = widget.controller.selectedInventoryDevice != null;
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasSelection ? const Color(0xFFFF2E93) : const Color(0xFF00FFF5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (hasSelection ? const Color(0xFFFF2E93) : const Color(0xFF00FFF5)).withOpacity(0.15),
            blurRadius: 8,
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10.5),
          onTap: () {
            setState(() {
              _isInventoryOpen = !_isInventoryOpen;
            });
            HapticFeedback.selectionClick();
          },
          child: Icon(
            _isInventoryOpen ? Icons.close : (hasSelection ? Icons.playlist_add_check : Icons.construction),
            color: hasSelection ? const Color(0xFFFF2E93) : const Color(0xFF00FFF5),
            size: 22,
          ),
        ),
      ),
    );
  }

  String _getGroupKey(DeviceModel item) {
    if (item.type == DeviceType.splitter && item.splitAngleDegrees != null) {
      return "splitter_${item.splitAngleDegrees!.toStringAsFixed(0)}";
    }
    return item.type.name;
  }

  Widget _buildGlassmorphicDrawer() {
    final availableItems = widget.controller.inventory.where((item) => !item.isPlaced).toList();

    // Group available items by type (and angle for splitters)
    final Map<String, List<DeviceModel>> groupedItems = {};
    for (var item in availableItems) {
      final key = _getGroupKey(item);
      groupedItems.putIfAbsent(key, () => []).add(item);
    }
    final groupKeys = groupedItems.keys.toList();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B0E14).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00ADB5).withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.5), // Inner radius aligned with the 1.5px border
        child: Column(
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFF111424),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, color: Color(0xFF00FFF5), size: 14),
                      SizedBox(width: 8),
                      Text(
                        "DEVICE BLUEPRINTS",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "${availableItems.length} AVAILABLE",
                    style: const TextStyle(
                      color: Color(0xFF00ADB5),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            
            // List of available blueprints
            Expanded(
              child: groupKeys.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "ALL BLUEPRINTS PLACED",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 38,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _isInventoryOpen = false;
                                });
                                widget.onGoToShop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00ADB5).withOpacity(0.1),
                                side: const BorderSide(color: Color(0xFF00ADB5), width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                              ),
                              icon: const Icon(Icons.storefront, color: Color(0xFF00FFF5), size: 16),
                              label: const Text(
                                "GO TO MARKET",
                                style: TextStyle(
                                  color: Color(0xFF00FFF5),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      itemCount: groupKeys.length,
                      itemBuilder: (context, index) {
                        final key = groupKeys[index];
                        final itemsInGroup = groupedItems[key]!;
                        final representativeItem = itemsInGroup.first;
                        final isSelected = widget.controller.selectedInventoryDevice != null &&
                            _getGroupKey(widget.controller.selectedInventoryDevice!) == key;

                        return GestureDetector(
                          onTap: () {
                            if (isSelected) {
                              widget.controller.selectInventoryDevice(null);
                            } else {
                              widget.controller.selectInventoryDevice(representativeItem);
                              setState(() {
                                _isInventoryOpen = false;
                              });
                            }
                            HapticFeedback.selectionClick();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 16),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Premium Cyber Card
                                Container(
                                  width: 100,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFFF2E93).withOpacity(0.15)
                                        : const Color(0xFF161B22),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFFFF2E93) : const Color(0xFF393E46),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildDeviceIcon(representativeItem.type, representativeItem.splitAngleDegrees),
                                      const SizedBox(height: 8),
                                      Text(
                                        representativeItem.type == DeviceType.splitter && representativeItem.splitAngleDegrees != null
                                            ? "SPLIT ${representativeItem.splitAngleDegrees!.toStringAsFixed(0)}°"
                                            : representativeItem.type.name.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                // Cyber-Cyan Count Badge overlay
                                Positioned(
                                  top: -6,
                                  right: -6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00ADB5), // Cyan/Teal
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFF0B0E14), width: 1.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF00ADB5).withOpacity(0.4),
                                          blurRadius: 4,
                                        )
                                      ],
                                    ),
                                    child: Text(
                                      "x${itemsInGroup.length}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceIcon(DeviceType type, double? splitAngle) {
    switch (type) {
      case DeviceType.reflector:
        return const Icon(Icons.flip, color: Color(0xFF00FFF5), size: 28);
      case DeviceType.splitter:
        Color color = const Color(0xFFFF2E93); // Default 180 (pink)
        if (splitAngle == 45.0) color = const Color(0xFF00FFF5); // Cyan
        if (splitAngle == 90.0) color = const Color(0xFFE0245E); // Purple/Red
        if (splitAngle == 135.0) color = const Color(0xFFFFB703); // Amber
        return Icon(Icons.call_split, color: color, size: 28);
      case DeviceType.gravityWell:
        return const Icon(Icons.blur_circular, color: Color(0xFF7B2CBF), size: 28);
      case DeviceType.bomb:
        return const Icon(Icons.brightness_low, color: Color(0xFFFF3333), size: 28);
      case DeviceType.portal:
        return const Icon(Icons.circle_outlined, color: Color(0xFFFF9F1C), size: 28);
      case DeviceType.floatingAsteroid:
        return const Icon(Icons.grain, color: Color(0xFFFFB703), size: 28);
    }
  }

  Widget _buildBottomControlPanel() {
    final state = widget.controller.playState;
    final isEditing = state == PlayState.editing;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF111424),
        border: Border(top: BorderSide(color: Color(0xFF00ADB5), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: isEditing
                    ? ElevatedButton(
                        onPressed: widget.controller.fireLaser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF2E93),
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: const Color(0xFFFF2E93).withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.white, width: 1.5),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.flash_on, size: 22, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              "FIRE SUPERLASER",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                      )
                    : OutlinedButton(
                        onPressed: widget.controller.resetLaser,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF00FFF5),
                          side: const BorderSide(color: Color(0xFF00FFF5), width: 2.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          backgroundColor: const Color(0xFF00FFF5).withOpacity(0.05),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh, size: 20),
                            SizedBox(width: 10),
                            Text(
                              "RESET CONSOLE",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            if (isEditing) ...[
              const SizedBox(width: 12),
              _buildBottomToolboxButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayDialog(PlayState state) {
    final isWin = state == PlayState.victory;
    final quest = widget.controller.activeQuest;

    // Intercept victory to show post-mission lore dialogue first
    if (isWin && quest != null && quest.type == QuestType.lore && !_hasShownPostMissionDialogue) {
      final postSeq = LoreDialogueConfig.postMissionDialogues[quest.id];
      if (postSeq != null) {
        return DialogueOverlay(
          dialogueSequence: postSeq,
          onComplete: () {
            AudioService.instance.playSfx('audio/victory.mp3');
            setState(() {
              _hasShownPostMissionDialogue = true;
            });
          },
        );
      }
    }

    // Intercept victory to show blueprint unlock overlay
    final needsBlueprint = quest != null && (quest.id == 'q3' || quest.id == 'q5' || quest.id == 'q6' || quest.id == 'q7' || quest.id == 'q8' || quest.id == 'q9');
    if (isWin && needsBlueprint && !_hasShownBlueprintUnlock) {
      return _buildBlueprintUnlockOverlay(quest.id);
    }

    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isWin ? Colors.greenAccent : Colors.redAccent,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: (isWin ? Colors.greenAccent : Colors.redAccent).withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isWin ? Icons.check_circle : Icons.error,
                size: 64,
                color: isWin ? Colors.greenAccent : Colors.redAccent,
              ),
              const SizedBox(height: 16),
              
              Text(
                isWin ? "SECTOR CLEANSED" : "MISSION FAILED",
                style: TextStyle(
                  color: isWin ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 16),
              
              Text(
                isWin
                    ? "Superlaser payload successfully destroyed all rebel strongholds. Imperial control has been established."
                    : "The superlaser missed target planets or was absorbed by sector walls. Rebel forces survived.",
                style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              if (isWin) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildRewardMetric(Icons.monetization_on, "+${widget.controller.creditsEarned}", Colors.amberAccent),
                    const SizedBox(width: 24),
                    _buildRewardMetric(Icons.science, "+${widget.controller.researchPointsEarned} RP", Colors.purpleAccent),
                  ],
                ),
                if (widget.controller.creditsEarned == 0) ...[
                  const SizedBox(height: 8),
                  const Text(
                    "(Sector already cleared: repeat rewards offline)",
                    style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
                  ),
                ],
                const SizedBox(height: 28),
              ],
              
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: widget.controller.resetLaser,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(isWin ? "PLAY AGAIN" : "RETRY CONSOLE"),
                  ),
                  if (isWin)
                    ElevatedButton(
                      onPressed: () {
                        if (widget.controller.activeQuest != null) {
                          widget.onBackToMenu();
                        } else {
                          // Move to next level if exists
                          final nextId = widget.controller.currentLevel.id + 1;
                          final nextExists = preloadedLevels.any((l) => l.id == nextId);
                          if (nextExists) {
                            widget.controller.loadLevel(nextId);
                          } else {
                            // Loop back to level 1 or show complete
                            widget.controller.loadLevel(1);
                            widget.onBackToMenu();
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(widget.controller.activeQuest != null ? "RETURN TO MAP" : "NEXT SECTOR"),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardMetric(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildHolographicRadialHud(
    DeviceModel device,
    double centerX,
    double centerY,
    double cellW,
    double cellH,
    double sizeW,
    double sizeH,
  ) {
    final double radius = (cellW > cellH ? cellW : cellH) * 0.65;
    final bool isTopDevice = device.gridY < 2;
    final double direction = isTopDevice ? 1.0 : -1.0;
    
    // Center-y coordinate of the capsule
    final double hudCenterY = centerY + direction * 75;
    
    final double capsuleW = 210.0;
    final double capsuleH = 44.0;
    
    final double leftPos = (centerX - capsuleW / 2).clamp(16.0, sizeW - capsuleW - 16.0);
    final double topPos = hudCenterY - capsuleH / 2;

    return AnimatedBuilder(
      animation: _hudAnimationController,
      builder: (context, child) {
        final val = _hudAnimationController.value;
        if (val <= 0.0) return const SizedBox.shrink();

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Target Custom Painter for Ring and Leader Line
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: HudConnectorPainter(
                    centerX: centerX,
                    centerY: centerY,
                    radius: radius,
                    direction: direction,
                    progress: val,
                  ),
                ),
              ),
            ),
            
            // 2. Interactive Floating Control Capsule
            Positioned(
              left: leftPos,
              top: topPos,
              child: Transform.scale(
                scale: 0.85 + 0.15 * val,
                alignment: Alignment.center,
                child: Opacity(
                  opacity: val,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: capsuleW,
                        height: capsuleH,
                        decoration: BoxDecoration(
                          color: const Color(0xE60F1115),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: const Color(0xFF00FFF5).withOpacity(0.85),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00FFF5).withOpacity(0.25 * val),
                              blurRadius: 12,
                              spreadRadius: 1,
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            // Rotate Button
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    widget.controller.rotateDevice(device);
                                    HapticFeedback.lightImpact();
                                    AudioService.instance.playSfx('audio/hud_click.mp3');
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.sync,
                                        color: Color(0xFF00FFF5),
                                        size: 16,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        "ROTATE",
                                        style: TextStyle(
                                          color: Color(0xFF00FFF5),
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                          fontFamily: 'Outfit',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            
                            // Vertical Divider
                            Container(
                              width: 1.2,
                              height: 24,
                              color: const Color(0xFF00FFF5).withOpacity(0.3),
                            ),
                            
                            // Reclaim Button
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    widget.controller.removeDevice(device);
                                    HapticFeedback.heavyImpact();
                                    AudioService.instance.playSfx('audio/hud_click.mp3');
                                    setState(() {
                                      _selectedHudDevice = null;
                                    });
                                    _hudAnimationController.reverse();
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        color: Color(0xFFFF2E93),
                                        size: 16,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        "RECLAIM",
                                        style: TextStyle(
                                          color: Color(0xFFFF2E93),
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                          fontFamily: 'Outfit',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBlueprintUnlockOverlay(String questId) {
    String title = "";
    IconData icon = Icons.biotech;
    String subtitle = "";
    String spec = "";
    Color glowColor = const Color(0xFF00FFF5);
    
    if (questId == 'q3') {
      title = "PRISM LASER SPLITTER (180°)";
      icon = Icons.call_split;
      subtitle = "Base Bifurcation Prismatic Core";
      spec = "Decrypted Imperial blueprint. Splits a single high-charge laser beam into two directly opposite (180°) vectors. Enables simultaneous targeting of opposing sectors.";
      glowColor = const Color(0xFFFF2E93);
    } else if (questId == 'q5') {
      title = "SPLITTER CORONA & TARGET MATRIX";
      icon = Icons.radar;
      subtitle = "Diagonals (45°, 90°, 135°) & Aiming Computer";
      spec = "Decrypted tactical data packages. Allows beam splitting at custom diagonal vectors to bypass asteroid slipways. Unlocks the Tactical Aiming Computer on the weapons bridge console.";
      glowColor = const Color(0xFF00FFF5);
    } else if (questId == 'q6') {
      title = "ANTI-MATTER PROXIMITY BOMB";
      icon = Icons.brightness_low;
      subtitle = "Tactical Detonation Core";
      spec = "Decrypted volatile technology. Deployable explosive cores that react violently to superlaser charge spikes. Detonation shatters heavy armored planet shield casings within a 2.2-unit radius.";
      glowColor = const Color(0xFFFF3333);
    } else if (questId == 'q7') {
      title = "SINGULARITY GRAVITY WELL";
      icon = Icons.blur_circular;
      subtitle = "Micro-Black Hole Emitter";
      spec = "Decrypted high-gravity blueprints. Projects micro-singularities that continuously pull and warp passing superlaser rays. Crucial for curving fire around impenetrable planetary screens.";
      glowColor = const Color(0xFF7B2CBF);
    } else if (questId == 'q8') {
      title = "COSMIC WARP PORTALS";
      icon = Icons.circle_outlined;
      subtitle = "Einstein-Rosen Spatial Bridge Pair";
      spec = "Decrypted spatial transport diagrams. Links two grid positions to warp superlasers across dimensions with zero beam attenuation. Enables traversal of solid asteroid walls.";
      glowColor = const Color(0xFFFF9F1C);
    } else if (questId == 'q9') {
      title = "FLOATING ASTEROID DEFLECTORS";
      icon = Icons.filter_hdr_outlined;
      subtitle = "Mobile Organic Prism Deflectors";
      spec = "Decrypted space-harnessing algorithms. Harness organic belt minerals to deploy floating space rock refractors. Drifting structures deflect superlaser rays upon impact.";
      glowColor = const Color(0xFF69F0AE);
    }

    return Container(
      color: Colors.black.withOpacity(0.92),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          constraints: const BoxConstraints(maxWidth: 360),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: glowColor, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: glowColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: glowColor.withOpacity(0.4), width: 1),
                ),
                child: Text(
                  "🔓 LORE BLUEPRINT DECRYPTED 🔓",
                  style: TextStyle(
                    color: glowColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Animated Wireframe Hologram representation
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1117),
                  shape: BoxShape.circle,
                  border: Border.all(color: glowColor.withOpacity(0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withOpacity(0.06),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 44, color: glowColor),
              ),
              const SizedBox(height: 20),
              
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                subtitle.toUpperCase(),
                style: TextStyle(
                  color: glowColor,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  letterSpacing: 0.8,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1117),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF30363D), width: 1),
                ),
                child: Text(
                  spec,
                  style: const TextStyle(
                    color: Color(0xFF8B949E),
                    fontSize: 11,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    AudioService.instance.playSfx('audio/upgrade.mp3');
                    setState(() {
                      _hasShownBlueprintUnlock = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: glowColor.withOpacity(0.15),
                    foregroundColor: glowColor,
                    side: BorderSide(color: glowColor, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "INTEGRATE TO DATABASE",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HudConnectorPainter extends CustomPainter {
  final double centerX;
  final double centerY;
  final double radius;
  final double direction; // -1.0 for up, 1.0 for down
  final double progress; // _hudAnimationController.value

  HudConnectorPainter({
    required this.centerX,
    required this.centerY,
    required this.radius,
    required this.direction,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final paint = Paint()
      ..color = const Color(0xFF00FFF5).withOpacity(0.8 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 1. Draw glowing selector circle with corner crosshairs
    canvas.drawCircle(Offset(centerX, centerY), radius * progress, paint);

    // Bounding corners (cybernetic lock brackets)
    final bracketLen = 8.0;
    final halfCell = radius * 0.9;
    final bracketsPath = Path();
    // Top Left
    bracketsPath.moveTo(centerX - halfCell, centerY - halfCell + bracketLen);
    bracketsPath.lineTo(centerX - halfCell, centerY - halfCell);
    bracketsPath.lineTo(centerX - halfCell + bracketLen, centerY - halfCell);
    // Top Right
    bracketsPath.moveTo(centerX + halfCell - bracketLen, centerY - halfCell);
    bracketsPath.lineTo(centerX + halfCell, centerY - halfCell);
    bracketsPath.lineTo(centerX + halfCell, centerY - halfCell + bracketLen);
    // Bottom Left
    bracketsPath.moveTo(centerX - halfCell, centerY + halfCell - bracketLen);
    bracketsPath.lineTo(centerX - halfCell, centerY + halfCell);
    bracketsPath.lineTo(centerX - halfCell + bracketLen, centerY + halfCell);
    // Bottom Right
    bracketsPath.moveTo(centerX + halfCell - bracketLen, centerY + halfCell);
    bracketsPath.lineTo(centerX + halfCell, centerY + halfCell);
    bracketsPath.lineTo(centerX + halfCell, centerY + halfCell - bracketLen);

    canvas.drawPath(bracketsPath, paint);

    // 2. Draw vertical dotted leader line pointing to capsule
    final lineStart = Offset(centerX, centerY + direction * radius);
    final lineEnd = Offset(centerX, centerY + direction * 55 * progress);

    final linePaint = Paint()
      ..color = const Color(0xFF00FFF5).withOpacity(0.5 * progress)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Draw dashed/dotted connector line
    double curY = lineStart.dy;
    final step = 4.0;
    final dash = 4.0;
    final targetY = lineEnd.dy;

    if (direction < 0) {
      // going up
      while (curY > targetY) {
        final nextY = (curY - dash).clamp(targetY, lineStart.dy);
        canvas.drawLine(Offset(centerX, curY), Offset(centerX, nextY), linePaint);
        curY -= (dash + step);
      }
    } else {
      // going down
      while (curY < targetY) {
        final nextY = (curY + dash).clamp(lineStart.dy, targetY);
        canvas.drawLine(Offset(centerX, curY), Offset(centerX, nextY), linePaint);
        curY += (dash + step);
      }
    }

    // Draw a small neon scanning dot at the tip of the line
    final dotPaint = Paint()
      ..color = const Color(0xFFFF2E93).withOpacity(0.9 * progress)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(lineEnd, 3.0, dotPaint);
  }

  @override
  bool shouldRepaint(covariant HudConnectorPainter oldDelegate) {
    return oldDelegate.centerX != centerX ||
        oldDelegate.centerY != centerY ||
        oldDelegate.direction != direction ||
        oldDelegate.progress != progress;
  }
}
