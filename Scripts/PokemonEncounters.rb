module EncounterTypes
  Land         = 0
  Cave         = 1
  Water        = 2
  RockSmash    = 3
  OldRod       = 4
  GoodRod      = 5
  SuperRod     = 6
  HeadbuttLow  = 7
  HeadbuttHigh = 8
  LandMorning  = 9
  LandDay      = 10
  LandNight    = 11
  BugContest   = 12
  WaterDay     = 13
  WaterNight   = 14
  Names=[
     "Land",
     "Cave",
     "Water",
     "RockSmash",
     "OldRod",
     "GoodRod",
     "SuperRod",
     "HeadbuttLow",
     "HeadbuttHigh",
     "LandMorning",
     "LandDay",
     "LandNight",
     "BugContest",
     "WaterDay",
     "WaterNight"
  ]
  EnctypeChances=[
     [20,20,10,10,10,10,5,5,4,4,1,1],
     [20,20,10,10,10,10,5,5,4,4,1,1],
     [60,30,5,4,1],
     [60,30,5,4,1],
     [70,30],
     [60,20,20],
     [40,40,15,4,1],
     [30,25,20,10,5,5,4,1],
     [30,25,20,10,5,5,4,1],
     [20,20,10,10,10,10,5,5,4,4,1,1],
     [20,20,10,10,10,10,5,5,4,4,1,1],
     [20,20,10,10,10,10,5,5,4,4,1,1],
     [20,20,10,10,10,10,5,5,4,4,1,1],
     [60,30,5,4,1],
     [60,30,5,4,1]
  ]
  EnctypeDensities=[25,10,10,0,0,0,0,0,0,25,25,25,25,10,10]
  EnctypeCompileDens=[1,2,3,0,0,0,0,0,0,1,1,1,1,3,3]
end

# Immutable slot view over Azure's existing [species,min_level,max_level] rows.
class PBEncounterSlotData
  attr_reader :slot,:species,:min_level,:max_level,:weight

  def initialize(slot,row,weight)
    @slot=slot
    @species=row[0]
    @min_level=row[1]
    @max_level=row[2]
    @weight=weight
    freeze
  end
end

# Typed encounter-type view. The legacy encounter table remains available as
# a deeply frozen array so existing runtime selection code keeps its layout.
class PBEncounterTypeData
  attr_reader :id,:name,:density,:encounters,:slots,:chances

  def initialize(typeid,density,encounters)
    @id=typeid
    @name=EncounterTypes::Names[typeid]
    @density=density
    @encounters=encounters
    @chances=(EncounterTypes::EnctypeChances[typeid] || []).clone.freeze
    slots=[]
    for index in 0...encounters.length
      row=encounters[index]
      slots.push(PBEncounterSlotData.new(index,row,@chances[index])) if row
    end
    @slots=slots.freeze
    freeze
  end

  def type; return @id; end
  def internal_name; return @name; end
end

# Rejuvenation-style typed access over Azure's map-keyed encounters.dat. Map
# IDs and compiled arrays are unchanged; symbolic lookup applies to encounter
# type names such as :Land, :WaterNight, and :HeadbuttHigh.
class PBEncounterData
  attr_reader :map_id,:densities,:encounters,:encounter_types

  def initialize(mapid)
    @map_id=mapid
    row=PBEncounterData.data[mapid]
    @densities=(row[0] || []).clone.freeze
    @encounters=PBEncounterData.immutable_encounters(row[1] || [])
    types=[]
    for typeid in 0...@encounters.length
      table=@encounters[typeid]
      next if !table
      types[typeid]=PBEncounterTypeData.new(typeid,@densities[typeid],table)
    end
    @encounter_types=types.freeze
    @azure_source_row=row
    freeze
  end

  def mapid; return @map_id; end
  def density(type); data=try_get(type); return data ? data.density : nil; end
  def has_type?(type); return !try_get(type).nil?; end
  def get(type)
    id=PBEncounterData.normalize_type(type)
    data=(id && id>=0) ? @encounter_types[id] : nil
    raise ArgumentError.new("Unknown encounter type #{type.inspect}") if !data
    return data
  end
  def try_get(type)
    id=PBEncounterData.normalize_type(type)
    return nil if id.nil? || id<0
    return @encounter_types[id]
  end
  def exists?(type); return !try_get(type).nil?; end
  def each
    return enum_for(:each) if !block_given?
    for data in @encounter_types
      yield data if data
    end
  end

  # Rejuvenation-compatible named table readers over Azure's numeric arrays.
  def Land; return @encounters[EncounterTypes::Land]; end
  def Cave; return @encounters[EncounterTypes::Cave]; end
  def Water; return @encounters[EncounterTypes::Water]; end
  def RockSmash; return @encounters[EncounterTypes::RockSmash]; end
  def OldRod; return @encounters[EncounterTypes::OldRod]; end
  def GoodRod; return @encounters[EncounterTypes::GoodRod]; end
  def SuperRod; return @encounters[EncounterTypes::SuperRod]; end
  def HeadbuttLow; return @encounters[EncounterTypes::HeadbuttLow]; end
  def HeadbuttHigh; return @encounters[EncounterTypes::HeadbuttHigh]; end
  def LandMorning; return @encounters[EncounterTypes::LandMorning]; end
  def LandDay; return @encounters[EncounterTypes::LandDay]; end
  def LandNight; return @encounters[EncounterTypes::LandNight]; end
  def BugContest; return @encounters[EncounterTypes::BugContest]; end
  def WaterDay; return @encounters[EncounterTypes::WaterDay]; end
  def WaterNight; return @encounters[EncounterTypes::WaterNight]; end

  class << self
    alias azure_uncached_new new

    def data; return pbCachedData("Data/encounters.dat"); end

    def normalize_id(value)
      return value.to_i if value.is_a?(Numeric) && value.to_i==value
      return value.to_i if value.is_a?(String) && value[/^\d+$/]
      return nil
    end

    def normalize_type(value)
      return value.to_i if value.is_a?(Numeric) && value.to_i==value
      return value.to_i if value.is_a?(String) && value[/^\d+$/]
      return nil if !value.is_a?(String) && !value.is_a?(Symbol)
      token=value.to_s.gsub(/[^A-Za-z0-9]/,"").upcase
      for index in 0...EncounterTypes::Names.length
        name=EncounterTypes::Names[index].to_s.gsub(/[^A-Za-z0-9]/,"").upcase
        return index if name==token
      end
      return nil
    end

    def immutable_encounters(source)
      tables=[]
      for typeid in 0...source.length
        table=source[typeid]
        next if !table
        rows=[]
        for row in table
          rows.push((row || []).clone.freeze)
        end
        tables[typeid]=rows.freeze
      end
      return tables.freeze
    end

    def new(mapid)
      id=normalize_id(mapid)
      return azure_uncached_new(mapid) if id.nil?
      source=data
      return wrapper_for(id,source)
    end

    def wrapper_for(id,source)
      if @azure_source_id!=source.object_id
        @azure_source_id=source.object_id
        @azure_cache={}
      end
      row=source[id]
      cached=@azure_cache[id] if @azure_cache
      if cached && cached.instance_variable_get(:@azure_source_row).equal?(row)
        return cached
      end
      wrapper=azure_uncached_new(id)
      @azure_cache[id]=wrapper
      return wrapper
    end

    def get(mapid)
      id=normalize_id(mapid)
      source=data
      raise ArgumentError.new("Unknown map encounters #{mapid.inspect}") if id.nil? || id<=0 || !source[id]
      return wrapper_for(id,source)
    end

    def try_get(mapid)
      id=normalize_id(mapid)
      return nil if id.nil? || id<=0
      source=data
      return nil if !source[id]
      return wrapper_for(id,source)
    end

    def exists?(mapid); return !try_get(mapid).nil?; end
    def each
      return enum_for(:each) if !block_given?
      source=data
      for mapid in source.keys.sort
        yield wrapper_for(mapid,source) if source[mapid]
      end
    end

    def clear_cache
      @azure_source_id=nil
      @azure_cache={}
    end
  end
end

def pbInvalidateEncounterData
  AzureDataCache.clear("Data/encounters.dat") if defined?(AzureDataCache)
  PBEncounterData.clear_cache if defined?(PBEncounterData)
end



class PokemonEncounters
  def initialize
    @enctypes=[]
    @density=nil
  end

  def stepcount
    return @stepcount
  end

  def clearStepCount
    @stepcount=0
  end

  def hasEncounter?(enc)
    return false if @density==nil || enc<0
    return @enctypes[enc] ? true : false  
  end

  def isCave?
    return false if @density==nil
    return @enctypes[EncounterTypes::Cave] ? true : false
  end

  def isGrass?
    return false if @density==nil
    return (@enctypes[EncounterTypes::Land] ||
            @enctypes[EncounterTypes::LandMorning] ||
            @enctypes[EncounterTypes::LandDay] ||
            @enctypes[EncounterTypes::LandNight] ||
            @enctypes[EncounterTypes::BugContest]) ? true : false
  end

  def isRegularGrass?
    return false if @density==nil
    return (@enctypes[EncounterTypes::Land] ||
            @enctypes[EncounterTypes::LandMorning] ||
            @enctypes[EncounterTypes::LandDay] ||
            @enctypes[EncounterTypes::LandNight]) ? true : false
  end

  def isWater?
    return false if @density==nil
    return (@enctypes[EncounterTypes::Water] ||
            @enctypes[EncounterTypes::WaterDay] ||
            @enctypes[EncounterTypes::WaterNight]) ? true : false
  end

  def isDesert?
    return false if @density==nil
    return (@enctypes[EncounterTypes::Land] ||
            @enctypes[EncounterTypes::LandMorning] ||
            @enctypes[EncounterTypes::LandDay] ||
            @enctypes[EncounterTypes::LandNight]) ? true : false
  end
  
  def pbEncounterType
    if $PokemonGlobal && ($PokemonGlobal.surfing ||
       ($PokemonGlobal.respond_to?(:swimming) && $PokemonGlobal.swimming))
      time = pbGetTimeNow
      enctype = EncounterTypes::Water
      enctype = EncounterTypes::WaterNight if self.hasEncounter?(EncounterTypes::WaterNight) && PBDayNight.isNight?(time)
      enctype = EncounterTypes::WaterDay if self.hasEncounter?(EncounterTypes::WaterDay) && PBDayNight.isDay?(time)
      # Morning uses WaterDay if available, otherwise falls back to Water
      enctype = EncounterTypes::WaterDay if self.hasEncounter?(EncounterTypes::WaterDay) && PBDayNight.isMorning?(time)
      return enctype
    elsif self.isCave?
      return EncounterTypes::Cave
    elsif self.isGrass?
      time=pbGetTimeNow
      enctype=EncounterTypes::Land
      enctype=EncounterTypes::LandNight if self.hasEncounter?(EncounterTypes::LandNight) && PBDayNight.isNight?(time)
      enctype=EncounterTypes::LandDay if self.hasEncounter?(EncounterTypes::LandDay) && PBDayNight.isDay?(time)
      enctype=EncounterTypes::LandMorning if self.hasEncounter?(EncounterTypes::LandMorning) && PBDayNight.isMorning?(time)
      if pbInBugContest? && self.hasEncounter?(EncounterTypes::BugContest)
        enctype=EncounterTypes::BugContest
      end
      return enctype
    elsif self.isDesert?
      time=pbGetTimeNow
      enctype=EncounterTypes::Land
      enctype=EncounterTypes::LandNight if self.hasEncounter?(EncounterTypes::LandNight) && PBDayNight.isNight?(time)
      enctype=EncounterTypes::LandDay if self.hasEncounter?(EncounterTypes::LandDay) && PBDayNight.isDay?(time)
      enctype=EncounterTypes::LandMorning if self.hasEncounter?(EncounterTypes::LandMorning) && PBDayNight.isMorning?(time)
      if pbInBugContest? && self.hasEncounter?(EncounterTypes::BugContest)
        enctype=EncounterTypes::BugContest
      end
      return enctype
    end
    return -1
  end

  def isEncounterPossibleHere?
    if $PokemonGlobal && $PokemonGlobal.surfing
      return true
    elsif $PokemonGlobal && $PokemonGlobal.respond_to?(:swimming) && $PokemonGlobal.swimming
      return true
    elsif pbGetTerrainTag($game_player)==PBTerrain::Ice
      return false
    elsif self.isCave?
      return true
    elsif self.isGrass?
      return pbIsGrassTag?($game_map.terrain_tag($game_player.x,$game_player.y))
    elsif self.isDesert?
      return pbIsDesertTag?($game_map.terrain_tag($game_player.x,$game_player.y))
    end
    return false
  end

  def setup(mapID)
    @density=nil
    @stepcount=0
    @enctypes=[]
    begin
      data=PBEncounterData.try_get(mapID)
      if data
        @density=data.densities
        @enctypes=data.encounters
      else
        @density=nil
        @enctypes=[]
      end
      rescue
      @density=nil
      @enctypes=[]
    end
  end

  def pbMapHasEncounter?(mapID,enctype)
    data=PBEncounterData.try_get(mapID)
    return false if !data || enctype<0
    return data.has_type?(enctype)
  end

  def pbMapEncounter(mapID,enctype)
    if enctype<0 || enctype>EncounterTypes::EnctypeChances.length
      raise ArgumentError.new(_INTL("Encounter type out of range"))
    end
    data=PBEncounterData.try_get(mapID)
    return nil if !data
    enctypes=data.encounters
    return nil if enctypes[enctype]==nil
    chances=EncounterTypes::EnctypeChances[enctype]
    chancetotal=0
    chances.each {|a| chancetotal+=a}
    rnd=rand(chancetotal)
    chosenpkmn=0
    chance=0
    for i in 0...chances.length
      chance+=chances[i]
      if rnd<chance
        chosenpkmn=i
        break
      end
    end
    encounter=enctypes[enctype][chosenpkmn]
    level=encounter[1]+rand(1+encounter[2]-encounter[1])
    return [encounter[0],level]
  end

# UPDATE 11/18/2013
# the following functions were copied from PokeBattle_Pokemon and slightly
# modified to fit the needs for this problem.
# they are used to determine the type of possible pokemon encounters
  def hasType?(species, type)
    if type.is_a?(String) || type.is_a?(Symbol)
      return isConst?(type1(species),PBTypes,type)||isConst?(type2(species),PBTypes,type)
    else
      return type1==type || type2==type
    end
  end
# Returns this Pokémon's first type.
  def type1(species)
    return $pkmn_dex[species][3]
  end

# Returns this Pokémon's second type.
  def type2(species)
    return $pkmn_dex[species][4]
  end

# adjusts the chances of finding a Pokemon of type by mult
# Note: This does NOT increase the find chance by mult (strictly speaking)
# Since a random number is created between 0 <= r < sum of chances
# Increasing these numbers will shift around the find rate of all of them.
  def shiftChances(chances, enctype, type, mult)
    for i in 0...chances.length
      pkmn = @enctypes[enctype][i]
      chances[i] *= mult if hasType?(pkmn[0], type)
      chances[i] = 1 if chances[i] < 1
      chances[i] = chances[i].to_i
    end
    return chances
  end
# end of update
  
  def pbEncounteredPokemon(enctype,tries=1)
    if enctype<0 || enctype>EncounterTypes::EnctypeChances.length
      raise ArgumentError.new(_INTL("Encounter type out of range"))
    end
    return nil if @enctypes[enctype]==nil
    # Ability weighting is per roll. Never mutate the shared constants.
    chances=EncounterTypes::EnctypeChances[enctype].clone
# UPDATE 11/18/2013
# I assumed multiple abilities would change the encounter rate.
# (Apparently it's only Magnet Pull)
# But if more exist in the future, this will make it easy to add them
# First Pokemon has Magnet Pull
    if !$Trainer.party[0].egg?
      abl = $Trainer.party[0].ability
      if isConst?(abl,PBAbilities,:MAGNETPULL)
        chances = shiftChances(chances, enctype, :STEEL, 1.5)
      end
      if isConst?(abl,PBAbilities,:FLASHFIRE)
        chances = shiftChances(chances, enctype, :FIRE, 1.5)
      end
      if isConst?(abl,PBAbilities,:HARVEST)
        chances = shiftChances(chances, enctype, :GRASS, 1.5)
      end
      if isConst?(abl,PBAbilities,:LIGHTNINGROD)
        chances = shiftChances(chances, enctype, :ELECTRIC, 1.5)
      end
      if isConst?(abl,PBAbilities,:STATIC)
        chances = shiftChances(chances, enctype, :ELECTRIC, 1.5)
      end
      if isConst?(abl,PBAbilities,:STORMDRAIN)
        chances = shiftChances(chances, enctype, :WATER, 1.5)
      end
    end
# end of update
# pkedit
  #####MODDED
  aArr = []
  if !$Trainer.party[0].egg? #Should also check for $Trainer.party[0].hp > 0 by logic, but then it wouldn't be in line with the other overworld party leader checks
    if $game_switches[74]
      for i in 0...chances.length
        aEnc = @enctypes[enctype][i]        
        if !(aEnc == nil)
          if !$Trainer.owned[aEnc[0]]
            aArr.push(i)
          end
        end
      end
    end
  end  
  if aArr.length > 0
    chosenpkmn = aArr[rand(aArr.length)]
    encounter = @enctypes[enctype][chosenpkmn].clone
  else
    #####/MODDED
    chancetotal=0
    chances.each {|a| chancetotal+=a}
    rnd=0
    tries.times do
      r=rand(chancetotal)
      rnd=r if rnd<r
    end
    chosenpkmn=0
    chance=0
    for i in 0...chances.length
      chance+=chances[i]
      if rnd<chance
        chosenpkmn=i
        break
      end
    end
    encounter=@enctypes[enctype][chosenpkmn].clone
  end #####MODDED
  return nil if !encounter
# UPDATE 11/19/2013
# pressure, hustle and vital spirit will now have a 150% chance of
# finding higher leveled pokemon in encounters
    if !$Trainer.party[0].egg?
      abl = $Trainer.party[0].ability
      if (isConst?(abl, PBAbilities, :PRESSURE) ||
       isConst?(abl, PBAbilities, :HUSTLE) ||
       isConst?(abl, PBAbilities, :VITALSPIRIT)) &&
       rand(2) == 0
# increase the lower bound to half way in-between lower and upper
        encounter[1] += (encounter[2] - encounter[1]) / 2
      end
    end
# end of update
    level=encounter[1]+rand(1+encounter[2]-encounter[1])
    return [encounter[0],level]
  end

  def pbCanEncounter?(encounter,repel)
    return false if $game_system.encounter_disabled
    return false if !encounter || !$Trainer
    return false if $DEBUG && Input.press?(Input::CTRL)
    if !pbPokeRadarOnShakingGrass
      return false if $PokemonGlobal.repel>0 && $Trainer.ablePokemonCount>0 &&
                      encounter[1]<$Trainer.ablePokemonParty[0].level
    end
    return true
  end

  def pbGenerateEncounter(enctype)
    if enctype<0 || enctype>EncounterTypes::EnctypeChances.length
      raise ArgumentError.new(_INTL("Encounter type out of range"))
    end
    return nil if @density==nil
    return nil if @density[enctype]==0 || !@density[enctype]
    return nil if @enctypes[enctype]==nil
    @stepcount+=1
    return nil if @stepcount<=3 # Check three steps after battle ends
    encount=@density[enctype]*16
    if $PokemonGlobal.bicycle
      encount=(encount*4/5)
    end
#    if $PokemonMap.blackFluteUsed
#      encount/=2
#    end
#    if $PokemonMap.whiteFluteUsed
#      encount=(encount*3/2)
#    end
    if $Trainer.party.length>0 && !$Trainer.party[0].isEgg?
      if isConst?($Trainer.party[0].item,PBItems,:CLEANSETAG)
        encount=(encount*2/3)
      elsif isConst?($Trainer.party[0].item,PBItems,:PUREINCENSE)
        encount=(encount*2/3)
      else   # Ignore ability effects if an item effect applies
        if isConst?($Trainer.party[0].ability,PBAbilities,:STENCH)
          encount=(encount/2)
        elsif isConst?($Trainer.party[0].ability,PBAbilities,:WHITESMOKE)
          encount=(encount/2)
        elsif isConst?($Trainer.party[0].ability,PBAbilities,:QUICKFEET)
          encount=(encount/2)
        elsif isConst?($Trainer.party[0].ability,PBAbilities,:INFILTRATOR)
          encount=(encount/2)
        elsif isConst?($Trainer.party[0].ability,PBAbilities,:SNOWCLOAK) &&
           $game_screen.weather_type==3
          encount=(encount/2)
        elsif isConst?($Trainer.party[0].ability,PBAbilities,:SANDVEIL) &&
           $game_screen.weather_type==4
          encount=(encount/2)
        elsif isConst?($Trainer.party[0].ability,PBAbilities,:SWARM)
          encount=(encount*3/2)
        elsif isConst?($Trainer.party[0].ability,PBAbilities,:ILLUMINATE)
          encount=(encount*2)
        elsif isConst?($Trainer.party[0].ability,PBAbilities,:ARENATRAP)
          encount=(encount*2)
        elsif isConst?($Trainer.party[0].ability,PBAbilities,:NOGUARD)
          encount=(encount*2)
        end
      end
    end
    # PokeMagnet attract mode doubles encounter rate
    if $game_switches[74]  # Attract mode
      encount=(encount*2)
    end
    return nil if rand(180*16)>=encount
    encpoke=pbEncounteredPokemon(enctype)
    if $Trainer.party.length>0 && !$Trainer.party[0].isEgg?
      if encpoke && isConst?($Trainer.party[0].ability,PBAbilities,:INTIMIDATE) &&
         encpoke[1]<=$Trainer.party[0].level-5 && rand(2)==0
        encpoke=nil
      end
      if encpoke && isConst?($Trainer.party[0].ability,PBAbilities,:KEENEYE) &&
         encpoke[1]<=$Trainer.party[0].level-5 && rand(2)==0
        encpoke=nil
      end
    end
    return encpoke
  end
end
