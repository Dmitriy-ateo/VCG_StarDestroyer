import 'package:flutter/material.dart';
import '../models/galaxy_model.dart';
import '../game/game_controller.dart';

class GalaxiesMapScreen extends StatelessWidget {
  final GameController controller;
  final Function(String) onGalaxySelected;
  final VoidCallback onBackToMenu;

  const GalaxiesMapScreen({
    super.key,
    required this.controller,
    required this.onGalaxySelected,
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
          final galaxies = preloadedGalaxies;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Color(0xFF00ADB5)),
                            onPressed: onBackToMenu,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "GALACTIC EMPIRE MAP",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      // Currencies status
                      Row(
                        children: [
                          _buildStatChip(Icons.monetization_on, "${progression.credits}", Colors.amberAccent),
                          const SizedBox(width: 10),
                          _buildStatChip(Icons.science, "${progression.researchPoints} RP", Colors.purpleAccent),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: const Color(0xFF00ADB5).withOpacity(0.3),
                  ),
                  const SizedBox(height: 20),

                  // Subtitle
                  const Text(
                    "SELECT TARGET SECTOR GALAXY",
                    style: TextStyle(
                      color: Color(0xFF00FFF5),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Galaxy Grid List
                  Expanded(
                    child: ListView.builder(
                      itemCount: galaxies.length,
                      itemBuilder: (context, index) {
                        final galaxy = galaxies[index];
                        final isUnlocked = galaxy.checkUnlockStatus(progression);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: InkWell(
                            onTap: isUnlocked ? () => onGalaxySelected(galaxy.id) : null,
                            borderRadius: BorderRadius.circular(16),
                            child: Opacity(
                              opacity: isUnlocked ? 1.0 : 0.65,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF161B22),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isUnlocked
                                        ? const Color(0xFF00ADB5).withOpacity(0.4)
                                        : Colors.redAccent.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                  boxShadow: isUnlocked
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF00ADB5).withOpacity(0.08),
                                            blurRadius: 16,
                                            offset: const Offset(0, 4),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          galaxy.name.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                        if (isUnlocked)
                                          const Icon(Icons.chevron_right, color: Color(0xFF00FFF5))
                                        else
                                          const Icon(Icons.lock, color: Colors.redAccent, size: 18),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      galaxy.description,
                                      style: const TextStyle(color: Colors.grey, fontSize: 11, height: 1.4),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      height: 1,
                                      color: Colors.white.withOpacity(0.06),
                                    ),
                                    const SizedBox(height: 12),

                                    // Dynamic Requirements Panel
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          isUnlocked ? "SYSTEM ACTIVE" : "LOCK SPECIFICATIONS",
                                          style: TextStyle(
                                            color: isUnlocked ? Colors.greenAccent : Colors.redAccent,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                        Text(
                                          isUnlocked ? "OUTPOST SECURED" : galaxy.requirementDescription,
                                          style: TextStyle(
                                            color: isUnlocked ? Colors.grey : Colors.amberAccent,
                                            fontSize: 9,
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
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
