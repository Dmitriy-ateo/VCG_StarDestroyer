import 'dart:math';
import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../models/level_data.dart';
import '../game/laser_calculator.dart';
import '../game/game_controller.dart';

class BoardPainter extends CustomPainter {
  final LevelData level;
  final List<DeviceModel> placedDevices;
  final double aimingAngle;
  final PlayState playState;
  final LaserTraceResult? traceResult;
  final double animationProgress;
  final int aimingComputerLevel;
  final DeviceModel? selectedInventoryDevice;
  final double bgAnimationValue;
  final double aimAnimationValue;
  final int laserIntensity;

  BoardPainter({
    required this.level,
    required this.placedDevices,
    required this.aimingAngle,
    required this.playState,
    this.traceResult,
    required this.animationProgress,
    required this.aimingComputerLevel,
    this.selectedInventoryDevice,
    required this.bgAnimationValue,
    this.aimAnimationValue = 0.0,
    required this.laserIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridAspectRatio = 8.0 / 12.0;
    double gridW;
    double gridH;
    double offsetX = 0.0;
    double offsetY = 0.0;
    
    if (size.width / size.height > gridAspectRatio) {
      gridH = size.height;
      gridW = gridH * gridAspectRatio;
      offsetX = (size.width - gridW) / 2;
    } else {
      gridW = size.width;
      gridH = gridW / gridAspectRatio;
      offsetY = (size.height - gridH) / 2;
    }

    final cellW = gridW / 8.0;
    final cellH = gridH / 12.0;
    final scale = min(cellW, cellH);

    // Helper: grid coordinate to pixel coordinate
    Offset toPixels(double gx, double gy) {
      return Offset(offsetX + gx * cellW, offsetY + gy * cellH);
    }

    Offset cellCenter(int x, int y) {
      return Offset(offsetX + (x + 0.5) * cellW, offsetY + (y + 0.5) * cellH);
    }

    // --- Unique Cosmic Background & Twinkling Stars (Phase 2 & 3) ---
    // 1. Draw space base fill
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF060913),
    );

    // Deterministic random numbers generator seeded by level ID
    int bgSeed = level.id * 54321;
    double bgRandom() {
      bgSeed = (bgSeed * 1103515245 + 12345) & 0x7FFFFFFF;
      return bgSeed / 2147483647.0;
    }

    // Set custom colors for nebulae depending on the active sector level ID
    Color nebulaColor1 = Colors.transparent;
    Color nebulaColor2 = Colors.transparent;
    
    switch (level.id) {
      case 1: // Calm Blue
        nebulaColor1 = const Color(0xFF0A2540).withOpacity(0.65);
        nebulaColor2 = const Color(0xFF004B87).withOpacity(0.35);
        break;
      case 2: // Teal/Grey Asteroid Field Gas
        nebulaColor1 = const Color(0xFF0D324D).withOpacity(0.55);
        nebulaColor2 = const Color(0xFF7F5A83).withOpacity(0.25);
        break;
      case 3: // Orange Solar Flares
        nebulaColor1 = const Color(0xFFFF8C00).withOpacity(0.30);
        nebulaColor2 = const Color(0xFFFF4500).withOpacity(0.18);
        break;
      case 4: // Toxic Crimson
        nebulaColor1 = const Color(0xFF8B0000).withOpacity(0.40);
        nebulaColor2 = const Color(0xFFFF1493).withOpacity(0.15);
        break;
      case 5: // Purple Slingshot whirlpool
        nebulaColor1 = const Color(0xFF4B0082).withOpacity(0.50);
        nebulaColor2 = const Color(0xFF9400D3).withOpacity(0.30);
        break;
      default: // Cyber green portal matrix lanes
        nebulaColor1 = const Color(0xFF008080).withOpacity(0.45);
        nebulaColor2 = const Color(0xFF5A189A).withOpacity(0.35);
        break;
    }

    // Paint cosmic nebula gas clouds (soft blurred radial colors)
    for (int n = 0; n < 3; n++) {
      final nX = bgRandom() * size.width;
      final nY = bgRandom() * size.height;
      final nRadius = scale * (2.0 + bgRandom() * 3.5);
      final activeColor = (n % 2 == 0) ? nebulaColor1 : nebulaColor2;
      
      if (activeColor == Colors.transparent) continue;
      
      final cloudPaint = Paint()
        ..shader = RadialGradient(
          colors: [activeColor, Colors.transparent],
        ).createShader(Rect.fromCircle(center: Offset(nX, nY), radius: nRadius))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, scale * 0.45);
        
      canvas.drawCircle(Offset(nX, nY), nRadius, cloudPaint);
    }

    // Paint Level 6 digital cybernetic matrix grid lines in background
    if (level.id == 6) {
      final techPaint = Paint()
        ..color = const Color(0xFF00FFF5).withOpacity(0.04)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      for (int i = 0; i < size.width; i += 40) {
        canvas.drawLine(Offset(i.toDouble(), 0), Offset(i.toDouble(), size.height), techPaint);
      }
    }

    // Deterministic twinkling starlight field generator (Phase 2)
    int starSeed = level.id * 12345;
    double starRandom() {
      starSeed = (starSeed * 1103515245 + 12345) & 0x7FFFFFFF;
      return starSeed / 2147483647.0;
    }

    for (int i = 0; i < 55; i++) {
      final xRatio = starRandom();
      final yRatio = starRandom();
      final sizeRatio = starRandom();
      final phaseOffset = starRandom();
      
      final starX = xRatio * size.width;
      final starY = yRatio * size.height;
      
      // Compute twinkle brightness based on bgAnimationValue and phaseOffset
      final angle = (bgAnimationValue * 2 * pi) + (phaseOffset * 2 * pi);
      final twinkle = (sin(angle) + 1.0) / 2.0; // 0.0 to 1.0
      
      final starPaint = Paint()
        ..color = Colors.white.withOpacity(0.20 + 0.80 * twinkle)
        ..style = PaintingStyle.fill;
        
      final starSize = 0.8 + sizeRatio * 2.0;
      canvas.drawCircle(Offset(starX, starY), starSize, starPaint);
      
      // Draw elegant neon cyan cross flares for larger/brighter stars
      if (sizeRatio > 0.88) {
        final flarePaint = Paint()
          ..color = const Color(0xFF00FFF5).withOpacity(0.35 * twinkle)
          ..strokeWidth = 0.8;
        canvas.drawLine(Offset(starX - 5, starY), Offset(starX + 5, starY), flarePaint);
        canvas.drawLine(Offset(starX, starY - 5), Offset(starX, starY + 5), flarePaint);
      }
    }

    // 2. Draw Space Grid Background Lines
    final gridPaint = Paint()
      ..color = const Color(0xFF0F1E36).withOpacity(0.8)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= 8; i++) {
      canvas.drawLine(
        Offset(offsetX + i * cellW, offsetY),
        Offset(offsetX + i * cellW, offsetY + gridH),
        gridPaint,
      );
    }
    for (int j = 0; j <= 12; j++) {
      canvas.drawLine(
        Offset(offsetX, offsetY + j * cellH),
        Offset(offsetX + gridW, offsetY + j * cellH),
        gridPaint,
      );
    }

    // 2. Draw Static Asteroid / Energy / Crystal Walls
    for (var wall in level.walls) {
      ExplosionEvent? wallExplosion;
      if (traceResult != null && playState != PlayState.editing) {
        final wallId = "wall_${wall.gridX}_${wall.gridY}";
        for (var exp in traceResult!.explosions) {
          if (exp.targetId == wallId) {
            wallExplosion = exp;
            break;
          }
        }
      }

      double wallOpacity = 1.0;
      double wallScale = 1.0;
      bool showParticles = false;
      double particleProgress = 0.0;

      if (wallExplosion != null) {
        final totalSteps = LaserCalculator.maxSteps.toDouble();
        final currentMaxStep = animationProgress * totalSteps;
        if (currentMaxStep >= wallExplosion.stepIndex) {
          final elapsed = currentMaxStep - wallExplosion.stepIndex;
          if (elapsed >= 15.0) {
            // Fully destroyed and shattered, do not draw!
            continue;
          }
          wallOpacity = (1.0 - elapsed / 15.0).clamp(0.0, 1.0);
          wallScale = 1.0 + (elapsed / 15.0) * 0.2;
          showParticles = true;
          particleProgress = elapsed / 15.0;
        }
      }

      final cellCenter = Offset(offsetX + wall.gridX * cellW + cellW / 2, offsetY + wall.gridY * cellH + cellH / 2);
      canvas.save();
      canvas.translate(cellCenter.dx, cellCenter.dy);
      canvas.scale(wallScale);

      final localRect = Rect.fromLTWH(-cellW / 2 + 2, -cellH / 2 + 2, cellW - 4, cellH - 4);
      final rrect = RRect.fromRectAndRadius(localRect, Radius.circular(scale * 0.15));

      final fillPaint = Paint()..style = PaintingStyle.fill;
      final outlinePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      if (wall.type == 'energyShield') {
        // Neon glowing cyan energy barrier
        final isPenetrated = wall.requiredLaserPower != null && laserIntensity >= wall.requiredLaserPower!;
        final baseColor = isPenetrated ? const Color(0xFF00FFF5).withOpacity(0.2) : const Color(0xFF00FFF5);
        
        fillPaint.color = baseColor.withOpacity(0.12 * wallOpacity);
        outlinePaint.color = baseColor.withOpacity(0.8 * wallOpacity);
        
        canvas.drawRRect(rrect, fillPaint);
        canvas.drawRRect(rrect, outlinePaint);

        // Draw dynamic scan lines / grid inside
        final linePaint = Paint()
          ..color = baseColor.withOpacity(0.3 * wallOpacity)
          ..strokeWidth = 1.0;
        
        for (double ly = -cellH / 2 + 6; ly < cellH / 2 - 4; ly += 6) {
          canvas.drawLine(Offset(-cellW / 2 + 4, ly), Offset(cellW / 2 - 4, ly), linePaint);
        }
      } else if (wall.type == 'crystal') {
        // Glowing violet/pink gemstone look
        final isPenetrated = wall.requiredLaserPower != null && laserIntensity >= wall.requiredLaserPower!;
        final baseColor = isPenetrated ? const Color(0xFFE040FB).withOpacity(0.25) : const Color(0xFFE040FB);

        fillPaint.shader = LinearGradient(
          colors: [baseColor.withOpacity(0.7 * wallOpacity), baseColor.withOpacity(0.2 * wallOpacity)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(localRect);

        outlinePaint.color = baseColor.withOpacity(0.9 * wallOpacity);

        canvas.drawRRect(rrect, fillPaint);
        canvas.drawRRect(rrect, outlinePaint);

        // Draw diamond facets/cracks inside
        final facetPaint = Paint()
          ..color = Colors.white.withOpacity(isPenetrated ? 0.05 : 0.25 * wallOpacity)
          ..strokeWidth = 1.0;
        
        canvas.drawLine(Offset(-cellW / 2 + 4, -cellH / 2 + 4), Offset(cellW / 2 - 4, cellH / 2 - 4), facetPaint);
        canvas.drawLine(Offset(cellW / 2 - 4, -cellH / 2 + 4), Offset(-cellW / 2 + 4, cellH / 2 - 4), facetPaint);
        canvas.drawLine(Offset(0, -cellH / 2 + 4), Offset(0, cellH / 2 - 4), facetPaint);
      } else if (wall.type == 'scrapMetal') {
        // Metallic copper/bronze look
        fillPaint.shader = LinearGradient(
          colors: [const Color(0xFFD84315).withOpacity(wallOpacity), const Color(0xFF4E342E).withOpacity(wallOpacity)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(localRect);

        outlinePaint.color = const Color(0xFF3E2723).withOpacity(wallOpacity);

        canvas.drawRRect(rrect, fillPaint);
        canvas.drawRRect(rrect, outlinePaint);

        // Draw mechanical plates/bolts details inside
        final detailPaint = Paint()
          ..color = Colors.black.withOpacity(0.3 * wallOpacity)
          ..strokeWidth = 1.5;
        
        canvas.drawLine(Offset(-cellW / 2 + 4, 0), Offset(cellW / 2 - 4, 0), detailPaint);
        canvas.drawLine(Offset(0, -cellH / 2 + 4), Offset(0, cellH / 2 - 4), detailPaint);
        
        // Corner bolts
        final boltPaint = Paint()
          ..color = Colors.black.withOpacity(0.4 * wallOpacity)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(-cellW / 3, -cellH / 3), scale * 0.02, boltPaint);
        canvas.drawCircle(Offset(cellW / 3, -cellH / 3), scale * 0.02, boltPaint);
        canvas.drawCircle(Offset(-cellW / 3, cellH / 3), scale * 0.02, boltPaint);
        canvas.drawCircle(Offset(cellW / 3, cellH / 3), scale * 0.02, boltPaint);
      } else if (wall.type == 'spaceLitter') {
        // Space Debris / Trash look (Weakest obstacle, several items in a cell with NO borders)
        final isPenetrated = wall.requiredLaserPower != null && laserIntensity >= wall.requiredLaserPower!;
        final baseOpacity = isPenetrated ? 0.15 : 0.75 * wallOpacity;

        // Config for 4 distinct debris shards orbiting
        final shardSizes = [scale * 0.08, scale * 0.055, scale * 0.075, scale * 0.065];
        final phaseOffsets = [0.0, pi * 0.5 + 0.25, pi + 0.5, pi * 1.5 + 0.15];
        final orbitRadiiX = [cellW * 0.28, cellW * 0.22, cellW * 0.32, cellW * 0.20];
        final orbitRadiiY = [cellH * 0.16, cellH * 0.12, cellH * 0.18, cellH * 0.11];
        final spinSpeeds = [1.2, -2.0, 2.6, -1.5];
        const tiltAngle = -0.436; // -25 degrees in radians for orbit tilt

        // We will compute the 3D depth (Z-value) of each shard to sort them
        final shards = <Map<String, dynamic>>[];
        for (int i = 0; i < 4; i++) {
          final orbitAngle = (bgAnimationValue * 2 * pi) + phaseOffsets[i];
          
          // Tilted elliptical orbit coordinates:
          // x = Rx * cos(theta) * cos(tilt) - Ry * sin(theta) * sin(tilt)
          // y = Rx * cos(theta) * sin(tilt) + Ry * sin(theta) * cos(tilt)
          final cosTheta = cos(orbitAngle);
          final sinTheta = sin(orbitAngle);
          final cosTilt = cos(tiltAngle);
          final sinTilt = sin(tiltAngle);

          final rx = orbitRadiiX[i];
          final ry = orbitRadiiY[i];

          final x = rx * cosTheta * cosTilt - ry * sinTheta * sinTilt;
          final y = rx * cosTheta * sinTilt + ry * sinTheta * cosTilt;

          // The depth Z. sinTheta represents back-to-front projection
          final z = sinTheta; // range [-1.0, 1.0]

          shards.add({
            'index': i,
            'offset': Offset(x, y),
            'z': z,
            'size': shardSizes[i],
            'spinSpeed': spinSpeeds[i],
          });
        }

        // Sort shards from back to front (Z ascending, so lower Z drawn first)
        shards.sort((a, b) => (a['z'] as double).compareTo(b['z'] as double));

        // Render each sorted shard
        for (final shard in shards) {
          final int idx = shard['index'] as int;
          final Offset offset = shard['offset'] as Offset;
          final double zDepth = shard['z'] as double;
          final double baseSize = shard['size'] as double;
          final double spinSpeed = shard['spinSpeed'] as double;

          // Scale and opacity based on depth
          // zDepth is in [-1.0, 1.0]
          final depthScale = 0.65 + 0.35 * ((zDepth + 1.0) / 2.0); // range [0.65, 1.0]
          final depthOpacity = 0.50 + 0.50 * ((zDepth + 1.0) / 2.0); // range [0.5, 1.0]
          final finalOpacity = baseOpacity * depthOpacity;
          final size = baseSize * depthScale;

          // 3D Lighting setup (Light from top-left-front)
          const lx = -0.577;
          const ly = -0.577;
          const lz = 0.577;

          // Facet shading colors
          final Color lightColor = const Color(0xFF6EFEB3).withOpacity(finalOpacity);
          final Color darkColor = const Color(0xFF004D25).withOpacity(finalOpacity);

          // Local spin angle around Y-axis
          final spin = (bgAnimationValue * 2 * pi * spinSpeed) + (idx * 1.7);

          // Build irregular 3D octahedron vertices
          // 6 base vertices:
          // 0: top, 1: bottom, 2: right, 3: back, 4: left, 5: front
          final baseVertices = [
            const _Offset3D(0.0, -1.2, 0.0), // top
            const _Offset3D(0.0, 1.2, 0.0),  // bottom
            const _Offset3D(1.0, 0.0, 0.0),  // right
            const _Offset3D(0.0, 0.0, -1.0), // back
            const _Offset3D(-1.0, 0.0, 0.0), // left
            const _Offset3D(0.0, 0.0, 1.0),  // front
          ];

          // Deterministic vertex perturbation based on index, grid coords, etc.
          double getNoise(int vIdx, int coordIdx) {
            final hash = (idx * 59 + vIdx * 37 + coordIdx * 17 + wall.gridX * 13 + wall.gridY * 31) % 100;
            return -0.22 + (hash / 100.0) * 0.44;
          }

          final rotatedVertices = <Offset>[];
          final rotated3D = <_Offset3D>[];

          for (int v = 0; v < 6; v++) {
            final bv = baseVertices[v];
            // Apply unique noise perturbation to make each shard asymmetrical
            final px = (bv.x + getNoise(v, 0)) * size;
            final py = (bv.y + getNoise(v, 1)) * size;
            final pz = (bv.z + getNoise(v, 2)) * size;

            // Rotate around vertical Y-axis (spin)
            final cosS = cos(spin);
            final sinS = sin(spin);
            final rx = px * cosS - pz * sinS;
            final ry = py;
            final rz = px * sinS + pz * cosS;

            // Apply static tilt around X-axis for organic orientation (15 degrees)
            const cosT = 0.966;
            const sinT = 0.259;

            final tx = rx;
            final ty = ry * cosT - rz * sinT;
            final tz = ry * sinT + rz * cosT;

            // Offset by shard's orbit position and add to lists
            rotatedVertices.add(Offset(tx + offset.dx, ty + offset.dy));
            rotated3D.add(_Offset3D(tx, ty, tz));
          }

          // Octahedron faces winding orders (front faces normal has positive Z)
          const faces = [
            [0, 2, 5], // Top-Right-Front
            [0, 5, 4], // Top-Front-Left
            [0, 4, 3], // Top-Left-Back
            [0, 3, 2], // Top-Back-Right
            [1, 5, 2], // Bottom-Front-Right
            [1, 4, 5], // Bottom-Left-Front
            [1, 3, 4], // Bottom-Back-Left
            [1, 2, 3], // Bottom-Right-Back
          ];

          // Draw front-facing faces (using 2D backface culling)
          for (final face in faces) {
            final pA = rotatedVertices[face[0]];
            final pB = rotatedVertices[face[1]];
            final pC = rotatedVertices[face[2]];

            // 2D Normal Z-component (winding order check)
            // If Nz > 0, the face is front-facing (visible)
            final nz = (pB.dx - pA.dx) * (pC.dy - pA.dy) - (pB.dy - pA.dy) * (pC.dx - pA.dx);

            if (nz > 0) {
              // Compute 3D normal for lighting
              final vA = rotated3D[face[0]];
              final vB = rotated3D[face[1]];
              final vC = rotated3D[face[2]];

              // Normal vector = (B - A) x (C - A)
              final nx = (vB.y - vA.y) * (vC.z - vA.z) - (vB.z - vA.z) * (vC.y - vA.y);
              final ny = (vB.z - vA.z) * (vC.x - vA.x) - (vB.x - vA.x) * (vC.z - vA.z);
              final nz3d = (vB.x - vA.x) * (vC.y - vA.y) - (vB.y - vA.y) * (vC.x - vA.x);

              // Normalize normal vector
              final len = sqrt(nx * nx + ny * ny + nz3d * nz3d);
              double dot = 0.0;
              if (len > 0.0001) {
                final unx = nx / len;
                final uny = ny / len;
                final unz = nz3d / len;
                // Dot product with light source direction
                dot = unx * lx + uny * ly + unz * lz;
              }

              // Map dot product from [-1.0, 1.0] to [0.0, 1.0]
              final tLight = ((dot + 1.0) / 2.0).clamp(0.0, 1.0);

              // Interpolate color based on light
              final faceColor = Color.lerp(darkColor, lightColor, tLight)!;

              final path = Path()
                ..moveTo(pA.dx, pA.dy)
                ..lineTo(pB.dx, pB.dy)
                ..lineTo(pC.dx, pC.dy)
                ..close();

              final facePaint = Paint()
                ..color = faceColor
                ..style = PaintingStyle.fill;

              canvas.drawPath(path, facePaint);

              // Draw extremely thin neon-green highlights on the edges of the front-facing polygons
              if (!isPenetrated) {
                final edgePaint = Paint()
                  ..color = const Color(0xFF00FF87).withOpacity(finalOpacity * 0.35)
                  ..strokeWidth = 0.5
                  ..style = PaintingStyle.stroke;
                canvas.drawPath(path, edgePaint);
              }
            }
          }
        }
      } else {
        // Standard grey rock asteroid
        fillPaint.shader = LinearGradient(
          colors: [const Color(0xFF222831).withOpacity(wallOpacity), const Color(0xFF393E46).withOpacity(wallOpacity), const Color(0xFF1E222B).withOpacity(wallOpacity)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(localRect);

        outlinePaint.color = const Color(0xFF2D3035).withOpacity(wallOpacity);

        canvas.drawRRect(rrect, fillPaint);
        canvas.drawRRect(rrect, outlinePaint);

        // Rock fissure details
        final detailPaint = Paint()
          ..color = Colors.black.withOpacity(0.3 * wallOpacity)
          ..strokeWidth = 1.0;
        canvas.drawLine(Offset(-cellW * 0.2, -cellH * 0.3), Offset(cellW * 0.2, cellH * 0.3), detailPaint);
      }

      // Draw particle shatters if destroyed
      if (showParticles) {
        final rand = Random(wall.gridX * 17 + wall.gridY * 31);
        final particlePaint = Paint()..style = PaintingStyle.fill;
        Color particleColor = const Color(0xFFE0E0E0);
        if (wall.type == 'energyShield') {
          particleColor = const Color(0xFF00FFF5);
        } else if (wall.type == 'spaceLitter') {
          particleColor = const Color(0xFF00FF87);
        } else if (wall.type == 'crystal') {
          particleColor = const Color(0xFFE040FB);
        } else if (wall.type == 'scrapMetal') {
          particleColor = const Color(0xFFFF5722);
        }

        for (int p = 0; p < 8; p++) {
          final angle = rand.nextDouble() * 2 * pi;
          final dist = cellW * 0.7 * particleProgress * (0.4 + 0.6 * rand.nextDouble());
          final px = cos(angle) * dist;
          final py = sin(angle) * dist;
          final pRadius = scale * 0.06 * (1.0 - particleProgress);
          particlePaint.color = particleColor.withOpacity((1.0 - particleProgress).clamp(0.0, 1.0));
          canvas.drawCircle(Offset(px, py), pRadius, particlePaint);
        }
      }

      canvas.restore();
    }

    // 3. Draw Aiming Computer Path Preview (if in edit mode)
    if (playState == PlayState.editing && aimingComputerLevel > 0) {
      // Calculate a preview path (simulate trace)
      final previewResult = LaserCalculator.traceLaser(
        level: level,
        devices: placedDevices,
        startAngleDegrees: aimingAngle,
        laserIntensity: laserIntensity,
      );

      final previewPaint = Paint()
        ..color = const Color(0xFF00ADB5).withOpacity(0.4)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      // Draw dotted preview line
      for (var path in previewResult.paths) {
        if (path.isEmpty) continue;
        
        // Calculate dynamic maximum preview points based on level (10% of maximum board height per level)
        // Maximum board height is 12.0 grid units. With stepSize = 0.05, total steps = 12.0 / 0.05 = 240.
        final double percentage = aimingComputerLevel * 0.1;
        final int maxAllowedPoints = (percentage * 240).toInt();

        final renderLength = min(path.length, maxAllowedPoints);
        final pathObj = Path();
        pathObj.moveTo(toPixels(path[0].dx, path[0].dy).dx, toPixels(path[0].dx, path[0].dy).dy); // fix coord below
        
        for (int i = 0; i < renderLength; i += 3) {
          if (i + 1 < renderLength) {
            final p1 = toPixels(path[i].dx, path[i].dy);
            final p2 = toPixels(path[i+1].dx, path[i+1].dy);
            canvas.drawLine(p1, p2, previewPaint);
          }
        }
      }
    }

    // 4. Draw Portal pairs preset or placed
    final allDevices = [...level.presetDevices, ...placedDevices];
    for (var dev in allDevices) {
      if (!dev.isPlaced) continue;
      final center = cellCenter(dev.gridX, dev.gridY);
      
      final isBombExploded = dev.type == DeviceType.bomb &&
          traceResult != null &&
          playState != PlayState.editing &&
          traceResult!.explosions.any((exp) =>
              exp.targetId == dev.id &&
              animationProgress * LaserCalculator.maxSteps >= exp.stepIndex);

      if (isBombExploded) {
        // Render shockwave expansion cloud instead of bomb hull
        final exp = traceResult!.explosions.firstWhere((e) => e.targetId == dev.id);
        final currentStep = animationProgress * LaserCalculator.maxSteps;
        final elapsed = currentStep - exp.stepIndex;
        
        if (elapsed >= 0 && elapsed < 40) {
          final progress = elapsed / 40.0;
          final expRadius = (scale * 0.4) + (exp.radius * scale * 1.3) * progress;
          
          final expPaint = Paint()
            ..color = const Color(0xFFFF2E93).withOpacity(0.8 * (1.0 - progress))
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, scale * 0.08);
            
          canvas.drawCircle(center, expRadius, expPaint);
          
          final corePaint = Paint()
            ..color = Colors.white.withOpacity(1.0 - progress)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, scale * 0.04);
          canvas.drawCircle(center, expRadius * 0.4, corePaint);
        }
        continue; // Skip normal bomb icon painting
      }

      _drawDevice(canvas, dev, center, scale, cellW, cellH);
    }

    // 5. Draw Target Planets (with atmospheric glows)
    for (var planet in level.planets) {
      // Check if this planet was hit by a previous explosion
      final isDestroyed = traceResult != null && 
          playState != PlayState.editing && 
          traceResult!.hitPlanetIds.contains(planet.id) &&
          traceResult!.explosions.any((exp) => 
              exp.targetId == planet.id && 
              animationProgress * LaserCalculator.maxSteps >= exp.stepIndex);

      if (isDestroyed) {
        // Render explosion cloud/shockwave instead of planet
        final exp = traceResult!.explosions.firstWhere((e) => e.targetId == planet.id);
        final currentStep = animationProgress * LaserCalculator.maxSteps;
        final elapsed = currentStep - exp.stepIndex;
        
        if (elapsed >= 0 && elapsed < 40) {
          final progress = elapsed / 40.0;
          final expPaint = Paint()
            ..color = planet.color.withOpacity(1.0 - progress)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(cellCenter(planet.gridX, planet.gridY), scale * 0.35 * (1.0 + progress * 1.5), expPaint);

          // Render ring lines
          final ringPaint = Paint()
            ..color = Colors.white.withOpacity(1.0 - progress)
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke;
          canvas.drawOval(
            Rect.fromCenter(
              center: cellCenter(planet.gridX, planet.gridY),
              width: scale * 0.8 * (1.0 + progress * 2),
              height: scale * 0.2 * (1.0 + progress * 2),
            ),
            ringPaint,
          );
        }
        continue;
      }

      final center = cellCenter(planet.gridX, planet.gridY);
      final radius = scale * 0.32;

      // Draw atmospheric glow
      final glowPaint = Paint()
        ..color = planet.color.withOpacity(0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, scale * 0.1);
      canvas.drawCircle(center, radius + scale * 0.08, glowPaint);

      // Draw dynamic tech-shield sector rings around shielded planets
      if (planet.requiredLaserPower != null && planet.requiredLaserPower! > 1) {
        final shieldPower = planet.requiredLaserPower!;
        final shieldColor = (shieldPower == 2) ? const Color(0xFF00FFF5) : const Color(0xFFFF2E93);
        final pulse = 1.0 + 0.06 * sin(bgAnimationValue * 2 * pi * 2);

        // 1. Draw glowing background circle
        final shieldBgPaint = Paint()
          ..color = shieldColor.withOpacity(0.08)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, radius * 1.25 * pulse, shieldBgPaint);

        // 2. Draw outer boundary circular shield rings
        final shieldBorderPaint = Paint()
          ..color = shieldColor.withOpacity(0.35)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(center, radius * 1.25 * pulse, shieldBorderPaint);

        final shieldOuterBorderPaint = Paint()
          ..color = shieldColor.withOpacity(0.12)
          ..strokeWidth = 0.8
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(center, radius * 1.35 * pulse, shieldOuterBorderPaint);

        // 3. Draw N orbiting sector ticks representing active shield sectors
        final tickPaint = Paint()
          ..color = shieldColor.withOpacity(0.85)
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        for (int t = 0; t < shieldPower; t++) {
          final startAngle = (bgAnimationValue * 2 * pi * 0.25) + t * (2 * pi / shieldPower);
          canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius * 1.25 * pulse),
            startAngle,
            0.5,
            false,
            tickPaint,
          );
        }
      }

      // Draw planet body with spherical radial gradient
      final bodyPaint = Paint()
        ..shader = RadialGradient(
          colors: [Colors.white, planet.color, planet.color.withRed(50).withGreen(50).withBlue(50)],
          stops: const [0.05, 0.6, 1.0],
          center: const Alignment(-0.3, -0.3),
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawCircle(center, radius, bodyPaint);

      // Draw planet orbital rings or clouds details
      final ringPaint = Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.8),
        0.5,
        pi,
        false,
        ringPaint,
      );

      // --- Draw Orbiting Satellites & Escort Fighters (Phase 4) ---
      final orbitRadius = radius * 1.55;
      final planetSeed = planet.id.hashCode;
      final orbitSpeed = 0.5 + (planetSeed % 3) * 0.4;
      final orbitAngle = (bgAnimationValue * 2 * pi * orbitSpeed) + (planetSeed * 0.45);
      
      final satPos = center + Offset(cos(orbitAngle) * orbitRadius, sin(orbitAngle) * orbitRadius);
      
      canvas.save();
      canvas.translate(satPos.dx, satPos.dy);
      canvas.rotate(orbitAngle + pi / 2); // Rotate to face flight direction

      // Render custom micro space entity based on planetSeed hash:
      // Even seed: tiny solar-wing satellite
      // Odd seed: micro patroller fighter
      if (planetSeed % 2 == 0) {
        // Draw satellite core (small silver circle)
        final satCorePaint = Paint()
          ..color = const Color(0xFFC0C0C0)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset.zero, 2.2, satCorePaint);

        // Draw blue solar panel wings
        final wingPaint = Paint()
          ..color = const Color(0xFF00ADB5)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.fill;
        canvas.drawRect(Rect.fromCenter(center: const Offset(-5, 0), width: 3.5, height: 1.2), wingPaint);
        canvas.drawRect(Rect.fromCenter(center: const Offset(5, 0), width: 3.5, height: 1.2), wingPaint);

        // Draw connecting wing rods
        final rodPaint = Paint()
          ..color = Colors.grey
          ..strokeWidth = 0.5;
        canvas.drawLine(const Offset(-5, 0), const Offset(5, 0), rodPaint);
      } else {
        // Draw micro patroller ship (cyberpunk pink tail, delta wing body)
        final shipBody = Path()
          ..moveTo(0, -4)
          ..lineTo(3.2, 2.5)
          ..lineTo(-3.2, 2.5)
          ..close();
          
        final shipPaint = Paint()
          ..color = const Color(0xFF8E9AAF)
          ..style = PaintingStyle.fill;
        canvas.drawPath(shipBody, shipPaint);

        // Tiny wing flare details
        final wingPaint = Paint()
          ..color = const Color(0xFFFF2E93)
          ..strokeWidth = 0.8
          ..style = PaintingStyle.stroke;
        canvas.drawLine(const Offset(-3.2, 2.5), const Offset(-4.5, 3.2), wingPaint);
        canvas.drawLine(const Offset(3.2, 2.5), const Offset(4.5, 3.2), wingPaint);
      }

      // Draw flashing neon navigation beacon light
      final blinkAngle = (bgAnimationValue * 6 * pi) + planetSeed;
      final isBlinkOn = sin(blinkAngle) > 0.1;
      if (isBlinkOn) {
        final navLightPaint = Paint()
          ..color = (planetSeed % 2 == 0) ? const Color(0xFF00FFF5) : const Color(0xFFFF2E93)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(const Offset(0, 3), 0.9, navLightPaint);
      }
      
      canvas.restore();
    }

    // 6. Draw Death Star Emitter (at level.deathStarX, level.deathStarY)
    final dsCenter = cellCenter(level.deathStarX, level.deathStarY);
    
    // Draw Targeting Semi-Circle (glowing dial around bottom Death Star) in editing mode
    if (playState == PlayState.editing) {
      final dialRadius = scale * 1.6;
      
      // Draw background glow for the dial area (faded out to 0 when idle)
      final dialGlowPaint = Paint()
        ..color = const Color(0xFF00ADB5).withOpacity(0.06 * aimAnimationValue)
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: dsCenter, radius: dialRadius),
        pi, // from -180 degrees (left)
        pi, // to 0 degrees (right)
        true, // solid pie wedge
        dialGlowPaint,
      );

      // Draw the neon dial boundary arc
      final dialArcPaint = Paint()
        ..color = const Color(0xFF00ADB5).withOpacity(0.4 * aimAnimationValue)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawArc(
        Rect.fromCircle(center: dsCenter, radius: dialRadius),
        pi,
        pi,
        false,
        dialArcPaint,
      );

      // Draw glowing outer dotted dial at slightly larger radius
      final dotDialRadius = dialRadius + 8.0;
      final dotPaint = Paint()
        ..color = const Color(0xFF00FFF5).withOpacity(0.6 * aimAnimationValue)
        ..style = PaintingStyle.fill;
      
      // Draw ticks and angle labels every 30 degrees from -180 to 0
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
      );

      for (int angle = -180; angle <= 0; angle += 30) {
        final rad = angle * pi / 180.0;
        final dotPos = dsCenter + Offset(cos(rad) * dotDialRadius, sin(rad) * dotDialRadius);
        
        // Draw tick dot
        canvas.drawCircle(dotPos, 2.0, dotPaint);

        // Draw dynamic indicator lines for major directions
        final isMajor = (angle % 90 == 0);
        final tickLinePaint = Paint()
          ..color = isMajor 
              ? const Color(0xFF00FFF5).withOpacity(0.7 * aimAnimationValue) 
              : const Color(0xFF00ADB5).withOpacity(0.3 * aimAnimationValue)
          ..strokeWidth = isMajor ? 1.5 : 1.0;
        canvas.drawLine(
          dsCenter + Offset(cos(rad) * (dialRadius - 6), sin(rad) * (dialRadius - 6)),
          dsCenter + Offset(cos(rad) * dialRadius, sin(rad) * dialRadius),
          tickLinePaint,
        );

        // Draw degree text labels for major angles (-180, -90, 0)
        if (isMajor) {
          final labelText = "$angle°";
          textPainter.text = TextSpan(
            text: labelText,
            style: TextStyle(
              color: const Color(0xFF00FFF5).withOpacity(0.8 * aimAnimationValue),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          );
          textPainter.layout();
          // Offset text slightly to not overlap the dots
          final textOffset = dsCenter + Offset(
            cos(rad) * (dotDialRadius + 14) - textPainter.width / 2,
            sin(rad) * (dotDialRadius + 14) - textPainter.height / 2,
          );
          textPainter.paint(canvas, textOffset);
        }
      }

      // Draw the active aiming vector pointer line (Show projector line only when not aiming)
      final aimRad = aimingAngle * pi / 180.0;
      final pointerEnd = dsCenter + Offset(cos(aimRad) * dialRadius, sin(aimRad) * dialRadius);
      
      final activePointerPaint = Paint()
        ..color = const Color(0xFF00FFF5).withOpacity(0.35 + 0.45 * aimAnimationValue) // Subtle idle, fully active on aim
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      
      // Draw solid pointing vector line
      canvas.drawLine(dsCenter, pointerEnd, activePointerPaint);

      // Draw a glowing reticle bubble at the intersection of aiming angle and dial
      final bubblePaint = Paint()
        ..color = const Color(0xFF00FFF5).withOpacity(0.4 + 0.6 * aimAnimationValue)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(pointerEnd, 4.0, bubblePaint);

      // Outer rings
      final ringPaint = Paint()
        ..color = const Color(0xFF00FFF5).withOpacity(0.2 + 0.4 * aimAnimationValue)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(pointerEnd, 8.0, ringPaint);
    }

    final dsRadius = scale * 0.42;

    // Draw main Death Star hull (dark metal sphere)
    final dsHullPaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF4F5D75), const Color(0xFF2D3142), const Color(0xFF1C1E26)],
        stops: const [0.0, 0.7, 1.0],
        center: const Alignment(-0.2, -0.2),
      ).createShader(Rect.fromCircle(center: dsCenter, radius: dsRadius));
    canvas.drawCircle(dsCenter, dsRadius, dsHullPaint);

    // Draw equator trench line
    final trenchPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(dsCenter.dx - dsRadius, dsCenter.dy),
      Offset(dsCenter.dx + dsRadius, dsCenter.dy),
      trenchPaint,
    );

    // Draw superlaser focusing dish (crater), rotating based on aiming angle
    final dishAngleRad = aimingAngle * pi / 180.0;
    final dishCenterOffset = Offset(cos(dishAngleRad) * (dsRadius * 0.5), sin(dishAngleRad) * (dsRadius * 0.5));
    final dishCenter = dsCenter + dishCenterOffset;

    final dishOuterPaint = Paint()
      ..color = const Color(0xFF1F222E)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(dishCenter, dsRadius * 0.35, dishOuterPaint);

    final dishInnerPaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF00ADB5), const Color(0xFF111424)],
      ).createShader(Rect.fromCircle(center: dishCenter, radius: dsRadius * 0.22));
    canvas.drawCircle(dishCenter, dsRadius * 0.22, dishInnerPaint);

    // Draw pulsing energy charge in emitter if in firing mode
    if (playState == PlayState.firing || playState == PlayState.victory) {
      final chargePaint = Paint()
        ..color = const Color(0xFF00FFF5)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, scale * 0.05);
      canvas.drawCircle(dishCenter, dsRadius * 0.12 * (1.0 + 0.3 * sin(animationProgress * 30)), chargePaint);
    }

    // 7. Draw Laser Trace (if in simulation state)
    if (traceResult != null && playState != PlayState.editing) {
      final totalSteps = LaserCalculator.maxSteps.toDouble();
      final currentMaxStep = animationProgress * totalSteps;
      final tailLength = 40.0; // Length of the laser missile trail in steps

      for (var path in traceResult!.paths) {
        if (path.isEmpty) continue;

        for (int i = 1; i < path.length; i++) {
          final p1 = path[i - 1];
          final p2 = path[i];

          final age1 = currentMaxStep - (i - 1);
          final age2 = currentMaxStep - i;

          final minAge = age2;
          final maxAge = age1;

          if (maxAge < 0 || minAge > tailLength) {
            continue; // Skip segments completely in the future or completely in the past
          }

          // Clip parameters t1 and t2 along the segment (0.0 to 1.0)
          double t1 = 0.0;
          double t2 = 1.0;

          final ageDiff = age2 - age1; // -1.0

          if (ageDiff != 0) {
            if (age1 < 0) {
              t1 = -age1 / ageDiff;
            } else if (age1 > tailLength) {
              t1 = (tailLength - age1) / ageDiff;
            }

            if (age2 < 0) {
              t2 = -age1 / ageDiff;
            } else if (age2 > tailLength) {
              t2 = (tailLength - age1) / ageDiff;
            }
          }

          // Calculate clipped coordinates
          final clipP1 = p1 + (p2 - p1) * t1;
          final clipP2 = p1 + (p2 - p1) * t2;

          // Convert to pixels
          final pix1 = toPixels(clipP1.dx, clipP1.dy);
          final pix2 = toPixels(clipP2.dx, clipP2.dy);

          // Calculate average age for styling
          final avgAge = age1 + ((t1 + t2) / 2.0) * ageDiff;
          final ageProgress = (avgAge / tailLength).clamp(0.0, 1.0);

          final opacity = 1.0 - ageProgress;
          final widthFactor = 1.0 - 0.65 * ageProgress; // Taper to 35% thickness

          // Draw glow line
          final glowLaserPaint = Paint()
            ..color = const Color(0xFF00FFF5).withOpacity(0.8 * opacity)
            ..strokeWidth = 6.0 * widthFactor
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, scale * 0.05 * widthFactor);
          canvas.drawLine(pix1, pix2, glowLaserPaint);

          // Draw core line
          final coreLaserPaint = Paint()
            ..color = Colors.white.withOpacity(opacity)
            ..strokeWidth = 2.0 * widthFactor
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;
          canvas.drawLine(pix1, pix2, coreLaserPaint);
        }
      }

      // 8. Draw Explosions / Shockwaves
      for (var exp in traceResult!.explosions) {
        if (currentMaxStep < exp.stepIndex) continue;

        // Time elapsed since explosion started
        final elapsed = currentMaxStep - exp.stepIndex;
        // Exp anim duration = 30 steps
        if (elapsed < 30) {
          final progress = elapsed / 30.0;
          final expPixelCenter = toPixels(exp.gridPos.dx, exp.gridPos.dy);

          if (exp.isBomb) {
            // Draw a massive shockwave ring
            final bombExplosionPaint = Paint()
              ..color = Colors.orangeAccent.withOpacity(1.0 - progress)
              ..style = PaintingStyle.fill;
            canvas.drawCircle(expPixelCenter, scale * exp.radius * progress, bombExplosionPaint);

            // Draw spark particles
            final rand = Random(exp.stepIndex);
            final sparkPaint = Paint()
              ..color = Colors.yellowAccent.withOpacity(1.0 - progress)
              ..strokeWidth = 2.0;

            for (int s = 0; s < 12; s++) {
              final angle = rand.nextDouble() * 2 * pi;
              final speed = scale * exp.radius * (0.3 + 0.7 * rand.nextDouble());
              final startOffset = Offset(cos(angle) * speed * progress * 0.5, sin(angle) * speed * progress * 0.5);
              final endOffset = Offset(cos(angle) * speed * progress, sin(angle) * speed * progress);
              canvas.drawLine(expPixelCenter + startOffset, expPixelCenter + endOffset, sparkPaint);
            }
          } else {
            // Planet destruction shockwave (handled inside planet loop to allow hiding planet, 
            // but we can draw generic details here too)
          }
        }
      }
    }
  }

  // Draw Device helper
  void _drawDevice(Canvas canvas, DeviceModel dev, Offset center, double scale, double cellW, double cellH) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(dev.angleDegrees * pi / 180.0);

    final itemRadius = scale * 0.35;

    switch (dev.type) {
      case DeviceType.reflector:
        // Draw standard vector glass mirror
        final backPaint = Paint()
          ..color = const Color(0xFF1A1A24)
          ..style = PaintingStyle.fill;
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: itemRadius * 2, height: scale * 0.15), backPaint);

        // Glass reflection mirror panel
        final glassPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF00FFF5), Color(0xFF00A8CC), Color(0xFF00FFF5)],
          ).createShader(Rect.fromCenter(center: Offset.zero, width: itemRadius * 2, height: scale * 0.08))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, scale * 0.015);

        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: itemRadius * 1.8, height: scale * 0.07), glassPaint);

        // Draw anchor mounts on sides
        final mountPaint = Paint()
          ..color = const Color(0xFF888888)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(-itemRadius, 0), scale * 0.05, mountPaint);
        canvas.drawCircle(Offset(itemRadius, 0), scale * 0.05, mountPaint);
        break;

      case DeviceType.splitter:
        final angle = dev.splitAngleDegrees ?? 180.0;
        
        // Color mapping for variants
        Color primaryGlow;
        List<Color> gradientColors;
        
        if (angle == 45.0) {
          primaryGlow = const Color(0xFF00FFF5); // Cyan
          gradientColors = const [Color(0xFF00ADB5), Color(0xFF00565B)];
        } else if (angle == 90.0) {
          primaryGlow = const Color(0xFFE0245E); // Neon Pink-Red
          gradientColors = const [Color(0xFF7209B7), Color(0xFF3F076E)];
        } else if (angle == 135.0) {
          primaryGlow = const Color(0xFFFFB703); // Amber
          gradientColors = const [Color(0xFFFB8500), Color(0xFF9E5200)];
        } else { // 180.0
          primaryGlow = const Color(0xFFFF2E93); // Hot Pink
          gradientColors = const [Color(0xFFFF0055), Color(0xFF7A0826)];
        }

        // Draw exit direction helper lines (dotted vectors emerging from central prism)
        final helperPaint = Paint()
          ..color = primaryGlow.withOpacity(0.6)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
          
        final splitRad = angle * pi / 180.0;
        
        // Output line 1 (along local x-axis, i.e., 0 degrees)
        canvas.drawLine(Offset.zero, Offset(itemRadius * 1.5, 0), helperPaint);
        // Output line 2 (along local split angle)
        canvas.drawLine(Offset.zero, Offset(cos(splitRad) * itemRadius * 1.5, sin(splitRad) * itemRadius * 1.5), helperPaint);

        // Draw arrows at the ends of helpers
        _drawArrowTip(canvas, Offset(itemRadius * 1.5, 0), 0.0, scale, primaryGlow);
        _drawArrowTip(canvas, Offset(cos(splitRad) * itemRadius * 1.5, sin(splitRad) * itemRadius * 1.5), splitRad, scale, primaryGlow);

        // Triangle shape representing prism
        final path = Path()
          ..moveTo(0, -itemRadius)
          ..lineTo(itemRadius, itemRadius)
          ..lineTo(-itemRadius, itemRadius)
          ..close();

        final prismPaint = Paint()
          ..shader = LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromCenter(center: Offset.zero, width: itemRadius * 2, height: itemRadius * 2));
        canvas.drawPath(path, prismPaint);

        // Highlight split outline
        final splitOutline = Paint()
          ..color = primaryGlow
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
        canvas.drawPath(path, splitOutline);

        // Core dot
        final corePaint = Paint()
          ..color = Colors.white.withOpacity(0.8)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset.zero, scale * 0.05, corePaint);
        break;

      case DeviceType.gravityWell:
        // Black hole / Gravity core (Swirling portals)
        final wellPaint = Paint()
          ..shader = RadialGradient(
            colors: [Colors.black, const Color(0xFF7B2CBF), Colors.transparent],
            stops: const [0.2, 0.7, 1.0],
          ).createShader(Rect.fromCircle(center: Offset.zero, radius: itemRadius));
        canvas.drawCircle(Offset.zero, itemRadius, wellPaint);

        // Core dot
        final corePaint = Paint()
          ..color = const Color(0xFFE0AAFF)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, scale * 0.02);
        canvas.drawCircle(Offset.zero, scale * 0.08, corePaint);
        break;

      case DeviceType.bomb:
        // Red ticking spike core
        final bombHullPaint = Paint()
          ..shader = RadialGradient(
            colors: [const Color(0xFFFF3333), const Color(0xFF660000)],
            center: const Alignment(-0.2, -0.2),
          ).createShader(Rect.fromCircle(center: Offset.zero, radius: itemRadius * 0.7));
        canvas.drawCircle(Offset.zero, itemRadius * 0.7, bombHullPaint);

        // Draw spikes
        final spikePaint = Paint()
          ..color = const Color(0xFFFF5555)
          ..strokeWidth = 2.0;
        for (int i = 0; i < 8; i++) {
          final angle = i * pi / 4.0;
          canvas.drawLine(Offset.zero, Offset(cos(angle) * itemRadius, sin(angle) * itemRadius), spikePaint);
        }

        // Ticking warning light
        final warningPaint = Paint()
          ..color = const Color(0xFFFFD166)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, scale * 0.015);
        canvas.drawCircle(Offset.zero, scale * 0.08, warningPaint);
        break;

      case DeviceType.portal:
        // Portal ellipse
        final portalBg = Paint()
          ..color = const Color(0xFF12131C)
          ..style = PaintingStyle.fill;
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: itemRadius * 1.8, height: scale * 0.22), portalBg);

        // Color coding (Orange / Blue portal styles)
        final color = (dev.portalPairId.hashCode % 2 == 0) ? const Color(0xFFFF9F1C) : const Color(0xFF00ADB5);

        final ringPaint = Paint()
          ..color = color
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, scale * 0.02);
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: itemRadius * 1.7, height: scale * 0.20), ringPaint);
        break;
    }

    canvas.restore();
  }

  void _drawArrowTip(Canvas canvas, Offset tipPos, double angleRad, double scale, Color color) {
    canvas.save();
    canvas.translate(tipPos.dx, tipPos.dy);
    canvas.rotate(angleRad);
    
    final size = scale * 0.08;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(-size, -size * 0.6)
      ..lineTo(-size, size * 0.6)
      ..close();
      
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) {
    return oldDelegate.level != level ||
        oldDelegate.placedDevices != placedDevices ||
        oldDelegate.aimingAngle != aimingAngle ||
        oldDelegate.playState != playState ||
        oldDelegate.traceResult != traceResult ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.aimingComputerLevel != aimingComputerLevel ||
        oldDelegate.selectedInventoryDevice != selectedInventoryDevice ||
        oldDelegate.bgAnimationValue != bgAnimationValue ||
        oldDelegate.aimAnimationValue != aimAnimationValue;
  }
}

class _Offset3D {
  final double x;
  final double y;
  final double z;
  const _Offset3D(this.x, this.y, this.z);
}
