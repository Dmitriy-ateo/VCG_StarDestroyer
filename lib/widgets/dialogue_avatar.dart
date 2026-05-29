import 'dart:math';
import 'package:flutter/material.dart';
import '../config/lore_dialogue.dart';

class DialogueAvatar extends StatefulWidget {
  final Character character;
  final Emotion emotion;
  final double size;

  const DialogueAvatar({
    super.key,
    required this.character,
    required this.emotion,
    this.size = 120.0,
  });

  @override
  State<DialogueAvatar> createState() => _DialogueAvatarState();
}

class _DialogueAvatarState extends State<DialogueAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: const Color(0xFF0F1115),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getCharacterThemeColor(widget.character).withOpacity(0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _getCharacterThemeColor(widget.character).withOpacity(0.12),
                blurRadius: 12,
                spreadRadius: 1,
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.5),
            child: CustomPaint(
              painter: _AvatarPainter(
                character: widget.character,
                emotion: widget.emotion,
                pulseValue: _pulseController.value,
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getCharacterThemeColor(Character c) {
    switch (c) {
      case Character.dax:
        return const Color(0xFF00FFF5); // Neon Cyan
      case Character.vance:
        return const Color(0xFFFF1744); // Cyber Red
      case Character.kael:
        return const Color(0xFF69F0AE); // Tactical Green
      case Character.vex:
        return const Color(0xFFFF9F1C); // Warm Orange
      case Character.sol:
        return const Color(0xFF2979FF); // Electric Blue
    }
  }
}

class _AvatarPainter extends CustomPainter {
  final Character character;
  final Emotion emotion;
  final double pulseValue;

  _AvatarPainter({
    required this.character,
    required this.emotion,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background grid lines (cybernetic comlink texture)
    _paintBackgroundGrid(canvas, size);

    // Draw main character silhouettes
    switch (character) {
      case Character.dax:
        _paintDax(canvas, size);
        break;
      case Character.vance:
        _paintVance(canvas, size);
        break;
      case Character.kael:
        _paintKael(canvas, size);
        break;
      case Character.vex:
        _paintVex(canvas, size);
        break;
      case Character.sol:
        _paintSol(canvas, size);
        break;
    }
  }

  void _paintBackgroundGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = _getThemeColor().withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw horizontal grid lines
    for (double y = 0; y < size.height; y += 12) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    // Draw vertical grid lines
    for (double x = 0; x < size.width; x += 12) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Circular radar sweeping arc
    final radarPaint = Paint()
      ..color = _getThemeColor().withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      (size.width / 2) * (0.3 + 0.6 * pulseValue),
      radarPaint,
    );
  }

  void _paintDax(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Dax: Capt. Dax Sterling (Cyan Visor)
    // 1. Shoulders & Officer Collar
    final bodyPath = Path()
      ..moveTo(w * 0.1, h)
      ..quadraticBezierTo(w * 0.15, h * 0.72, w * 0.3, h * 0.72)
      ..lineTo(w * 0.35, h * 0.76)
      ..lineTo(w * 0.42, h * 0.64)
      ..lineTo(w * 0.58, h * 0.64)
      ..lineTo(w * 0.65, h * 0.76)
      ..lineTo(w * 0.7, h * 0.72)
      ..quadraticBezierTo(w * 0.85, h * 0.72, w * 0.9, h)
      ..close();

    final bodyPaint = Paint()..color = const Color(0xFF1B222E);
    final borderPaint = Paint()
      ..color = const Color(0xFF00FFF5).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(bodyPath, bodyPaint);
    canvas.drawPath(bodyPath, borderPaint);

    // 2. Neck
    final neckPath = Path()
      ..moveTo(w * 0.42, h * 0.68)
      ..lineTo(w * 0.42, h * 0.55)
      ..lineTo(w * 0.58, h * 0.55)
      ..lineTo(w * 0.58, h * 0.68)
      ..close();
    canvas.drawPath(neckPath, Paint()..color = const Color(0xFF2C3540));

    // 3. Head & Hair Contours
    final headPath = Path()
      ..moveTo(w * 0.36, h * 0.55)
      ..quadraticBezierTo(w * 0.34, h * 0.34, w * 0.5, h * 0.32)
      ..quadraticBezierTo(w * 0.66, h * 0.34, w * 0.64, h * 0.55)
      ..quadraticBezierTo(w * 0.62, h * 0.62, w * 0.5, h * 0.62)
      ..quadraticBezierTo(w * 0.38, h * 0.62, w * 0.36, h * 0.55)
      ..close();
    canvas.drawPath(headPath, Paint()..color = const Color(0xFF232D3A));

    // Sharp hair vector on top
    final hairPath = Path()
      ..moveTo(w * 0.36, h * 0.45)
      ..lineTo(w * 0.34, h * 0.34)
      ..quadraticBezierTo(w * 0.42, h * 0.22, w * 0.55, h * 0.24)
      ..quadraticBezierTo(w * 0.68, h * 0.26, w * 0.66, h * 0.38)
      ..lineTo(w * 0.64, h * 0.42)
      ..quadraticBezierTo(w * 0.5, h * 0.36, w * 0.36, h * 0.45)
      ..close();
    canvas.drawPath(hairPath, Paint()..color = const Color(0xFF141923));

    // 4. Glowing Neon Visor
    Color visorColor = const Color(0xFF00FFF5);
    double visorPulse = 1.0;
    double rotationAngle = 0.0;

    if (emotion == Emotion.determined) {
      visorColor = const Color(0xFFFF2E93); // Determined pink/angry look
      rotationAngle = -0.06; // tilted down
    } else if (emotion == Emotion.worried) {
      visorColor = const Color(0xFFFFB703); // Worried yellow pulse
      visorPulse = 0.6 + 0.4 * pulseValue;
    }

    canvas.save();
    canvas.translate(w * 0.5, h * 0.44);
    canvas.rotate(rotationAngle);

    final visorPaint = Paint()
      ..color = visorColor.withOpacity(visorPulse)
      ..style = PaintingStyle.fill;

    final visorGlow = Paint()
      ..color = visorColor.withOpacity(0.3 * visorPulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final Path visor = Path()
      ..moveTo(-w * 0.16, -h * 0.035)
      ..lineTo(w * 0.16, -h * 0.035)
      ..lineTo(w * 0.13, h * 0.035)
      ..lineTo(-w * 0.13, h * 0.035)
      ..close();

    canvas.drawPath(visor, visorGlow);
    canvas.drawPath(visor, visorPaint);
    canvas.restore();
  }

  void _paintVance(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Vance: Grand Moff Vance (Red Peaked Hat & Mechanical Eye)
    // 1. Shoulders & Imperial Peaked Collar
    final bodyPath = Path()
      ..moveTo(w * 0.1, h)
      ..quadraticBezierTo(w * 0.15, h * 0.70, w * 0.32, h * 0.70)
      ..lineTo(w * 0.40, h * 0.55)
      ..lineTo(w * 0.60, h * 0.55)
      ..lineTo(w * 0.68, h * 0.70)
      ..quadraticBezierTo(w * 0.85, h * 0.70, w * 0.9, h)
      ..close();

    final bodyPaint = Paint()..color = const Color(0xFF1B1B1B);
    final borderPaint = Paint()
      ..color = const Color(0xFFFF1744).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(bodyPath, bodyPaint);
    canvas.drawPath(bodyPath, borderPaint);

    // 2. Neck
    canvas.drawRect(
      Rect.fromLTRB(w * 0.42, h * 0.52, w * 0.58, h * 0.60),
      Paint()..color = const Color(0xFF2C2C2C),
    );

    // 3. Head Contour
    final headPath = Path()
      ..moveTo(w * 0.38, h * 0.52)
      ..quadraticBezierTo(w * 0.35, h * 0.34, w * 0.5, h * 0.32)
      ..quadraticBezierTo(w * 0.65, h * 0.34, w * 0.62, h * 0.52)
      ..quadraticBezierTo(w * 0.60, h * 0.60, w * 0.5, h * 0.60)
      ..quadraticBezierTo(w * 0.40, h * 0.60, w * 0.38, h * 0.52)
      ..close();
    canvas.drawPath(headPath, Paint()..color = const Color(0xFF222222));

    // 4. Peaked Commander Cap
    final capPath = Path()
      ..moveTo(w * 0.34, h * 0.35)
      ..quadraticBezierTo(w * 0.38, h * 0.18, w * 0.5, h * 0.18)
      ..quadraticBezierTo(w * 0.62, h * 0.18, w * 0.66, h * 0.35)
      ..quadraticBezierTo(w * 0.5, h * 0.40, w * 0.34, h * 0.35)
      ..close();
    canvas.drawPath(capPath, Paint()..color = const Color(0xFF121212));

    // Cap Visor Rim
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.32, h * 0.36)
        ..quadraticBezierTo(w * 0.5, h * 0.42, w * 0.68, h * 0.36)
        ..quadraticBezierTo(w * 0.5, h * 0.38, w * 0.32, h * 0.36),
      Paint()..color = const Color(0xFFFF1744).withOpacity(0.6),
    );

    // 5. Glowing Red Cybernetic Monocle (Right Eye)
    Color monocleColor = const Color(0xFFFF1744);
    double opacity = 1.0;

    if (emotion == Emotion.angry) {
      opacity = 0.5 + 0.5 * sin(DateTime.now().millisecondsSinceEpoch * 0.025).abs();
    } else if (emotion == Emotion.defeated) {
      // Flickering weak/offline monocle
      opacity = 0.15 + 0.1 * pulseValue;
    }

    final eyeCenter = Offset(w * 0.44, h * 0.46);
    final monoclePaint = Paint()
      ..color = monocleColor.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    final monocleGlow = Paint()
      ..color = monocleColor.withOpacity(0.3 * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(eyeCenter, w * 0.05, monocleGlow);
    canvas.drawCircle(eyeCenter, w * 0.04, monoclePaint);
    canvas.drawCircle(eyeCenter, w * 0.015, Paint()..color = Colors.white.withOpacity(opacity));

    // Defeated status cracks
    if (emotion == Emotion.defeated) {
      final crackPaint = Paint()
        ..color = const Color(0xFF555555)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawLine(eyeCenter, eyeCenter + const Offset(-10, -12), crackPaint);
      canvas.drawLine(eyeCenter + const Offset(-5, -6), eyeCenter + const Offset(-15, -2), crackPaint);
      canvas.drawLine(eyeCenter, eyeCenter + const Offset(12, 10), crackPaint);
    }
  }

  void _paintKael(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Kael: Commander Kael (Green Comm monocle)
    // 1. Shoulders & Collar
    final bodyPath = Path()
      ..moveTo(w * 0.1, h)
      ..quadraticBezierTo(w * 0.18, h * 0.72, w * 0.32, h * 0.72)
      ..lineTo(w * 0.40, h * 0.58)
      ..lineTo(w * 0.60, h * 0.58)
      ..lineTo(w * 0.68, h * 0.72)
      ..quadraticBezierTo(w * 0.82, h * 0.72, w * 0.9, h)
      ..close();

    canvas.drawPath(bodyPath, Paint()..color = const Color(0xFF1E2620));
    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = const Color(0xFF69F0AE).withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // 2. Neck
    canvas.drawRect(
      Rect.fromLTRB(w * 0.43, h * 0.55, w * 0.57, h * 0.62),
      Paint()..color = const Color(0xFF2D3830),
    );

    // 3. Head & Cap
    final headPath = Path()
      ..moveTo(w * 0.38, h * 0.55)
      ..quadraticBezierTo(w * 0.36, h * 0.35, w * 0.5, h * 0.34)
      ..quadraticBezierTo(w * 0.64, h * 0.35, w * 0.62, h * 0.55)
      ..quadraticBezierTo(w * 0.60, h * 0.62, w * 0.5, h * 0.62)
      ..quadraticBezierTo(w * 0.40, h * 0.62, w * 0.38, h * 0.55)
      ..close();
    canvas.drawPath(headPath, Paint()..color = const Color(0xFF28322B));

    // Cap
    final capPath = Path()
      ..moveTo(w * 0.35, h * 0.36)
      ..quadraticBezierTo(w * 0.39, h * 0.22, w * 0.5, h * 0.22)
      ..quadraticBezierTo(w * 0.61, h * 0.22, w * 0.65, h * 0.36)
      ..quadraticBezierTo(w * 0.5, h * 0.40, w * 0.35, h * 0.36)
      ..close();
    canvas.drawPath(capPath, Paint()..color = const Color(0xFF141C16));

    // 4. Glowing Tactical Green Monocle (Left Eye)
    Color eyeColor = const Color(0xFF69F0AE);
    double opacity = 1.0;

    if (emotion == Emotion.angry) {
      opacity = 0.5 + 0.5 * sin(DateTime.now().millisecondsSinceEpoch * 0.02).abs();
    } else if (emotion == Emotion.defeated) {
      opacity = 0.15 + 0.15 * pulseValue;
    }

    final eyeCenter = Offset(w * 0.56, h * 0.45);
    canvas.drawCircle(eyeCenter, w * 0.05, Paint()..color = eyeColor.withOpacity(0.25 * opacity)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    canvas.drawCircle(eyeCenter, w * 0.038, Paint()..color = eyeColor.withOpacity(opacity));
    canvas.drawCircle(eyeCenter, w * 0.015, Paint()..color = Colors.white.withOpacity(opacity));
  }

  void _paintVex(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Vex: Syndicate Boss Vex (Respirator mask & Orange eyepatch)
    // 1. Shoulders with scrap metal spikes
    final bodyPath = Path()
      ..moveTo(w * 0.1, h)
      ..lineTo(w * 0.2, h * 0.72)
      ..lineTo(w * 0.32, h * 0.75)
      ..lineTo(w * 0.42, h * 0.62)
      ..lineTo(w * 0.58, h * 0.62)
      ..lineTo(w * 0.68, h * 0.75)
      ..lineTo(w * 0.8, h * 0.72)
      ..lineTo(w * 0.9, h)
      ..close();

    canvas.drawPath(bodyPath, Paint()..color = const Color(0xFF2C2016));
    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = const Color(0xFFFF9F1C).withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Spikes on shoulders
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.16, h * 0.72)
        ..lineTo(w * 0.13, h * 0.64)
        ..lineTo(w * 0.22, h * 0.71)
        ..close(),
      Paint()..color = const Color(0xFF3E3025),
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.84, h * 0.72)
        ..lineTo(w * 0.87, h * 0.64)
        ..lineTo(w * 0.78, h * 0.71)
        ..close(),
      Paint()..color = const Color(0xFF3E3025),
    );

    // 2. Neck with respirator tubes
    canvas.drawRect(
      Rect.fromLTRB(w * 0.44, h * 0.58, w * 0.56, h * 0.64),
      Paint()..color = const Color(0xFF3A3A3A),
    );

    // 3. Head & Hazard Respirator Mask
    final headPath = Path()
      ..moveTo(w * 0.38, h * 0.58)
      ..quadraticBezierTo(w * 0.34, h * 0.35, w * 0.5, h * 0.33)
      ..quadraticBezierTo(w * 0.66, h * 0.35, w * 0.62, h * 0.58)
      ..quadraticBezierTo(w * 0.60, h * 0.65, w * 0.5, h * 0.65)
      ..quadraticBezierTo(w * 0.40, h * 0.65, w * 0.38, h * 0.58)
      ..close();
    canvas.drawPath(headPath, Paint()..color = const Color(0xFF343434));

    // Circular Respirator Mask filter on bottom
    canvas.drawCircle(Offset(w * 0.5, h * 0.56), w * 0.12, Paint()..color = const Color(0xFF1E1E1E));
    canvas.drawCircle(Offset(w * 0.5, h * 0.56), w * 0.10, Paint()..color = const Color(0xFF121212));

    // 4. Glowing Orange Eyepatch (Right Eye)
    Color eyepatchColor = const Color(0xFFFF9F1C);
    double opacity = 1.0;

    if (emotion == Emotion.angry) {
      opacity = 0.5 + 0.5 * sin(DateTime.now().millisecondsSinceEpoch * 0.03).abs();
    } else if (emotion == Emotion.defeated) {
      eyepatchColor = const Color(0xFFE040FB); // Flickers into purple unstable code
      opacity = 0.2 + 0.1 * pulseValue;
    }

    final eyeCenter = Offset(w * 0.44, h * 0.44);
    canvas.drawCircle(eyeCenter, w * 0.045, Paint()..color = eyepatchColor.withOpacity(0.35 * opacity)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    
    // Draw angled eyepatch strap
    final strapPaint = Paint()
      ..color = const Color(0xFF121212)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(w * 0.34, h * 0.40), Offset(w * 0.54, h * 0.48), strapPaint);

    canvas.drawCircle(eyeCenter, w * 0.035, Paint()..color = eyepatchColor.withOpacity(opacity));
    canvas.drawCircle(eyeCenter, w * 0.015, Paint()..color = Colors.white.withOpacity(opacity));
  }

  void _paintSol(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sol: Major Sol (Closed Blue Grid Visor Combat Helmet)
    // 1. Shoulders & Heavy Armor
    final bodyPath = Path()
      ..moveTo(w * 0.08, h)
      ..quadraticBezierTo(w * 0.12, h * 0.65, w * 0.30, h * 0.65)
      ..lineTo(w * 0.38, h * 0.60)
      ..lineTo(w * 0.62, h * 0.60)
      ..lineTo(w * 0.70, h * 0.65)
      ..quadraticBezierTo(w * 0.88, h * 0.65, w * 0.92, h)
      ..close();

    canvas.drawPath(bodyPath, Paint()..color = const Color(0xFF1E2836));
    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = const Color(0xFF2979FF).withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // 2. Heavy Neck Neckpiece
    canvas.drawRect(
      Rect.fromLTRB(w * 0.40, h * 0.56, w * 0.60, h * 0.62),
      Paint()..color = const Color(0xFF141D2B),
    );

    // 3. Fully Rounded Cybernetic Combat Helmet
    final helmetPath = Path()
      ..moveTo(w * 0.32, h * 0.45)
      ..quadraticBezierTo(w * 0.32, h * 0.22, w * 0.5, h * 0.22)
      ..quadraticBezierTo(w * 0.68, h * 0.22, w * 0.68, h * 0.45)
      ..quadraticBezierTo(w * 0.66, h * 0.60, w * 0.5, h * 0.60)
      ..quadraticBezierTo(w * 0.34, h * 0.60, w * 0.32, h * 0.45)
      ..close();
    canvas.drawPath(helmetPath, Paint()..color = const Color(0xFF0F1622));
    canvas.drawPath(
      helmetPath,
      Paint()
        ..color = const Color(0xFF2979FF).withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // 4. Visor Faceplate Grid (Blue telemetry grid overlay)
    Color gridColor = const Color(0xFF2979FF);

    final visorRect = Rect.fromLTRB(w * 0.37, h * 0.34, w * 0.63, h * 0.50);
    canvas.drawRect(
      visorRect,
      Paint()..color = const Color(0xFF070B14),
    );

    canvas.save();
    canvas.clipRect(visorRect);

    if (emotion == Emotion.angry) {
      // Rapid visual static noise lines
      final rand = Random();
      final staticPaint = Paint()..color = gridColor.withOpacity(0.7)..strokeWidth = 1.0;
      for (int i = 0; i < 6; i++) {
        final double ry = visorRect.top + rand.nextDouble() * visorRect.height;
        canvas.drawLine(Offset(visorRect.left, ry), Offset(visorRect.right, ry), staticPaint);
      }
    } else if (emotion == Emotion.defeated) {
      // Offline grid, single flickering grey line
      final offlinePaint = Paint()..color = Colors.grey.withOpacity(0.25 + 0.15 * pulseValue)..strokeWidth = 1.5;
      canvas.drawLine(
        Offset(visorRect.left, visorRect.top + visorRect.height / 2),
        Offset(visorRect.right, visorRect.top + visorRect.height / 2),
        offlinePaint,
      );
    } else {
      // Standard scrolling blue telemetry rows
      final gridPaint = Paint()..color = gridColor.withOpacity(0.5)..strokeWidth = 1.0;
      for (double y = visorRect.top + 2; y < visorRect.bottom; y += 4) {
        canvas.drawLine(Offset(visorRect.left, y), Offset(visorRect.right, y), gridPaint);
      }
      // Scrolling tracking bar
      final double scanY = visorRect.top + (visorRect.height * (0.1 + 0.8 * pulseValue));
      canvas.drawRect(
        Rect.fromLTRB(visorRect.left, scanY - 1, visorRect.right, scanY + 1),
        Paint()..color = gridColor.withOpacity(0.85)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }

    canvas.restore();
  }

  Color _getThemeColor() {
    switch (character) {
      case Character.dax:
        return const Color(0xFF00FFF5);
      case Character.vance:
        return const Color(0xFFFF1744);
      case Character.kael:
        return const Color(0xFF69F0AE);
      case Character.vex:
        return const Color(0xFFFF9F1C);
      case Character.sol:
        return const Color(0xFF2979FF);
    }
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter oldDelegate) {
    return oldDelegate.character != character ||
        oldDelegate.emotion != emotion ||
        oldDelegate.pulseValue != pulseValue;
  }
}
