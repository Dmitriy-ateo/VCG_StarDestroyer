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
        "title": "Calibrating the Ring",
        "description": "Rebel jamming arrays have locked down the rings of Kuat. Bypassing them requires a complex 3-reflector detour, or a high-intensity laser that melts their shielding.",
        "type": "lore",
        "storyLoreSnippet": "Admiral, the rebel blockades have established a high-frequency jamming station at Kuat. Direct fire is blocked by an orbital Energy Shield at (6, 5). Calibrate a 3-reflector detour around the asteroid field, or deploy a Level 2+ Laser to burn straight through their shields!",
        "creditsReward": 150,
        "rpReward": 30,
        "isCompleted": false,
        "levelData": {
          "id": 1,
          "name": "Calibrating the Ring",
          "description": "Detour or Pierce! The rebel comm station at (6, 2) is protected by a Power 2 Energy Shield at (6, 5). Firing UP from (6, 11), place Reflectors at (6, 9) at 45°, (2, 9) at 135°, and (2, 2) at 135° to reflect the beam around the shield. Late-game ships (Power 2+) can fire straight up to vaporize the shield instantly!",
          "deathStarX": 6,
          "deathStarY": 11,
          "deathStarInitialAngle": -90.0,
          "planets": [
            {
              "id": "p1",
              "gridX": 6,
              "gridY": 2,
              "radius": 20.0,
              "name": "Kuat Comm Station",
              "color": "0xFF00FFF5"
            }
          ],
          "walls": [
            { "gridX": 6, "gridY": 5, "isDestructible": false, "type": "energyShield", "requiredLaserPower": 2 },
            { "gridX": 3, "gridY": 8, "isDestructible": false, "type": "asteroid" },
            { "gridX": 4, "gridY": 8, "isDestructible": false, "type": "asteroid" },
            { "gridX": 5, "gridY": 8, "isDestructible": false, "type": "asteroid" }
          ],
          "availableInventory": [
            { "id": "t_ref1", "type": "reflector" },
            { "id": "t_ref2", "type": "reflector" },
            { "id": "t_ref3", "type": "reflector" }
          ]
        }
      },
      {
        "id": "q2",
        "title": "The Corellian Gauntlet",
        "description": "Weave the superlaser through a tight double-bend gauntlet. Upgraded tactical ships can melt the shielding to take efficient shortcuts.",
        "type": "lore",
        "storyLoreSnippet": "Sir, rebel stealth frigates are anchored inside the Corellian cargo slipways. Heavy blast shields block direct access. Route the superlaser using three mirrors, or deploy a Level 2+ Laser to disintegrate the terminal shield gate and strike them with a single reflection!",
        "creditsReward": 200,
        "rpReward": 40,
        "isCompleted": false,
        "levelData": {
          "id": 2,
          "name": "The Corellian Gauntlet",
          "description": "Thread the S-bend. Place three Reflectors: (5, 9) at 135° to reflect right, (6, 9) at 45° to reflect up, and (6, 2) at 45° to strike the Corellia Vanguard at (2, 2). Upgraded ships (Power 2+) can melt the shield at (5, 8) and use only one mirror at (5, 2) at 45° to reflect left!",
          "deathStarX": 5,
          "deathStarY": 11,
          "deathStarInitialAngle": -90.0,
          "planets": [
            {
              "id": "p1",
              "gridX": 2,
              "gridY": 2,
              "radius": 20.0,
              "name": "Corellia Vanguard",
              "color": "0xFFFFAB40"
            }
          ],
          "walls": [
            { "gridX": 5, "gridY": 8, "isDestructible": false, "type": "energyShield", "requiredLaserPower": 2 },
            { "gridX": 4, "gridY": 8, "isDestructible": false, "type": "asteroid" },
            { "gridX": 3, "gridY": 6, "isDestructible": false, "type": "asteroid" },
            { "gridX": 2, "gridY": 4, "isDestructible": false, "type": "asteroid" },
            { "gridX": 4, "gridY": 4, "isDestructible": false, "type": "asteroid" }
          ],
          "availableInventory": [
            { "id": "t_ref1", "type": "reflector" },
            { "id": "t_ref2", "type": "reflector" },
            { "id": "t_ref3", "type": "reflector" }
          ]
        }
      },
      {
        "id": "q3",
        "title": "The Kuat Triple-Split",
        "description": "Escaping rebel convoy fleets are scattered in three directions. Combine a 180° splitter and a 90° splitter to coordinate a triple strike.",
        "type": "side",
        "storyLoreSnippet": "Admiral, multiple rebel escorts are executing an emergency jump. Standard lasers can only track one target. Mount a 180° Splitter at (3, 8) and a 90° Splitter at (5, 8) to bifurcate and redirect the beam to hit all three escaping hulls simultaneously!",
        "creditsReward": 250,
        "rpReward": 50,
        "isCompleted": false,
        "levelData": {
          "id": 3,
          "name": "The Kuat Triple-Split",
          "description": "Multi-beam strike! Place a 180° Splitter at (3, 8) at 0° to split Left and Right. Place a Reflector at (1, 8) at 45° to reflect the left beam up to (1, 2). Place a 90° Splitter at (5, 8) at -90° to split Up and Right. Place a Reflector at (7, 8) at 135° to reflect the right beam up to (7, 2)!",
          "deathStarX": 3,
          "deathStarY": 11,
          "deathStarInitialAngle": -90.0,
          "planets": [
            {
              "id": "p1",
              "gridX": 1,
              "gridY": 2,
              "radius": 20.0,
              "name": "Kuat Escort Alpha",
              "color": "0xFF00FFF5"
            },
            {
              "id": "p2",
              "gridX": 5,
              "gridY": 2,
              "radius": 20.0,
              "name": "Kuat Escort Beta",
              "color": "0xFFFFE57F"
            },
            {
              "id": "p3",
              "gridX": 7,
              "gridY": 2,
              "radius": 20.0,
              "name": "Kuat Escort Gamma",
              "color": "0xFFFF5252"
            }
          ],
          "walls": [
            { "gridX": 3, "gridY": 5, "isDestructible": false, "type": "scrapMetal", "requiredLaserPower": 4 }
          ],
          "availableInventory": [
            { "id": "t_split1", "type": "splitter", "splitAngleDegrees": 180.0 },
            { "id": "t_split2", "type": "splitter", "splitAngleDegrees": 90.0 },
            { "id": "t_ref1", "type": "reflector" },
            { "id": "t_ref2", "type": "reflector" }
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
        "title": "The Nebula Core Detonation",
        "description": "A well-defended rebel armada is hidden behind crystalline clusters. Trigger a volatile bomb core to clear them in a single blast.",
        "type": "lore",
        "storyLoreSnippet": "The rebel base in the Mon Calamari dust nebula is fortified behind massive crystal matrices. Direct fire cannot pierce them. Starting ships must detour around the cloud. High-intensity ships (Laser Power 3+) can melt the crystal block at (1, 5) to forge a direct, rapid vector!",
        "creditsReward": 300,
        "rpReward": 60,
        "isCompleted": false,
        "levelData": {
          "id": 4,
          "name": "The Nebula Core Detonation",
          "description": "Ignite the Core! Drag the volatile bomb into (5, 3). Place Reflectors at (1, 8) at 135° and (5, 8) at 45° to reflect the beam around the shield and detonate the bomb. Late-game ships (Power 3+) can pierce the Crystal Wall at (1, 5) and reflect right from (1, 3) at 135°!",
          "deathStarX": 1,
          "deathStarY": 11,
          "deathStarInitialAngle": -90.0,
          "planets": [
            {
              "id": "p1",
              "gridX": 4,
              "gridY": 2,
              "radius": 20.0,
              "name": "Calamari Alpha",
              "color": "0xFF03A9F4"
            },
            {
              "id": "p2",
              "gridX": 6,
              "gridY": 2,
              "radius": 20.0,
              "name": "Calamari Beta",
              "color": "0xFFE040FB"
            }
          ],
          "walls": [
            { "gridX": 1, "gridY": 5, "isDestructible": false, "type": "crystal", "requiredLaserPower": 3 },
            { "gridX": 3, "gridY": 7, "isDestructible": false, "type": "asteroid" },
            { "gridX": 5, "gridY": 5, "isDestructible": false, "type": "asteroid" }
          ],
          "availableInventory": [
            { "id": "t_bomb1", "type": "bomb" },
            { "id": "t_ref1", "type": "reflector" },
            { "id": "t_ref2", "type": "reflector" },
            { "id": "t_ref3", "type": "reflector" }
          ],
          "presetDevices": []
        }
      },
      {
        "id": "q5",
        "title": "The Gravitational Sling",
        "description": "Utilize a gravity well to curve the superlaser around asteroid columns and bypass early defense grids.",
        "type": "lore",
        "storyLoreSnippet": "Admiral, the capital base on Mon Gazza has placed massive shielding columns on X=5. We must deploy a high-mass Gravity Well to curve our beam left around the blockade. Catch the curved trajectory with a mirror to strike their rear core!",
        "creditsReward": 350,
        "rpReward": 70,
        "isCompleted": false,
        "levelData": {
          "id": 5,
          "name": "The Gravitational Sling",
          "description": "Orbital detour. Place a Gravity Well at (2, 7) to pull the laser LEFT around the asteroid at (5, 5). Place a Reflector at (1, 4) at 135° to reflect the curved laser right onto the Mon Gazza core at (6, 4)!",
          "deathStarX": 5,
          "deathStarY": 11,
          "deathStarInitialAngle": -90.0,
          "planets": [
            {
              "id": "p1",
              "gridX": 6,
              "gridY": 4,
              "radius": 20.0,
              "name": "Mon Gazza Core",
              "color": "0xFF69F0AE"
            }
          ],
          "walls": [
            { "gridX": 5, "gridY": 5, "isDestructible": false, "type": "asteroid" },
            { "gridX": 1, "gridY": 3, "isDestructible": false, "type": "energyShield", "requiredLaserPower": 2 }
          ],
          "availableInventory": [
            { "id": "t_well1", "type": "gravityWell" },
            { "id": "t_ref1", "type": "reflector" }
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
        "title": "The Quantum Paradox",
        "description": "Harness the power of spatial portals, splitting matrices, and reflective vectors to vaporize both Kessel outposts simultaneously.",
        "type": "lore",
        "storyLoreSnippet": "The final rebel fortress in Kessel is split across folded dimensions. Route the beam up, reflect it right at (3, 9) into Portal A at (6, 9). It exits Portal B at (1, 5) going right. Place a 180° Splitter at (3, 5) to split the beam left and right, and place mirrors at (2, 5) and (5, 5) to redirect both up!",
        "creditsReward": 500,
        "rpReward": 100,
        "isCompleted": false,
        "levelData": {
          "id": 6,
          "name": "The Quantum Paradox",
          "description": "Spatial division. Firing UP from (3, 11), place a Reflector at (3, 9) at 135° to reflect right into Portal A at (6, 9). The laser exits Portal B at (1, 5) going right. Place a 180° Splitter at (3, 5) at 0° to split Left and Right. Place a Reflector at (2, 5) at 45° to reflect UP to (2, 2) and another Reflector at (5, 5) at 135° to reflect UP to (5, 2)!",
          "deathStarX": 3,
          "deathStarY": 11,
          "deathStarInitialAngle": -90.0,
          "planets": [
            {
              "id": "p1",
              "gridX": 2,
              "gridY": 2,
              "radius": 20.0,
              "name": "Kessel Prime",
              "color": "0xFFFFD54F"
            },
            {
              "id": "p2",
              "gridX": 5,
              "gridY": 2,
              "radius": 20.0,
              "name": "Kessel Secundus",
              "color": "0xFFFFE57F"
            }
          ],
          "walls": [
            { "gridX": 1, "gridY": 4, "isDestructible": false, "type": "crystal", "requiredLaserPower": 3 },
            { "gridX": 6, "gridY": 4, "type": "crystal", "requiredLaserPower": 3 }
          ],
          "availableInventory": [
            { "id": "t_split1", "type": "splitter", "splitAngleDegrees": 180.0 },
            { "id": "t_ref1", "type": "reflector" },
            { "id": "t_ref2", "type": "reflector" },
            { "id": "t_ref3", "type": "reflector" }
          ],
          "presetDevices": [
            { "id": "p_port1", "type": "portal", "gridX": 6, "gridY": 9, "portalPairId": "p_port2", "isPlaced": true },
            { "id": "p_port2", "type": "portal", "gridX": 1, "gridY": 5, "portalPairId": "p_port1", "isPlaced": true }
          ]
        }
      }
    ]
  }
]
''';
