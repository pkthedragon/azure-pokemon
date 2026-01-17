BOSSINFOHASH = {
##############################
# Boss Template
##############################

    :GODKILLER => {
        :name => "God Killer", # nickname
        :entryText => "Heaven-shaking Godkiller appeared.", # dialogue upon enterring battle as a wild pokemon
        :shieldCount => 2, # number of shields
        :barGraphic => "", # what kind of hp bar graphic should be pulled
        :immunities => { # any immunities to things 
            :moves => [],
            :fieldEffectDamage => []
        },
        :capturable => true, # can you catch this boss after shields are removed?
        :moninfo => { # bosspokemon details
            :species => PBSpecies::GARCHOMP,
            :level => 5,
            :form => 0,
            :item => PBItems::LEFTOVERS,
            :moves => [PBMoves::DARKPULSE,PBMoves::PSYSHOCK,PBMoves::MOONLIGHT,PBMoves::MOONBLAST],
            :ability => PBAbilities::RKSSYSTEM,
            :gender => "F",
            :nature => PBNatures::MODEST,
            :iv => 31,
            :happiness => 255,
            :ev => [252,0,4,0,252,0]
            },
        :sosDetails =>  { # sospokemon details
            :activationRequirement => "@battlers[battlerIndex].shieldCount == 0",
            :continuous => true,
            :totalMonCount => 3,
            :sosBuffer => 3, # sos buffer number; default 3
            #:refreshingRequirement => [0], # refresh SOS mon: revive if dead/refresh if alive
            :entryMessage => ["Godkiller called more to aid the slaughter!","This corresponds to Gyarados!"],
            :moninfos => {
                1 => {
                    :species => PBSpecies::GARCHOMP,
                    :level => 5,
                    :form => 0,
                    :item => PBItems::LEFTOVERS,
                    :moves => [PBMoves::DARKPULSE,PBMoves::PSYSHOCK,PBMoves::MOONLIGHT,PBMoves::MOONBLAST],
                    :ability => PBAbilities::INTIMIDATE,
                    :gender => "F",
                    :nature => PBNatures::MODEST,
                    :iv => 31,
                    :happiness => 255,
                    :ev => [252,0,4,0,252,0]
                },
                2 => {
                    :species =>  PBSpecies::GYARADOS,
                    :level => 5,
                    :form => 0,
                    :item => PBItems::GYARADOSITE,
                    :moves => [PBMoves::DARKPULSE,PBMoves::PSYSHOCK,PBMoves::MOONLIGHT,PBMoves::MOONBLAST],
                    :ability => PBAbilities::PROTEAN,
                    :gender => "F",
                    :nature => PBNatures::MODEST,
                    :iv => 31,
                    :happiness => 255,
                    :ev => [252,0,4,0,252,0]
                    },
            },
        },
        :onEntryEffects => { # effects applied on entry, use same attributes/syntax as onbreakeffects
            :fieldChange => 37,
            :fieldChangeMessage => "Gothitelle laughs at how dumb your face looks. So mean!"
        },
        :onBreakEffects => { # in order of shield count, with the highest value being the first shield broken and the lowest the last
            1 => {
                :threshold => 0, # if desired, shield can be broken at higher hp% than 0
                :animation => PBMoves::FAIRYLOCK, # animation plays
                :message => "", # message that plays when shield is broken
                :bossEffect => PBEffects::MagicCoat, # effect that applies on the boss when breaking shield
                :bossEffectduration => true, # duration of the effect(some effects are booleans, double check)
                :bossEffectMessage => "{1} shrouded itself with Magic Coat!", # message that plays for the effect
                :bossEffectanimation => PBMoves::MAGICCOAT, # effect animation
                :weatherChange => PBWeather::RAINDANCE, # weather to apply
                :formchange => 0, # formchanges
                :abilitychange => PBAbilities::DOWNLOAD, # ability to change to upon shieldbreaker
                :fieldChange => 8, # field changes
                :fieldChangeMessage => "", # message that plays when the field is changes
                :weatherCount => 5, # weather turncount
                :weatherChangeMessage => "Rain began to fall!", # weather message
                :weatherChangeAnimation => "Rain", # string of "Rain", "Sunny","Hail","Sandstorm"
                :typeChange => [PBTypes::FIRE,PBTypes::ROCK], # any given type changes
                :movesetUpdate => [PBMoves::EARTHQUAKE,PBMoves::OUTRAGE,PBMoves::ROCKSLIDE,PBMoves::FIREBLAST], # any given moveset changes
                :speciesUpdate => PBSpecies::FLYGON,
                :statusCure => true, # if status is cured when shield is broken
                :effectClear => true, # if effects are cleared when shield is broken
                :bossSideStatusChanges => [PBStatuses::PARALYSIS,"Paralysis"], # what status gets inflicted on a boss/player pokemon when shield is broken. array has 2 elements, first the status symbol, then a string for the animation
                :playerSideStatusChanges => [PBStatuses::PARALYSIS,"Paralysis",nil], # what status gets inflicted on a boss/player pokemon when shield is broken. array has 3 elements, first the status symbol, then a string for the animation, then true if ground types immune to para
                :statDropCure => true, # if statdrops are negated when shield is broken
                :playerEffects => PBEffects::Curse, # effects applied upon enemies on breaking shield
                :playerEffectsduration => true, # enemy effect durration
                :playerEffectsAnimation => PBMoves::CURSE, # enemyeffect animation
                :playerEffectsMessage => "A curse was inflicted on the opposing side!", # enemy effect message
                :stateChanges => :TrickRoom, # handles state changes found in the Battle_Global class(in Battle_ActiveSide file + Trick Room
                :stateChangeAnimation => PBMoves::TRICKROOM, # state change animation
                :stateChangeCount => 5, # state change turncount
                :stateChangeMessage => "The dimensions were changed!", # statechange messages
                :playersideChanges => PBEffects::ToxicSpikes, # handles side changes found in the Battle_Side class(in Battle_ActiveSide file) 
                :playersideChangeAnimation => PBMoves::TOXICSPIKES, # side change animation
                :playersideChangeCount => true, # side change turncount
                :playersideChangeMessage => "Poison Barbs was set up!", # statechange messages
                :bosssideChanges => PBEffects::ToxicSpikes, # handles side changes found in the Battle_Side class(in Battle_ActiveSide file) 
                :bosssideChangeAnimation => PBMoves::TOXICSPIKES, # side change animation
                :bosssideChangeCount => true, # side change turncount
                :bosssideChangeMessage => "Poison Barbs was set up!", # statechange messages
                :itemchange => PBItems::LEFTOVERS, # item that is given upon breaking shield
                :bgmChange => "Battle! Gym Leader",
                :bossStatChanges => { # any statboosts that are given
                    PBStats::SPATK => 1,
                },
                :playerSideStatChanges => { # any statchanges applied to the players side
                    PBStats::SPATK => -1,
                },
                :soscontinuous => true  # make SOS continuous from this shield onwards.
            },
        }
    },

    :HEROICTANGROWTH => {
        :name => "Heroic Tangrowth", # nickname
        :entryText => "The guardian Tangrowth attacks!", # dialogue upon enterring battle as a wild pokemon
        :shieldCount => 1, # number of shields
        :immunities => {},
        :capturable => false, # can you catch this boss after shields are removed?
        :moninfo => { # bosspokemon details
            :species => PBSpecies::TANGROWTH,
            :level => 22,
            :form => 1,
            :item => PBItems::MEADOWTRIBUTE,
            :moves => [PBMoves::MEGADRAIN,PBMoves::SHOCKWAVE,PBMoves::FLAIL,PBMoves::LEECHSEED],
            :ability => PBAbilities::LEAFGUARD,
            :gender => "M",
            :nature => PBNatures::TIMID,
            :iv => 20,
            :happiness => 255
        },
        :sosDetails =>  { # sospokemon details
            :activationRequirement => "@battlers[battlerIndex].shieldCount == 0",
            :continuous => true,
            :totalMonCount => 1,
            :moninfos => {
                1 => {
                    :species => PBSpecies::TANGELA,
                    :level => 16,
                    :form => 0,
                    :item => PBItems::OCCABERRY,
                    :moves => [PBMoves::STUNSPORE,PBMoves::ACIDSPRAY,PBMoves::INFESTATION,],
                    :ability => PBAbilities::LEAFGUARD,
                    :nature => :MODEST,
                    :iv => 31,
                    :happiness => 255,
                    :ev => [40,40,40,40,40,40]
                },
            },
        },
        :onBreakEffects => { # in order of shield count, with the highest value being the first shield broken and the lowest the last
            1 => {
                :threshold => 0, # if desired, shield can be broken at higher hp% than 0
                :message => "Guardian Tangrowth holds sturdy!", # message that plays when shield is broken
                :bossEffect => PBEffects::Ingrain, # effect that applies on the boss when breaking shield
                :bossEffectduration => true, # duration of the effect(some effects are booleans, double check)
                :bossEffectMessage => "{1} roots itself!", # message that plays for the effect
                :bossEffectanimation => PBMoves::INGRAIN, # effect animation
                :weatherChange => PBWeather::SUNNYDAY, # weather to apply
                :weatherCount => 5, # weather turncount
                :weatherChangeMessage => "Sunlight intensifies upon the battlefield!", # weather message
                :weatherChangeAnimation => "Sunny", # string of "Rain", "Sunny","Hail","Sandstorm"
                :statusCure => true # if status is cured when shield is broken
            },
        }
    },

    :HEROICTANGROWTH_INTENSE => {
        :name => "Heroic Tangrowth", # nickname
        :entryText => "The guardian Tangrowth attacks!", # dialogue upon enterring battle as a wild pokemon
        :shieldCount => 1, # number of shields
        :immunities => {},
        :capturable => false, # can you catch this boss after shields are removed?
        :moninfo => { # bosspokemon details
            :species => PBSpecies::TANGROWTH,
            :level => 25,
            :form => 1,
            :item => PBItems::MEADOWTRIBUTE,
            :moves => [PBMoves::MEGADRAIN,PBMoves::SHOCKWAVE,PBMoves::ANCIENTPOWER,PBMoves::GROWTH],
            :ability => PBAbilities::DRIZZLE,
            :gender => "M",
            :nature => PBNatures::TIMID,
            :iv => 20,
            :happiness => 255,
            :ev => [50,50,50,50,50,50]
            },
        :sosDetails =>  { # sospokemon details
            :activationRequirement => "@battlers[battlerIndex].shieldCount == 0",
            :continuous => true,
            :totalMonCount => 2,
            :moninfos => {
                1 => {
                    :species => PBSpecies::TANGELA,
                    :level => 18,
                    :form => 0,
                    :item => PBItems::OCCABERRY,
                    :moves => [PBMoves::RAGEPOWDER,PBMoves::STUNSPORE,PBMoves::ACIDSPRAY,PBMoves::INFESTATION],
                    :ability => PBAbilities::LEAFGUARD,
                    :nature => :MODEST,
                    :iv => 31,
                    :happiness => 255
                },
            },
        },
        :onBreakEffects => { # in order of shield count, with the highest value being the first shield broken and the lowest the last
            1 => {
                :threshold => 0, # if desired, shield can be broken at higher hp% than 0
                :message => "The guardian Tangrowth holds sturdy!", # message that plays when shield is broken
                :bossEffect => PBEffects::Ingrain, # effect that applies on the boss when breaking shield
                :bossEffectduration => true, # duration of the effect(some effects are booleans, double check)
                :bossEffectMessage => "{1} roots itself!", # message that plays for the effect
                :bossEffectanimation => PBMoves::INGRAIN, # effect animation
                :weatherChange => PBWeather::SUNNYDAY, # weather to apply
                :weatherCount => 5, # weather turncount
                :weatherChangeMessage => "Sunlight intensifies upon the battlefield!", # weather message
                :weatherChangeAnimation => "Sunny" # string of "Rain", "Sunny","Hail","Sandstorm"
            },
        }
    },

    :MOTHEREXPLOUD => {
        :name => "Mother Exploud", # nickname
        :entryText => "Mother Exploud's howl echoes through the cave!", # dialogue upon enterring battle as a wild pokemon
        :shieldCount => 1, # number of shields
        :immunities => {},
        :capturable => false, # can you catch this boss after shields are removed?
        :moninfo => { # bosspokemon details
            :species => PBSpecies::EXPLOUD,
            :level => 23,
            :form => 0,
            :item => PBItems::THROATSPRAY,
            :moves => [PBMoves::ECHOEDVOICE],
            :ability => PBAbilities::AMPLIFY,
            :gender => "F",
            :nature => PBNatures::MODEST,
            :iv => 20,
            :happiness => 255
        },
        :sosDetails =>  { # sospokemon details
            :activationRequirement => "@battlers[battlerIndex].shieldCount == 0",
            :continuous => true,
            :totalMonCount => 1,
            :moninfos => {
                1 => {
                    :species => PBSpecies::WHISMUR,
                    :level => 17,
                    :form => 0,
                    :item => PBItems::CHOPLEBERRY,
                    :moves => [PBMoves::HELPINGHAND,PBMoves::MAGICPOWDER,PBMoves::ROAR,PBMoves::SUPERSONIC],
                    :ability => PBAbilities::SOUNDPROOF,
                    :nature => :MODEST,
                    :iv => 20,
                    :happiness => 255
                },
            },
        },
        :onEntryEffects => { # effects applied on entry, use same attributes/syntax as onbreakeffects
            :abilitychange => PBAbilities::PARENTALBOND,
            :message => "{1}'s motherly instincts take over!"
        }
    },

    :TOXICROAKBOSS => {
        :name => "Toxicroak", # nickname
        :entryText => "A Toxicroak blocks the way!", # dialogue upon enterring battle as a wild pokemon
        :shieldCount => 1, # number of shields
        :immunities => {},
        :capturable => false, # can you catch this boss after shields are removed?
        :moninfo => { # bosspokemon details
            :species => PBSpecies::TOXICROAK,
            :level => 30,
            :form => 0,
            :item => PBItems::DAMPROCK,
            :moves => [PBMoves::THUNDER,PBMoves::SURF,PBMoves::AURASPHERE,PBMoves::SNARL],
            :ability => PBAbilities::DRYSKIN,
            :gender => "M",
            :nature => PBNatures::ADAMANT,
            :iv => 25,
            :happiness => 255
        },
        :onEntryEffects => { # effects applied on entry, use same attributes/syntax as onbreakeffects
            :typeChange => [PBTypes::ELECTRIC,PBTypes::FIGHTING],
            :message => "{1} crackles with electric energy!"
        },
        :onBreakEffects => { # in order of shield count, with the highest value being the first shield broken and the lowest the last
            1 => {
                :threshold => 0, # if desired, shield can be broken at higher hp% than 0
                :weatherChange => PBWeather::RAINDANCE, # weather to apply
                :weatherCount => 8, # weather turncount
                :weatherChangeMessage => "A heavy rain began to fall!", # weather message
                :weatherChangeAnimation => "Rain" # string of "Rain", "Sunny","Hail","Sandstorm"
            },
        }
    },
}
