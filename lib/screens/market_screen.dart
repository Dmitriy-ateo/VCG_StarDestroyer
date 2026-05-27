import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/device_model.dart';
import '../models/game_progression.dart';
import '../game/game_controller.dart';

class MarketScreen extends StatelessWidget {
  final GameController controller;
  final VoidCallback onBackToMenu;
  final VoidCallback onGoToResearch;

  const MarketScreen({
    super.key,
    required this.controller,
    required this.onBackToMenu,
    required this.onGoToResearch,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final progression = controller.progression;

          // List of purchaseable items dynamically constructed from researched state
          final items = [
            _MarketItemData(
              itemId: "reflector",
              name: "Deflector Prism Mirror",
              description: "Directs incoming lasers using vector angles. Pure reflective glass.",
              price: GameProgression.getMarketItemPrice("reflector"),
              icon: Icons.flip,
              glowColor: const Color(0xFF00FFF5),
              isResearched: progression.unlockedDevices.contains(DeviceType.reflector),
            ),
            _MarketItemData(
              itemId: "splitter_180",
              name: "Prism Laser Splitter (180°)",
              description: "Splits a single beam into two directly opposite rays.",
              price: GameProgression.getMarketItemPrice("splitter_180"),
              icon: Icons.call_split,
              glowColor: const Color(0xFFFF2E93),
              isResearched: progression.unlockedSplitterAngles.contains(180.0),
            ),
            _MarketItemData(
              itemId: "splitter_90",
              name: "Prism Laser Splitter (90°)",
              description: "Splits a single beam into two rays separated by a 90° angle.",
              price: GameProgression.getMarketItemPrice("splitter_90"),
              icon: Icons.call_split,
              glowColor: const Color(0xFFFF2E93),
              isResearched: progression.unlockedSplitterAngles.contains(90.0),
            ),
            _MarketItemData(
              itemId: "splitter_135",
              name: "Prism Laser Splitter (135°)",
              description: "Splits a single beam into two rays separated by a 135° angle.",
              price: GameProgression.getMarketItemPrice("splitter_135"),
              icon: Icons.call_split,
              glowColor: const Color(0xFFFF2E93),
              isResearched: progression.unlockedSplitterAngles.contains(135.0),
            ),
            _MarketItemData(
              itemId: "splitter_45",
              name: "Prism Laser Splitter (45°)",
              description: "Splits a single beam into two rays separated by a 45° angle.",
              price: GameProgression.getMarketItemPrice("splitter_45"),
              icon: Icons.call_split,
              glowColor: const Color(0xFFFF2E93),
              isResearched: progression.unlockedSplitterAngles.contains(45.0),
            ),
            _MarketItemData(
              itemId: "bomb",
              name: "Anti-Matter Trigger Bomb",
              description: "Proximity explosives reacting violently with high-charge lasers.",
              price: GameProgression.getMarketItemPrice("bomb"),
              icon: Icons.brightness_low,
              glowColor: const Color(0xFFFF3333),
              isResearched: progression.unlockedDevices.contains(DeviceType.bomb),
            ),
            _MarketItemData(
              itemId: "gravityWell",
              name: "Singularity Gravity Well",
              description: "Generates microscopic black holes that bend laser rays dynamically.",
              price: GameProgression.getMarketItemPrice("gravityWell"),
              icon: Icons.blur_circular,
              glowColor: const Color(0xFF7B2CBF),
              isResearched: progression.unlockedDevices.contains(DeviceType.gravityWell),
            ),
            _MarketItemData(
              itemId: "portal",
              name: "Cosmic Warp Portals (Pair)",
              description: "Einstein-Rosen bridges linking spatial grid indexes for ray transit.",
              price: GameProgression.getMarketItemPrice("portal"),
              icon: Icons.circle_outlined,
              glowColor: const Color(0xFFFF9F1C),
              isResearched: progression.unlockedDevices.contains(DeviceType.portal),
            ),
          ];

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                children: [
                  // 1. Header Row
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
                              onPressed: onBackToMenu,
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
                                    "TACTICAL MARKET",
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
                                    "MERCHANT DEPLOYMENT CONSOLE",
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
                      // Currency statuses
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                            },
                            child: _buildStatChip(Icons.monetization_on, "${progression.credits}", Colors.amberAccent),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              onGoToResearch();
                            },
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: _buildStatChip(Icons.science, "${progression.researchPoints} RP", Colors.purpleAccent),
                            ),
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

                  // Subtitle & Store Notification
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FFF5).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF00FFF5).withOpacity(0.2)),
                    ),
                    child: const Text(
                      "MERCHANT NOTICE: Buy extra tactical devices to expand your permanent grid inventory. Devices must be researched in the Research Lab first.",
                      style: TextStyle(color: Color(0xFF00FFF5), fontSize: 10, fontStyle: FontStyle.italic, height: 1.3),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Store Items List
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isLocked = !item.isResearched;
                        final ownedCount = progression.purchasedMarketDevices[item.itemId] ?? 0;
                        final canAfford = progression.credits >= item.price;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161B22),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isLocked 
                                  ? const Color(0xFF393E46) 
                                  : item.glowColor.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              if (!isLocked)
                                BoxShadow(
                                  color: item.glowColor.withOpacity(0.05),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                )
                            ],
                          ),
                          child: Row(
                            children: [
                              // Device Icon Container
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: isLocked 
                                      ? const Color(0xFF222831) 
                                      : item.glowColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isLocked 
                                        ? Colors.transparent 
                                        : item.glowColor.withOpacity(0.4),
                                    width: 1.0,
                                  ),
                                ),
                                child: Icon(
                                  item.icon,
                                  color: isLocked ? Colors.grey : item.glowColor,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Device Text Description
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13.5,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (ownedCount > 0) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.greenAccent.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
                                            ),
                                            child: Text(
                                              "+$ownedCount OWNED",
                                              style: const TextStyle(
                                                color: Colors.greenAccent,
                                                fontSize: 8,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item.description,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Purchase Action Button
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isLocked) ...[
                                    const Icon(Icons.lock, color: Colors.grey, size: 20),
                                    const SizedBox(height: 4),
                                    const Text(
                                      "RESEARCH REQ.",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ] else ...[
                                    ElevatedButton(
                                      onPressed: canAfford
                                          ? () {
                                              controller.buyMarketDevice(item.itemId);
                                              HapticFeedback.mediumImpact();
                                              final messenger = ScaffoldMessenger.of(context);
                                              messenger.clearSnackBars();
                                              messenger.showSnackBar(
                                                SnackBar(
                                                  behavior: SnackBarBehavior.floating,
                                                  backgroundColor: const Color(0xFF161B22),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    side: BorderSide(color: item.glowColor),
                                                  ),
                                                  content: Row(
                                                    children: [
                                                      Icon(Icons.check_circle_outline, color: item.glowColor),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        "Purchased extra ${item.name}!",
                                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: item.glowColor.withOpacity(0.15),
                                        foregroundColor: item.glowColor,
                                        disabledBackgroundColor: const Color(0xFF222831),
                                        disabledForegroundColor: Colors.grey,
                                        side: BorderSide(
                                          color: canAfford ? item.glowColor : Colors.transparent,
                                          width: 1.0,
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.monetization_on, size: 14, color: Colors.amberAccent),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${item.price}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
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
}

class _MarketItemData {
  final String itemId;
  final String name;
  final String description;
  final int price;
  final IconData icon;
  final Color glowColor;
  final bool isResearched;

  const _MarketItemData({
    required this.itemId,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.glowColor,
    required this.isResearched,
  });
}
