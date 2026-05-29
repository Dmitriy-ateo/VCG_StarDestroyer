import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/game_controller.dart';
import 'galaxy_board_screen.dart';
import '../services/audio_service.dart';

class CommandBridgeScreen extends StatefulWidget {
  final GameController controller;
  final VoidCallback onStartCampaign;
  final VoidCallback onStartGame;
  final VoidCallback onOpenShop;
  final VoidCallback onOpenMarket;
  final VoidCallback onBackToMenu;

  const CommandBridgeScreen({
    super.key,
    required this.controller,
    required this.onStartCampaign,
    required this.onStartGame,
    required this.onOpenShop,
    required this.onOpenMarket,
    required this.onBackToMenu,
  });

  @override
  State<CommandBridgeScreen> createState() => _CommandBridgeScreenState();
}

class _CommandBridgeScreenState extends State<CommandBridgeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  String _hoveredSection = 'none';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Automatically trigger deep space Command Bridge ambience music
    AudioService.instance.playBgm('audio/bridge_music.mp3');
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerHaptic() {
    HapticFeedback.selectionClick();
  }

  void _showSettingsDialog(BuildContext context) {
    _triggerHaptic();
    AudioService.instance.playSfx('audio/hud_click.mp3');
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isMusic = AudioService.instance.musicEnabled;
            final isSfx = AudioService.instance.sfxEnabled;

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1117).withOpacity(0.92),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00FFF5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FFF5).withOpacity(0.12),
                      blurRadius: 16,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.settings, color: Color(0xFF00FFF5), size: 24),
                        const SizedBox(width: 10),
                        const Text(
                          "BRIDGE AUDIO CONTROL",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF8B949E)),
                          onPressed: () {
                            _triggerHaptic();
                            AudioService.instance.playSfx('audio/hud_click.mp3');
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFF21262D), height: 16, thickness: 1),
                    const SizedBox(height: 12),

                    // Background Music Option
                    Row(
                      children: [
                        const Icon(Icons.music_note, color: Colors.amberAccent, size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "BACKGROUND MUSIC",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Cinematic retro space ambient loops",
                                style: TextStyle(
                                  color: Color(0xFF8B949E),
                                  fontSize: 9.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isMusic,
                          activeColor: const Color(0xFF00FFF5),
                          activeTrackColor: const Color(0xFF00FFF5).withOpacity(0.3),
                          onChanged: (val) async {
                            _triggerHaptic();
                            await AudioService.instance.toggleMusic(val);
                            if (val) {
                              await AudioService.instance.playBgm('audio/bridge_music.mp3');
                            }
                            setDialogState(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Sound Effects Option
                    Row(
                      children: [
                        const Icon(Icons.volume_up, color: Color(0xFFFF2E93), size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "SOUND EFFECTS",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Laser zaps, portal warps, and explosions",
                                style: TextStyle(
                                  color: Color(0xFF8B949E),
                                  fontSize: 9.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isSfx,
                          activeColor: const Color(0xFF00FFF5),
                          activeTrackColor: const Color(0xFF00FFF5).withOpacity(0.3),
                          onChanged: (val) async {
                            _triggerHaptic();
                            await AudioService.instance.toggleSfx(val);
                            if (val) {
                              await AudioService.instance.playSfx('audio/hud_click.mp3');
                            }
                            setDialogState(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Close Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF161B22),
                          foregroundColor: const Color(0xFF00FFF5),
                          side: const BorderSide(color: Color(0xFF00FFF5), width: 1.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          _triggerHaptic();
                          AudioService.instance.playSfx('audio/hud_click.mp3');
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "DISMISS CONFIG",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.0,
                            fontFamily: 'monospace',
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
      },
    );
  }

  void _showBriefingDialog(BuildContext context) {
    _triggerHaptic();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1117).withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00FFF5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFF5).withOpacity(0.15),
                  blurRadius: 16,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.menu_book, color: Color(0xFF00FFF5), size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      "TACTICAL BRIEFING",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF8B949E)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(color: Color(0xFF21262D), height: 24, thickness: 1),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("1. THE SUPERLASER BLUEPRINT"),
                        _buildSectionText(
                          "Admiral, the Death Star superlaser has been fitted with unstable vector focusing prisms. "
                          "Your goal is to guide the laser beams through space debris and asteroid obstacles to strike target planets simultaneously. "
                          "Reflectors rotate the beam by 90°. Drag and drop reflectors onto empty grid cells to calibrate the vector path."
                        ),
                        const SizedBox(height: 16),
                        _buildSectionHeader("2. PRISM CRYSTAL SPLITTERS"),
                        _buildSectionText(
                          "Splitters segment the laser into two separate paths! Standard splitters separate at 180°, "
                          "but special R&D models split at 45°, 90°, and 135°. "
                          "⚠️ NOTE: Level 1 splitters are unstable and drain exactly 1 laser power during bifurcation. "
                          "Upgrade splitters to Rank F ★ (Level 2+) in the Research Lab to enable 100% efficient, lossless splitting!"
                        ),
                        const SizedBox(height: 16),
                        _buildSectionHeader("3. TELEPORTATION PORTALS"),
                        _buildSectionText(
                          "Quantum Portals warp the laser beam across space folds! Beams entering Portal A instantly exit Portal B. "
                          "⚠️ NOTE: Level 1 portals are warp-unstable and drain exactly 1 laser power. "
                          "Upgrade Portals in the Research Lab to stabilize the wormhole for lossless transit!"
                        ),
                        const SizedBox(height: 16),
                        _buildSectionHeader("4. Breakable Barriers & Penetration"),
                        _buildSectionText(
                          "Some sectors are obstructed by high-tech barriers:\n"
                          "• 🛡️ Energy Shields (Cyan) - Melted by sufficient laser power.\n"
                          "• 💎 Crystal Matrixes (Violet) - Heavy crystals requiring high intensity to shatter.\n"
                          "• ⚙️ Scrap Metal (Amber) - Dense debris blocking low-power beams.\n"
                          "Piercing a breakable barrier shatters the block, allowing the laser to propagate forward while draining exactly 1 laser power."
                        ),
                        const SizedBox(height: 16),
                        _buildSectionHeader("5. RPG blue-Tech Upgrades"),
                        _buildSectionText(
                          "Spend Credits (C) in the Chassis Bay to upgrade Starting Laser Intensity, Aiming computers, and Chassis Blueprints. "
                          "Spend Research Points (RP) in the Research Lab to upgrade Reflectors, Splitters, Gravity Wells, Portals, and Volatile Bombs. "
                          "Blueprints progress from Rank F to SSS, with star sub-tiers (F -> F* -> F** -> F*** -> E). Each sub-tier unlocks massive physics boosts!"
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FFF5).withOpacity(0.1),
                      side: const BorderSide(color: Color(0xFF00FFF5), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "UNDERSTOOD, ADMIRAL",
                      style: TextStyle(
                        color: Color(0xFF00FFF5),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF00FFF5),
        fontWeight: FontWeight.bold,
        fontSize: 13,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFC9D1D9),
          fontSize: 11,
          height: 1.45,
        ),
      ),
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

  Widget _buildSettingsChip(IconData icon, String label, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22).withOpacity(0.85),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accentColor, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progression = widget.controller.progression;
    final unlockedGalaxiesCount = max(1, progression.completedGalaxyIds.length + 1);
    
    // Check if daily hard mission is active (uncompleted) in any galaxy
    final hasDailyAlert = progression.dailyHardGalaxyId != null &&
        !progression.dailyHardCompleted &&
        GalaxyBoardScreen.completedDailyCount < 10;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Captain Bridge visual background image - Full Screen
              Positioned.fill(
                child: Image.asset(
                  'assets/images/captain_bridge.png',
                  fit: BoxFit.fill,
                ),
              ),

              // Interactive Hotspot Overlays mapped proportionally to prevent coordinate drift
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final h = constraints.maxHeight;

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Tactical Market (Left Sliding Door)
                        _buildHotspot(
                          id: 'market',
                          label: "TACTICAL MARKET",
                          subsystem: "ARMORY SYSTEMS CACHE",
                          status: "Blueprints Stocked",
                          statusColor: const Color(0xFFFF2E93),
                          glowColor: const Color(0xFFFF2E93),
                          left: w * 0.06,
                          top: h * 0.30,
                          width: w * 0.22,
                          height: h * 0.30, // Perfectly aligned with the upper sliding door frame
                          centerOffset: const Offset(0.0, 0.0),
                          onTap: () {
                            _triggerHaptic();
                            widget.onOpenMarket();
                          },
                          screenWidth: w,
                        ),

                        // Tactical Briefing (Bottom-Left Desk)
                        _buildHotspot(
                          id: 'briefing',
                          label: "TACTICAL BRIEFING",
                          subsystem: "CAPTAIN'S DATA LOGS",
                          status: "TACTICAL LOGS SYNCED",
                          statusColor: const Color(0xFF00FFF5),
                          glowColor: const Color(0xFF00FFF5),
                          left: w * 0.08,
                          top: h * 0.64,
                          width: w * 0.46,
                          height: h * 0.24,
                          centerOffset: const Offset(0.0, 0.0),
                          onTap: () => _showBriefingDialog(context),
                          screenWidth: w,
                        ),

                        // Research Lab (Center Holographic upgrade table)
                        _buildHotspot(
                          id: 'research',
                          label: "RESEARCH LAB",
                          subsystem: "R&D QUANTUM ENGINES CORE",
                          status: "Blueprints Available",
                          statusColor: const Color(0xFF00E676),
                          glowColor: const Color(0xFF00E676),
                          left: w * 0.36,
                          top: h * 0.52,
                          width: w * 0.28,
                          height: h * 0.18,
                          centerOffset: const Offset(0.0, 0.0),
                          onTap: () {
                            _triggerHaptic();
                            widget.onOpenShop();
                          },
                          screenWidth: w,
                        ),

                        // Launch Campaign (Huge Outer Space window viewport)
                        _buildHotspot(
                          id: 'campaign',
                          label: "LAUNCH CAMPAIGN",
                          subsystem: "STAR NAVIGATION SYSTEM",
                          status: "$unlockedGalaxiesCount/3 GALAXIES UNLOCKED",
                          statusColor: const Color(0xFF00FFF5),
                          glowColor: const Color(0xFF00FFF5),
                          left: w * 0.40,
                          top: h * 0.18,
                          width: w * 0.55,
                          height: h * 0.34,
                          centerOffset: const Offset(0.0, 0.0),
                          onTap: () {
                            _triggerHaptic();
                            widget.onStartCampaign();
                          },
                          screenWidth: w,
                        ),

                        // Training Center (Bottom-Right Terminal console)
                        _buildHotspot(
                          id: 'training',
                          label: "TRAINING CENTER",
                          subsystem: "GUNNERY TARGET SIMULATOR",
                          status: "15 SECTORS LOADED",
                          statusColor: const Color(0xFFFFB703),
                          glowColor: const Color(0xFFFFB703),
                          left: w * 0.65,
                          top: h * 0.56,
                          width: w * 0.28,
                          height: h * 0.28,
                          centerOffset: const Offset(0.0, 0.0),
                          onTap: () {
                            _triggerHaptic();
                            widget.onStartGame();
                          },
                          screenWidth: w,
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Floating Header overlay (Semi-transparent background matches other screens)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    color: const Color(0xFF0B0E14).withOpacity(0.4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back, color: Color(0xFF00ADB5)),
                                    onPressed: () {
                                      _triggerHaptic();
                                      AudioService.instance.playSfx('audio/hud_click.mp3');
                                      widget.onBackToMenu();
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "COMMAND DECK",
                                          style: TextStyle(
                                            color: Color(0xFFFFFFFF),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "STAR DESTROYER BRIDGE",
                                          style: TextStyle(
                                            color: Color(0xFF00FFF5),
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.8,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _triggerHaptic();
                                    AudioService.instance.playSfx('audio/hud_click.mp3');
                                    widget.onOpenMarket();
                                  },
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: _buildStatChip(Icons.monetization_on, "${progression.credits}", Colors.amberAccent),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    _triggerHaptic();
                                    AudioService.instance.playSfx('audio/hud_click.mp3');
                                    widget.onOpenShop();
                                  },
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: _buildStatChip(Icons.science, "${progression.researchPoints} RP", Colors.purpleAccent),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    _triggerHaptic();
                                    AudioService.instance.playSfx('audio/hud_click.mp3');
                                    _showSettingsDialog(context);
                                  },
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: _buildSettingsChip(Icons.settings, "SETTINGS", const Color(0xFF00FFF5)),
                                  ),
                                ),
                                if (hasDailyAlert) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF1744).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFFF1744), width: 1.2),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.warning, color: Color(0xFFFF1744), size: 12),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 1,
                          color: const Color(0xFF00ADB5).withOpacity(0.15),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHotspot({
    required String id,
    required String label,
    required String subsystem,
    required String status,
    required Color statusColor,
    required Color glowColor,
    required double left,
    required double top,
    required double width,
    required double height,
    required Offset centerOffset,
    required VoidCallback onTap,
    required double screenWidth,
  }) {
    final isHovered = _hoveredSection == id;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            _hoveredSection = id;
          });
          HapticFeedback.selectionClick();
        },
        onExit: (_) {
          setState(() {
            _hoveredSection = 'none';
          });
        },
        child: GestureDetector(
          onTap: () {
            AudioService.instance.playSfx('audio/hud_click.mp3');
            onTap();
          },
          behavior: HitTestBehavior.opaque,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Pulsing concentric radar beacon when not hovered to suggest interactivity
              if (!isHovered)
                Center(
                  child: Transform.translate(
                    offset: centerOffset,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final value = _pulseController.value;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 16 + value * 24,
                              height: 16 + value * 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: glowColor.withOpacity(1.0 - value),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: glowColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: glowColor,
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

              // Fully Animated Futuristic Holographic/Cybernetic Overlay Layer on Hover
              if (isHovered)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _HotspotOverlayPainter(
                          id: id,
                          color: glowColor,
                          animationValue: _pulseController.value,
                        ),
                      );
                    },
                  ),
                ),

              // Floating micro glassmorphic tooltip card on hover (clamped to screen boundaries)
              if (isHovered)
                Positioned(
                  left: (left + (width - 165.0) / 2.0).clamp(16.0, screenWidth - 165.0 - 16.0) - left,
                  width: 165,
                  top: -85,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1117).withOpacity(0.95),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: glowColor.withOpacity(0.8), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: glowColor.withOpacity(0.20),
                            blurRadius: 8,
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subsystem,
                            style: TextStyle(
                              color: glowColor.withOpacity(0.8),
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: statusColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                status,
                                style: const TextStyle(
                                  color: Color(0xFF8B949E),
                                  fontSize: 6,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
    );
  }
}

class _HotspotOverlayPainter extends CustomPainter {
  final String id;
  final Color color;
  final double animationValue;

  _HotspotOverlayPainter({
    required this.id,
    required this.color,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 3D perspective quad projection points for each console bridge element
    Offset tl, tr, br, bl;
    if (id == 'campaign') {
      // Space Window viewport (horizontal perspective shift)
      tl = Offset(size.width * 0.12, size.height * 0.22);
      tr = Offset(size.width * 0.98, size.height * 0.17);
      br = Offset(size.width * 0.98, size.height * 1.02);
      bl = Offset(size.width * 0.12, size.height * 0.90);
    } else if (id == 'briefing') {
      // Bottom-Left desk monitor screen (tilted horizontally and skewed)
      tl = Offset(size.width * 0.12, size.height * 0.14);
      tr = Offset(size.width * 0.74, size.height * 0.48);
      br = Offset(size.width * 0.72, size.height * 0.88);
      bl = Offset(size.width * 0.10, size.height * 0.54);
    } else if (id == 'research') {
      // Center round table surface (flattened circular perspective)
      tl = Offset(size.width * 0.18, size.height * 0.65);
      tr = Offset(size.width * 0.82, size.height * 0.65);
      br = Offset(size.width * 0.74, size.height * 0.92);
      bl = Offset(size.width * 0.26, size.height * 0.92);
    } else if (id == 'market') {
      // Left door lock display (highly slanted vertical side perspective)
      tl = Offset(size.width * 0.24, size.height * 0.02);
      tr = Offset(size.width * 0.96, size.height * 0.05);
      br = Offset(size.width * 1.0, size.height * 0.86);
      bl = Offset(size.width * 0.24, size.height * 0.98);
    } else if (id == 'training') {
      // Bottom-Right control terminal console screen (slanted isometric screen)
      tl = Offset(size.width * 0.12, size.height * 0.25);
      tr = Offset(size.width * 0.82, size.height * 0.08);
      br = Offset(size.width * 0.80, size.height * 0.75);
      bl = Offset(size.width * 0.12, size.height * 0.90);
    } else {
      tl = Offset.zero;
      tr = Offset(size.width, 0);
      br = Offset(size.width, size.height);
      bl = Offset(0, size.height);
    }

    // Bilinear patch interpolation to map 2D coordinates [0, 1] into the perspective quad
    Offset getQuadPoint(double u, double v) {
      final top = Offset.lerp(tl, tr, u)!;
      final bottom = Offset.lerp(bl, br, u)!;
      return Offset.lerp(top, bottom, v)!;
    }

    final paint = Paint()
      ..color = color.withOpacity(0.35)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Draw perspective-aligned bounding box contour
    final borderPath = Path()
      ..moveTo(tl.dx, tl.dy)
      ..lineTo(tr.dx, tr.dy)
      ..lineTo(br.dx, br.dy)
      ..lineTo(bl.dx, bl.dy)
      ..close();
    canvas.drawPath(borderPath, paint);

    if (id == 'campaign') {
      // 1. LAUNCH CAMPAIGN (Space Window): Perspective grid & scope
      final linePaint = Paint()
        ..color = color.withOpacity(0.12)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke;

      // Draw horizontal & vertical perspective grid lines
      const gridCount = 6;
      for (int i = 1; i < gridCount; i++) {
        final ratio = i / gridCount;
        canvas.drawLine(getQuadPoint(0, ratio), getQuadPoint(1, ratio), linePaint);
        canvas.drawLine(getQuadPoint(ratio, 0), getQuadPoint(ratio, 1), linePaint);
      }

      // Draw sweeping scanner bar
      final scanV = animationValue;
      final scanPaint = Paint()
        ..color = color
        ..strokeWidth = 2.0
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withOpacity(0.0),
            color,
            color.withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTRB(0, size.height * scanV - 8, size.width, size.height * scanV + 8));
      
      canvas.drawLine(getQuadPoint(0, scanV), getQuadPoint(1, scanV), scanPaint);

      // Draw perspective-correct elliptical central targeting reticle
      final reticlePath = Path();
      const circleSegments = 32;
      for (int i = 0; i <= circleSegments; i++) {
        final a = (i / circleSegments) * 2 * pi;
        // Map reticle circle centered at u=0.60, v=0.45 with radius proportional to perspective
        final pt = getQuadPoint(0.60 + 0.08 * cos(a), 0.45 + 0.12 * sin(a));
        if (i == 0) {
          reticlePath.moveTo(pt.dx, pt.dy);
        } else {
          reticlePath.lineTo(pt.dx, pt.dy);
        }
      }
      canvas.drawPath(reticlePath, Paint()..color = color..strokeWidth = 1.5..style = PaintingStyle.stroke);

      // reticle center indicator dot
      final centerPt = getQuadPoint(0.60, 0.45);
      canvas.drawCircle(centerPt, 3.5, Paint()..color = color..style = PaintingStyle.fill);

      // Reticle ticks aligned with perspective vectors
      final ticksPaint = Paint()..color = color..strokeWidth = 1.5;
      canvas.drawLine(getQuadPoint(0.60 - 0.11, 0.45), getQuadPoint(0.60 - 0.08, 0.45), ticksPaint);
      canvas.drawLine(getQuadPoint(0.60 + 0.08, 0.45), getQuadPoint(0.60 + 0.11, 0.45), ticksPaint);
      canvas.drawLine(getQuadPoint(0.60, 0.45 - 0.16), getQuadPoint(0.60, 0.45 - 0.12), ticksPaint);
      canvas.drawLine(getQuadPoint(0.60, 0.45 + 0.12), getQuadPoint(0.60, 0.45 + 0.16), ticksPaint);

    } else if (id == 'research') {
      // 2. RESEARCH LAB (Hologram Table): 3D wireframe floating blueprint prism
      final ringPaint = Paint()
        ..color = color.withOpacity(0.4)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;

      // Projector base perspective ellipses on the table surface
      final projectorPath1 = Path();
      final projectorPath2 = Path();
      const tableSegments = 32;
      for (int i = 0; i <= tableSegments; i++) {
        final a = (i / tableSegments) * 2 * pi;
        final pt1 = getQuadPoint(0.5 + 0.35 * cos(a), 0.5 + 0.35 * sin(a));
        final pt2 = getQuadPoint(0.5 + 0.23 * cos(a), 0.5 + 0.23 * sin(a));
        if (i == 0) {
          projectorPath1.moveTo(pt1.dx, pt1.dy);
          projectorPath2.moveTo(pt2.dx, pt2.dy);
        } else {
          projectorPath1.lineTo(pt1.dx, pt1.dy);
          projectorPath2.lineTo(pt2.dx, pt2.dy);
        }
      }
      canvas.drawPath(projectorPath1, ringPaint);
      canvas.drawPath(projectorPath2, Paint()..color = color.withOpacity(0.2)..strokeWidth = 0.8..style = PaintingStyle.stroke);

      // Table center projected point
      final tableCenter = getQuadPoint(0.5, 0.5);

      // Floating 3D Wireframe blueprint coordinates
      final floatY = size.height * 0.35 + 5.0 * sin(animationValue * 2 * pi);
      final prCenter = Offset(size.width / 2, floatY);
      
      final rotAngle = animationValue * 2 * pi;
      final prRadiusX = size.width * 0.22;
      final prRadiusY = 6.0;

      // Pyramid apex
      final apex = Offset(prCenter.dx, prCenter.dy - 22.0);

      // 3 Base points rotated around center axis
      final base1 = Offset(prCenter.dx + prRadiusX * cos(rotAngle), prCenter.dy + prRadiusY * sin(rotAngle));
      final base2 = Offset(prCenter.dx + prRadiusX * cos(rotAngle + 2 * pi / 3), prCenter.dy + prRadiusY * sin(rotAngle + 2 * pi / 3));
      final base3 = Offset(prCenter.dx + prRadiusX * cos(rotAngle + 4 * pi / 3), prCenter.dy + prRadiusY * sin(rotAngle + 4 * pi / 3));

      final wirePaint = Paint()
        ..color = color
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      // Draw wireframe base lines
      canvas.drawLine(base1, base2, wirePaint);
      canvas.drawLine(base2, base3, wirePaint);
      canvas.drawLine(base3, base1, wirePaint);

      // Draw apex connector lines
      canvas.drawLine(base1, apex, wirePaint);
      canvas.drawLine(base2, apex, wirePaint);
      canvas.drawLine(base3, apex, wirePaint);

      // Holographic projection rays from base projector to floating wireframe vertices
      final rayPaint = Paint()
        ..color = color.withOpacity(0.15)
        ..strokeWidth = 0.8;
      canvas.drawLine(tableCenter, base1, rayPaint);
      canvas.drawLine(tableCenter, base2, rayPaint);
      canvas.drawLine(tableCenter, base3, rayPaint);

    } else if (id == 'market') {
      // 3. TACTICAL MARKET (Sliding Door): Auth lock decryption scan
      final lockPaint = Paint()
        ..color = color
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      const padding = 0.05;
      const bracketLen = 0.15;

      // Perspective corners on door panel
      canvas.drawPath(Path()..moveTo(getQuadPoint(padding, padding + bracketLen).dx, getQuadPoint(padding, padding + bracketLen).dy)..lineTo(getQuadPoint(padding, padding).dx, getQuadPoint(padding, padding).dy)..lineTo(getQuadPoint(padding + bracketLen, padding).dx, getQuadPoint(padding + bracketLen, padding).dy), lockPaint);
      canvas.drawPath(Path()..moveTo(getQuadPoint(1 - padding - bracketLen, padding).dx, getQuadPoint(1 - padding - bracketLen, padding).dy)..lineTo(getQuadPoint(1 - padding, padding).dx, getQuadPoint(1 - padding, padding).dy)..lineTo(getQuadPoint(1 - padding, padding + bracketLen).dx, getQuadPoint(1 - padding, padding + bracketLen).dy), lockPaint);
      canvas.drawPath(Path()..moveTo(getQuadPoint(padding, 1 - padding - bracketLen).dx, getQuadPoint(padding, 1 - padding - bracketLen).dy)..lineTo(getQuadPoint(padding, 1 - padding).dx, getQuadPoint(padding, 1 - padding).dy)..lineTo(getQuadPoint(padding + bracketLen, 1 - padding).dx, getQuadPoint(padding + bracketLen, 1 - padding).dy), lockPaint);
      canvas.drawPath(Path()..moveTo(getQuadPoint(1 - padding - bracketLen, 1 - padding).dx, getQuadPoint(1 - padding - bracketLen, 1 - padding).dy)..lineTo(getQuadPoint(1 - padding, 1 - padding).dx, getQuadPoint(1 - padding, 1 - padding).dy)..lineTo(getQuadPoint(1 - padding, 1 - padding - bracketLen).dx, getQuadPoint(1 - padding, 1 - padding - bracketLen).dy), lockPaint);

      // Sweeping vertical authentication line
      final scanV = 0.15 + 0.70 * (0.5 + 0.5 * sin(animationValue * 2 * pi));
      canvas.drawLine(getQuadPoint(padding, scanV), getQuadPoint(1 - padding, scanV), lockPaint);

      // Decryption active scanner grid bits at bottom
      final dotCount = 4;
      for (int i = 0; i < dotCount; i++) {
        final dotU = 0.3 + i * 0.14;
        final dotV = 0.8;
        final isActive = ((animationValue * 4).floor() % dotCount) == i;
        final dotCenter = getQuadPoint(dotU, dotV);
        canvas.drawRect(
          Rect.fromCenter(center: dotCenter, width: 4, height: 4),
          Paint()..color = isActive ? color : color.withOpacity(0.15)..style = PaintingStyle.fill,
        );
      }

    } else if (id == 'briefing') {
      // 4. TACTICAL BRIEFING (Desk Screen): Perspective oscilloscope waveform
      final gridPaint = Paint()
        ..color = color.withOpacity(0.12)
        ..strokeWidth = 0.6;

      // Draw screen background fill
      canvas.drawPath(borderPath, Paint()..color = const Color(0xFF0D1117).withOpacity(0.4)..style = PaintingStyle.fill);

      // Draw grid lines
      const screenLines = 4;
      for (int i = 1; i < screenLines; i++) {
        final ratio = i / screenLines;
        canvas.drawLine(getQuadPoint(0, ratio), getQuadPoint(1, ratio), gridPaint);
        canvas.drawLine(getQuadPoint(ratio, 0), getQuadPoint(ratio, 1), gridPaint);
      }

      // Draw active telemetry sine wave graph skewed in perspective
      final wavePath = Path();
      const segments = 45;
      for (int i = 0; i <= segments; i++) {
        final u = i / segments;
        final angle = u * 4 * pi + animationValue * 2 * pi;
        final v = 0.5 + 0.28 * sin(angle);
        final pt = getQuadPoint(u, v);
        if (i == 0) {
          wavePath.moveTo(pt.dx, pt.dy);
        } else {
          wavePath.lineTo(pt.dx, pt.dy);
        }
      }

      canvas.drawPath(
        wavePath, 
        Paint()
          ..color = color
          ..strokeWidth = 1.8
          ..style = PaintingStyle.stroke
      );

    } else if (id == 'training') {
      // 5. TRAINING CENTER (Console screen): Weapons sonar radar sweep
      // Radar outer perspective circle
      final radarPath = Path();
      const radarSegments = 32;
      for (int i = 0; i <= radarSegments; i++) {
        final a = (i / radarSegments) * 2 * pi;
        final pt = getQuadPoint(0.5 + 0.38 * cos(a), 0.5 + 0.38 * sin(a));
        if (i == 0) {
          radarPath.moveTo(pt.dx, pt.dy);
        } else {
          radarPath.lineTo(pt.dx, pt.dy);
        }
      }
      canvas.drawPath(radarPath, Paint()..color = color.withOpacity(0.2)..strokeWidth = 1.0..style = PaintingStyle.stroke);

      // Concentric inner perspective ring
      final innerPath = Path();
      for (int i = 0; i <= radarSegments; i++) {
        final a = (i / radarSegments) * 2 * pi;
        final pt = getQuadPoint(0.5 + 0.19 * cos(a), 0.5 + 0.19 * sin(a));
        if (i == 0) {
          innerPath.moveTo(pt.dx, pt.dy);
        } else {
          innerPath.lineTo(pt.dx, pt.dy);
        }
      }
      canvas.drawPath(innerPath, Paint()..color = color.withOpacity(0.08)..strokeWidth = 0.6..style = PaintingStyle.stroke);

      // Sonar sweeper center
      final centerPt = getQuadPoint(0.5, 0.5);

      // Radar sweep line skewed to perspective
      final sweepAngle = animationValue * 2 * pi;
      final sweeperEnd = getQuadPoint(0.5 + 0.38 * cos(sweepAngle), 0.5 + 0.38 * sin(sweepAngle));
      canvas.drawLine(centerPt, sweeperEnd, Paint()..color = color..strokeWidth = 1.5);

      // Radar sweeps trail lines mapped to perspective
      const trailCount = 5;
      for (int i = 1; i <= trailCount; i++) {
        final trailAngle = sweepAngle - (i * 0.08);
        final trailEnd = getQuadPoint(0.5 + 0.38 * cos(trailAngle), 0.5 + 0.38 * sin(trailAngle));
        canvas.drawLine(
          centerPt, 
          trailEnd, 
          Paint()
            ..color = color.withOpacity(0.2 * (1.0 - (i / trailCount)))
            ..strokeWidth = 1.0
        );
      }

      // Blinking target lock on console
      final targetAngle = 0.8;
      final targetPt = getQuadPoint(0.5 + 0.28 * cos(targetAngle), 0.5 + 0.28 * sin(targetAngle));
      
      final blinkState = (animationValue * 6).floor() % 2 == 0;
      if (blinkState) {
        canvas.drawPath(
          Path()
            ..moveTo(targetPt.dx - 4, targetPt.dy - 4)
            ..lineTo(targetPt.dx + 4, targetPt.dy - 4)
            ..lineTo(targetPt.dx + 4, targetPt.dy + 4)
            ..lineTo(targetPt.dx - 4, targetPt.dy + 4)
            ..close(),
          Paint()..color = const Color(0xFFFF1744)..strokeWidth = 1.0..style = PaintingStyle.stroke,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HotspotOverlayPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.id != id;
  }
}
