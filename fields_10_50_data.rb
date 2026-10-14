  ##############################
  # 10. Corrosive Field
  ##############################
  10 => {
    :name => "Corrosive Field",
    :abbr => "CF",
    :message => "The field is corrupted!",
    :passiveEffects => [
      "Contains entry hazard dealing type-scaling Poison damage to grounded non Poison and Steel types",
      "Sleeping non-Poison/Steel Pokemon without Wonder Guard suffer 1/16 Max HP damage each turn",
      "Ingrain and Grass Pelt damage their users each turn"
    ],
    :createdBy => {
      :note => "Created via field transformation or specific moves"
    },
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Grass type attacks (additional poison damage)", "Smack Down", "Mud Slap", "Mudshot", "Muddy Water", "Mud Bomb", "Whirlpool", "Thousand Arrows", "Apple Acid"],
        2.0 => ["Grass Knot", "Acid", "Acid Spray", "Snap Trap"]
      },
      :additionalDamageType => {
        "Poison" => ["Grass type attacks", "Smack Down", "Mud Slap", "Mudshot", "Muddy Water", "Mud Bomb", "Whirlpool", "Thousand Arrows", "Apple Acid"]
      },
      :accuracyChange => {
        100 => ["Sleep Powder", "Poison Powder", "Stun Spore", "Toxic"]
      },
      :statEffectAmplified => ["Acid Armor"],
      :special => [
        "Floral Healing additionally poisons its target",
        "Activates Venom Drench and Venoshock",
        "Toxic Spikes cannot be absorbed",
        "Nature Power becomes Acid",
        "Camouflage changes the user's type to Poison",
        "Secret Power may Poison"
      ]
    },
    :abilityEffects => [
      "Toxic Boost, Poison Heal, Immunity, Wonder Guard, Pastel Veil: ignore entry damage",
      "Corrosion: Pokemon deal x1.5 damage",
      "Activates Merciless",
      "Mimicry: changes the user's type to Poison",
      "Poison Heal and Toxic Boost: are activated for grounded Pokemon"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Grassy Terrain" => ["Seed Flare", "Purify"]
      }
    },
    :itemEffects => [
      "Telluric Seed: boosts Attack and applies Baneful Bunker to the user"
    ]
  },

  ##############################
  # 11. Corrosive Mist Field
  ##############################
  11 => {
    :name => "Corrosive Mist Field",
    :abbr => "CMF",
    :message => "Corrosive mist settles on the field!",
    :passiveEffects => [
      "All Pokemon are poisoned at the end of each round if Neutralising Gas is not active",
      "Aqua Ring and Dry Skin damage their users each turn (Poison Types will be healed by Dry Skin instead)",
      "The abilities Poison Heal and Toxic Boost are activated"
    ],
    :createdBy => {
      :note => "Created via field transformation"
    },
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Fire moves", "Smog", "Clear Smog", "Acid Spray", "Bubble", "Bubble Beam", "Sparkling Aria", "Apple Acid", "Oceanic Operetta"]
      },
      :additionalDamageType => {
        "Poison" => ["Special Flying attacks", "Bubble", "Bubble beam", "Energy ball", "Sparkling Aria", "Apple Acid"]
      },
      :accuracyChange => {
        100 => ["Toxic"]
      },
      :statEffectAmplified => ["Acid Armor", "Smokescreen"],
      :fail => [],
      :special => [
        "Activates Venom Drench and Venoshock",
        "Floral Healing additionally poisons its target",
        "Life Dew additionally poisons the targets",
        "Nature Power becomes Acid Spray",
        "Camouflage changes the user's type to Poison",
        "Secret Power may Poison",
        "Pokemon using Endure, or having Sturdy may survive field-termination damage with 1 HP",
        "Pokemon behind protect moves including Wide Guard, or having Flash Fire are immune to field-termination damage"
      ]
    },
    :abilityEffects => [
      "Aftermath: damages for 50% HP (from 25%)",
      "Mimicry: changes the user's type to Poison",
      "Activates Water Compaction on send out",
      "Corrosion: Pokemon deal x1.5 damage",
      "Activates Merciless"
    ],
    :fieldTransformations => {
      :terminates => ["Heat Wave", "Eruption", "Lava Plume", "Searing Shot", "Fire Pledge", "Flame Burst", "Selfdestruct", "Explosion", "Inferno Overdrive (KOs all active Pokemon)", "Gust", "Whirlwind", "Defog", "Hurricane", "Tailwind", "Razor Wind", "Twister", "Supersonic Skystrike"],
      :transformsTo => {
        "Corrosive Field" => ["Gravity"]
      }
    },
    :itemEffects => [
      "Elemental Seed: boosts Attack and Sp.Atk and badly poisons the user"
    ]
  },

  ##############################
  # 12. Desert Field
  ##############################
  12 => {
    :name => "Desert Field",
    :abbr => "DF",
    :message => "The field is rife with sand.",
    :passiveEffects => [
      "Sunny Day, Drought, Sand Storm and Sandstream last for 8 turns",
      "Ground type Pokemon's Sp.Def increases x1.5",
      "Sandstorm deals 1/8 Max HP damage per turn (from 1/16)",
      "When Sunny Day is active: Grass and Water-type Pokemon take 1/8 Max HP damage at the end of the turn",
      "When Sunny Day is active: Grass and Water-type Pokemon are healed by Water-type moves (similar to dry skin)",
      "When Sunny Day is active: Dry Skin damages its user each turn"
    ],
    :createdBy => {
      :note => "Created via field transformation or set by event"
    },
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Heat Wave", "Needle Arm", "Pin Missile", "Dig", "Sand Tomb", "Thousand Waves", "Burn up", "Scald", "Steam Eruption"]
      },
      :powerDecrease => {
        0.5 => ["Water-type moves from grounded (excluding Scald and Steam Eruption)", "Electric moves against grounded"]
      },
      :statEffectAmplified => ["Sand Attack"],
      :fail => ["Soak", "Aqua Ring"],
      :durationChange => {
        "Arenite Wall" => 8
      },
      :special => [
        "Nature Power becomes Sand Tomb",
        "Shore up restores 66% HP (from 50%)",
        "Sand Tomb deals 1/6 Max HP damage per turn (from 1/8)",
        "Arenite Wall works without the need for a Sandstorm",
        "Camouflage changes the user's type to Ground",
        "Secret Power may lower Accuracy"
      ]
    },
    :abilityEffects => [
      "Solar Idol, Sand Veil, Sand Rush and Sand Force: are activated",
      "Mimicry: changes the user's type to Ground",
      "Sand Spit: lowers accuracy of foes upon activation",
      "Pokemon that gain Wandering Spirit: lose speed every turn"
    ],
    :itemEffects => [
      "Telluric Seed: boosts Defense, Sp.Def and Speed and applies Sand Tomb to the user"
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
      "Hail lasts for 8 turns",
      "Grounded Pokemon increase Speed when using all attacking, physical-contact priority moves, Feint, Rollout, Steamroller, Defense Curl, Lunge",
      "Ice type attacks have a double chance to freeze",
      "Burn damage is halved"
    ],
    :createdBy => {
      :note => "Created via field transformation"
    },
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Ice moves"]
      },
      :powerDecrease => {
        0.5 => ["Fire moves", "Scald", "Steam Eruption"]
      },
      :special => [
        "Rock-type attacks become Ice-type attacks",
        "Nature Power becomes Ice Beam",
        "Camouflage changes the user's type to Ice",
        "Secret Power may Freeze",
        "Enables Aurora Veil"
      ]
    },
    :abilityEffects => [
      "Activates Ice Body and Snow Cloak",
      "Ice Scales: also halves physical damage",
      "Refrigerate's base power boost becomes x1.5 (from x1.2)",
      "Liquid Voice: makes attacks Ice type instead of Water",
      "Activates Slush Rush",
      "Mimicry: changes the user's type to Ice"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Water Surface" => ["Heat Wave", "Flame Burst", "Lava Plume", "Eruption", "Searing Shot", "Fire Pledge", "Inferno Overdrive", "Magma Drift"],
        "Cave" => ["Earthquake", "Magnitude", "Bulldoze", "Tectonic Rage", "Dive (if beneath is Water/Murkwater)"]
      }
    },
    :itemEffects => [
      "Elemental Seed: boosts Speed two stages"
    ]
  },

  ##############################
  # 14. Rocky Field
  ##############################
  14 => {
    :name => "Rocky Field",
    :abbr => "ROF",
    :message => "The field is littered with rocks.",
    :passiveEffects => [
      "While a substitute is up or evasion is increased, Pokemon may dodge Bulletproof-blockable attacks behind rocks",
      "Missing a physical contact attack causes 1/8 Max HP recoil damage (does not affect Rock Head Pokemon)",
      "Pokemon with Gorilla Tactics take double recoil damage",
      "Flinched Pokemon suffer 1/16 Max HP damage (does not affect Sturdy or Steadfast Pokemon)"
    ],
    :createdBy => {
      :note => "Created via field transformation or set by event"
    },
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Rock moves", "Earthquake", "Magnitude", "Rock Climb", "Strength", "Bulldoze", "Accelerock"],
        2.0 => ["Rock Smash"]
      },
      :additionalDamageType => {
        "Rock" => ["Earthquake", "Magnitude", "Rock Climb", "Strength", "Bulldoze", "Accelerock"]
      },
      :statEffectAmplified => ["Rock Polish"],
      :durationChange => {
        "Arenite Wall" => 8
      },
      :special => [
        "Arenite Wall works without the need for a Sandstorm",
        "Stealth Rock damage is doubled",
        "Nature Power becomes Rock Smash",
        "Camouflage changes the user's type to Rock",
        "Secret Power may Flinch"
      ]
    },
    :abilityEffects => [
      "Long Reach: drops accuracy by x0.9"
    ],
    :itemEffects => [
      "Telluric Seed: boosts Defense and Sp.Def and damages the user with Stealth Rocks"
    ]
  },

  ##############################
  # 15. Forest Field
  ##############################
  15 => {
    :name => "Forest Field",
    :abbr => "FOF",
    :message => "The field is abound with trees.",
    :passiveEffects => [],
    :createdBy => {
      :note => "Created via field transformation or set by event"
    },
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Grass and special Bug moves", "Grav Apple"],
        2.0 => ["Attack Order", "Cut (with additional Grass damage)"]
      },
      :powerDecrease => {
        0.5 => ["Surf", "Muddy Water"]
      },
      :additionalDamageType => {
        "Grass" => ["Cut", "Slash", "Air Slash", "Fury Cutter", "Air Cutter", "Psycho Cut", "Breaking Swipe"]
      },
      :statEffectAmplified => ["Growth", "Defend Order"],
      :special => [
        "Strength Sap heals 30% more HP",
        "Infestation deals 1/6 Max HP damage per turn (from 1/8)",
        "Nature's Madness deals 75% HP damage (from 50%)",
        "Forest's Curse additionally Curses the target",
        "Heal Order restores 66% of the user's Max HP (from 50%)",
        "Nature Power becomes Wood Hammer",
        "Ingrain's healing effect is doubled",
        "Camouflage changes the user's type to Bug",
        "Secret Power may induce Sleep",
        "Sticky Web's effect is doubled"
      ]
    },
    :abilityEffects => [
      "Activates Overgrow, Swarm, Grass Pelt and Leaf Guard",
      "Long Reach: Pokemon suffer a x0.9 accuracy loss",
      "Sap Sipper: gradually restores HP",
      "Effect Spore: activation chance is doubled to 60%",
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
    :createdBy => {
      :note => "Created via field transformation or set by event"
    },
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
        "Gear Up's effect is doubled, and additionally boosts its user",
        "Steel Beam's recoil is set to 25%",
        "Nature Power becomes Gear Grind",
        "Camouflage changes the user's type to Steel",
        "Secret Power may reduce Attack",
        "Discharge additionally can potentially alternate between Short-circuit and Factory for each instance of damage in double battles"
      ]
    },
    :abilityEffects => [
      "Galvanize's boost becomes x1.5 (from x1.2)",
      "Steelworker's damage boost becomes x2 (from x1.5)",
      "Download's boost is doubled",
      "Motor Drive's speed boosting effect is doubled",
      "Technician: activates with moves of Base Power of 80 or below",
      "Gulp Missile: always grabs Pikachu",
      "Mimicry: changes the user's type to Steel"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Short-circuit Field" => ["Discharge", "Explosion", "Selfdestruct", "Magnitude", "Fissure", "Earthquake", "Ion Deluge", "Bulldoze", "Tectonic Rage", "Gigavolt Havoc", "Overdrive", "Aura Wheel"]
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
    :createdBy => {
      :note => "Created via field transformation from Factory Field"
    },
    :moveEffects => {
      :powerBoost => {
        1.3 => ["Dark Pulse", "Night Daze", "Night Slash", "Shadow Ball", "Shadow Claw", "Shadow Force", "Shadow Sneak", "Shadow Punch", "Shadow Bone", "Phantom Force"],
        1.5 => ["Dazzling Gleam", "Flash Cannon", "Surf", "Muddy Water", "Gyro Ball", "Magnet Bomb", "Gear Grind", "Hydro Vortex"],
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
      "Static's activation chance is doubled to 60%",
      "Volt Absorb: gradually restores HP",
      "Activates Plus and Minus",
      "Activates Surge Surfer",
      "Download: boosts both attacking stats",
      "Gulp Missile: always grabs Pikachu",
      "Mimicry: changes the user's type to Electric",
      "Galvanize's boost becomes x2 (from x1.2)",
      "Steelworker: additionally makes all Steel type attacks gain Electric typing"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Factory Field" => ["Charge Beam", "Discharge", "Wild Charge", "Parabolic Charge", "Ion Deluge", "Gigavolt Havoc", "Overdrive", "Aura Wheel"]
      }
    },
    :itemEffects => [
      "Synthetic Seed: boosts Sp. Def and applies Magnet Rise to the user"
    ]
  },

  ##############################
  # 19. Wasteland
  ##############################
  19 => {
    :name => "Wasteland",
    :abbr => "WL",
    :message => "The waste is watching...",
    :passiveEffects => [
      "Entry hazards are consumed at the end of the turn, returning a special effect to the side they were on:",
      "Stealth Rocks deal type-scaling Rock damage double the normal effect to Pokemon",
      "Spikes deal 33% max HP to grounded Pokemon",
      "Toxic Spikes deal 12.5% max HP to grounded non-Poison/Steel types, and inflicts poison",
      "Sticky Web severely lowers Pokemon's speed"
    ],
    :createdBy => {
      :note => "Created via field transformation or set by event"
    },
    :moveEffects => {
      :powerBoost => {
        1.2 => ["Gunk Shot", "Sludge", "Sludge Wave", "Sludge Bomb", "Acid Downpour", "Octazooka (chance to inflict random status)"],
        1.5 => ["Vine Whip", "Power Whip", "Mud Bomb", "Mud Slap", "Mud Shot"]
      },
      :powerDecrease => {
        0.25 => ["Magnitude", "Earthquake", "Bulldoze"]
      },
      :additionalDamageType => {
        "Poison" => ["Mud Bomb", "Mud Slap", "Mud Shot"]
      },
      :special => [
        "Activates Venom Drench and Venoshock",
        "Nature Power becomes Gunk Shot",
        "Camouflage changes user's type to Poison",
        "Secret Power may inflict Burn, Paralysis, Freeze or Poison",
        "Spit-up gains a x2 boost in power",
        "Swallow's healing effect is doubled, curing the user of status at maximum stock",
        "Poison moves have a chance to inflict random status on non-poison/steel targets",
        "Acid Downpour additionally applies a random status to non-Poison/Steel types"
      ]
    },
    :abilityEffects => [
      "Effect Spore, Poison Point and Stench's activation chances are doubled",
      "Liquid Ooze: deals double damage",
      "Activates Poison Heal and Toxic Boost",
      "Gooey: additionally poisons on contact",
      "Pokemon with Corrosion: may trigger field's random statuses on any Pokemon",
      "Activates Merciless"
    ],
    :itemEffects => [
      "Telluric Seed: boosts Atk and Sp Atk and applies a random status to the user"
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
      "Pokemon with Inner Focus, Pure Power, Steadfast ignore accuracy and evasion changes when attacking (unless opponent has Unnerve)"
    ],
    :createdBy => {
      :note => "Created via field transformation or set by event"
    },
    :moveEffects => {
      :powerBoost => {
        1.2 => ["Psychic"],
        1.3 => ["Zen Headbutt", "Stored Power", "Aura Sphere", "Focus Blast"],
        1.5 => ["Hidden Power", "Land's Wrath", "Surf", "Muddy Water", "Thousand Waves", "Strength (with Fighting/Psychic damage)"],
        2.0 => ["Mud Slap", "Mud Shot", "Mud Bomb", "Sand Tomb"]
      },
      :additionalDamageType => {
        "Fighting/Psychic" => ["Strength"]
      },
      :statEffectAmplified => ["Calm Mind", "Sand Attack", "Kinesis", "Meditate"],
      :durationChange => {
        "Sandstorm and Sand Stream" => 8,
        "Arenite Wall" => 8
      },
      :special => [
        "Special Flying attacks, Twister, Fire Spin, Leaf Tornado, Razor Wind, Whirlpool stir up ash, lowering all active Pokemon's accuracy",
        "Psych-up cures the user's status",
        "Focus Energy boosts Critical Hit rate by three stages",
        "Pokemon trapped in Sand Tomb suffer an accuracy drop each turn",
        "Arenite Wall works without the need for a Sandstorm",
        "Nature Power becomes Meditate",
        "Camouflage changes user's type to Ground",
        "Secret Power may lower accuracy",
        "Shore Up restores 75% HP (from 50%)"
      ]
    },
    :abilityEffects => [
      "Activates Sand Veil, Sand Rush and Sand Force",
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
    :passiveEffects => [
      "Ground attacks always fail",
      "Spikes and Toxic Spikes sink into the water, vanishing"
    ],
    :createdBy => {
      :note => "Created via field transformation"
    },
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Water and Electric moves", "Whirlpool", "Dive", "Surf", "Muddy Water", "Sludge Wave", "Hydro Vortex", "Origin Pulse"]
      },
      :powerDecrease => {
        0.5 => ["Fire moves against grounded Pokemon"]
      },
      :special => [
        "Dive lasts only one turn",
        "Tar Shot washes off at the end of the turn",
        "Life Dew grants the user Aqua Ring",
        "Whirlpool deals 1/6 Max HP damage per turn (from 1/8) and confuses the target",
        "Nature Power becomes Whirlpool",
        "Camouflage changes user's type to Water",
        "Secret Power may lower speed",
        "Splash lowers the opponent's accuracy",
        "Aqua Ring restores 1/8 Max HP each turn (from 1/16)"
      ]
    },
    :abilityEffects => [
      "Water Veil: cures all status conditions",
      "Activates Swift Swim, Hydration, Torrent",
      "Grounded Pokemon with Dry Skin and Water Absorb: gradually restore HP",
      "Shore Up: activates Water Compaction",
      "Schooling: is active at all times",
      "Activates Surge Surfer",
      "Activates Water Compaction each turn",
      "Steam Engine: raises speed at the end of every turn",
      "Mimicry: changes the user's type to Water",
      "Propeller Tail: increases the power of the user's priority moves by 1.5x",
      "Gulp Missile: always picks up Arrokuda"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Underwater" => ["Dive", "Gravity", "Anchor Shot", "Grav Apple"],
        "Murkwater Surface" => ["Sludge Wave (two uses)", "Acid Downpour (one use)"],
        "Icy Field" => ["Blizzard", "Glaciate", "Subzero Slammer"]
      }
    },
    :itemEffects => [
      "Elemental Seed: boosts Sp. Def and applies Aqua Ring to the user"
    ]
  },

  ##############################
  # 22. Underwater
  ##############################
  22 => {
    :name => "Underwater",
    :abbr => "UW",
    :message => "Blub blub...",
    :passiveEffects => [
      "All weather is annulled",
      "Non-water types' Speed is halved, except for Swift Swimmers",
      "Non-Water types that are weak to Water take type-scaling damage each turn"
    ],
    :createdBy => {
      :note => "Created via field transformation from Water Surface"
    },
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Water moves", "Water Pulse"],
        2.0 => ["Electric moves", "Dragon Darts", "Anchor Shot"]
      },
      :additionalDamageType => {
        "Water" => ["Ground type attacks", "Grav Apple", "Dragon Darts"]
      },
      :fail => ["Fire attacks", "Tar Shot"],
      :special => [
        "Water attacks deal neutral damage to Water type Pokemon",
        "Whirlpool deals 1/6 Max HP damage per turn (from 1/8) and confuses the target",
        "Dive lasts only one turn",
        "Nature Power becomes Water Pulse",
        "Camouflage changes user's type to Water",
        "Secret Power may lower attack",
        "Aqua Ring restores 1/8 Max HP each turn (from 1/16)"
      ]
    },
    :abilityEffects => [
      "Swift Swim, Steelworker: immune to field damage and speed decrease",
      "Magic Guard, Swift Swim: immune to field damage",
      "Magma Armor, Flame Body: take x2 field damage",
      "Water Veil: cures all status conditions",
      "Activates Swift Swim, Hydration, Torrent",
      "Dry Skin and Water Absorb: gradually restore HP",
      "Steam Engine: raises speed at the end of every turn",
      "Mimicry: changes the user's type to Water",
      "Propellor Tail: increases the power of the user's priority moves by 1.5x",
      "Gulp Missile: always picks up Arrokuda (damage dealt is Water type scaling damage)",
      "Schooling: is active at all times",
      "Activates Surge Surfer",
      "Activates Water Compaction each turn"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Water Surface" => ["Dive", "Fly", "Bounce", "Sky Drop", "Shore Up"],
        "Murkwater Surface" => ["Sludge Wave (two uses)", "Acid Downpour"]
      }
    },
    :itemEffects => [
      "Elemental Seed: boosts Speed and applies Soak to the user"
    ],
    :fieldDamage => {
      :amount => "type-scaling Water damage",
      :timing => "end of turn",
      :affects => "Non-Water types that are weak to Water",
      :immuneAbilities => ["Magic Guard", "Swift Swim", "Steelworker"],
      :doubledAbilities => ["Magma Armor", "Flame Body"]
    }
  },

  ##############################
  # 23. Cave
  ##############################
  23 => {
    :name => "Cave",
    :abbr => "CV",
    :message => "The cave echoes dully...",
    :passiveEffects => [
      "Ground type attacks can hit airborne Pokemon",
      "Fly and Bounce each last only one turn",
      "Earthquake, Bulldoze, Tectonic Rage, Continental Crush and Magnitude collapse the cave after two uses, instantly KOing all active Pokemon"
    ],
    :createdBy => {
      :note => "Created via field transformation or set by event"
    },
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Rock moves", "Sound-based attacks", "Rock Tomb"]
      },
      :powerDecrease => {
        0.5 => ["Non-contact Flying moves"]
      },
      :fail => ["Sky Drop"],
      :special => [
        "Stealth Rock damage is doubled",
        "Nature Power becomes Rock Tomb",
        "Camouflage changes user's type to Rock",
        "Secret Power may flinch",
        "Pokemon using Endure, or having Sturdy may survive collapse with 1 HP",
        "Pokemon with Battle Armor and Shell Armor take 50% damage from collapse",
        "Pokemon with Solid Rock or Prism Armor or Arenite Wall take 33% damage from collapse",
        "Pokemon behind protect moves including Wide Guard, or having Bulletproof, Rock Head, or Stalwart are immune to collapse damage"
      ]
    },
    :abilityEffects => [
      "Punk Rock: increases sound moves by 1.5x",
      "Mimicry: changes the user's type to Rock"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Crystal Cavern" => ["Power Gem", "Diamond Storm"],
        "Dragon's Den" => ["Dragon Pulse (Two uses)", "Draco Meteor", "Devastating Drake"],
        "Volcanic Field" => ["Fever Pitch (two uses)", "Magma Drift (two uses)", "Eruption (two uses)", "Lava Plume (two uses)", "Heat Wave (two uses)", "Overheat (two uses)", "Fusion Flare"],
        "Corrupted Cave" => ["Sludge Wave", "Acid Downpour"],
        "Icy Field" => ["Blizzard", "Subzero Slammer"]
      }
    },
    :itemEffects => [
      "Telluric Seed: boosts Defense and damages the user with Stealth Rocks"
    ]
  },

  ##############################
  # 24. Glitch Field
  ##############################
  24 => {
    :name => "Glitch Field",
    :abbr => "GF",
    :message => "1n!taliz3 .b//////attl3",
    :passiveEffects => [
      "The physical/special move split is undone",
      "Special Attacks, for both attacker and defender, calculate off of the higher stat between SpAtk and SpDef"
    ],
    :createdBy => {
      :moves => ["Conversion and Conversion2 in succession while not holding an Everstone"],
      :duration => 5
    },
    :moveEffects => {
      :powerBoost => {
        1.2 => ["Psychic moves"],
        1.3 => ["Techno Blast"]
      },
      :accuracyChange => {
        90 => ["Blizzard"]
      },
      :fail => ["Roar", "Whirlwind"],
      :special => [
        "Fairy type attacks become Normal type",
        "Type chart altered: Dragon deals neutral, Bug hits Poison super-effectively, Ice hits Fire neutrally, Ghost can't hit Psychic, Poison hits Bug super-effectively, Steel resists Ghost and Dark",
        "Critical hit rate increases by one stage if attacker is faster than target",
        "Moves with recharge turn don't need to recharge if opponent is KO'd",
        "Rest heals the user when called by Sleep Talk and resets sleep counter to 2 turns",
        "Rage locks the user into the move indefinitely",
        "Metronome will never choose a move with less than 70 base power",
        "Explosion and Selfdestruct reduce targets' defense by half",
        "Nature Power becomes Metronome",
        "Camouflage changes user's type to Bird",
        "Secret Power may lower speed"
      ]
    },
    :abilityEffects => [
      "RKS System's type becomes ??? at all times",
      "Mimicry: changes the user's type to ???",
      "Download: raises both offensive stats"
    ],
    :itemEffects => [
      "Synthetic Seed: boosts Def and Sp. Def and makes user ??? type",
      "Drives: allow Genesect to become immune to the respective type of the drive"
    ]
  },

  ##############################
  # 25. Crystal Cavern
  ##############################
  25 => {
    :name => "Crystal Cavern",
    :abbr => "CC",
    :message => "The cave is littered with crystals.",
    :passiveEffects => [],
    :createdBy => {
      :note => "Created via field transformation from Cave"
    },
    :moveEffects => {
      :powerBoost => {
        1.3 => ["Aurora Beam", "Signal Beam", "Flash Cannon", "Dazzling Gleam", "Mirror Shot", "Doom Desire", "Technoblast", "Moongeist Beam", "Menacing Moonraze Maelstrom", "Photon Geyser"],
        1.5 => ["Rock type attacks (random Fire/Water/Grass/Psychic typing)", "Dragon moves", "Power Gem", "Diamond Storm", "Ancient Power", "Rock Smash", "Rock Tomb", "Prismatic Laser", "Luster Purge", "Judgment", "Strength", "Rock Climb", "Multi-Attack"]
      },
      :special => [
        "Rock attacks randomly gain Fire, Water, Grass, or Psychic typing",
        "Stealth Rocks' damage type randomly becomes Fire, Water, Grass or Psychic",
        "Nature Power becomes Power Gem",
        "Camouflage changes the user's type to one of Fire, Water, Grass or Psychic",
        "Secret Power may inflict a random status between Burn, Freeze, Sleep or Confusion",
        "Enables Aurora Veil",
        "Rock Polish additionally increases Attack and SpAtk one stage each"
      ]
    },
    :abilityEffects => [
      "Prism Armor: Pokemon take x0.5 decreased damage",
      "Mimicry: changes the user's type to Rock"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Dark Crystal Cavern" => ["Dark Pulse", "Dark Void", "Night Daze"],
        "Cave" => ["Earthquake (two uses)", "Bulldoze (two uses)", "Magnitude (two uses)", "Tectonic Rage (one use)"]
      }
    },
    :itemEffects => [
      "Magical Seed: boosts Sp Atk and applies Magic Coat to the user"
    ]
  },

  ##############################
  # 26. Murkwater Surface
  ##############################
  26 => {
    :name => "Murkwater Surface",
    :abbr => "MS",
    :message => "The water is tainted...",
    :passiveEffects => [
      "Grounded non-Poison or Steel types take type-scaling Poison damage at the end of each turn",
      "Pokemon using Dive take x4 field damage",
      "Ground attacks always fail",
      "Spikes and Toxic Spikes sink into the water, vanishing"
    ],
    :createdBy => {
      :note => "Created via field transformation from Water Surface"
    },
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Water attacks (additional Poison damage)", "Poison type attacks", "Electric attacks", "Mud Bomb", "Mud shot", "Mud Slap", "Thousand Waves", "Smack Down", "Apple Acid", "Acid", "Acid Spray", "Brine"]
      },
      :additionalDamageType => {
        "Poison" => ["Water attacks", "Mud Bomb", "Mud shot", "Mud Slap", "Thousand Waves", "Smack Down", "Apple Acid"],
        "Water" => ["Sludge Wave"],
        "Water/Poison" => ["Mud Bomb", "Mud shot", "Mud Slap", "Thousand Waves"]
      },
      :statEffectAmplified => ["Acid Armor"],
      :special => [
        "Tar Shot poisons targets",
        "Life Dew poisons targets",
        "Activates Venom Drench and Venoshock",
        "Nature Power becomes Sludge Wave",
        "Camouflage changes the user's type to Poison",
        "Secret Power may inflict poison"
      ]
    },
    :abilityEffects => [
      "Grounded Poison-type Pokemon with Dry Skin or Water Absorb: gradually recover HP",
      "Poison Heal and Toxic Boost: are activated for grounded Pokemon",
      "Activates Merciless",
      "Mimicry: changes the user's type to Poison",
      "Activates Swift Swim",
      "Gooey: effect is doubled",
      "Liquid Ooze: deals double damage",
      "Stench's activation chance is doubled",
      "Shore Up: activates Water Compaction",
      "Activates Water Compaction each turn",
      "Schooling: is active at all times",
      "Activates Surge Surfer"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Water Surface" => ["Whirlpool", "Purify"],
        "Icy Field" => ["Blizzard", "Glaciate", "Subzero Slammer"]
      }
    },
    :itemEffects => [
      "Elemental Seed: applies Soak and Aqua Ring, and poisons the user"
    ],
    :fieldDamage => {
      :amount => "type-scaling Poison damage",
      :timing => "end of turn",
      :affects => "grounded non-Poison or Steel types",
      :immuneAbilities => ["Immunity", "Toxic Boost", "Poison Heal", "Magic Guard", "Wonder Guard", "Pastel Veil", "Surge Surfer"],
      :doubledAbilities => ["Dry Skin", "Water Absorb", "Magma Armor", "Flame Body"]
    }
  },

  ##############################
  # 27. Mountain
  ##############################
  27 => {
    :name => "Mountain",
    :abbr => "MTN",
    :message => "High up!",
    :passiveEffects => [
      "Sunny Day and Drought last for 8 turns",
      "After three consecutive turns, Hail weather will transforms this field into a Snowy Mountain"
    ],
    :createdBy => {
      :note => "Created via field transformation or set by event"
    },
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Rock and Flying type attacks", "Thunder", "Eruption", "Avalanche", "Vital Throw", "Storm Throw", "Circle Throw", "Ominous Wind", "Razor Wind", "Icy Wind", "Silver Wind", "Fairy Wind", "Twister", "Special Flying Moves (additional x1.5 in Strong Winds)", "Gust (additional x1.5 in Strong Winds)"]
      },
      :durationChange => {
        "Tailwind" => "6 turns (creates Strong Winds)"
      },
      :special => [
        "Thunder never misses",
        "Nature Power becomes Rock Slide",
        "Camouflage changes the user's type to Rock",
        "Secret Power may flinch"
      ]
    },
    :abilityEffects => [
      "Activates Gale Wings during Strong Winds",
      "Pokemon with Long Reach: deal x1.5 damage",
      "Aerilate's base power boost becomes x1.5 (from x1.2)",
      "Mimicry: changes the user's type to Rock"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Sky Field" => ["Fly", "Bounce", "Heavenly Wing"],
        "Snowy Mountain" => ["Blizzard", "Subzero Slammer"],
        "Volcanic Top Field" => ["Lava Plume", "Magma Drift", "Eruption", "Inferno Overdrive"]
      }
    },
    :itemEffects => [
      "Telluric Seed: boosts Attack and lowers Accuracy"
    ]
  },

  ##############################
  # 28. Snowy Mountain
  ##############################
  28 => {
    :name => "Snowy Mountain",
    :abbr => "SM",
    :message => "The snow glows white on the mountain...",
    :passiveEffects => [
      "After three consecutive turns, Sunny weather will transforms this field into a Mountain",
      "Sunny Day, Drought, Hail and Snow Warning last for 8 turns"
    ],
    :createdBy => {
      :note => "Created via field transformation from Mountain"
    },
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Rock, Ice and Flying type attacks", "Powder Snow", "Avalanche", "Vital Throw", "Storm Throw", "Circle Throw", "Ominous Wind", "Razor Wind", "Silver Wind", "Fairy Wind", "Twister", "Special Flying Moves (additional x1.5 in Strong Winds)", "Gust (additional x1.5 in Strong Winds)"],
        2.0 => ["Icy Wind"]
      },
      :powerDecrease => {
        0.5 => ["Fire moves", "Scald", "Steam Eruption"]
      },
      :additionalDamageType => {
        "Ice" => ["Rock attacks"]
      },
      :durationChange => {
        "Tailwind" => "6 turns (creates Strong Winds)"
      },
      :special => [
        "Enables Aurora Veil",
        "Thunder never misses",
        "Nature Power becomes Avalanche",
        "Camouflage changes the user's type to Ice",
        "Secret Power may freeze"
      ]
    },
    :abilityEffects => [
      "Activates Ice Body and Snow Cloak",
      "Refrigerate's base power boost becomes x1.5 (from x1.2)",
      "Aerilate's base power boost becomes x1.5 (from x1.2)",
      "Activates Slush Rush",
      "Ice Scales: ignores the user's Ice type weaknesses",
      "Ball Fetch: gets Snowballs",
      "Pokemon with Long Reach: deal x1.5 damage",
      "Activates Gale Wings during Strong Winds",
      "Mimicry: changes the user's type to Ice"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Sky Field" => ["Fly", "Bounce", "Heavenly Wing"],
        "Mountain" => ["Heat Wave", "Flame Burst", "Lava Plume", "Searing Shot", "Fire Pledge", "Inferno Overdrive"],
        "Volcanic Top" => ["Eruption", "Magma Drift"]
      }
    },
    :itemEffects => [
      "Telluric Seed: boosts Sp.Atk and lowers Accuracy"
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
      "Normal type attacks hit Ghost and Dark types for super effective damage",
      "(Ghost-type) Curses are lifted after each turn"
    ],
    :createdBy => {
      :note => "Created via field transformation or set by event"
    },
    :moveEffects => {
      :powerBoost => {
        1.2 => ["Dragon and Psychic moves"],
        1.3 => ["Psystrike", "Aeroblast", "Origin Pulse", "Precipice Blades", "Dragon Ascent", "Doom Desire", "Mist Ball", "Luster Purge", "Psycho Boost", "Spacial Rend", "Roar of Time", "Crush Grip", "Secret Sword", "Relic Song", "Hyperspace Hole", "Land's Wrath", "Moongeist Beam", "Sunsteel Strike", "Prismatic Laser", "Fleur Cannon", "Genesis Supernova", "Behemoth Blade", "Behemoth Bash", "Eternabeam", "Dynamax Cannon", "Retribution"],
        1.5 => ["Fairy and special Normal moves", "Mystical Fire", "Magical Leaf", "Judgment", "Sacred Fire", "Ancient Power"]
      },
      :powerDecrease => {
        0.5 => ["Ghost and special Dark moves"]
      },
      :statEffectAmplified => ["Cosmic Power"],
      :special => [
        "Spirit Break deals super effective damage to Ghost types",
        "Life Dew's healing increases to 50%",
        "Wish restores 75% of the user's Max HP (from 50%)",
        "Miracle Eye additionally boosts SpAtk",
        "Nature Power becomes Judgment",
        "Camouflage changes the user's type to Normal",
        "Secret Power may lower SpAtk",
        "Nature's Madness deals 75% HP damage (from 50%)"
      ]
    },
    :abilityEffects => [
      "Justified's effect is doubled",
      "Cursed Body: has no effect",
      "Perish Body: has no effect",
      "Power Spot: increases partner's damage output by 1.5x",
      "Mimicry: changes the user's type to Normal",
      "RKS System's type becomes Dark at all times"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Cursed Field" => ["Curse (two uses)", "Ominous Wind (two uses)", "Phantom Force", "Shadow Force"]
      }
    },
    :itemEffects => [
      "Magical Seed: boosts Sp.Atk and applies Magic Coat to the user"
    ]
  },

  ##############################
  # 31. Fairy Tale Field
  ##############################
  31 => {
    :name => "Fairy Tale Field",
    :abbr => "FTF",
    :message => "Once upon a time...",
    :passiveEffects => [
      "Steel hits Dragon types super-effectively"
    ],
    :createdBy => {
      :note => "Created via field transformation or set by event"
    },
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Fairy and Steel type attacks", "Night Slash", "Leaf Blade", "Mystical Fire", "Ancient Power", "Relic Song", "Magical Leaf", "Psycho Cut", "Sparkling Aria", "Solar Blade", "Smart Strike", "Moongeist Beam", "Fleur Cannon", "Behemoth Bash", "Behemoth Blade", "Razor Shell"],
        2.0 => ["Dragon type attacks", "Draining Kiss", "Mist Ball"]
      },
      :additionalDamageType => {
        "Dragon" => ["Fire type attacks"],
        "Steel" => ["Fighting type attacks", "Cut", "Slash", "Sacred Sword", "Secret Sword"]
      },
      :statEffectAmplified => ["Acid Armor", "Swords Dance", "Noble Roar"],
      :special => [
        "Floral Healing heals 2/3s target's HP (from 1/2)",
        "Fire type attacks gain Dragon typing",
        "Fighting type attacks gain Steel typing",
        "Cut, Slash, Sacred Sword, Secret Sword become Steel type",
        "Crafty Shield and Flower Shield boost the user's Defense and Special Defense one stage",
        "King's Shield protects from all moves, attacking or otherwise",
        "King's Shield additionally lowers an attacker's Special Attack 2 stages on contact",
        "Sweet Kiss and Draining Kiss cure sleep",
        "Wish restores 75% of the user's Max HP (from 50%)",
        "Healing Wish boosts recipient's Attack and Special Attack",
        "Miracle Eye additionally boosts SpAtk",
        "Forest's Curse additionally Curses the target",
        "Strange Steam always confuses",
        "Nature Power becomes Secret Sword",
        "Camouflage changes the user's type to Fairy",
        "Secret Power may induce Sleep"
      ]
    },
    :abilityEffects => [
      "Soul Heart: additionally boosts Sp. Def on use",
      "Pokemon with Queenly Majesty: deal x1.5 damage",
      "Activates Marvel Scale",
      "Mimicry: changes the user's type to Fairy",
      "Steely Spirit: boost is now x2",
      "Stance Change: boost and lower Attack and Defense one stage when switching forms",
      "Battle Armor, Shell Armor: have their Defense boosted on switch-in",
      "Magic Guard, Magic Bounce, Mirror Armor, Pastel Veil: have their Special Defense boosted on switch-in",
      "Magician: has their Special Attack boosted on switch-in",
      "Dauntless Shield, Power of Alchemy: have their defenses boosted on switch-in",
      "Intrepid Sword: has their offenses boosted on switch-in"
    ],
    :itemEffects => [
      "Magical Seed: boosts Attack and applies King's Shield to the user"
    ]
  },

  ##############################
  # 32. Dragon's Den
  ##############################
  32 => {
    :name => "Dragon's Den",
    :abbr => "DD",
    :message => "If you wish to slay a dragon...",
    :passiveEffects => [
      "Weather and Terrain effects fail",
      "Dragon type Pokemon's Sp.Def increases x1.5",
      "Fly and Bounce each last only one turn"
    ],
    :createdBy => {
      :note => "Created via field transformation from Cave"
    },
    :moveEffects => {
      :powerBoost => {
        1.3 => ["Rock type attacks"],
        1.5 => ["Dragon type attacks", "Fire type attacks", "Magma Storm", "Mega Kick", "Stomping Tantrum", "Earth Power", "Diamond Storm", "Matrix Shot", "Shell Trap", "Power Gem", "Magma Drift", "Lava Plume", "Rock Climb (with Fire/Rock damage)", "Strength (with Fire/Rock damage)"],
        2.0 => ["Smack Down (with Fire damage)", "Thousand Arrow (with Fire damage)", "Pay Day", "Dragon Ascent", "Luster Purge", "Mist Ball"]
      },
      :powerDecrease => {
        0.5 => ["Water and Ice type attacks"]
      },
      :additionalDamageType => {
        "Fire" => ["Smack Down", "Thousand Arrow", "Earthquake", "Stealth Rocks"],
        "Fire/Rock" => ["Rock Climb", "Strength"]
      },
      :accuracyChange => {
        100 => ["Dragon Rush"]
      },
      :statEffectAmplified => ["Noble Roar", "Dragon Dance", "Coil"],
      :special => [
        "Stealth Rocks do Fire type damage",
        "Magma Storm deals 1/6 Max HP damage per turn (from 1/8)",
        "Nature Power becomes Dragon Pulse",
        "Camouflage changes the user's type to Dragon",
        "Secret Power may Burn"
      ]
    },
    :abilityEffects => [
      "Magma Armor, Shell Armor: have their defenses boosted on switch-in",
      "Shed Skin: activates at the end of every turn",
      "Berserk: boosts SpAtk by 2 stages",
      "Magma Armor: additionally protects from Fire Attacks",
      "Multiscale: additionally annulls user's Dragon type's weaknesses at all times",
      "Activates Marvel Scale"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Fairy Tale Field" => ["Mist Ball"]
      }
    },
    :itemEffects => [
      "Amulet Coin: prevents the user from being statused",
      "Elemental Seed: boosts Sp.Atk and applies Flash Fire boost to the user"
    ]
  },

  ##############################
  # 33. Flower Garden Field
  ##############################
  33 => {
    :name => "Flower Garden Field",
    :abbr => "FGF",
    :message => "Seeds line the field.",
    :passiveEffects => [
      "Starts at Stage 1 and increases to a maximum of Stage 5",
      "At Stages 3/4/5, Grass type Pokemon take damage reduced by x0.75/0.67/0.5"
    ],
    :createdBy => {
      :note => "Created via field transformation or set by event"
    },
    :moveEffects => {
      :powerBoost => {
        "Stage 2/3/4/5" => ["Grass type attacks x1.2/1.5/2/3"],
        "Stage 2/4" => ["Bug type attacks x1.5/2"],
        1.5 => ["Grav Apple", "Cut (at Stage 2+)", "Fire attacks (at Stage 3+)"],
        "Stage 3/4" => ["Petal Dance x1.2/1.5", "Petal Blizzard x1.2/1.5", "Fleur Cannon x1.2/1.5"]
      },
      :additionalDamageType => {
        "Grass" => ["Cut (at Stage 2+)"]
      },
      :accuracyChange => {
        100 => ["Sleep Power (Stage 2+)", "Stun Spore (Stage 2+)", "Poison Powder (Stage 2+)"]
      },
      :statEffectAmplified => ["Rototiller"],
      :special => [
        "Rototiller, Flower Shield, Rain Dance, Sunny Day, Growth, Ingrain, Grassy Terrain, Grassy Glide grow the field one stage",
        "Growth's effect increases (x2, x3) at stages (1, 3)",
        "Cut hits Grass types super-effectively at Stage 2+",
        "Rototiller additionally boosts user's Attack and Special Attack",
        "Flower Shield additionally boosts Sp. Def and user's defenses at Stage 2+",
        "Flower Shield's effect is doubled at Stage 3+",
        "Sweet Scent additionally lowers defenses at Stage 3+",
        "Petal Dance, Petal Blizzard, All Powder Moves target both opposing Pokemon at Stage 5",
        "Sweet Scent's effect increase x2/3 at Stages 4/5",
        "Ingrain's effect increases x2/4 at Stages 2/4",
        "Floral Healing's healing is boosted to 66% at Stage 3+",
        "Infestation deals 1/6 / 1/4 / 1/3 Max HP Damage per turn at Stages 3/4/5",
        "Nature Power becomes Petal Blizzard at Stage 5, Growth at all other stages",
        "Camouflage changes the user's type to Grass",
        "Secret Power may lower Evasion, and both defenses at Stage 3+, effect doubles at Stage 5",
        "Bloom Doom grows field by 1 stage",
        "Cut reduces field by one stage",
        "Acid Downpour reduces field to stage 1",
        "Heat Wave, Flame Burst, Lava Plume, Searing Shot, Fire Pledge, Inferno Overdrive reduce field by 2 stages"
      ]
    },
    :abilityEffects => [
      "Flower Gift, Flower Veil, Drought, Drizzle, Grassy Surge: grow the field one stage on activation",
      "Activates Flower Gift and Swarm",
      "Always activates Harvest, Leaf Guard and Grass Pelt at Stage 2+",
      "Pokemon with Ripen: increase the field stages by x2 when they do so",
      "Mimicry: changes the user's type to Grass",
      "Flower Veil: passively reduces damage x0.5 to user and allied Grass types at Stage 3+",
      "Chlorophyll: is activated at Stage 4+",
      "Swarm: increases Bug attacks' power by x2/3 at Stages 3/5",
      "Overgrow: activates at 66% HP/Any HP at Stages 2/3",
      "Overgrow: increases Grass attacks' power by x2/3 at Stages 4/5"
    ],
    :itemEffects => [
      "Synthetic Seed: boosts Sp.Def and applies Ingrain to the user"
    ]
  },

  ##############################
  # 34. Starlight Arena
  ##############################
  34 => {
    :name => "Starlight Arena",
    :abbr => "SA",
    :message => "Starlight fills the battlefield.",
    :passiveEffects => [
      "Temporarily annulled by all weather except Strong Winds"
    ],
    :createdBy => {
      :note => "Created via field transformation or set by event"
    },
    :moveEffects => {
      :powerBoost => {
        1.3 => ["Fairy type attacks", "Dark type attacks"],
        1.5 => ["Psychic type attacks", "Aurora Beam", "Signal Beam", "Flash Cannon", "Luster Purge", "Dazzling Gleam", "Mirror Shot", "Moonblast", "Technoblast", "Solar Beam", "Photon Geyser", "Prismatic Laser"],
        2.0 => ["Draco Meteor", "Meteor Mash", "Comet Punch", "Spacial Rend", "Swift", "Hyperspace Hole", "Hyperspace Fury", "Moongeist Beam", "Sunsteel Strike", "Black Hole Eclipse", "Meteor Assault", "Searing Sunraze Smash", "Menacing Moonraze Maelstrom", "Light that Burns the Sky"],
        4.0 => ["Doom Desire (with Fire damage)"]
      },
      :additionalDamageType => {
        "Fairy" => ["Dark type attacks", "Solar Beam", "Solar Blade"],
        "Fire" => ["Doom Desire"]
      },
      :statEffectAmplified => ["Cosmic Power", "Flash"],
      :durationChange => {
        "Trick Room, Magic Room and Wonder Room" => 8
      },
      :special => [
        "Enables Aurora Veil",
        "Meteor Assault has no charge up/recharge",
        "Wish restores 75% of the user's Max HP (from 50%)",
        "Healing Wish and Lunar Dance boost recipient's Attack and Special Attack",
        "Moonlight restores 75% of the user's Max HP",
        "Nature Power becomes Moonblast",
        "Camouflage changes the user's type to Dark",
        "Secret Power may lower Sp. Def"
      ]
    },
    :abilityEffects => [
      "Victory Star: additionally boosts user and allies' attacks x1.5",
      "Activates Marvel Scale",
      "Shadow Shield: Pokemon take x0.5 decreased damage",
      "Solar Idol: is activated",
      "Mirror Armor: protects the user's side from priority moves",
      "Mimicry: changes the user's type to Dark",
      "Illuminate: have their Special Attack boosted on switch-in",
      "Adaptability: copies Trace's effect"
    ],
    :itemEffects => [
      "Magical Seed: boosts Sp Atk and applies Lunar Dance to the user"
    ]
  },

  ##############################
  # 35. New World
  ##############################
  35 => {
    :name => "New World",
    :abbr => "NA",
    :message => "From darkness, from stardust, from memories of eons passed and visions yet to come...",
    :passiveEffects => [
      "Grounded Pokemon's Speed is halved",
      "Prevents all weather and generated Field Effects"
    ],
    :createdBy => {
      :note => "Created via field transformation or set by event"
    },
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Dark type attacks", "Mirror Shot", "Aurora Beam", "Signal Beam", "Dazzling Gleam", "Flash Cannon", "Psystrike", "Aeroblast", "Sacred Fire", "Mist Ball", "Luster Purge", "Origin Pulse", "Precipice Blades", "Dragon Ascent", "Psycho Boost", "Roar of Time", "Magma Storm", "Crush Grip", "Shadow Force", "Seed Flare", "Judgment", "Searing Shot", "V-Create", "Sacred Sword", "Secret Sword", "Fusion Bolt", "Fusion Flare", "Bolt Strike", "Blue Flare", "Glaciate", "Ice Burn", "Freeze Shock", "Relic Song", "Techno Blast", "Oblivion Wing", "Land's Wrath", "Thousand Arrow", "Thousand Waves", "Diamond Storm", "Steam Eruption", "Eruption", "Power Gem", "Earth Power", "Fleur Cannon", "Prismatic Laser", "Sunsteel Strike", "Spectral Thief", "Moongeist Beam", "Multiattack", "Continental Crush", "Genesis Supernova", "Soul-eating Seven Star Strike", "Core Enforcer"],
        2.0 => ["Vacuum Wave", "Draco Meteor", "Meteor Mash", "Moonblast", "Comet Punch", "Spacial Rend", "Swift", "Future Sight", "Ancient Power", "Hyperspace Hole", "Hyperspace Fury", "Searing Sunraze Smash", "Menacing Moonraze Maelstrom", "Light that Burns the Sky", "Retribution"],
        4.0 => ["Doom Desire (with Fire damage)", "Black Hole Eclipse"]
      },
      :additionalDamageType => {
        "Fire" => ["Doom Desire"]
      },
      :accuracyChange => {
        100 => ["Dark Void"]
      },
      :statEffectAmplified => ["Cosmic Power", "Flash"],
      :durationChange => {
        "Trick Room, Magic Room and Wonder Room" => 8
      },
      :special => [
        "Heart Swap additionally gains Pain Split's effect",
        "Lunar Dance boosts all of the recipient's stats",
        "Moonlight restores 75% of the user's Max HP",
        "Nature's Madness deals 75% HP damage (from 50%)",
        "Nature Power becomes Spacial Rend",
        "Camouflage changes the user's type to a random type",
        "Secret Power may lower all stats"
      ]
    },
    :abilityEffects => [
      "Shadow Shield: Pokemon take x0.5 decreased damage",
      "Multitype: randomly become a different type at the end of each turn",
      "Victory Star: additionally boosts user and allies' attacks x1.5",
      "Mimicry: changes the user's type to a random type",
      "Solar Idol: is activated",
      "RKS System: matches Multitype's effects, but is selected separately"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Starlight Arena" => ["Gravity (temporary)", "Geomancy"]
      }
    },
    :itemEffects => [
      "Magical Seed: boosts all stats and makes the user recharge"
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
      :moves => ["Topsy Turvy (unless user is holding an Everstone)"],
      :duration => 3
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
      "Priority attacks fail on grounded Pokemon"
    ],
    :createdBy => {
      :moves => ["Psychic Terrain", "Genesis Super Nova"],
      :abilities => ["Psychic Surge"],
      :duration => 5,
      :note => "Created on empty fields"
    },
    :overlayEffects => {
      :terrain => "Psychic Terrain",
      :effects => [
        "Psychic moves increase in base power x1.3",
        "Mystical Fire, Magical Leaf, Aura Sphere, Hex, Moonblast, Mind Blown increase in base power x1.3",
        "Anticipation boosts Sp.Atk on switch in",
        "Pure Power doubles Sp.Atk instead of Atk"
      ]
    },
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Psychic attacks", "Hex", "Magical Leaf", "Mystical Fire", "Moonblast", "Aura Sphere", "Mind Blown"]
      },
      :additionalDamageType => {
        "Psychic" => ["Strength", "Ancient Power", "Dragon Pulse", "Water Pulse"]
      },
      :accuracyChange => {
        90 => ["Hypnosis"]
      },
      :statEffectAmplified => ["Nasty Plot", "Calm Mind", "Cosmic Power", "Meditate", "Kinesis"],
      :durationChange => {
        "Gravity, Trick Room, Magic Room and Wonder Room" => 8
      },
      :special => [
        "Secret Power may confuse its target",
        "Nature Power becomes Psychic",
        "Camouflage becomes Psychic",
        "Psych Up, Meditate, Mind Reader and Miracle Eye additionally boost Sp.Atk two stages on use",
        "Kinesis additionally lowers its target's Attack and Sp.Atk two stages",
        "Telekinesis additionally lowers its target's Defense and Sp.Def two stages",
        "Shattered Psyche additionally confuses its target"
      ]
    },
    :abilityEffects => [
      "Pure Power: doubles Sp.Atk instead of Atk",
      "Anticipation and Forewarn: boost Sp.Atk on switch in",
      "Zen Mode: is activated",
      "Power Spot: increases partner's damage output by 1.5x (from 1.3x)",
      "Magician: additionally lowers the accuracy of status moves targeted to the user to 50%",
      "Telepathy: Pokemon's Speed doubles",
      "Mimicry: changes the user's type to Psychic"
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
      "Pokemon gradually lose health while asleep if they are not Ghost-type"
    ],
    :createdBy => {
      :note => "Created via field transformation from Blessed Field"
    },
    :moveEffects => {
      :powerBoost => {
        1.3 => ["Dark-type moves", "Flame Burst (becomes Ghost)", "Inferno (becomes Ghost)", "Flame Charge (becomes Ghost)", "Fire Spin (becomes Ghost)"],
        1.5 => ["Ghost-type moves", "Night Shade"]
      },
      :additionalDamageType => {
        "Ghost" => ["Flame Burst", "Inferno", "Flame Charge", "Fire Spin"]
      },
      :accuracyChange => {
        90 => ["Will-o-Wisp", "Hypnosis", "Inferno"]
      },
      :special => [
        "Ghost and Dark-types deal neutral damage to each other",
        "Nightmare inflicts more damage",
        "Cursed Body always activates upon fainting",
        "Spite depletes two more PP than usual",
        "Ominous Wind has a 20% chance of raising all stats",
        "Curse, when used by a Ghost-type, uses only 25% of the user's HP",
        "Phantom Force and Shadow Force become single turn moves",
        "Mean Look, Fire Spin, Ominous Wind, Inferno target both opponents",
        "Fire Spin deals 1/6 Max HP damage per turn (from 1/8)",
        "Spirit Break deals super effective damage to Ghost types",
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
      "Pokemon that gain Wandering Spirit: lose speed every turn",
      "Power Spot: damage increase is 1.5x",
      "Rattled: boosts the user's Speed upon switch-in"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Blessed Field" => ["Judgement", "Sacred Fire", "Purify", "Origin Pulse", "Retribution"]
      },
      :disables => ["Flash", "Dazzling Gleam (temporarily nullify)"]
    },
    :itemEffects => [
      "Magical Seed: raises Defense and Special Defense and burns the user"
    ]
  },

  ##############################
  # 41. Corrupted Cave
  ##############################
  41 => {
    :name => "Corrupted Cave",
    :abbr => "CC",
    :message => "Corruption seeps from every crevice!",
    :passiveEffects => [
      "All grounded non-Poison-types are poisoned at the end of turn (unless they have Wonder Skin, Immunity, or Pastel Veil)",
      "Pokemon with Grass Pelt, Leaf Guard, Flower Veil are hurt each round"
    ],
    :createdBy => {
      :note => "Created via field transformation from Cave"
    },
    :moveEffects => {
      :powerBoost => {
        1.2 => ["Rock- and Grass-type moves"],
        1.5 => ["Poison-type moves", "Seed Flare", "Apple Acid"]
      },
      :powerDecrease => {
        0.5 => ["Non-contact Flying moves"]
      },
      :additionalDamageType => {
        "Poison" => ["Ground-type moves", "Rock Slide", "Smack Down", "Stone Edge", "Rock Tomb", "Diamond Storm", "Apple Acid", "Stealth Rock"],
        "Rock" => ["Sludge Wave", "Gunk Shot"]
      },
      :special => [
        "Tar Shot additionally poisons",
        "Toxic Thread inflicts badly poisoned status",
        "Nature Power becomes Gunk Shot",
        "Camouflage changes the user's type to Poison",
        "Secret Power inflicts poison",
        "Ingrain damages the user, unless the user is Poison- Rock- or Steel-type"
      ]
    },
    :abilityEffects => [
      "Pokemon with Poison Heal: are healed each round",
      "Poison Touch, Poison Point: have a doubled activation rate",
      "Toxic Boost: boost is doubled from 50% to 100%",
      "Mimicry: changes the user's type to Poison",
      "Corrosion: boosts the power of all moves by 50%",
      "Dry Skin: heals the user if they are Poison-type, otherwise damages the user",
      "Liquid Ooze: damage inflicted is doubled"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Cave" => ["Seed Flare", "Purify", "Solar Beam", "Solar Blade"]
      },
      :terminates => ["Heat Wave (combusts field, 50% max HP to all)", "Blast Burn (combusts field, 50% max HP to all)", "Eruption (combusts field, 50% max HP to all)", "Lava Plume (combusts field, 50% max HP to all)", "Inferno Overdrive (combusts field, 50% max HP to all)"]
    },
    :itemEffects => [
      "Black Sludge: effects are doubled",
      "Synthetic Seed: increases Defense by two stages and applies Poison status to the user"
    ]
  },

  ##############################
  # 42. Bewitched Woods
  ##############################
  42 => {
    :name => "Bewitched Woods",
    :abbr => "BW",
    :message => "Double, double toil and trouble",
    :passiveEffects => [
      "Pokemon sleeping in the fairy rings take damage equal to 1/16th of max HP",
      "Grounded Grass Pokemon restore 1/16th Max HP each turn"
    ],
    :createdBy => {
      :note => "Created via field transformation or set by event"
    },
    :moveEffects => {
      :powerBoost => {
        1.3 => ["Fairy-type moves", "Dark-type moves", "Magical Leaf", "Dark Pulse", "Night Daze", "Moonblast", "Dream Eater", "Night Slash"],
        1.5 => ["Grass-type moves", "Hex", "Mystical Fire", "Spirit Break"]
      },
      :accuracyChange => {
        80 => ["Sleep Powder", "Grass Whistle", "Hypnosis"],
        90 => ["Poison Powder", "Stun Spore", "Will-O-Wisp"]
      },
      :durationChange => {
        "Torment" => "8 turns (traps target)"
      },
      :special => [
        "Grass-type attacks now hit Steel-type Pokemon super effectively",
        "Poison-, Fairy-, and Dark-types now hit each other neutrally",
        "Magic Powder puts the target to sleep",
        "Damage taken from Nightmare is doubled",
        "Strength Sap now also lowers Special Attack",
        "Moonlight restores 75% of the user's Max HP",
        "Forest's Curse additionally curses the target",
        "Nature Power becomes Dazzling Gleam",
        "Camouflage changes the user's type to Fairy",
        "Secret Power may randomly inflict Sleep, Poison, or Paralysis"
      ]
    },
    :abilityEffects => [
      "Prankster: affects Dark-type Pokémon",
      "Effect Spore: has a doubled activation rate",
      "Natural Cure: heals status at the end of the turn",
      "Pastel Veil and Aroma Veil: remove the user's Fairy-type weaknesses",
      "Power Spot: damage increase is 1.5x",
      "Mimicry: changes the user's type to Fairy"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Forest Field" => ["Purify", "Geomancy"]
      }
    },
    :itemEffects => [
      "Magical Seed: raises Special Defense and applies ingrain to the user"
    ]
  },

  ##############################
  # 43. Sky Field
  ##############################
  43 => {
    :name => "Sky Field",
    :abbr => "SKF",
    :message => "The sky is filled with clouds.",
    :passiveEffects => [
      "All weather effects and Tailwind will last 8 turns"
    ],
    :createdBy => {
      :note => "Created via field transformation from Mountain or Snowy Mountain"
    },
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Flying-type moves", "Icy Wind", "Ominous Wind", "Silver Wind", "Razor Wind", "Fairy Wind", "Aeroblast", "Sky Uppercut", "Flying Press", "Thundershock", "Thunderbolt", "Thunder", "Steel Wing", "Twister", "Grav Apple", "Dragon Ascent", "Heat Wave"]
      },
      :additionalDamageType => {
        "Flying" => ["Dive", "Twister"]
      },
      :fail => ["Earthquake", "Magnitude", "Bulldoze", "Rototiller", "Dig", "Spikes", "Toxic Spikes", "Sticky Webs", "Ingrain"],
      :special => [
        "Tailwind creates Strong Winds",
        "Razor Wind, Sky Attack, Bounce, Fly will be used immediately, rather than charging up",
        "Thunder and Hurricane never miss",
        "Flying Press's Flying type damage does not account for resistances",
        "Weather Ball becomes Flying-type during Strong Winds",
        "Nature Power becomes Sky Attack",
        "Camouflage changes the user's type to Flying",
        "Secret Power may Confuse"
      ]
    },
    :abilityEffects => [
      "Big Pecks: additionally boosts Defense upon switch-in",
      "Gale Wings: is active regardless of HP",
      "Early Bird: makes the user immune to Sleep",
      "Mimicry: changes the user's type to Flying",
      "Aerilate's base power boost becomes x1.5 (from x1.2)",
      "Levitate: additionally boosts Speed upon switch-in",
      "Cloud Nine: removes weather"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Mountain Field" => ["Grav Apple (two uses)", "Smack Down (two uses)", "Gravity (one use)", "Thousand Arrows (one use)"]
      }
    },
    :itemEffects => [
      "Elemental Seed: lowers Defense and Special Defense and applies Tailwind"
    ]
  },

  ##############################
  # 44. Infernal Field
  ##############################
  44 => {
    :name => "Infernal Field",
    :abbr => "HEF",
    :message => "The souls of the damned burn on.",
    :passiveEffects => [
      "Bad Dreams and Nightmare's effects are doubled and trap the target",
      "Rain and Hail are terminated immediately"
    ],
    :createdBy => {
      :note => "Created via field transformation or set by event"
    },
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Fire and Dark type moves", "Blast Burn", "Earth Power", "Inferno", "Inferno Overdrive", "Precipice Blades"],
        2.0 => ["Punishment", "Smog", "Dream Eater"]
      },
      :powerDecrease => {
        0.5 => ["Fairy and Water type moves (excluding Spirit Break)"]
      },
      :additionalDamageType => {
        "Dark" => ["Aura Sphere", "Frustration", "Spirit Break"],
        "Fire" => ["Ground, Steel and Rock moves", "Stealth Rock"]
      },
      :accuracyChange => {
        100 => ["Will-O-Wisp", "Dark Void", "Inferno"]
      },
      :statEffectAmplified => ["Nasty Plot"],
      :special => [
        "Fire moves become super effective against Ghost types",
        "Torment causes passive damage, dealing 1/8th HP to inflicted targets at the end of the turn",
        "Burn Up targets have their type restored at the end of the turn",
        "Activates Hex",
        "Nightmare can be used immediately",
        "Camouflage changes the user's type to Fire",
        "Secret Power may Burn",
        "Nature Power becomes Punishment"
      ]
    },
    :abilityEffects => [
      "Activates Blaze, Flash Fire, Flare Boost",
      "Magma Armor, Flame Body, Desolate Land: get their defenses boosted upon entry",
      "Magma Armor: grants immunity to Fire-type moves",
      "Pastel Veil: fails",
      "Perish Body: traps the opponent upon triggering and has a countdown of 1",
      "Ice Face: melts on entry",
      "Mimicry: turns the user into a Fire type",
      "Steam Engine: raises speed at the end of every turn by 1 stage"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Volcanic Field" => ["Judgement", "Origin Pulse", "Purify"],
        "Frozen Dimensional Field" => ["Glaciate"]
      }
    },
    :itemEffects => [
      "Elemental Seed: boosts Attack and Special Attack and traps the user"
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
    :createdBy => {
      :note => "Created via field transformation or set by event"
    },
    :moveEffects => {
      :powerBoost => {
        1.3 => ["Water- and Ground-type moves", "Scald", "Surf", "Muddy Water", "Steam Eruption", "Ominous Wind (with Ground damage)", "Razor Wind (with Ground damage)", "Silver Wind (with Ground damage)", "Icy Wind (with Ground damage)", "Fairy Wind (with Ground damage)", "Twister (with Ground damage)", "Gust (with Ground damage)"],
        1.5 => ["Electric-type moves", "Sand Tomb", "Whirlpool", "Burn Up", "Thousand Waves", "Scorching Sands", "Razor Shell"]
      },
      :additionalDamageType => {
        "Ground" => ["Ominous Wind", "Razor Wind", "Silver Wind", "Icy Wind", "Fairy Wind", "Twister", "Gust"]
      },
      :statEffectAmplified => ["Sand Attack"],
      :durationChange => {
        "Sand Tomb and Whirlpool" => "8 turns",
        "Arenite Wall" => "8 turns (can be set up without sandstorm)"
      },
      :special => [
        "Shore Up restores 75% of the user's Max HP",
        "Nature Power becomes Scorching Sands",
        "Camouflage changes the user's type to Ground",
        "Secret Power may lower Accuracy"
      ]
    },
    :abilityEffects => [
      "Activates Sand Force, Sand Veil, Sand Rush, Swift Swim, Hydration",
      "Sand Spit: additionally lowers the opposing Pokemon's Accuracy",
      "Water Compaction: sharply raises Special Defense upon activation",
      "Dry Skin: Pokemon lose 1/16th Max HP at the end of each turn",
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
  # 46. Chargestone Cave
  ##############################
  46 => {
    :name => "Chargestone Cave",
    :abbr => "HC",
    :message => "Brimming with power!",
    :passiveEffects => [
      "Rock- and Electric-type Pokemon levitate",
      "Punching moves deal additional Rock/Electric damage at end of turn to all Pokemon unless they are Rock- or Electric-type"
    ],
    :createdBy => {
      :note => "Created via field transformation or set by event"
    },
    :moveEffects => {
      :powerBoost => {
        1.3 => ["Rock-type moves", "Electric-type moves", "Special Flying-type moves (gain Electric-type)", "Bullet Punch", "Comet Punch", "Dizzy Punch", "Double Iron Bash", "Drain Punch", "Dynamic Punch", "Fire Punch", "Focus Punch", "Hammer Arm", "Ice Hammer", "Ice Punch", "Mach Punch", "Mega Punch", "Meteor Mash", "Plasma Fists", "Power-Up Punch", "Shadow Punch", "Sky Uppercut", "Thunder Punch", "Accelerock", "Magnet Bomb", "Strength", "Rock Smash", "Headbutt", "Zen Headbutt", "Head Smash", "Heavy Slam", "Body Slam", "Slam", "Giga Impact", "Dragon Rush", "Wood Hammer", "Dragon Hammer"]
      },
      :additionalDamageType => {
        "Electric" => ["Special Flying-type moves"],
        "Rock/Electric" => ["Stealth Rock", "All punching and bashing moves listed above"]
      },
      :special => [
        "Rock-type moves have a 20% chance to paralyze",
        "Magnet Rise sharply raises Speed",
        "Charge additionally raises Defense",
        "Magnetic Flux affects all allied Pokemon",
        "Nature Power becomes Magnetic Flux",
        "Camouflage changes the user's type to Electric",
        "Secret Power may deal additional Rock/Electric damage to all Pokemon unless they are Rock- or Electric-type"
      ]
    },
    :abilityEffects => [
      "Lightning Rod: raises Special Attack",
      "Motor Drive: raises Speed",
      "Volt Absorb: restores 1/16th Max HP at the end of each turn",
      "Plus and Minus: are activated",
      "Magnet Pull: additionally traps Rock- and Electric-type Pokemon",
      "Solid Rock: grants Electric-type resistances",
      "Rock Head: Pokemon have a 20% chance to paralyze with all contact moves",
      "Galvanize's base power boost becomes x1.5",
      "Power Spot's boost becomes x1.5",
      "Mimicry: changes the user's type to Electric"
    ],
    :fieldTransformations => {
      :transformsTo => {
        "Cave" => ["Tectonic Rage", "Mud Sport (temporarily)"]
      }
    },
    :itemEffects => [
      "Telluric Seed: raises Defense and Special Defense and paralyzes the holder"
    ]
  },

  ##############################
  # 47. Cavern Nest
  ##############################
  47 => {
    :name => "Cavern Nest",
    :abbr => "CN",
    :message => "Skittering legs and many eyes surround you.",
    :passiveEffects => [
      "Bug-type moves are super effective against Rock- and Ground-types",
      "Bug-type Pokemon are not affected by Stealth Rocks"
    ],
    :createdBy => {
      :note => "Created via field transformation or set by event"
    },
    :moveEffects => {
      :powerBoost => {
        1.3 => ["Rock-type moves", "Biting and Sound moves"],
        1.5 => ["Bug-type moves", "Attack Order", "Infestation", "Belch", "Spit Up", "Beat Up"]
      },
      :powerDecrease => {
        0.5 => ["Special Flying-type moves"]
      },
      :accuracyChange => {
        80 => ["Poison Powder (becomes spread move)", "Sleep Powder (becomes spread move)", "Stun Spore (becomes spread move)"]
      },
      :statEffectAmplified => ["Growth", "Defend Order", "Stockpile"],
      :durationChange => {
        "Infestation" => "8 turns"
      },
      :special => [
        "Stockpile can increase up to six stages",
        "Heal Order heals 66% max HP",
        "Swallow heals all status conditions",
        "Sticky Web's stat changes are amplified and affect airborne targets",
        "Strength Sap heals 30% more HP",
        "Sweet Scent makes all active non Bug-type Pokémon drowsy",
        "Attract prevents the target from switching out",
        "Nature Power becomes Infestation",
        "Camouflage changes the user's type to Bug",
        "Secret Power may poison"
      ]
    },
    :abilityEffects => [
      "Intimidate: also lowers Special Attack",
      "Swarm: is activated",
      "Overcoat: has the same effect as Bulletproof",
      "Shield Dust: protects the user from all status",
      "Solid Rock and Sturdy: Pokemon resist Bug-, Fighting-, and Ground-type attacks",
      "Rattled: raises Speed on entry",
      "Rivalry: raises Attack on entry",
      "Mimicry: changes the user's type to Bug"
    ],
    :itemEffects => [
      "Telluric Seed: boosts Defense and taunts the opponent"
    ]
  },

  ##############################
  # 48. Cloud Forest
  ##############################
  48 => {
    :name => "Cloud Forest",
    :abbr => "CF",
    :message => "Where earth and sky meet.",
    :passiveEffects => [
      "Hail and Rain last for 8 turns",
      "Misty Terrain lasts for 8 turns",
      "Grounded Pokemon have reduced Speed"
    ],
    :createdBy => {
      :note => "Created via field transformation or set by event"
    },
    :moveEffects => {
      :powerBoost => {
        1.2 => ["Grass- and Water-type moves"],
        1.3 => ["Flying-type moves", "Thundershock", "Thunderbolt", "Thunder", "Weather Ball", "Origin Pulse", "Strange Steam", "Steam Eruption"],
        1.5 => ["Icy Wind", "Ominous Wind", "Silver Wind", "Razor Wind", "Fairy Wind", "Aeroblast", "Hurricane", "Twister", "Heat Wave", "Clear Smog", "Blizzard"]
      },
      :durationChange => {
        "Tailwind" => "8 turns (creates Strong Winds)"
      },
      :special => [
        "Razor Wind, Sky Attack, Fly will be used immediately, rather than charging up",
        "Thunder and Hurricane never miss",
        "Ingrained Pokemon resist Flying- and Ground-type moves",
        "Growth has amplified stat changes",
        "Defog raises the Accuracy of all Pokemon on the field",
        "Roost boosts Defenses until an attacking move is used",
        "Nature Power becomes Weather Ball",
        "Camouflage changes the user's type to Flying",
        "Secret Power may raise the user's Accuracy"
      ]
    },
    :abilityEffects => [
      "Leaf Guard, Grass Pelt, Cloud Nine, Forecast, Overcoat, Water Veil: raise Defenses on entry",
      "Aerilate's base power boost becomes x1.5",
      "Early Bird: has Gale Wings's effect",
      "Forecast: raises Speed on entry",
      "Gale Wings: is always activated during Strong Winds",
      "Keen Eye and Long Reach: Pokemon ignore Accuracy checks",
      "Serene Grace: prevents flinching or effects that limit move choice",
      "Hydration and Sap Sipper: restore 1/8th max HP each turn",
      "Mimicry: changes the user's type to Flying"
    ],
    :itemEffects => [
      "Telluric Seed: boosts Speed and makes the holder airborne"
    ]
  },

  ##############################
  # 49. Boxing Ring
  ##############################
  49 => {
    :name => "Boxing Ring",
    :abbr => "BR",
    :message => "Fight to the faint!",
    :passiveEffects => [
      "Pokemon can score points during the match, every 10 points, their attack becomes a combo and hits an additional time",
      "One Point: Using attacking moves, making target flinch, inflicting status condition, hitting through confusion",
      "Two Points: dealing over 50% max HP with one attack, making target faint, dodging/protecting from attack",
      "Three Points: One-Hit KOing opponent, living attack at 10% max HP or less, getting a critical hit",
      "Damage taken from recoil is reduced by 0.2x"
    ],
    :createdBy => {
      :note => "Created via field transformation or set by event"
    },
    :moveEffects => {
      :powerBoost => {
        1.3 => ["Physical Dark-type moves", "Physical Normal-type moves (become part Fighting)", "Submission", "Strength", "Retaliate", "Thrash", "Outrage", "Vital Throw", "Storm Throw", "Circle Throw", "Rage", "Body Slam", "Heavy Slam", "Body Press", "Ice Punch", "Thunder Punch", "Fire Punch", "Shadow Punch", "Bullet Punch", "Ice Hammer", "Dragon Hammer", "Double Iron Bash", "Mega Punch", "Triple Axel", "Blaze Kick", "Trop Kick", "Mega Kick", "Pound", "Smack Down", "Dragon Rush", "Play Rough", "Beat Up", "Foul Play", "Meteor Mash", "Skull Bash", "Flying Press", "Darkest Lariat", "All-Out Pummeling", "Malicious Moonsault"],
        1.5 => ["Physical Fighting-type moves"]
      },
      :additionalDamageType => {
        "Fighting" => ["Physical Normal-type moves"]
      },
      :statEffectAmplified => ["Leer", "Growl", "Double Team", "Defense Curl", "Agility"],
      :special => [
        "Mirror Move raises the user's speed by one stage when used",
        "Obstruct lowers speed in addition to its normal effect",
        "Substitute blocks critical hits",
        "Camouflage makes the user a Fighting-type",
        "Secret Power may give the user a point",
        "Nature Power becomes Submission"
      ]
    },
    :abilityEffects => [
      "Pressure and Moxie's effects are doubled",
      "Intimidate: also lowers Special Attack",
      "Arena Trap: affects non-grounded and Ghost-type pokémon",
      "Defiant: boosts Defense by two stages upon activation",
      "Competitive: boosts Special Defense by two stages upon activation",
      "Justified: raises Special Attack upon activation",
      "Anger Point: activates whenever hit by a super-effective move",
      "Rattled: is triggered by all contact moves",
      "Rivalry's boost is increased to x1.5 and activated regardless of gender",
      "Guts: decreases damage taken by x0.2",
      "Iron Fist: boosts affected moves by x1.5 instead",
      "No Guard: raises Speed and critical hit rate but lowers Defense and Special Defense",
      "Hustle: raises Speed",
      "Mimicry: makes the user a Fighting-type"
    ],
    :itemEffects => [
      "Synthetic Seed: increases critical hit rate and Speed and traps the user"
    ]
  },

  ##############################
  # 50. Library Field
  ##############################
  50 => {
    :name => "Library Field",
    :abbr => "LF",
    :message => "Pages flutter around!",
    :passiveEffects => [
      "Silenced Pokemon have their Speed reduced to x0.5",
      "Confused Pokemon take x2 damage"
    ],
    :createdBy => {
      :note => "Created via field transformation or set by event"
    },
    :moveEffects => {
      :powerBoost => {
        1.3 => ["Fire-type moves", "Special Psychic-type moves", "Slashing and Wind moves", "Focus Punch", "Focus Blast", "Return", "Frustration", "Perforate", "Fire Spin (becomes spread move)", "Whirlpool (becomes spread move)"],
        1.5 => ["Smart Strike", "Ancient Power", "Barrage", "Headbutt", "Zen Headbutt", "Iron Head", "Head Smash", "Head Charge", "Skull Bash", "Mind Blown"]
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
        "Nature Power becomes Calm Mind",
        "Camouflage changes the user's type to Normal",
        "Secret Power may silence"
      ]
    },
    :abilityEffects => [
      "Pressure and Moxie's effects are doubled",
      "Intimidate: also lowers Special Attack",
      "Arena Trap: affects non-grounded and Ghost-type pokémon",
      "Defiant: boosts Defense by two stages upon activation",
      "Competitive: boosts Special Defense by two stages upon activation",
      "Justified: raises Special Attack upon activation",
      "Anger Point: activates whenever hit by a super-effective move",
      "Rattled: is triggered by all contact moves",
      "Rivalry's boost is increased to x1.5 and activated regardless of gender",
      "Guts: decreases damage taken by x0.2",
      "Iron Fist: boosts affected moves by x1.5 instead",
      "No Guard: raises Speed and critical hit rate but lowers Defense and Special Defense",
      "Hustle: raises Speed",
      "Mimicry: makes the user a Fighting-type"
    ],
    :itemEffects => [
      "Synthetic Seed: increases critical hit rate and Speed and traps the user"
    ]
  }

