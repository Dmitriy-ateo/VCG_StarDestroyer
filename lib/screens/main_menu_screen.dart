import 'package:flutter/material.dart';

class MainMenuScreen extends StatefulWidget {
  final VoidCallback onStartCampaign;
  final VoidCallback onStartGame;
  final VoidCallback onOpenShop;
  final VoidCallback onOpenMarket;

  const MainMenuScreen({
    super.key,
    required this.onStartCampaign,
    required this.onStartGame,
    required this.onOpenShop,
    required this.onOpenMarket,
  });

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      body: Stack(
        children: [
          // 1. Grid Background
          Positioned.fill(
            child: CustomPaint(
              painter: _MenuGridPainter(),
            ),
          ),

          // 2. Main Title Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Star Icon Logo
                  const Icon(
                    Icons.radar_sharp,
                    color: Color(0xFF00FFF5),
                    size: 80,
                  ),
                  const SizedBox(height: 16),

                  // Pulsing title
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final value = _pulseController.value;
                      return Column(
                        children: [
                          Text(
                            "STAR DESTROYER",
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: const Color(0xFF00ADB5).withOpacity(0.5 + value * 0.4),
                                  blurRadius: 10 + value * 15,
                                )
                              ],
                            ),
                          ),
                          Text(
                            "SINGLE SHOT",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 6.0,
                              color: const Color(0xFF00FFF5),
                              shadows: [
                                Shadow(
                                  color: const Color(0xFF00FFF5).withOpacity(0.4 + value * 0.4),
                                  blurRadius: 8 + value * 12,
                                )
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 36),

                  // Subtitle
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      "ESTABLISH EMPIRE DOMINANCE WITH PHYSICS PUZZLES",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Menu Buttons
                  _buildMenuButton(
                    label: "LAUNCH CAMPAIGN",
                    onPressed: widget.onStartCampaign,
                    isPrimary: true,
                  ),
                  const SizedBox(height: 16),
                  _buildMenuButton(
                    label: "TRAINING CENTER",
                    onPressed: widget.onStartGame,
                    isPrimary: false,
                  ),
                  const SizedBox(height: 16),
                  _buildMenuButton(
                    label: "RESEARCH LAB",
                    onPressed: widget.onOpenShop,
                    isPrimary: false,
                  ),
                  const SizedBox(height: 16),
                  _buildMenuButton(
                    label: "TACTICAL MARKET",
                    onPressed: widget.onOpenMarket,
                    isPrimary: false,
                  ),
                  const SizedBox(height: 16),
                  _buildMenuButton(
                    label: "TACTICAL BRIEFING",
                    onPressed: () => _showHowToPlayDialog(context),
                    isPrimary: false,
                  ),

                  const SizedBox(height: 64),
                  // Footer
                  const Text(
                    "VIBEGAMING STUDIO • CLASSIFIED ARCHITECTURE",
                    style: TextStyle(color: Color(0xFF393E46), fontSize: 9, letterSpacing: 1.2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required String label,
    required VoidCallback? onPressed,
    required bool isPrimary,
    String? subtitle,
  }) {
    final isEnabled = onPressed != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 280,
          height: 50,
          decoration: BoxDecoration(
            boxShadow: isPrimary && isEnabled
                ? [
                    BoxShadow(
                      color: const Color(0xFF00ADB5).withOpacity(0.25),
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: isPrimary
              ? ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEnabled ? const Color(0xFF00ADB5) : const Color(0xFF222831),
                    foregroundColor: isEnabled ? Colors.white : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: isEnabled ? Colors.transparent : const Color(0xFF393E46), width: 1),
                    ),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.5),
                  ),
                )
              : OutlinedButton(
                  onPressed: onPressed,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isEnabled ? const Color(0xFF00ADB5) : Colors.grey,
                    side: BorderSide(color: isEnabled ? const Color(0xFF00ADB5) : const Color(0xFF393E46), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.5),
                  ),
                ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 8, letterSpacing: 0.5, fontWeight: FontWeight.bold),
          ),
        ],
      ],
    );
  }

  void _showHowToPlayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161B22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF00ADB5), width: 1.5),
          ),
          title: const Row(
            children: [
              Icon(Icons.menu_book, color: Color(0xFF00FFF5)),
              SizedBox(width: 12),
              Text(
                "TACTICAL INSTRUMENTS",
                style: TextStyle(color: Colors.white, letterSpacing: 1.5, fontSize: 18),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInstructionRow(
                  Icons.looks_one,
                  "Mission Directive",
                  "Destroy all Target Planets in each sector using EXACTLY ONE superlaser shot. If you miss even one planet, the simulation fails.",
                ),
                _buildInstructionRow(
                  Icons.looks_two,
                  "Device Placement",
                  "Drag items from the inventory onto empty grid coordinate cells. Tap once to rotate a placed device by 45°. Long-press to remove it.",
                ),
                _buildInstructionRow(
                  Icons.looks_3,
                  "Device Typology",
                  "• REFLECTOR: Redirects the laser path based on its mirror angle.\n• SPLITTER: Splits one laser beam into two streams.\n• BOMB: Detonates on touch, blowing up planets in a grid radius of 2.\n• GRAVITY WELL: Creates a curved trajectory by bending rays.\n• PORTALS: Enters portal A, exits portal B.",
                ),
                _buildInstructionRow(
                  Icons.looks_4,
                  "Upgrades Console",
                  "Spend earned credits on upgrades like Aiming Preview paths. Spend RP from tutorial clearances to unlock splitters, portals, and gravity blueprints.",
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("DISMISS", style: TextStyle(color: Color(0xFF00FFF5), fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }

  Widget _buildInstructionRow(IconData icon, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF00ADB5), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(color: Colors.grey, fontSize: 11, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF132238).withOpacity(0.3)
      ..strokeWidth = 1.0;

    const spacing = 40.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double j = 0; j < size.height; j += spacing) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
