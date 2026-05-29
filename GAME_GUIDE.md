# Star Destroyer: Single Shot — Game Design & Solvability Guide

This guide establishes the rules of engagement, game mechanics, component parameters, and design guidelines for **Star Destroyer: Single Shot**. 

> [!IMPORTANT]
> **MANDATORY RULES FOR DEVELOPERS & DESIGNERS**:
> 1. **Solvability Check**: When adding a new Sector (Level) to the database, you **MUST** ensure and verify that the level is mathematically and logically solvable using the provided inventory blueprints and constraints. Obstructing a required placement coordinate with a static wall or planet is strictly prohibited.
> 2. **Documentation Synchronization (The Rule for New Game Changes)**: When introducing or modifying any new game mechanic, item, galaxy, chassis upgrade, or interface hotspot, you **MUST** immediately update this Guide (`GAME_GUIDE.md`) to document the rules, mechanics, physics, and design specifications of the new item/change. Keeping this guide perfectly synchronized with codebase changes is a strict requirement.

---

## 1. Core Objective

The objective of each sector is to **destroy all target planets** in a single consolidated firing sequence. 
*   **Shielded Planets**: Many planets are heavily shielded and cannot be destroyed by direct laser contact.
*   **Volatile Bombs**: Volatile bomb cores are highly reactive. Hitting a bomb core with the superlaser triggers a massive chain reaction shockwave with an explosion radius of **2.2 cells**, vaporizing all planets and structures within that area.

---

## 2. Sector Dimensions & Coordinates System

Sectors are built on a native vertical portrait coordinates grid:
*   **Dimensions**: 8 columns wide ($X \in [0, 7]$) by 12 rows high ($Y \in [0, 11]$).
*   **Coordinates**: Grid origins start at the top-left $(0, 0)$.
*   **Death Star Placement**: Centered at the bottom row ($Y=11$, usually $X=3$ or $X=2$).
*   **Firing Arc Constraints**: Firing trajectory is strictly bounded to the upward semicircle ($[-180.0^\circ, 0.0^\circ]$). Firing angles outside this arc (e.g. downward) are automatically clamped.

---

## 3. Inventory Blueprint Components

Players are equipped with high-tech tactical modules to steer and manipulate the laser:

### 3.1 Reflector (Glass Mirror)
*   **Function**: Intercepts the laser beam and reflects it based on standard vector reflection geometry ($R = I - 2(I \cdot N)N$).
*   **Rotation**: Rotates in $45^\circ$ increments.
*   **Design Use**: Bends the straight-up laser around asteroid walls.

### 3.2 Splitter (Prism Crystals)
*   **Function**: Splits a single incoming laser beam into two distinct beams.
*   **Outputs**: 
    1.  *Vector 1* continues along the splitter's primary rotation angle.
    2.  *Vector 2* emerges at a variant separation offset angle ($45^\circ$, $90^\circ$, $135^\circ$, or $180^\circ$).
*   **Design Use**: Essential for sectors containing multiple planets in separated orbits.

### 3.3 Gravity Well (Swirling Core)
*   **Function**: Exerts a continuous pulling force on the laser beam, curving its trajectory.
*   **Pull Radius**: Pulls within a range of $3.5$ cells. 
*   **Design Use**: Used to create curved gravity slingshots to reach targets hidden behind asteroid screens.

### 3.4 Portals (Einstein-Rosen Pairs)
*   **Function**: Instantly teleports a laser beam entering Portal A out of Portal B, maintaining the beam's original travel angle.
*   **Design Use**: Used to traverse large asteroid obstacles or cross extreme distances instantly.

### 3.5 Floating Deflection Asteroids (Volcanic Space Rocks)
*   **Function**: A beatable, single-use preset block that intercepts the laser and deflects its direction relative to the asteroid's angle of rotation ($R = I + \theta_{\text{asteroid}}$).
*   **Not Purchasable**: This block is a pre-placed, level-specific obstacle and is not a purchasable or researchable inventory device.
*   **Shatter Physics**: On laser impact, the asteroid detonates immediately (registering an organic dust debris cloud explosion) and is deactivated, preventing infinite laser loops.
*   **Design Use**: Vital in outer-rim high-density fields to steer the laser around static obsidian barriers and redirect it onto hidden planets.

---

## 4. Mandatory Level Design Solvability Protocol

To prevent unsolvable states (such as the Level 4 coordinate conflict where a wall blocked the only valid reflection cell), every level creator **must** adhere to this checklist before committing a sector to `lib/models/level_data.dart`:

### 4.1 Slot Emptiness Verification
Ensure that the exact coordinates $(x, y)$ planned for critical player reflector/splitter placements are **completely empty**:
*   No static asteroid `WallBlock` can occupy the coordinates.
*   No preset `PlanetTarget` or locked `presetDevices` can occupy the coordinates.
*   The path of the laser leading *to* the required reflection/split point must not be blocked by preloaded walls.

### 4.2 Mathematical Solution Verification
Calculate the laser path mathematically to ensure a clear solution path exists:
$$\text{Trajectory Path} \cap \text{Target Cells} \neq \emptyset$$
*   If a bomb core is used, check that all target planets fall within the Euclidean distance of $2.2$ cells from the bomb's center $(x_b + 0.5, y_b + 0.5)$:
$$\sqrt{(x_p - x_b)^2 + (y_p - y_b)^2} < 2.2$$

### 4.3 Simulation Testing
*   Deploy the sector locally and run the solution sequence in the simulator to verify that the victory screen triggers and all listeners notify successfully.

---

## 5. Campaign Progression & Balanced Game Difficulty Scale

To provide a highly satisfying, engaging, and balanced progression loop, the game's campaign sectors, training levels, and chassis/device capabilities are divided into three distinct difficulty tiers. This ensures that the learning curve increases smoothly from simple tutorials up to complex spatial puzzle networks.

### 5.1 Difficulty Tier Classification & Balance

```mermaid
graph TD
    T1[Tier 1: Apprentice <br/> Galaxy 1: Core Outpost <br/> Easy Puzzles]
    T2[Tier 2: Commander <br/> Galaxy 2: Nebular Depths <br/> Medium Puzzles]
    T3[Tier 3: Grand Admiral <br/> Galaxy 3: Outer Horizon <br/> Hard Puzzles]

    T1 -->|Requires Laser Rank F ★| T2
    T2 -->|Requires Laser Rank F ★★ & Aiming F ★| T3
```

#### Tier 1: Apprentice Sectors (Galaxy 1 — Core Outpost)
*   **Difficulty Rating**: Easy (Sectors 1-3)
*   **Core Concepts**: Basic vector reflection and straight-line S-bend pathing.
*   **Obstacles**: Volcanic Obsidian Asteroids (indestructible blocks that partition coordinate bounds).
*   **Requirements**: 
    - None (Open to all recruits by default).
    - Sub-systems start at **Rank F** (Level 1).
*   **Available Inventory**: Standard Deflector Reflectors only.
*   **Economy Yields**: Medium Credits (C) for initial upgrades. No dynamic Research Points (RP).

#### Tier 2: Commander Sectors (Galaxy 2 — Nebular Depths)
*   **Difficulty Rating**: Medium / Intermediate (Sectors 4-5, Training Programs 1-6)
*   **Core Concepts**: Multi-target beam bifurcation, volatile chain explosions, and laser intensity attenuation management.
*   **Obstacles**: Penetrable obstacles spawning dynamically from the second galaxy onwards:
    - **Energy Shields**: Cyan barriers requiring Laser Power $\ge 2$. Transits into a semi-transparent deactivated pulse state on penetration.
    - **Crystals**: Pink barriers requiring Laser Power $\ge 3$.
    - **Scrap Metal**: Orange barriers requiring Laser Power $\ge 2$.
    - **Space Debris**: Free-floating low-poly borderless clutters that occlude coordinate cells.
*   **Unlock Requirements**:
    - Clearance of Galaxy 1.
    - **Laser Intensity Rank F ★+** (Star Rating $\ge 1$, Cumulative Score $\ge 1$).
*   **Available Inventory**: Reflectors, Splitters, and Deployable Volatile Bombs.
*   **Level-Dependent Balance Mechanics**:
    - *Prism Splitters*: Unstable Level 1 splitters drain exactly 1 laser power from both split output beams. Upgrading to Level 2+ stabilizes the prisms, enabling 100% efficient, lossless splitting.
    - *Volatile Bombs*: A Level $L$ bomb can only destroy planets with a defense shield rating $\le L$. Highly shielded planets survive nearby low-level blasts, urging players to prioritize bomb level upgrades.

#### Tier 3: Grand Admiral Sectors (Galaxy 3 — Outer Horizon & Advanced Training)
*   **Difficulty Rating**: Hard / Master (Sectors 6-18)
*   **Core Concepts**: Multi-dimensional Einstein-Rosen wormhole transits, curved gravitational slingshot orbits, and complex bifurcated layouts.
*   **Obstacles**: Shielded Planets (Level 2+ target planets requiring high laser intensity/bombs) and elaborate obsidian labyrin labyrinths.
*   **Unlock Requirements**:
    - Clearance of Galaxy 2.
    - **Laser Intensity Rank F ★★+** (Star Rating $\ge 2$).
    - **Aiming Computer Rank F ★+** (Star Rating $\ge 1$).
    - Researched Portal Blueprints.
*   **Available Inventory**: Full tactical inventory (Portals, Gravity Wells, Splitters, Bombs, Reflectors).
*   **Level-Dependent Balance Mechanics**:
    - *Einstein-Rosen Portals*: Unstable Level 1 portals drain 1 laser power during wormhole transit. Upgrading to Level 2+ stabilizes the warp gate for lossless transit.
    - *Gravity Wells*: Upgrading increases gravitational active attraction radius ($Radius = 2.5 + 0.3 \times Level$) and pull strength ($0.10 + 0.03 \times Level$), enabling sharp vector curves.

#### Tier 4: Fleet Admiral Sectors (Galaxy 7 — Asteroid Frontier)
*   **Difficulty Rating**: Master / S-Rank (Sectors 19-20)
*   **Core Concepts**: Organic vector deflection, single-use refractive pathing, and multi-beam splitter coordination in extreme dense debris fields.
*   **Obstacles**: Armored targets, static asteroid walls, and organic volcanic drift blockades.
*   **Unlock Requirements**:
    - Clearance of Galaxy 6.
    - **Laser Intensity Rank F ★★+** (Star Rating $\ge 2$).
*   **Available Inventory**: Floating Deflection Asteroids, Prism Splitters, Reflectors.

#### 5.1.1 Daily Hard Softlock Protection Rule
When the global **Daily Hard** threat modifier is active, standard sectors in advanced galaxies undergo structural threat hardening, adding defensive shields to targets and placing extra obsidian obstructions.
*   **The Risk**: New recruits begin their career with exactly $0$ Credits, $0$ RP, and standard Level 1 lasers. If their introductory levels were subject to Daily Hard boosts, they would face shielded planets requiring Level 2+ lasers. Because they cannot destroy any planets, they would be unable to earn credits to buy upgrades, resulting in an immediate soft-lock.
*   **The Rule**: **Galaxy 1 (Core Outpost) campaign levels are strictly immune to all Daily Hard difficulty boosts and shield adjustments.** Under no circumstances can a modifier increase target shields or block paths in Galaxy 1. This guarantees that starting levels remain 100% solvable with base equipment, allowing new players to safely complete them and earn their initial credits.

#### 5.1.2 Procedural Generation Direct-Hit Restriction (Galaxy 2+)
To preserve challenge, spatial complexity, and target puzzle depth across procedurally generated maps:
*   **The Goal**: Procedural layouts must force strategic usage of reflective and curved slingshot dynamics (mirrors, splitters, gravity wells, portal relays, and explosive cores) and eliminate trivial diagonal cheats.
*   **The Constraint**: Starting from **Galaxy 2 (Nebular Depths)** and above, **no generated daily sector or daily hard sector is allowed to have an unblocked, straight line-of-sight path from the Death Star to any planet.** 
*   **The Mechanism**: The generator automatically traces a ray from the Death Star center `(deathStarX + 0.5, deathStarY + 0.5)` to each planet center `(planet.gridX + 0.5, planet.gridY + 0.5)`. If the path is unblocked, it places an indestructible volcanic asteroid along the vector, safe-guarding the integrity of the puzzle without interfering with the intended curved or multi-bent solution.

#### 5.1.3 Procedural Side Quests Orbital Distribution
To represent an expansive galactic starmap:
*   **Orbit Capacity**: Orbit 2 (middle track) hosts exactly **7 active side quests** represented by Assignment beacons.
*   **Collision Prevention**: Minimum angular separation is reduced from `0.7` to `0.5` radians, ensuring all 7 planets are distributed evenly along the elliptical orbit without overlapping.
*   **Galaxy-Scaled Rewards**: Rewards scale with galaxy numbers to incentivize deep-space progression:
    - **Credits**: $150 + \text{GalaxyNum} \times 50 + \text{Random}(100)$
    - **Research Points**: $15 + \text{GalaxyNum} \times 5 + \text{Random}(15)$

#### 5.1.4 Procedural Difficulty Generator (Galaxy-Based Scaling)
Daily and procedural side quests dynamically scale their complexity based on the active galaxy number:
*   **Target Shields**: Target planet defense shields (`requiredLaserPower`) scale linearly: $\text{Shield Power} = \text{GalaxyNum}$ (Galaxy 4 requires Level 4 lasers, Galaxy 6 requires Level 6 lasers), encouraging players to upgrade sub-systems.
*   **Obstruction Clutter**: Indestructible asteroid clutter density scale: $2 + \text{GalaxyNum}$ walls.
*   **Barrier Hardening**: Energy shield barriers increase in shield power: $\max(2, \text{GalaxyNum} - 1)$; scrap metal: $\max(1, \text{GalaxyNum} - 2)$.
*   **Puzzle Complexity**: Advanced items like splitters, portals, and gravity wells are dynamically injected in player inventory (Galaxy 4+) requiring multi-step spatial pathing.

---

### 5.2 R&D Sub-Systems Chassis Upgrades (Credits)

Sub-systems (Laser Intensity, Tactical Aiming Computer, Deflector Sub-Chassis Capacity) are upgraded in the R&D Shop using **Credits (C)**. 

*   **Progression Path**: Upgrades climb through ranks `F -> E -> D -> C -> B -> A -> S -> SS -> SSS`. Each rank features 3 Star tiers (`0` to `3` stars), with 5 sub-levels per star. Completing Level 5 wraps to the next star tier, and completing 3-Stars wraps to the next rank (Level 1, 0-Stars).
*   **Geometric Cost Curve**: To act as a significant late-game currency sink while keeping initial upgrades highly accessible, cost scales geometrically:
    $$Cost = 80 \times 1.08^{\text{cumulativeLevel}}$$
*   **Linear Cap**: To maintain game viability at ultimate tiers, the geometric cost levels off linearly above 1500 Credits:
    $$Cost = 1500 + (\text{cumulativeLevel} - 35) \times 15 \quad (\text{when } Cost > 1500)$$

---

### 5.3 Tech Devices R&D Upgrades (Research Points)

Placed tactical modules are upgraded in the R&D Shop using **Research Points (RP)** earned by clearing campaign sectors and training programs.

*   **Progression Path**: Follows the same F-to-SSS rank and star wrapping sequence.
*   **Geometric Cost Curve**:
    $$Cost = 30 \times 1.10^{\text{cumulativeLevel}}$$
*   **Linear Cap**: Levels off linearly above 1200 RP to prevent astronomical cost overflows:
    $$Cost = 1200 + (\text{cumulativeLevel} - 38) \times 20 \quad (\text{when } Cost > 1200)$$

---

### 5.4 Cross-Session Persistence (Local Core Storage)

To protect your strategic career and progression:
*   **Automatic Saves**: All campaign progression stats, unlocked device blueprints, purchased store modules, chassis/device ranks, and completed quest states are saved persistently to the local device.
*   **Daily Hard Persistence**: Active daily threat levels and completed rollover dates are retained across restarts.
*   **App Reopening**: Returning players instantly resume their exact position in the galaxy campaign, retaining every single credit and armory upgrade purchased.

---

## 6. Command Bridge Tactical Interface

The Command Bridge acts as the central strategic hub of the Star Destroyer, providing five interactive hotspots that link the player to various game systems:

*   **Tactical Market (Left Sliding Door)**: Accesses the blueprint shop for splitters, bombs, and special items. Bounded by a perfectly vertical 3D perspective projection quad representing the sliding door frame to maintain isometric alignment.
*   **Tactical Briefing (Bottom-Left Desk)**: Opens the Admiral's logs and system manuals.
*   **Research Lab (Center Hologram Table)**: Displays floating wireframe holograms of structural modules, facilitating R&D technology upgrades using RP.
*   **Launch Campaign (Main Viewport)**: Leads to the star galaxy selection map.
*   **Training Center (Bottom-Right Terminal)**: Launches simulated sectors for targeting calibration.

All interface hotspots utilize micro glassmorphic tooltips that hover securely clamped within screen boundaries to prevent any visual clipping on mobile aspect ratios.

---

## 7. In-Game Board Tactical Interface

To manage placed modules efficiently on the active grid, players interact with a premium gesture menu:
*   **Single-Tap Cycles**: Tapping a placed module instantly rotates its orientation clockwise with zero gesture latency, facilitating rapid setups.
*   **Holographic Radial HUD**: Long-pressing a placed module for **350ms** triggers a cybernetic target lock-on visualization:
    - Renders a pulsing neon-cyan target circle and bracket guidelines around the selected cell.
    - Draws a dashed vertical connector line containing a pulsing neon-pink scan dot that leads to a floating control capsule.
    - The capsule utilizes glassmorphism (`sigma: 10`) with glowing interactive Touch Targets: **ROTATE (↺)** in cyan and **RECLAIM (🗑)** in warning pink.
*   **Adaptive Boundary Protection**: The HUD automatically monitors grid position. If a device is placed in the top two rows, the leader line and capsule flip downwards to prevent off-screen clipping. The horizontal position clamps to prevent viewport clipping.

---

## 8. Cinematic Sci-Fi Audio System (BGM & SFX)

An immersive, premium soundscape wraps the tactical experience of *Star Destroyer: Single Shot*, creating continuous context-aware audio feedback loops across gameplay stages.

### 8.1 Adaptive Soundtrack (BGM — Looping Tracks)
*   **Command Bridge Theme (`bridge_music.mp3`)**: A deep, atmospheric cosmic synthesizer pad playing looping space ambient background music in the main strategic bridge.
*   **Space Battle Theme (`battle_music.mp3`)**: An energetic, fast-tempo retro cyberpunk synth-wave track playing continuously during active tactical level simulation.
*   **Continuous Seamless Playback**: Looping BGM tracks are managed statefully. When re-entering a screen, the active track is maintained and does not restart from the beginning if it is already playing, preserving audio continuity.

### 8.2 Kinetic Propagation Sound Effects (SFX — Polyphonic Clips)
Sound effects trigger dynamically in real-time corresponding to tactical events and physics interactions:
*   **Plasma Firing Hum (`laser_fire.mp3`)**: Triggers when initiating the superlaser firing sequence.
*   **Metallic Deflection Ping (`deflect.mp3`)**: Plays when the laser beam bounces off refractors, splitters, or rotates via deflection.
*   **Temporal Warp Whoosh (`portal_warp.mp3`)**: Plays on portal transits and black hole gravity bends.
*   **Volumetric Blast Rumble (`explosion.mp3`)**: Triggers upon bomb detonations and single-use asteroid shattering events.
*   **Tactical HUD Click (`hud_click.mp3`)**: Plays when navigating menus, rotating inventory tiles, or performing button selections.
*   **Chime of Upgrades (`upgrade.mp3`)**: Plays on successful R&D tech blueprint upgrades and store purchases.
*   **Fanfare & Power-down (`victory.mp3` & `defeat.mp3`)**: Triggers triumphant electronic synthesis upon sector completion, or low-power decay static upon failure.

### 8.3 Technical & Architecture Safeguards

#### 8.3.1 Polyphonic Sound Player Manager
To handle rapid, overlapping sound triggers (e.g. splitters generating concurrent portal transits and asteroid detonations within milliseconds) without audio clipping or sound truncation, the sound system features a **4-Player Polyphonic SFX Pool**. The system cycles playback across separate `AudioPlayer` channels seamlessly.

#### 8.3.2 Glassmorphic Audio Settings Overlay
Players maintain full, persistent control over audio levels inside the command bridge interface. Real-time toggles modify volume configurations instantly. Preferences are cached securely in local `SharedPreferences` to ensure they persist across app restarts.

#### 8.3.3 VM Test Immunization Guard
To ensure the automated verification suite remains immune to native channel crashes, `AudioService` monitors for Dart VM test context:
*   **The Guard**: Detects test environment execution (`Platform.environment.containsKey('FLUTTER_TEST')`).
*   **The Action**: Automatically bypasses native iOS/Android audio hardware registration, routing all calls into safe, virtualized log mock outputs to ensure the test suite continues running at 100% speed.

