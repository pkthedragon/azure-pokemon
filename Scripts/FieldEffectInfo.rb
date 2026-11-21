# Field Effect Information Database
# Data structure for all field effects and their mechanics
# Transforming or destroying any field effect grants a x1.3 power bonus.

#pk code
FIELDEFFECTDATA = {
  #----------------- 1. Electric Terrain [ET] -------------------#
  1 => {
    :name => "Electric Terrain",
    :abbr => "ET",
    :message => "The field is hyper-charged!",
    :manualText => [
      "#----------------- 1. Electric Terrain [ET] -------------------#",
      "\"The field is hyper-charged!\"",
      "(Passive effects by the field.):",
      "*\tDouble shocked Pokemon regain their type at the end of the turn.",
      "",
      "(Overlay):",
      "Electric Terrain:",
      "*\tDamage from recoil and crashing is reduced 0.5x.",
      "*\tElectric moves from grounded Pokemon increase in base power x1.3",
      "*\tExplosive and Bomb moves deal 1.3x damage.",
      "*\tIf Electric Terrain is active on Short-Circuit, max boost rolls",
      "*\tGalvanize's damage increase is 1.5.x",
      "",
      "(The following moves are affected by this field.):",
      "*\tDamage from recoil and crashing is nullified.",
      "*\tElectric moves from grounded Pokemon increase in base power x1.5",
      "*\tThese moves deal additional Electric type damage and increase in base power x1.5:",
      "Surf\t\t\tMuddy Water\tHurricane\t\tSmack Down\t\tThousand Arrows     \tHydro Vortex",
      "*\tFocus Punch will always fail",
      "*\tThe stat-changing effect of these moves is amplified:",
      "\t\tCharge\t\t\tEerie Impulse",
      "*\tPlasma Fists increases in base power x2",
      "*\tExplosive and Bomb moves deal 1.5x damage.\t",
      "*\tMagnet Rise lasts for 8 turns",
      "*\tNature Power becomes Thunderbolt",
      "*\tCamouflage changes the user's type to Electric",
      "*\tSecret Power may Paralyze",
      "",
      "(The following abilities are affected by this field):",
      "*\tGalvanize boosts attacks to 1.5 instead of 1.2",
      "*\tSurge Surfer is activated",
      "*\tGulp Missile always picks up Pikachu.",
      "*\tMimicry changes the user's type to Electric",
      "",
      "(The following items are affected by this field):",
      "*\tElemental Seed boosts defense and applies to Charge to the user.",
      "",
      ""
    ].join("\n")
  },

  #----------------- 2. Grassy Terrain [GT] -------------------#
  2 => {
    :name => "Grassy Terrain",
    :abbr => "GT",
    :message => "The field is in full bloom.",
    :manualText => [
      "#------------------ 2. Grassy Terrain [GT] ------------------#",
      "\"The field is in full bloom.\"",
      "",
      "(Passive effects by the field.):",
      "*\tGrounded Pokemon restore 1/16th max hp at the end of the turn",
      "",
      "(Overlay):",
      "Grassy Terrain:",
      "*\tGrass moves from grounded Pokemon increase in base power x1.3",
      "*\tThese moves suffer a x0.5 decrease of power:",
      "\t\tMuddy Water\t\tSurf\tEarthquake\t\tMagnitude",
      "\t\tBulldoze",
      "",
      "(The following moves are affected by this field.):",
      "*\tGrass moves from grounded Pokemon increase in base power x1.5",
      "*\tFire moves against grounded Pokemon increase in base power x1.5",
      "*\tWind moves increase in base power x1.5",
      "*\tThese moves suffer a x0.5 decrease of power:",
      "\t\tMuddy Water\t\tSurf\tEarthquake\t\tMagnitude",
      "\t\tBulldoze",
      "*\tThese moves gain double their normal stat-changing effects:",
      "\t\tGrowth\t\t\tCoil",
      "*\tFloral Healing restores 66% of the user's Max HP",
      "*\tNature Power becomes Energy Ball",
      "*\tSnap Trap deals 1/6 Max HP damage per turn (from 1/8)",
      "*\tCamouflage changes the user's type to Grass",
      "*\tSecret Power may induce Sleep",
      "*\tNature's Madness deals 75% HP damage (From 50%)",
      "",
      "(The following abilities are affected by this field):",
      "*\tMimicry changes the user's type to Grass",
      "*\tCotton Down lowers speed by two stages.",
      "",
      "(The following items are affected by this field):",
      "*\tElemental Seed boosts Defense and applies Ingrain to the user",
      "",
      "",
      "",
      ""
    ].join("\n")
  },

  #----------------- 3. Misty Terrain [MT] -------------------#
  3 => {
    :name => "Misty Terrain",
    :abbr => "MT",
    :message => "Mist settles on the field.",
    :manualText => [
      "#------------------- 3. Misty Terrain [MT] --------------------#",
      "\"Mist settles on the field.\"",
      "",
      "(Passive effects by the field.):",
      "*\tAll Pokemon are immune to status conditions",
      "*\tHail and Rain last for 8 turns",
      "",
      "(Overlay):",
      "Misty Terrain:",
      "*\tFairy-type attacks from grounded Pokemon deal 1.3x damage.",
      "*\tAura/Pulse moves deal 1.3x damage.",
      "",
      "(The following moves are affected by this field.):",
      "*\tFairy-type attacks from grounded Pokemon deal 1.5x damage.",
      "*\tDragon-type moves decrease in base power x0.5",
      "*\tPulse moves deal 1.5x damage.",
      "*\tThese moves increase in base power x1.5:",
      "Mist Ball\t\tSteam Eruption",
      "Strange Steam\tClear Smog\t\tSmog",
      "*\tThese moves increase in base power x1.3",
      "\t\tHidden Power\t\tSecret Power\t\tAncient Power",
      "\t\tStored Power\t\t",
      "*\tAromatic Mist, Mist, and Haze increase Defense and Special Defense of the user and allies",
      "* \tSweet Scent lowers Defense and Special Defense",
      "* \tAqua Ring restores 1/8 Max HP each turn",
      "*\tEnables Aurora Veil",
      "*\tNature Power becomes Mist Ball",
      "*\tCamouflage changes the user's type to Fairy",
      "*\tSecret Power may lower Special Attack",
      "",
      "(The following abilities are affected by this field):",
      "*\tThe ability Marvel Scale is activated",
      "*\tThe ability Water Compaction is activated",
      "*\tSoul Heart additionally boosts Special Defense on use",
      "*\tPokemon with the ability Dry Skin recover 1/16 Max HP each turn",
      "*\tPower Spot's power boost becomes x1.5",
      "*\tPixilate's base power boost becomes x1.5",
      "*\tRefrigerate's base power boost becomes x1.5",
      "*\tPastel Veil halves the damage taken from Poison Type attacks for user and allies",
      "*\tMimicry changes the user's type to Fairy",
      "",
      "(The following items are affected by this field):",
      "*\tElemental Seed boosts Special Defense and applies Healing Wish to the user",
      ""
    ].join("\n")
  },

  #----------------- 4. Dark Crystal Cavern [DCC] -------------------#
  4 => {
    :name => "Dark Crystal Cavern",
    :abbr => "DCC",
    :message => "Darkness is gathering...",
    :manualText => [
      "#---------------- 4. Dark Crystal Cavern [DCC] -----------------#",
      "\"Darkness is gathering...\"",
      "(The following moves are affected by this field.):",
      "*\tThese moves increase in base power x1.5:",
      "\t\tDark Pulse\t\tNight Daze\t\tNight Slash\t\tShadow Ball\t\tShadow Claw",
      "\t\tShadow Force\t\tShadow Sneak\t\tShadow Punch\t\tAurora Beam\t\tSignal Beam",
      "\t\tFlash Cannon\t\tLuster Purge\t\tDazzling Gleam\t\tMirror Shot\t\tDoom Desire",
      "\t\tTechnoblast \t\tPower Gem               Moongeist Beam          Shadow Bone",
      "\t\tBlack Hole Eclipse  Menacing Moonraze Maelstrom",
      "*\tThese moves increase in base power x2:",
      "        Prismatic Laser         ",
      "*\tThese moves gain double their normal stat-changing effects:",
      "\t\tFlash",
      "*\tThe base accuracy of these moves becomes 100:",
      "\t\tDark Void",
      "*\tSolar Beam and Solar Blade always fail.",
      "*\tEnables Aurora Veil",
      "*\tMoonlight restores 75% of the user's Max HP",
      "* \tNature Power becomes Dark Pulse",
      "*\tCamouflage changes the user's type to Dark",
      "*\tSecret Power may lower Accuracy",
      "*\tSynthesis and Morning Sun restores 25% of the user's Max HP",
      "(The following abilities are affected by this field):",
      "*   Prism Armor and Shadow Shield Pokemon take x0.5 decreased damage",
      "(The following moves change this field):",
      "* \tTemporarily transformed by sunny weather into Crystal Cavern",
      "*\tTwo uses of these moves will transform this field into a Cave:\t",
      "\t\tEarthquake\t\tBulldoze\t\tMagnitude\t\tTectonic Rage",
      "(The following items are affected by this field):",
      "*\tMagical Seed boosts Sp.Def and applies Magic Coat to the user",
      "",
      "",
      ""
    ].join("\n")
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
    :manualText => [
      "#---------------- 8. Swamp Field [SF] -------------------#",
      "\"The field is swamped.\"",
      "(Passive effects by the field.):",
      "*\tAt the end of each turn the speed of each grounded Pokemon is reduced one stage",
      "*\tSleeping Pokemon suffer 1/16 Max HP damage each turn",
      "*   Pokemon under the effects of Trapping moves lose double speed at the end of the turn.",
      "*   Sleeping Pokemon under the effect of Trapping moves take double damage.",
      "(The field can be created by):",
      "*\tCreated by Water Pledge + Grass Pledge",
      "*\tPoison moves against grounded Pokemon increase in base power x1.5",
      "(The following moves are affected by this field.):",
      "*\tThese moves increase in base power x1.5:",
      "\t\tMud Bomb \t\tMud Shot\t\tMud Slap \t\tMuddy Water \t\tSurf\t\t\t",
      "\t\tSludge Wave \t\tGunk Shot \t\tBrine \t\t\tSmack Down\t\tThousand Arrows",
      "\t\tHydro Vortex",
      "*   These moves deal part Water Type damage:",
      "        Smack Down      Thousand Arrows",
      "* \tPrevents use of Selfdestruct and Explosion",
      "*\tNature Power becomes Muddy Water",
      "*\tCamouflage changes the user's type to Water",
      "*\tSecret Power may lower Speed",
      "* \tAqua Ring restores 1/8 Max HP each turn (from 1/16)",
      "*\tStrength Sap heals 30% more HP\t",
      "*\tThe base accuracy of these moves becomes 100:",
      "\t\tSleep Powder\t",
      "*\tIngrain damages its user instead of heals, unless the user is Poison or Steel type.",
      "(The following abilities are affected by this field):",
      "*\tPokemon with the following abilities are immune to the field slow:",
      "\t\tClear Body\t\tQuick Feet\t\tSwift Swim\t\tWhite Smoke",
      "\t\tPropellor Tail",
      "*\tThe effect of Gooey is doubled.",
      "*   Activates Water Compaction each turn",
      "*\tPokemon with the ability Dry Skin recover 1/16 Max HP each turn",
      "*   Gulp Missile always picks up Arrokuda",
      "*   Mimicry changes the user's type to Water.",
      "(The following items are affected by this field):",
      "*       Telluric Seed boosts Defense and Sp. Def and applies Ingrain to the user",
      "",
      "",
      "",
      "",
      ""
    ].join("\n")
  },

  #----------------- 9. Rainbow Field [RBF] -------------------#
  9 => {
    :name => "Rainbow Field",
    :abbr => "RBF",
    :message => "What does it mean?",
    :manualText => [
      "#---------------- 9. Rainbow Field [RBF] -----------------#",
      "\"What does it mean?\"",
      "(Passive effects by the field.):",
      "*\tThe secondary effect chance of all moves is doubled",
      "* \tSleep Pokemon recover 1/16 Max HP each turn",
      "(The field can be created by):",
      "*\tCreated by Fire Pledge + Water Pledge, or by cancelling Rainy or Sunny weather with its opposite",
      "(The following moves are affected by this field.):",
      "*\tSpecial Normal moves increase in base power x1.5 and apply damage of a random type",
      "*\tThese moves increase in base power x1.5:",
      "\t\tSilver Wind\t\tMystical Fire \t\tDragon Pulse \t\tTri Attack \t\tSacred Fire ",
      "\t\tFire Pledge\t\tWater Pledge\t\tGrass Pledge\t\tAurora Beam \t\tJudgment ",
      "\t\tRelic Song\t\tHidden Power \t\tSecret Power \t\tWeather Ball \t\tMist Ball ",
      "\t\tHeart Stamp \t\tMoon Blast\t\tZen Headbutt            Sparkling Aria      Fleur Cannon",
      "\t\tPrismatic Laser         Twinkle Tackle",
      "*\tThese moves suffer a x0.5 decrease of power:",
      "\t\tDark Pulse\t\tNight Daze\t\tShadow Ball\t\tNever-ending Nightmare",
      "*\tThe following moves' stat-boosting effect is amplified:",
      "\t\tMeditate\t\t\tCosmic Power",
      "*\tSonicboom deals 140 flat HP damage",
      "*   Life Dew restores 50% of the user's Max HP",
      "*\tWish restores 75% of the user's Max HP (from 50%)",
      "*       Enables Aurora Veil",
      "*\tNightmare and Bad Dreams have no effect.",
      "*\tNature Power becomes Aurora Beam",
      "*\tCamouflage changes the user's type to Dragon",
      "*\tSecret Power may inflict any status randomly",
      "(The following abilities are affected by this field):",
      "*\tPrism Armor Pokemon take x0.5 decreased damage",
      "*   Soul Heart additionally boosts Sp. Def on use",
      "*   Pastel Veil halves damage from Poison type attacks.",
      "*\tCloud Nine will randomly boost one stat at the end of each turn",
      "* \tThe ability Marvel Scale is activated",
      "*   Mimicry changes the user's type to Dragon.",
      "*\tWonderskin will evade all status moves (from 50%)",
      "(The following moves change this field):",
      "*\tTerminated by Sand and Hail",
      "",
      "(The following items are affected by this field):",
      "*       Magical Seed boosts Sp.Atk and applies Healing Wish to the user",
      ""
    ].join("\n")
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
    :manualText => [
      "#---------------- 13. Icy Field  [IF] ----------------#",
      "\"The field is covered in ice.\"",
      "(Passive effects by the field.):",
      "*\tPhysical positive priority and momentum moves raise Speed.",
      "*\tBeam moves deal 1.3x damage.",
      "",
      "(The following moves are affected by this field.):",
      "*\tHail lasts for 8 turns\t",
      "*\tIce type attacks have a double chance to freeze",
      "*\tIce moves increase in base power x1.5",
      "*\tFire moves decrease in base power x0.5",
      "*\tThese moves suffer a x0.5 decrease of power:",
      "\t\tScald\t\t\tSteam Eruption",
      "*\tRock-type attacks become Ice-type attacks.",
      "*\tBurn damage is halved",
      "*\tNature Power becomes Ice Beam",
      "*\tCamouflage changes the user's type to Ice",
      "*\tSecret Power may Freeze",
      "*\tEnables Aurora Veil",
      "",
      "(The following abilities are affected by this field):",
      "*\tActivates Ice Body and Snow Cloak",
      "*\tIce Scales also halves physical damage",
      "*\tRefrigerate's base power boost becomes x1.5 (from x1.2)",
      "*\tLiquid Voice's makes attacks Ice type instead of Water.",
      "*\tActivates Slush Rush",
      "*\tMimicry changes the user's type to Ice",
      "",
      "(The following moves change this field):",
      "*\tThese moves will transform this field into the Water Surface.",
      "\t\tHeat Wave\t\tFlame Burst\t\tLava Plume\t\tEruption\t\t\tSearing Shot\t\tFire Pledge\t\tInferno Overdrive       Magma Drift  ",
      "\t\tEarthquake\t\tMagnitude\t\tBulldoze\t\tTectonic Rage",
      "        \t\tDive",
      "",
      "(The following items are affected by this field):",
      "*\tElemental Seed boosts Speed and lowers Accuracy",
      ""
    ].join("\n")
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
    :manualText => [
      "#---------------- 15. Forest Field [FOF] ------------------#",
      "\"The field is abound with trees.\"",
      "(The following moves are affected by this field.):",
      "*\tGrass- and Bug-type Pokémon’s Defense is boosted 1.5x.",
      "*\tGrass and special Bug moves increase in base power x1.5",
      "*\tStrength Sap heals 30% more HP",
      "*\tInfestation deals 1/6 Max HP damage per turn (from 1/8)",
      "*\tAttack Order and Grav Apple deal 1.5x damage.",
      "*\tSlashing and special Fire-type moves deal 1.5x damage and gain the Grass-type.",
      "*\tThese moves suffer a x0.5 decrease of power:",
      "\t\tSurf\t\t\tMuddy Water",
      "*\tNature's Madness deals 75% HP damage (from 50%)",
      "*\tForest's Curse additionally Curses the target",
      "*\tHeal Order restores 66% of the user's Max HP (from 50%)",
      "*\tNature Power becomes Wood Hammer",
      "*\tCamouflage changes the user's type to Bug",
      "*\tSecret Power may raise Attack",
      "",
      "(The stat changing effect of these moves is affected by this field):",
      "*\tThe stat changing effect of these moves is amplified:",
      "\t\tGrowth\t\t\tDefend Order",
      "",
      "(The following abilities are affected by this field):",
      "*\tActivates Overgrow, Swarm, and Leaf Guard",
      "*\tSap Sipper gradually restores HP",
      "*\tEffect Spore puts the target to sleep for two turns instead.",
      "*\tMimicry changes the users type to Bug",
      "",
      "(The following items are affected by this field)",
      "*\tTelluric Seed boosts Attack and applies Spiky Shield to the user",
      ""
    ].join("\n")
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
    :manualText => [
      "#---------------- 17. Factory Field [FAF] -----------------#",
      "\"Machines whir in the background.\"",
      " ",
      "(The following moves are affected by this field.):",
      "*\tElectric moves increase in base power x1.2",
      "*\tGear Up's effect is doubled, and additionally boosts its user",
      "*\tThese moves increase in base power x1.5:",
      "\t\tSteam Roller\t\tTechno Blast",
      "*\tThese moves increase in base power x2:",
      "\t\tFlash Cannon \t\tGyro Ball \t\tGear Grind \t\tMagnet Bomb",
      "\t\tDouble Iron Bash",
      "*   Steel Beam's recoil is set to 25%",
      "*\tThe stat changing effect of these moves is amplified:",
      "\t\tMetal Sound \t\tIron Defense \t\tShift Gear \t\tAutotomize",
      "*\tMagnet Rise lasts for 8 turns",
      "*\tNature Power becomes Gear Grind",
      "*\tCamouflage changes the user's type to Steel",
      "*\tSecret Power may reduce Attack",
      " ",
      "(The following moves change this field):",
      "*\tThese moves will transform this field into a Short-circuit Field:\t\t",
      "\t\tDischarge\t\tExplosion \t\tSelfdestruct \t\tMagnitude \t\tFissure",
      " \t\tEarthquake \t\tIon Deluge\t\tBulldoze\t\t\tTectonic Rage   Gigavolt Havoc",
      "\t\tOverdrive       Aura Wheel",
      "\t\tDischarge additionally can potentially alternate between the Short-circuit Field and the Factory Field for each instance of damage per attack in double battles",
      " ",
      "(The following abilities are affected by this field):",
      "*   Galvanize's boost becomes x1.5 (from x1.2)",
      "*\tSteelworker's damage boost becomes x2 (from x1.5)",
      "*   Download's boost is doubled.",
      "*   Motor Drive's speed boosting effect is doubled.",
      "*   Technician activates with moves of Base Power of 80 or below.",
      "*   Gulp Missile always grabs Pikachu.",
      "*\tMimicry changes the user's type to Steel",
      " ",
      "(The following items are affected by this field):",
      "*       Synthetic Seed boosts Sp. Atk and applies Laser Focus to the user",
      "",
      "",
      ""
    ].join("\n")
  },
  #----------------- 18. Short-circuit Field [SCF] -------------------#
  18 => {
    :name => "Short-circuit Field",
    :abbr => "SCF",
    :message => "Bzzt!",
    :manualText => [
      "#---------------- 18. Short-circuit Field [SCF] -----------------#",
      "\"Bzzt!\"",
      " ",
      "(The following moves are affected by this field.):",
      "*\tElectric attacks amplify a random increment of base power between x0.5 and x2",
      "*\tThese moves increase in base power x1.5:",
      "\t\tDazzling Gleam      Flash Cannon",
      "*   Steel Beam increases in BP by 1.667x and instantly KO's the user. Deals Steel & Electric type damage.",
      "*\tThese moves increase in base power x1.3:",
      "\t\tDark Pulse\t\tNight Daze\t\tNight Slash\t\tShadow Ball\t\tShadow Claw",
      "\t\tShadow Force\t\tShadow Sneak\t\tShadow Punch\t\tShadow Bone",
      "\t\tPhantom Force",
      "*\tThese moves deal additional Electric type damage and increase power x1.5:\t",
      "\t\tSurf \t\t\tMuddy Water\t\tGyro Ball \t\tMagnet Bomb \t",
      " \t\tGear Grind\t\tHydro Vortex",
      "*\tThe stat changing effect of these moves is amplified:",
      "\t\tMetal Sound\t\tFlash",
      "*\tThe base accuracy of these moves becomes 80:",
      "\t\tZap Cannon",
      "*\tMagnet Rise lasts for 8 turns",
      "*\tNature Power becomes Discharge",
      "*\tCamouflage changes the user's type to Electric",
      "*\tSecret Power may Paralyze",
      " ",
      "(The following moves change this field):",
      "*\tThese moves will transform this field into a Factory Field:\t\t",
      "\t\tCharge Beam\t\tDischarge\t\tWild Charge\t\tParabolic Charge\t\tIon Deluge",
      "\t\tGigavolt Havoc  Overdrive       Aura Wheel",
      "\tDischarge additionally can potentially alternate between the Short-circuit Field and the Factory Field for each instance of damage per attack",
      " ",
      "(The following abilities are affected by this field):",
      "*\tStatic's activation chance is doubled to 60%",
      "*\tVolt Absorb gradually restores HP",
      "*\tActivates Plus and Minus",
      "*\tActivates Surge Surfer",
      "*   Download boosts both attacking stats.",
      "*   Gulp Missile always grabs Pikachu.",
      "*\tMimicry changes the user's type to Electric",
      "*   Galvanize's boost becomes x2 (from x1.2)",
      "*\tSteelworker additionally makes all Steel type attacks gain Electric typing",
      " ",
      "(The following items are affected by this field):",
      "*   Synthetic Seed boosts Sp. Def and applies Magnet Rise to the user",
      "",
      "",
      ""
    ].join("\n")
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
    :manualText => [
      "#---------------- 20. Ashen Beach [AB] -----------------#",
      "\"Ash and sand line the field.\"",
      " ",
      "(Passive effects by the field.):",
      "*\tFighting types are immune to confusion",
      "*\tPokemon with the following abilities ignore accuracy and evasion changes when attacking, unless an opponent has Unnerve:",
      "\t\tOwn Tempo\t\tInner Focus\t\tPure Power",
      "Steadfast",
      " ",
      "(The following moves are affected by this field.):",
      "*\tThese moves stir up ash, lowering all active Pokemons' accuracy:",
      "\t\tSpecial Flying attacks",
      "\t\tTwister\t\t\tFire Spin\t\tLeaf Tornado",
      "Razor Wind\t\tWhirlpool",
      "*\tThe following moves' stat-boosting effect is amplified:",
      "\t\tCalm Mind\t\tSand Attack\t\tKinesis\t\t",
      "Meditate",
      "*\tSandstorm and Sand Stream last for 8 turns",
      "*\tPsych-up cures the user's status\t\t",
      "* \tFocus Energy boosts Critical Hit rate by three stages\t\t",
      "*\tThese moves increase in base power x2:",
      "\t\tMud Slap\t\tMud Shot\t\tMud Bomb",
      "\t    \tSand Tomb",
      "*\tThese moves increase in base power x1.5 and apply Fighting/Psychic type damage",
      "\t\tStrength",
      "*\tThese moves increase in base power x1.5:",
      "\t\tHidden Power\t\tLand's Wrath\t\tSurf",
      "Muddy Water\t\tThousand Waves",
      "*\tThese moves increase in base power x1.3:",
      "\t\tZen Headbutt\t\tStored Power\t\tAura Sphere",
      "Focus Blast",
      "*\tThese moves increase in base power x1.2:",
      "\t\tPsychic\t\t",
      "*\tPokemon trapped in Sand Tomb suffer an accuracy drop each turn.",
      "*\tArenite Wall lasts 8 turns",
      "*\tArenite Wall works without the need for a Sandstorm",
      "*\tNature Power becomes Meditate",
      "*\tCamouflage changes user's type to Ground",
      "*\tSecret Power may lower accuracy",
      "*\tShore Up restores 75% HP (from 50%)",
      " ",
      "(The following abilities are affected by this field):",
      "*\tActivates Sand Veil, Sand Rush and Sand Force",
      "*\tWater Compaction additionally boosts Sp. Def on use",
      "*\tSand Spit lowers accuracy of foes upon activation.",
      "*\tZen Mode is active.",
      "*\tMimicry changes the user's type to Ground",
      " ",
      "(The following items are affected by this field):",
      "*       Telluric Seed applies Focus Energy.",
      "",
      "",
      ""
    ].join("\n")
  },
  #----------------- 21. Water Surface [WS] -------------------#
  21 => {
    :name => "Water Surface",
    :abbr => "WS",
    :message => "The water's surface is calm.",
    :manualText => [
      "#---------------- 21. Water Surface [WS] -----------------#",
      "\"The water's surface is calm.\"",
      " ",
      "(The following moves are affected by this field.):",
      "*\tWater and Electric moves increase in base power x1.5",
      "*\tFire moves against grounded Pokemon decrease base power x0.5",
      "*\tGround attacks always fail",
      "*\tSpikes and Toxic Spikes sink into the water, vanishing",
      "*\tDive lasts only one turn",
      "*   Tar Shot washes off at the end of the turn.",
      "*   Life Dew grants the user Aqua Ring.",
      "*\tThese moves increase in base power x1.5:",
      "\t\tWhirlpool\t\t\tDive\t\t\tSurf\t\t\tMuddy Water",
      "\t\tSludge Wave         Hydro Vortex    Origin Pulse",
      "*\tNature Power becomes Whirlpool",
      "*\tCamouflage changes user's type to Water",
      "*\tSecret Power may lower speed",
      "*\tSplash lowers the opponent's accuracy",
      "* \tAqua Ring restores 1/8 Max HP each turn (from 1/16)\t",
      " ",
      "(The following abilities are affected by this field):",
      "*\tWater Veil cures all status conditions",
      "*\tActivates Swift Swim, Hydration, Torrent\t",
      "*\tGrounded Pokemon with Dry Skin and Water Absorb gradually restore HP",
      "*\tShore Up activates Water Compaction",
      "*\tSchooling is active at all times",
      "*\tActivates Surge Surfer",
      "*   Activates Water Compaction each turn",
      "*   Steam Engine raises speed at the end of every turn.",
      "*   Mimicry changes the users type to Water.",
      "*   Propeller Tail increases the power of the user's priority moves by 1.5x",
      "*   Gulp Missile always picks up Arrokuda.",
      " ",
      "(The following items are affected by this field):",
      "*\tElemental Seed boosts Sp. Def and applies Aqua Ring to the user",
      ""
    ].join("\n")
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
    :manualText => [
      "#---------------- 23. Cave [CV] -----------------#",
      "\"The cave echoes dully...\"",
      " ",
      "(The following moves are affected by this field.):",
      "*\tGround type attacks can hit airborne Pokemon",
      "* \tFly and Bounce each last only one turn",
      "*\tSky Drop always fails",
      "*\tStealth Rock damage is doubled",
      "*\tRock moves increase in base power x1.5",
      "*\tNon-contact Flying moves decrease in base power x0.5",
      "* \tSound-based attacks receive a x1.5 increase in power",
      "*\tThese moves gain an additional x1.5 increase in power:",
      "\t\tRock Tomb",
      "*\tNature Power becomes Rock Tomb",
      "*\tCamouflage changes user's type to Rock",
      "*\tSecret Power may crush.",
      "*\tShelter halves damage from Rock-type moves.",
      "*\tTerrain Pulse becomes Rock-type.",
      " ",
      "(The following moves cause the field to react):\t",
      "*\tEarthquake, Bulldoze, Tectonic Rage, Continental Crush and Magnitude collapse the cave, setting and activating Stealth Rocks and crushing all Pokemon",
      "*\tPokemon with these abilities are immune to cave-ins: Battle Armor, Shell Armor, Solid Rock, Prism Armor, Bulletproof, Rock Head, Stalwart",
      "*\tProtection moves, Wide Guard, and Arenite Wall prevent cave-in damage and effects.",
      "*\tPokemon using Endure or Miracle, or having Sturdy survive cave-ins at 1 HP.",
      "",
      "(The following abilities are affected by this field):",
      "*   Punk Rock increases sound moves by 1.5x",
      "*   Mimicry changes the users type to Rock.",
      " ",
      "(The following items are affected by this field):",
      "*\tTelluric Seed sharply boosts Defense but crushes the holder.",
      ""
    ].join("\n")
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
    :manualText => [
      "#---------------- 29. Blessed Field [HF] -----------------#",
      "\"The field is blessed!\"",
      "(Passive effects by the field.):",
      "*\tNormal-type moves affect Ghost-type Pokemon.",
      "",
      "(Overlay):",
      "Blessed Terrain:",
      "*\tSpecial Normal-type attacks deal 1.3x damage.",
      "*\tLight moves deal 1.3x damage.",
      " ",
      "(The following moves are affected by this field.):",
      "*\tGhost and special Dark moves decrease in base power x0.5",
      "*\tFairy and special Normal moves increase in base power x1.5",
      "*\tDragon and Psychic moves increase in base power x1.2",
      "*\tLight moves deal 1.3x damage.\t",
      "*\tThese moves increase in base power x1.3:",
      "\t\tPsystrike \t\tAeroblast \t\tOrigin Pulse",
      "Precipice Blades\t\tDragon Ascent",
      " \t\tDoom Desire\t \tMist Ball\t\tLuster Purge \t\tPsycho Boost \t\t    \tSpacial Rend",
      "Roar of Time    Crush Grip \t\tSecret Sword\t\tRelic Song \t\t Hyperspace Hole\t\t",
      "\t\tLand's Wrath\tMoongeist Beam  Sunsteel Strike\t\tPrismatic Laser\t\t    \tFleur Cannon",
      "\t\tGenesis Supernova ",
      "\t    \tBehemoth Blade  Behemoth Bash",
      "\t\tEternabeam      Dynamax Cannon",
      "\t\tRetribution",
      "*\tThese moves increase in base power x1.5:",
      "\t\tMystical Fire\t\tMagical Leaf\t\tJudgment\t\tSacred Fire",
      "\t\tAncient Power",
      "*   These moves deal super effective damage to Ghost types:",
      "        Spirit Break",
      "*   Life Dew's healing increases to 50%",
      "*\tWish restores 75% of the user's Max HP (from 50%)",
      "*\tMiracle Eye additionally boosts SpAtk",
      "*\tThe stat changing effect of these moves is amplified:",
      "\t\tCosmic Power",
      "*\t(Ghost-type) Curses are lifted after each turn",
      "* \tNature Power becomes Judgment",
      "*\tCamouflage changes the user's type to Normal",
      "*\tSecret Power may lower SpAtk",
      "*\tNature's Madness deals 75% HP damage (from 50%)",
      " ",
      "(The following abilities are affected by this field):",
      "*\tJustified's effect is doubled",
      "*\tCursed Body has no effect",
      "*\tPerish Body has no effect.",
      "*\tPower Spot increases partner's damage output by 1.5x",
      "*\tMimicry changes the users type to Normal.",
      "*\tRKS System's type becomes Dark at all times",
      " ",
      "(The following moves change this field):",
      "*\tTwo uses of these moves transform the field into Cursed Field:",
      "\t\tCurse \t\tOminous Wind",
      "",
      "*\tThese moves transform the field into Cursed Field:",
      "\t\tPhantom Force \tShadow Force",
      " ",
      "(The following items are affected by this field):",
      "*\tMagical Seed boosts Sp.Atk and applies Magic Coat to the user",
      ""
    ].join("\n")
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
    :manualText => [
      "#---------------- 36. Inverse Field [IF] -----------------#",
      "\"!trats elttaB\"",
      " ",
      "(Passive effects by the field.):",
      "*\tThe type chart is inverted",
      " ",
      "(The field can be created by):",
      "*\tCreated for 3 turns by Topsy Turvy unless the user is holding an Everstone",
      " ",
      "(The following moves are affected by this field.):",
      "* \tNature Power becomes Trick Room",
      "*\tCamouflage changes the user's type to Normal",
      "*\tSecret Power may inflict confusion",
      " ",
      "(The following abilities are affected by this field.):",
      "*\tMimicry changes the user's type to a random type",
      " ",
      "(The following items are affected by this field):",
      "*\tMagical Seed changes the user's type to Normal and gives them Normalize.",
      ""
    ].join("\n")
  },
  #----------------- 37. Psychic Terrain [PT] -------------------#
  37 => {
    :name => "Psychic Terrain",
    :abbr => "PT",
    :message => "The field became mysterious!",
    :manualText => [
      "#---------------- 37. Psychic Terrain [PT] -----------------#",
      " ",
      "(Passive effects by the field.):",
      "*\tGravity and Room moves last 8 turns.",
      "*\tUnwound Pokemon regain their type at the end of the turn.",
      " ",
      "(Overlay):",
      "Psychic Terrain:",
      "*\tPositive priority attacks deal 0.5x damage.",
      "*\tPsychic moves increase in base power x1.3",
      " ",
      "(The following moves are affected by this field.):",
      "*\tPositive priority moves fail.",
      "*\tPsychic attacks deal x1.5 increased damage",
      "*\tThe effect of the following stat-altering moves is increased:",
      "\t\tNasty Plot\tCalm Mind\tCosmic Power\t\tMeditate",
      "*\tThese moves increase in base power x1.5:",
      "\t\tMystical Fire\tMagical Leaf   Aura Sphere",
      "\t\tHex             Moonblast      Mind Blown",
      "*\tThe following moves deal additional Psychic-type damage:",
      "\t\tStrength\t\tAncient Power\t\tDragon Pulse\t\tWater Pulse",
      "*\tSecret Power may confuse its target",
      "*\tNature Power becomes Psychic",
      "*\tCamouflage becomes Psychic",
      "*\tPsych Up, Meditate, Mind Reader and Miracle Eye additionally boost Sp.Atk two stages on use",
      "*\tHypnosis puts the target to sleep for two turns",
      "*\tKinesis additionally lowers its target's Attack and Sp.Atk two stages",
      "*\tTelekinesis additional lowers its target's Defense and Sp.Def two stages",
      "*\tShattered Psyche additionally confuses its target",
      "",
      " ",
      "(The following abilities are affected by this field):",
      "*\tAnticipation and Forewarn boost Sp.Atk on switch in",
      "*\tZen Mode is activated.",
      "*\tPower Spot increases partner's damage output by 1.5x(from 1.3x)",
      "*\tTelepathy Pokemon's Speed doubles",
      " ",
      "(The following items are affected by this field):",
      "*\tMagical Seed boosts Sp.Def and Sp.Atk and confuses the user",
      ""
    ].join("\n")
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
    :manualText => [
      "#---------------- 40. Cursed Field [CF] -----------------#",
      "\"The field is cursed!'",
      "(Passive effects by the field.):",
      "*\tGhost-type moves affect Normal-type Pokemon.",
      "",
      "(Overlay):",
      "Cursed Terrain:",
      "*\tGhost-type attacks against grounded Pokemon deal 1.3x damage.",
      "*\tWind moves deal 1.3x damage.",
      " ",
      "(The following moves are affected by this field.):",
      "*\tGhost-type moves gain a 1.5x boost in power",
      "*\tDark-type moves gain a 1.3x boost in power",
      "*\tGhost and Dark-types deal neutral damage to each other",
      "*\tWind moves deal 1.3x damage.",
      "*\tInferno has 90 accuracy",
      "*\tHypnosis puts the target to sleep for two turns.",
      "*\tNightmare inflicts more damage. ",
      "*\tCursed Body always activates upon fainting.",
      "*\tThe following move(s) gets a 1.3x increase in power and gain the Ghost type",
      "\t\tFlame Burst\t\tInferno",
      "Flame Charge\t\tFire Spin",
      "*\tSpite depletes two more PP than usual.",
      "*\tOminous wind has a 20% chance of raising all stats",
      "*\tCurse, when used by a Ghost-type, uses only 25% of the user's HP",
      "*\tThe following moves become single turn moves:",
      "\t\tPhantom Force\tShadow Force",
      "*  \tThe following moves target both opponents",
      "\t\tMean Look\tFire Spin\tOminous Wind\tInferno",
      "*\tFire Spin deals 1/6 Max HP damage per turn (from 1/8)",
      "*\tSpirit Break deals super effective damage to Ghost types.",
      "*\tNight Shade deals 1.5x more damage",
      "*\tMagic Powder puts the target to Sleep.",
      "*\tScary Face has its effect doubled",
      "*\tDestiny Bond can no longer fail when used consecutively",
      "*\tNature Power becomes Phantom Force",
      "*\tCamouflage changes the user's type to Ghost",
      "*\tSecret Power inflicts Curse",
      " ",
      "(The following abilities are affected by this field): ",
      "*\tPerish Body traps the opponent upon triggering",
      "*\tCursed Body always activates upon fainting",
      "*\tMimicry changes the user's type to Ghost.",
      "*\tPokemon that gain Wandering Spirit lose speed every turn",
      "*\tPower Spot damage increase is 1.5x.",
      "*\tRattled boosts the user's Speed upon switch-in",
      " ",
      "(The following moves change this field): ",
      "*\tThe following moves can turn this field into a Blessed Field:",
      "\t\tJudgement\tSacred Fire\tPurify",
      "Origin Pulse\tRetribution",
      "*\tThese moves temporarily nullify this field:",
      "     \t\tFlash       Dazzling Gleam",
      " ",
      "(The following items are affected by this field):",
      "*\tMagical Seed raises Defense and Special Defense and burns the user",
      ""
    ].join("\n")
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
    :manualText => [
      "#---------------- 42. Bewitched Woods [BW] ----------------#",
      "\"Double, double toil and trouble…\"",
      " ",
      "(Passive effects by the field.):",
      "*\tPokemon sleeping in the fairy rings take damage equal to 1/16th of max HP.",
      "*\tGrounded Grass Pokemon restore 1/16th Max HP each turn ",
      "",
      "(The following moves are affected by this field.):",
      "*\tGrass-type moves increase in base power x1.5",
      "*\tFairy-type moves increase in base power x1.3",
      "*\tDark-type moves increase in base power x1.3",
      "*\tGrass-type attacks now hit Steel-type Pokemon super effectively",
      "*\tPoison-, Fairy-, and Dark-types now hit each other neutrally",
      "*\tThe following moves gain a 1.3x boost in power:",
      "\t\tMagical Leaf\t\tDark Pulse",
      "\t\tNight Daze\t\tMoonblast",
      "\t\tDream Eater\t\tNight Slash",
      "*\tThe following moves gain a 1.5x boost in power:",
      "\t\tHex             Mystical Fire\tSpirit Break",
      "*\tThe following moves’ accuracy has been increased to 80:",
      "\t\tSleep Powder\t\tGrass Whistle",
      "\t\tHypnosis",
      "*\tThe following moves’ accuracy has been increased to 90:",
      "\t\tPoison Powder\tStun Spore",
      "\t\tWill-O-Wisp",
      "*\tMagic Powder puts the target to sleep",
      "*\tTorment lasts for 8 turns and traps the target",
      "*\tDamage taken from Nightmare is doubled",
      "*\tFairy-types cannot get badly poisoned by Toxic Spikes",
      "*\tMoonlight restores 75% of the user's Max HP",
      "*\tForest's Curse additionally curses the target",
      "*\tNature Power becomes Dazzling Gleam",
      "*\tCamouflage changes the user's type to Fairy",
      "*\tSecret Power may randomly inflict Sleep, Poison, or Paralysis.",
      " ",
      "(The following abilities are affected by this field):",
      "*\tPrankster affects Dark-type Pokémon",
      "*\tEffect Spore has a doubled activation rate",
      "*\tNatural Cure heals status at the end of the turn",
      "*\tPastel Veil and Aroma Veil remove the user's Fairy-type weaknesses",
      "*\tPower Spot damage increase is 1.5x here.",
      "*\tMimicry changes the user's type to Fairy",
      " ",
      "",
      "(The following moves change this field):",
      "*\tThe following moves will transform this field into a Forest Field:",
      "\t\tPurify\t\tGeomancy\t\t",
      " ",
      "(The following items are affected by this field):",
      "*\tMagical Seed raises Special Defense and applies ingrain to the user",
      "",
      "",
      "",
      "",
      "",
      ""
    ].join("\n")
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
    :manualText => [
      "#--------------- 45. Beach Field [BF] ---------------#",
      "“The waves lap at the shore.”",
      "",
      "(Passive effects by the field.):",
      "*\tSun lasts for 8 turns",
      "",
      "(The following moves are affected by this field.):",
      "*\tWater- and Ground-type moves increase in base power x1.3",
      "*\tElectric-type moves increase in base power x1.5",
      "*\tThese moves are boosted in power x1.5:",
      "Sand Tomb\t\tWhirlpool\t\tBurn Up",
      "Thousand Waves\tScorching Sands\tRazor Shell",
      "*\tThese moves are boosted in power x1.3:",
      "Scald\t\t\tSurf\t\t\tMuddy Water",
      "Steam Eruption\tBrine",
      "*\tWind moves are boosted 1.3x and deal additional Ground-type damage:",
      "Ominous Wind\tRazor Wind\t\tSilver Wind",
      "Icy Wind\t\tFairy Wind\t\tTwister",
      "Gust",
      "*\tBrine’s power is always doubled.",
      "*\tSand Tomb and Whirlpool duration is increased to 8 turns",
      "*\tSand Attack is amplified",
      "*\tArenite Wall lasts 8 turns and can be set up without sandstorm",
      "*\tShore Up restores 75% of the user's Max HP",
      "*\tNature Power becomes Scorching Sands",
      "*\tCamouflage changes the user's type to Ground",
      "*\tSecret Power may lower Accuracy",
      "",
      "(The following abilities are affected by this field):",
      "*\tThese abilities are activated:",
      "Sand Force\t\tSand Veil\t\tSand Rush",
      "Swift Swim\t\tHydration",
      "*\tSand Spit additionally lowers the opposing Pokemon's Accuracy",
      "*\tWater Compaction sharply raises Special Defense upon activation",
      "*\tDry Skin Pokemon lose 1/16th Max HP at the end of each turn",
      "*\tShell Armor boosts Defense and Special Defense on entry",
      "*\tMimicry changes the user's type to Ground",
      "",
      "",
      "",
      "(The following items are affected by this field):",
      "*\tTelluric Seed boosts Speed and Accuracy and applies Sand Tomb to the user",
      ""
    ].join("\n")
  },
  #----------------- 47. Library Field [LIB] -------------------#
  47 => {
    :name => "Library Field",
    :abbr => "LIB",
    :message => "Pages flutter around!",
    :manualText => [
      "#------------------- 47. Library [LIB] --------------------#",
      "\"Pages flutter around!\"\u000b\u000b(Passive effects by the field.):",
      "*\tSilencing lowers speed by x0.5",
      "*\tConfused Pokemon take x2 damage",
      "",
      "(The following moves are affected by this field.):",
      "*\tFire-type moves increase in base power x1.3",
      "*\tSpecial Psychic-type moves increase in base power x1.3",
      "*\tSlashing and Wind moves increase in base power x1.3",
      "*\tSound-based moves silence the user",
      "*\tThese moves are boosted in power x1.3:",
      "\t\tFocus Punch\t\tFocus Blast\t\tReturn",
      "\t\tFrustration\t\tPerforate",
      "*\tThe following moves are boosted in po wer x1.5:",
      "\t\tSmart Strike\t\tAncient Power\t\tBarrage",
      "\t\tHeadbutt\t\tZen Headbutt\t\tIron Head",
      "\t\tHead Smash\t\tHead Charge\t\tSkull Bash",
      "\t\tMind Blown",
      "*\tThe following moves are boosted in power x1.5 and become spread moves:",
      "\t\tFire Spin\t\tWhirlpool",
      "*\tThe stat-changing effect of these moves is amplified:",
      "\t\tCalm Mind\t\tAmnesia",
      "*\tWhirlwind and Telekinesis damage the target for 1/6th max HP",
      "*\tFocus Blast cannot miss",
      "*\tFocus Punch cannot be interrupted",
      "*\tFocus Energy increases critical hit rate by three stages",
      "*\tHelping Hand boost is increased to x2",
      "*\tDoodle copies positive stat stages",
      "*\tNature Power becomes Calm Mind",
      "*\tCamouflage changes the user's type to Normal",
      "*\tSecret Power may silence",
      "",
      "(The following abilities are affected by this field):",
      "*\tThe following abilities prevent the lowering of stats and redirection of moves:",
      "\t\tSoundproof\t\tUnaware\t\tInner Focus",
      "\t\tOblivious",
      "*\tPokemon with the following abilities become confused on entry:",
      "\t\tDefeatist\t\tSimple\t\t\tKlutz\t",
      "*\tKeen Eye raises Accuracy",
      "*\tSchooling raises all stats",
      "*\tAnalytic base power boost becomes x1.5",
      "*\tTechnician boosts moves 80 power or below",
      "",
      "(The following items are affected by this field):",
      "*\tSynthetic Seed applies Focus Energy to the holder",
      ""
    ].join("\n")
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
