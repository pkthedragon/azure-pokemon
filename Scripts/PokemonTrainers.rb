TSPECIES   = 0
TPLEVEL     = 1
TPITEM      = 2
TPMOVE1     = 3
TPMOVE2     = 4
TPMOVE3     = 5
TPMOVE4     = 6
TPABILITY   = 7
TPGENDER    = 8
TPFORM      = 9
TPSHINY     = 10
TPNATURE    = 11
TPIV        = 12
TPHAPPINESS = 13
TPNAME      = 14
TPSHADOW    = 15
TPBALL      = 16
TPHIDDENPOWER = 17
TPHPEV        = 18
TPATKEV       = 19
TPDEFEV       = 20
TPSPEEV       = 21
TPSPAEV       = 22
TPSPDEV       = 23
TPPREMEGA     = 24
TPBOSS        = 25
TPHPOB        = 26
TPATKOB       = 27
TPDEFOB       = 28
TPSPEOB       = 29
TPSPAOB       = 30
TPSPDOB       = 31
TPABILITYOVERRIDE = 32
TPDEFAULTS = [0,10,0,0,0,0,0,nil,nil,0,false,nil,10,70,nil,false,0,17,0,0,0,0,0,0,false,nil,0,0,0,0,0,0]

#pk code
class PBTrainerPokemonData
  attr_reader :species,:level,:item,:moves,:ability,:gender,:form,:shiny
  attr_reader :nature,:iv,:happiness,:name,:shadow,:ball,:hidden_power
  attr_reader :evs,:premega,:boss,:offsets,:ability_override

  def initialize(row)
    @species=row[TSPECIES]
    @level=row[TPLEVEL]
    @item=row[TPITEM]
    @moves=[row[TPMOVE1],row[TPMOVE2],row[TPMOVE3],row[TPMOVE4]].freeze
    @ability=row[TPABILITY]
    @ability_override=row[TPABILITYOVERRIDE]
    @gender=row[TPGENDER]
    @form=row[TPFORM]
    @shiny=row[TPSHINY]
    @nature=row[TPNATURE]
    @iv=row[TPIV]
    @happiness=row[TPHAPPINESS]
    @name=row[TPNAME].is_a?(String) ? row[TPNAME].clone.freeze : row[TPNAME]
    @shadow=row[TPSHADOW]
    @ball=row[TPBALL]
    @hidden_power=row[TPHIDDENPOWER]
    @evs=[row[TPHPEV],row[TPATKEV],row[TPDEFEV],row[TPSPEEV],row[TPSPAEV],row[TPSPDEV]].freeze
    @premega=row[TPPREMEGA]
    @boss=row[TPBOSS]
    @offsets=[row[TPHPOB],row[TPATKOB],row[TPDEFOB],row[TPSPEOB],row[TPSPAOB],row[TPSPDOB]].freeze
    freeze
  end
end

#pk code
class PBTrainerTeamData
  attr_reader :index,:name,:trainer_type,:party_id,:items,:party

  def initialize(index,row)
    @index=index
    @trainer_type=row[0]
    @name=row[1].is_a?(String) ? row[1].clone.freeze : row[1]
    @items=(row[2] || []).clone.freeze
    pokemon=[]
    for entry in (row[3] || [])
      pokemon.push(PBTrainerPokemonData.new(entry))
    end
    @party=pokemon.freeze
    @party_id=row[4] || 0
    @azure_source_row=row
    freeze
  end

  def trainerType; return @trainer_type; end
  def partyID; return @party_id; end
  def teamid; return [@name,@trainer_type,@party_id].freeze; end
  def key; return [@trainer_type,@name,@party_id].freeze; end
end

#pk code
module AzureTrainerDataCache
  def self.normalize_type(value)
    return value.to_i if value.is_a?(Numeric) && value.to_i==value
    if value.is_a?(String) || value.is_a?(Symbol)
      return nil if !hasConst?(PBTrainers,value)
      return getID(PBTrainers,value)
    end
    return nil
  end

  def self.data
    $trainerdata=load_data("Data/trainers.dat") if !$trainerdata
    sync($trainerdata)
    return $trainerdata
  end

  def self.sync(records)
    source_id=records ? records.object_id : nil
    source_length=records ? records.length : 0
    return if @source_id==source_id && @source_length==source_length && @index
    @source_id=source_id
    @source_length=source_length
    @index={}
    @positions={}
    @teams={}
    return if !records
    for position in 0...records.length
      trainer=records[position]
      next if !trainer
      key=[trainer[0],trainer[1],trainer[4]]
      # Keep the first duplicate.
      if !@index.has_key?(key)
        @index[key]=trainer
        @positions[key]=position
      end
    end
  end

  def self.record(trainerid,trainername,partyid=0)
    records=data
    return nil if !records
    trainerid=normalize_type(trainerid)
    return nil if trainerid.nil?
    return @index[[trainerid,trainername,partyid]]
  end

  def self.team(trainerid,trainername,partyid=0)
    trainerid=normalize_type(trainerid)
    return nil if trainerid.nil?
    records=data
    key=[trainerid,trainername,partyid]
    row=@index[key]
    return nil if !row
    cached=@teams[key] if @teams
    if cached && cached.instance_variable_get(:@azure_source_row).equal?(row)
      return cached
    end
    cached=PBTrainerTeamData.new(@positions[key],row)
    @teams[key]=cached
    return cached
  end

  def self.exists?(trainerid,trainername,partyid=0)
    return !record(trainerid,trainername,partyid).nil?
  end

  def self.free_party_id(trainerid,trainername,limit=256)
    trainerid=normalize_type(trainerid)
    return -1 if trainerid.nil?
    data
    for partyid in 0...limit
      return partyid if !@index.has_key?([trainerid,trainername,partyid])
    end
    return -1
  end

  def self.each_team
    return enum_for(:each_team) if !block_given?
    records=data
    for index in 0...records.length
      row=records[index]
      next if !row
      key=[row[0],row[1],row[4]]
      next if @positions[key]!=index
      yield team(row[0],row[1],row[4])
    end
  end

  def self.replace(records)
    $trainerdata=records
    clear
    sync(records)
    return records
  end

  def self.clear
    @source_id=nil
    @source_length=nil
    @index=nil
    @positions=nil
    @teams=nil
  end
end

#pk code
class AzureTrainerTeamEditorData
  attr_reader :records

  def self.load
    return self.new(load_data("Data/trainers.dat"))
  end

  def initialize(records)
    @records=records || []
    rebuild
  end

  def key_for(record)
    return [record[0],record[1],record[4] || 0]
  end

  def rebuild
    @index={}
    for index in 0...@records.length
      record=@records[index]
      next if !record
      key=key_for(record)
      @index[key]=index if !@index.has_key?(key)
    end
  end

  def each
    return enum_for(:each) if !block_given?
    for index in 0...@records.length
      yield index,@records[index] if @records[index]
    end
  end

  def record_at(index); return @records[index]; end
  def index_for(trainerid,trainername,partyid=0)
    trainerid=AzureTrainerDataCache.normalize_type(trainerid)
    return nil if trainerid.nil?
    return @index[[trainerid,trainername,partyid]]
  end
  def exists?(trainerid,trainername,partyid=0)
    return !index_for(trainerid,trainername,partyid).nil?
  end
  def free_party_id(trainerid,trainername,limit=256)
    trainerid=AzureTrainerDataCache.normalize_type(trainerid)
    return -1 if trainerid.nil?
    for partyid in 0...limit
      return partyid if !@index.has_key?([trainerid,trainername,partyid])
    end
    return -1
  end
  def conflicting_index(record,except_index=nil)
    index=@index[key_for(record)]
    return nil if index.nil? || index==except_index
    return index
  end
  def add(record)
    return nil if conflicting_index(record)
    @records.push(record)
    rebuild
    return @records.length-1
  end
  def replace_at(index,record)
    return false if index<0 || index>=@records.length
    return false if conflicting_index(record,index)
    @records[index]=record
    rebuild
    return true
  end
  def delete_at(index)
    return nil if index<0 || index>=@records.length
    record=@records.delete_at(index)
    rebuild
    return record
  end
  def commit
    rebuild
    save_data(@records,"Data/trainers.dat")
    AzureTrainerDataCache.replace(@records)
    return @records
  end
end

#pk code
def pbTrainerEVSpread(poke,pokemon)
  evs=poke.values_at(TPHPEV,TPATKEV,TPDEFEV,TPSPEEV,TPSPAEV,TPSPDEV).map(&:to_i)
  return Array.new(6,[85,pokemon.level*3/2].min) if evs.sum==0
  return evs.map { |ev| ev==252 ? pokemon.evStatCap : ev }
end

def pbLoadTrainerDifficult(trainerid,trainername,partyid=0,procedure=nil)
  if trainerid.is_a?(String) || trainerid.is_a?(Symbol)
    if !hasConst?(PBTrainers,trainerid)
      raise _INTL("Trainer type does not exist ({1}, {2}, ID {3})",trainerid,trainername,partyid)
    end
    trainerid=getID(PBTrainers,trainerid)
  end
  success=false
  items=[]
  party=[]
  opponent=nil
  trainer=AzureTrainerDataCache.record(trainerid,trainername,partyid)
  if trainer
    name=trainer[1]
    thistrainerid=trainer[0]
    thispartyid=trainer[4]
    items=trainer[2].clone
    name=pbGetMessageFromHash(MessageTypes::TrainerNames,name)
    for i in RIVALNAMES
      if isConst?(trainerid,PBTrainers,i[0]) && $game_variables[i[1]]!=0
        name=$game_variables[i[1]]
      end
    end
    opponent=PokeBattle_Trainer.new(name,thistrainerid)
    opponent.setForeignID($Trainer) if $Trainer
    for poke in trainer[3]
      boss = poke[TPBOSS].is_a?(Symbol) ? $bosscache[poke[TPBOSS]] : nil
      if boss
        if $game_variables[:Difficulty_Mode] == 2 #pk code
          boss = ((poke[TPBOSS].to_s) +"_INTENSE").intern
          boss = poke[TPBOSS] if !$bosscache[boss]
        elsif [0,1].include?($game_variables[:Difficulty_Mode]) #pk code
          boss = ((poke[TPBOSS].to_s) +"_NORMAL").intern
          boss = poke[TPBOSS] if !$bosscache[boss]
        end
        if $bosscache[boss]
          Events.onBossCreate.trigger(nil,poke[TPBOSS])
        end
        party.push(pbLoadWildBoss(boss,$bosscache))
        next
      end
      species=poke[TSPECIES]
      level = DifficultModes.applyLevelProcedure(poke[TPLEVEL],procedure)
      pokemon=PokeBattle_Pokemon.new(species,level,opponent)
      pokemon.form=poke[TPFORM]
      pokemon.resetMoves
      pokemon.setItem(poke[TPITEM])
      if poke[TPMOVE1]>0 || poke[TPMOVE2]>0 || poke[TPMOVE3]>0 || poke[TPMOVE4]>0
        k=0
        for move in [TPMOVE1,TPMOVE2,TPMOVE3,TPMOVE4]
          pokemon.moves[k]=PBMove.new(poke[move])
          k+=1
        end
        pokemon.moves.compact!
      end
      pokemon.setAbility(poke[TPABILITY])
      pokemon.abilityoverride=poke[TPABILITYOVERRIDE] if !poke[TPABILITYOVERRIDE].nil?
      pokemon.setGender(poke[TPGENDER])
      if poke[TPSHINY]   # if this is a shiny Pokémon
        pokemon.makeShiny
      else
        pokemon.makeNotShiny
      end
      pokemon.setNature(poke[TPNATURE])
      iv=poke[TPIV]
      if iv && iv > 0 && iv != TPDEFAULTS[TPIV]
        for i in 0...6
          if iv == 32
            pokemon.iv[0]=31
            pokemon.iv[1]=31
            pokemon.iv[2]=31
            pokemon.iv[3]=0
            pokemon.iv[4]=31
            pokemon.iv[5]=31
          else
            pokemon.iv[i]=iv&0x1F
          end
        end
      else
        for i in 0...6
          pokemon.iv[i]=31
        end
      end
      if poke[TPPREMEGA]=="true"
        pokemon.enablepremega
      end
      pokemon.ev=pbTrainerEVSpread(poke,pokemon) #pk code
      pokemon.obhp=poke[TPHPOB].to_i
      pokemon.obatk=poke[TPATKOB].to_i
      pokemon.obdef=poke[TPDEFOB].to_i
      pokemon.obspe=poke[TPSPEOB].to_i
      pokemon.obspa=poke[TPSPAOB].to_i
      pokemon.obspd=poke[TPSPDOB].to_i   
      pokemon.happiness=poke[TPHAPPINESS]
      pokemon.name=poke[TPNAME] if poke[TPNAME] && poke[TPNAME]!=""
      if poke[TPSHADOW]   # if this is a Shadow Pokémon
        pokemon.makeShadow rescue nil
        pokemon.pbUpdateShadowMoves(true) rescue nil
        pokemon.makeNotShiny
      end
      pokemon.ballused=poke[TPBALL]
      pokemon.calcStats
      party.push(pokemon)
    end
    success=true
  end
  return success ? [opponent,items,party] : nil
end

def bossFunction(boss,bossid,pokemon)
  pokemon.enablebossmon 
  pokemon.shieldCount = boss.shieldCount
  pokemon.bossId = bossid
end

def pbConvertTrainerData
  data=load_data("Data/trainertypes.dat")
  trainertypes=[]
  for i in 0...data.length
    record=data[i]
    if record
      trainertypes[record[0]]=record[2]
    end
  end
  MessageTypes.setMessages(MessageTypes::TrainerTypes,trainertypes)
  pbSaveTrainerTypes()
  pbSaveTrainerBattles()
end

def pbNewTrainer(trainerid,trainername,trainerparty,editorData=nil)
  pokemon=[]
  level=TPDEFAULTS[TPLEVEL]
  for i in 1..6
    if i==1
      Kernel.pbMessage(_INTL("Please enter the first Pokémon.",i))
    else
      break if !Kernel.pbConfirmMessage(_INTL("Add another Pokémon?"))
    end
    loop do
      species=pbChooseSpeciesOrdered(1)
      if species<=0
        if i==1
          Kernel.pbMessage(_INTL("This trainer must have at least 1 Pokémon!"))
        else
          break
        end
      else
        params=ChooseNumberParams.new
        params.setRange(1,PBExperience::MAXLEVEL)
        params.setDefaultValue(level)
        level=Kernel.pbMessageChooseNumber(_INTL("Set the level for {1}.",
           PBSpecies.getName(species)),params)
        tempPoke=PokeBattle_Pokemon.new(species,level)
        pokemon.push([species,level,0,
           tempPoke.moves[0].id,
           tempPoke.moves[1].id,
           tempPoke.moves[2].id,
           tempPoke.moves[3].id
        ])
        break
      end
    end
  end
  trainer=[trainerid,trainername,[],pokemon,trainerparty]
  editorData=AzureTrainerTeamEditorData.load if !editorData
  conflict=editorData.conflicting_index(trainer)
  if conflict
    Kernel.pbMessage(_INTL("A Trainer battle with this type, name, and ID already exists at index {1}.",conflict))
    return nil
  end
  editorData.add(trainer)
  editorData.commit
  pbConvertTrainerData
  Kernel.pbMessage(_INTL("The Trainer's data was added to the list of battles and at PBS/trainers.txt."))
  return trainer
end

def pbTrainerTypeCheck(symbol)
  ret=true
  if $DEBUG
    if !hasConst?(PBTrainers,symbol)
      ret=false
    else
      trtype=PBTrainers.const_get(symbol)
      data=load_data("Data/trainertypes.dat")
      ret=false if !data || !data[trtype]
    end
    if !ret
      if Kernel.pbConfirmMessage(_INTL("Add new trainer type {1}?",symbol))
        pbTrainerTypeEditorNew(symbol.to_s)
      end
      pbMapInterpreter.command_end if pbMapInterpreter
    end
  end
  return ret
end

def pbGetFreeTrainerParty(trainerid,trainername,editorData=nil)
  return editorData.free_party_id(trainerid,trainername) if editorData
  return AzureTrainerDataCache.free_party_id(trainerid,trainername)
end

def pbTrainerCheck(trainerid,trainername,maxbattles,startBattleId=0)
  if $DEBUG
    if trainerid.is_a?(String) || trainerid.is_a?(Symbol)
      pbTrainerTypeCheck(trainerid)
      return false if !hasConst?(PBTrainers,trainerid)
      trainerid=PBTrainers.const_get(trainerid)
    end
    for i in 0...maxbattles
      trainer=pbLoadTrainer(trainerid,trainername,i+startBattleId)
      if !trainer
        traineridstring="#{trainerid}"
        traineridstring=getConstantName(PBTrainers,trainerid) rescue "-"
        if Kernel.pbConfirmMessage(_INTL("Add new battle {1} (of {2}) for ({3}, {4})?",
          i+1,maxbattles,traineridstring,trainername))
          pbNewTrainer(trainerid,trainername,i)
        end
      end
    end
  end
  return true
end

def pbMissingTrainer(trainerid, trainername, trainerparty)
  if trainerid.is_a?(String) || trainerid.is_a?(Symbol)
    if !hasConst?(PBTrainers,trainerid)
      raise _INTL("Trainer type does not exist ({1}, {2}, ID {3})",trainerid,trainername,partyid)
    end
    trainerid=getID(PBTrainers,trainerid)
  end
  traineridstring="#{trainerid}"
  traineridstring=getConstantName(PBTrainers,trainerid) rescue "-"
  if $DEBUG
    message=""
    if trainerparty!=0
      message=(_INTL("Add new trainer ({1}, {2}, ID {3})?",traineridstring,trainername,trainerparty))
    else
      message=(_INTL("Add new trainer ({1}, {2})?",traineridstring,trainername))
    end
    cmd=Kernel.pbMessage(message,[_INTL("Yes"),_INTL("No")],2)
    if cmd==0
      pbNewTrainer(trainerid,trainername,trainerparty)
    end
    return cmd
  else
    raise _INTL("Can't find trainer ({1}, {2}, ID {3})",traineridstring,trainername,trainerparty)
  end
end

# Rematch code

def pbTrainerRematchKey(trainerid, trainername, trainerparty, battlekind,
                        trainerid2=nil, trainername2=nil, trainerparty2=nil)
  if trainerid.is_a?(String) || trainerid.is_a?(Symbol)
    trainerid=getID(PBTrainers,trainerid)
  end
  if trainerid2 && (trainerid2.is_a?(String) || trainerid2.is_a?(Symbol))
    trainerid2=getID(PBTrainers,trainerid2)
  end
  if trainerid==PBTrainers::PAX && trainername=="Pax" && trainerparty==0 && !trainerid2 && battlekind=="single" #pk code
    battlekind="double"
  end
  return [trainerid,trainername,trainerparty,battlekind,
          trainerid2,trainername2,trainerparty2]
end

#pk code
def pbGetBossTrainerRematches
  $boss_trainer_rematches ||= [
    # Normal terrain battles
    pbTrainerRematchKey(:POKEMONTRAINER_Kara,"Kara",0,"single"),
    pbTrainerRematchKey(:POKEMONTRAINER_Percy,"Percy",0,"single"),
    pbTrainerRematchKey(:POKEMONTRAINER_Kara,"Kara",2,"single"),
    # Grassy Terrain battles
    pbTrainerRematchKey(:HANDMAIDEN,"Rose",0,"single"),
    pbTrainerRematchKey(:LUX,"Lux",0,"single"),
    pbTrainerRematchKey(:ELDERCULTIST_Perrin,"Pride",0,"double",
                        :POKEMONTRAINER_Percy,"Percy",0),
    pbTrainerRematchKey(:POKEMONTRAINER_Kara,"Kara",3,"single"),
    pbTrainerRematchKey(:LISTIS,"Listis",0,"single"),
    pbTrainerRematchKey(:POKEFAN_M2,"Bryant",0,"single"),
    pbTrainerRematchKey(:PAX,"Pax",0,"double"),
    # Library Field battles
    pbTrainerRematchKey(:MINERVA,"Minerva",0,"single"),
    pbTrainerRematchKey(:ATEN,"Aten",0,"single"),
    pbTrainerRematchKey(:TEMPLAR1,"Davith",0,"single"),
    # Beach battles
    pbTrainerRematchKey(:POKEMONTRAINER_Percy,"Percy",1,"single"),
    pbTrainerRematchKey(:ZOSSIE,"Zossie",0,"double"),
    pbTrainerRematchKey(:ELDER,"Nick",0,"double"),
    pbTrainerRematchKey(:TRENT,"Trent",0,"single"),
    # Cave battles
    pbTrainerRematchKey(:POKEMONRANGER_M,"Pyuku",0,"single"),
    pbTrainerRematchKey(:RICHBOY,"Chuck",0,"single"),
    # Forest Field battles
    pbTrainerRematchKey(:GENTLEMAN,"Willberg",0,"single"),
    pbTrainerRematchKey(:POKEMONRANGER_M,"Pyuku",2,"single"),
    # Double battles (no specific field)
    pbTrainerRematchKey(:CULTISTM,"Alex",0,"double",
                        :CULTISTF,"Harper",0),
    pbTrainerRematchKey(:AURORA,"Aurora",0,"double",:RYOU,"Ryou",0) #pk code
  ]
end

def pbGetBossTrainerFields
  $boss_trainer_fields ||= {
    # Grassy Terrain (2)
    pbTrainerRematchKey(:HANDMAIDEN,"Rose",0,"single") => 2,
    pbTrainerRematchKey(:LUX,"Lux",0,"single") => 2,
    pbTrainerRematchKey(:ELDERCULTIST_Perrin,"Pride",0,"double",
                        :POKEMONTRAINER_Percy,"Percy",0) => 2,
    pbTrainerRematchKey(:POKEMONTRAINER_Kara,"Kara",3,"single") => 2,
    pbTrainerRematchKey(:LISTIS,"Listis",0,"single") => 2,
    pbTrainerRematchKey(:POKEFAN_M2,"Bryant",0,"single") => 2,
    pbTrainerRematchKey(:PAX,"Pax",0,"double") => 2,
    # Library Field (47)
    pbTrainerRematchKey(:MINERVA,"Minerva",0,"single") => 47, #pk code
    pbTrainerRematchKey(:ATEN,"Aten",0,"single") => 47,
    pbTrainerRematchKey(:TEMPLAR1,"Davith",0,"single") => 47,
    # Beach (46)
    pbTrainerRematchKey(:POKEMONTRAINER_Percy,"Percy",1,"single") => 46,
    pbTrainerRematchKey(:ZOSSIE,"Zossie",0,"double") => 46,
    pbTrainerRematchKey(:ELDER,"Nick",0,"double") => 46,
    pbTrainerRematchKey(:TRENT,"Trent",0,"single") => 46,
    # Cave Field (23)
    pbTrainerRematchKey(:POKEMONRANGER_M,"Pyuku",0,"single") => 23,
    pbTrainerRematchKey(:RICHBOY,"Chuck",0,"single") => 23,
    # Forest Field (15)
    pbTrainerRematchKey(:GENTLEMAN,"Willberg",0,"single") => 15,
    pbTrainerRematchKey(:POKEMONRANGER_M,"Pyuku",2,"single") => 15
  }
end

def pbTrainerRematchBoss?(rematch)
  return pbGetBossTrainerRematches.include?(rematch)
end

def pbTrainerRematchField(rematch)
  return pbGetBossTrainerFields[rematch]
end

#pk code
class PokemonGlobalMetadata
  attr_writer :encounteredTrainers

  def encounteredTrainers
    @encounteredTrainers = [] unless @encounteredTrainers.is_a?(Array)
    return @encounteredTrainers
  end

  def recordTrainerEncounter(trainerid,trainername,partyid)
    history = encounteredTrainers
    key = [trainerid,trainername,partyid]
    history.push(key) unless history.include?(key)
  end
end

def pbRegisterTrainerRematch(trainerid, trainername, trainerparty, battlekind,
                             trainerid2=nil, trainername2=nil, trainerparty2=nil)
  return if !$PokemonGlobal
  $PokemonGlobal.trainerRematches ||= []
  key=pbTrainerRematchKey(trainerid,trainername,trainerparty,battlekind,
                          trainerid2,trainername2,trainerparty2)
  $PokemonGlobal.trainerRematches.push(key) if !$PokemonGlobal.trainerRematches.include?(key)
end

def pbTrainerRematchDisplayName(rematch)
  trainer_type=PBTrainers.getName(rematch[0])
  trainer_name=pbGetMessageFromHash(MessageTypes::TrainerNames,rematch[1])
  if rematch[3]=="double" && rematch[4]
    trainer2_type=PBTrainers.getName(rematch[4])
    trainer2_name=pbGetMessageFromHash(MessageTypes::TrainerNames,rematch[5])
    return _INTL("{1} {2} & {3} {4}",trainer_type,trainer_name,trainer2_type,trainer2_name)
  end
  return _INTL("{1} {2}",trainer_type,trainer_name)
end

def pbStartTrainerRematch(rematch)
  endspeech=_INTL("...")
  field=pbTrainerRematchField(rematch)
  $game_variables[708] = field ? field : 0
  if rematch[3]=="double" && rematch[4]
    pbDoubleTrainerBattle(rematch[0],rematch[1],rematch[2],endspeech,
                          rematch[4],rematch[5],rematch[6],endspeech)
  else
    doublebattle = (rematch[3]=="double")
    pbTrainerBattle(rematch[0],rematch[1],endspeech,doublebattle,rematch[2])
  end
end

def pbTrainerRematchListMenu(rematches, title)
  if rematches.empty?
    Kernel.pbMessage(_INTL("There are no {1} in your memory.",title))
    return
  end
  commands=[]
  for rematch in rematches
    commands.push(pbTrainerRematchDisplayName(rematch))
  end
  using(cmdwindow=Window_CommandPokemon.new(commands)) {
    cmdwindow.height=Graphics.height if cmdwindow.height>Graphics.height
    cmdwindow.width=Graphics.width if cmdwindow.width>Graphics.width
    cmdwindow.x=(Graphics.width-cmdwindow.width)/2
    cmdwindow.y=(Graphics.height-cmdwindow.height)/2
    loop do
      Graphics.update
      Input.update
      cmdwindow.update
      if Input.trigger?(Input::B)
        pbPlayCancelSE()
        break
      elsif Input.trigger?(Input::C)
        pbPlayDecisionSE()
        selection=cmdwindow.index
        pbStartTrainerRematch(rematches[selection]) if selection && selection>=0
        break
      end
    end
  }
end

def pbTrainerRematchMenu
  old_menu_disabled = $game_system.menu_disabled rescue false
  rematches = ($PokemonGlobal) ? $PokemonGlobal.trainerRematches : nil
  rematches = [] if !rematches
  if rematches.empty?
    Kernel.pbMessage(_INTL("You can't seem to recall."))
    return
  end
  rematches=rematches.map { |rematch| pbTrainerRematchKey(*rematch) }.uniq #pk code
  boss_rematches = []
  standard_rematches = []
  for rematch in rematches
    if pbTrainerRematchBoss?(rematch)
      boss_rematches.push(rematch)
    else
      standard_rematches.push(rematch)
    end
  end
  $game_system.menu_disabled = true
  commands = [_INTL("Trainer Rematches"), _INTL("Boss Rematches"), _INTL("Cancel")]
  using(cmdwindow = Window_CommandPokemon.new(commands)) {
    cmdwindow.height = Graphics.height if cmdwindow.height > Graphics.height
    cmdwindow.width  = Graphics.width  if cmdwindow.width  > Graphics.width
    cmdwindow.x = (Graphics.width - cmdwindow.width) / 2
    cmdwindow.y = (Graphics.height - cmdwindow.height) / 2
    loop do
      Graphics.update
      Input.update
      cmdwindow.update

      if Input.trigger?(Input::B)
        pbPlayCancelSE()
        break
      elsif Input.trigger?(Input::C)
        pbPlayDecisionSE()
        selection = cmdwindow.index
        if selection == 0
          pbTrainerRematchListMenu(standard_rematches, _INTL("trainers"))
        elsif selection == 1
          pbTrainerRematchListMenu(boss_rematches, _INTL("boss trainers"))
        else
          pbPlayCancelSE()
        end
        break
      end
    end
  }
ensure
  $game_temp.menu_calling = false if $game_temp
  Input.update
  while Input.press?(Input::B) || Input.press?(Input::C)
    Graphics.update
    Input.update
  end
  2.times do
    Graphics.update
    Input.update
  end
  $game_system.menu_disabled = old_menu_disabled
end


def pbPartnerAblePokemonCount
  return 0 if !$PokemonGlobal || !$PokemonGlobal.partner
  party = $PokemonGlobal.partner[3] rescue nil
  return 0 if !party
  ret = 0
  for i in party
    next if !i
    ret += 1 if i.hp > 0 && !i.isEgg?
  end
  return ret
end

def pbCanDoubleBattle?
  return false if !$Trainer
  return false if $PokemonTemp && $PokemonTemp.forceSingleBattle
  return ($Trainer.ablePokemonCount + pbPartnerAblePokemonCount) >= 2
end

def pbCanTripleBattle?
  return false if !$Trainer
  return false if $PokemonTemp && $PokemonTemp.forceSingleBattle
  return ($Trainer.ablePokemonCount + pbPartnerAblePokemonCount) >= 3
end

def pbBattleSizeAllowed?(size_rule)
  normalized = pbNormalizeBattleSizeRule(size_rule)
  return true if !normalized
  needed = pbBattleSideSizeFromRule(normalized, false)
  return true if needed <= 1
  return pbCanDoubleBattle? if needed == 2
  return pbCanTripleBattle?
end

def pbFallbackBattleSizeRule(size_rule)
  normalized = pbNormalizeBattleSizeRule(size_rule)
  normalized = "single" if !normalized
  return "single" if $PokemonTemp && $PokemonTemp.forceSingleBattle
  return normalized if pbBattleSizeAllowed?(normalized)
  needed = pbBattleSideSizeFromRule(normalized, false)
  return "double" if needed >= 3 && pbCanDoubleBattle?
  return "single"
end

def pbResolveTrainerBattleSizeRule(size_rule = nil, foe_trainer_count = 1, legacy_doublebattle = false)
  normalized = pbNormalizeBattleSizeRule(size_rule)
  if !normalized
    normalized = legacy_doublebattle ? "double" : "#{foe_trainer_count}v#{foe_trainer_count}"
    normalized = pbNormalizeBattleSizeRule(normalized)
  end
  return pbFallbackBattleSizeRule(normalized)
end




def pbDoubleTrainerBattle(trainerid1, trainername1, trainerparty1, endspeech1,
                          trainerid2, trainername2, trainerparty2, endspeech2, 
                          canlose=false,variable=nil)
  size_rule = pbResolveTrainerBattleSizeRule(pbBattleRules["size"], 2, true)
  player_side_size = pbBattleSideSizeFromRule(size_rule, false)
  trainer1=pbLoadTrainer(trainerid1,trainername1,trainerparty1)
  Events.onTrainerPartyLoad.trigger(nil,trainer1)
  if !trainer1
    pbMissingTrainer(trainerid1,trainername1,trainerparty1)
    pbClearBattleRules
  end
  trainer2=pbLoadTrainer(trainerid2,trainername2,trainerparty2)
  Events.onTrainerPartyLoad.trigger(nil,trainer2)
  if !trainer2
    pbMissingTrainer(trainerid2,trainername2,trainerparty2)
    pbClearBattleRules
  end
  if !trainer1 || !trainer2
    return false
  end
  if $PokemonGlobal.partner && player_side_size > 1
    othertrainer=PokeBattle_Trainer.new($PokemonGlobal.partner[1],
                                        $PokemonGlobal.partner[0])
    othertrainer.id=$PokemonGlobal.partner[2]
    othertrainer.party=$PokemonGlobal.partner[3]
    playerparty=[]
    for i in 0...$Trainer.party.length
      playerparty[i]=$Trainer.party[i]
    end
    for i in 0...othertrainer.party.length
      playerparty[6+i]=othertrainer.party[i]
    end
    fullparty1=true
    playertrainer=[$Trainer,othertrainer]
  else
    playerparty=$Trainer.party
    playertrainer=$Trainer
    fullparty1=false
  end
  combinedParty=[]
  for i in 0...trainer1[2].length
    combinedParty[i]=trainer1[2][i]
  end
  for i in 0...trainer2[2].length
    combinedParty[6+i]=trainer2[2][i]
  end
  scene=pbNewBattleScene
  battle=PokeBattle_Battle.new(scene,
     playerparty,combinedParty,playertrainer,[trainer1[0],trainer2[0]])
  trainerbgm=pbGetTrainerBattleBGM([trainer1[0],trainer2[0]])
  battle.fullparty1=fullparty1
  battle.fullparty2=true
  battle.setBattleMode(size_rule)
  battle.endspeech=endspeech1
  battle.endspeech2=endspeech2
  if fullparty1 && $PokemonGlobal.partner
    battle.items=[trainer1[1],trainer2[1],$PokemonGlobal.partner[4]] rescue battle.items=[trainer1[1],trainer2[1]]
  else 
    battle.items=[trainer1[1],trainer2[1]]
  end
  if Input.press?(Input::CTRL) && $DEBUG
    Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
    Kernel.pbMessage(_INTL("AFTER LOSING..."))
    Kernel.pbMessage(battle.endspeech)
    Kernel.pbMessage(battle.endspeech2) if battle.endspeech2 && battle.endspeech2!=""
    pbClearBattleRules
    return true
  end
  Events.onStartBattle.trigger(nil,nil)
  battle.internalbattle=true
  pbPrepareBattle(battle)
  restorebgm=true
  decision=0
  pbBattleAnimation((battle.doublebattle) ? 3 : 1,trainerbgm) { 
     pbSceneStandby {
        decision=battle.pbStartBattle(canlose)
     }
     # Register trainer encounter for Trainer Index (regardless of win/loss)
     $PokemonGlobal.recordTrainerEncounter(trainer1[0].trainertype,trainer1[0].name,trainerparty1)
     $PokemonGlobal.recordTrainerEncounter(trainer2[0].trainertype,trainer2[0].name,trainerparty2)

     Achievements.incrementProgress("MOVES_USED",$game_variables[530])
     Achievements.incrementProgress("ITEMS_USED",$game_variables[536])
     Achievements.incrementProgress("ITEMS_USED_IN_BATTLE",$game_variables[536])
     Achievements.incrementProgress("MAX_FRIENDSHIP",$game_variables[541])
     for i in $Trainer.party; (i.makeUnmega rescue nil); end
     for i in $Trainer.party
       if isConst?(i.species,PBSpecies,:MIMIKYU)
         i.form=0
       end
       if isConst?(i.species,PBSpecies,:CRAMORANT)
        i.form=0
      end
      if isConst?(i.species,PBSpecies,:PARAS) ||  isConst?(i.species,PBSpecies,:PARASECT)
        if i.form==2
          i.form=1
        end
      end
     end
     if $PokemonGlobal.partner
       pbHealAll
       for i in $PokemonGlobal.partner[3]
         i.heal
         i.makeUnmega rescue nil
         if isConst?(i.species,PBSpecies,:MIMIKYU)
           i.form=0
         end
         if isConst?(i.species,PBSpecies,:CRAMORANT)
          i.form=0
        end
        if isConst?(i.species,PBSpecies,:PARAS) ||  isConst?(i.species,PBSpecies,:PARASECT)
          if i.form==2
            i.form=1
          end
        end
       end
     end
     if decision==2 || decision==5
       if canlose
         for i in $Trainer.party; i.heal; end
         for i in 0...10
           Graphics.update
         end
         PokemonSelection.restore
       else
         $game_system.bgm_unpause
         $game_system.bgs_unpause
         Kernel.pbStartOver
       end
     end
     Events.onEndBattle.trigger(nil,decision)
  }
  Input.update
  pbSet(variable,decision)
  Achievements.incrementProgress("TRAINER_BATTLES",1)
  $game_variables[704]=0
  $game_variables[702]=0
  $game_variables[298]=0
  $game_variables[708]=0
  if decision==1
    pbRegisterTrainerRematch(trainerid1,trainername1,trainerparty1,"double",
                             trainerid2,trainername2,trainerparty2)
  end
  pbClearBattleRules
  return (decision==1)
end

def pbTrainerBattle(trainerid,trainername,endspeech,
                    doublebattle=false,trainerparty=0,canlose=false,variable=nil)
  if $Trainer.pokemonCount==0
    Kernel.pbMessage(_INTL("SKIPPING BATTLE...")) if $DEBUG
    return false
  end
  if !$PokemonTemp.waitingTrainer && pbMapInterpreterRunning?
    thisEvent=pbMapInterpreter.get_character(0)
    triggeredEvents=$game_player.pbTriggeredTrainerEvents([2],false)
    otherEvent=[]
    for i in triggeredEvents
      if i.id!=thisEvent.id && !$game_self_switches[[$game_map.map_id,i.id,"A"]]
        otherEvent.push(i)
      end
    end
    if otherEvent.length==1
      trainer=pbLoadTrainer(trainerid,trainername,trainerparty)
      Events.onTrainerPartyLoad.trigger(nil,trainer)
      if !trainer
        pbMissingTrainer(trainerid,trainername,trainerparty)
        pbClearBattleRules
        return false
      end
      if trainer[2].length<=6 # 3
        $PokemonTemp.waitingTrainer=[trainer,thisEvent.id,endspeech,
                                     trainerid,trainername,trainerparty]
        return false
      end
    end
  end
  trainer=pbLoadTrainer(trainerid,trainername,trainerparty)
  Events.onTrainerPartyLoad.trigger(nil,trainer)
  if !trainer
    pbMissingTrainer(trainerid,trainername,trainerparty)
    pbClearBattleRules
    return false
  end
  foe_trainer_count = $PokemonTemp.waitingTrainer ? 2 : 1
  size_rule = pbResolveTrainerBattleSizeRule(pbBattleRules["size"], foe_trainer_count, doublebattle)
  player_side_size = pbBattleSideSizeFromRule(size_rule, false)
  if $PokemonGlobal.partner && player_side_size > 1
    othertrainer=PokeBattle_Trainer.new(
       $PokemonGlobal.partner[1],$PokemonGlobal.partner[0])
    othertrainer.id=$PokemonGlobal.partner[2]
    othertrainer.party=$PokemonGlobal.partner[3]
    playerparty=[]
    for i in 0...$Trainer.party.length
      playerparty[i]=$Trainer.party[i]
    end
    for i in 0...othertrainer.party.length
      playerparty[6+i]=othertrainer.party[i]
    end
    fullparty1=true
    playertrainer=[$Trainer,othertrainer]
  else
    playerparty=$Trainer.party
    playertrainer=$Trainer
    fullparty1=false
  end
  if $PokemonTemp.waitingTrainer
    combinedParty=[]
    fullparty2=false
    if false
      if $PokemonTemp.waitingTrainer[0][2].length>3
        raise _INTL("Opponent 1's party has more than three Pokémon, which is not allowed")
      end
      if trainer[2].length>3
        raise _INTL("Opponent 2's party has more than three Pokémon, which is not allowed")
      end
    elsif $PokemonTemp.waitingTrainer[0][2].length>3 || trainer[2].length>3
      for i in 0...$PokemonTemp.waitingTrainer[0][2].length
        combinedParty[i]=$PokemonTemp.waitingTrainer[0][2][i]
      end
      for i in 0...trainer[2].length
        combinedParty[6+i]=trainer[2][i]
      end
      fullparty2=true
    else
      for i in 0...$PokemonTemp.waitingTrainer[0][2].length
        combinedParty[i]=$PokemonTemp.waitingTrainer[0][2][i]
      end
      for i in 0...trainer[2].length
        combinedParty[3+i]=trainer[2][i]
      end
      fullparty2=false
    end
    scene=pbNewBattleScene
    battle=PokeBattle_Battle.new(scene,playerparty,combinedParty,playertrainer,
       [$PokemonTemp.waitingTrainer[0][0],trainer[0]])
    trainerbgm=pbGetTrainerBattleBGM(
       [$PokemonTemp.waitingTrainer[0][0],trainer[0]])
    battle.fullparty1=fullparty1
    battle.fullparty2=fullparty2
    battle.setBattleMode(size_rule)
    battle.endspeech=$PokemonTemp.waitingTrainer[2]
    battle.endspeech2=endspeech
    if fullparty1 && $PokemonGlobal.partner
      battle.items=[$PokemonTemp.waitingTrainer[0][1],trainer[1],$PokemonGlobal.partner[4]] rescue [$PokemonTemp.waitingTrainer[0][1],trainer[1]]
    else
      battle.items=[$PokemonTemp.waitingTrainer[0][1],trainer[1]]
    end
  else
    scene=pbNewBattleScene
    battle=PokeBattle_Battle.new(scene,playerparty,trainer[2],playertrainer,trainer[0])
    battle.fullparty1=fullparty1
    battle.setBattleMode(size_rule)
    battle.endspeech=endspeech
    if $PokemonGlobal.partner
      battle.items=trainer[1]
    else 
      battle.items=trainer[1]
    end
    trainerbgm=pbGetTrainerBattleBGM(trainer[0])
  end
  if Input.press?(Input::CTRL) && $DEBUG
    Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
    Kernel.pbMessage(_INTL("AFTER LOSING..."))
    Kernel.pbMessage(battle.endspeech)
    Kernel.pbMessage(battle.endspeech2) if battle.endspeech2
    if $PokemonTemp.waitingTrainer
      pbMapInterpreter.pbSetSelfSwitch($PokemonTemp.waitingTrainer[1],"A",true)
      $PokemonTemp.waitingTrainer=nil
    end
    pbClearBattleRules
    return true
  end
  Events.onStartBattle.trigger(nil,nil)
  battle.internalbattle=true
  pbPrepareBattle(battle)
  restorebgm=true
  decision=0
  Audio.me_stop
  pbBattleAnimation((battle.doublebattle) ? 3 : 1,trainerbgm,trainer[0].trainertype,trainer[0].name) { 
    pbSceneStandby {
      decision=battle.pbStartBattle(canlose)
    }
    # Register trainer encounter for Trainer Index (regardless of win/loss)
    if $PokemonTemp.waitingTrainer
      waiting_trainer = $PokemonTemp.waitingTrainer[0][0]
      $PokemonGlobal.recordTrainerEncounter(waiting_trainer.trainertype,waiting_trainer.name,
                                            $PokemonTemp.waitingTrainer[5])
    end
    $PokemonGlobal.recordTrainerEncounter(trainer[0].trainertype,trainer[0].name,trainerparty)

    Achievements.incrementProgress("MOVES_USED",$game_variables[530])
    Achievements.incrementProgress("ITEMS_USED",$game_variables[536])
    Achievements.incrementProgress("ITEMS_USED_IN_BATTLE",$game_variables[536])
    Achievements.incrementProgress("MAX_FRIENDSHIP",$game_variables[541])
    for i in $Trainer.party; (i.makeUnmega rescue nil); end
    for i in $Trainer.party
      if isConst?(i.species,PBSpecies,:MIMIKYU)
        i.form=0
      end
      if isConst?(i.species,PBSpecies,:PARAS) ||  isConst?(i.species,PBSpecies,:PARASECT)
        if i.form==2
          i.form=1
        end
      end
    end
    # Refresh PP after battle
    for i in $Trainer.party; i.healPP; end
    if $PokemonGlobal.partner
      pbHealAll
      for i in $PokemonGlobal.partner[3]
        i.heal
        i.makeUnmega rescue nil
        if isConst?(i.species,PBSpecies,:MIMIKYU)
          i.form=0
        end
        if isConst?(i.species,PBSpecies,:CRAMORANT)
          i.form=0
        end
        if isConst?(i.species,PBSpecies,:PARAS) ||  isConst?(i.species,PBSpecies,:PARASECT)
          if i.form==2
            i.form=1
          end
        end
      end
    end
    if decision==2 || decision==5
      if canlose
        for i in $Trainer.party; i.heal; end
        for i in 0...10
          Graphics.update
        end
        PokemonSelection.restore
      else
        $game_system.bgm_unpause if $game_switches[2100] != true #don't stop the music switch
        $game_system.bgs_unpause if $game_switches[2100] != true #don't stop the music switch
        #EXTREMELY CLUNKY PICTURE FIX
        $game_screen.pictures[1].erase
        $game_screen.pictures[2].erase
        #DOUBLY CLUNKY THROUGH FIX
        $game_player.through = false
        Kernel.pbStartOver
      end
    else
      Events.onEndBattle.trigger(nil,decision)
      if decision==1
        if $PokemonTemp.waitingTrainer
          pbMapInterpreter.pbSetSelfSwitch($PokemonTemp.waitingTrainer[1],"A",true)
        end
      end
    end
  }
  $game_switches[:No_Catch]=false
  $game_variables[704]=0
  $game_variables[702]=0
  $game_variables[298]=0
  $game_variables[708]=0
  $game_switches[1121]=false
  Input.update
  pbSet(variable,decision)
  if decision==1
    if $PokemonTemp.waitingTrainer
      pbRegisterTrainerRematch($PokemonTemp.waitingTrainer[3],
                               $PokemonTemp.waitingTrainer[4],
                               $PokemonTemp.waitingTrainer[5],
                               "double",
                               trainerid,trainername,trainerparty)
    else
      pbRegisterTrainerRematch(trainerid,trainername,trainerparty,"single")
    end
  end
  $PokemonTemp.waitingTrainer=nil
  Achievements.incrementProgress("TRAINER_BATTLES",1)
  pbClearBattleRules
  return (decision==1)
end

#pk code
class PokemonTrainerIndexScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbScene
    @scene.pbEndScene
  end
end

#pk code
class Scene_TrainerIndex
  def pbStartScene
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999

    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/navbg")

    @sprites["header"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Trainer Index"), 94, 0, Graphics.width - 94, 64, @viewport
    )
    @sprites["header"].baseColor = Color.new(248, 248, 248)
    @sprites["header"].shadowColor = Color.new(0, 0, 0)
    @sprites["header"].windowskin = nil

    @choices = pbGetEncounteredTrainers
    @sprites["command_window"] = Window_CommandPokemonWhiteArrow.new(@choices, 324)
    @sprites["command_window"].viewport = @viewport
    @sprites["command_window"].windowskin = nil
    @sprites["command_window"].x = 94
    @sprites["command_window"].y = 64
    @sprites["command_window"].height = Graphics.height - 64

    pbFadeInAndShow(@sprites)
  end

  def pbScene
    loop do
      Graphics.update
      Input.update
      pbUpdateSpriteHash(@sprites)

      if Input.trigger?(Input::B)
        pbPlayCancelSE()
        break
      elsif Input.trigger?(Input::C)
        index = @sprites["command_window"].index
        if index == @choices.length - 1  # "Back" option
          pbPlayCancelSE()
          break
        elsif @choices[index] != "???"
          pbPlayDecisionSE()
          trainer_key = pbGetTrainerKeyFromIndex(index)
          pbShowTrainerDetails(trainer_key)
        else
          pbPlayBuzzerSE()
        end
      end
    end
  end

  def pbShowTrainerDetails(trainer_key)
    scene = Scene_TrainerIndex_Info.new(trainer_key)
    scene.main
  end

  def pbGetEncounteredTrainers
    encountered_trainers = $PokemonGlobal.encounteredTrainers

    $trainerdata = load_data("Data/trainers.dat") if !$trainerdata

    trainers = []
    @trainer_key_map = []

    $trainerdata.each do |trainer|
      trainerid = trainer[0]
      trainername = trainer[1]
      partyid = trainer[4]

      key = [trainerid, trainername, partyid]
      @trainer_key_map.push(key)

      trainertype_name = PBTrainers.getName(trainerid) rescue "???"

      if encountered_trainers.include?(key)
        trainers.push("#{trainertype_name} #{trainername}")
      else
        trainers.push("???")
      end
    end

    trainers.push(_INTL("Back"))
    return trainers
  end

  def pbGetTrainerKeyFromIndex(index)
    return @trainer_key_map[index]
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#pk code
class Scene_TrainerIndex_Info
  def initialize(trainer_key)
    @trainer_key = trainer_key
    @trainerid = trainer_key[0]
    @trainername = trainer_key[1]
    @partyid = trainer_key[2]

    @trainer_data = AzureTrainerDataCache.record(
      @trainerid,@trainername,@partyid
    )
  end

  def main
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999

    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/navbg")

    info_text = pbGenerateTrainerInfoText

    @sprites["info"] = Window_AdvancedTextPokemon.newWithSize(
      info_text, 10, 10, Graphics.width - 20, Graphics.height - 20, @viewport
    )
    @sprites["info"].baseColor = Color.new(248, 248, 248)
    @sprites["info"].shadowColor = Color.new(80, 80, 80)

    @scroll_y = 0
    @max_scroll = [@sprites["info"].contents.height - @sprites["info"].height + 32, 0].max

    pbFadeInAndShow(@sprites)

    loop do
      Graphics.update
      Input.update
      pbUpdateSpriteHash(@sprites)

      if Input.press?(Input::UP) && @scroll_y > 0
        @scroll_y -= 4
        @sprites["info"].oy = @scroll_y
      elsif Input.press?(Input::DOWN) && @scroll_y < @max_scroll
        @scroll_y += 4
        @sprites["info"].oy = @scroll_y
      end

      if Input.trigger?(Input::B) || Input.trigger?(Input::C)
        pbPlayCancelSE()
        break
      end
    end

    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbGenerateTrainerInfoText
    return "No data available." if !@trainer_data

    text = ""

    trainertype_name = PBTrainers.getName(@trainerid) rescue "Unknown"
    text << "<ac><b>#{trainertype_name} #{@trainername}</b></ac>\n"
    if @partyid > 0
      text << "<ac>(Team #{@partyid})</ac>\n"
    end
    text << "\n"

    items = @trainer_data[2]
    if items && items.length > 0
      text << "<c2=5080F0F0>ITEMS:</c2>\n"
      items.each do |item|
        item_name = PBItems.getName(item) rescue item.to_s
        text << "• #{item_name}\n"
      end
      text << "\n"
    end

    party = @trainer_data[3]
    if party && party.length > 0
      text << "<c2=50F0A050>═══ POKEMON TEAM ═══</c2>\n"
      text << "Team Size: #{party.length}\n\n"

      party.each_with_index do |poke, i|
        text << "<c2=50D0D050>Pokemon #{i + 1}:</c2>\n"
        text << pbFormatPokemonInfo(poke)
        text << "\n"
      end
    end

    text << "\n<ac>Press B to return</ac>"

    return text
  end

  def pbFormatPokemonInfo(poke)
    text = ""

    species = poke[TSPECIES]
    species_name = PBSpecies.getName(species) rescue species.to_s
    text << "Species: #{species_name}\n"
    text << "Level: #{poke[TPLEVEL]}\n" if poke[TPLEVEL]

    if poke[TPFORM] && poke[TPFORM] > 0
      text << "Form: #{poke[TPFORM]}\n"
    end

    if poke[TPABILITY]
      text << _INTL("Ability slot: {1}",poke[TPABILITY]) << "\n"
    end

    if poke[TPITEM] && poke[TPITEM] > 0
      item_name = PBItems.getName(poke[TPITEM]) rescue poke[TPITEM].to_s
      text << "Item: #{item_name}\n"
    end

    if poke[TPNATURE]
      nature = poke[TPNATURE]
      if nature.is_a?(Symbol)
        nature_name = nature.to_s.capitalize
      elsif nature.is_a?(Integer) && nature > 0
        nature_name = PBNatures.getName(nature) rescue nature.to_s
      else
        nature_name = nil
      end
      text << "Nature: #{nature_name}\n" if nature_name
    end

    if poke[TPGENDER]
      gender = case poke[TPGENDER]
      when 0, "M", "m" then "Male"
      when 1, "F", "f" then "Female"
      when 2 then "Genderless"
      else poke[TPGENDER].to_s
      end
      text << "Gender: #{gender}\n"
    end

    if poke[TPSHINY] && (poke[TPSHINY] == true || poke[TPSHINY] == "shiny")
      text << "Shiny: Yes\n"
    end

    if poke[TPNAME] && poke[TPNAME].to_s.length > 0
      text << "Nickname: #{poke[TPNAME]}\n"
    end

    if poke[TPIV]
      text << "IVs: #{poke[TPIV]}\n"
    end

    #pk code
    ev_values = [poke[TPHPEV],poke[TPATKEV],poke[TPDEFEV],poke[TPSPAEV],poke[TPSPDEV],poke[TPSPEEV]]
    ev_names = ["HP", "Atk", "Def", "SpA", "SpD", "Spe"]
    ev_display = ev_values.each_with_index.filter_map { |val, i| "#{ev_names[i]}:#{val}" if val.to_i > 0 }.join(", ")
    text << "EVs: #{ev_display}\n" if ev_display.length > 0

    if poke[TPHAPPINESS] && poke[TPHAPPINESS] > 0
      text << "Happiness: #{poke[TPHAPPINESS]}\n"
    end

    moves = []
    moves << poke[TPMOVE1] if poke[TPMOVE1] && poke[TPMOVE1] > 0
    moves << poke[TPMOVE2] if poke[TPMOVE2] && poke[TPMOVE2] > 0
    moves << poke[TPMOVE3] if poke[TPMOVE3] && poke[TPMOVE3] > 0
    moves << poke[TPMOVE4] if poke[TPMOVE4] && poke[TPMOVE4] > 0

    if moves.length > 0
      text << "Moves:\n"
      moves.each do |move|
        move_name = PBMoves.getName(move) rescue move.to_s
        text << "  • #{move_name}\n"
      end
    end

    if poke[TPBOSS]
      text << "Boss Pokemon: #{poke[TPBOSS]}\n"
    end

    return text
  end
end

#pk code
def pbTesterTeamMenu
  unless defined?(PBTrainers) && PBTrainers.const_defined?(:TESTER)
    Kernel.pbMessage(_INTL("PBTrainers::TESTER isn't defined."))
    return false
  end

  trainers_data = nil
  begin
    trainers_data = load_data("Data/trainers.dat")
  rescue
    Kernel.pbMessage(_INTL("Couldn't load Data/trainers.dat. Compile Trainers first."))
    return false
  end

  tester_type = PBTrainers::TESTER

  candidate_names = pbGetTrainerNamesForType_Simple(trainers_data, tester_type)

  names = []
  candidate_names.each do |nm|
    next if !nm || nm.to_s.strip.empty?
    next if nm.to_s == "???"
    if pbTrainerEntryExists?(tester_type, nm, 0)
      names << nm.to_s
    end
  end
  names.uniq!
  names.sort_by! { |n| n.downcase }

  if names.empty?
    Kernel.pbMessage(_INTL("No TESTER teams found.\nMake sure Trainers are compiled and the PBS has TESTER entries."))
    return false
  end

  cmd = names + [_INTL("Cancel")]
  chosen = Kernel.pbShowCommands(nil, cmd, -1)
  return false if chosen.nil? || chosen < 0 || chosen >= names.length

  team_name = names[chosen]
  pbApplyTrainerTeamToPlayer(tester_type, team_name, 0)
  return true
end

def pbGetTrainerNamesForType_Simple(trainers_data, trainer_type_id)
  out = []

  begin
    if trainers_data.is_a?(Array) && trainers_data[trainer_type_id].is_a?(Hash)
      out.concat(trainers_data[trainer_type_id].keys)
    end
  rescue
  end

  begin
    if trainers_data.is_a?(Hash) && trainers_data[trainer_type_id].is_a?(Hash)
      out.concat(trainers_data[trainer_type_id].keys)
    end
  rescue
  end

  begin
    if trainers_data.is_a?(Hash)
      trainers_data.keys.each do |k|
        next unless k.is_a?(Array)
        next unless k.length >= 2
        next unless k[0] == trainer_type_id
        out << k[1]
      end
    end
  rescue
  end

  begin
    if trainers_data.is_a?(Array)
      trainers_data.each do |entry|
        next if entry.nil?
        if entry.respond_to?(:trainertype) && entry.respond_to?(:name)
          out << entry.name if entry.trainertype == trainer_type_id
        elsif entry.is_a?(Array) && entry.length >= 2
          out << entry[1] if entry[0] == trainer_type_id
        end
      end
    end
  rescue
  end

  out.compact!
  out.map! { |x| x.to_s }
  out.uniq!
  return out
end

def pbTrainerEntryExists?(trainer_type_id, trainer_name, version=0)
  return false if trainer_name.nil? || trainer_name.to_s.strip.empty?
  begin
    loaded = pbLoadTrainer(trainer_type_id, trainer_name, version)
    return false if loaded.nil?
    if loaded.is_a?(Array)
      party = nil
      party = loaded[2] if loaded.length >= 3
      party = loaded[1] if party.nil? && loaded[1].is_a?(Array)
      return party.is_a?(Array) && party.length > 0
    end
    return true
  rescue
    return false
  end
end

def pbApplyTrainerTeamToPlayer(trainer_type_id, trainer_name, version=0)
  loaded = pbLoadTrainer(trainer_type_id, trainer_name, version)
  party = nil

  if loaded.is_a?(Array)
    party = loaded[2] if loaded.length >= 3
    party = loaded[1] if party.nil? && loaded[1].is_a?(Array)
  end

  if !party.is_a?(Array) || party.empty?
    Kernel.pbMessage(_INTL("Failed to load party for {1}.", trainer_name))
    return false
  end

  new_party = []
  party.each do |pkmn|
    break if new_party.length >= 6
    next if pkmn.nil?

    begin
      mon = pkmn.clone
    rescue
      mon = pkmn
    end

    begin
      mon.trainerID = $Trainer.id if mon.respond_to?(:trainerID=)
      mon.ot = $Trainer.name if mon.respond_to?(:ot=)
    rescue
    end
    begin
      mon.heal if mon.respond_to?(:heal)
    rescue
    end

    new_party << mon
  end

  $Trainer.party.clear
  new_party.each { |m| $Trainer.party << m }

  Kernel.pbMessage(_INTL("Loaded TESTER team: {1}", trainer_name))
  return true
end
