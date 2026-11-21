# Field Effect Information Database
# Data structure for all field effects and their mechanics
# NOTE: Transforming or destroying any field effect grants a 1.3x power bonus

#pk code
FIELDEFFECTDATA = {
  #----------------- 1. Electric Terrain [ET] -------------------#
  1 => {
    :name => "Electric Terrain",
    :abbr => "ET",
    :message => "The field is hyper-charged!",

    # (Overlay):
    :overlayEffects => {
      :terrain => "Electric Terrain",
      :effects => [
        "Damage from recoil and crashing is halved.",
        "On other fields, Electric attacks from grounded users are boosted by 1.5x.",
        "Explosive and Bomb moves deal 1.3x damage.",
        "Electric Terrain makes boosts roll their maximum on Short-Circuit Field.",
        "Galvanize's damage multiplier is 1.5x."
      ]
    },

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Electric moves from grounded users without the Electric Terrain overlay", "Explosive moves", "Bomb moves"]
      },
      :additionalDamageType => {
        "Electric" => ["Explosion", "Self-Destruct", "Surf", "Muddy Water", "Hurricane", "Smack Down", "Thousand Arrows", "Hydro Vortex"]
      },
      :fail => ["Focus Punch"],
      :statChanges => [
        "Charge sharply raises the user's Special Defense.",
        "Eerie Impulse drastically lowers the target's Special Attack."
      ],
      :durationChange => {
        "Magnet Rise" => 8
      },
      :special => [
        "Damage from recoil and crashing is nullified.",
        "Nature Power becomes Thunderbolt.",
        "Camouflage makes the user Electric-type.",
        "Secret Power may paralyze the target."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Galvanize raises its damage multiplier from 1.2x to 1.5x.",
      "Surge Surfer is activated.",
      "Gulp Missile always picks up Pikachu.",
      "Mimicry makes the user Electric-type."
    ],

    # (The following items are affected by this field):
    :itemEffects => [
      "Elemental Seed raises Defense and applies Charge to the holder."
    ]
  },

  #----------------- 2. Grassy Terrain [GT] -------------------#
  2 => {
    :name => "Grassy Terrain",
    :abbr => "GT",
    :message => "The field is in full bloom.",

    # (Overlay):
    :overlayEffects => {
      :terrain => "Grassy Terrain",
      :effects => [
        "On other fields, Grass moves from grounded users normally deal 1.3x damage.",
        "Muddy Water, Surf, Earthquake, Magnitude, and Bulldoze deal half damage."
      ]
    },

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Grass moves from grounded users without the Grassy Terrain overlay", "Fire moves against grounded targets", "Wind moves"]
      },
      :powerDecrease => {
        0.5 => ["Muddy Water", "Surf", "Earthquake", "Magnitude", "Bulldoze"]
      },
      :statChanges => [
        "Growth sharply raises the user's Attack and Special Attack.",
        "Coil sharply raises the user's Attack, Defense, and Accuracy."
      ],
      :special => [
        "Floral Healing restores two-thirds of the target's maximum HP.",
        "Sludge Wave and Acid Downpour deal 1.3x damage.",
        "Nature Power becomes Energy Ball.",
        "Snap Trap deals 1/6 Max HP damage per turn (from 1/8).",
        "Camouflage makes the user Grass-type.",
        "Secret Power may make the target drowsy.",
        "Nature's Madness deals 75% HP damage (from 50%)."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Mimicry makes the user Grass-type.",
      "Cotton Down sharply lowers Speed."
    ],

    # (The following items are affected by this field):
    :itemEffects => [
      "Elemental Seed raises Defense and applies Ingrain to the holder."
    ],

    # (Other effects):
    :passiveEffects => [
      "Grounded Pokémon restore 1/16 of their maximum HP at the end of the turn."
    ]
  },

  #----------------- 3. Misty Terrain [MT] -------------------#
  3 => {
    :name => "Misty Terrain",
    :abbr => "MT",
    :message => "Mist settles on the field.",

    # (Overlay):
    :overlayEffects => {
      :terrain => "Misty Terrain",
      :effects => [
        "On other fields, Fairy attacks get a separate boost from the overlay. Grounded users also get a 1.3x power multiplier.",
        "Aura/Pulse moves deal 1.3x damage."
      ]
    },

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Fairy attacks without the Misty Terrain overlay", "Aura and pulse moves", "Mist Ball", "Steam Eruption", "Strange Steam", "Clear Smog", "Smog"],
        1.3 => ["Hidden Power (all types)", "Secret Power", "Ancient Power", "Stored Power"]
      },
      :powerDecrease => {
        0.5 => ["Dragon-type moves"]
      },
      :special => [
        "Aromatic Mist raises Defense and Special Defense for the user and its targeted ally. Mist and Haze raise both defenses for the user and its allies. Haze resets stat changes before raising both defenses.",
        "Sweet Scent sharply lowers Evasion and lowers Defense and Special Defense.",
        "Aqua Ring restores 1/8 Max HP each turn.",
        "Aurora Veil can be used on this field.",
        "Nature Power becomes Mist Ball.",
        "Camouflage makes the user Fairy-type.",
        "Secret Power may lower Special Attack."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Marvel Scale is activated.",
      "Soul Heart also raises Special Defense when it activates.",
      "Dry Skin restores 1/16 of the holder's maximum HP each turn.",
      "Pixilate's base power multiplier becomes 1.5x.",
      "Refrigerate's base power multiplier becomes 1.5x.",
      "Pastel Veil halves damage taken from Poison-type attacks for user and allies.",
      "Mimicry makes the user Fairy-type."
    ],

    # (The following items are affected by this field):
    :itemEffects => [
      "Elemental Seed raises Special Defense, fully heals the holder, and cures its status."
    ],

    # (Other effects):
    :passiveEffects => [
      "Misty Terrain protects grounded Pokémon from new major status conditions.",
      "Hail and Rain last for 8 turns."
    ],

    # (Field transformations):
    :fieldTransformations => {
      :terminates => ["Whirlwind", "Gust", "Razor Wind", "Hurricane", "Defog", "Twister", "Tailwind"]
    }
  },

  #----------------- 4. Dark Crystal Cavern [DCC] -------------------#
  4 => {
    :name => "Dark Crystal Cavern",
    :abbr => "DCC",
    :message => "Darkness is gathering...",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Dark Pulse", "Night Daze", "Night Slash", "Shadow Ball", "Shadow Claw",
                "Shadow Force", "Shadow Sneak", "Shadow Punch", "Aurora Beam", "Signal Beam",
                "Flash Cannon", "Luster Purge", "Dazzling Gleam", "Mirror Shot", "Doom Desire",
                "Techno Blast", "Power Gem", "Moongeist Beam", "Shadow Bone",
                "Black Hole Eclipse", "Menacing Moonraze Maelstrom"],
        2.0 => ["Prismatic Laser"]
      },
      :fail => ["Solar Beam", "Solar Blade"],
      :special => [
        "Aurora Veil can be used on this field.",
        "Earthquake, Bulldoze, Magnitude, and Tectonic Rage deal 1.3x damage.",
        "Moonlight restores 75% of Max HP.",
        "Synthesis and Morning Sun restore 25% of Max HP.",
        "Nature Power becomes Dark Pulse.",
        "Camouflage makes the user Dark-type.",
        "Secret Power may lower Accuracy."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Mimicry makes the user Dark-type."
    ],

    # (The following items are affected by this field):
    :itemEffects => [
      "Magical Seed raises Special Defense and applies Magic Coat to the holder."
    ],

    # (Field transformations):
    :fieldTransformations => {
      :transformsTo => {
        "Crystal Cavern" => ["Sunny weather (temporary)"],
        "Cave" => ["Earthquake (2 uses)", "Bulldoze (2 uses)", "Magnitude (2 uses)", "Tectonic Rage (2 uses)"]
      }
    }
  },

  #----------------- 5. Chess Board [CB] -------------------#
  5 => {
    :name => "Chess Board",
    :abbr => "CB",
    :message => "Opening variation set.",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Strength", "Ancient Power", "Continental Crush", "Psychic", "Rock Throw", "Feint", "Feint Attack", "Fake Out", "Sucker Punch", "Gilded Arrow"],
        2.0 => ["Barrage"]
      },
      :additionalDamageType => {
        "Rock" => ["Strength", "Psychic", "Barrage"]
      },
      :statChanges => [
        "Calm Mind sharply raises the user's Special Attack and Special Defense.",
        "Nasty Plot drastically raises the user's Special Attack."
      ],
      :special => [
        "The chess-piece attacks deal half damage to Adaptability, Anticipation, Synchronize, or Telepathy targets.",
        "Chess-piece attacks deal double damage to confused targets and those with Oblivious, Klutz, Defeatist, Unaware, Simple, or Fairy Silvally. An attacker with the Telekinesis boost doubles them again.",
        "Gilded Arrow also deals Rock-scaled damage equal to 1/8 of maximum HP at neutral effectiveness.",
        "Nature Power calls Ancient Power. Secret Power may lower Defense."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Adaptability allows attacks to hit through type immunities.",
      "Mimicry makes the user Psychic-type. An active Illusion boosts attacking power by 1.2x.",
      "Gorilla Tactics and Reckless multiply their holder's attacking power by 1.2x and raise the critical-hit ratio of attacks against the holder."
    ],

    # (The following items are affected by this field):
    :itemEffects => [
      "Synthetic Seed raises Special Attack and applies Magic Coat."
    ]
  },

  #----------------- 6. Big Top Arena [BTA] -------------------#
  6 => {
    :name => "Big Top Arena",
    :abbr => "BTA",
    :message => "Now presenting...!",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Sound moves", "Vine Whip", "Power Whip", "Fire Lash", "Fiery Dance", "Petal Dance", "Revelation Dance", "Drum Beating", "Fly", "Acrobatics", "First Impression"],
        2.0 => ["Pay Day"]
      },
      :statChanges => [
        "Dragon Dance sharply raises the user's Attack and Speed.",
        "Swords Dance drastically raises the user's Attack."
      ],
      :special => [
        "Physical Fighting attacks and listed heavy strikes roll for a damage multiplier from 0.5x to 3x.",
        "Heavy strikes include Strength, Wood Hammer, Dual Chop, Heat Crash, Sky Drop, Bulldoze, Icicle Crash, Body Slam, Stomp, Giga Impact, Pound, Smack Down, Iron Tail, Meteor Mash, Crabhammer, Dragon Rush, Bounce, Slam, Heavy Slam, Earthquake, Magnitude, High Horsepower, Ice Hammer, Dragon Hammer, Brutal Swing, Stomping Tantrum, Continental Crush, Grav Apple, and Double Iron Bash.",
        "Positive Attack stages improve the heavy-strike roll. Negative stages lower it.",
        "Acrobatics doubles its base power even if the user holds an item.",
        "Nature Power calls Acrobatics. Secret Power may lower Special Defense."
      ],
      :durationChange => {
        "Rain Dance" => 8
      }
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Huge Power, Guts, Pure Power, Sheer Force, and Iron Fist move heavy-strike rolls to the high end.",
      "Amplify boosts sound moves by 1.5x. Mimicry makes the user Normal-type."
    ],

    # (The following items are affected by this field):
    :itemEffects => [
      "Synthetic Seed raises Attack and applies Helping Hand."
    ]
  },

  #----------------- 7. Volcanic Field [VF] -------------------#
  7 => {
    :name => "Volcanic Field",
    :abbr => "VF",
    :message => "The heat is intense!",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Fire moves from grounded users", "Smack Down", "Thousand Arrows", "Rock Slide"],
        2.0 => ["Smog", "Clear Smog"]
      },
      :powerDecrease => {
        0.5 => ["Ice moves", "Grass moves against grounded targets"]
      },
      :additionalDamageType => {
        "Fire" => ["Smack Down", "Thousand Arrows", "Rock Slide", "Smog", "Clear Smog"]
      },
      :fail => ["Hail"],
      :special => [
        "The field damage is 1/8 of maximum HP at neutral Fire effectiveness. Tar Shot, Leaf Guard, Ice Body, and Fluffy worsen it.",
        "Nature Power calls Flamethrower. Secret Power may burn."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Flash Fire activates on the ground. Blaze and Flare Boost can boost attacks under the field's heat.",
      "Steam Engine raises Speed each turn. Heatproof restores 1/16 of maximum HP. Mimicry makes the user Fire-type."
    ],

    # (The following items are affected by this field):
    :itemEffects => [
      "Elemental Seed raises Attack, Special Attack, and Speed and traps the holder in Fire Spin."
    ],

    # (Other effects):
    :passiveEffects => [
      "Hail melts and the Grassy Terrain overlay burns away.",
      "Eligible grounded Pokémon take Fire-scaled damage at the end of each turn. Fire types, Aqua Ring, Dig or Dive, and several heat-related abilities protect against the damage."
    ],

    # (Field transformations):
    :fieldTransformations => {
      :transformsTo => {
        "Cave" => ["Whirlwind", "Gust", "Razor Wind", "Defog", "Hurricane", "Tailwind", "Blizzard", "Surf", "Muddy Water", "Water Spout", "Water Pledge", "Sparkling Aria", "Sand Tomb"]
      },
      :terminates => ["Rain can extinguish the field. Some extinguishing moves restore the original field if the fire was temporary"]
    }
  },

  #----------------- 8. Swamp Field [SF] -------------------#
  8 => {
    :name => "Swamp Field",
    :abbr => "SF",
    :message => "The field is swamped.",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Poison moves (against grounded)", "Mud Bomb", "Mud Shot", "Mud-Slap",
                "Muddy Water", "Surf", "Sludge Wave", "Gunk Shot", "Brine",
                "Smack Down", "Thousand Arrows", "Hydro Vortex"]
      },
      :additionalDamageType => {
        "Water" => ["Smack Down", "Thousand Arrows"]
      },
      :fail => ["Self Destruct", "Explosion"],
      :special => [
        "Aqua Ring restores 1/8 Max HP each turn (from 1/16).",
        "Strength Sap heals 30% more HP.",
        "Ingrain damages the user instead of healing it, unless the user is Poison- or Steel-type.",
        "Nature Power becomes Muddy Water.",
        "Camouflage makes the user Water-type.",
        "Secret Power may lower Speed."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Clear Body, Quick Feet, Swift Swim, Temporal Shift, White Smoke, and Propeller Tail prevent the field's Speed drop.",
      "Gooey sharply lowers the Speed of attackers that make contact.",
      "Water Compaction sharply raises Defense each turn.",
      "Dry Skin restores 1/16 of the holder's maximum HP each turn.",
      "Gulp Missile always picks up Arrokuda.",
      "Mimicry makes the user Water-type."
    ],

    # (The following items are affected by this field):
    :itemEffects => [
      "Telluric Seed raises Defense and Special Defense and applies Ingrain to the holder."
    ],

    # (Other effects):
    :passiveEffects => [
      "At the end of the turn, the field lowers the Speed of grounded Pokémon that have acted. It sharply lowers their Speed if they are trapped. Contrary reverses the effect.",
      "Sleeping Pokémon suffer 1/16 Max HP damage each turn.",
      "Sleeping Pokémon under the effect of trapping moves take double damage."
    ],

    # (How this field is created):
    :createdBy => {
      :moves => ["Water Pledge + Grass Pledge"]
    }
  },

  #----------------- 9. Rainbow Field [RBF] -------------------#
  9 => {
    :name => "Rainbow Field",
    :abbr => "RBF",
    :message => "What does it mean?",

    # (The following moves are affected by this field.):
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
      :statChanges => [
        "Cosmic Power sharply raises the user's Defense and Special Defense."
      ],
      :special => [
        "Sonicboom deals 140 flat HP damage.",
        "Life Dew restores 50% of Max HP.",
        "Wish restores 75% of Max HP (from 50%).",
        "Aurora Veil can be used on this field.",
        "Nightmare and Bad Dreams have no effect.",
        "Nature Power becomes Aurora Beam.",
        "Camouflage makes the user Dragon-type.",
        "Secret Power can randomly burn, freeze, paralyze, poison, or put the target to sleep."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Pokémon with Prism Armor take half damage.",
      "Soul Heart also raises Special Defense when it activates.",
      "Pastel Veil halves damage from Poison-type attacks.",
      "Marvel Scale is activated.",
      "Mimicry makes the user Dragon-type."
    ],

    # (The following items are affected by this field):
    :itemEffects => [
      "Magical Seed raises Special Attack, fully heals the holder, and cures its status."
    ],

    # (Other effects):
    :passiveEffects => [
      "Secondary effect chance of all moves is doubled.",
      "Sleeping Pokémon recover 1/16 Max HP each turn."
    ],

    # (How this field is created):
    :createdBy => {
      :moves => ["Fire Pledge + Water Pledge"],
      :note => "Also created by cancelling Rainy or Sunny weather with its opposite."
    },

    # (Field transformations):
    :fieldTransformations => {
      :terminates => ["Sand weather", "Hail weather"]
    }
  },

  #----------------- 10. Corrosive Field [CF] -------------------#
  10 => {
    :name => "Corrosive Field",
    :abbr => "CF",
    :message => "The field is corrupted!",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Smack Down", "Mud-Slap", "Mudshot", "Muddy Water", "Mud Bomb", "Whirlpool", "Thousand Arrows", "Apple Acid"],
        2.0 => ["Grass Knot", "Acid", "Acid Spray", "Snap Trap"]
      },
      :additionalDamageType => {
        "Poison" => ["Grass type attacks", "Smack Down", "Mud-Slap", "Mudshot", "Muddy Water", "Mud Bomb", "Whirlpool", "Thousand Arrows", "Apple Acid"]
      },
      :statChanges => [
        "Acid Armor drastically raises the user's Defense."
      ],
      :special => [
        "Floral Healing additionally poisons its target.",
        "Activates Venom Drench and Venoshock.",
        "Toxic Spikes cannot be absorbed.",
        "Nature Power becomes Acid.",
        "Camouflage makes the user Poison-type.",
        "Seed Flare deals 1.3x damage when it transforms the field.",
        "Secret Power may Poison."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Magic Guard, Toxic Boost, Poison Heal, Immunity, Wonder Guard, and Pastel Veil prevent entry damage.",
      "Mimicry makes the user Poison-type.",
      "Poison Heal restores HP to grounded Pokémon. Grounded Toxic Boost users benefit even without being poisoned."
    ],

    # (The following items are affected by this field):
    :itemEffects => [
      "Telluric Seed raises Attack and applies Baneful Bunker to the holder."
    ],

    # (Other effects):
    :passiveEffects => [
      "Grounded switch-ins other than Poison and Steel types take Poison-scaled entry damage (one quarter of maximum HP at neutral effectiveness).",
      "Sleeping Pokémon other than Poison and Steel types lose 1/16 of maximum HP each turn unless protected by Magic Guard or Wonder Guard.",
      "Ingrain damages vulnerable users each turn."
    ],

    # (How this field is created):
    :createdBy => {
      :note => "Created via field transformation or specific moves."
    },

    # (Field transformations):
    :fieldTransformations => {
      :transformsTo => {
        "Grassy Terrain" => ["Seed Flare", "Purify"]
      }
    }
  },

  #----------------- 11. Corrosive Mist Field [CMF] -------------------#
  11 => {
    :name => "Corrosive Mist Field",
    :abbr => "CMF",
    :message => "Corrosive mist settles on the field!",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Fire moves", "Smog", "Clear Smog", "Acid Spray", "Bubble", "Bubble Beam", "Sparkling Aria", "Apple Acid", "Oceanic Operetta"],
        1.3 => ["Moves that ignite or disperse the mist"]
      },
      :additionalDamageType => {
        "Poison" => ["Special Flying attacks", "Bubble", "Bubble Beam", "Energy Ball", "Sparkling Aria", "Apple Acid"]
      },
      :statChanges => [
        "Acid Armor drastically raises the user's Defense."
      ],
      :special => [
        "Activates Venom Drench and Venoshock.",
        "Floral Healing additionally poisons its target.",
        "Life Dew additionally poisons the targets.",
        "Nature Power becomes Acid Spray.",
        "Camouflage makes the user Poison-type.",
        "Secret Power may Poison.",
        "Pokémon using Endure or with Sturdy may survive field-termination damage with 1 HP.",
        "Pokémon protected by moves such as Wide Guard or with Flash Fire are immune to field-termination damage."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Aftermath deals 50% HP damage, up from 25%.",
      "Mimicry makes the user Poison-type.",
      "Water Compaction can sharply raise Defense on entry."
    ],

    # (The following items are affected by this field):
    :itemEffects => [
      "Elemental Seed raises Attack and Special Attack and badly poisons the holder."
    ],

    # (Other effects):
    :passiveEffects => [
      "At the end of each round, Pokémon that can be poisoned are poisoned unless Neutralizing Gas is active.",
      "Aqua Ring harms vulnerable Pokémon. Dry Skin harms most Pokémon and heals Poison types.",
      "The abilities Poison Heal and Toxic Boost are activated."
    ],

    # (How this field is created):
    :createdBy => {
      :note => "Created via field transformation."
    },

    # (Field transformations):
    :fieldTransformations => {
      :terminates => ["Heat Wave", "Eruption", "Lava Plume", "Searing Shot", "Fire Pledge", "Flame Burst", "Self Destruct", "Explosion", "Inferno Overdrive (KOs all active Pokémon)", "Gust", "Whirlwind", "Defog", "Hurricane", "Tailwind", "Razor Wind", "Twister", "Supersonic Skystrike"],
      :transformsTo => {
        "Corrosive Field" => ["Gravity"]
      }
    }
  },

  #----------------- 12. Desert Field [DF] -------------------#
  12 => {
    :name => "Desert Field",
    :abbr => "DF",
    :message => "The field is rife with sand.",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Heat Wave", "Needle Arm", "Pin Missile", "Dig", "Sand Tomb", "Thousand Waves", "Burn Up", "Scald", "Steam Eruption", "Scorching Sands"]
      },
      :powerDecrease => {
        0.5 => ["Water-type moves from grounded (excluding Scald and Steam Eruption)", "Electric moves against grounded"]
      },
      :statChanges => [
        "Sand Attack sharply lowers the target's Accuracy."
      ],
      :fail => ["Soak", "Aqua Ring"],
      :durationChange => {
        "Arenite Wall" => 8
      },
      :special => [
        "Nature Power becomes Sand Tomb.",
        "Shore up restores 66% HP (from 50%).",
        "Sand Tomb deals 1/6 Max HP damage per turn (from 1/8).",
        "Arenite Wall works without the need for a Sandstorm.",
        "Camouflage makes the user Ground-type.",
        "Secret Power may lower Accuracy."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Solar Idol, Sand Veil, Sand Rush and Sand Force are activated.",
      "Mimicry makes the user Ground-type.",
      "Sand Spit lowers Accuracy when it activates.",
      "Wandering Spirit lowers its holder's Speed every turn."
    ],

    # (The following items are affected by this field):
    :itemEffects => [
      "Telluric Seed raises Defense, Special Defense, and Speed and applies Sand Tomb to the holder."
    ],

    # (Other effects):
    :passiveEffects => [
      "Sunny Day, Drought, Sand Storm and Sandstream last for 8 turns.",
      "Ground-type Pokémon defend against special attacks with a 1.5x Special Defense multiplier.",
      "Sandstorm deals 1/8 Max HP damage per turn (from 1/16).",
      "When Sunny Day is active, Grass- and Water-type Pokémon take 1/8 Max HP damage at the end of the turn.",
      "When Sunny Day is active, Grass- and Water-type Pokémon are healed by Water-type moves (similar to dry skin).",
      "Dry Skin loses 1/8 of maximum HP each turn in the dry air."
    ],

    # (How this field is created):
    :createdBy => {
      :note => "Created via field transformation or set by event."
    }
  },

  #----------------- 13. Icy Field [IF] -------------------#
  13 => {
    :name => "Icy Field",
    :abbr => "IF",
    :message => "The field is covered in ice.",

    # (The following moves are affected by this field.):
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
        "Ice-type attacks have a double chance to freeze.",
        "Burn damage is halved.",
        "Rock-type attacks gain Ice-type effectiveness.",
        "Aurora Veil can be used on this field.",
        "Nature Power becomes Ice Beam.",
        "Camouflage makes the user Ice-type.",
        "Secret Power may lower Speed."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Ice Body is activated.",
      "Snow Cloak is activated.",
      "Ice Scales also halves physical damage.",
      "Refrigerate's base power multiplier becomes 1.5x (from 1.2x).",
      "Liquid Voice makes attacks Ice-type instead of Water-type.",
      "Slush Rush is activated.",
      "Mimicry makes the user Ice-type."
    ],

    # (The following items are affected by this field):
    :itemEffects => [
      "Elemental Seed sharply raises Speed."
    ],

    # (Other effects):
    :passiveEffects => [
      "Damaging priority contact moves and certain momentum moves can raise a grounded user's Speed.",
      "Beam moves deal 1.3x damage."
    ],

    # (Field transformations):
    :fieldTransformations => {
      :transformsTo => {
        "Water Surface" => ["Heat Wave", "Flame Burst", "Lava Plume", "Eruption", "Searing Shot",
                            "Fire Pledge", "Incinerate", "Lava Surf"]
      }
    }
  },

  #----------------- 14. Rocky Field [ROF] -------------------#
  14 => {
    :name => "Rocky Field",
    :abbr => "ROF",
    :message => "The field is littered with rocks.",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Rock moves", "Earthquake", "Magnitude", "Rock Climb", "Strength", "Bulldoze", "Accelerock"],
        2.0 => ["Rock Smash"]
      },
      :additionalDamageType => {
        "Rock" => ["Earthquake", "Magnitude", "Rock Climb", "Strength", "Bulldoze", "Accelerock"]
      },
      :statChanges => [
        "Rock Polish drastically raises the user's Speed."
      ],
      :durationChange => {
        "Arenite Wall" => 8
      },
      :special => [
        "Arenite Wall works without the need for a Sandstorm.",
        "Stealth Rock damage is doubled.",
        "Nature Power becomes Rock Smash.",
        "Camouflage makes the user Rock-type.",
        "Secret Power may flinch a sleeping or frozen target."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Mimicry makes the user Rock-type."
    ],

    # (The following items are affected by this field):
    :itemEffects => [
      "Telluric Seed raises Defense and Special Defense and damages the holder with Stealth Rock."
    ],

    # (Other effects):
    :passiveEffects => [
      "Substitute or raised Evasion provides cover from specific projectile attacks.",
      "Missing a physical contact attack causes 1/8 Max HP recoil damage (does not affect Rock Head Pokémon).",
      "Pokémon with Gorilla Tactics take double recoil damage.",
      "Flinched Pokémon suffer 1/16 Max HP damage (does not affect Sturdy or Steadfast Pokémon)."
    ],

    # (How this field is created):
    :createdBy => {
      :note => "Created via field transformation or set by event."
    }
  },

  #----------------- 15. Forest Field [FOF] -------------------#
  15 => {
    :name => "Forest Field",
    :abbr => "FOF",
    :message => "Trees fill the arena!",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Grass moves", "Special Bug moves", "Attack Order", "Slashing moves", "Special Fire moves"]
      },
      :powerDecrease => {
        0.5 => ["Surf", "Muddy Water"]
      },
      :additionalDamageType => {
        "Grass" => ["Slashing moves", "Special Fire-type moves"]
      },
      :statChanges => [
        "Growth sharply raises the user's Attack and Special Attack.",
        "Defend Order sharply raises the user's Defense and Special Defense."
      ],
      :special => [
        "Strength Sap heals 30% more HP.",
        "Grav Apple has 120 base power.",
        "Infestation deals 1/6 Max HP damage per turn (from 1/8).",
        "Nature's Madness deals 75% HP damage (from 50%).",
        "Forest's Curse additionally Curses the target.",
        "Heal Order restores 66% of Max HP (from 50%).",
        "Nature Power becomes Wood Hammer.",
        "Camouflage makes the user Bug-type.",
        "Secret Power may put the target to sleep."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Overgrow is activated.",
      "Swarm is activated.",
      "Leaf Guard is activated.",
      "Sap Sipper restores 1/16 of maximum HP per turn.",
      "Effect Spore puts the target to sleep for two turns instead.",
      "Mimicry makes the user Bug-type."
    ],

    # (The following items are affected by this field):
    :itemEffects => [
      "Telluric Seed raises Attack and applies Spiky Shield to the holder."
    ],

    # (Other effects):
    :passiveEffects => [
      "Grass- and Bug-type Pokémon have a 1.5x Defense multiplier."
    ]
  },

  #----------------- 16. Volcanic Top Field [VTF] -------------------#
  16 => {
    :name => "Volcanic Top Field",
    :abbr => "VTF",
    :message => "The volcanic field's heat is intense!",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.2 => ["Fire moves"],
        1.3 => ["Eruption", "Heat Wave", "Magma Storm", "Lava Plume", "Lava Surf"],
        1.5 => ["Thunder", "Wind moves", "Precipice Blades", "Smog", "Clear Smog"],
        1.667 => ["Steam Eruption"]
      },
      :powerDecrease => {
        0.5 => ["Ice moves", "Special Water moves except Steam Eruption"],
        0.9 => ["Physical Water moves"]
      },
      :additionalDamageType => {
        "Fire" => ["Rock moves", "Explosion", "Self-Destruct", "Magnet Bomb", "Egg Bomb", "Dive", "Seismic Toss", "Dig", "Wind moves", "Precipice Blades", "Smog", "Clear Smog"]
      },
      :fail => ["Hail"],
      :special => [
        "Flying-type users cannot miss with certain aerial attacks under Tailwind.",
        "Poison Gas badly poisons its targets.",
        "Thick Fat and Ice Silvally reduce eruption damage. Tar Shot increases it.",
        "Nature Power calls Eruption. Secret Power may burn.",
        "Earthquake, Bulldoze, Magnitude, Eruption, Precipice Blades, Lava Plume, Lava Surf, Earth Power, and Hot Tempo trigger an eruption."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "An eruption raises Defense and Special Defense for Pokémon with Magma Armor, and raises Special Attack for Pokémon with Flare Boost. It also activates Flash Fire and Blaze.",
      "Steam Engine raises Speed each turn. Heatproof restores 1/16 of maximum HP. Mimicry makes the user Fire-type."
    ],

    # (The following items are affected by this field):
    :itemEffects => [
      "Telluric Seed raises Defense and primes Shell Trap."
    ],

    # (Other effects):
    :passiveEffects => [
      "Hail melts and the Grassy Terrain overlay burns away.",
      "Desolate Land can trigger an eruption on entry.",
      "An eruption clears entry hazards and Leech Seed. It deals up to one quarter of maximum HP depending on Fire effectiveness."
    ],

    # (How this field is created):
    :createdBy => {
      :note => "Lava Plume, Lava Surf, or Eruption on Mountain. Eruption or Lava Surf on Snowy Mountain."
    },

    # (Field transformations):
    :fieldTransformations => {
      :transformsTo => {
        "Sky Field" => ["Fly", "Bounce", "Heavenly Wing"],
        "Mountain" => ["Blizzard", "Glaciate"]
      }
    }
  },

  #----------------- 17. Factory Field [FF] -------------------#
  17 => {
    :name => "Factory Field",
    :abbr => "FF",
    :message => "Machines whir in the background.",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.2 => ["Electric attacks when the Electric Terrain overlay is absent"],
        1.3 => ["Discharge", "Gigavolt Havoc", "Corkscrew Crash", "Overdrive", "Aura Wheel", "Explosion", "Self-Destruct", "Magnitude", "Earthquake", "Bulldoze", "Tectonic Rage"],
        1.5 => ["Steamroller", "Techno Blast"],
        2.0 => ["Flash Cannon", "Gyro Ball", "Magnet Bomb", "Gear Grind", "Double Iron Bash"]
      },
      :statChanges => [
        "Autotomize drastically raises the user's Speed.",
        "Shift Gear sharply raises the user's Attack and Speed.",
        "Gear Up sharply raises Attack and Special Attack for Pokémon on the user's side that have Plus or Minus.",
        "Metal Sound drastically lowers the target's Special Defense.",
        "Iron Defense drastically raises the user's Defense."
      ],
      :special => [
        "Steel Beam normally costs one quarter of the user's max HP on this field.",
        "Electric Terrain lasts eight turns when applied as an overlay. Nature Power calls Gear Grind. Secret Power can lower Attack."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => ["Galvanize boosts converted attacks by 50% before the field's Electric-type bonus."],

    # (The following items are affected by this field):
    :itemEffects => ["Synthetic Seed raises Special Attack and grants Laser Focus."],

    # (Field transformations):
    :fieldTransformations => {
      :transformsTo => {
        "Short-circuit Field" => ["Discharge", "Gigavolt Havoc", "Corkscrew Crash", "Overdrive", "Aura Wheel", "Explosion", "Self-Destruct", "Magnitude", "Earthquake", "Fissure", "Bulldoze", "Tectonic Rage"]
      }
    }
  },
  #----------------- 18. Short-circuit Field [SCF] -------------------#
  18 => {
    :name => "Short-circuit Field",
    :abbr => "SCF",
    :message => "Bzzt!",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.3 => ["Dark Pulse", "Phantom Force", "Night Daze", "Night Slash", "Shadow Ball", "Shadow Punch", "Shadow Claw", "Shadow Sneak", "Shadow Force", "Shadow Bone"],
        1.5 => ["Dazzling Gleam", "Flash Cannon", "Surf", "Muddy Water", "Magnet Bomb", "Gyro Ball", "Gear Grind"],
        1.667 => ["Steel Beam"]
      },
      :additionalDamageType => {
        "Electric" => ["Surf", "Muddy Water", "Magnet Bomb", "Gyro Ball", "Gear Grind", "Hydro Vortex", "Steel Beam"]
      },
      :accuracyChange => {80 => ["Zap Cannon"]},
      :durationChange => {"Magnet Rise" => 8},
      :statChanges => [
        "Metal Sound drastically lowers the target's Special Defense."
      ],
      :special => [
        "Steel Beam normally costs all of the user's remaining HP.",
        "Nature Power calls Discharge. Secret Power can paralyze."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Volt Absorb restores 1/16 max HP at the end of a turn when healing is allowed. Surge Surfer doubles Speed.",
      "Galvanize doubles converted moves before the field multiplier if the Electric Terrain overlay is absent."
    ],

    # (The following items are affected by this field):
    :itemEffects => ["Synthetic Seed raises Special Defense and grants Magnet Rise."],

    # (Other effects):
    :passiveEffects => [
      "Electric attacks randomly use a damage multiplier of 0.5, 0.8, 1.2, 1.5, or 2.0. The Electric Terrain overlay guarantees 2.0."
    ],

    # (Field transformations):
    :fieldTransformations => {
      :transformsTo => {
        "Factory Field" => ["Discharge", "Gigavolt Havoc", "Ion Deluge", "Overdrive", "Aura Wheel", "Parabolic Charge", "Wild Charge", "Charge Beam"]
      }
    }
  },
  #----------------- 19. Wasteland [WL] -------------------#
  19 => {
    :name => "Wasteland",
    :abbr => "WL",
    :message => "The field is poisonous!",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.2 => ["Octazooka", "Sludge", "Gunk Shot", "Sludge Wave", "Sludge Bomb", "Acid Downpour"],
        1.5 => ["Vine Whip", "Power Whip", "Mud-Slap", "Mud Shot", "Mud Bomb"],
        2.0 => ["Spit Up"]
      },
      :powerDecrease => {0.25 => ["Earthquake", "Magnitude", "Bulldoze"]},
      :additionalDamageType => {"Poison" => ["Mud-Slap", "Mud Shot", "Mud Bomb"]},
      :special => [
        "Swallow heals 1.5 times its usual amount. Venoshock is powered up and Venom Drench can lower stats even if its target is unpoisoned.",
        "Nature Power calls Gunk Shot. Secret Power can randomly burn, freeze, paralyze, or poison."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => ["Grounded Pokémon with Poison Heal recover 1/8 max HP per turn when healing is allowed."],

    # (The following items are affected by this field):
    :itemEffects => ["Telluric Seed raises Attack and Special Attack and attempts to inflict a random burn, freeze, paralysis, or poison on the holder."],

    # (Other effects):
    :passiveEffects => [
      "At the end of the turn, the field consumes entry hazards and strikes the side they were placed on.",
      "Stealth Rock deals twice its usual damage. Spikes deal one third of grounded targets' max HP.",
      "Toxic Spikes deal 1/8 max HP and can poison grounded targets that are neither Poison nor Steel.",
      "Sticky Web drastically lowers Speed by four stages. Mystic Harvest deals type-scaled Grass damage, 1/6 max HP at neutral effectiveness."
    ]
  },
  #----------------- 20. Ashen Beach [AB] -------------------#
  20 => {
    :name => "Ashen Beach",
    :abbr => "AB",
    :message => "Ash and sand line the field.",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.2 => ["Psychic"],
        1.3 => ["Stored Power", "Zen Headbutt", "Focus Blast", "Aura Sphere"],
        1.5 => ["Hidden Power", "Strength", "Land's Wrath", "Thousand Waves", "Surf", "Muddy Water"],
        2.0 => ["Mud-Slap", "Mud Shot", "Mud Bomb", "Sand Tomb"]
      },
      :additionalDamageType => {"Psychic" => ["Strength, which becomes Fighting-type on this field"]},
      :statChanges => [
        "Calm Mind sharply raises the user's Special Attack and Special Defense.",
        "Sand Attack sharply lowers the target's Accuracy."
      ],
      :durationChange => {"Arenite Wall" => 8, "Sandstorm" => 8},
      :special => [
        "Focus Energy sharply raises the user's critical-hit ratio.",
        "Shore Up heals 66% of max HP, as in sandstorm.",
        "Special Flying attacks, Leaf Tornado, Fire Spin, Twister, Razor Wind, and Whirlpool stir up ash and can lower Accuracy.",
        "Nature Power calls Meditate. Secret Power can lower Accuracy."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => ["Mimicry makes the user Ground-type. Zen Mode activates without needing low HP."],

    # (The following items are affected by this field):
    :itemEffects => ["Telluric Seed drastically raises the holder's critical-hit ratio."],

    # (Other effects):
    :passiveEffects => ["Fighting types resist attempts to confuse them on this field."]
  },
  #----------------- 21. Water Surface [WS] -------------------#
  21 => {
    :name => "Water Surface",
    :abbr => "WS",
    :message => "The water's surface is calm.",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.3 => ["Dive", "Anchor Shot", "Blizzard", "Glaciate", "Subzero Slammer", "Sludge Wave", "Acid Downpour"],
        1.5 => ["Water attacks", "Electric attacks without the Electric Terrain overlay", "Surf", "Muddy Water", "Origin Pulse", "Whirlpool", "Dive", "Hydro Vortex"]
      },
      :powerDecrease => {0.5 => ["Fire attacks against targets with no Ground immunity"]},
      :special => [
        "The listed Water moves receive their move-specific boosts in addition to the Water-type boost.",
        "Dive executes in one turn. Life Dew gives its user Aqua Ring. Aqua Ring restores 1/8 max HP.",
        "Nature Power calls Whirlpool. Secret Power can lower Speed."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Hydroplane raises Attack by 50% on Water Surface unless the holder has a working Utility Umbrella, and costs 1/8 max HP each turn.",
      "Torrent powers up Water moves even at full HP.",
      "Propeller Tail increases the damage of the user's damaging moves with positive base priority by 50%.",
      "Grounded Pokémon with Water Absorb can recover 1/16 max HP per turn.",
      "Swift Swim and Surge Surfer double Speed. Steam Engine raises Speed at the end of each turn.",
      "Mimicry makes the user Water-type. Wishiwashi with Schooling can form a school regardless of level or HP."
    ],

    # (The following items are affected by this field):
    :itemEffects => ["Elemental Seed raises Special Defense and grants Aqua Ring."],

    # (Other effects):
    :passiveEffects => ["Ground attacks are stopped by the water. Spikes and Toxic Spikes sink."],

    # (How this field is created):
    :createdBy => { :note => "Can occur while surfing, swimming, or fishing, or when a battle resurfaces from Underwater." },

    # (Field transformations):
    :fieldTransformations => {
      :transformsTo => {
        "Underwater" => ["Dive", "Gravity", "Anchor Shot", "Grav Apple"],
        "Murkwater Surface" => ["Sludge Wave twice", "Acid Downpour"],
        "Icy Field" => ["Blizzard", "Glaciate", "Subzero Slammer"]
      }
    }
  },
  #----------------- 22. Underwater [UW] -------------------#
  22 => {
    :name => "Underwater",
    :abbr => "UW",
    :message => "Blub blub...",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.3 => ["Dive", "Sky Drop", "Fly", "Bounce", "Supersonic Skystrike"],
        1.5 => ["Water attacks", "Water Pulse"],
        2.0 => ["Electric attacks without the Electric Terrain overlay", "Anchor Shot", "Dragon Darts", "Sludge Wave", "Acid Downpour"]
      },
      :additionalDamageType => {"Water" => ["Ground attacks", "Grav Apple", "Dragon Darts"]},
      :fail => ["Fire attacks", "Tar Shot"],
      :special => [
        "Dive executes in one turn. Aqua Ring restores 1/8 max HP.",
      "Targets use double Defense against non-Water physical attacks from attackers without Water typing or Swift Swim.",
        "Water attacks double their type effectiveness against Water Pokémon, offsetting Water resistance.",
        "Nature Power calls Water Pulse. Secret Power can lower Attack."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Propeller Tail increases the damage of the user's damaging moves with positive base priority by 50%.",
      "Torrent powers up Water moves even at full HP.",
      "Swift Swim and Surge Surfer double Speed. Steam Engine raises Speed at the end of each turn.",
      "Mimicry makes the user Water-type. Wishiwashi with Schooling can form a school regardless of level or HP."
    ],

    # (The following items are affected by this field):
    :itemEffects => ["Elemental Seed raises Speed and changes the holder to Water type unless it has Multitype or RKS System."],

    # (Other effects):
    :passiveEffects => ["Weather effects are suppressed. Non-Water Pokémon with neither Swift Swim nor Steelworker have one quarter of their usual Speed."],

    # (How this field is created):
    :createdBy => { :note => "Can be reached from Water Surface." },

    # (Field damage):
    :fieldDamage => {
      :amount => "1/4 max HP against a target with a single weakness to Water. Damage scales with Water effectiveness.",
      :timing => "End of turn",
      :affects => "Non-Water Pokémon that are weak to Water",
      :immuneAbilities => ["Swift Swim", "Magic Guard"],
      :doubledAbilities => ["Flame Body", "Magma Armor"]
    },

    # (Field transformations):
    :fieldTransformations => {
      :transformsTo => {
        "Water Surface" => ["Dive", "Sky Drop", "Fly", "Bounce", "Shore Up"],
        "Murkwater Surface" => ["Sludge Wave twice", "Acid Downpour"]
      }
    }
  },
  #----------------- 23. Cave [CV] -------------------#
  23 => {
    :name => "Cave",
    :abbr => "CV",
    :message => "The cave echoes dully...",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.3 => ["Power Gem", "Diamond Storm", "Hot Tempo", "Lava Surf", "Lava Plume", "Eruption", "Heat Wave", "Inferno", "Overheat", "Fire Lash", "Fusion Flare", "Inferno Overdrive", "Draco Meteor", "Devastating Drake", "Sludge Wave", "Blizzard", "Subzero Slammer", "Acid Downpour"],
        1.5 => ["Rock attacks", "Sound-based attacks", "Rock Tomb"]
      },
      :powerDecrease => {0.5 => ["Non-contact Flying attacks"]},
      :fail => ["Sky Drop"],
      :special => [
        "Fly and Bounce execute in one turn. Terrain Pulse becomes Rock type.",
        "Nature Power calls Rock Tomb. Secret Power can inflict Crushed.",
        "The cave stays in place after the ceiling collapses. Shelter halves incoming Rock damage."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => ["Amplify boosts sound moves by 50%. Mimicry makes the user Rock-type."],

    # (The following items are affected by this field):
    :itemEffects => ["Telluric Seed sharply raises Defense and attempts to inflict Crushed on the holder."],

    # (Other effects):
    :passiveEffects => [
      "Ground attacks can hit airborne Pokémon. Stealth Rock damage is doubled.",
      "Two uses of Earthquake, Magnitude, Bulldoze, Tectonic Rage, or Continental Crush collapse the ceiling. The cave-in places Stealth Rock on both sides, triggers it immediately, and attempts to inflict Crushed.",
      "Semi-invulnerable Pokémon, bosses, and Pokémon protected by shields, certain abilities, or Rock Silvally's protection avoid Crushed from the collapse. After the Stealth Rock damage, Endure, Sturdy, and Miracle can leave survivors at 1 HP in place of inflicting Crushed."
    ]
  },
  #----------------- 24. Glitch Field [GF] -------------------#
  24 => {
    :name => "Glitch Field",
    :abbr => "GF",
    :message => "1n!taliz3 .b//////attl3",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.2 => ["Psychic attacks without the Psychic Terrain overlay"],
        1.5 => ["Super U.M.D. Move"]
      },
      :accuracyChange => {90 => ["Blizzard"]},
      :fail => ["Roar", "Whirlwind"],
      :special => [
        "Fairy attacks become Normal. Dragon attacks always have neutral type effectiveness, and Ghost attacks cannot hit Psychic types.",
        "Bug attacks quadruple their effectiveness versus Poison. Ice attacks double their effectiveness versus Fire. Poison attacks are super effective against Bug, and Steel resists Ghost and Dark.",
        "Rest can heal through Sleep Talk. Metronome filters out moves below 70 base power.",
        "Nature Power calls Metronome. Secret Power can lower Speed."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => ["Download can raise both attacking stats."],

    # (The following items are affected by this field):
    :itemEffects => [
      "Synthetic Seed raises Defense and Special Defense and changes the holder to ??? type unless it has Multitype or RKS System.",
      "Genesect can absorb Electric moves with Shock Drive, Fire with Burn Drive, and Ice with Chill Drive. Douse Drive can absorb direct Ice moves or moves that add Water typing."
    ],

    # (Other effects):
    :passiveEffects => [
      "The pre-split physical and special categories depend on type. Special damage uses the higher of Special Attack and Special Defense.",
      "Being faster than the target raises the attacker's critical-hit ratio."
    ],

    # (How this field is created):
    :createdBy => { :moves => ["Conversion and Conversion 2 in succession without an Everstone"], :duration => 5 }
  },
  #----------------- 25. Crystal Cavern [CC] -------------------#
  25 => {
    :name => "Crystal Cavern",
    :abbr => "CC",
    :message => "The cave is littered with crystals.",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.3 => ["Aurora Beam", "Signal Beam", "Flash Cannon", "Dazzling Gleam", "Mirror Shot", "Techno Blast", "Doom Desire", "Moongeist Beam", "Menacing Moonraze Maelstrom", "Photon Geyser", "Dark Pulse", "Night Daze", "Bulldoze", "Earthquake", "Magnitude", "Tectonic Rage", "Black Hole Eclipse"],
        1.5 => ["Rock attacks", "Dragon attacks", "Power Gem", "Diamond Storm", "Ancient Power", "Rock Tomb", "Rock Smash", "Multi-Attack", "Luster Purge", "Judgment", "Strength", "Rock Climb", "Light That Burns the Sky"]
      },
      :additionalDamageType => {"Random Water, Grass, Fire, or Psychic" => ["Rock attacks", "Judgment", "Rock Climb", "Strength", "Multi-Attack", "Prismatic Laser"]},
      :statChanges => [
        "Rock Polish sharply raises the user's Speed and also raises its Attack and Special Attack."
      ],
      :special => [
        "Aurora Veil can be used here.",
        "Nature Power calls Power Gem. Secret Power can burn, freeze, confuse, or put its target to sleep."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => ["Prism Armor doubles effective Defense and Special Defense on this field."],

    # (The following items are affected by this field):
    :itemEffects => ["Magical Seed raises Special Attack and grants Magic Coat."],

    # (Field transformations):
    :fieldTransformations => {
      :transformsTo => {
        "Dark Crystal Cavern" => ["Dark Pulse", "Dark Void", "Night Daze"],
        "Cave" => ["Two uses of Bulldoze, Earthquake, or Magnitude", "Tectonic Rage"]
      }
    }
  },
  #----------------- 26. Murkwater Surface [MS] -------------------#
  26 => {
    :name => "Murkwater Surface",
    :abbr => "MS",
    :message => "The water is tainted...",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.3 => ["Blizzard", "Glaciate", "Whirlpool", "Subzero Slammer"],
        1.5 => ["Water attacks", "Poison attacks", "Electric attacks without the Electric Terrain overlay", "Mud Bomb", "Mud-Slap", "Mud Shot", "Smack Down", "Acid", "Acid Spray", "Brine", "Thousand Waves", "Apple Acid"]
      },
      :additionalDamageType => {
        "Poison" => ["Water attacks", "Smack Down", "Apple Acid"],
        "Water" => ["Sludge Wave"]
      },
      :statChanges => [
        "Acid Armor drastically raises the user's Defense."
      ],
      :special => [
        "Mud Bomb, Mud-Slap, Mud Shot, and Thousand Waves become Water type and add Poison effectiveness.",
        "Tar Shot and Life Dew can poison. Whirlpool clears hazards when cleaning the water.",
        "Nature Power calls Sludge Wave. Secret Power can poison."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Swift Swim and Surge Surfer double Speed. Wishiwashi with Schooling can form a school regardless of level or HP.",
      "Grounded Pokémon with Poison Heal, or grounded Poison types with Water Absorb or Dry Skin, can heal 1/8 max HP per turn."
    ],

    # (The following items are affected by this field):
    :itemEffects => ["Elemental Seed grants Aqua Ring, raises Speed, and attempts to badly poison the holder."],

    # (Other effects):
    :passiveEffects => ["Ground attacks are stopped by the water. Spikes and Toxic Spikes sink."],

    # (Field damage):
    :fieldDamage => {
      :amount => "Type-scaled Poison damage. Dive users can take four times the regular grounded damage.",
      :timing => "End of turn",
      :affects => "Grounded non-Poison, non-Steel Pokémon, and Pokémon diving into the murk",
      :immuneAbilities => ["Poison Heal", "Magic Guard", "Wonder Guard", "Surge Surfer", "Toxic Boost", "Immunity", "Pastel Veil"],
      :doubledAbilities => ["Dry Skin", "Water Absorb", "Flame Body", "Magma Armor"]
    },

    # (Field transformations):
    :fieldTransformations => {
      :transformsTo => {
        "Water Surface" => ["Whirlpool", "Purify"],
        "Icy Field" => ["Blizzard", "Glaciate", "Subzero Slammer"]
      }
    }
  },
  #----------------- 27. Mountain [MTN] -------------------#
  27 => {
    :name => "Mountain",
    :abbr => "MTN",
    :message => "High up!",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.3 => ["Fly", "Bounce", "Blizzard", "Heavenly Wing", "Lava Plume", "Lava Surf", "Eruption", "Subzero Slammer", "Inferno Overdrive"],
        1.5 => ["Rock attacks", "Flying attacks", "Wind moves", "Vital Throw", "Circle Throw", "Storm Throw", "Thunder", "Eruption", "Avalanche"]
      },
      :durationChange => {"Tailwind" => 6},
      :special => [
        "Sunny Day lasts eight turns.",
        "Strong Winds further boost wind moves and special Flying attacks by 50%. Tailwind can create Strong Winds.",
        "Thunder skips its accuracy check.",
        "Nature Power calls Rock Slide. Secret Power can flinch."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => ["Long Reach applies a 1.5x multiplier to the relevant attacking stat. Aerilate boosts converted attacks by 50%. Mimicry makes the user Rock-type."],

    # (The following items are affected by this field):
    :itemEffects => ["Telluric Seed raises Attack and lowers Accuracy."],

    # (Other effects):
    :passiveEffects => ["After three turns of hail, the field turns into Snowy Mountain."],

    # (Field transformations):
    :fieldTransformations => {
      :transformsTo => {
        "Sky Field" => ["Fly", "Bounce", "Heavenly Wing"],
        "Snowy Mountain" => ["Blizzard", "Subzero Slammer", "Three turns of hail"],
        "Volcanic Top" => ["Lava Plume", "Lava Surf", "Eruption", "Inferno Overdrive"]
      }
    }
  },
  #----------------- 28. Snowy Mountain [SM] -------------------#
  28 => {
    :name => "Snowy Mountain",
    :abbr => "SM",
    :message => "The snow glows white on the mountain...",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.3 => ["Heat Wave", "Flame Burst", "Lava Plume", "Searing Shot", "Fire Pledge", "Fly", "Bounce", "Heavenly Wing", "Eruption", "Lava Surf", "Inferno Overdrive"],
        1.5 => ["Rock attacks", "Ice attacks", "Flying attacks", "Wind moves except Icy Wind", "Vital Throw", "Storm Throw", "Circle Throw", "Avalanche", "Powder Snow"],
        2.0 => ["Icy Wind"]
      },
      :powerDecrease => {0.5 => ["Fire attacks", "Scald", "Steam Eruption"]},
      :additionalDamageType => {"Ice" => ["Rock attacks"]},
      :durationChange => {"Tailwind" => 6},
      :special => [
        "Sunny Day and Hail last eight turns.",
        "Strong Winds further boost wind moves and special Flying attacks by 50%. Tailwind can create Strong Winds.",
        "Aurora Veil can be used here. Thunder skips its accuracy check.",
        "Nature Power calls Avalanche. Secret Power can freeze."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Ice Body and Slush Rush activate here. Long Reach applies a 1.5x multiplier to the relevant attacking stat.",
      "Aerilate and Refrigerate boost their converted moves by 50%. Mimicry makes the user Ice-type."
    ],

    # (The following items are affected by this field):
    :itemEffects => ["Telluric Seed raises Special Attack and lowers Accuracy."],

    # (Field transformations):
    :fieldTransformations => {
      :transformsTo => {
        "Sky Field" => ["Fly", "Bounce", "Heavenly Wing"],
        "Mountain" => ["Heat Wave", "Flame Burst", "Lava Plume", "Searing Shot", "Fire Pledge", "Inferno Overdrive"],
        "Volcanic Top" => ["Eruption", "Lava Surf"]
      }
    }
  },
  #----------------- 29. Blessed Field [HF] -------------------#
  29 => {
    :name => "Blessed Field",
    :abbr => "HF",
    :message => "The field is blessed!",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.2 => ["Dragon attacks", "Psychic attacks without the Psychic Terrain overlay"],
        1.3 => ["Light moves", "Psystrike", "Aeroblast", "Origin Pulse", "Precipice Blades", "Dragon Ascent", "Doom Desire", "Mist Ball", "Luster Purge", "Psycho Boost", "Spacial Rend", "Roar of Time", "Crush Grip", "Secret Sword", "Relic Song", "Hyperspace Hole", "Land's Wrath", "Moongeist Beam", "Sunsteel Strike", "Prismatic Laser", "Fleur Cannon", "Non-Normal Multipulse", "Behemoth Blade", "Behemoth Bash", "Dynamax Cannon", "Eternabeam", "Genesis Supernova"],
        1.5 => ["Fairy attacks without the Misty Terrain overlay", "Special Normal attacks", "Mystical Fire", "Magical Leaf", "Ancient Power", "Judgment", "Sacred Fire"]
      },
      :powerDecrease => {0.5 => ["Ghost attacks", "Special Dark attacks"]},
      :statChanges => [
        "Cosmic Power sharply raises the user's Defense and Special Defense."
      ],
      :special => [
        "Life Dew heals half of max HP. Wish restores three quarters of the user's max HP.",
        "Miracle Eye also sharply raises the user's Special Attack.",
        "Nature Power calls Judgment. Secret Power can lower Special Attack."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => ["Power Spot increases the partner's attack power by 50%. Mimicry makes the user Normal-type."],

    # (The following items are affected by this field):
    :itemEffects => ["Magical Seed raises Special Attack and grants Magic Coat."],

    # (Other effects):
    :passiveEffects => ["Normal attacks are super effective against Ghost and Dark types here."],

    # (Field transformations):
    :fieldTransformations => {
      :transformsTo => {
        "Cursed Field" => ["Ghost-type Curse", "Trick-or-Treat", "Phantom Force", "Shadow Force", "Ominous Wind twice"]
      }
    }
  },
  #----------------- 30. Mirror Arena [MA] -------------------#
  30 => {
    :name => "Mirror Arena",
    :abbr => "MA",
    :message => "Mirrors are laid around the field!",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.3 => ["Earthquake", "Bulldoze", "Magnitude", "Boomburst", "Hyper Voice", "Tectonic Rage"],
        1.5 => ["Aurora Beam", "Signal Beam", "Flash Cannon", "Luster Purge", "Dazzling Gleam", "Techno Blast", "Doom Desire", "Prismatic Laser"],
        2.0 => ["Mirror Shot", "Reflected Charge Beam, Solar Beam, Psybeam, Tri Attack, Bubble Beam, Hyper Beam, Ice Beam, Origin Pulse, Moongeist Beam, and Fleur Cannon"]
      },
      :durationChange => {"Reflect" => 8, "Light Screen" => 8, "Aurora Veil" => 8},
      :special => [
        "Mirror Shot and the listed 1.5x attacks skip their accuracy roll.",
        "Mirror Shot always lowers Accuracy when it hits.",
        "Reflect, Light Screen, and Aurora Veil also raise the user's Evasion. Aurora Veil can be used without hail.",
        "Mirror Move raises Attack, Special Attack, and Speed when it copies a move. Copycat raises Accuracy, Attack, and Special Attack when it copies a move.",
        "Nature Power calls Mirror Shot. Secret Power can lower Evasion."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Sand Veil, Tangled Feet, Magic Bounce, Color Change, and Illusion can raise Evasion on entry.",
      "Magic Bounce also raises Evasion when bouncing a move. Illuminate lowers the opposing Pokémon's Accuracy."
    ],

    # (The following items are affected by this field):
    :itemEffects => ["Bright Powder and Lax Incense can raise Evasion on entry.", "Synthetic Seed sharply raises Evasion."],

    # (Other effects):
    :passiveEffects => [
      "The attacker's positive Accuracy and Evasion stages and the target's negative Accuracy and Evasion stages raise the attacker's critical-hit ratio.",
      "Special non-contact attacks that miss an accuracy roll have a 50% chance to reflect onto the target. Certain reflected beams deal double damage.",
      "A contact attack that fails its hit sequence can shatter a mirror and cost the user one quarter of max HP."
    ],

    # (Field transformations):
    :fieldTransformations => {
      :terminates => ["Earthquake", "Bulldoze", "Magnitude", "Boomburst", "Hyper Voice", "Tectonic Rage"],
      :note => "Shattering the field deals half of max HP to each vulnerable Pokémon. Shell Armor, Battle Armor, semi-invulnerability, and several protective moves can stop the damage."
    }
  },
  #----------------- 31. Fairy Tale Field [FTF] -------------------#
  31 => {
    :name => "Fairy Tale Field",
    :abbr => "FTF",
    :message => "Once upon a time...",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Steel attacks", "Fairy attacks without the Misty Terrain overlay", "Night Slash", "Leaf Blade", "Psycho Cut", "Smart Strike", "Solar Blade", "Razor Shell", "Behemoth Blade", "Behemoth Bash", "Magical Leaf", "Mystical Fire", "Ancient Power", "Relic Song", "Sparkling Aria", "Moongeist Beam", "Fleur Cannon"],
        2.0 => ["Dragon attacks", "Draining Kiss", "Mist Ball"]
      },
      :additionalDamageType => {"Dragon" => ["Fire attacks"]},
      :statChanges => [
        "Acid Armor drastically raises the user's Defense.",
        "Swords Dance drastically raises the user's Attack.",
        "Noble Roar sharply lowers the target's Attack and Special Attack."
      ],
      :special => [
        "Floral Healing heals two thirds of max HP. Crafty Shield raises the user's Defense and Special Defense. Flower Shield raises Defense for Grass-type Pokémon and raises the user's Defense and Special Defense if there is a Grass-type Pokémon in battle.",
        "King's Shield can block status moves. It sharply lowers Attack and Special Attack of attackers that make contact.",
        "Wish restores three quarters of the user's max HP. Miracle Eye also sharply raises the user's Special Attack. Forest's Curse can also curse its target.",
        "Cut, Slash, Sacred Sword, and Secret Sword become Steel type.",
        "Nature Power calls Secret Sword. Secret Power can put the target to sleep."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Steely Spirit doubles Steel attack power. Mimicry makes the user Fairy-type.",
      "Entering with Battle Armor, Shell Armor, or Stance Change raises Defense. Power of Alchemy and Dauntless Shield raise both defenses.",
      "Mirror Armor, Magic Guard, Magic Bounce, and Pastel Veil can raise Special Defense on entry. Magician raises Special Attack, and Intrepid Sword raises Attack and Special Attack."
    ],

    # (The following items are affected by this field):
    :itemEffects => ["Magical Seed raises Attack and grants King's Shield."],

    # (Other effects):
    :passiveEffects => ["Steel attacks hit Dragon types super effectively."],

    # (How this field is created):
    :createdBy => { :moves => ["Mist Ball in Dragon's Den"] }
  },
  #----------------- 32. Dragon's Den [DD] -------------------#
  32 => {
    :name => "Dragon's Den",
    :abbr => "DD",
    :message => "If you wish to slay a dragon...",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.3 => ["Rock attacks", "Mist Ball after its move-specific boost"],
        1.5 => ["Dragon attacks", "Fire attacks", "Mega Kick", "Stomping Tantrum", "Rock Climb", "Strength", "Magma Storm", "Lava Plume", "Shell Trap", "Earth Power", "Lava Surf", "Power Gem", "Diamond Storm", "Matrix Shot"],
        2.0 => ["Smack Down", "Thousand Arrows", "Luster Purge", "Mist Ball", "Dragon Ascent", "Pay Day"]
      },
      :powerDecrease => {0.5 => ["Water attacks", "Ice attacks"]},
      :additionalDamageType => {"Fire" => ["Smack Down", "Thousand Arrows"], "Rock" => ["Rock Climb", "Strength"]},
      :accuracyChange => {100 => ["Dragon Rush"]},
      :statChanges => [
        "Noble Roar sharply lowers the target's Attack and Special Attack.",
        "Dragon Dance sharply raises the user's Attack and Speed.",
        "Coil sharply raises the user's Attack, Defense, and Accuracy."
      ],
      :special => [
        "Stealth Rock deals Fire damage. Fly and Bounce execute in one turn.",
        "Strength and Rock Climb become Fire type in addition to their Rock effectiveness.",
        "Nature Power calls Dragon Pulse or a move tied to the original field. For example, it calls Rock Tomb if the original field was Cave. Secret Power can burn."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Shell Armor raises Defense on entry. Multiscale halves the effectiveness of Fairy, Ice, and Dragon attacks."
    ],

    # (The following items are affected by this field):
    :itemEffects => [
      "Amulet Coin protects its holder from status conditions.",
      "Elemental Seed raises Special Attack and grants the Flash Fire effect."
    ],

    # (Other effects):
    :passiveEffects => [
      "Hail fails or melts away. Dragon types get a 50% Special Defense boost."
    ],

    # (Field transformations):
    :fieldTransformations => {:transformsTo => {"Fairy Tale Field" => ["Mist Ball"]}}
  },

  #----------------- 33. Flower Garden Field [FGF] -------------------#
  33 => {
    :name => "Flower Garden Field",
    :abbr => "FGF",
    :message => "Seeds line the field.",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        "1.2 / 1.5 / 2 / 3" => ["Grass attacks at stages 2 / 3 / 4 / 5 without a Grassy Terrain overlay"],
        1.3 => ["Heat Wave, Eruption, Searing Shot, Flame Burst, Lava Plume, Fire Pledge, and Inferno Overdrive from stage 3 unless it is raining"],
        1.5 => ["Cut from stage 2", "Fire attacks from stage 3", "Bug attacks at stages 3 and 4"],
        2.0 => ["Bug attacks at stage 5"],
        "1.2 then 1.5" => ["Petal Dance, Petal Blizzard, and Fleur Cannon at stage 3 then stages 4 and 5"]
      },
      :additionalDamageType => {
        "Grass" => ["Cut from stage 2"]
      },
      :special => [
        "From stage 2, Cut is super effective against Grass.",
        "Growth sharply raises Attack and Special Attack, or drastically raises both from stage 3 onward.",
        "Flower Shield raises Defense and Special Defense for Grass-type Pokémon at garden stage 2 and sharply raises both from stage 3. Rototiller sharply raises Attack and Special Attack for Grass-type Pokémon. Both moves can also raise the same stats for a non-Grass user if there is a Grass-type Pokémon in battle.",
        "Ingrain heals 1/8 of maximum HP at stages 2 and 3, and 1/4 at stages 4 and 5. Floral Healing restores about two-thirds from stage 3.",
        "Infestation deals 1/6, 1/4, or 1/3 of maximum HP to unshielded targets at stages 3, 4, or 5, respectively.",
        "At stage 5, Petal Dance, Petal Blizzard, Cotton Spore, Spore, Sleep Powder, Stun Spore, Poison Powder, and Powder can target both opponents.",
        "Nature Power calls Growth until stage 5, when it calls Petal Blizzard. Camouflage makes the user Grass-type. Secret Power may lower Evasion and, from stage 3, Defense and Special Defense. At stage 5, it may sharply lower all three."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Flower Gift, Flower Veil, Drought, Drizzle, and Grass-associated Silvally can advance the garden on entry.",
      "The field enables Flower Gift without sun. Chlorophyll can double Speed without sun at stages 4 and 5.",
      "Above one-third HP, Swarm boosts Bug attacks by 1.5x at stages 1 and 2, 2x at stages 3 and 4, and 3x at stage 5.",
      "Above one-third HP, Overgrow boosts Grass attacks by 1.5x at stage 2 if the user has at most 67% HP. Stages 3, 4, and 5 apply 1.5x, 2x, and 3x respectively.",
      "Mimicry makes the user Grass-type."
    ],

    # (The following items are affected by this field):
    :itemEffects => ["Synthetic Seed raises Special Defense and applies Ingrain."],

    # (Other effects):
    :passiveEffects => [
      "The garden starts at stage 1 and can grow to stage 5. Grass-type targets take 0.75x, 0.67x, and 0.5x damage at stages 3, 4, and 5.",
      "Cut lowers the garden by one stage. Heat Wave, Eruption, Searing Shot, Flame Burst, Lava Plume, and Fire Pledge lower it by two stages from stage 3 onward unless it is raining."
    ],

    # (How this field is created):
    :createdBy => {
      :moves => ["Growth", "Flower Shield", "Rain Dance", "Sunny Day", "Rototiller", "Ingrain", "Grassy Terrain", "Bloom Doom"],
      :note => "These moves advance an existing garden. Ripen advances it an additional stage with the first six moves."
    }
  },
  #----------------- 34. Starlight Arena [SA] -------------------#
  34 => {
    :name => "Starlight Arena",
    :abbr => "SA",
    :message => "Starlight fills the battlefield.",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.3 => ["Fairy attacks without a Misty Terrain overlay"],
        1.5 => ["Dark attacks", "Psychic attacks without a Psychic Terrain overlay", "Aurora Beam", "Signal Beam", "Flash Cannon", "Luster Purge", "Dazzling Gleam", "Mirror Shot", "Moonblast", "Techno Blast", "Solar Beam", "Photon Geyser", "Prismatic Laser"],
        2.0 => ["Draco Meteor", "Meteor Mash", "Comet Punch", "Spacial Rend", "Swift", "Hyperspace Hole", "Hyperspace Fury", "Moongeist Beam", "Sunsteel Strike", "Black Hole Eclipse", "Meteor Assault", "Searing Sunraze Smash", "Menacing Moonraze Maelstrom", "Light That Burns the Sky"],
        4.0 => ["Doom Desire's delayed hit"]
      },
      :additionalDamageType => {"Fairy" => ["Dark attacks"], "Fire" => ["Doom Desire's delayed hit"]},
      :statChanges => [
        "Cosmic Power sharply raises the user's Defense and Special Defense."
      ],
      :durationChange => {
        "Trick Room, Aurora Veil, and the Psychic Terrain overlay created by Psychic Terrain" => 8
      },
      :special => [
        "Healing Wish and Lunar Dance can raise the recipient's Attack and Special Attack on entry.",
        "Nature Power calls Moonblast. Camouflage makes the user Dark-type. Secret Power may lower Special Defense."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Victory Star applies a 1.5x multiplier to the relevant attacking stat for the holder and separately for an ally.",
      "Shadow Shield doubles the effective defenses used by damage calculations.",
      "Mirror Armor blocks opposing priority attacks on its side. Illuminate sharply raises Special Attack on entry and can put a Mirror Armor partner in the spotlight.",
      "Adaptability can copy an opposing ability like Trace. Mimicry makes the user Dark-type."
    ],

    # (The following items are affected by this field):
    :itemEffects => ["Magical Seed raises Special Attack, fully heals HP, and clears major status. It does not activate for World of Nightmares."],

    # (Other effects):
    :passiveEffects => ["Rain, sun, sandstorm, and hail hide the stars while the weather lasts. World of Nightmares can transform Starlight Arena into New World after eight turns."]
  },
  #----------------- 35. New World [NW] -------------------#
  35 => {
    :name => "New World",
    :abbr => "NW",
    :message => "From darkness, from stardust, from memories of eons past and visions yet to come...",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Dark attacks", "Aurora Beam", "Signal Beam", "Flash Cannon", "Dazzling Gleam", "Mirror Shot", "Earth Power", "Power Gem", "Eruption", "Continental Crush", "Fusion Bolt", "Fusion Flare", "Ice Burn", "Freeze Shock", "Bolt Strike", "Blue Flare", "Techno Blast", "Oblivion Wing", "Land's Wrath", "Thousand Arrows", "Thousand Waves", "Diamond Storm", "Steam Eruption", "Core Enforcer", "Fleur Cannon", "Prismatic Laser", "Sunsteel Strike", "Spectral Thief", "Moongeist Beam", "Multi-Attack"],
        2.0 => ["Vacuum Wave", "Draco Meteor", "Meteor Mash", "Moonblast", "Comet Punch", "Swift", "Searing Sunraze Smash", "Menacing Moonraze Maelstrom", "Hyperspace Hole", "Spacial Rend", "Hyperspace Fury", "Ancient Power", "Future Sight's delayed hit"],
        4.0 => ["Doom Desire's delayed hit", "Black Hole Eclipse", "Light That Burns the Sky"]
      },
      :additionalDamageType => {"Fire" => ["Doom Desire's delayed hit"]},
      :statChanges => [
        "Cosmic Power sharply raises the user's Defense and Special Defense."
      ],
      :durationChange => {
        "Trick Room, Magic Room, and Wonder Room" => 8
      },
      :special => [
        "Heart Swap also averages the battlers' HP. Lunar Dance can raise all seven battle stats of the recipient.",
        "Nature's Madness removes three-quarters of the target's current HP.",
        "Meteor Beam, Electro Shot, and Brainstorm skip their charging turn.",
        "Nature Power calls Spacial Rend. Camouflage picks a random type. Secret Power may lower all seven battle stats."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Shadow Shield doubles the relevant effective defenses. Victory Star applies a 1.5x multiplier to the relevant attacking stat for the holder and separately for an ally.",
      "Multitype, RKS System, and Mimicry can change the user's type to a random type."
    ],

    # (The following items are affected by this field):
    :itemEffects => ["Magical Seed raises Attack, Defense, Special Attack, Special Defense, and Speed, then makes the holder recharge."],

    # (Other effects):
    :passiveEffects => ["Grounded Pokémon have half Speed. Ordinary weather and terrain moves fail to establish their effects."],

    # (Field transformations):
    :fieldTransformations => {
      :transformsTo => {"Starlight Arena" => ["Gravity (temporary)", "Geomancy"]}
    }
  },
  #----------------- 36. Inverse Field [IF] -------------------#
  36 => {
    :name => "Inverse Field",
    :abbr => "IF",
    :message => "!trats elttaB",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :special => ["Nature Power calls Trick Room. Camouflage makes the user Normal-type. Secret Power may confuse the target."]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => ["Mimicry makes the user Normal-type."],

    # (The following items are affected by this field):
    :itemEffects => ["Magical Seed grants Normalize and changes a non-Normal holder to Normal."],

    # (Other effects):
    :passiveEffects => ["The type chart is inverted. This also changes the type effectiveness applied to entry hazards."],

    # (How this field is created):
    :createdBy => {
      :moves => ["Topsy-Turvy"],
      :note => "On an empty field, Topsy-Turvy creates Inverse Field for 3 turns, or 6 with Amplifield Rock."
    }
  },
  #----------------- 37. Psychic Terrain [PT] -------------------#
  37 => {
    :name => "Psychic Terrain",
    :abbr => "PT",
    :message => "The field became mysterious!",

    # (Overlay):
    :overlayEffects => {
      :terrain => "Psychic Terrain",
      :effects => ["The overlay boosts eligible Psychic attacks and the same six selected moves by 1.3x. Anticipation raises Special Attack on entry."]
    },

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Psychic attacks from users vulnerable to Ground", "Hex", "Magical Leaf", "Mystical Fire", "Moonblast", "Aura Sphere", "Mind Blown"]
      },
      :additionalDamageType => {
        "Psychic" => ["Strength", "Ancient Power", "Dragon Pulse", "Water Pulse"]
      },
      :statChanges => [
        "Nasty Plot drastically raises the user's Special Attack.",
        "Calm Mind sharply raises the user's Special Attack and Special Defense.",
        "Cosmic Power sharply raises the user's Defense and Special Defense."
      ],
      :durationChange => {
        "Gravity, Trick Room, Magic Room, and Wonder Room" => 8
      },
      :special => [
        "Expanding Force gets its Psychic Terrain enhancement when its user is grounded. Terrain Pulse becomes Psychic-type.",
        "Psych Up, Mind Reader, and Miracle Eye can sharply raise the user's Special Attack. Telekinesis also sharply lowers the target's Defense and Special Defense.",
        "Nature Power calls Psychic. Camouflage makes the user Psychic-type. Secret Power and Shattered Psyche can confuse their target."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Pure Power doubles Special Attack instead of Attack. Anticipation and Forewarn sharply raise Special Attack on entry.",
      "Telepathy doubles Speed. Zen Mode can activate. Mimicry makes the user Psychic-type."
    ],

    # (The following items are affected by this field):
    :itemEffects => ["Magical Seed raises Special Attack and Special Defense, and can confuse the holder."],

    # (Other effects):
    :passiveEffects => ["Priority attacks are blocked against opponents even if the target is airborne. Headstrong can bypass the block."],

    # (How this field is created):
    :createdBy => {
      :moves => ["Psychic Terrain", "Genesis Supernova"],
      :abilities => ["Psychic Surge"],
      :note => "A Psychic Terrain effect over another field uses the overlay rules."
    }
  },
  #----------------- 38. Dimensional Field [DF] -------------------#
  38 => {
    :name => "Dimensional Field",
    :abbr => "DF",
    :message => "Darkness radiates.",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.2 => ["Ghost attacks", "Dark Pulse", "Night Daze"],
        1.5 => ["Dark attacks", "Shadow attacks", "Hyperspace Fury", "Hyperspace Hole", "Spacial Rend", "Roar of Time", "Dynamax Cannon", "Eternabeam", "Shadow Force"],
        1.3 => ["Blizzard", "Cold Truth", "Ice Burn", "Freeze Shock", "Glaciate", "Sheer Cold"]
      },
      :powerDecrease => {0.5 => ["Fairy attacks"]},
      :accuracyChange => {100 => ["Dark Pulse and Night Daze skip the accuracy check"]},
      :durationChange => {
        "Gravity, Trick Room, Magic Room, and Wonder Room" => "3 to 8 rounds"
      },
      :fail => ["Sunny Day", "Rain Dance", "Sandstorm", "Hail", "Lucky Chant", "Teatime"],
      :special => [
        "Dig, Dive, Fly, or Bounce can take the user's full HP on the charging turn. Sturdy, Wide Guard, and Mat Block can protect the user.",
        "Nature Power calls Dark Pulse. Camouflage makes the user Dark-type. Secret Power can flinch a sleeping or frozen target."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => ["Shadow Shield doubles effective defenses. Rattled raises Speed on entry. Mimicry makes the user Dark-type."],

    # (The following items are affected by this field):
    :itemEffects => [
      "Magical Seed raises Defense and toggles Trick Room.",
      "Rift Seed sharply raises the holder's highest stat among Attack, Defense, Special Attack, Special Defense, and Speed."
    ],

    # (Other effects):
    :passiveEffects => [
      "Sleeping Pokémon and Pokémon under Heal Block lose 1/16 of maximum HP each round for each applicable effect.",
      "Shadow Sky deals 1/8 of maximum HP each round to eligible Pokémon. Embargo traps its target. Obstruct blocks status effects."
    ],

    # (Field transformations):
    :fieldTransformations => {
      :transformsTo => {
        "Frozen Dimensional Field" => ["Blizzard", "Cold Truth", "Ice Burn", "Freeze Shock", "Glaciate", "Sheer Cold"],
        "Infernal Field" => ["Precipice Blades"]
      },
      :terminates => ["Seed Flare or Purify when Shadow Sky is absent"]
    }
  },
  #----------------- 39. Frozen Dimensional Field [FDF] -------------------#
  39 => {
    :name => "Frozen Dimensional Field",
    :abbr => "FDF",
    :message => "Hate and anger radiates.",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.2 => ["Dark attacks", "Surf", "Muddy Water", "Water Pulse", "Hydro Pump", "Night Slash", "Dark Pulse", "Hyperspace Fury", "Hyperspace Hole"],
        1.3 => ["Blast Burn", "Inferno", "Lava Plume", "Heat Wave", "Eruption", "Flame Burst", "Burn Up", "Inferno Overdrive"],
        1.5 => ["Ice attacks"]
      },
      :powerDecrease => {0.5 => ["Fire attacks"]},
      :additionalDamageType => {
        "Ice" => ["Surf", "Water Pulse", "Dark Pulse", "Night Slash", "Hydro Pump", "Muddy Water"]
      },
      :fail => ["Gravity", "Magic Room", "Trick Room", "Wonder Room", "Teatime", "Court Change"],
      :special => [
        "Freeze Shock and Ice Burn attack immediately. Stored Power and Power Trip start at 60 base power before their boosts.",
        "Parting Shot also lowers Speed.",
        "Nature Power calls Ice Beam. Camouflage makes the user Ice-type. Secret Power may freeze the target."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Slush Rush doubles Speed without hail. Ice Face can absorb special attacks as well as physical attacks.",
      "Blaze, Flare Boost, and Flash Fire damage bonuses are suppressed. Rattled raises Speed on entry. Mimicry makes the user Ice-type."
    ],

    # (The following items are affected by this field):
    :itemEffects => [
      "Elemental Seed sharply raises Speed and subjects the holder to Torment unless protected by Oblivious.",
      "Rift Seed raises the holder's highest stat among Attack, Defense, Special Attack, Special Defense, and Speed."
    ],

    # (Other effects):
    :passiveEffects => ["Hail and Shadow Sky deal 1/8 of maximum HP each round to eligible Pokémon."],

    # (Field transformations):
    :fieldTransformations => {
      :transformsTo => {
        "Dimensional Field" => ["Heat Wave", "Eruption", "Inferno", "Flame Burst", "Lava Plume", "Blast Burn", "Burn Up", "Inferno Overdrive"],
        "Icy Field" => ["Purify"]
      }
    }
  },
  #----------------- 40. Cursed Field [CF] -------------------#
  40 => {
    :name => "Cursed Field",
    :abbr => "CF",
    :message => "The field is cursed!",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.3 => ["Dark attacks", "Wind moves", "Flame Burst", "Inferno", "Flame Charge", "Fire Spin"],
        1.5 => ["Ghost attacks", "Spirit Break", "Night Shade's fixed damage"]
      },
      :powerDecrease => {0.7 => ["Fairy attacks"]},
      :additionalDamageType => {
        "Ghost" => ["Flame Burst", "Inferno", "Flame Charge", "Fire Spin"]
      },
      :accuracyChange => {90 => ["Inferno"]},
      :special => [
        "Ghost attacks hit Normal. Ghost and Dark attacks hit each other neutrally. Spirit Break is super effective against Ghost.",
        "Phantom Force and Shadow Force attack immediately. Fire Spin, Mean Look, Ominous Wind, and Inferno may target both opponents.",
        "Spite removes 6 PP. Scary Face drastically lowers Speed by four stages. Ghost-type Curse costs a quarter of maximum HP.",
        "Magic Powder can put the target to sleep. Destiny Bond may be used consecutively. Fire Spin deals 1/6 of a trapped, unshielded target's maximum HP each round.",
        "Nature Power calls Phantom Force. Camouflage makes the user Ghost-type. Secret Power may apply Curse."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Mummy traps its bearer. Shadow Tag can ignore a target's protective abilities.",
      "Cursed Body can activate when the bearer faints. Wandering Spirit lowers Speed each round. Rattled raises Speed on entry. Mimicry makes the user Ghost-type."
    ],

    # (The following items are affected by this field):
    :itemEffects => ["Magical Seed raises Defense and Special Defense, and can burn the holder."],

    # (Other effects):
    :passiveEffects => [
      "Sleeping non-Ghost Pokémon lose 1/16 of maximum HP each round. An opposing Shadow Tag user increases this to 1/8 for unshielded targets."
    ],

    # (How this field is created):
    :createdBy => {
      :moves => ["Curse used by a Ghost type on Blessed Field", "Trick-or-Treat on Blessed Field"]
    },

    # (Field transformations):
    :fieldTransformations => {
      :transformsTo => {"Blessed Field" => ["Judgment", "Sacred Fire", "Origin Pulse"]},
      :disables => ["Flash, Dazzling Gleam, and Purify can suppress it for three rounds outside protected story battles."]
    }
  },
  #----------------- 41. Corrupted Cave [CC] -------------------#
  41 => {
    :name => "Corrupted Cave",
    :abbr => "CC",
    :message => "Corruption seeps from every crevice!",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {1.2 => ["Rock and Grass attacks"], 1.5 => ["Poison attacks", "Seed Flare", "Apple Acid"]},
      :powerDecrease => {0.5 => ["Fairy attacks", "Non-contact Flying attacks"]},
      :additionalDamageType => {
        "Poison" => ["Rock Slide", "Smack Down", "Stone Edge", "Rock Tomb", "Diamond Storm", "Apple Acid"],
        "Rock" => ["Gunk Shot", "Sludge Wave"]
      },
      :special => [
        "Tar Shot can also poison. Toxic Thread inflicts bad poison. Ingrain harms eligible grounded Pokémon. Stealth Rock deals Poison-type damage.",
        "Heat Wave, Blast Burn, Eruption, and Lava Plume combust the cave, dealing half of maximum HP to exposed Pokémon unless Damp prevents it.",
        "Nature Power calls Gunk Shot. Camouflage makes the user Poison-type. Secret Power may poison."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => ["Without sun or rain, Dry Skin heals Poison holders or damages other non-Steel holders by 1/8 of maximum HP. Mimicry makes the user Poison-type."],

    # (The following items are affected by this field):
    :itemEffects => [
      "Black Sludge effects are doubled.",
      "Synthetic Seed sharply raises Defense and can badly poison the holder."
    ],

    # (Other effects):
    :passiveEffects => [
      "Each round, grounded non-Poison Pokémon may be poisoned. Bosses, Immunity, Pastel Veil, and normal poison immunities prevent this.",
      "Leaf Guard, Flower Veil, and Grass-associated Silvally lose 1/8 of maximum HP each round. Grounded Poison Heal users recover 1/8 if healing is allowed."
    ],

    # (Field transformations):
    :fieldTransformations => {
      :transformsTo => {
        "Cave" => ["Seed Flare", "Purify", "Solar Beam", "Solar Blade"],
        "Volcanic Field" => ["Heat Wave", "Blast Burn", "Eruption", "Lava Plume", "Inferno Overdrive"]
      }
    }
  },
  #----------------- 42. Bewitched Woods [BW] -------------------#
  42 => {
    :name => "Bewitched Woods",
    :abbr => "BW",
    :message => "Double, double toil and trouble...",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.3 => ["Dark attacks", "Fairy attacks without a Misty Terrain overlay", "Magical Leaf", "Dream Eater", "Dark Pulse", "Night Daze", "Moonblast", "Night Slash"],
        1.5 => ["Grass attacks without a Grassy Terrain overlay", "Hex", "Mystical Fire", "Spirit Break"]
      },
      :durationChange => {
        "Grassy Terrain overlay" => 8
      },
      :special => [
        "Grass attacks are super effective against Steel. Poison and Fairy attacks hit each other neutrally, as do Dark and Fairy attacks.",
        "Magic Powder may also put its target to sleep. Forest's Curse also applies Curse.",
        "Nature Power calls Dazzling Gleam. Camouflage makes the user Fairy-type. Secret Power may cause sleep, poison, or paralysis."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Prankster can affect Dark Pokémon. Natural Cure can heal major status at the end of the round.",
      "Pastel Veil and Aroma Veil halve the effectiveness of Steel attacks against the holder. Mimicry makes the user Fairy-type."
    ],

    # (The following items are affected by this field):
    :itemEffects => ["Magical Seed raises Special Defense and applies Ingrain."],

    # (Other effects):
    :passiveEffects => [
      "Sleeping Pokémon lose 1/8 of maximum HP per round, or 1/16 if shielded.",
      "Grounded Grass Pokémon heal 1/16 of maximum HP per round, or 1/8 with a Grassy Terrain overlay. Big Root improves the healing."
    ],

    # (Field transformations):
    :fieldTransformations => {
      :transformsTo => {"Forest Field" => ["Purify"]}
    }
  },
  #----------------- 43. Sky Field [SF] -------------------#
  43 => {
    :name => "Sky Field",
    :abbr => "SF",
    :message => "The sky is filled with clouds.",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.5 => ["Flying attacks", "Wind moves", "Sky Uppercut", "Flying Press", "Thunder Shock", "Thunderbolt", "Thunder", "Steel Wing", "Dragon Darts", "Grav Apple", "Dragon Ascent"],
        1.3 => ["Smack Down", "Thousand Arrows", "Grav Apple"]
      },
      :additionalDamageType => {"Flying" => ["Dive", "Twister"]},
      :accuracyChange => {100 => ["Thunder and Hurricane skip the accuracy check"]},
      :durationChange => {"Standard weather moves and Tailwind" => 8},
      :fail => ["Earthquake", "Magnitude", "Bulldoze", "Dig", "Rototiller", "Spikes", "Toxic Spikes", "Sticky Web", "Mystic Harvest"],
      :special => [
        "Tailwind can bring Strong Winds. Weather Ball is doubled in power and becomes Flying.",
        "Razor Wind, Sky Attack, Fly, and Bounce skip their charging turn. Flying Press's Flying component ignores resistances.",
        "Nature Power calls Sky Attack. Camouflage makes the user Flying-type. Secret Power may confuse."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Gale Wings works regardless of HP. Big Pecks raises Defense on entry. Levitate, Solar Idol, and Lunar Idol raise Speed on entry. Mimicry makes the user Flying-type."
    ],

    # (The following items are affected by this field):
    :itemEffects => ["Elemental Seed lowers Defense and Special Defense while setting Tailwind for eight rounds."],

    # (Field transformations):
    :fieldTransformations => {
      :transformsTo => {
        "Mountain" => ["Gravity", "Ingrain", "Thousand Arrows", "Two total uses of Smack Down or Grav Apple"]
      }
    }
  },
  #----------------- 44. Colosseum Field [COL] -------------------#
  44 => {
    :name => "Colosseum Field",
    :abbr => "COL",
    :message => "All eyes are on the combatants!",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.2 => ["Storm Throw", "Wood Hammer", "Dragon Hammer", "Power Whip", "Spirit Shackle", "Drill Run", "Drill Peck", "Ice Hammer", "Icicle Spear", "Anchor Shot", "Crabhammer", "Shadow Bone", "Fire Lash", "Sucker Punch", "Throat Chop"],
        1.5 => ["Sacred Sword", "Secret Sword", "Submission", "Meteor Assault", "Smart Strike", "Smack Down", "Brutal Swing", "Electroweb", "Vine Whip", "Psycho Cut", "Night Slash", "Bonemerang", "First Impression", "Bone Rush", "Bone Club", "Leaf Blade", "Payback", "Punishment", "Meteor Mash", "Bullet Punch", "Clanging Scales", "Steamroller"],
        2.0 => ["Beat Up", "Fell Stinger", "Pay Day", "Reversal", "Pursuit"]
      },
      :powerDecrease => {0.5 => ["Flying attacks"]},
      :statChanges => [
        "Swords Dance drastically raises the user's Attack."
      ],
      :fail => ["Baton Pass", "Encore"],
      :special => [
        "Roar and Whirlwind can sharply raise the user's Attack instead of forcing the target out.",
        "Nature Power calls Beat Up. Camouflage makes the user Steel-type. Secret Power may raise the user's Attack."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Dauntless Shield, Battle Armor, and Shell Armor raise Defense on entry.",
      "Dauntless Shield, Mirror Armor, and Magic Guard raise Special Defense on entry.",
      "Intrepid Sword, No Guard, and Justified raise Attack and Special Attack on entry. Mimicry makes the user Steel-type.",
      "Defiant also sharply raises Defense, and Competitive also sharply raises Special Defense."
    ],

    # (The following items are affected by this field):
    :itemEffects => ["Synthetic Seed sharply raises Attack and Taunts the holder for four rounds."],

    # (Other effects):
    :passiveEffects => [
      "Voluntary switching is blocked. Shed Shell and Run Away bypass the field's switch restriction.",
      "Knocking out a target raises the user's stat corresponding to the target's highest stat.",
      "Wonder Guard protects its bearer from many sources of indirect damage, including entry hazards, poison, burn, and recoil."
    ]
  },
  #----------------- 45. Infernal Field [INF] -------------------#
  45 => {
    :name => "Infernal Field",
    :abbr => "INF",
    :message => "The souls of the damned burn on.",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {1.5 => ["Fire attacks", "Dark attacks", "Inferno Overdrive"], 2.0 => ["Punishment", "Smog", "Dream Eater"]},
      :powerDecrease => {0.5 => ["Fairy and Water attacks, except Spirit Break"]},
      :additionalDamageType => {"Dark" => ["Aura Sphere", "Frustration", "Spirit Break"], "Fire" => ["Ground, Steel, and Rock attacks"]},
      :accuracyChange => {100 => ["Inferno skips the accuracy check"]},
      :statChanges => [
        "Nasty Plot drastically raises the user's Special Attack."
      ],
      :special => [
        "Fire attacks hit Ghost super effectively. Hex gets its status-based boost against healthy targets. Stealth Rock deals Fire-type damage.",
        "Nature Power calls Punishment. Camouflage makes the user Fire-type. Secret Power may burn."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Blaze can activate above one-third HP. Grounded Flash Fire users activate the boost at the end of the round. Flame Body and Desolate Land raise both defenses on entry.",
      "Pastel Veil loses its protection against poison. Steam Engine raises Speed each round. Ice Face melts on entry. Mimicry makes the user Fire-type."
    ],

    # (The following items are affected by this field):
    :itemEffects => ["Elemental Seed raises Attack and Special Attack and traps the holder."],

    # (Other effects):
    :passiveEffects => [
      "Rain and hail end immediately. Grounded Pokémon under Torment lose 1/8 of maximum HP each round."
    ],

    # (Field transformations):
    :fieldTransformations => {
      :transformsTo => {
        "Volcanic Field" => ["Judgment", "Origin Pulse"],
        "Frozen Dimensional Field" => ["Glaciate"]
      }
    }
  },
  #----------------- 46. Beach Field [BF] -------------------#
  46 => {
    :name => "Beach Field",
    :abbr => "BF",
    :message => "The waves lap at the shore.",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.3 => ["Water and Ground attacks", "Surf", "Muddy Water", "Scald", "Steam Eruption", "Wind moves"],
        1.5 => ["Electric attacks", "Sand Tomb", "Thousand Waves", "Scorching Sands", "Burn Up", "Razor Shell", "Whirlpool"]
      },
      :additionalDamageType => {"Ground" => ["Wind moves"]},
      :statChanges => [
        "Sand Attack sharply lowers the target's Accuracy."
      ],
      :durationChange => {"Sun, Sand Tomb, Whirlpool, and Dune Defense" => 8},
      :special => [
        "Shore Up heals 66% of maximum HP. It also sharply raises the Defense of users with Water Compaction.",
        "The Sand Tomb effect from Dust Bowl lasts eight turns.",
        "Nature Power calls Scorching Sands. Camouflage makes the user Ground-type. Secret Power may lower Accuracy."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Sand Rush and Swift Swim double Speed without their usual weather. Sand Spit can lower the attacker's Accuracy.",
      "Without sun or rain, Dry Skin loses 1/8 of maximum HP each round. Shell Armor raises Defense and Special Defense on entry. Mimicry makes the user Ground-type."
    ],

    # (The following items are affected by this field):
    :itemEffects => ["Telluric Seed raises Speed and Accuracy and traps the holder in Sand Tomb for four rounds."],

    # (Field transformations):
    :fieldTransformations => {
      :transformsTo => {"Ashen Beach" => ["Lava Plume", "Eruption"], "Water Surface" => ["Origin Pulse", "Hydro Vortex"]}
    }
  },
  #----------------- 47. Library Field [LIB] -------------------#
  47 => {
    :name => "Library Field",
    :abbr => "LIB",
    :message => "Pages flutter around!",

    # (The following moves are affected by this field.):
    :moveEffects => {
      :powerBoost => {
        1.3 => ["Fire attacks", "Special Psychic attacks", "Slashing and wind moves", "Focus Punch", "Focus Blast", "Return", "Frustration", "Perforate"],
        1.5 => ["Smart Strike", "Ancient Power", "Barrage", "Headbutt", "Zen Headbutt", "Iron Head", "Head Smash", "Head Charge", "Skull Bash", "Mind Blown"],
        2.25 => ["Fire Spin and Whirlpool, before other applicable bonuses and damage rounding"]
      },
      :accuracyChange => {100 => ["Focus Blast skips the accuracy check"]},
      :special => [
        "Calm Mind sharply raises Special Attack and Special Defense. Amnesia drastically raises Special Defense. Focus Energy drastically raises the user's critical-hit ratio.",
        "Taking damage no longer interrupts Focus Punch. Helping Hand multiplies damage by two.",
        "Roar, Whirlwind, and Telekinesis deal 1/6 of maximum HP in addition to their ordinary effects.",
        "Fire Spin, Whirlpool, Mean Look, Ominous Wind, and Inferno can target both opponents.",
        "Nature Power calls Calm Mind. Camouflage makes the user Normal-type. Secret Power may silence."
      ]
    },

    # (The following abilities are affected by this field):
    :abilityEffects => [
      "Analytic's multiplier increases to 1.5x. Technician can boost moves of up to 80 base power."
    ],

    # (The following items are affected by this field):
    :itemEffects => ["Synthetic Seed drastically raises the holder's critical-hit ratio."],

    # (Other effects):
    :passiveEffects => [
      "Silenced Pokémon have half Speed. Pokémon hit while confused take double damage.",
      "Sound moves can silence their user for three rounds. A silenced user cannot use sound moves."
    ]
  },
}

# Helper method to get field effect data by ID
def pbGetFieldEffectData(fieldID)
  return FIELDEFFECTDATA[pbFieldEffectID(fieldID)] #pk code
end

#pk code
def pbFieldEffectID(fieldID)
  return fieldID==50 ? 47 : fieldID
end

# Helper method to get field effect name
def pbGetFieldEffectName(fieldID)
  return _INTL("No Field") if fieldID==0 #pk code
  data = pbGetFieldEffectData(fieldID)
  return data ? data[:name] : "Unknown Field"
end

# Helper method to get field message
def pbGetFieldEffectMessage(fieldID)
  data = pbGetFieldEffectData(fieldID)
  return data ? data[:message] : ""
end
