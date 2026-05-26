import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/device_model.dart';
import '../models/game_progression.dart';
import '../game/game_controller.dart';

class MarketScreen extends StatelessWidget {
  final GameController controller;
  final VoidCallback onBackToMenu;

  const MarketScreen({
    super.key,
    required this.controller,
    required this.onBackToMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final progression = controller.progression;

          // List of purchaseable items
          final items = [
            _MarketItemData(
              type: DeviceType.reflector,
              name: "Deflector Prism Mirror",
              description: "Directs incoming lasers using vector angles. Pure reflective glass.",
              price: GameProgression.getDeviceMarketPrice(DeviceType.reflector),
              icon: Icons.flip,
              glowColor: const Color(0xFF00FFF5),
            ),
            _MarketItemData(
              type: DeviceType.splitter,
              name: "Prism Laser Splitter (180°)",
              description: "Splits a single beam into two directly opposite rays.",
              price: GameProgression.getDeviceMarketPrice(DeviceType.splitter),
              icon: Icons.call_split,
              glowColor: const Color(0xFFFF2E93),
            ),
            _MarketItemData(
              type: DeviceType.bomb,
              name: "Anti-Matter Trigger Bomb",
              description: "Proximity explosives reacting violently with high-charge lasers.",
              price: GameProgression.getDeviceMarketPrice(DeviceType.bomb),
              icon: Icons.brightness_low,
              glowColor: const Color(0xFFFF3333),
            ),
            _MarketItemData(
              type: DeviceType.gravityWell,
              name: "Singularity Gravity Well",
              description: "Generates microscopic black holes that bend laser rays dynamically.",
              price: GameProgression.getDeviceMarketPrice(DeviceType.gravityWell),
              icon: Icons.blur_circular,
              glowColor: const Color(0xFF7B2CBF),
            ),
            _MarketItemData(
              type: DeviceType.portal,
              name: "Cosmic Warp Portals (Pair)",
              description: "Einstein-Rosen bridges linking spatial grid indexes for ray transit.",
              price: GameProgression.getDeviceMarketPrice(DeviceType.portal),
              icon: Icons.circle_outlined,
              glowColor: const Color(0xFFFF9F1C),
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
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Color(0xFF00FFF5)),
                            onPressed: onBackToMenu,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "TACTICAL MARKET",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      
                      // Currency statuses
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
                        final isResearched = progression.unlockedDevices.contains(item.type);
                        final ownedCount = progression.purchasedMarketDevices[item.type] ?? 0;
                        final canAfford = progression.credits >= item.price;
                        final isLocked = !isResearched;

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
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (ownedCount > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                                              controller.buyMarketDevice(item.type);
                                              HapticFeedback.mediumImpact();
                                              ScaffoldMessenger.of(context).showSnackBar(
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
}

class _MarketItemData {
  final DeviceType type;
  final String name;
  final String description;
  final int price;
  final IconData icon;
  final Color glowColor;

  const _MarketItemData({
    required this.type,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.glowColor,
  });
}
