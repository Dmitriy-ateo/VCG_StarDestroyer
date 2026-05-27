import 'package:flutter/material.dart';

/// Single source of truth for the game's high-fidelity cyber aesthetic.
/// Inspired by the Aetheric Command style guide.
class StyleGuide {
  StyleGuide._();

  // ==========================================
  // COLOR PALETTE
  // ==========================================
  
  /// Primary Theme Color: Aetheric Gold/Amber (#FFBB00)
  static const Color primary = Color(0xFFFFBB00);

  /// Secondary Theme Color: Cyber Pink/Magenta (#FF00FF)
  static const Color secondary = Color(0xFFFF00FF);

  /// Tertiary Theme Color: Aetheric Cyan/Teal (#00FFFF)
  static const Color tertiary = Color(0xFF00FFFF);

  /// Neutral Dark Background: Deep Space Charcoal (#0F1115)
  static const Color neutralBg = Color(0xFF0F1115);

  /// Sleek Secondary Card Base Color (#161B22)
  static const Color neutralCard = Color(0xFF161B22);

  /// Bright Active Text Color
  static const Color textWhite = Color(0xFFFFFFFF);

  /// Muted Secondary Text Color
  static const Color textGrey = Color(0xFF8E9297);

  /// Glowing HUD Border Opacity Level
  static const double borderOpacity = 0.4;

  // ==========================================
  // TYPOGRAPHY (Monospace & High-Tech)
  // ==========================================

  /// Title styles (Headline style)
  static const TextStyle headline = TextStyle(
    color: textWhite,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );

  /// Subtitles & Telemetry Labels
  static const TextStyle label = TextStyle(
    color: tertiary,
    fontSize: 9,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.8,
  );

  /// Monospace Body Text (inspired by JetBrains Mono)
  static const TextStyle body = TextStyle(
    color: textWhite,
    fontSize: 11.5,
    fontFamily: 'monospace',
    height: 1.4,
  );

  /// Muted Description / Technical Text
  static const TextStyle technical = TextStyle(
    color: textGrey,
    fontSize: 10,
    fontFamily: 'monospace',
    height: 1.3,
  );

  // ==========================================
  // COMPONENT STYLES & DECORATIONS
  // ==========================================

  /// Glowing neon-accented card decoration
  static BoxDecoration glowingCard({
    required Color accentColor,
    Color bgColor = neutralCard,
    double borderRadius = 8.0,
  }) {
    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: accentColor.withOpacity(borderOpacity), width: 1.2),
      boxShadow: [
        BoxShadow(
          color: accentColor.withOpacity(0.06),
          blurRadius: 4,
          spreadRadius: 0.5,
        ),
      ],
    );
  }
}
