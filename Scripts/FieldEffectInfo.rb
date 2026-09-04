# Field Effect Information Database
# Data structure for all field effects and their mechanics
# NOTE: Transforming or destroying any field effect grants a x1.3 power bonus

FIELDEFFECTDATA = {

  ##############################
  # 1. Electric Terrain
  ##############################
  1 => {
    :name => "Electric Terrain",
    :abbr => "ET",
    :message => "The field is hyper-charged!",
    :passiveEffects => [
      "Double shocked Pokemon regain their type at the end of the turn"
    ],
    :overlayEffects => {
      :terrain => "Electric Terrain",
      :effects => [
        "Damage from recoil and crashing is reduced 0.5x",
        "Electric moves from grounded Pokemon increase in base power x1.3",
        "Explosive and Bomb moves deal 1.3x damage",
        "If Electric Terrain is active on Short-Circuit, max boost rolls",
        "Galvanize's damage increase is x1.5"
      ]
    },
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Electric moves (grounded)", "Surf", "Muddy Water", "Hurricane", "Smack Down", "Thousand Arrows", "Hydro Vortex", "Explosive and Bomb moves"],
        2.0 => ["Plasma Fists"]
      },
      :additionalDamageType => {
        "Electric" => ["Surf", "Muddy Water", "Hurricane", "Smack Down", "Thousand Arrows", "Hydro Vortex"]
      },
      :fail => ["Focus Punch"],
      :statEffectAmplified => ["Charge", "Eerie Impulse"],
      :durationChange => {
        "Magnet Rise" => 8
      },
      :special => [
        "Damage from recoil and crashing is nullified",
        "Nature Power becomes Thunderbolt",
        "Camouflage changes the user's type to Electric",
        "Secret Power may Paralyze"
      ]
    },
    :abilityEffects => [
      "Galvanize: boosts attacks to x1.5 instead of x1.2",
      "Surge Surfer: is activated",
      "Gulp Missile: always picks up Pikachu",
      "Mimicry: changes the user's type to Electric"
    ],
    :itemEffects => [
      "Elemental Seed: boosts Defense and applies Charge to the user"
    ]
  },

  ##############################
  # 2. Grassy Terrain
  ##############################
  2 => {
    :name => "Grassy Terrain",
    :abbr => "GT",
    :message => "The field is in full bloom.",
    :passiveEffects => [
      "Grounded Pokemon restore 1/16th max HP at the end of the turn"
    ],
    :overlayEffects => {
      :terrain => "Grassy Terrain",
      :effects => [
        "Grass moves from grounded Pokemon increase in base power x1.3"
      ]
    },
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Grass moves (grounded)", "Fire moves (against grounded)", "Wind moves"]
      },
      :powerDecrease => {
        0.5 => ["Muddy Water", "Surf", "Earthquake", "Magnitude", "Bulldoze"]
      },
      :statEffectAmplified => ["Growth", "Coil"],
      :special => [
        "Floral Healing restores 66% of Max HP",
        "Nature Power becomes Energy Ball",
        "Snap Trap deals 1/6 Max HP damage per turn (from 1/8)",
        "Camouflage changes the user's type to Grass",
        "Secret Power may induce Sleep",
        "Nature's Madness deals 75% HP damage (from 50%)"
      ]
    },
    :abilityEffects => [
      "Mimicry: changes the user's type to Grass",
      "Cotton Down: lowers speed by two stages"
    ],
    :itemEffects => [
      "Elemental Seed: boosts Defense and applies Ingrain to the user"
    ]
  },

  ##############################
  # 3. Misty Terrain
  ##############################
  3 => {
    :name => "Misty Terrain",
    :abbr => "MT",
    :message => "Mist settles on the field.",
    :passiveEffects => [
      "All Pokemon are immune to status conditions",
      "Hail and Rain last for 8 turns"
    ],
    :overlayEffects => {
      :terrain => "Misty Terrain",
      :effects => [
        "Fairy-type attacks from grounded Pokemon deal 1.3x damage",
        "Aura/Pulse moves deal 1.3x damage"
      ]
    },
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Fairy-type attacks (grounded)", "Pulse moves", "Mist Ball", "Steam Eruption", "Strange Steam", "Clear Smog", "Smog"],
        1.3 => ["Hidden Power", "Secret Power", "Ancient Power", "Stored Power"]
      },
      :powerDecrease => {
        0.5 => ["Dragon-type moves"]
      },
      :statEffectAmplified => ["Aromatic Mist", "Mist", "Haze"],
      :special => [
        "Aromatic Mist, Mist, and Haze increase Defense and Special Defense of user and allies",
        "Sweet Scent lowers Defense and Special Defense",
        "Aqua Ring restores 1/8 Max HP each turn",
        "Enables Aurora Veil",
        "Nature Power becomes Mist Ball",
        "Camouflage changes the user's type to Fairy",
        "Secret Power may lower Special Attack"
      ]
    },
    :abilityEffects => [
      "Marvel Scale: is activated",
      "Water Compaction: is activated",
      "Soul Heart: additionally boosts Special Defense on use",
      "Dry Skin: recover 1/16 Max HP each turn",
      "Power Spot: power boost becomes x1.5",
      "Pixilate: base power boost becomes x1.5",
      "Refrigerate: base power boost becomes x1.5",
      "Pastel Veil: halves damage taken from Poison Type attacks for user and allies",
      "Mimicry: changes the user's type to Fairy"
    ],
    :itemEffects => [
      "Elemental Seed: boosts Special Defense and applies Healing Wish to the user"
    ]
  },

  ##############################
  # 4. Dark Crystal Cavern
  ##############################
  4 => {
    :name => "Dark Crystal Cavern",
    :abbr => "DCC",
    :message => "Darkness is gathering...",
    :passiveEffects => [],
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Dark Pulse", "Night Daze", "Night Slash", "Shadow Ball", "Shadow Claw",
                "Shadow Force", "Shadow Sneak", "Shadow Punch", "Aurora Beam", "Signal Beam",
                "Flash Cannon", "Luster Purge", "Dazzling Gleam", "Mirror Shot", "Doom Desire",
                "Technoblast", "Power Gem", "Moongeist Beam", "Shadow Bone",
                "Black Hole Eclipse", "Menacing Moonraze Maelstrom"],
        2.0 => ["Prismatic Laser"]
      },
      :accuracyChange => {
        100 => ["Dark Void"]
      },
      :statEffectAmplified => ["Flash"],
      :fail => ["Solar Beam", "Solar Blade"],
      :special => [
        "Enables Aurora Veil",
        "Moonlight restores 75% of Max HP",
        "Synthesis and Morning Sun restore 25% of Max HP",
        "Nature Power becomes Dark Pulse",
        "Camouflage changes the user's type to Dark",
        "Secret Power may lower Accuracy"
      ]
    },
    :abilityEffects => [
      "Prism Armor: Pokemon take x0.5 decreased damage",
      "Shadow Shield: Pokemon take x0.5 decreased damage"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Crystal Cavern" => ["Sunny weather (temporary)"],
        "Cave" => ["Earthquake (2 uses)", "Bulldoze (2 uses)", "Magnitude (2 uses)", "Tectonic Rage (2 uses)"]
      }
    },
    :itemEffects => [
      "Magical Seed: boosts Sp.Def and applies Magic Coat to the user"
    ]
  },

  ##############################
  # 8. Swamp Field
  ##############################
  8 => {
    :name => "Swamp Field",
    :abbr => "SF",
    :message => "The field is swamped.",
    :passiveEffects => [
      "At end of each turn, speed of each grounded Pokemon is reduced one stage",
      "Sleeping Pokemon suffer 1/16 Max HP damage each turn",
      "Pokemon under effect of Trapping moves lose double speed at end of turn",
      "Sleeping Pokemon under effect of Trapping moves take double damage"
    ],
    :createdBy => {
      :moves => ["Water Pledge + Grass Pledge"]
    },
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Poison moves (against grounded)", "Mud Bomb", "Mud Shot", "Mud Slap",
                "Muddy Water", "Surf", "Sludge Wave", "Gunk Shot", "Brine",
                "Smack Down", "Thousand Arrows", "Hydro Vortex"]
      },
      :additionalDamageType => {
        "Water" => ["Smack Down", "Thousand Arrows"]
      },
      :accuracyChange => {
        100 => ["Sleep Powder"]
      },
      :fail => ["Selfdestruct", "Explosion"],
      :special => [
        "Aqua Ring restores 1/8 Max HP each turn (from 1/16)",
        "Strength Sap heals 30% more HP",
        "Ingrain damages user instead of heals (unless Poison or Steel type)",
        "Nature Power becomes Muddy Water",
        "Camouflage changes the user's type to Water",
        "Secret Power may lower Speed"
      ]
    },
    :abilityEffects => [
      "Clear Body, Quick Feet, Swift Swim, White Smoke, Propellor Tail: immune to field slow",
      "Gooey: effect is doubled",
      "Water Compaction: activates each turn",
      "Dry Skin: recover 1/16 Max HP each turn",
      "Gulp Missile: always picks up Arrokuda",
      "Mimicry: changes the user's type to Water"
    ],
    :itemEffects => [
      "Telluric Seed: boosts Defense and Sp. Def and applies Ingrain to the user"
    ]
  },

  ##############################
  # 9. Rainbow Field
  ##############################
  9 => {
    :name => "Rainbow Field",
    :abbr => "RBF",
    :message => "What does it mean?",
    :passiveEffects => [
      "Secondary effect chance of all moves is doubled",
      "Sleeping Pokemon recover 1/16 Max HP each turn"
    ],
    :createdBy => {
      :moves => ["Fire Pledge + Water Pledge"],
      :note => "Also created by cancelling Rainy or Sunny weather with its opposite"
    },
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Special Normal moves (apply random type damage)", "Silver Wind", "Mystical Fire",
                "Dragon Pulse", "Tri Attack", "Sacred Fire", "Fire Pledge", "Water Pledge",
                "Grass Pledge", "Aurora Beam", "Judgment", "Relic Song", "Hidden Power",
                "Secret Power", "Weather Ball", "Mist Ball", "Heart Stamp", "Moon Blast",
                "Zen Headbutt", "Sparkling Aria", "Fleur Cannon", "Prismatic Laser", "Twinkle Tackle"]
      },
      :powerDecrease => {
        0.5 => ["Dark Pulse", "Night Daze", "Shadow Ball", "Never-ending Nightmare"]
      },
      :statEffectAmplified => ["Meditate", "Cosmic Power"],
      :special => [
        "Sonicboom deals 140 flat HP damage",
        "Life Dew restores 50% of Max HP",
        "Wish restores 75% of Max HP (from 50%)",
        "Enables Aurora Veil",
        "Nightmare and Bad Dreams have no effect",
        "Nature Power becomes Aurora Beam",
        "Camouflage changes the user's type to Dragon",
        "Secret Power may inflict any status randomly"
      ]
    },
    :abilityEffects => [
      "Prism Armor: Pokemon take x0.5 decreased damage",
      "Soul Heart: additionally boosts Sp. Def on use",
      "Pastel Veil: halves damage from Poison type attacks",
      "Cloud Nine: will randomly boost one stat at end of each turn",
      "Marvel Scale: is activated",
      "Mimicry: changes the user's type to Dragon",
      "Wonderskin: will evade all status moves (from 50%)"
    ],
    :fieldTransformations => {
      :terminates => ["Sand weather", "Hail weather"]
    },
    :itemEffects => [
      "Magical Seed: boosts Sp.Atk and applies Healing Wish to the user"
    ]
  },

  ##############################
  # 13. Icy Field
  ##############################
  13 => {
    :name => "Icy Field",
    :abbr => "IF",
    :message => "The field is covered in ice.",
    :passiveEffects => [
      "Physical positive priority and momentum moves raise Speed",
      "Beam moves deal 1.3x damage"
    ],
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Ice moves"]
      },
      :powerDecrease => {
        0.5 => ["Fire moves", "Scald", "Steam Eruption"]
      },
      :durationChange => {
        "Hail" => 8
      },
      :special => [
        "Ice type attacks have a double chance to freeze",
        "Burn damage is halved",
        "Rock-type attacks become Ice-type attacks",
        "Enables Aurora Veil",
        "Nature Power becomes Ice Beam",
        "Camouflage changes the user's type to Ice",
        "Secret Power may Freeze"
      ]
    },
    :abilityEffects => [
      "Ice Body: is activated",
      "Snow Cloak: is activated",
      "Ice Scales: also halves physical damage",
      "Refrigerate: base power boost becomes x1.5 (from x1.2)",
      "Liquid Voice: makes attacks Ice type instead of Water",
      "Slush Rush: is activated",
      "Mimicry: changes the user's type to Ice"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Water Surface" => ["Heat Wave", "Flame Burst", "Lava Plume", "Eruption", "Searing Shot",
                            "Fire Pledge", "Inferno Overdrive", "Magma Drift", "Earthquake",
                            "Magnitude", "Bulldoze", "Tectonic Rage", "Dive"]
      }
    },
    :itemEffects => [
      "Elemental Seed: boosts Speed and lowers Accuracy"
    ]
  },

  ##############################
  # 15. Forest Field
  ##############################
  15 => {
    :name => "Forest Field",
    :abbr => "FOF",
    :message => "The field is abound with trees.",
    :passiveEffects => [
      "Grass- and Bug-type Pokemon's Defense is boosted 1.5x"
    ],
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Grass and special Bug moves", "Attack Order", "Grav Apple", "Slashing moves", "Special Fire-type moves"]
      },
      :powerDecrease => {
        0.5 => ["Surf", "Muddy Water"]
      },
      :additionalDamageType => {
        "Grass" => ["Slashing moves", "Special Fire-type moves"]
      },
      :statEffectAmplified => ["Growth", "Defend Order"],
      :special => [
        "Strength Sap heals 30% more HP",
        "Infestation deals 1/6 Max HP damage per turn (from 1/8)",
        "Nature's Madness deals 75% HP damage (from 50%)",
        "Forest's Curse additionally Curses the target",
        "Heal Order restores 66% of Max HP (from 50%)",
        "Nature Power becomes Wood Hammer",
        "Camouflage changes the user's type to Bug",
        "Secret Power may raise Attack"
      ]
    },
    :abilityEffects => [
      "Overgrow: is activated",
      "Swarm: is activated",
      "Leaf Guard: is activated",
      "Sap Sipper: gradually restores HP",
      "Effect Spore: puts the target to sleep for two turns instead",
      "Mimicry: changes the user's type to Bug"
    ],
    :itemEffects => [
      "Telluric Seed: boosts Attack and applies Spiky Shield to the user"
    ]
  },

  ##############################
  # 17. Factory Field
  ##############################
  17 => {
    :name => "Factory Field",
    :abbr => "FAF",
    :message => "Machines whir in the background.",
    :passiveEffects => [],
    :moveEffects => {
      :powerBoost => {
        1.2 => ["Electric moves"],
        1.5 => ["Steam Roller", "Techno Blast"],
        2.0 => ["Flash Cannon", "Gyro Ball", "Gear Grind", "Magnet Bomb", "Double Iron Bash"]
      },
      :statEffectAmplified => ["Metal Sound", "Iron Defense", "Shift Gear", "Autotomize"],
      :durationChange => {
        "Magnet Rise" => 8
      },
      :special => [
        "Gear Up's effect is doubled and additionally boosts its user",
        "Steel Beam's recoil is set to 25%",
        "Nature Power becomes Gear Grind",
        "Camouflage changes the user's type to Steel",
        "Secret Power may reduce Attack"
      ]
    },
    :abilityEffects => [
      "Galvanize: boost becomes x1.5 (from x1.2)",
      "Steelworker: damage boost becomes x2 (from x1.5)",
      "Download: boost is doubled",
      "Motor Drive: speed boosting effect is doubled",
      "Technician: activates with moves of Base Power of 80 or below",
      "Gulp Missile: always grabs Pikachu",
      "Mimicry: changes the user's type to Steel"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Short-circuit Field" => ["Discharge", "Explosion", "Selfdestruct", "Magnitude", "Fissure",
                                  "Earthquake", "Ion Deluge", "Bulldoze", "Tectonic Rage",
                                  "Gigavolt Havoc", "Overdrive", "Aura Wheel"]
      }
    },
    :itemEffects => [
      "Synthetic Seed: boosts Sp. Atk and applies Laser Focus to the user"
    ]
  },

  ##############################
  # 18. Short-circuit Field
  ##############################
  18 => {
    :name => "Short-circuit Field",
    :abbr => "SCF",
    :message => "Bzzt!",
    :passiveEffects => [
      "Electric attacks amplify a random increment of base power between x0.5 and x2"
    ],
    :moveEffects => {
      :powerBoost => {
        1.3 => ["Dark Pulse", "Night Daze", "Night Slash", "Shadow Ball", "Shadow Claw",
                "Shadow Force", "Shadow Sneak", "Shadow Punch", "Shadow Bone", "Phantom Force"],
        1.5 => ["Dazzling Gleam", "Flash Cannon", "Surf", "Muddy Water", "Gyro Ball",
                "Magnet Bomb", "Gear Grind", "Hydro Vortex"],
        1.667 => ["Steel Beam (instantly KOs user, deals Steel & Electric damage)"]
      },
      :additionalDamageType => {
        "Electric" => ["Surf", "Muddy Water", "Gyro Ball", "Magnet Bomb", "Gear Grind", "Hydro Vortex", "Steel Beam"]
      },
      :accuracyChange => {
        80 => ["Zap Cannon"]
      },
      :statEffectAmplified => ["Metal Sound", "Flash"],
      :durationChange => {
        "Magnet Rise" => 8
      },
      :special => [
        "Nature Power becomes Discharge",
        "Camouflage changes the user's type to Electric",
        "Secret Power may Paralyze"
      ]
    },
    :abilityEffects => [
      "Static: activation chance is doubled to 60%",
      "Volt Absorb: gradually restores HP",
      "Plus: is activated",
      "Minus: is activated",
      "Surge Surfer: is activated",
      "Download: boosts both attacking stats",
      "Gulp Missile: always grabs Pikachu",
      "Mimicry: changes the user's type to Electric",
      "Galvanize: boost becomes x2 (from x1.2)",
      "Steelworker: additionally makes all Steel type attacks gain Electric typing"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Factory Field" => ["Charge Beam", "Discharge", "Wild Charge", "Parabolic Charge",
                           "Ion Deluge", "Gigavolt Havoc", "Overdrive", "Aura Wheel"]
      }
    },
    :itemEffects => [
      "Synthetic Seed: boosts Sp. Def and applies Magnet Rise to the user"
    ]
  },

  ##############################
  # 20. Ashen Beach
  ##############################
  20 => {
    :name => "Ashen Beach",
    :abbr => "AB",
    :message => "Ash and sand line the field.",
    :passiveEffects => [
      "Fighting types are immune to confusion",
      "Pokemon with Own Tempo, Inner Focus, Pure Power, or Steadfast ignore accuracy and evasion changes when attacking (unless opponent has Unnerve)"
    ],
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Strength (with Fighting/Psychic damage)", "Hidden Power", "Land's Wrath", "Surf", "Muddy Water", "Thousand Waves"],
        1.3 => ["Zen Headbutt", "Stored Power", "Aura Sphere", "Focus Blast"],
        1.2 => ["Psychic"],
        2.0 => ["Mud Slap", "Mud Shot", "Mud Bomb", "Sand Tomb"]
      },
      :additionalDamageType => {
        "Fighting/Psychic" => ["Strength"]
      },
      :statEffectAmplified => ["Calm Mind", "Sand Attack", "Kinesis", "Meditate"],
      :durationChange => {
        "Sandstorm" => 8,
        "Sand Stream" => 8,
        "Arenite Wall" => 8
      },
      :special => [
        "Special Flying attacks, Twister, Fire Spin, Leaf Tornado, Razor Wind, and Whirlpool stir up ash, lowering all active Pokemon's accuracy",
        "Psych-up cures the user's status",
        "Focus Energy boosts Critical Hit rate by three stages",
        "Pokemon trapped in Sand Tomb suffer an accuracy drop each turn",
        "Arenite Wall works without the need for a Sandstorm",
        "Shore Up restores 75% HP (from 50%)",
        "Nature Power becomes Meditate",
        "Camouflage changes user's type to Ground",
        "Secret Power may lower accuracy"
      ]
    },
    :abilityEffects => [
      "Sand Veil: is activated",
      "Sand Rush: is activated",
      "Sand Force: is activated",
      "Water Compaction: additionally boosts Sp. Def on use",
      "Sand Spit: lowers accuracy of foes upon activation",
      "Zen Mode: is active",
      "Mimicry: changes the user's type to Ground"
    ],
    :itemEffects => [
      "Telluric Seed: applies Focus Energy"
    ]
  },

  ##############################
  # 21. Water Surface
  ##############################
  21 => {
    :name => "Water Surface",
    :abbr => "WS",
    :message => "The water's surface is calm.",
    :passiveEffects => [],
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Water moves", "Electric moves", "Whirlpool", "Dive", "Surf", "Muddy Water",
                "Sludge Wave", "Hydro Vortex", "Origin Pulse"]
      },
      :powerDecrease => {
        0.5 => ["Fire moves (against grounded)"]
      },
      :fail => ["Ground attacks", "Spikes", "Toxic Spikes"],
      :special => [
        "Dive lasts only one turn",
        "Tar Shot washes off at end of turn",
        "Life Dew grants the user Aqua Ring",
        "Whirlpool deals 1/6 Max HP damage per turn (from 1/8) and confuses the target",
        "Aqua Ring restores 1/8 Max HP each turn (from 1/16)",
        "Splash lowers the opponent's accuracy",
        "Nature Power becomes Whirlpool",
        "Camouflage changes user's type to Water",
        "Secret Power may lower speed"
      ]
    },
    :abilityEffects => [
      "Water Veil: cures all status conditions",
      "Swift Swim: is activated",
      "Hydration: is activated",
      "Torrent: is activated",
      "Dry Skin: grounded Pokemon gradually restore HP",
      "Water Absorb: grounded Pokemon gradually restore HP",
      "Water Compaction: activates each turn",
      "Schooling: is active at all times",
      "Surge Surfer: is activated",
      "Steam Engine: raises speed at end of every turn",
      "Mimicry: changes the user's type to Water",
      "Propeller Tail: increases power of priority moves by 1.5x",
      "Gulp Missile: always picks up Arrokuda"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Underwater" => ["Dive", "Gravity", "Anchor Shot", "Grav Apple"],
        "Murkwater Surface" => ["Sludge Wave (2 uses)", "Acid Downpour (1 use)"],
        "Icy Field" => ["Blizzard", "Glaciate", "Subzero Slammer"]
      }
    },
    :itemEffects => [
      "Elemental Seed: boosts Sp. Def and applies Aqua Ring to the user"
    ]
  },

  ##############################
  # 23. Cave
  ##############################
  23 => {
    :name => "Cave",
    :abbr => "CV",
    :message => "The cave echoes dully...",
    :passiveEffects => [],
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Rock moves", "Sound-based attacks", "Rock Tomb"]
      },
      :powerDecrease => {
        0.5 => ["Non-contact Flying moves"]
      },
      :fail => ["Sky Drop"],
      :special => [
        "Ground type attacks can hit airborne Pokemon",
        "Fly and Bounce each last only one turn",
        "Stealth Rock damage is doubled",
        "Shelter halves damage from Rock-type moves",
        "Terrain Pulse becomes Rock-type",
        "Nature Power becomes Rock Tomb",
        "Camouflage changes user's type to Rock",
        "Secret Power may crush",
        "Earthquake, Bulldoze, Tectonic Rage, Continental Crush and Magnitude collapse the cave, setting and activating Stealth Rocks and crushing all Pokemon",
        "Protection moves, Wide Guard, and Arenite Wall prevent cave-in damage and effects",
        "Pokemon using Endure or Miracle, or having Sturdy survive cave-ins at 1 HP"
      ]
    },
    :abilityEffects => [
      "Punk Rock: increases sound moves by 1.5x",
      "Mimicry: changes the user's type to Rock",
      "Cave-in immunity: Battle Armor, Shell Armor, Solid Rock, Prism Armor, Bulletproof, Rock Head, Stalwart"
    ],
    :itemEffects => [
      "Telluric Seed: sharply boosts Defense but crushes the holder"
    ]
  },

  ##############################
  # 29. Blessed Field
  ##############################
  29 => {
    :name => "Blessed Field",
    :abbr => "HF",
    :message => "The field is blessed!",
    :passiveEffects => [
      "Normal-type moves affect Ghost-type Pokemon"
    ],
    :overlayEffects => {
      :terrain => "Blessed Terrain",
      :effects => [
        "Special Normal-type attacks deal 1.3x damage",
        "Light moves deal 1.3x damage"
      ]
    },
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Fairy and special Normal moves", "Mystical Fire", "Magical Leaf", "Judgment", "Sacred Fire", "Ancient Power"],
        1.3 => ["Psystrike", "Aeroblast", "Origin Pulse", "Precipice Blades", "Dragon Ascent",
                "Doom Desire", "Mist Ball", "Luster Purge", "Psycho Boost", "Spacial Rend",
                "Roar of Time", "Crush Grip", "Secret Sword", "Relic Song", "Hyperspace Hole",
                "Land's Wrath", "Moongeist Beam", "Sunsteel Strike", "Prismatic Laser", "Fleur Cannon",
                "Genesis Supernova", "Behemoth Blade", "Behemoth Bash", "Eternabeam", "Dynamax Cannon",
                "Retribution", "Light moves"],
        1.2 => ["Dragon and Psychic moves"]
      },
      :powerDecrease => {
        0.5 => ["Ghost and special Dark moves"]
      },
      :statEffectAmplified => ["Cosmic Power"],
      :special => [
        "Spirit Break deals super effective damage to Ghost types",
        "Life Dew's healing increases to 50%",
        "Wish restores 75% of Max HP (from 50%)",
        "Miracle Eye additionally boosts SpAtk",
        "Ghost-type Curses are lifted after each turn",
        "Nature's Madness deals 75% HP damage (from 50%)",
        "Nature Power becomes Judgment",
        "Camouflage changes the user's type to Normal",
        "Secret Power may lower SpAtk"
      ]
    },
    :abilityEffects => [
      "Justified: effect is doubled",
      "Cursed Body: has no effect",
      "Perish Body: has no effect",
      "Power Spot: increases partner's damage output by 1.5x",
      "Mimicry: changes the user's type to Normal",
      "RKS System: type becomes Dark at all times"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Cursed Field" => ["Curse (2 uses)", "Ominous Wind (2 uses)", "Phantom Force", "Shadow Force"]
      }
    },
    :itemEffects => [
      "Magical Seed: boosts Sp.Atk and applies Magic Coat to the user"
    ]
  },

  ##############################
  # 36. Inverse Field
  ##############################
  36 => {
    :name => "Inverse Field",
    :abbr => "IF",
    :message => "!trats elttaB",
    :passiveEffects => [
      "The type chart is inverted"
    ],
    :createdBy => {
      :moves => ["Topsy Turvy"],
      :duration => 3,
      :note => "Created for 3 turns by Topsy Turvy unless the user is holding an Everstone"
    },
    :moveEffects => {
      :special => [
        "Nature Power becomes Trick Room",
        "Camouflage changes the user's type to Normal",
        "Secret Power may inflict confusion"
      ]
    },
    :abilityEffects => [
      "Mimicry: changes the user's type to a random type"
    ],
    :itemEffects => [
      "Magical Seed: changes the user's type to Normal and gives them Normalize"
    ]
  },

  ##############################
  # 37. Psychic Terrain
  ##############################
  37 => {
    :name => "Psychic Terrain",
    :abbr => "PT",
    :message => "The field is charged with psychic energy!",
    :passiveEffects => [
      "Gravity and Room moves last 8 turns",
      "Unwound Pokemon regain their type at the end of the turn"
    ],
    :overlayEffects => {
      :terrain => "Psychic Terrain",
      :effects => [
        "Positive priority attacks deal 0.5x damage",
        "Psychic moves increase in base power x1.3"
      ]
    },
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Psychic attacks", "Mystical Fire", "Magical Leaf", "Aura Sphere", "Hex", "Moonblast", "Mind Blown"]
      },
      :additionalDamageType => {
        "Psychic" => ["Strength", "Ancient Power", "Dragon Pulse", "Water Pulse"]
      },
      :fail => ["Positive priority moves"],
      :statEffectAmplified => ["Nasty Plot", "Calm Mind", "Cosmic Power", "Meditate"],
      :special => [
        "Psych Up, Meditate, Mind Reader and Miracle Eye additionally boost Sp.Atk two stages on use",
        "Hypnosis puts the target to sleep for two turns",
        "Kinesis additionally lowers its target's Attack and Sp.Atk two stages",
        "Telekinesis additionally lowers its target's Defense and Sp.Def two stages",
        "Shattered Psyche additionally confuses its target",
        "Secret Power may confuse its target",
        "Nature Power becomes Psychic",
        "Camouflage becomes Psychic"
      ]
    },
    :abilityEffects => [
      "Anticipation: boosts Sp.Atk on switch in",
      "Forewarn: boosts Sp.Atk on switch in",
      "Zen Mode: is activated",
      "Power Spot: increases partner's damage output by 1.5x (from 1.3x)",
      "Telepathy: Pokemon's Speed doubles"
    ],
    :itemEffects => [
      "Magical Seed: boosts Sp.Def and Sp.Atk and confuses the user"
    ]
  },

  ##############################
  # 40. Cursed Field
  ##############################
  40 => {
    :name => "Cursed Field",
    :abbr => "CF",
    :message => "The field is cursed!",
    :passiveEffects => [
      "Ghost-type moves affect Normal-type Pokemon"
    ],
    :overlayEffects => {
      :terrain => "Cursed Terrain",
      :effects => [
        "Ghost-type attacks against grounded Pokemon deal 1.3x damage",
        "Wind moves deal 1.3x damage"
      ]
    },
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Ghost-type moves"],
        1.3 => ["Dark-type moves", "Wind moves", "Flame Burst", "Inferno", "Flame Charge", "Fire Spin"]
      },
      :additionalDamageType => {
        "Ghost" => ["Flame Burst", "Inferno", "Flame Charge", "Fire Spin"]
      },
      :accuracyChange => {
        90 => ["Inferno"]
      },
      :special => [
        "Ghost and Dark-types deal neutral damage to each other",
        "Hypnosis puts the target to sleep for two turns",
        "Nightmare inflicts more damage",
        "Cursed Body always activates upon fainting",
        "Spite depletes two more PP than usual",
        "Ominous Wind has a 20% chance of raising all stats",
        "Curse, when used by a Ghost-type, uses only 25% of the user's HP",
        "Phantom Force and Shadow Force become single turn moves",
        "Mean Look, Fire Spin, Ominous Wind, and Inferno target both opponents",
        "Fire Spin deals 1/6 Max HP damage per turn (from 1/8)",
        "Spirit Break deals super effective damage to Ghost types",
        "Night Shade deals 1.5x more damage",
        "Magic Powder puts the target to Sleep",
        "Scary Face has its effect doubled",
        "Destiny Bond can no longer fail when used consecutively",
        "Nature Power becomes Phantom Force",
        "Camouflage changes the user's type to Ghost",
        "Secret Power inflicts Curse"
      ]
    },
    :abilityEffects => [
      "Perish Body: traps the opponent upon triggering",
      "Cursed Body: always activates upon fainting",
      "Mimicry: changes the user's type to Ghost",
      "Wandering Spirit: Pokemon that gain it lose speed every turn",
      "Power Spot: damage increase is 1.5x",
      "Rattled: boosts the user's Speed upon switch-in"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Blessed Field" => ["Judgement", "Sacred Fire", "Purify", "Origin Pulse", "Retribution"]
      },
      :disables => ["Flash", "Dazzling Gleam"]
    },
    :itemEffects => [
      "Magical Seed: raises Defense and Special Defense and burns the user"
    ]
  },

  ##############################
  # 42. Bewitched Woods
  ##############################
  42 => {
    :name => "Bewitched Woods",
    :abbr => "BW",
    :message => "Double, double toil and trouble…",
    :passiveEffects => [
      "Pokemon sleeping in the fairy rings take damage equal to 1/16th of max HP",
      "Grounded Grass Pokemon restore 1/16th Max HP each turn"
    ],
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Grass-type moves", "Hex", "Mystical Fire", "Spirit Break"],
        1.3 => ["Fairy-type moves", "Dark-type moves", "Magical Leaf", "Dark Pulse", "Night Daze", "Moonblast", "Dream Eater", "Night Slash"]
      },
      :accuracyChange => {
        80 => ["Sleep Powder", "Grass Whistle", "Hypnosis"],
        90 => ["Poison Powder", "Stun Spore", "Will-O-Wisp"]
      },
      :special => [
        "Grass-type attacks now hit Steel-type Pokemon super effectively",
        "Poison-, Fairy-, and Dark-types now hit each other neutrally",
        "Magic Powder puts the target to sleep",
        "Torment lasts for 8 turns and traps the target",
        "Damage taken from Nightmare is doubled",
        "Fairy-types cannot get badly poisoned by Toxic Spikes",
        "Moonlight restores 75% of Max HP",
        "Forest's Curse additionally curses the target",
        "Nature Power becomes Dazzling Gleam",
        "Camouflage changes the user's type to Fairy",
        "Secret Power may randomly inflict Sleep, Poison, or Paralysis"
      ]
    },
    :abilityEffects => [
      "Prankster: affects Dark-type Pokemon",
      "Effect Spore: has a doubled activation rate",
      "Natural Cure: heals status at end of turn",
      "Pastel Veil: removes the user's Fairy-type weaknesses",
      "Aroma Veil: removes the user's Fairy-type weaknesses",
      "Power Spot: damage increase is 1.5x",
      "Mimicry: changes the user's type to Fairy"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Forest Field" => ["Purify", "Geomancy"]
      }
    },
    :itemEffects => [
      "Magical Seed: raises Special Defense and applies Ingrain to the user"
    ]
  },

  ##############################
  # 45. Beach Field
  ##############################
  45 => {
    :name => "Beach Field",
    :abbr => "BF",
    :message => "The waves lap at the shore.",
    :passiveEffects => [
      "Sun lasts for 8 turns"
    ],
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Electric-type moves", "Sand Tomb", "Whirlpool", "Burn Up", "Thousand Waves", "Scorching Sands", "Razor Shell"],
        1.3 => ["Water- and Ground-type moves", "Scald", "Surf", "Muddy Water", "Steam Eruption", "Wind moves (with additional Ground damage)"]
      },
      :additionalDamageType => {
        "Ground" => ["Ominous Wind", "Razor Wind", "Silver Wind", "Icy Wind", "Fairy Wind", "Twister", "Gust"]
      },
      :statEffectAmplified => ["Sand Attack"],
      :durationChange => {
        "Sand Tomb" => 8,
        "Whirlpool" => 8,
        "Arenite Wall" => 8
      },
      :special => [
        "Arenite Wall can be set up without sandstorm",
        "Shore Up restores 75% of Max HP",
        "Nature Power becomes Scorching Sands",
        "Camouflage changes the user's type to Ground",
        "Secret Power may lower Accuracy"
      ]
    },
    :abilityEffects => [
      "Sand Force: is activated",
      "Sand Veil: is activated",
      "Sand Rush: is activated",
      "Swift Swim: is activated",
      "Hydration: is activated",
      "Sand Spit: additionally lowers the opposing Pokemon's Accuracy",
      "Water Compaction: sharply raises Special Defense upon activation",
      "Dry Skin: Pokemon lose 1/16th Max HP at end of each turn",
      "Shell Armor: boosts Defense and Special Defense on entry",
      "Mimicry: changes the user's type to Ground"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Ashen Beach" => ["Lava Plume", "Eruption"],
        "Water Surface" => ["Origin Pulse", "Glacial Flood", "Hydro Vortex"]
      }
    },
    :itemEffects => [
      "Telluric Seed: boosts Speed and Accuracy and applies Sand Tomb to the user"
    ]
  },

  ##############################
  # 47. Library Field
  ##############################
  47 => {
    :name => "Library Field",
    :abbr => "LIB",
    :message => "Pages flutter around!",
    :passiveEffects => [
      "Silencing lowers speed by x0.5",
      "Confused Pokemon take x2 damage"
    ],
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Smart Strike", "Ancient Power", "Barrage", "Headbutt", "Zen Headbutt",
                "Iron Head", "Head Smash", "Head Charge", "Skull Bash", "Mind Blown",
                "Fire Spin (spread)", "Whirlpool (spread)"],
        1.3 => ["Fire-type moves", "Special Psychic-type moves", "Slashing moves", "Wind moves",
                "Focus Punch", "Focus Blast", "Return", "Frustration", "Perforate"]
      },
      :statEffectAmplified => ["Calm Mind", "Amnesia"],
      :special => [
        "Sound-based moves silence the user",
        "Whirlwind and Telekinesis damage the target for 1/6th max HP",
        "Focus Blast cannot miss",
        "Focus Punch cannot be interrupted",
        "Focus Energy increases critical hit rate by three stages",
        "Helping Hand boost is increased to x2",
        "Doodle copies positive stat stages",
        "Fire Spin and Whirlpool become spread moves",
        "Nature Power becomes Calm Mind",
        "Camouflage changes the user's type to Normal",
        "Secret Power may silence"
      ]
    },
    :abilityEffects => [
      "Soundproof, Unaware, Inner Focus, Oblivious: prevent lowering of stats and redirection of moves",
      "Defeatist, Simple, Klutz: Pokemon become confused on entry",
      "Keen Eye: raises Accuracy",
      "Schooling: raises all stats",
      "Analytic: base power boost becomes x1.5",
      "Technician: boosts moves 80 power or below"
    ],
    :itemEffects => [
      "Synthetic Seed: applies Focus Energy to the holder"
    ]
  }

}

# Helper method to get field effect data by ID
def pbGetFieldEffectData(fieldID)
  return FIELDEFFECTDATA[fieldID] if FIELDEFFECTDATA.has_key?(fieldID)
  return nil
end

# Helper method to get field effect name
def pbGetFieldEffectName(fieldID)
  data = pbGetFieldEffectData(fieldID)
  return data ? data[:name] : "Unknown Field"
end

# Helper method to get field message
def pbGetFieldEffectMessage(fieldID)
  data = pbGetFieldEffectData(fieldID)
  return data ? data[:message] : ""
end
