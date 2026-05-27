import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/device_model.dart';
import '../models/level_data.dart';
import '../game/game_controller.dart';
import '../widgets/board_painter.dart';

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

  @override
  void initState() {
    super.initState();
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();

    _aimAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    _aimAnimationController.dispose();
    super.dispose();
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
        text = "🪐 [Planet: ${planet.name}]\nTarget rebel base. Direct the superlaser here to destroy it.";
        break;
      }
    }

    // 2. Check Walls
    if (text == null) {
      for (var wall in widget.controller.currentLevel.walls) {
        if (wall.gridX == x && wall.gridY == y) {
          if (wall.type == 'energyShield') {
            final isPenetrated = widget.controller.progression.laserIntensityLevel >= (wall.requiredLaserPower ?? 999);
            final statusText = isPenetrated ? "⚠️ PENETRATED (Laser Power >= ${wall.requiredLaserPower})" : "❌ BLOCKED (Requires Laser Power ${wall.requiredLaserPower})";
            text = "🛡️ [Energy Shield]\n$statusText\nLaser power decreases by 1 on penetration.";
          } else if (wall.type == 'crystal') {
            final isPenetrated = widget.controller.progression.laserIntensityLevel >= (wall.requiredLaserPower ?? 999);
            final statusText = isPenetrated ? "⚠️ PENETRATED (Laser Power >= ${wall.requiredLaserPower})" : "❌ BLOCKED (Requires Laser Power ${wall.requiredLaserPower})";
            text = "💎 [Crystal Matrix]\n$statusText\nLaser power decreases by 1 on penetration.";
          } else if (wall.type == 'scrapMetal') {
            final isPenetrated = widget.controller.progression.laserIntensityLevel >= (wall.requiredLaserPower ?? 999);
            final statusText = isPenetrated ? "⚠️ PENETRATED (Laser Power >= ${wall.requiredLaserPower})" : "❌ BLOCKED (Requires Laser Power ${wall.requiredLaserPower})";
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
    switch (dev.type) {
      case DeviceType.reflector:
        return "🪞 [Reflector]\nBounces the laser at 90° angles. Tap to rotate.";
      case DeviceType.splitter:
        return "📐 [Splitter (${dev.splitAngleDegrees?.toStringAsFixed(0)}°)]\nSplits the incoming laser into twin beams. Tap to rotate.";
      case DeviceType.portal:
        return "🌀 [Quantum Portal]\nTeleports the incoming laser beam instantly to its paired portal.";
      case DeviceType.gravityWell:
        return "🕳️ [Gravity Well]\nGenerates a gravity pull that continuously curves the laser beam path.";
      case DeviceType.bomb:
        return "💣 [Tactical Bomb]\nDetonates in a 2.2-unit radius when hit, destroying all nearby planets.";
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
                  onPressed: widget.onBackToMenu,
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
              
              final x = ((details.localPosition.dx - offsetX) / cellW).floor();
              final y = ((details.localPosition.dy - offsetY) / cellH).floor();

              // Check if selecting to place a device
              if (widget.controller.selectedInventoryDevice != null) {
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
            onDoubleTapDown: (details) {
              _hideTooltip();
              if (widget.controller.playState != PlayState.editing) return;

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
                widget.controller.removeDevice(clickedDevice);
                HapticFeedback.mediumImpact();
              }
            },
            onLongPressStart: (details) {
              final x = ((details.localPosition.dx - offsetX) / cellW).floor();
              final y = ((details.localPosition.dy - offsetY) / cellH).floor();
              _showTooltipAt(x, y, details.localPosition);
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
                  ? const Center(
                      child: Text(
                        "ALL BLUEPRINTS PLACED",
                        style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
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
            if (isEditing && widget.controller.inventory.isNotEmpty) ...[
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
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
}
