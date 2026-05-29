enum Character { dax, vance, kael, vex, sol }

enum Emotion { calm, determined, worried, angry, defeated }

class DialogueNode {
  final Character speaker;
  final Emotion emotion;
  final String text;
  final bool isLeft;

  const DialogueNode({
    required this.speaker,
    required this.emotion,
    required this.text,
    required this.isLeft,
  });
}

class LoreDialogueConfig {
  static final Map<String, List<DialogueNode>> preMissionDialogues = {
    'q1': [
      const DialogueNode(
        speaker: Character.dax,
        emotion: Emotion.calm,
        text: "This is Captain Dax Sterling. Dreadnought Stealth Chassis holding, but the Kuat jamming arrays are active. We must calibrate the prototype superlaser to bypass their asteroid blockade.",
        isLeft: true,
      ),
      const DialogueNode(
        speaker: Character.kael,
        emotion: Emotion.calm,
        text: "Intruder detected! You are trespassing in restricted Imperial slipways. Activating orbital Energy Shield at (6, 5). Turn back immediately or be vaporized!",
        isLeft: false,
      ),
      const DialogueNode(
        speaker: Character.dax,
        emotion: Emotion.determined,
        text: "I built those energy shield grids, Commander. I know their vector blind spots. Charging the subspace quantum emitter releases a massive energy spike that exposes our location.",
        isLeft: true,
      ),
      const DialogueNode(
        speaker: Character.dax,
        emotion: Emotion.determined,
        text: "We have exactly ONE SHOT to strike your arrays in a single synchronized flash. That leaves no witnesses, no trace, and gives your fleet zero time to lock onto our stealth spike. Commencing detour calibration.",
        isLeft: true,
      ),
    ],
    'q2': [
      const DialogueNode(
        speaker: Character.kael,
        emotion: Emotion.angry,
        text: "Sterling! You won't escape Kuat's fate. I have reinforced the Corellia cargo slipways. Heavy asteroid columns and a terminal gate shield block all direct lines of fire!",
        isLeft: false,
      ),
      const DialogueNode(
        speaker: Character.dax,
        emotion: Emotion.calm,
        text: "The slipways are S-bend corridors, Kael. Perfect for multi-reflections. If we deploy three mirrors, our laser will thread cleanly right through your barricades.",
        isLeft: true,
      ),
      const DialogueNode(
        speaker: Character.dax,
        emotion: Emotion.determined,
        text: "Or, if our laser intensity is high enough, we can disintegrate your gate directly. Either way, this logistics fleet burns today in a single stealth strike.",
        isLeft: true,
      ),
    ],
    'q4': [
      const DialogueNode(
        speaker: Character.vex,
        emotion: Emotion.calm,
        text: "Well, well. Dax Sterling. Grand Moff Vance paid my spice syndicate a mountain of credits to keep this dust sector clean. You won't find a direct shot through this Mon Calamari gas cloud.",
        isLeft: false,
      ),
      const DialogueNode(
        speaker: Character.dax,
        emotion: Emotion.worried,
        text: "This refinery is harvesting highly volatile dark-matter cores. If they destabilize, the entire Mon Calamari orbit will collapse! I must neutralize it.",
        isLeft: true,
      ),
      const DialogueNode(
        speaker: Character.vex,
        emotion: Emotion.angry,
        text: "Not on my watch! Bounce your beam around the asteroids to hit the core, or try blasting through our heavy crystal wall. We are locked and loaded!",
        isLeft: false,
      ),
      const DialogueNode(
        speaker: Character.dax,
        emotion: Emotion.determined,
        text: "We will steer the laser to detonate the explosive core, vaporizing the entire armada before they can transmit our signal. Stand by for impact.",
        isLeft: true,
      ),
    ],
    'q6': [
      const DialogueNode(
        speaker: Character.sol,
        emotion: Emotion.calm,
        text: "Captain Sterling, Vance's primary coordinates are locked inside Kessel's spatial divisions. Firing straight is heavily blocked by our twin shields at (3, 7) and (3, 8).",
        isLeft: false,
      ),
      const DialogueNode(
        speaker: Character.vance,
        emotion: Emotion.calm,
        text: "Sterling. Your stolen dreadnought is impressive, but you cannot pierce dimensional folds. My Kessel outposts are split across folded space.",
        isLeft: false,
      ),
      const DialogueNode(
        speaker: Character.dax,
        emotion: Emotion.determined,
        text: "I designed the warp portal relays, Vance. They operate on spatial reflection vectors. I'll steer the laser into the portal, split the beam across the matrix, and strike both Kessel cores in a single synchronized flash!",
        isLeft: true,
      ),
      const DialogueNode(
        speaker: Character.vance,
        emotion: Emotion.angry,
        text: "Arrogant fool! You have exactly one shot. If a single outpost survives to transmit, my core fleet will reduce your dreadnought to stardust!",
        isLeft: false,
      ),
    ],
    'q7': [
      const DialogueNode(
        speaker: Character.dax,
        emotion: Emotion.calm,
        text: "We have reached the Void Terminus, Vance. The edge of known space. Your capital citadel sits right at the event horizon. There is nowhere left to run.",
        isLeft: true,
      ),
      const DialogueNode(
        speaker: Character.vance,
        emotion: Emotion.calm,
        text: "You're too late, Dax! My singularity shields are active. The crushing gravity of the black hole blocks all straight paths. Your laser will be ripped apart!",
        isLeft: false,
      ),
      const DialogueNode(
        speaker: Character.dax,
        emotion: Emotion.determined,
        text: "The black hole is the key, Vance. Space-time is warped here. I will deploy a localized gravity well to slingshot the beam around the singularity, steer it into the spatial portals, and strike your command core from behind!",
        isLeft: true,
      ),
      const DialogueNode(
        speaker: Character.vance,
        emotion: Emotion.angry,
        text: "Raaah! Your tactical theories are madness! Fire and be consumed by the gravity well!",
        isLeft: false,
      ),
    ],
    'q8': [
      const DialogueNode(
        speaker: Character.dax,
        emotion: Emotion.calm,
        text: "We've tracked Vance's fleet core to the Obsidian Core. The shipyard is locked behind crystalline walls. Directly splitting the laser won't work.",
        isLeft: true,
      ),
      const DialogueNode(
        speaker: Character.vance,
        emotion: Emotion.calm,
        text: "You are persistent, Sterling! But my obsidian columns are impenetrable. You cannot shoot through row 4!",
        isLeft: false,
      ),
      const DialogueNode(
        speaker: Character.dax,
        emotion: Emotion.determined,
        text: "I don't need to shoot through row 4, Vance. I will place the splitter at (3, 6) to bifurcate the laser, detonating the explosive bombs at (1, 6) and (5, 6). The blast will crush your outposts!",
        isLeft: true,
      ),
      const DialogueNode(
        speaker: Character.vance,
        emotion: Emotion.angry,
        text: "Detonation triggers?! Guards, reinforce the perimeter!",
        isLeft: false,
      ),
    ],
    'q9': [
      const DialogueNode(
        speaker: Character.dax,
        emotion: Emotion.calm,
        text: "Vance! Your empire has collapsed. The Chronos Rift is your last stronghold. Surrender your command core.",
        isLeft: true,
      ),
      const DialogueNode(
        speaker: Character.vance,
        emotion: Emotion.calm,
        text: "Never, Sterling! The Chronos Rift is a dimensional convergence. Your standard reflections are useless here. The nexus shields are absolute!",
        isLeft: false,
      ),
      const DialogueNode(
        speaker: Character.dax,
        emotion: Emotion.determined,
        text: "This is the end of the line, Vance. I will combine portals, splitters, and reflectors to fold the laser itself across the rift, striking both of your stations at once!",
        isLeft: true,
      ),
      const DialogueNode(
        speaker: Character.vance,
        emotion: Emotion.angry,
        text: "Raaah! I will reduce your dreadnought to ashes! Chronos defenses, fire!",
        isLeft: false,
      ),
    ],
  };

  static final Map<String, List<DialogueNode>> postMissionDialogues = {
    'q1': [
      const DialogueNode(
        speaker: Character.kael,
        emotion: Emotion.defeated,
        text: "Impossible... our primary shield matrix... shattered in a single flash! The entire Kuat jamming array is... vaporized! Who... what are you?!",
        isLeft: false,
      ),
      const DialogueNode(
        speaker: Character.dax,
        emotion: Emotion.determined,
        text: "A ghost from Vance's past. Jamming arrays cleared. Stealth systems holding. Jumping to hyperspace before their reinforcement ships arrive.",
        isLeft: true,
      ),
      const DialogueNode(
        speaker: Character.vance,
        emotion: Emotion.angry,
        text: "Commander Kael, report! ...Kael! Signal lost. A stealth hull and a superlaser? He's returned...",
        isLeft: false,
      ),
    ],
    'q2': [
      const DialogueNode(
        speaker: Character.kael,
        emotion: Emotion.defeated,
        text: "The Corellian cargo frigates... incinerated in a single flash! Grand Moff Vance... I have failed you...",
        isLeft: false,
      ),
      const DialogueNode(
        speaker: Character.dax,
        emotion: Emotion.calm,
        text: "Vance doesn't care about his officers, Kael. You were just a delay mechanism. Stealth field fully charged. Vanishing in 3... 2... 1...",
        isLeft: true,
      ),
    ],
    'q4': [
      const DialogueNode(
        speaker: Character.vex,
        emotion: Emotion.defeated,
        text: "The dark-matter core... it erupted! The blast... it's tearing my mercenaries apart! Retreat! Retreat!",
        isLeft: false,
      ),
      const DialogueNode(
        speaker: Character.dax,
        emotion: Emotion.calm,
        text: "Dark matter extraction halted. Mon Calamari dust cloud is stabilized. But Vance's main Kessel facility is still active. I'm coming for you, Vance.",
        isLeft: true,
      ),
    ],
    'q6': [
      const DialogueNode(
        speaker: Character.sol,
        emotion: Emotion.defeated,
        text: "Both outposts... vaporized across the portal folds in a single synchronized strike! The dimensional grid is collapsing!",
        isLeft: false,
      ),
      const DialogueNode(
        speaker: Character.vance,
        emotion: Emotion.defeated,
        text: "No... my dark-matter matrix... Kessel is lost! Sterling... what do you want?!",
        isLeft: false,
      ),
      const DialogueNode(
        speaker: Character.dax,
        emotion: Emotion.determined,
        text: "Justice, Vance. For my homeworld, and for every system you harvested. The Empire's hold on this galaxy ends here.",
        isLeft: true,
      ),
    ],
    'q7': [
      const DialogueNode(
        speaker: Character.vance,
        emotion: Emotion.defeated,
        text: "No... the event horizon... my core citadel is collapsing! The gravity well... you bent the light itself... to strike us!",
        isLeft: false,
      ),
      const DialogueNode(
        speaker: Character.dax,
        emotion: Emotion.determined,
        text: "Spacetime is neutral, Vance. It only bends to the mass we place. The singularity has collapsed, and your reign is finished.",
        isLeft: true,
      ),
      const DialogueNode(
        speaker: Character.vance,
        emotion: Emotion.defeated,
        text: "Sterling... this isn't... the end...",
        isLeft: false,
      ),
      const DialogueNode(
        speaker: Character.dax,
        emotion: Emotion.calm,
        text: "It is for you. Stealth systems holding. The Void is silent. Mission fully accomplished.",
        isLeft: true,
      ),
    ],
    'q8': [
      const DialogueNode(
        speaker: Character.vance,
        emotion: Emotion.defeated,
        text: "Obsidian outposts... destroyed in a single chain reaction! The entire shipyard is burning!",
        isLeft: false,
      ),
      const DialogueNode(
        speaker: Character.dax,
        emotion: Emotion.calm,
        text: "One final leap left, Vance. The Chronos Rift. I'm coming to finish this.",
        isLeft: true,
      ),
    ],
    'q9': [
      const DialogueNode(
        speaker: Character.vance,
        emotion: Emotion.defeated,
        text: "No... the nexus... shattered! The Chronos Rift is collapsing! Everything I built... gone...",
        isLeft: false,
      ),
      const DialogueNode(
        speaker: Character.dax,
        emotion: Emotion.determined,
        text: "Your empire was built on harvested worlds, Vance. Now it returns to the void. The galaxy is finally free.",
        isLeft: true,
      ),
      const DialogueNode(
        speaker: Character.vance,
        emotion: Emotion.defeated,
        text: "Sterling... the galaxy... will never...",
        isLeft: false,
      ),
      const DialogueNode(
        speaker: Character.dax,
        emotion: Emotion.calm,
        text: "It will thrive without you. Commencing final stealth fade. Mission accomplished.",
        isLeft: true,
      ),
    ],
  };
}
