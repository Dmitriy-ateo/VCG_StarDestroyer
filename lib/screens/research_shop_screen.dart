import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/device_model.dart';
import '../models/game_progression.dart';
import '../game/game_controller.dart';
import '../services/audio_service.dart';

class ResearchShopScreen extends StatelessWidget {
  final GameController controller;
  final VoidCallback onBackToGame;
  final VoidCallback onGoToShop;

  const ResearchShopScreen({
    super.key,
    required this.controller,
    required this.onBackToGame,
    required this.onGoToShop,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final progression = controller.progression;

          return DefaultTabController(
            length: 2,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  children: [
                    // Unified One-Row Header
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
                                  AudioService.instance.playSfx('audio/hud_click.mp3');
                                  onBackToGame();
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
                                      "R&D COMMAND CONSOLE",
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
                                      "TECHNOLOGY UPGRADE TERMINAL",
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
                        // Currency Statuses
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                AudioService.instance.playSfx('audio/hud_click.mp3');
                                onGoToShop();
                              },
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: _buildStatChip(Icons.monetization_on, "${progression.credits}", Colors.amberAccent),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                              },
                              child: _buildStatChip(Icons.science, "${progression.researchPoints} RP", Colors.purpleAccent),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 1,
                      color: const Color(0xFF00ADB5).withOpacity(0.15),
                    ),
                    const SizedBox(height: 12),
                    
                    // Subtitle
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00ADB5).withOpacity(0.06),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "NOTIFICATION: Chassis and Device upgrades improve superlaser capacities across all sectors.",
                        style: TextStyle(color: Color(0xFF00ADB5), fontSize: 10, fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cyberpunk Neon TabBar
                    TabBar(
                      onTap: (index) {
                        AudioService.instance.playSfx('audio/hud_click.mp3');
                      },
                      labelColor: const Color(0xFF00FFF5),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: const Color(0xFF00ADB5),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: const Color(0xFF00ADB5).withOpacity(0.15),
                      tabs: const [
                        Tab(
                          icon: Icon(Icons.build_circle_outlined, size: 20),
                          text: "CHASSIS UPGRADES",
                        ),
                        Tab(
                          icon: Icon(Icons.biotech_outlined, size: 20),
                          text: "DEVICE RESEARCH",
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // TabBarView content
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Tab 1: Sub-system Upgrades (Credits)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ListView(
                              children: [
                                _buildUpgradeCard(
                                  context: context,
                                  title: "Laser Intensity Core",
                                  description: "Amplifies superlaser energy throughput. Binds thermal particles for larger beam diameter.",
                                  icon: Icons.bolt,
                                  upgradeType: "intensity",
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(height: 16),
                                _buildUpgradeCard(
                                  context: context,
                                  title: "Tactical Aiming Computer",
                                  description: "Projects anticipated ray paths around gravity wells and reflectors on your radar matrix.",
                                  icon: Icons.radar,
                                  upgradeType: "aiming",
                                  color: const Color(0xFF00ADB5),
                                ),
                                const SizedBox(height: 16),
                                _buildUpgradeCard(
                                  context: context,
                                  title: "Deflector Sub-Chassis",
                                  description: "Increases structural load capacity allowing more reflectors to be loaded simultaneously.",
                                  icon: Icons.layers,
                                  upgradeType: "chassis",
                                  color: Colors.amberAccent,
                                ),
                              ],
                            ),
                          ),

                          // Tab 2: Device Architecture Research (RP)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ListView(
                              children: [
                                // Splitter variants
                                _buildSplitterAngleResearchCard(
                                  context: context,
                                  title: "Splitter Variant 180°",
                                  description: "Splits ray into directly opposite paths. Essential for dual planetary orbits.",
                                  angle: 180.0,
                                  cost: GameProgression.getSplitterResearchCost(180.0),
                                  isUnlocked: progression.unlockedSplitterAngles.contains(180.0),
                                  glowColor: const Color(0xFFFF2E93),
                                ),
                                const SizedBox(height: 16),
                                _buildSplitterAngleResearchCard(
                                  context: context,
                                  title: "Splitter Variant 90°",
                                  description: "Splits incoming beam at a perfect right angle. Excellent for corner grids.",
                                  angle: 90.0,
                                  cost: GameProgression.getSplitterResearchCost(90.0),
                                  isUnlocked: progression.unlockedSplitterAngles.contains(90.0),
                                  glowColor: const Color(0xFFE0245E),
                                ),
                                const SizedBox(height: 16),
                                _buildSplitterAngleResearchCard(
                                  context: context,
                                  title: "Splitter Variant 135°",
                                  description: "Splits incoming beam diagonally outward. Bypasses offset solar panels.",
                                  angle: 135.0,
                                  cost: GameProgression.getSplitterResearchCost(135.0),
                                  isUnlocked: progression.unlockedSplitterAngles.contains(135.0),
                                  glowColor: const Color(0xFFFFB703),
                                ),
                                const SizedBox(height: 16),
                                _buildSplitterAngleResearchCard(
                                  context: context,
                                  title: "Splitter Variant 45°",
                                  description: "Splits beam outward at sharp diagonal. Sneaks past asteroid shields.",
                                  angle: 45.0,
                                  cost: GameProgression.getSplitterResearchCost(45.0),
                                  isUnlocked: progression.unlockedSplitterAngles.contains(45.0),
                                  glowColor: const Color(0xFF00FFF5),
                                ),
                                const SizedBox(height: 16),
                                // Other devices
                                _buildDeviceResearchCard(
                                  context: context,
                                  title: "Standard Deflector Reflector",
                                  description: "High-grade glass deflector mirror reflecting laser rays at 90° angles.",
                                  type: DeviceType.reflector,
                                  cost: GameProgression.getDeviceResearchCost(DeviceType.reflector),
                                  isUnlocked: progression.unlockedDevices.contains(DeviceType.reflector),
                                ),
                                const SizedBox(height: 16),
                                _buildDeviceResearchCard(
                                  context: context,
                                  title: "Dual Prism Splitter Core",
                                  description: "Prismatic splitter core. Stabilizes splitting to prevent beam attenuation at Level 2+.",
                                  type: DeviceType.splitter,
                                  cost: GameProgression.getDeviceResearchCost(DeviceType.splitter),
                                  isUnlocked: progression.unlockedDevices.contains(DeviceType.splitter),
                                ),
                                const SizedBox(height: 16),
                                _buildDeviceResearchCard(
                                  context: context,
                                  title: "Anti-Matter Trigger Bomb",
                                  description: "Proximity explosives reacting violently with high-charge lasers.",
                                  type: DeviceType.bomb,
                                  cost: GameProgression.getDeviceResearchCost(DeviceType.bomb),
                                  isUnlocked: progression.unlockedDevices.contains(DeviceType.bomb),
                                ),
                                const SizedBox(height: 16),
                                _buildDeviceResearchCard(
                                  context: context,
                                  title: "Singularity Gravity Well",
                                  description: "Generates microscopic black holes that bend laser rays dynamically.",
                                  type: DeviceType.gravityWell,
                                  cost: GameProgression.getDeviceResearchCost(DeviceType.gravityWell),
                                  isUnlocked: progression.unlockedDevices.contains(DeviceType.gravityWell),
                                ),
                                const SizedBox(height: 16),
                                _buildDeviceResearchCard(
                                  context: context,
                                  title: "Cosmic Warp Portals",
                                  description: "Einstein-Rosen bridges linking spatial grid indexes for ray transit.",
                                  type: DeviceType.portal,
                                  cost: GameProgression.getDeviceResearchCost(DeviceType.portal),
                                  isUnlocked: progression.unlockedDevices.contains(DeviceType.portal),
                                ),
                                const SizedBox(height: 16),
                                _buildDeviceResearchCard(
                                  context: context,
                                  title: "Floating Deflection Asteroid",
                                  description: "Organic space rocks. Shatters when hit, deflecting lasers at its precise placement angle.",
                                  type: DeviceType.floatingAsteroid,
                                  cost: GameProgression.getDeviceResearchCost(DeviceType.floatingAsteroid),
                                  isUnlocked: progression.unlockedDevices.contains(DeviceType.floatingAsteroid),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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

  Widget _buildUpgradeCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required String upgradeType,
    required Color color,
  }) {
    final progression = controller.progression;
    final rank = progression.chassisRanks[upgradeType] ?? 'F';
    final stars = progression.chassisStars[upgradeType] ?? 0;
    final subLevel = progression.chassisSubLevels[upgradeType] ?? 1;

    final cost = GameProgression.getChassisUpgradeCost(rank, stars, subLevel);
    final canBuy = cost > 0 && progression.credits >= cost;

    final rankColor = rank == 'SSS' || rank == 'SS' || rank == 'S'
        ? const Color(0xFFFF007F)
        : (rank == 'A' || rank == 'B'
            ? const Color(0xFFFFB703)
            : (rank == 'C' || rank == 'D'
                ? const Color(0xFF00E676)
                : const Color(0xFF00FFF5)));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22).withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rankColor.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: rankColor.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Rank Badge (Chassis upgrades)
              RankBadgeWidget(
                rank: rank,
                stars: stars,
                subLevel: subLevel,
                isUnlocked: true,
                size: 56,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: rankColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: rankColor.withOpacity(0.4), width: 0.8),
                          ),
                          child: Text(
                            "RANK $rank",
                            style: TextStyle(
                              color: rankColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1117),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF21262D), width: 1.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "SUB-LEVEL: ",
                          style: TextStyle(
                            color: rankColor.withOpacity(0.8),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          "$subLevel / 5",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (stars > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            "★" * stars,
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(5, (index) {
                        final active = index < subLevel;
                        return Container(
                          width: 14,
                          height: 6,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: active ? rankColor : Colors.transparent,
                            border: Border.all(
                              color: active ? rankColor : const Color(0xFF30363D),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(1.5),
                            boxShadow: active
                                ? [
                                    BoxShadow(
                                      color: rankColor.withOpacity(0.4),
                                      blurRadius: 3,
                                    )
                                  ]
                                : null,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                cost > 0
                    ? ElevatedButton(
                        onPressed: canBuy
                            ? () {
                                controller.buyUpgrade(upgradeType);
                                AudioService.instance.playSfx('audio/upgrade.mp3');
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
                                      side: BorderSide(color: rankColor.withOpacity(0.8), width: 1.5),
                                    ),
                                    content: Row(
                                      children: [
                                        Icon(Icons.verified, color: rankColor, size: 18),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            "Upgraded $title successfully!",
                                            style: TextStyle(color: rankColor, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: rankColor.withOpacity(0.12),
                          foregroundColor: rankColor,
                          disabledBackgroundColor: const Color(0xFF21262D),
                          disabledForegroundColor: const Color(0xFF484F58),
                          side: BorderSide(
                            color: canBuy ? rankColor.withOpacity(0.5) : Colors.transparent,
                            width: 1.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.upgrade, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              "BUY: $cost C",
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.greenAccent.withOpacity(0.3), width: 0.8),
                        ),
                        child: const Text(
                          "MAX TECH SPEC REACHED",
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceResearchCard({
    required BuildContext context,
    required String title,
    required String description,
    required DeviceType type,
    required int cost,
    required bool isUnlocked,
  }) {
    final progression = controller.progression;
    final rank = progression.deviceRanks[type] ?? 'F';
    final stars = progression.deviceStars[type] ?? 0;
    final subLevel = progression.deviceSubLevels[type] ?? 1;

    final upgradeCost = GameProgression.getDeviceUpgradeCost(rank, stars, subLevel);
    final canResearch = !isUnlocked && progression.researchPoints >= cost;
    final canUpgrade = isUnlocked && upgradeCost > 0 && progression.researchPoints >= upgradeCost;

    final rankColor = isUnlocked
        ? (rank == 'SSS' || rank == 'SS' || rank == 'S'
            ? const Color(0xFFFF007F)
            : (rank == 'A' || rank == 'B'
                ? const Color(0xFFFFB703)
                : (rank == 'C' || rank == 'D'
                    ? const Color(0xFF00E676)
                    : const Color(0xFF00FFF5))))
        : const Color(0xFF454F5E);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22).withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? rankColor.withOpacity(0.4) : const Color(0xFF393E46),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isUnlocked ? rankColor.withOpacity(0.05) : Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Rank Badge (Redesigned)
              RankBadgeWidget(
                rank: rank,
                stars: stars,
                subLevel: subLevel,
                isUnlocked: isUnlocked,
                size: 56,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        if (isUnlocked)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: rankColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: rankColor.withOpacity(0.4), width: 0.8),
                            ),
                            child: Text(
                              "RANK $rank",
                              style: TextStyle(
                                color: rankColor,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isUnlocked) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF21262D), width: 1.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "SUB-LEVEL: ",
                            style: TextStyle(
                              color: rankColor.withOpacity(0.8),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            "$subLevel / 5",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (stars > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              "★" * stars,
                              style: const TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: List.generate(5, (index) {
                          final active = index < subLevel;
                          return Container(
                            width: 14,
                            height: 6,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: active ? rankColor : Colors.transparent,
                              border: Border.all(
                                color: active ? rankColor : const Color(0xFF30363D),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(1.5),
                              boxShadow: active
                                  ? [
                                      BoxShadow(
                                        color: rankColor.withOpacity(0.4),
                                        blurRadius: 3,
                                      )
                                    ]
                                  : null,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                  upgradeCost > 0
                      ? ElevatedButton(
                          onPressed: canUpgrade
                              ? () {
                                  controller.upgradeDevice(type);
                                  AudioService.instance.playSfx('audio/upgrade.mp3');
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
                                        side: BorderSide(color: rankColor.withOpacity(0.8), width: 1.5),
                                      ),
                                      content: Row(
                                        children: [
                                          Icon(Icons.flash_on, color: rankColor, size: 18),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              "Upgraded $title tech specs!",
                                              style: TextStyle(color: rankColor, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: rankColor.withOpacity(0.12),
                            foregroundColor: rankColor,
                            disabledBackgroundColor: const Color(0xFF21262D),
                            disabledForegroundColor: const Color(0xFF484F58),
                            side: BorderSide(
                              color: canUpgrade ? rankColor.withOpacity(0.5) : Colors.transparent,
                              width: 1.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.upgrade, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                "UPGRADE: $upgradeCost RP",
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.greenAccent.withOpacity(0.3), width: 0.8),
                          ),
                          child: const Text(
                            "MAX TECH SPEC REACHED",
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: canResearch
                      ? () {
                          controller.unlockDeviceBlueprint(type);
                          final messenger = ScaffoldMessenger.of(context);
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
                                side: const BorderSide(color: Colors.purpleAccent, width: 1.5),
                              ),
                              content: Row(
                                children: [
                                  const Icon(Icons.science, color: Colors.purpleAccent, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Unlocked $title Blueprints!",
                                      style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent.withOpacity(0.12),
                    foregroundColor: Colors.purpleAccent,
                    disabledBackgroundColor: const Color(0xFF21262D),
                    disabledForegroundColor: const Color(0xFF484F58),
                    side: BorderSide(
                      color: canResearch ? Colors.purpleAccent.withOpacity(0.5) : Colors.transparent,
                      width: 1.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.science, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        "RESEARCH CORE: $cost RP",
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSplitterAngleResearchCard({
    required BuildContext context,
    required String title,
    required String description,
    required double angle,
    required int cost,
    required bool isUnlocked,
    required Color glowColor,
  }) {
    final canResearch = !isUnlocked && controller.progression.researchPoints >= cost;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isUnlocked ? glowColor.withOpacity(0.4) : const Color(0xFF393E46)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isUnlocked ? glowColor.withOpacity(0.1) : const Color(0xFF222831),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.call_split, color: isUnlocked ? glowColor : Colors.grey, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          isUnlocked
              ? Column(
                  children: [
                    Icon(Icons.verified, color: glowColor, size: 24),
                    const SizedBox(height: 4),
                    Text("RESEARCHED", style: TextStyle(color: glowColor, fontSize: 9, fontWeight: FontWeight.bold)),
                  ],
                )
              : ElevatedButton(
                  onPressed: canResearch
                      ? () {
                          controller.unlockSplitterVariant(angle);
                          final messenger = ScaffoldMessenger.of(context);
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
                                side: const BorderSide(color: Colors.purpleAccent, width: 1.5),
                              ),
                              content: Row(
                                children: [
                                  const Icon(Icons.science, color: Colors.purpleAccent, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Unlocked $title Blueprints!",
                                      style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent.withOpacity(0.2),
                    foregroundColor: Colors.purpleAccent,
                    disabledBackgroundColor: const Color(0xFF222831),
                    disabledForegroundColor: Colors.grey,
                  ),
                  child: Text("$cost RP"),
                ),
        ],
      ),
    );
  }


}

class RankBadgeWidget extends StatelessWidget {
  final String rank;
  final int stars;
  final int subLevel;
  final bool isUnlocked;
  final double size;

  const RankBadgeWidget({
    super.key,
    required this.rank,
    required this.stars,
    required this.subLevel,
    required this.isUnlocked,
    this.size = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RankBadgePainter(
          rank: rank,
          stars: stars,
          subLevel: subLevel,
          isUnlocked: isUnlocked,
        ),
      ),
    );
  }
}

class _RankBadgePainter extends CustomPainter {
  final String rank;
  final int stars;
  final int subLevel;
  final bool isUnlocked;

  _RankBadgePainter({
    required this.rank,
    required this.stars,
    required this.subLevel,
    required this.isUnlocked,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Color rankColor;
    if (!isUnlocked) {
      rankColor = const Color(0xFF454F5E);
    } else {
      if (rank == 'SSS' || rank == 'SS' || rank == 'S') {
        rankColor = const Color(0xFFFF007F);
      } else if (rank == 'A' || rank == 'B') {
        rankColor = const Color(0xFFFFB703);
      } else if (rank == 'C' || rank == 'D') {
        rankColor = const Color(0xFF00E676);
      } else {
        rankColor = const Color(0xFF00FFF5);
      }
    }

    final center = Offset(size.width / 2, size.height / 2);
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = rankColor.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = rankColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    if (isUnlocked) {
      final glowPaint = Paint()
        ..color = rankColor.withOpacity(0.2)
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke;
      
      final glowPath = Path();
      glowPath.moveTo(w * 0.5, -2);
      glowPath.lineTo(w + 2, h * 0.25 - 1);
      glowPath.lineTo(w + 2, h * 0.75 + 1);
      glowPath.lineTo(w * 0.5, h + 2);
      glowPath.lineTo(-2, h * 0.75 + 1);
      glowPath.lineTo(-2, h * 0.25 - 1);
      glowPath.close();
      canvas.drawPath(glowPath, glowPaint);
    }

    final path = Path();
    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.25);
    path.lineTo(w, h * 0.75);
    path.lineTo(w * 0.5, h);
    path.lineTo(0, h * 0.75);
    path.lineTo(0, h * 0.25);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);

    final innerPath = Path();
    innerPath.moveTo(w * 0.5, h * 0.12);
    innerPath.lineTo(w * 0.88, h * 0.3);
    innerPath.lineTo(w * 0.88, h * 0.7);
    innerPath.lineTo(w * 0.5, h * 0.88);
    innerPath.lineTo(w * 0.12, h * 0.7);
    innerPath.lineTo(w * 0.12, h * 0.3);
    innerPath.close();

    final innerPaint = Paint()
      ..color = rankColor.withOpacity(0.25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(innerPath, innerPaint);

    if (isUnlocked) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: rank,
          style: TextStyle(
            color: Colors.white,
            fontSize: rank.length > 2 ? 13 : rank.length > 1 ? 15 : 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            shadows: [
              Shadow(
                color: rankColor,
                blurRadius: 6.0,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2 - (stars > 0 ? 5 : 0)),
      );

      if (stars > 0) {
        final starsText = '★' * stars;
        final starPainter = TextPainter(
          text: TextSpan(
            text: starsText,
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 9,
              letterSpacing: 1.0,
              shadows: [
                Shadow(
                  color: Color(0xFFFFD700),
                  blurRadius: 3.0,
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        starPainter.layout();
        starPainter.paint(
          canvas,
          Offset(center.dx - starPainter.width / 2, h * 0.72),
        );
      }
    } else {
      final lockPainter = TextPainter(
        text: const TextSpan(
          text: "LOCK",
          style: TextStyle(
            color: Color(0xFF454F5E),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            letterSpacing: 0.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      lockPainter.layout();
      lockPainter.paint(
        canvas,
        Offset(center.dx - lockPainter.width / 2, center.dy - lockPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RankBadgePainter oldDelegate) {
    return oldDelegate.rank != rank ||
        oldDelegate.stars != stars ||
        oldDelegate.subLevel != subLevel ||
        oldDelegate.isUnlocked != isUnlocked;
  }
}
