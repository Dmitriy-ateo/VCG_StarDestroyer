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
  }
]
''';
