// Level campaign configuration database
// standard 8x12 grid system (gridX: 0-7, gridY: 0-11)

const String levelsJsonConfig = r'''
[
  {
    "id": 1,
    "name": "Level 1: Core Calibration",
    "description": "Aim directly at the rebel base planet Alderaan at the top and press FIRE to test the superlaser. Drag gesture on screen or use bottom dial adjustment to aim.",
    "deathStarX": 3,
    "deathStarY": 11,
    "deathStarInitialAngle": -90.0,
    "planets": [
      {
        "id": "p1",
        "gridX": 3,
        "gridY": 2,
        "radius": 20.0,
        "name": "Alderaan",
        "color": "0xFF448AFF"
      }
    ],
    "walls": [],
    "availableInventory": [],
    "presetDevices": [],
    "creditsReward": 100,
    "researchPointsReward": 20
  },
  {
    "id": 2,
    "name": "Level 2: Orbital Reflection",
    "description": "Impending asteroids block direct sight. Drag a REFLECTOR onto grid slot (3, 2) and tap once to rotate it 135° to reflect the laser right to Chandrila.",
    "deathStarX": 3,
    "deathStarY": 11,
    "deathStarInitialAngle": -90.0,
    "planets": [
      {
        "id": "p1",
        "gridX": 6,
        "gridY": 2,
        "radius": 20.0,
        "name": "Chandrila",
        "color": "0xFF64FFDA"
      }
    ],
    "walls": [
      { "gridX": 3, "gridY": 6, "isDestructible": false },
      { "gridX": 4, "gridY": 6, "isDestructible": false },
      { "gridX": 5, "gridY": 6, "isDestructible": false }
    ],
    "availableInventory": [
      { "id": "t_ref1", "type": "reflector" }
    ],
    "presetDevices": [],
    "creditsReward": 150,
    "researchPointsReward": 30
  },
  {
    "id": 3,
    "name": "Level 3: Split Sector",
    "description": "Two rebel planets sit in opposite orbits. Place the SPLITTER 180° blueprint on slot (3, 3) at rotation 0° to split the laser left and right.",
    "deathStarX": 3,
    "deathStarY": 11,
    "deathStarInitialAngle": -90.0,
    "planets": [
      {
        "id": "p1",
        "gridX": 1,
        "gridY": 3,
        "radius": 20.0,
        "name": "Corellia Prime",
        "color": "0xFFFFAB40"
      },
      {
        "id": "p2",
        "gridX": 6,
        "gridY": 3,
        "radius": 20.0,
        "name": "Corellia Secundus",
        "color": "0xFFFF5252"
      }
    ],
    "walls": [
      { "gridX": 3, "gridY": 2, "isDestructible": false }
    ],
    "availableInventory": [
      { "id": "t_split1", "type": "splitter", "splitAngleDegrees": 180.0 }
    ],
    "presetDevices": [],
    "creditsReward": 200,
    "researchPointsReward": 40
  },
  {
    "id": 4,
    "name": "Level 4: Chain Reaction",
    "description": "Planets are shielded, but a volatile bomb core rests at (5, 3). Place a reflector at (2, 3) at rotation 135° to reflect the laser into the bomb for an explosion!",
    "deathStarX": 2,
    "deathStarY": 11,
    "deathStarInitialAngle": -90.0,
    "planets": [
      {
        "id": "p1",
        "gridX": 4,
        "gridY": 2,
        "radius": 20.0,
        "name": "Mon Calamari Alpha",
        "color": "0xFF03A9F4"
      },
      {
        "id": "p2",
        "gridX": 6,
        "gridY": 2,
        "radius": 20.0,
        "name": "Mon Calamari Beta",
        "color": "0xFFE040FB"
      },
      {
        "id": "p3",
        "gridX": 5,
        "gridY": 1,
        "radius": 20.0,
        "name": "Mon Calamari Gamma",
        "color": "0xFF536DFE"
      }
    ],
    "walls": [
      { "gridX": 2, "gridY": 1, "isDestructible": false },
      { "gridX": 5, "gridY": 4, "isDestructible": false }
    ],
    "availableInventory": [
      { "id": "t_ref1", "type": "reflector" },
      { "id": "t_bomb1", "type": "bomb" }
    ],
    "presetDevices": [],
    "creditsReward": 250,
    "researchPointsReward": 50
  },
  {
    "id": 5,
    "name": "Level 5: Gravitational Slingshot",
    "description": "Mon Gazza is blocked by asteroids. Drag a GRAVITY WELL near slot (4, 7) to generate a pull that curves the upward laser around the asteroid wall.",
    "deathStarX": 2,
    "deathStarY": 11,
    "deathStarInitialAngle": -90.0,
    "planets": [
      {
        "id": "p1",
        "gridX": 5,
        "gridY": 2,
        "radius": 20.0,
        "name": "Mon Gazza",
        "color": "0xFF69F0AE"
      }
    ],
    "walls": [
      { "gridX": 2, "gridY": 5, "isDestructible": false },
      { "gridX": 3, "gridY": 5, "isDestructible": false },
      { "gridX": 4, "gridY": 5, "isDestructible": false }
    ],
    "availableInventory": [
      { "id": "t_well1", "type": "gravityWell" }
    ],
    "presetDevices": [],
    "creditsReward": 300,
    "researchPointsReward": 60
  },
  {
    "id": 6,
    "name": "Level 6: Portal Transit",
    "description": "Einstein-Rosen portal transits link the system. Steer the laser left into a reflector to bounce it up into Portal A at (1, 7), which teleports out of Portal B at (6, 4) to destroy Kessel.",
    "deathStarX": 3,
    "deathStarY": 11,
    "deathStarInitialAngle": -90.0,
    "planets": [
      {
        "id": "p1",
        "gridX": 6,
        "gridY": 1,
        "radius": 20.0,
        "name": "Kessel",
        "color": "0xFFFFE57F"
      }
    ],
    "walls": [
      { "gridX": 3, "gridY": 3, "isDestructible": false },
      { "gridX": 3, "gridY": 4, "isDestructible": false },
      { "gridX": 3, "gridY": 5, "isDestructible": false },
      { "gridX": 4, "gridY": 3, "isDestructible": false },
      { "gridX": 4, "gridY": 4, "isDestructible": false },
      { "gridX": 4, "gridY": 5, "isDestructible": false }
    ],
    "availableInventory": [
      { "id": "t_ref1", "type": "reflector" }
    ],
    "presetDevices": [
      { "id": "port1", "type": "portal", "gridX": 1, "gridY": 7, "portalPairId": "port2", "isPlaced": true },
      { "id": "port2", "type": "portal", "gridX": 6, "gridY": 4, "portalPairId": "port1", "isPlaced": true }
    ],
    "creditsReward": 400,
    "researchPointsReward": 80
  },
  {
    "id": 7,
    "name": "Level 7: Double Portal Reflection",
    "description": "Portals fold the sector space. Reflect the laser at (3, 9) into Portal A at (2, 9) at 135°, which exits Portal B at (6, 5) going up to vaporize the fleet at (6, 1).",
    "deathStarX": 3,
    "deathStarY": 11,
    "deathStarInitialAngle": -90.0,
    "planets": [
      {
        "id": "p1",
        "gridX": 6,
        "gridY": 1,
        "radius": 20.0,
        "name": "Kamino Outpost",
        "color": "0xFF00FF87"
      }
    ],
    "walls": [
      { "gridX": 6, "gridY": 7, "isDestructible": false },
      { "gridX": 3, "gridY": 5, "isDestructible": false }
    ],
    "availableInventory": [
      { "id": "t_ref1", "type": "reflector" }
    ],
    "presetDevices": [
      { "id": "port1", "type": "portal", "gridX": 2, "gridY": 9, "portalPairId": "port2", "isPlaced": true },
      { "id": "port2", "type": "portal", "gridX": 6, "gridY": 5, "portalPairId": "port1", "isPlaced": true }
    ],
    "creditsReward": 450,
    "researchPointsReward": 90
  },
  {
    "id": 8,
    "name": "Level 8: Prismatic Gravity Sling",
    "description": "Combine the gravity well at (2, 7) and a reflector to guide the laser horizontally across a splitter at (6, 4) to hit dual targets.",
    "deathStarX": 5,
    "deathStarY": 11,
    "deathStarInitialAngle": -90.0,
    "planets": [
      {
        "id": "p1",
        "gridX": 6,
        "gridY": 1,
        "radius": 20.0,
        "name": "Geonosis Alpha",
        "color": "0xFFFF5252"
      },
      {
        "id": "p2",
        "gridX": 6,
        "gridY": 7,
        "radius": 20.0,
        "name": "Geonosis Beta",
        "color": "0xFFFFAB40"
      }
    ],
    "walls": [
      { "gridX": 5, "gridY": 5, "isDestructible": false }
    ],
    "availableInventory": [
      { "id": "t_well1", "type": "gravityWell" },
      { "id": "t_split1", "type": "splitter", "splitAngleDegrees": 180.0 }
    ],
    "presetDevices": [],
    "creditsReward": 500,
    "researchPointsReward": 100
  },
  {
    "id": 9,
    "name": "Level 9: Proximity Detonation Field",
    "description": "Rebel fleets are shielded behind planetary barriers at (6, 2). Place a Reflector at (3, 5) at 45° to reflect the laser right, and drop a bomb at (6, 5) to blow them up in a single flash!",
    "deathStarX": 3,
    "deathStarY": 11,
    "deathStarInitialAngle": -90.0,
    "planets": [
      {
        "id": "p1",
        "gridX": 6,
        "gridY": 2,
        "radius": 20.0,
        "name": "Naboo Base",
        "color": "0xFFE040FB"
      }
    ],
    "walls": [
      { "gridX": 6, "gridY": 3, "isDestructible": false }
    ],
    "availableInventory": [
      { "id": "t_ref1", "type": "reflector" },
      { "id": "t_bomb1", "type": "bomb" }
    ],
    "presetDevices": [],
    "creditsReward": 550,
    "researchPointsReward": 110
  },
  {
    "id": 10,
    "name": "Level 10: Multi-dimensional Matrix",
    "description": "Use preset portals and a splitter variant to bifurcate the laser and strike two planets simultaneously across spatial folds.",
    "deathStarX": 3,
    "deathStarY": 11,
    "deathStarInitialAngle": -90.0,
    "planets": [
      {
        "id": "p1",
        "gridX": 2,
        "gridY": 2,
        "radius": 20.0,
        "name": "Hoth Station Alpha",
        "color": "0xFF00FFF5"
      },
      {
        "id": "p2",
        "gridX": 5,
        "gridY": 2,
        "radius": 20.0,
        "name": "Hoth Station Beta",
        "color": "0xFF64FFDA"
      }
    ],
    "walls": [],
    "availableInventory": [
      { "id": "t_split1", "type": "splitter", "splitAngleDegrees": 90.0 },
      { "id": "t_ref1", "type": "reflector" }
    ],
    "presetDevices": [
      { "id": "port1", "type": "portal", "gridX": 6, "gridY": 9, "portalPairId": "port2", "isPlaced": true },
      { "id": "port2", "type": "portal", "gridX": 1, "gridY": 5, "portalPairId": "port1", "isPlaced": true }
    ],
    "creditsReward": 600,
    "researchPointsReward": 120
  },
  {
    "id": 11,
    "name": "Level 11: The Accretion Trap",
    "description": "A dense volcanic asteroid field blocks Kessel. Orbit a Gravity Well around slot (3, 5) to loop the laser path horizontally to destroy the rebel command center.",
    "deathStarX": 1,
    "deathStarY": 11,
    "deathStarInitialAngle": -90.0,
    "planets": [
      {
        "id": "p1",
        "gridX": 6,
        "gridY": 3,
        "radius": 20.0,
        "name": "Kessel Core",
        "color": "0xFFFF2E93"
      }
    ],
    "walls": [
      { "gridX": 3, "gridY": 4, "isDestructible": false },
      { "gridX": 4, "gridY": 4, "isDestructible": false }
    ],
    "availableInventory": [
      { "id": "t_well1", "type": "gravityWell" },
      { "id": "t_ref1", "type": "reflector" }
    ],
    "presetDevices": [],
    "creditsReward": 650,
    "researchPointsReward": 130
  },
  {
    "id": 12,
    "name": "Level 12: Triple Mirror Link",
    "description": "Navigate a complex triple-bend course. Place Reflectors at (3, 8), (6, 8), and (6, 3) to route the laser around the volcanic shield rows.",
    "deathStarX": 3,
    "deathStarY": 11,
    "deathStarInitialAngle": -90.0,
    "planets": [
      {
        "id": "p1",
        "gridX": 1,
        "gridY": 3,
        "radius": 20.0,
        "name": "Endor Vanguard",
        "color": "0xFF69F0AE"
      }
    ],
    "walls": [
      { "gridX": 3, "gridY": 5, "isDestructible": false },
      { "gridX": 5, "gridY": 5, "isDestructible": false }
    ],
    "availableInventory": [
      { "id": "t_ref1", "type": "reflector" },
      { "id": "t_ref2", "type": "reflector" },
      { "id": "t_ref3", "type": "reflector" }
    ],
    "presetDevices": [],
    "creditsReward": 700,
    "researchPointsReward": 140
  },
  {
    "id": 13,
    "name": "Level 13: Anti-matter Split Core",
    "description": "Trigger explosive blast radius reactions to destroy shielded planet coordinates. Place a Splitter 180° at (3, 6) to explode bombs at (1, 6) and (5, 6).",
    "deathStarX": 3,
    "deathStarY": 11,
    "deathStarInitialAngle": -90.0,
    "planets": [
      {
        "id": "p1",
        "gridX": 1,
        "gridY": 4,
        "radius": 20.0,
        "name": "Bespin Gas Core",
        "color": "0xFF03A9F4"
      },
      {
        "id": "p2",
        "gridX": 5,
        "gridY": 4,
        "radius": 20.0,
        "name": "Bespin Outpost",
        "color": "0xFFFFE57F"
      }
    ],
    "walls": [
      { "gridX": 3, "gridY": 3, "isDestructible": false }
    ],
    "availableInventory": [
      { "id": "t_split1", "type": "splitter", "splitAngleDegrees": 180.0 },
      { "id": "t_bomb1", "type": "bomb" },
      { "id": "t_bomb2", "type": "bomb" }
    ],
    "presetDevices": [],
    "creditsReward": 750,
    "researchPointsReward": 150
  },
  {
    "id": 14,
    "name": "Level 14: Warp Cascade",
    "description": "Steer the laser into a chain reaction of dimension folds. Realign the coordinates at (3, 8) into the primary warp core.",
    "deathStarX": 3,
    "deathStarY": 11,
    "deathStarInitialAngle": -90.0,
    "planets": [
      {
        "id": "p1",
        "gridX": 6,
        "gridY": 2,
        "radius": 20.0,
        "name": "Yavin Base",
        "color": "0xFFFFB703"
      }
    ],
    "walls": [],
    "availableInventory": [
      { "id": "t_ref1", "type": "reflector" }
    ],
    "presetDevices": [
      { "id": "port1", "type": "portal", "gridX": 4, "gridY": 8, "portalPairId": "port2", "isPlaced": true },
      { "id": "port2", "type": "portal", "gridX": 1, "gridY": 4, "portalPairId": "port3", "isPlaced": true },
      { "id": "port3", "type": "portal", "gridX": 6, "gridY": 4, "portalPairId": "port1", "isPlaced": true }
    ],
    "creditsReward": 800,
    "researchPointsReward": 160
  },
  {
    "id": 15,
    "name": "Level 15: Singularity Gate",
    "description": "Curve the laser using a gravity well at (2, 8) into Portal A at (1, 5) to emerge from Portal B at (6, 2) and strike the final rebel capital.",
    "deathStarX": 2,
    "deathStarY": 11,
    "deathStarInitialAngle": -90.0,
    "planets": [
      {
        "id": "p1",
        "gridX": 6,
        "gridY": 1,
        "radius": 20.0,
        "name": "Coruscant Rebel Core",
        "color": "0xFF00FFF5"
      }
    ],
    "walls": [
      { "gridX": 2, "gridY": 3, "isDestructible": false }
    ],
    "availableInventory": [
      { "id": "t_well1", "type": "gravityWell" }
    ],
    "presetDevices": [
      { "id": "port1", "type": "portal", "gridX": 1, "gridY": 5, "portalPairId": "port2", "isPlaced": true },
      { "id": "port2", "type": "portal", "gridX": 6, "gridY": 2, "portalPairId": "port1", "isPlaced": true }
    ],
    "creditsReward": 1000,
    "researchPointsReward": 200
  }
]
''';
