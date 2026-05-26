# Star Destroyer: Single Shot — Game Design & Solvability Guide

This guide establishes the rules of engagement, game mechanics, component parameters, and design guidelines for **Star Destroyer: Single Shot**. 

> [!IMPORTANT]
> **MANDATORY RULE FOR LEVEL DESIGNERS**:
> When adding a new Sector (Level) to the database, you **MUST** ensure and verify that the level is mathematically and logically solvable using the provided inventory blueprints and constraints. Obstructing a required placement coordinate with a static wall or planet is strictly prohibited.

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
