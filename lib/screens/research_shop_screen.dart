import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../models/game_progression.dart';
import '../game/game_controller.dart';

class ResearchShopScreen extends StatelessWidget {
  final GameController controller;
  final VoidCallback onBackToGame;

  const ResearchShopScreen({
    super.key,
    required this.controller,
    required this.onBackToGame,
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
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Color(0xFF00ADB5)),
                              onPressed: onBackToGame,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "R&D COMMAND CONSOLE",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        
                        // Currency Statuses
                        Row(
                          children: [
                            _buildStatChip(Icons.monetization_on, "${progression.credits}", Colors.amberAccent),
                            const SizedBox(width: 10),
                            _buildStatChip(Icons.science, "${progression.researchPoints} RP", Colors.purpleAccent),
                          ],
                        ),
                      ],
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
                                  currentLvl: progression.laserIntensityLevel,
                                  maxLvl: 5,
                                  cost: GameProgression.getUpgradeCost("intensity", progression.laserIntensityLevel),
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(height: 16),
                                _buildUpgradeCard(
                                  context: context,
                                  title: "Tactical Aiming Computer",
                                  description: "Projects anticipated ray paths around gravity wells and reflectors on your radar matrix.",
                                  icon: Icons.radar,
                                  upgradeType: "aiming",
                                  currentLvl: progression.aimingComputerLevel,
                                  maxLvl: 3,
                                  cost: GameProgression.getUpgradeCost("aiming", progression.aimingComputerLevel),
                                  color: const Color(0xFF00ADB5),
                                ),
                                const SizedBox(height: 16),
                                _buildUpgradeCard(
                                  context: context,
                                  title: "Deflector Sub-Chassis",
                                  description: "Increases structural load capacity allowing more reflectors to be loaded simultaneously.",
                                  icon: Icons.layers,
                                  upgradeType: "chassis",
                                  currentLvl: progression.chassisCapacityLevel,
                                  maxLvl: 5,
                                  cost: GameProgression.getUpgradeCost("chassis", progression.chassisCapacityLevel),
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
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
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
    required int currentLvl,
    required int maxLvl,
    required int cost,
    required Color color,
  }) {
    final canBuy = cost > 0 && controller.progression.credits >= cost;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF393E46)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
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
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Level progress indicator lights
              Row(
                children: List.generate(maxLvl, (index) {
                  final active = index < currentLvl;
                  return Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: active ? color : Colors.transparent,
                      border: Border.all(color: color, width: 1.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
              
              // Purchase Button
              cost > 0
                  ? ElevatedButton(
                      onPressed: canBuy
                          ? () {
                              controller.buyUpgrade(upgradeType);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Upgraded $title successfully!")),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color.withOpacity(0.2),
                        foregroundColor: color,
                        disabledBackgroundColor: const Color(0xFF222831),
                        disabledForegroundColor: Colors.grey,
                        side: BorderSide(color: canBuy ? color : Colors.transparent),
                      ),
                      child: Text("BUY: $cost C"),
                    )
                  : const Text(
                      "MAX LEVEL REACHED",
                      style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
            ],
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
    final canResearch = !isUnlocked && controller.progression.researchPoints >= cost;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isUnlocked ? Colors.purpleAccent.withOpacity(0.4) : const Color(0xFF393E46)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isUnlocked ? Colors.purpleAccent.withOpacity(0.1) : const Color(0xFF222831),
              borderRadius: BorderRadius.circular(10),
            ),
            child: _buildDeviceIcon(type, isUnlocked ? Colors.purpleAccent : Colors.grey),
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
              ? const Column(
                  children: [
                    Icon(Icons.verified, color: Colors.purpleAccent, size: 24),
                    SizedBox(height: 4),
                    Text("RESEARCHED", style: TextStyle(color: Colors.purpleAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                  ],
                )
              : ElevatedButton(
                  onPressed: canResearch
                      ? () {
                          controller.unlockDeviceBlueprint(type);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Unlocked $title Blueprints!")),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Unlocked $title Blueprints!")),
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

  Widget _buildDeviceIcon(DeviceType type, Color color) {
    switch (type) {
      case DeviceType.reflector:
        return Icon(Icons.flip, color: color, size: 24);
      case DeviceType.splitter:
        return Icon(Icons.call_split, color: color, size: 24);
      case DeviceType.gravityWell:
        return Icon(Icons.blur_circular, color: color, size: 24);
      case DeviceType.bomb:
        return Icon(Icons.brightness_low, color: color, size: 24);
      case DeviceType.portal:
        return Icon(Icons.circle_outlined, color: color, size: 24);
    }
  }
}
