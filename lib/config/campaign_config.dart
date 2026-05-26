// Static JSON configuration for the Campaign Galaxies map and quest lines
// standard 8x12 grid system (gridX: 0-7, gridY: 0-11)

const String campaignJsonConfig = r'''
[
  {
    "id": "galaxy_1",
    "name": "Core Outpost",
    "description": "Establish initial Imperial coordinates. Realign core relays and calibrate targeting systems in the inner ring.",
    "requirementDescription": "Open to all recruits by default.",
    "minLaserIntensityLevel": 1,
    "minAimingComputerLevel": 1,
    "requiredUnlockedBlueprints": [],
    "prerequisiteGalaxyIds": [],
    "quests": [
      {
        "id": "q1",
        "title": "Core Calibration",
        "description": "Verify Death Star superlaser calibration on the rebel-held Alderaan planet.",
        "type": "lore",
        "storyLoreSnippet": "Admiral, we must execute a high-intensity fire test on the Alderaan base. Rotate the Death Star emitter and press FIRE to test the superlaser.",
        "creditsReward": 100,
        "rpReward": 20,
        "isCompleted": false,
        "levelData": {
          "id": 1,
          "name": "Core Calibration",
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
          "availableInventory": []
        }
      },
      {
        "id": "q2",
        "title": "Orbital Reflection",
        "description": "Bounce the laser beam around the asteroid blockade Chandrila orbit.",
        "type": "lore",
        "storyLoreSnippet": "Rebel blockade ships are hiding behind heavy asteroids in the Chandrila orbit. Place a Reflector to redirect the laser right to Chandrila.",
        "creditsReward": 150,
        "rpReward": 30,
        "isCompleted": false,
        "levelData": {
          "id": 2,
          "name": "Orbital Reflection",
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
          ]
        }
      },
      {
        "id": "q3",
        "title": "Split Outpost",
        "description": "Optional Side Mission. Split laser relays in Corellia opposite orbits.",
        "type": "side",
        "storyLoreSnippet": "Optional tactical mission. Two rebel planets sit in opposite orbits. Research and construct a 180° Splitter to destroy both targets simultaneously.",
        "creditsReward": 200,
        "rpReward": 40,
        "isCompleted": false,
        "levelData": {
          "id": 3,
          "name": "Split Sector",
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
          ]
        }
      }
    ]
  },
  {
    "id": "galaxy_2",
    "name": "Nebular Depths",
    "description": "Vast space clusters warped by intense gravity fields. Utilize high-mass slingshot orbits to navigate asteroid shielding.",
    "requirementDescription": "Requires R&D Laser Intensity Level 2+.",
    "minLaserIntensityLevel": 2,
    "minAimingComputerLevel": 1,
    "requiredUnlockedBlueprints": [],
    "prerequisiteGalaxyIds": ["galaxy_1"],
    "quests": [
      {
        "id": "q4",
        "title": "Chain Reaction",
        "description": "Trigger volatile bomb core detonations in the Calamari sector.",
        "type": "lore",
        "storyLoreSnippet": "The planets of Mon Calamari are protected by dense shielding. Our intelligence has located a volatile bomb core at (5, 3). Bypassing their shields by triggering the bomb!",
        "creditsReward": 250,
        "rpReward": 50,
        "isCompleted": false,
        "levelData": {
          "id": 4,
          "name": "Chain Reaction",
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
          ]
        }
      },
      {
        "id": "q5",
        "title": "Gravitational Slingshot",
        "description": "Bend superlaser rays around heavy blocking asteroids via gravity wells.",
        "type": "lore",
        "storyLoreSnippet": "The planet Mon Gazza is entirely blocked behind thick asteroid shielding. Use the newly unlocked Gravity Well device to curve the laser beam through their blind spot.",
        "creditsReward": 300,
        "rpReward": 60,
        "isCompleted": false,
        "levelData": {
          "id": 5,
          "name": "Gravitational Slingshot",
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
          ]
        }
      }
    ]
  },
  {
    "id": "galaxy_3",
    "name": "Outer Horizon",
    "description": "Distended outer space sectors connected through spatial portals.",
    "requirementDescription": "Requires Laser Intensity Level 3+, Aiming Computer Level 2+, and Researched Portals.",
    "minLaserIntensityLevel": 3,
    "minAimingComputerLevel": 2,
    "requiredUnlockedBlueprints": ["portal"],
    "prerequisiteGalaxyIds": ["galaxy_2"],
    "quests": [
      {
        "id": "q6",
        "title": "Portal Transit",
        "description": "Utilize Einstein-Rosen bridges to link distant targets.",
        "type": "lore",
        "storyLoreSnippet": "A rebel command center on Kessel is isolated behind complete shield walls. We must steer the laser into a reflector to bounce it up into Portal A, which will teleport it out of Portal B.",
        "creditsReward": 400,
        "rpReward": 80,
        "isCompleted": false,
        "levelData": {
          "id": 6,
          "name": "Portal Transit",
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
          ]
        }
      }
    ]
  }
]
''';
