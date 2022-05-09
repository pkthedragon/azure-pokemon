################################################################################
# This section was created solely for you to put various bits of code that
# modify various wild Pokémon and trainers immediately prior to battling them.
# Be sure that any code you use here ONLY applies to the Pokémon/trainers you
# want it to apply to!
################################################################################

# Make all wild Pokémon shiny while a certain Switch is ON (see Settings).
Events.onWildPokemonCreate+=proc {|sender,e|
   pokemon=e[0]
   if $game_switches[SHINY_WILD_POKEMON_SWITCH]
     pokemon.makeShiny
   end
}

# Used in the random dungeon map.  Makes the levels of all wild Pokémon in that
# map depend on the levels of Pokémon in the player's party.
# This is a simple method, and can/should be modified to account for evolutions
# and other such details.  Of course, you don't HAVE to use this code.
Events.onWildPokemonCreate+=proc {|sender,e|
   pokemon=e[0]
   if $game_map.map_id==51
     pokemon.level=pbBalancedLevel($Trainer.party) - 4 + rand(5)   # For variety
     pokemon.calcStats
     pokemon.resetMoves
   end
}

Events.onTrainerPartyLoad+=proc {|sender,e|
  if e[0] # Trainer data should exist to be loaded, but may not exist somehow
    trainer=e[0][0] # A PokeBattle_Trainer object of the loaded trainer
    items=e[0][1]   # An array of the trainer's items they can use
    party=e[0][2]   # An array of the trainer's Pokémon
    if $Trainer.numbadges>=6 || ($game_variables[200] == 2 && $Trainer.numbadges>=3)
      if ($game_variables[200] == 2 && $Trainer.numbadges>=10)
        for i in party
          for j in 0...4
            i.moves[j].pp = (i.moves[j].pp * 2).floor
          end
        end
      else
        for i in party
          for j in 0...4
            i.moves[j].pp = (i.moves[j].pp * 1.6).floor
          end
        end
      end
    end
    if ($game_variables[665] == 9 && $game_variables[181] == 56)
      for i in party
        i.hp=1
      end
    end
    if trainer.trainertype==PBTrainers::HANDMAIDEN && trainer.name=="Rose"
      for i in party
        if (i.species==PBSpecies::DRAGONAIR && i.item==PBItems::LEFTOVERS)
          i.status=PBStatuses::BURN
        end  
      end
    end
    if trainer.trainertype==PBTrainers::MYRON && trainer.name=="Myron"
      for i in party
        if (i.species==PBSpecies::MISMAGIUS)
          case $game_variables[200]
          when 0
            $game_variables[704]=2
          when 1
            $game_variables[704]=1
          when 2
            $game_variables[704]=3
          end
        end  
      end
    end
    if trainer.trainertype==PBTrainers::GHOSTMAN && trainer.name=="Myron"
      for i in party
        if (i.species==PBSpecies::GENESECT)
          case $game_variables[200]
          when 0
            $game_variables[704]=2
          when 1
            $game_variables[704]=1
          when 2
            $game_variables[704]=3
          end
        end  
      end
    end
  end
}

# UPDATE 11/19/2013
# Cute Charm now gives a 2/3 chance of being opposite gender
Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  if !$Trainer.party[0].egg?
    ourpkmn = $Trainer.party[0]
    abl = ourpkmn.ability
    if isConst?(abl, PBAbilities, :CUTECHARM) && rand(3) < 2
      pokemon.setGender(ourpkmn.gender == 0 ? 1 : 0)
    end
  end
}
# UPDATE 11/19/2013
# sync will now give a 50% chance of encountered pokemon having
# the same nature as the party leader
Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  if !$Trainer.party[0].egg?
    ours = $Trainer.party[0]
    if isConst?(ours.ability, PBAbilities, :SYNCHRONIZE)
      pokemon.setNature(ours.nature)
    end
  end
}
#Regional Variants + Other things with multiple movesets (Wormadam, Meowstic, etc)
Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
    v=MultipleForms.call("getMoveList",pokemon)
    if v!=nil
      moves = v
    else      
      moves = pokemon.getMoveList
    end
    movelist=[]
    for i in moves
      if i[0]<=pokemon.level
        movelist[movelist.length]=i[1]
      end
    end
    movelist|=[] # Remove duplicates
    listend=movelist.length-4
    listend=0 if listend<0
    j=0
    for i in listend...listend+4
      moveid=(i>=movelist.length) ? 0 : movelist[i]
      pokemon.moves[j]=PBMove.new(moveid)
      j+=1
    end    
}

Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  case pokemon.species
    when PBSpecies::TANGROWTH
      if $game_map.map_id == 34
        $game_switches[290]=true
        $game_switches[1500]=true
        pokemon.isbossmon=true
        $game_variables[704]=2
        if $game_variables[200] == 0
          pokemon.level=20
        elsif $game_variables[200] == 1
          pokemon.level=15 
        elsif $game_variables[200] == 2
          pokemon.level=22 
        end
        pokemon.pbLearnMove(:MEGADRAIN)
        pokemon.pbLearnMove(:INGRAIN)
        pokemon.pbLearnMove(:ANCIENTPOWER)
        pokemon.pbLearnMove(:AMNESIA)
        pokemon.item = PBItems::TANGROWTHCREST
        pokemon.setNature(PBNatures::TIMID)    
        for i in 0...6
          pokemon.ev[i]=(20)
        end
      end
    when PBSpecies::ROTOM
      if $game_map.map_id == 51
        $game_switches[290]=true
        $game_switches[1500]=true
        pokemon.isbossmon=true
        $game_variables[704]=2
        if $game_variables[200] == 0
          pokemon.level=30
        elsif $game_variables[200] == 1
          pokemon.level=25 
        elsif $game_variables[200] == 2
          pokemon.level=35 
        end
        pokemon.pbLearnMove(:OMINOUSWIND)
        pokemon.pbLearnMove(:DISCHARGE)
        pokemon.pbLearnMove(:DOUBLETEAM)
        pokemon.pbLearnMove(:CONFUSERAY)
        pokemon.setNature(PBNatures::QUIET)    
        for i in 0...6
          pokemon.ev[i]=(31)
        end
      end
    when PBSpecies::MISMAGIUS
      if $game_map.map_id == 43 || $game_map.map_id == 2 || $game_map.map_id == 56
        $game_switches[290]=true
        $game_switches[1500]=true
        pokemon.isbossmon=true
        $game_variables[704]=1
        if $game_variables[200] == 0
          pokemon.level=25
        elsif $game_variables[200] == 1
          pokemon.level=22 
        elsif $game_variables[200] == 2
          pokemon.level=27 
        end
        pokemon.pbLearnMove(:OMINOUSWIND)
        pokemon.pbLearnMove(:THUNDERBOLT)
        pokemon.pbLearnMove(:TORMENT)
        pokemon.pbLearnMove(:NASTYPLOT)
        pokemon.item = PBItems::MISMAGIUSCREST
        pokemon.setNature(PBNatures::MODEST)    
        for i in 0...6
          pokemon.ev[i]=(25)
        end
      end
    end
  # Egg moves for wild events
  case $game_variables[545]
    when 1 # Sandygast
      pokemon.pbLearnMove(:STOCKPILE)
    when 2 # Shieldon
      pokemon.pbLearnMove(:ROCKBLAST)
      pokemon.pbLearnMove(:SCREECH)
    when 3 # Wooloo
      pokemon.pbLearnMove(:COUNTER)
    when 4 # Smoochum
      pokemon.pbLearnMove(:FAKEOUT)
    when 5 # Chingling
      pokemon.pbLearnMove(:HYPNOSIS)
    when 6 # Mystic Larvitar
      pokemon.form=1
      pokemon.resetMoves
      pokemon.calcStats
    when 7 # Pichu
      pokemon.pbLearnMove(:WISH)
    when 8 # Trubbish
      pokemon.pbLearnMove(:ROCKBLAST)
    when 9 # Lileep
      pokemon.pbLearnMove(:MEGADRAIN)
    when 10 # Duskull
      pokemon.pbLearnMove(:PAINSPLIT)
    when 11 # Espurr
      pokemon.pbLearnMove(:YAWN)
    when 11 # Espurr
      pokemon.pbLearnMove(:ASSIST)
    when 12 # Sinistea
      pokemon.pbLearnMove(:METRONOME)
    when 13 # Mystic Stufful
      pokemon.form=1
      pokemon.resetMoves
      pokemon.calcStats
    when 14 # Drifloon
      pokemon.pbLearnMove(:TAILWIND)
    when 14 # Drifloon
      pokemon.pbLearnMove(:WEATHERBALL)
    when 15 # Whismur
      pokemon.pbLearnMove(:EXTRASENSORY)
    when 16 # Turtwig
      pokemon.pbLearnMove(:HEAVYSLAM)
    when 16 # Turtwig
      pokemon.pbLearnMove(:WIDEGUARD)
    when 17 # Castform
      pokemon.pbLearnMove(:RAINDANCE)
      pokemon.pbLearnMove(:HAIL)
      pokemon.pbLearnMove(:SUNNYDAY)
      pokemon.pbLearnMove(:OMINOUSWIND)
    when 18 # Mystic Voltorb
      pokemon.form=1
      pokemon.resetMoves
      pokemon.calcStats
    when 19 # Applin
      pokemon.pbLearnMove(:RECYCLE)
      pokemon.pbLearnMove(:SUCKERPUNCH)
    when 20 # Spinarak
      pokemon.pbLearnMove(:RAGEPOWDER)
      pokemon.pbLearnMove(:NIGHTSLASH)
    when 21 # Swinub
      pokemon.pbLearnMove(:ICICLECRASH)
    end
}
