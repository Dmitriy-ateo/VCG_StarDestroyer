import 'dart:math';
import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../models/level_data.dart';

class LaserSegment {
  final List<Offset> points;
  final bool isActive;
  LaserSegment(this.points, {this.isActive = true});
}

class ExplosionEvent {
  final Offset gridPos;
  final int stepIndex; // At what step did it detonate
  final double radius;
  final String targetId; // If planet, its ID
  final bool isBomb; // Whether it is a bomb or a planet

  ExplosionEvent({
    required this.gridPos,
    required this.stepIndex,
    required this.radius,
    required this.targetId,
    this.isBomb = false,
  });
}

class AudioTriggerEvent {
  final String sfxName;
  final int stepIndex;

  AudioTriggerEvent(this.sfxName, this.stepIndex);
}

class LaserTraceResult {
  final List<List<Offset>> paths; // All laser paths (multiple due to splitters)
  final Set<String> hitPlanetIds; // Planets hit
  final List<ExplosionEvent> explosions; // Bomb/planet explosions
  final List<AudioTriggerEvent> audioTriggers; // Dynamic audio triggers (reflections, teleports)
  final bool success; // Did we destroy all planets?

  LaserTraceResult({
    required this.paths,
    required this.hitPlanetIds,
    required this.explosions,
    required this.audioTriggers,
    required this.success,
  });
}

class LaserBeam {
  Offset pos;
  Offset dir;
  List<Offset> path;
  Set<String> visitedDevices;
  bool isAlive;
  int intensity;

  LaserBeam({
    required this.pos,
    required this.dir,
    required this.path,
    required this.visitedDevices,
    this.isAlive = true,
    required this.intensity,
  });
}

class LaserCalculator {
  static const int maxSteps = 400; // Limit laser length to prevent loops
  static const double stepSize = 0.05; // High resolution stepping
  static const double gridWidth = 8.0;
  static const double gridHeight = 12.0;

  static Offset? intersectSegments(Offset p1, Offset p2, Offset a, Offset b) {
    final double den = (b.dy - a.dy) * (p2.dx - p1.dx) - (b.dx - a.dx) * (p2.dy - p1.dy);
    if (den == 0) return null; // Parallel
    
    final double ua = ((b.dx - a.dx) * (p1.dy - a.dy) - (b.dy - a.dy) * (p1.dx - a.dx)) / den;
    final double ub = ((p2.dx - p1.dx) * (p1.dy - a.dy) - (p2.dy - p1.dy) * (p1.dx - a.dx)) / den;
    
    const double eps = 1e-9;
    if (ua >= -eps && ua <= 1.0 + eps && ub >= -eps && ub <= 1.0 + eps) {
      return Offset(p1.dx + ua * (p2.dx - p1.dx), p1.dy + ua * (p2.dy - p1.dy));
    }
    return null;
  }

  static LaserTraceResult traceLaser({
    required LevelData level,
    required List<DeviceModel> devices,
    required double startAngleDegrees,
    required int laserIntensity, // Upgrades affect range/intensity
    required Map<DeviceType, int> deviceLevels, // Device tech levels
  }) {
    final startRad = startAngleDegrees * pi / 180.0;
    final startPos = Offset(level.deathStarX + 0.5, level.deathStarY + 0.5);
    final startDir = Offset(cos(startRad), sin(startRad));

    final List<LaserBeam> activeBeams = [
      LaserBeam(
        pos: startPos,
        dir: startDir,
        path: [startPos],
        visitedDevices: {},
        intensity: laserIntensity,
      )
    ];

    final List<List<Offset>> finalizedPaths = [];
    final Set<String> hitPlanetIds = {};
    final List<ExplosionEvent> explosions = [];
    final List<AudioTriggerEvent> audioTriggers = [];
    
    // Track bomb grids that have exploded
    final Set<String> explodedBombIds = {};

    // Combine preset level devices and player placed devices
    final List<DeviceModel> allDevices = [...level.presetDevices, ...devices];

    int step = 0;
    while (activeBeams.isNotEmpty && step < maxSteps) {
      step++;
      final List<LaserBeam> nextBeams = [];

      for (var beam in activeBeams) {
        if (!beam.isAlive) continue;

        // Move beam
        beam.pos += beam.dir * stepSize;
        beam.path.add(beam.pos);

        // 1. Boundary check
        if (beam.pos.dx < 0 || beam.pos.dx > gridWidth || beam.pos.dy < 0 || beam.pos.dy > gridHeight) {
          beam.isAlive = false;
          finalizedPaths.add(beam.path);
          continue;
        }

        // 2. Wall check
        bool hitWall = false;
        for (var wall in level.walls) {
          // If inside the wall cell [gridX, gridX+1] x [gridY, gridY+1]
          if (beam.pos.dx >= wall.gridX && beam.pos.dx <= wall.gridX + 1 &&
              beam.pos.dy >= wall.gridY && beam.pos.dy <= wall.gridY + 1) {
            
            // Check if laser intensity is enough to penetrate and shatter this wall
            if (wall.requiredLaserPower != null && beam.intensity >= wall.requiredLaserPower!) {
              final wallId = "wall_${wall.gridX}_${wall.gridY}";
              
              if (beam.visitedDevices.contains(wallId)) {
                continue; // Already penetrated this block, let the laser pass through freely
              }
              
              beam.visitedDevices.add(wallId);

              if (!explodedBombIds.contains(wallId)) {
                explodedBombIds.add(wallId);
                explosions.add(ExplosionEvent(
                  gridPos: Offset(wall.gridX + 0.5, wall.gridY + 0.5),
                  stepIndex: step,
                  radius: 1.0,
                  targetId: wallId,
                  isBomb: false,
                ));
              }
              beam.intensity--; // Lose 1 power on penetration!
              continue; // Penetrate and bypass
            }

            hitWall = true;
            break;
          }
        }
        if (hitWall) {
          beam.isAlive = false;
          finalizedPaths.add(beam.path);
          continue;
        }

        // 3. Planet collision check
        bool isBlockedByPlanet = false;

        for (var planet in level.planets) {
          if (planet.isDestroyed || beam.visitedDevices.contains(planet.id)) continue;
          
          final planetCenter = Offset(planet.gridX + 0.5, planet.gridY + 0.5);
          final dist = (beam.pos - planetCenter).distance;
          
          if (dist < 0.4) {
            final reqPower = planet.requiredLaserPower ?? 1;

            if (beam.intensity < reqPower) {
              // Case 1: Blocked completely (Laser intensity too low).
              isBlockedByPlanet = true;
              break;
            } else if (beam.intensity == reqPower) {
              // Case 2: Hits, destroys, and terminates (matching power).
              hitPlanetIds.add(planet.id);
              explosions.add(ExplosionEvent(
                gridPos: planetCenter,
                stepIndex: step,
                radius: 1.0,
                targetId: planet.id,
                isBomb: false,
              ));
              isBlockedByPlanet = true;
              break;
            } else {
              // Case 3: Hits, destroys, loses 1 intensity, and continues/penetrates!
              hitPlanetIds.add(planet.id);
              explosions.add(ExplosionEvent(
                gridPos: planetCenter,
                stepIndex: step,
                radius: 1.0,
                targetId: planet.id,
                isBomb: false,
              ));
              beam.visitedDevices.add(planet.id);
              beam.intensity--;
              // Do not set hitPlanetId or isBlockedByPlanet, allowing the beam to propagate forward!
            }
          }
        }
        if (isBlockedByPlanet) {
          beam.isAlive = false;
          finalizedPaths.add(beam.path);
          continue;
        }

        // 4. Device interactions
        bool beamDeactivated = false;
        for (var dev in allDevices) {
          if (!dev.isPlaced) continue;

          final devCenter = Offset(dev.gridX + 0.5, dev.gridY + 0.5);
          final dist = (beam.pos - devCenter).distance;

          // If within active radius of the device
          if (dist < 0.35) {
            if (beam.visitedDevices.contains(dev.id)) {
              // Already interacted with this device recently, skip to prevent double triggers
              continue;
            }

            beam.visitedDevices.add(dev.id);

            if (dev.type == DeviceType.reflector) {
              final mirrorRad = dev.angleDegrees * pi / 180.0;
              final mirrorDir = Offset(cos(mirrorRad), sin(mirrorRad));
              final a = devCenter - mirrorDir * 0.35;
              final b = devCenter + mirrorDir * 0.35;

              final p1 = beam.path.length >= 2 ? beam.path[beam.path.length - 2] : beam.pos - beam.dir * stepSize;
              final p2 = beam.pos;

              final ip = intersectSegments(p1, p2, a, b);
              if (ip != null) {
                // Vector Reflection
                final normal = Offset(-sin(mirrorRad), cos(mirrorRad));
                final dot = beam.dir.dx * normal.dx + beam.dir.dy * normal.dy;
                beam.dir = beam.dir - normal * (2 * dot);
                beam.dir = beam.dir / beam.dir.distance; // Normalize

                beam.pos = ip;
                if (beam.path.isNotEmpty) {
                  beam.path[beam.path.length - 1] = ip;
                }
                audioTriggers.add(AudioTriggerEvent('audio/deflect.mp3', step));
              } else {
                // Not a real collision with the mirror segment. 
                // Remove from visited so it can be re-evaluated next step.
                beam.visitedDevices.remove(dev.id);
                continue;
              }
            } 
            else if (dev.type == DeviceType.splitter) {
              // Splitter splits the laser into two directions:
              // 1. Vector 1 is aligned with splitter rotation (dev.angleDegrees)
              // 2. Vector 2 is rotated by the splitter's variant separation angle (dev.splitAngleDegrees)
              final splitDiff = dev.splitAngleDegrees ?? 180.0;
              final angle1Rad = dev.angleDegrees * pi / 180.0;
              final angle2Rad = (dev.angleDegrees + splitDiff) * pi / 180.0;

              final dir1 = Offset(cos(angle1Rad), sin(angle1Rad));
              final dir2 = Offset(cos(angle2Rad), sin(angle2Rad));

              // Snap current beam position to splitter center
              beam.pos = devCenter;
              if (beam.path.isNotEmpty) {
                beam.path[beam.path.length - 1] = devCenter;
              }

              // Optical prism splitting efficiency upgrade impact
              final splitterLevel = deviceLevels[DeviceType.splitter] ?? 1;
              final nextIntensity = (splitterLevel == 1) ? (beam.intensity - 1) : beam.intensity;

              // Create a second beam going in direction 2 with copied path history
              nextBeams.add(LaserBeam(
                pos: devCenter,
                dir: dir2,
                path: List.from(beam.path),
                visitedDevices: Set.from(beam.visitedDevices),
                intensity: nextIntensity,
              ));

              // Redirect the original beam to direction 1
              beam.dir = dir1;
              audioTriggers.add(AudioTriggerEvent('audio/deflect.mp3', step));
              if (splitterLevel == 1) {
                beam.intensity--;
              }
            } 
            else if (dev.type == DeviceType.bomb) {
              if (!explodedBombIds.contains(dev.id)) {
                explodedBombIds.add(dev.id);
                // Trigger explosion event
                explosions.add(ExplosionEvent(
                  gridPos: devCenter,
                  stepIndex: step,
                  radius: 2.2, // Explodes surrounding cells
                  targetId: dev.id,
                  isBomb: true,
                ));

                // Detonate any planets in the explosion radius depending on bomb level vs shield power!
                final bombLevel = deviceLevels[DeviceType.bomb] ?? 1;
                for (var planet in level.planets) {
                  final pCenter = Offset(planet.gridX + 0.5, planet.gridY + 0.5);
                  final expDist = (devCenter - pCenter).distance;
                  if (expDist < 2.2) {
                    final reqPower = planet.requiredLaserPower ?? 1;
                    // Bomb must have high enough level to detonate the planet's shield!
                    if (bombLevel >= reqPower) {
                      if (!hitPlanetIds.contains(planet.id)) {
                        hitPlanetIds.add(planet.id);
                        explosions.add(ExplosionEvent(
                          gridPos: pCenter,
                          stepIndex: step + 5, // Explodes shortly after the bomb
                          radius: 1.0,
                          targetId: planet.id,
                          isBomb: false,
                        ));
                      }
                    }
                  }
                }
              }
              // Beam is absorbed by bomb detonation
              beamDeactivated = true;
              break;
            } 
            else if (dev.type == DeviceType.portal) {
              // Find the paired portal
              final pair = allDevices.firstWhere(
                (d) => d.id == dev.portalPairId || (d.portalPairId == dev.id && d.id != dev.id),
                orElse: () => dev,
              );

              if (pair != dev && pair.isPlaced) {
                final pairCenter = Offset(pair.gridX + 0.5, pair.gridY + 0.5);
                
                // Add the jump point to path
                beam.path.add(devCenter);
                
                // Teleport to paired portal center
                beam.pos = pairCenter;
                beam.visitedDevices.add(pair.id); // Don't re-trigger immediately
                audioTriggers.add(AudioTriggerEvent('audio/portal_warp.mp3', step));

                // Teleportation field stabilization upgrade impact
                final portalLevel = deviceLevels[DeviceType.portal] ?? 1;
                if (portalLevel == 1) {
                  beam.intensity--; // Unstable Level 1 portal drains 1 laser power!
                }
              }
            }
            else if (dev.type == DeviceType.floatingAsteroid) {
              if (!explodedBombIds.contains(dev.id)) {
                explodedBombIds.add(dev.id);

                // Slight deflection based on asteroid angleDegrees (-15 to 45 deg, etc.)
                final double shiftRad = dev.angleDegrees * pi / 180.0;
                final double currentAngleRad = atan2(beam.dir.dy, beam.dir.dx);
                final double newAngleRad = currentAngleRad + shiftRad;
                
                beam.dir = Offset(cos(newAngleRad), sin(newAngleRad));
                beam.dir = beam.dir / beam.dir.distance; // Normalize

                // Snap current beam position to asteroid center
                beam.pos = devCenter;
                if (beam.path.isNotEmpty) {
                  beam.path[beam.path.length - 1] = devCenter;
                }

                // Shattering debris explosion
                explosions.add(ExplosionEvent(
                  gridPos: devCenter,
                  stepIndex: step,
                  radius: 1.3, // organic dust debris cloud
                  targetId: dev.id,
                  isBomb: true,
                ));
              }
            }
          }
        }

        if (beamDeactivated) {
          beam.isAlive = false;
          finalizedPaths.add(beam.path);
          continue;
        }

        // 5. Gravity Wells (continuous force)
        for (var dev in allDevices) {
          if (!dev.isPlaced || dev.type != DeviceType.gravityWell) continue;

          final wellCenter = Offset(dev.gridX + 0.5, dev.gridY + 0.5);
          final diff = wellCenter - beam.pos;
          final distSq = diff.dx * diff.dx + diff.dy * diff.dy;
          final dist = sqrt(distSq);

          // Singularity gravitational active range and pull strength upgrades
          final wellLevel = deviceLevels[DeviceType.gravityWell] ?? 1;
          final range = 2.5 + 0.3 * wellLevel;
          final strength = 0.10 + 0.03 * wellLevel;

          if (dist > 0.1 && dist < range) {
            // Apply gravity pulling force: Force = G / (dist^2)
            final force = diff / (distSq * dist) * strength;
            
            // Accelerate direction vector
            beam.dir += force * stepSize;
            beam.dir = beam.dir / beam.dir.distance; // Keep velocity magnitude constant
          }
        }

        nextBeams.add(beam);
      }

      activeBeams.clear();
      activeBeams.addAll(nextBeams);
    }

    // Wrap up any remaining active beams
    for (var beam in activeBeams) {
      finalizedPaths.add(beam.path);
    }

    // Success condition: did we destroy all planets?
    final success = hitPlanetIds.length == level.planets.length;

    return LaserTraceResult(
      paths: finalizedPaths,
      hitPlanetIds: hitPlanetIds,
      explosions: explosions,
      audioTriggers: audioTriggers,
      success: success,
    );
  }
}
