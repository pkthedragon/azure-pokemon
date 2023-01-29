########## Rental Code - START ##########

# Rental Pokemon for Single (3 Pokemon)
def pbRentalSingle
  $game_variables[543] = $Trainer.party
  $Trainer.party = []
  while $Trainer.party.length<3
    species = pbChooseSpeciesOrdered(1)
    level = 100
    pbAddPokemonSilent(species,level)
  end
end

# Rental Pokemon for Double (4 Pokemon)
def pbRentalDouble
  $game_variables[543] = $Trainer.party
  $Trainer.party = []
  while $Trainer.party.length<4
    species = pbChooseSpeciesOrdered(1)
    level = 100
    pbAddPokemonSilent(species,level)
  end
end

# Returns Party that was stored in variable
def pbRentReturn
  $Trainer.party = $game_variables[543]
  if $game_variables[12] != 0
    $Trainer.name = $game_variables[12]
  end
  $game_switches[1075]=false
#  Kernel.pbMessage(_INTL("Gave back rental pokemon."))
end

# Rental Pokemon for Battle Factory (6 Pokemon)
def pbRentalBF
  $game_variables[543] = $Trainer.party
  $Trainer.party = []
  while $Trainer.party.length<6
    species = rand(PBSpecies.maxValue)+1
    level = 100
    pbAddPokemonSilent(species,level)
  end
end

def pbRentalParty(mons, levels, newname=0)
  if mons.length != levels.length
    print "Please set mon and levels arrays to same length"
    return
  end
  $game_variables[543] = $Trainer.party
  if newname!=0
    $game_variables[12] = $Trainer.name
    $Trainer.name = newname
  else
    $game_variables[12] = 0
  end
  $Trainer.party = []
  mons.zip(levels).each do |species,level|
    pbAddRentalPokemonSilent(species,level)
  end
  $game_switches[1075]=true
end

def pbRentalMoves(index, moves=[])
  mon = $Trainer.party[index]
  mon.pbDeleteAllMoves
  if moves.length == 0
    mon.resetMoves
  else
    for move in moves
      mon.pbLearnMove(move)
    end
  end
end

def pbRentalIVs(index, ivs=[])
  mon = $Trainer.party[index]
  if ivs.length==6
    mon.iv = ivs
  end
end

def pbRentalItems(num, items=[])
  return if num == 0 || items.length == 0
  for i in 0...num
    if items[i] != -1
      mon = $Trainer.party[i]
      mon.setItem(items[i])
    end
  end
end

def pbRentalAbilities(num, abilities=[])
  return if num == 0 || abilities.length == 0
  for i in 0...num
    if abilities[i] != -1
      mon = $Trainer.party[i]
      index = pbGetAbilityIndex(mon, abilities[i])
      if index > -1
        mon.setAbility(index)
      end
    end
  end
end

def pbGetAbilityIndex(mon, ability)
  aname = getConst(PBAbilities,ability)
  name = PBAbilities.getName(aname)
  abils = mon.getAbilityList
  for i in 0...abils[0].length
    abil = PBAbilities.getName(abils[0][i])
    if name == abil
      return i
    end    
  end
  return -1
end
########## Rental Code - END ##########

# Level up box mons up to levelup value
def LevelUpNowRage(levelup)
  for i in -1...$PokemonStorage.maxBoxes
    for j in 0...$PokemonStorage.maxPokemon(i)
      if $PokemonStorage[i][j]
        $PokemonStorage[i][j].level=levelup
      end
    end
  end
end

# add a pokemon with tons of custom data
def pbAddSilent(pokemon,level=nil,seeform=true,ivs=[],ability=-1,moves=[],female=false,obtainText="",name="",ot="",shiny=-1,evs=[],nature=-1,holditem=-1,form=-1,happiness=-1)
  return false if !pokemon || !$Trainer || $Trainer.party.length>=6
  if pokemon.is_a?(String) || pokemon.is_a?(Symbol)
    pokemon=getID(PBSpecies,pokemon)
  end
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon=PokeBattle_Pokemon.new(pokemon,level,$Trainer)
  end
  if ivs.length==6
    pokemon.iv = ivs
  end
  if ability!=-1
    pokemon.setAbility(ability)
  end
  if moves.length > 0
    pokemon.pbDeleteAllMoves
    for move in moves
      pokemon.pbLearnMove(move)
    end
  end
  if female
    pokemon.makeFemale
  end
  if obtainText!=""
    pokemon.obtainText = _INTL(obtainText)
  end
  if name!=""
    pokemon.name = name
  end
  if ot!=""
    pokemon.ot = ot
  end
  if shiny<0
    pokemon.makeNotShiny
  elsif shiny==1
    pokemon.makeShiny
  end
  if evs.length==6
    pokemon.ev = evs
  end
  if nature!=-1
    pokemon.setNature(nature)
  end
  if holditem!=-1
    pokemon.setItem(holditem)
  end
  if form!=-1
    pokemon.form = form
  end
  if happiness!=-1
    pokemon.happiness = happiness
  end
  pokemon.calcStats
  
  $Trainer.seen[pokemon.species]=true
  $Trainer.owned[pokemon.species]=true
  pbSeenForm(pokemon) if seeform
  pokemon.pbRecordFirstMoves
  $Trainer.party[$Trainer.party.length]=pokemon
  return true
end

Events.onStepTaken+=proc{
  if $game_variables[595] > 0
    $game_variables[595]-=1
  end
}

def pbGameVariable?(num)
  return $game_variables[num]
end

########## Change time - START ##########
def turnToDay
  $game_switches[1499] = true
  $game_switches[1496] = true
  $game_switches[1497] = false
  $game_switches[1498] = false
end

def turnToEvening
  $game_switches[1499] = true
  $game_switches[1496] = false
  $game_switches[1497] = true
  $game_switches[1498] = false
end

def turnToNight
  $game_switches[1499] = true
  $game_switches[1496] = false
  $game_switches[1497] = false
  $game_switches[1498] = true
end

def turnToNormal
  $game_switches[1499] = false
  $game_switches[1496] = false
  $game_switches[1497] = false
  $game_switches[1498] = false
end
########## Change time - END ##########


########## Record Utils - START ##########
def readFile(filename)
  fin = File.open(filename)
  data = fin.read
  fin.close
  return data
end

# maybe I'm stupid, maybe this shit just doesn't have ord()
# or at least something to convert char to int/ascii equivalent...sort of
def char_to_int(char)
  letter_to_index = {"a"=>0,"b"=> 1,"c"=> 2,"d"=> 3,"e"=> 4,"f"=> 5,"g"=> 6,
                     "h"=> 7,"i"=> 8,"j"=> 9, "k"=>10, "l"=>11, "m"=>12, "n"=>13, 
                     "o"=>14, "p"=>15, "q"=>16, "r"=>17, "s"=>18, "t"=>19, 
                     "u"=>20, "v"=>21, "w"=>22, "x"=>23, "y"=>24, "z"=>25}
  if char == char.capitalize
    char.downcase!
  end
  return letter_to_index[char]
end

def int_to_char(int)
  index_to_letter = {0=>"a", 1=>"b", 2=>"c", 3=>"d", 4=>"e", 5=>"f", 6=>"g", 
                     7=>"h", 8=>"i", 9=>"j", 10=>"k", 11=>"l", 12=>"m", 13=>"n", 
                     14=>"o", 15=>"p", 16=>"q", 17=>"r", 18=>"s", 19=>"t", 
                     20=>"u", 21=>"v", 22=>"w", 23=>"x", 24=>"y", 25=>"z"}
  return index_to_letter[int]
end

def int_to_charC(int)
  index_to_letter = {0=>"A", 1=>"B", 2=>"C", 3=>"D", 4=>"E", 5=>"F", 6=>"G", 
                     7=>"H", 8=>"I", 9=>"J", 10=>"K", 11=>"L", 12=>"M", 13=>"N", 
                     14=>"O", 15=>"P", 16=>"Q", 17=>"R", 18=>"S", 19=>"T", 
                     20=>"U", 21=>"V", 22=>"W", 23=>"X", 24=>"Y", 25=>"Z"}
  return index_to_letter[int]
end

def decipherText(cipher_text, key)
  a_off = 65
  key = key.split('')

  plain_text = cipher_text.split('').collect do |cipher_letter|
    if ('A'..'Z').include?(cipher_letter) || ('a'..'z').include?(cipher_letter)
      key_offset = char_to_int(key.first)
      if ('A'..'Z').include?(cipher_letter)
        letter = ( (char_to_int(cipher_letter) - (key_offset + a_off)) + 26) % 26
        letter = int_to_charC(letter)
      else
        letter = ( (char_to_int(cipher_letter) - (key_offset + 32 + a_off)) + 26) % 26
        letter = int_to_char(letter)
      end      
    else
      letter = cipher_letter
    end
    key << key.shift
    letter
  end

  return plain_text.join
end

def loadText(data, type)
  lines = data.split("\n")

  num = lines.length
  start = true
  i = 0

  if type == "chapters"
    chap = 0
    while i < num
      if lines[i][0..6] == "Chapter"
        value = lines[i][7..9]
        chap = value.strip.to_i
        if chap > $game_variables[651]
          break
        end
        $chap_names.push(lines[i])
      else
        if chap < $game_variables[651]
          j = 1
          while lines[i+j][0..6] != "Chapter"
            j += 1
          end
          i += (j-1)
          $chap_desc.push(lines[i])
        else
          i += $game_variables[652]
          $chap_desc.push(lines[i])
          break
        end
      end
      i += 1
    end
  elsif type == "characters"
    while i < num
      if i % 2 == 0
        $char_names.push(lines[i])
      else
        $char_desc.push(lines[i])
      end
      i += 1
    end
  end
end
########## Record Utils - END ##########

# Exp to level limit (get full exp if doesn't touch level limit)
def LevelLimitExpGain(pokemon, exp)
 # levelLimits = [15, 20, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 85, 90]
 # leadersDefeated = $Trainer.numbadges
    
  if pokemon.level>=$game_variables[700]
    return -1
  elsif pokemon.level<$game_variables[700]
    totalExpNeeded = PBExperience.pbGetStartExperience($game_variables[700], pokemon.growthrate)
    currExpNeeded = totalExpNeeded - pokemon.exp
    if exp > currExpNeeded
      return currExpNeeded
    end
  end
  return exp
end
#Checks for Different forms
def pbFormSeen?(species,form)
  return $Trainer.formseen[species][0][form] || $Trainer.formseen[species][1][form]
end
# Cause why not
def fuckyou
  savedir = RTP.getSaveFileName("Game.rxdata")
  savefolder = savedir[0..savedir.size-12]
  files = Dir.entries(savefolder)

  for file in files
    if file[file.size-7..file.size-1] == ".rxdata"
      savefile = savefolder+file
      begin; File.delete(savefile); rescue; end
    end
  end
end


####### Cass shit #########
def inPast?
  mapid = $game_map.map_id
  while mapid != 0
    mapid = $mapinfos[mapid].parent_id
    return true if mapid == 235
  end
  return false
end
  
def eventfindreplace
  for n in 1..999
    savemap = false
    map_name = sprintf("Data/Map%03d.rxdata", n)
    next if !(File.open(map_name,"rb") { true } rescue false)
    map = load_data(map_name)
    for i in map.events.keys.sort
      event = map.events[i]
      for j in 0...event.pages.length
        page = event.pages[j]
        list = page.list
        index = 0 
        while index < list.length - 1
          if list[index].code == 401
            text = list[index].parameters[0]
            if text.include? "©"
              puts "found"
              savemap = true
              map.events[i].pages[j].list[index].parameters[0].gsub! '©', '™'
            end
          end
          index += 1
        end
      end
    end
    if savemap
      save_data(map,sprintf("Data/Map%03d.rxdata", n))
    end
  end
end

def eventfilereplace
  original = edited = []
  currentmap = 0
  original = File.readlines('copy-intl.txt')
  edited = File.readlines('intl.txt')
  for line in original
    line.strip!
  end
  for line in edited
    line.strip!
  end
  for line in 0...edited.length
    next if original[line] == edited[line]
    puts original[line]
    map = 0
    savemap = false
    n = 0
    for n in currentmap..608
      map_name = sprintf("Data/Map%03d.rxdata", n)
      next if !(File.open(map_name,"rb") { true } rescue false)
      map = load_data(map_name)
      for i in map.events.keys.sort
        event = map.events[i]
        for j in 0...event.pages.length
          page = event.pages[j]
          list = page.list
          index = 0 
          while index < list.length - 1
            if list[index].code == 101
              text = list[index].parameters[0]
              begin
                text += " " + list[index+1].parameters[0] if list[index+1] && list[index+1].code == 401
                text += " " + list[index+2].parameters[0] if list[index+2] && list[index+2].code == 401
              rescue
              end
              if text == original[line]
                puts "map found"
                savemap = true
                replacetext = edited[line].scan(/.{0,39}[a-z.!?,;](?:\s|$)/mi)
                puts replacetext.inspect
                for text in replacetext
                  text.lstrip!
                end
                indent = 0
                map.events[i].pages[j].list[index].parameters[0] = replacetext[0]
                indent = map.events[i].pages[j].list[index].indent
                if replacetext[1]
                  if map.events[i].pages[j].list[index+1].code == 401
                    map.events[i].pages[j].list[index+1].parameters[0] = replacetext[1]
                  else
                    newcommand = RPG::EventCommand.new(401,indent,[text])
                    map.events[i].pages[j].list.insert(index+1,newcommand)
                    list = map.events[i].pages[j].list
                  end
                  if replacetext[2]
                    if map.events[i].pages[j].list[index+2].code == 401
                      map.events[i].pages[j].list[index+2].parameters[0] = replacetext[2]
                    else
                      newcommand = RPG::EventCommand.new(401,indent,[text])
                      map.events[i].pages[j].list.insert(index+2,newcommand)
                      list = map.events[i].pages[j].list
                    end
                  end
                end
                index +=1
              end
            end
            index += 1
          end
        end
      end
      if savemap
        save_data(map,sprintf("Data/Map%03d.rxdata", n))
        puts "saved map " + n.to_s
        currentmap = n
        break
      end
      n += 1
    end
  end
end

def eventindent
  #screams
  for n in 1..999
    savemap = false
    map_name = sprintf("Data/Map%03d.rxdata", n)
    next if !(File.open(map_name,"rb") { true } rescue false)
    map = load_data(map_name)
    for i in map.events.keys.sort
      event = map.events[i]
      for j in 0...event.pages.length
        page = event.pages[j]
        list = page.list
        index = 0 
        code101found = false
        currentindent = 0
        while index < list.length - 1
          if list[index].code == 101
            code101found = true
          end
          if list[index].code == 401
            if list[index].indent != currentindent
              map.events[i].pages[j].list[index].indent = currentindent
              if code101found
                puts sprintf("%03d ; %03d",n,i)
                puts sprintf("%03d ; %03d",event.x,event.y)
                puts $mapinfos[n].name
                puts "amending code"
                map.events[i].pages[j].list[index].code = 101
                code101found = false
              end
              puts list[index].inspect
              savemap = true
            end
          else
            currentindent = list[index].indent
          end
          index += 1
        end
      end
    end
    save_data(map,sprintf("Data/Map%03d.rxdata", n)) if savemap
  end
end

def eventcolon
  for n in 1..999
    savemap = false
    map_name = sprintf("Data/Map%03d.rxdata", n)
    next if !(File.open(map_name,"rb") { true } rescue false)
    map = load_data(map_name)
    for i in map.events.keys.sort
      event = map.events[i]
      for j in 0...event.pages.length
        page = event.pages[j]
        list = page.list
        index = 0 
        while index < list.length - 1
          if list[index].code == 401
            text = list[index].parameters[0]
            if text.include? ":"
              puts sprintf("%03d ; %03d",n,i)
              puts sprintf("%03d ; %03d",event.x,event.y)
              puts $mapinfos[n].name
              puts "Target text:"
              puts list[index].parameters[0]
              puts "In lines:"
              puts list[index-1].parameters[0] rescue nil
              puts list[index].parameters[0]
              puts list[index+1].parameters[0]
              if Kernel.pbConfirmMessageSerious("Do you want to amend the code?")
                savemap = true
                map.events[i].pages[j].list[index].code = 101
              end
            end
          end
          index += 1
        end
      end
    end
    if savemap
      save_data(map,sprintf("Data/Map%03d.rxdata", n))
    end
  end
end

#Variable 726 holds the trainer party
#Variable 690 holds secondary parties
def characterSwitch(character)
  #Backup the player trainer's information
  $game_variables[726] = []
  $game_variables[12] = $Trainer.name
  $game_variables[726][0] = $Trainer.party
  $game_variables[726][1] = $Trainer.money
  $game_variables[726][2] = $Trainer.badges
  $game_variables[726][3] = $Trainer.id
  $game_variables[726][4] = $Trainer.outfit
  $game_variables[726][5] = $PokemonBag
  $game_variables[726][6] = false #this is just to confirm that the bag was swapped
  
  if character == "" #Don't change information, just switch teams
    trainerinfo = pbLoadTrainerDifficult(trainertype,trainername,partyid)
    $Trainer.party = trainerinfo[2]
    return #skip the rest of the changes
  end

  #Conditions that apply to all changes
  $game_switches[1235] = true #NOTPLAYER switch
  if $game_switches[1408]==false
    $PokemonBag = PokemonBag.new
  end
  $game_variables[726][6] = true #indicates that the bag was replaced
  
  #Load in the new trainer's information
  if character.is_a?(String)
    case character
    when "Koda"
      pbChangePlayer(10)
      $Trainer.name = "Koda"
      $Trainer.outfit = 0
      $Trainer.party = []
      $Trainer.money = 2500
      $Trainer.id = 32623
      trainerinfo = pbLoadTrainerDifficult(PBTrainers::KODA,"Koda",0)
      $Trainer.party = trainerinfo[2]
      $PokemonBag.pbStoreItem(PBItems::MEGARING,1)
    when "Myron"
      pbChangePlayer(9)
      $Trainer.name = "Myron"
      $Trainer.outfit = 0
      $Trainer.party = []
      $Trainer.money = 900000
      $Trainer.id = 01457
      trainerinfo = pbLoadTrainerDifficult(PBTrainers::MYRON,"Myron",0)
      $Trainer.party = trainerinfo[2]
      $PokemonBag.pbStoreItem(PBItems::MEGARING,1)
    end
  end
  if $game_switches[1408]==false
    $PokemonBag.pbStoreItem(PBItems::FULLHEAL,4)
    $PokemonBag.pbStoreItem(PBItems::MAXPOTION,6)
    $PokemonBag.pbStoreItem(PBItems::REVIVE,4)
    $PokemonBag.pbStoreItem(PBItems::MAXREVIVE,1)
  end
=begin
with the changes to the nightmare academy, i'm not sure this is necessary
  badgearray = []
  maxlevel = 0
  for mon in $Trainer.party
    maxlevel = mon.level if maxlevel < mon.level
  end
  badgelevels = [15, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 85, 90]
  for i in 0...badgelevels.length
    badgearray[i]= maxlevel > badgelevels[i] ? true : nil
  end
  $Trainer.badges = badgearray
=end
end

def teamSwap(trainertype,trainername,partyid=nil)
  $game_variables[726][0] = $Trainer.party
  trainerinfo = pbLoadTrainerDifficult(trainertype,trainername,partyid)
  $Trainer.party = trainerinfo[2]
end

def teamRestore
  $Trainer.party = $game_variables[726][0]
end

def pyramidSetup
  $game_variables[73] = []
  trainerinfo = pbLoadTrainerDifficult(PBTrainers::STUDENT_3,"Aelita")
  $game_variables[73][0] = trainerinfo[2]
  trainerinfo = pbLoadTrainerDifficult(PBTrainers::OUTCAST,"Ren",2)
  $game_variables[73][1] = trainerinfo[2]
end

def pyramidSwitch(character)
  #if i was better at coding, i wouldn't need this function.
  #save the current party
  case $Trainer.name  
  when "Aelita"
    $game_variables[73][0] = $Trainer.party
  when "Ren"
    $game_variables[73][1] = $Trainer.party
  else
    $game_variables[73][2] = $Trainer.party
  end
  #swap characters
  case character
  when "Player"
    characterRestore
    $Trainer.party = $game_variables[73][2]
    $game_switches[1235] = false
  when "Aelita"
    pbChangePlayer(15)
    $Trainer.name = "Aelita"
    $Trainer.outfit = 0
    $Trainer.party = []
    $Trainer.money = 0
    $Trainer.party = $game_variables[73][0]
    $game_switches[1235] = true #non-player
  when "Ren"
    pbChangePlayer(13)
    $Trainer.name = "Ren"
    $Trainer.outfit = 0
    $Trainer.party = []
    $Trainer.money = 0
    $Trainer.party = $game_variables[73][1]
    $game_switches[1235] = true #non-player
  end
end

def characterChecker
  val = $PokemonGlobal.playerID
  if val == 0
    $game_switches[94] = true
  elsif val == 3
    $game_switches[95] = true
  elsif val == 6
    $game_switches[96] = true
  end
end

def characterRestore(resetbag=true)
  pbChangePlayer(0) if $game_switches[94] == true
  pbChangePlayer(3) if $game_switches[95] == true
  pbChangePlayer(6) if $game_switches[96] == true
  $Trainer.party = $game_variables[726][0] if $game_switches[1408] == false
  $Trainer.name = $game_variables[12]
  $Trainer.badges = $game_variables[726][2]
  $Trainer.id = $game_variables[726][3]
  $Trainer.outfit = $game_variables[726][4]
  if resetbag==true # prevents bag/money from being reset
    $Trainer.money = $game_variables[726][1]
    $PokemonBag = $game_variables[726][5] 
  end
  $game_variables[726][6] = false
  $game_switches[1235] = false #you're now the player!
  $game_switches[145] = false
  $game_switches[1408] = false
end

def bagyeet
  File.open("bag.dat","w"){|file|
    Marshal.dump($PokemonBag,file)
  }
end

def bagyoink
  File.open("bag.dat","r"){|file|
    $PokemonBag =Marshal.load(file)
  }
end

def teamyeet
  File.open("team.dat","w"){|file|
    Marshal.dump($Trainer.party,file)
  }
end

def teamyoink
  File.open("team.dat","r"){|file|
    $Trainer.party =Marshal.load(file)
  }
end

