class Reset < Exception
end



def pbGetExceptionMessage(e,script="")
  emessage=e.message
  if e.is_a?(Hangup)
    emessage="The script is taking too long.  The game will restart."
  elsif e.is_a?(Errno::ENOENT)
    filename=emessage.sub("No such file or directory - ", "")
    emessage="File #{filename} not found."
  end
  if emessage && !safeExists?("Game.rgssad") && !safeExists?("Game.rgss2a")
    emessage=emessage.gsub(/uninitialized constant PBItems\:\:(\S+)/){
       "The item '#{$1}' is not valid. Please add the item\nto the list of items in the editor. See the wiki for more information." }
    emessage=emessage.gsub(/undefined method `(\S+?)' for PBItems\:Module/){
       "The item '#{$1}' is not valid. Please add the item\nto the list of items in the editor. See the wiki for more information." }
    emessage=emessage.gsub(/uninitialized constant PBTypes\:\:(\S+)/){
       "The type '#{$1}' is not valid. Please add the type\nto the PBS/types.txt file." }
    emessage=emessage.gsub(/undefined method `(\S+?)' for PBTypes\:Module/){
       "The type '#{$1}' is not valid. Please add the type\nto the PBS/types.txt file." }
    emessage=emessage.gsub(/uninitialized constant PBTrainers\:\:(\S+)$/){
       "The trainer type '#{$1}' is not valid. Please add the trainer\nto the list of trainer types in the Editor. See the wiki for\nmore information." }
    emessage=emessage.gsub(/undefined method `(\S+?)' for PBTrainers\:Module/){
       "The trainer type '#{$1}' is not valid. Please add the trainer\nto the list of trainer types in the Editor. See the wiki for\nmore information." }
    emessage=emessage.gsub(/uninitialized constant PBSpecies\:\:(\S+)$/){
       "The Pokemon species '#{$1}' is not valid. Please\nadd the species to the PBS/pokemon.txt file.\nSee the wiki for more information." }
    emessage=emessage.gsub(/undefined method `(\S+?)' for PBSpecies\:Module/){
       "The Pokemon species '#{$1}' is not valid. Please\nadd the species to the PBS/pokemon.txt file.\nSee the wiki for more information." }
  end
 return emessage
end

def pbCriticalCode
  ret=0
  begin
    yield
    ret=1
    rescue Exception
    e=$!
    if e.is_a?(Reset) || e.is_a?(SystemExit)
      raise
    else
      pbPrintException(e)
      if e.is_a?(Hangup)
        ret=2
        raise Reset.new
      end
    end
  end
  return ret
end



####################

module FileLineData
  @file=""
  @linedata=""
  @lineno=0
  @section=nil
  @key=nil
  @value=nil

  def self.file
    @file
  end

  def self.file=(value)
    @file=value
  end

  def self.clear
    @file=""
    @linedata=""
    @lineno=""
    @section=nil
    @key=nil
    @value=nil
  end

  def self.linereport
    if @section
      return _INTL("File {1}, section {2}, key {3}\n{4}\n",@file,@section,@key,@value)
    else
      return _INTL("File {1}, line {2}\n{3}\n",@file,@lineno,@linedata)
    end
  end

  def self.setSection(section,key,value)
    @section=section
    @key=key
    if value && value.length>200
      @value=_INTL("{1}...",value[0,200])
    else
      @value=!value ? "" : value.clone
    end
  end

  def self.setLine(line,lineno)
    @section=nil
    if line && line.length>200
      @linedata=_INTL("{1}...",line[0,200])
    else
      @linedata=line
    end
    @lineno=lineno
  end
end

# Shared, source-aware validation primitives for PBS adapters. These raise
# before compiler output is written and keep error messages tied to the active
# file/line or section tracked by FileLineData.
module AzurePBSValidation
  def self.error(message)
    raise _INTL("{1}\n{2}",message,FileLineData.linereport)
  end

  def self.required(value,label)
    error(_INTL("The required value {1} is missing.",label)) if !value || value.to_s.strip==""
    return value
  end

  def self.integer(value,label,min=nil,max=nil,allow_blank=false)
    return nil if allow_blank && (!value || value.to_s.strip=="")
    required(value,label)
    text=value.to_s.strip
    error(_INTL("{1} must be an integer, got {2}.",label,value)) if !text[/^-?\d+$/]
    number=text.to_i
    error(_INTL("{1} must be at least {2}, got {3}.",label,min,number)) if !min.nil? && number<min
    error(_INTL("{1} must be at most {2}, got {3}.",label,max,number)) if !max.nil? && number>max
    return number
  end

  def self.count(values,label,min,max)
    size=values ? values.length : 0
    error(_INTL("{1} must contain between {2} and {3} entries; found {4}.",label,min,max,size)) if size<min || size>max
    return values
  end

  def self.known_property(key,allowed,label)
    error(_INTL("Unknown {1} property {2}.",label,key)) if !allowed.include?(key)
    return key
  end

  def self.source(section,key=nil)
    if key
      for field in section[:fields]
        next if field[0]!=key
        FileLineData.setLine("#{field[0]} = #{field[1]}",field[2] || section[:lineno] || 0)
        return
      end
    end
    FileLineData.setLine("[#{section[:id]}]",section[:lineno] || 0)
  end

  def self.section_id(section,label,min,max)
    source(section)
    return integer(section[:id],label,min,max)
  end

  def self.properties(section,allowed,label,allow_legacy=false)
    seen={}
    for field in section[:fields]
      key=field[0]
      source(section,key)
      required(key,_INTL("{1} property name",label))
      if !allowed.include?(key) && !(allow_legacy && key[/^Legacy/])
        known_property(key,allowed,label)
      end
      unique(seen,key,_INTL("property in {1}",label),field[2] || section[:lineno] || 0)
    end
    return section
  end

  def self.item(row,label,section=nil)
    keys=["LegacyItemID",nil,"Name","Pocket","Price","Description",
          "FieldUse","BattleUse","Type","Move"]
    setsource=proc {|index| source(section,keys[index]) if section && keys[index] }
    normalized=row.clone
    setsource.call(0)
    normalized[0]=integer(row[0],_INTL("Legacy item ID for {1}",label),1)
    source(section) if section
    normalized[1]=constant_symbol(row[1],_INTL("Item symbol for {1}",label))
    setsource.call(2)
    normalized[2]=required(row[2],_INTL("Item name for {1}",label)).to_s
    setsource.call(3)
    normalized[3]=integer(row[3],_INTL("Item pocket for {1}",label),1,pbPocketNames.length-1)
    setsource.call(4)
    normalized[4]=integer(row[4],_INTL("Item price for {1}",label),0)
    setsource.call(5)
    normalized[5]=required(row[5],_INTL("Item description for {1}",label)).to_s
    setsource.call(6)
    normalized[6]=integer(row[6],_INTL("Item field use for {1}",label),0,5)
    setsource.call(7)
    normalized[7]=integer(row[7],_INTL("Item battle use for {1}",label),0,4)
    setsource.call(8)
    normalized[8]=integer(row[8],_INTL("Item type for {1}",label),0,13,true)
    normalized[9]=row[9].to_s
    normalized[9]=nil if normalized[9]==""
    if normalized[6]==3 || normalized[6]==4
      setsource.call(9)
      required(normalized[9],_INTL("Machine move for {1}",label))
    elsif normalized[9]
      setsource.call(9)
      error(_INTL("Item {1} defines a machine move but FieldUse is {2}, not 3 or 4.",label,normalized[6]))
    end
    return normalized
  end

  def self.move_number(value,label,min,max)
    required(value,label)
    if value.is_a?(Numeric)
      number=value.to_i
    else
      text=value.to_s.strip
      if text[/^0[xX][0-9A-Fa-f]+$/]
        number=text[2,text.length-2].to_i(16)
      elsif text[/^\d+$/]
        number=text.to_i
      elsif text[/^[0-9A-Fa-f]+$/] && text[/[A-Fa-f]/]
        number=text.to_i(16)
      else
        error(_INTL("{1} must be a decimal or hexadecimal integer, got {2}.",label,value))
      end
    end
    error(_INTL("{1} must be at least {2}, got {3}.",label,min,number)) if number<min
    error(_INTL("{1} must be at most {2}, got {3}.",label,max,number)) if number>max
    return number
  end

  def self.move_flags(value,label,symbol)
    flags=value.nil? ? "" : value.to_s.strip
    if flags[/[^a-ps]/]
      error(_INTL("{1} contains unsupported flags; use only a-p.",label))
    end
    seen={}
    for flag in flags.split(//)
      error(_INTL("{1} contains duplicate flag {2}.",label,flag)) if seen[flag]
      seen[flag]=true
    end
    # Azure's original DOUBLEKICK row contains an "s" marker. The legacy
    # compiler ignored it because runtime move flags occupy a-p. Retain that
    # source token for lossless round trips, but reject it on every other move.
    if flags[/s/] && symbol!="DOUBLEKICK"
      error(_INTL("{1} contains legacy ignored flag s, which is preserved only for DOUBLEKICK.",label))
    end
    return flags
  end

  def self.move(row,label,section=nil)
    normalized=row.clone
    functionKey="LegacyFunctionCode"
    targetKey="LegacyTarget"
    flagsKey="LegacyFlags"
    if section
      fieldKeys=section[:fields].map {|field| field[0] }
      functionKey="FunctionCode" if fieldKeys.include?("FunctionCode")
      targetKey="Target" if fieldKeys.include?("Target")
      flagsKey="Flags" if fieldKeys.include?("Flags")
    end
    source(section,"LegacyMoveID") if section
    normalized[0]=integer(row[0],_INTL("Legacy move ID for {1}",label),1)
    source(section) if section
    normalized[1]=constant_symbol(row[1],_INTL("Move symbol for {1}",label))
    source(section,"Name") if section
    normalized[2]=required(row[2],_INTL("Move name for {1}",label)).to_s
    source(section,functionKey) if section
    normalized[3]=move_number(row[3],_INTL("Function code for {1}",label),0,65535)
    source(section,"Power") if section
    normalized[4]=integer(row[4],_INTL("Power for {1}",label),0,255)
    source(section,"Type") if section
    if row[5].is_a?(Numeric)
      normalized[5]=integer(row[5],_INTL("Type for {1}",label),0)
    else
      typename=constant_symbol(row[5],_INTL("Type for {1}",label))
      normalized[5]=pbGetConst(PBTypes,typename,
         _INTL("Undefined type constant name: %s\n{1}",FileLineData.linereport))
    end
    source(section,"Category") if section
    if row[6].is_a?(Numeric)
      normalized[6]=integer(row[6],_INTL("Category for {1}",label),0,2)
    else
      categories={"Physical"=>0,"Special"=>1,"Status"=>2}
      category=required(row[6],_INTL("Category for {1}",label)).to_s
      error(_INTL("Unknown move category {1} for {2}.",category,label)) if !categories.has_key?(category)
      normalized[6]=categories[category]
    end
    source(section,"Accuracy") if section
    normalized[7]=integer(row[7],_INTL("Accuracy for {1}",label),0,255)
    source(section,"TotalPP") if section
    normalized[8]=integer(row[8],_INTL("Total PP for {1}",label),0,255)
    source(section,"EffectChance") if section
    normalized[9]=integer(row[9],_INTL("Effect chance for {1}",label),0,255)
    source(section,targetKey) if section
    normalized[10]=move_number(row[10],_INTL("Target for {1}",label),0,65535)
    source(section,"Priority") if section
    normalized[11]=integer(row[11],_INTL("Priority for {1}",label),-128,127)
    source(section,flagsKey) if section && row[12]
    normalized[12]=move_flags(row[12],_INTL("Flags for {1}",label),normalized[1])
    normalized[13]=row[13]
    if normalized[6]==2 && normalized[4]!=0
      error(_INTL("Status moves must have a base damage of 0."))
    end
    if normalized[6]!=2 && normalized[4]==0
      print _INTL(
        "Warning: Physical and special moves can't have a base damage of 0, changing to a Status move\n{1}",FileLineData.linereport)
      normalized[6]=2
    end
    return normalized
  end

  def self.boolean(value,label,default=false)
    return default if value.nil?
    text=value.to_s.strip.downcase
    return true if text=="true" || text=="1" || text=="yes"
    return false if text=="false" || text=="0" || text=="no"
    error(_INTL("{1} must be true, false, 1, 0, yes, or no; got {2}.",label,value))
  end

  def self.constant_list(value,label)
    return [] if value.nil? || value.to_s.strip==""
    text=value.to_s.strip
    if text[/^\s*,/] || text[/,\s*,/] || text[/,\s*$/]
      error(_INTL("{1} contains an empty entry.",label))
    end
    values=text.split(/\s*,\s*/)
    seen={}
    normalized=[]
    for entry in values
      symbol=constant_symbol(entry,label)
      error(_INTL("{1} contains duplicate value {2}.",label,symbol)) if seen[symbol]
      seen[symbol]=true
      normalized.push(symbol)
    end
    return normalized
  end

  def self.type(section)
    label=_INTL("type section [{1}]",section[:id])
    allowed=["Name","InternalName","IsPseudoType","IsSpecialType",
             "Weaknesses","Resistances","Immunities"]
    properties(section,allowed,label)
    data=pbAltPBSFieldHash(section)
    for key in ["Name","InternalName"]
      if !data.has_key?(key)
        source(section)
        error(_INTL("Type section [{1}] is missing {2}.",section[:id],key))
      end
    end
    normalized=[section_id(section,"Type ID",0,255),nil,nil,false,false,[],[],[]]
    source(section,"Name")
    normalized[1]=required(data["Name"],_INTL("Type name for {1}",label)).to_s
    source(section,"InternalName")
    normalized[2]=constant_symbol(data["InternalName"],_INTL("Internal type symbol for {1}",label))
    if data.has_key?("IsPseudoType")
      source(section,"IsPseudoType")
      normalized[3]=boolean(data["IsPseudoType"],_INTL("IsPseudoType for {1}",label))
    end
    if data.has_key?("IsSpecialType")
      source(section,"IsSpecialType")
      normalized[4]=boolean(data["IsSpecialType"],_INTL("IsSpecialType for {1}",label))
    end
    relationKeys=["Weaknesses","Resistances","Immunities"]
    for i in 0...relationKeys.length
      key=relationKeys[i]
      next if !data.has_key?(key)
      source(section,key)
      normalized[5+i]=constant_list(data[key],_INTL("{1} for {2}",key,label))
    end
    relations={}
    for i in 0...relationKeys.length
      for symbol in normalized[5+i]
        if relations.has_key?(symbol)
          source(section,relationKeys[i])
          error(_INTL("Type {1} appears in both {2} and {3} for {4}.",
             symbol,relations[symbol],relationKeys[i],label))
        end
        relations[symbol]=relationKeys[i]
      end
    end
    return normalized
  end

  def self.csv_values(value,label,allow_empty=false)
    return [] if value.nil? || value.to_s.strip==""
    text=value.to_s.clone
    if text[/,\s*$/]
      error(_INTL("{1} has a trailing empty CSV entry.",label))
    end
    values=[]
    loop do
      entry=csvfield!(text)
      if !allow_empty && entry.to_s.strip==""
        error(_INTL("{1} contains an empty CSV entry.",label))
      end
      values.push(entry)
      break if text==""
    end
    return values
  end

  def self.tm_species_list(value,label)
    values=csv_values(value,label)
    normalized=[]
    seen={}
    for entry in values
      symbol=required(entry,label).to_s.strip
      if symbol!="NIDORANfE" && symbol!="NIDORANmA"
        symbol=constant_symbol(symbol,label)
      end
      next if seen[symbol]
      seen[symbol]=true
      normalized.push(symbol)
    end
    return normalized
  end

  def self.property_value(section,data,keys,label,is_required=false)
    present=[]
    for key in keys
      present.push(key) if data.has_key?(key)
    end
    if present.length>1
      source(section,present[1])
      error(_INTL("{1} defines conflicting aliases {2}.",label,present.join(", ")))
    end
    if present.length==0
      source(section)
      error(_INTL("{1} is missing.",label)) if is_required
      return [nil,nil]
    end
    key=present[0]
    source(section,key)
    required(data[key],label) if is_required
    return [key,data[key]]
  end

  def self.decimal(value,label,min=nil,max=nil)
    required(value,label)
    begin
      number=Float(value)
    rescue
      error(_INTL("{1} must be a number, got {2}.",label,value))
    end
    error(_INTL("{1} must be at least {2}, got {3}.",label,min,number)) if !min.nil? && number<min
    error(_INTL("{1} must be at most {2}, got {3}.",label,max,number)) if !max.nil? && number>max
    return number
  end

  def self.pokemon_section(section)
    allowed=[
      "LegacySpeciesID","Name","LegacyName","Category","Kind","LegacyKind",
      "Pokedex","LegacyPokedex","Moves","LegacyMoves","Color","LegacyColor",
      "Types","Type1","LegacyType1","Type2","LegacyType2","BaseStats","LegacyBaseStats",
      "Rareness","CatchRate","LegacyRareness","GenderRate","GenderRatio","LegacyGenderRate",
      "Happiness","LegacyHappiness","GrowthRate","LegacyGrowthRate","StepsToHatch","HatchSteps",
      "LegacyStepsToHatch","LegacyEffortPoints","EVs","EffortPoints","Compatibility","EggGroups",
      "LegacyCompatibility","Height","LegacyHeight","Weight","LegacyWeight","BaseEXP","BaseExp",
      "LegacyBaseEXP","EggMoves","LegacyEggMoves","FormNames","LegacyFormNames","Evolutions",
      "LegacyEvolutions","Habitat","LegacyHabitat","Abilities","LegacyAbilities","HiddenAbility",
      "LegacyHiddenAbility","HiddenAbilities","LegacyHiddenAbilities","WildItemCommon",
      "LegacyWildItemCommon","WildItemUncommon","LegacyWildItemUncommon","WildItemRare",
      "LegacyWildItemRare","RegionalNumbers","LegacyRegionalNumbers","LegacyBattlerPlayerY",
      "LegacyBattlerEnemyY","LegacyBattlerAltitude","LegacyFormName","Legacytoobig"
    ]
    label=_INTL("Pokemon section [{1}]",section[:id])
    properties(section,allowed,label)
    source(section)
    symbol=constant_symbol(section[:id],_INTL("Pokemon symbol for {1}",label))
    data=pbAltPBSFieldHash(section)
    if !data.has_key?("LegacySpeciesID")
      error(_INTL("{1} is missing LegacySpeciesID.",label))
    end
    source(section,"LegacySpeciesID")
    speciesID=integer(data["LegacySpeciesID"],_INTL("Legacy species ID for {1}",label),1,65535)

    requiredGroups=[
      [["Name","LegacyName"],"species name"],
      [["Category","Kind","LegacyKind"],"species category"],
      [["Pokedex","LegacyPokedex"],"Pokedex entry"],
      [["Moves","LegacyMoves"],"level-up move list"],
      [["Color","LegacyColor"],"species color"],
      [["BaseStats","LegacyBaseStats"],"base stat list"],
      [["Rareness","CatchRate","LegacyRareness"],"catch rate"],
      [["GenderRate","GenderRatio","LegacyGenderRate"],"gender ratio"],
      [["Happiness","LegacyHappiness"],"base happiness"],
      [["GrowthRate","LegacyGrowthRate"],"growth rate"],
      [["StepsToHatch","HatchSteps","LegacyStepsToHatch"],"hatch steps"],
      [["LegacyEffortPoints","EVs","EffortPoints"],"EV yield"],
      [["Compatibility","EggGroups","LegacyCompatibility"],"egg groups"],
      [["Height","LegacyHeight"],"height"],
      [["Weight","LegacyWeight"],"weight"],
      [["BaseEXP","BaseExp","LegacyBaseEXP"],"base experience"],
      [["Abilities","LegacyAbilities"],"ability list"]
    ]
    for group in requiredGroups
      property_value(section,data,group[0],_INTL("Required {1} for {2}",group[1],label),true)
    end
    optionalGroups=[
      ["EggMoves","LegacyEggMoves"],["FormNames","LegacyFormNames"],
      ["Evolutions","LegacyEvolutions"],["Habitat","LegacyHabitat"],
      ["HiddenAbility","LegacyHiddenAbility","HiddenAbilities","LegacyHiddenAbilities"],
      ["WildItemCommon","LegacyWildItemCommon"],
      ["WildItemUncommon","LegacyWildItemUncommon"],
      ["WildItemRare","LegacyWildItemRare"],
      ["RegionalNumbers","LegacyRegionalNumbers"]
    ]
    for group in optionalGroups
      property_value(section,data,group,_INTL("Optional property for {1}",label),false)
    end

    typeListKey=nil
    typeListValue=nil
    if data.has_key?("Types")
      if data.has_key?("Type1") || data.has_key?("LegacyType1") ||
         data.has_key?("Type2") || data.has_key?("LegacyType2")
        source(section,"Types")
        error(_INTL("{1} must use either Types or the legacy Type1/Type2 properties, not both.",label))
      end
      typeListKey="Types"
      typeListValue=data["Types"]
    else
      type1Key,type1Value=property_value(section,data,["Type1","LegacyType1"],
         _INTL("Primary type for {1}",label),true)
      type2Key,type2Value=property_value(section,data,["Type2","LegacyType2"],
         _INTL("Secondary type for {1}",label),false)
      typeListKey=type1Key
      typeListValue=type1Value
      typeListValue=typeListValue.to_s+","+type2Value.to_s if type2Key && type2Value.to_s!=""
    end
    source(section,typeListKey)
    typeValues=csv_values(typeListValue,_INTL("Type list for {1}",label))
    count(typeValues,_INTL("Type list for {1}",label),1,2)
    for entry in typeValues
      constant_symbol(entry,_INTL("Type symbol for {1}",label))
    end

    baseStatsKey,baseStatsValue=property_value(section,data,["BaseStats","LegacyBaseStats"],
       _INTL("Base stats for {1}",label),true)
    baseStats=csv_values(baseStatsValue,_INTL("Base stats for {1}",label))
    count(baseStats,_INTL("Base stats for {1}",label),6,6)
    for stat in baseStats
      integer(stat,_INTL("Base stat for {1}",label),1,255)
    end

    abilitiesKey,abilitiesValue=property_value(section,data,["Abilities","LegacyAbilities"],
       _INTL("Abilities for {1}",label),true)
    abilities=csv_values(abilitiesValue,_INTL("Abilities for {1}",label))
    count(abilities,_INTL("Abilities for {1}",label),1,2)
    for ability in abilities
      constant_symbol(ability,_INTL("Ability symbol for {1}",label))
    end
    hiddenKey,hiddenValue=property_value(section,data,
       ["HiddenAbility","LegacyHiddenAbility","HiddenAbilities","LegacyHiddenAbilities"],
       _INTL("Hidden ability for {1}",label),false)
    if hiddenKey && hiddenValue.to_s!=""
      hiddenAbilities=csv_values(hiddenValue,_INTL("Hidden abilities for {1}",label))
      count(hiddenAbilities,_INTL("Hidden abilities for {1}",label),1,1)
      constant_symbol(hiddenAbilities[0],_INTL("Hidden ability symbol for {1}",label))
    end
    eggGroupKey,eggGroupValue=property_value(section,data,
       ["Compatibility","EggGroups","LegacyCompatibility"],
       _INTL("Egg groups for {1}",label),true)
    eggGroups=csv_values(eggGroupValue,_INTL("Egg groups for {1}",label))
    count(eggGroups,_INTL("Egg groups for {1}",label),1,2)

    movesKey,movesValue=property_value(section,data,["Moves","LegacyMoves"],
       _INTL("Level-up moves for {1}",label),true)
    moveValues=csv_values(movesValue,_INTL("Level-up moves for {1}",label))
    if moveValues.length==0 || moveValues.length%2!=0
      error(_INTL("Level-up moves for {1} must contain level/move pairs.",label))
    end
    i=0
    while i<moveValues.length
      integer(moveValues[i],_INTL("Move level for {1}",label),0,PBExperience::MAXLEVEL)
      constant_symbol(moveValues[i+1],_INTL("Move symbol for {1}",label))
      i+=2
    end

    eggKey,eggValue=property_value(section,data,["EggMoves","LegacyEggMoves"],
       _INTL("Egg moves for {1}",label),false)
    if eggKey && eggValue.to_s!=""
      for move in csv_values(eggValue,_INTL("Egg moves for {1}",label))
        constant_symbol(move,_INTL("Egg move symbol for {1}",label))
      end
    end
    evoKey,evoValue=property_value(section,data,["Evolutions","LegacyEvolutions"],
       _INTL("Evolutions for {1}",label),false)
    if evoKey && evoValue.to_s!=""
      evoValues=csv_values(evoValue,_INTL("Evolutions for {1}",label))
      if evoValues.length%3!=0
        error(_INTL("Evolutions for {1} must contain species/method/parameter triples.",label))
      end
      i=0
      while i<evoValues.length
        constant_symbol(evoValues[i],_INTL("Evolution species for {1}",label))
        required(evoValues[i+1],_INTL("Evolution method for {1}",label))
        i+=3
      end
    end

    evKey,evValue=property_value(section,data,["LegacyEffortPoints","EVs","EffortPoints"],
       _INTL("EV yield for {1}",label),true)
    evValues=csv_values(evValue,_INTL("EV yield for {1}",label))
    numericEVs=(evValues.length==6 && evValues.all? {|entry| entry[/^\d+$/] })
    if numericEVs
      for amount in evValues
        integer(amount,_INTL("EV yield amount for {1}",label),0,255)
      end
    else
      if evValues.length==0 || evValues.length%2!=0
        error(_INTL("EV yield for {1} must contain stat/amount pairs.",label))
      end
      statNames=["HP","ATTACK","ATK","DEFENSE","DEF","SPEED","SPD",
                 "SPECIAL_ATTACK","SPATK","SP_ATTACK","SPECIAL_DEFENSE","SPDEF","SP_DEFENSE"]
      seenStats={}
      i=0
      while i<evValues.length
        stat=evValues[i].to_s.upcase
        error(_INTL("Unknown EV stat {1} for {2}.",evValues[i],label)) if !statNames.include?(stat)
        canonical={"ATK"=>"ATTACK","DEF"=>"DEFENSE","SPD"=>"SPEED",
                   "SPATK"=>"SPECIAL_ATTACK","SP_ATTACK"=>"SPECIAL_ATTACK",
                   "SPDEF"=>"SPECIAL_DEFENSE","SP_DEFENSE"=>"SPECIAL_DEFENSE"}[stat] || stat
        error(_INTL("EV yield for {1} repeats stat {2}.",label,canonical)) if seenStats[canonical]
        seenStats[canonical]=true
        integer(evValues[i+1],_INTL("EV yield amount for {1}",label),0,255)
        i+=2
      end
    end

    for numericGroup in [
      [["Rareness","CatchRate","LegacyRareness"],"Catch rate",0,255],
      [["Happiness","LegacyHappiness"],"Happiness",0,255],
      [["StepsToHatch","HatchSteps","LegacyStepsToHatch"],"Hatch steps",1,65535],
      [["BaseEXP","BaseExp","LegacyBaseEXP"],"Base experience",0,65535]
    ]
      key,value=property_value(section,data,numericGroup[0],
         _INTL("{1} for {2}",numericGroup[1],label),true)
      integer(value,_INTL("{1} for {2}",numericGroup[1],label),numericGroup[2],numericGroup[3])
    end
    for decimalGroup in [
      [["Height","LegacyHeight"],"Height"],[["Weight","LegacyWeight"],"Weight"]
    ]
      key,value=property_value(section,data,decimalGroup[0],
         _INTL("{1} for {2}",decimalGroup[1],label),true)
      decimal(value,_INTL("{1} for {2}",decimalGroup[1],label),0.05)
    end

    regionalKey,regionalValue=property_value(section,data,["RegionalNumbers","LegacyRegionalNumbers"],
       _INTL("Regional numbers for {1}",label),false)
    if regionalKey && regionalValue.to_s!=""
      for regionalNumber in csv_values(regionalValue,_INTL("Regional numbers for {1}",label))
        integer(regionalNumber,_INTL("Regional number for {1}",label),0,65535)
      end
    end
    for itemGroup in [
      ["WildItemCommon","LegacyWildItemCommon"],
      ["WildItemUncommon","LegacyWildItemUncommon"],
      ["WildItemRare","LegacyWildItemRare"]
    ]
      itemKey,itemValue=property_value(section,data,itemGroup,_INTL("Wild item for {1}",label),false)
      next if !itemKey || itemValue.to_s==""
      itemValues=csv_values(itemValue,_INTL("Wild item for {1}",label))
      count(itemValues,_INTL("Wild item for {1}",label),1,1)
      constant_symbol(itemValues[0],_INTL("Wild item symbol for {1}",label))
    end
    return {:id=>speciesID,:symbol=>symbol}
  end

  def self.pokemon_metrics(section)
    allowed=["LegacyBattlerPlayerY","BattlerPlayerY","LegacyBattlerEnemyY","BattlerEnemyY",
             "LegacyBattlerAltitude","BattlerAltitude"]
    label=_INTL("Pokemon metrics section [{1}]",section[:id])
    properties(section,allowed,label)
    source(section)
    symbol=constant_symbol(section[:id],_INTL("Pokemon metrics symbol for {1}",label))
    data=pbAltPBSFieldHash(section)
    for group in [
      ["LegacyBattlerPlayerY","BattlerPlayerY"],
      ["LegacyBattlerEnemyY","BattlerEnemyY"],
      ["LegacyBattlerAltitude","BattlerAltitude"]
    ]
      key,value=property_value(section,data,group,_INTL("Metric for {1}",label),false)
      next if !key
      integer(value,_INTL("{1} for {2}",key,label),-32768,32767,true)
    end
    return symbol
  end

  def self.constant_symbol(value,label)
    symbol=required(value,label).to_s
    # These two mixed-case constants are historical Essentials spellings used
    # by Azure scripts and saves. Keep only their exact forms grandfathered.
    legacyNidoran=(symbol=="NIDORANfE" || symbol=="NIDORANmA")
    if !legacyNidoran && !symbol[/^[A-Z][A-Z0-9_]*$/]
      error(_INTL("{1} must begin with an uppercase letter and contain only uppercase letters, digits, and underscores; got {2}.",label,symbol))
    end
    return symbol
  end

  def self.ruby_constant_symbol(value,label)
    symbol=required(value,label).to_s
    if !symbol[/^[A-Z][A-Za-z0-9_]*$/]
      error(_INTL("{1} must be a valid Ruby constant beginning with an uppercase letter; got {2}.",label,symbol))
    end
    return symbol
  end

  def self.ability(row,label,section=nil)
    normalized=row.clone
    source(section,"LegacyAbilityID") if section
    normalized[0]=integer(row[0],_INTL("Legacy ability ID for {1}",label),1)
    source(section) if section
    normalized[1]=constant_symbol(row[1],_INTL("Ability symbol for {1}",label))
    source(section,"Name") if section
    normalized[2]=required(row[2],_INTL("Ability name for {1}",label)).to_s
    source(section,"Description") if section
    normalized[3]=required(row[3],_INTL("Ability description for {1}",label)).to_s
    return normalized
  end

  def self.trainer_type(row,label,section=nil)
    normalized=row.clone
    source(section,"LegacyTrainerTypeID") if section
    normalized[0]=integer(row[0],_INTL("Legacy trainer type ID for {1}",label),0)
    source(section) if section
    # Azure historically uses case-significant trainer constants such as
    # POKEMONTRAINER_Troy. They are valid Ruby constants and are referenced by
    # events/scripts, so preserve their spelling instead of normalizing it.
    normalized[1]=ruby_constant_symbol(row[1],_INTL("Trainer type symbol for {1}",label))
    source(section,"Name") if section
    normalized[2]=required(row[2],_INTL("Trainer type name for {1}",label)).to_s
    source(section,"BaseMoney") if section
    normalized[3]=integer(row[3],_INTL("Base money for {1}",label),0,255,true)
    normalized[3]=30 if normalized[3].nil?
    normalized[4]=row[4]
    normalized[5]=row[5]
    normalized[6]=row[6]
    genderValues={""=>2,"Male"=>0,"M"=>0,"0"=>0,"Female"=>1,"F"=>1,"1"=>1,
                  "Mixed"=>2,"X"=>2,"2"=>2}
    source(section,"Gender") if section
    gender=row[7].nil? ? "" : row[7].to_s
    error(_INTL("Unknown trainer gender {1} for {2}.",gender,label)) if !genderValues.has_key?(gender)
    normalized[7]=genderValues[gender]
    source(section,"SkillLevel") if section
    normalized[8]=integer(row[8],_INTL("Skill level for {1}",label),0,255,true)
    normalized[8]=normalized[3] if normalized[8].nil?
    return normalized
  end

  def self.unique(seen,key,label,first_location=nil)
    if seen.has_key?(key)
      location=seen[key]
      error(_INTL("Duplicate {1} {2}; the first definition is at line {3}.",label,key.inspect,location))
    end
    seen[key]=first_location
    return key
  end

  def self.encounter_type(data,typeid,mapid)
    return if !data || typeid.nil? || typeid<0
    slots=data[1][typeid]
    return if !slots
    expected=EncounterTypes::EnctypeChances[typeid]
    expectedCount=expected ? expected.length : 0
    if slots.length!=expectedCount
      error(_INTL("Encounter map {1}, type {2}, must contain exactly {3} slots; found {4}.",
         mapid,EncounterTypes::Names[typeid],expectedCount,slots.length))
    end
  end

  def self.encounter_map(data,mapid)
    return if !data
    for typeid in 0...EncounterTypes::Names.length
      next if !data[1][typeid]
      encounter_type(data,typeid,mapid)
    end
    hasLand=data[1][EncounterTypes::Land] ||
            data[1][EncounterTypes::LandMorning] ||
            data[1][EncounterTypes::LandDay] ||
            data[1][EncounterTypes::LandNight] ||
            data[1][EncounterTypes::BugContest]
    if hasLand && data[1][EncounterTypes::Cave]
      error(_INTL("Can't define both Land and Cave encounters in the same area (map ID {1}).",mapid))
    end
  end
end



def findIndex(a)
  index=-1
  count=0
  a.each {|i|
     if yield i
       index=count
       break
     end
     count+=1
  }
  return index
end

def prepline(line)
  line.sub!(/\s*\#.*$/,"")
  line.sub!(/\s+$/,"")
  return line
end

def csvfield!(str)
  ret=""
  str.sub!(/^\s*/,"")
  if str[0,1]=="\""
    str[0,1]=""
    escaped=false
    fieldbytes=0
    str.scan(/./) do |s|
      fieldbytes+=s.length
      break if s=="\"" && !escaped
      if s=="\\" && !escaped
        escaped=true
      else
        ret+=s
        escaped=false
      end
    end
    str[0,fieldbytes]=""
    if !str[/^\s*,/] && !str[/^\s*$/]
      raise _INTL("Invalid quoted field (in: {1})\n{2}",str,FileLineData.linereport)
    end
    str[0,str.length]=$~.post_match
  else
    if str[/,/]
      str[0,str.length]=$~.post_match
      ret=$~.pre_match
    else
      ret=str.clone
      str[0,str.length]=""
    end
    ret.gsub!(/\s+$/,"")
  end
  return ret
end

def csvquote(str)
  return "" if !str || str==""
  if str[/[,\"]/] #|| str[/^\s/] || str[/\s$/] || str[/^#/]
    str=str.gsub(/[\"]/,"\\\"")
    str="\"#{str}\""
  end
  return str
end

def csvBoolean!(str,line=-1)
  field=csvfield!(str)
  if field[/^1|[Tt][Rr][Uu][Ee]|[Yy][Ee][Ss]$/]
    return true
  elsif field[/^0|[Ff][Aa][Ll][Ss][Ee]|[Nn][Oo]$/]
    return false
  else
    raise _INTL("Field {1} is not a Boolean value (true, false, 1, 0)\n{2}",field,FileLineData.linereport)
    return false
  end
end

def csvPosInt!(str,line=-1)
  ret=csvfield!(str)
  if !ret[/^\d+$/]
    raise _INTL("Field {1} is not a positive integer\n{2}",ret,FileLineData.linereport)
  end
  return ret.to_i
end

def csvInt!(str,line=-1)
  ret=csvfield!(str)
  if !ret[/^\-?\d+$/]
    raise _INTL("Field {1} is not an integer\n{2}",ret,FileLineData.linereport)
  end
  return ret.to_i
end

def csvFloat!(str,key,section)
  ret=csvfield!(str)
  return Float(ret) rescue raise _INTL("Field {1} is not a number\n{2}",ret,FileLineData.linereport)
end

def intSize(value)
  return 1 if value<0x80
  return 2 if value<0x4000
  return 3 if value<0x200000
  return 4 if value<0x10000000
  return 5
end

def strSize(str)
  return str.length+intSize(str.length)
end

def encodeInt(strm,value)
  num=0
  loop do
    if value<0x80
      strm.fputb(value)
      return num+1
    end
    strm.fputb(0x80|(value&0x7F))
    value>>=7
    num+=1
  end
end

def decodeInt(strm)
  bits=0
  curbyte=0
  ret=0
  begin
    curbyte=strm.fgetb
    ret+=(curbyte&0x7F)<<bits
    bits+=7
  end while(((curbyte&0x80)>0)&&bits<0x1d)
  return ret
end

def encodeString(strm,str)
  encodeInt(strm,str.length)
  strm.write(str)
end

def decodeString(strm)
  len=decodeInt(strm)
  return strm.read(len)
end



class SerialRecord < Array
  def bytesize
    return SerialRecord.bytesize(self)
  end

  def encode(strm)
    return SerialRecord.encode(self,strm)
  end

  def self.bytesize(arr)
    ret=0
    return 0 if !arr
    for field in arr
      if field==nil || field==true || field==false
        ret+=1
      elsif field.is_a?(String)
        ret+=strSize(field)+1
      elsif field.is_a?(Numeric)
        ret+=intSize(field)+1
      end
    end
    return ret
  end

  def self.encode(arr,strm)
    return if !arr
    for field in arr
      if field==nil
        strm.write("0")
      elsif field==true
        strm.write("T")
      elsif field==false
        strm.write("F")
      elsif field.is_a?(String)
        strm.write("\"")
        encodeString(strm,field)
      elsif field.is_a?(Numeric)
        strm.write("i")
        encodeInt(strm,field)
      end
    end
  end

  def self.decode(strm,offset,length)
    ret=SerialRecord.new
    strm.pos=offset
    while strm.pos<offset+length
      datatype=strm.read(1)
      case datatype
        when "0"
          ret.push(nil)
        when "T"
          ret.push(true)
        when "F"
          ret.push(false)
        when "\""
          ret.push(decodeString(strm))
        when "i"
          ret.push(decodeInt(strm))
      end
    end
    return ret
  end
end



def readSerialRecords(filename)
  ret=[]
  pbRgssOpen(filename,"rb"){|file|
     numrec=file.fgetdw>>3
     curpos=0
     for i in 0...numrec
       file.pos=curpos
       offset=file.fgetdw
       length=file.fgetdw
       record=SerialRecord.decode(file,offset,length)
       ret.push(record)
       curpos+=8
     end
  }
  return ret
end



class ItemList
  include Enumerable

  def initialize
    @list=[]
  end

  def []=(x,v); @list[x]=v; end

  def [](x)
    if !@list[x]
      defrecord=SerialRecord.new
      defrecord.push(0)
      defrecord.push("????????")
      defrecord.push(0)
      defrecord.push(0)
      defrecord.push("????????")
      @list[x]=defrecord
      return defrecord
    end
    return @list[x]
  end

  def length; @list.length; end

  def each
    for i in 0...self.length
      yield self[i]
    end
  end
end



def readSerialRecords(filename)
  ret=[]
  if !pbRgssExists?(filename)
    return ret
  end
  pbRgssOpen(filename,"rb"){|file|
     numrec=file.fgetdw>>3
     curpos=0
     for i in 0...numrec
       file.pos=curpos
       offset=file.fgetdw
       length=file.fgetdw
       record=SerialRecord.decode(file,offset,length)
       ret.push(record)
       curpos+=8
     end
  }
  return ret
end

def readItemList(filename)
  ret=ItemList.new
  if !pbRgssExists?(filename)
    return ret
  end
  pbRgssOpen(filename,"rb"){|file|
     numrec=file.fgetdw>>3
     curpos=0
     for i in 0...numrec
       file.pos=curpos
       offset=file.fgetdw
       length=file.fgetdw
       record=SerialRecord.decode(file,offset,length)
       ret[record[0]]=record
       curpos+=8
     end
  }
  return ret
end

def writeSerialRecords(filename,records)
  File.open(filename,"wb"){|file|
     totalsize=records.length*8
     for record in records
       file.fputdw(totalsize)
       bytesize=record.bytesize
       file.fputdw(bytesize)
       totalsize+=bytesize
     end
     for record in records
       record.encode(file)
     end
  }
end

def pbGetCsvRecord(rec,lineno,schema)
  record=[]
  repeat=false
  if schema[1][0,1]=="*"
    repeat=true
    start=1
  else
    repeat=false
    start=0
  end
  begin
    for i in start...schema[1].length
      chr=schema[1][i,1]
      case chr
        when "u"
          record.push(csvPosInt!(rec,lineno))
        when "v"
          field=csvPosInt!(rec,lineno)
          raise _INTL("Field '{1}' must be greater than 0\n{2}",field,FileLineData.linereport) if field==0
          record.push(field)
        when "i"
          record.push(csvInt!(rec,lineno))
        when "U", "I"
          field=csvfield!(rec)
          if field==""
            record.push(nil)
          elsif !field[/^\d+$/]
            raise _INTL("Field '{1}' must be 0 or greater\n{2}",field,FileLineData.linereport)
          else
            record.push(field.to_i)
          end
        when "x"
          field=csvfield!(rec)
          if !field[/^[A-Fa-f0-9]+$/]
            raise _INTL("Field '{1}' is not a hexadecimal number\n{2}",field,FileLineData.linereport)
          end
          record.push(field.hex)
        when "s"
          record.push(csvfield!(rec))
        when "S"
          field=csvfield!(rec)
          if field==""
            record.push(nil)
          else
            record.push(field)
          end
        when "n" # Name
          field=csvfield!(rec)
          if !field[/^(?![0-9])\w+$/]
            raise _INTL("Field '{1}' must contain only letters, digits, and\nunderscores and can't begin with a number.\n{2}",field,FileLineData.linereport)
          end
          record.push(field)
        when "N" # Optional name
          field=csvfield!(rec)
          if field==""
            record.push(nil)
          else
            if !field[/^(?![0-9])\w+$/]
              raise _INTL("Field '{1}' must contain only letters, digits, and\nunderscores and can't begin with a number.\n{2}",field,FileLineData.linereport)
            end
            record.push(field)
          end
        when "b"
          record.push(csvBoolean!(rec,lineno))
        when "e"
          record.push(csvEnumField!(rec,schema[2+i-start],"",FileLineData.linereport))
      end
    end
    break if repeat && rec==""
  end while repeat
  return (schema[1].length==1) ? record[0] : record
end

def pbWriteCsvRecord(record,file,schema)
  if !record.is_a?(Array)
    rec=[record]
  else
    rec=record.clone
  end
  for i in 0...schema[1].length
    chr=schema[1][i,1]
    file.write(",") if i>0
    if rec[i].nil?
      # do nothing
    elsif rec[i].is_a?(String)
      file.write(csvquote(rec[i]))
    elsif rec[i]==true
      file.write("true")
    elsif rec[i]==false
      file.write("false")
    elsif rec[i].is_a?(Numeric)
      case chr
        when "e"
          enumer=schema[2+i]
          if enumer.is_a?(Array)
            file.write(enumer[rec[i]])
          elsif enumer.is_a?(Symbol) || enumer.is_a?(String)
            mod=Object.const_get(enumer.to_sym)
            if enumer.to_s=="PBTrainers" && !mod.respond_to?("getCount")
              file.write((getConstantName(mod,rec[i]) rescue pbGetTrainerConst(rec[i])))
            else
              file.write(getConstantName(mod,rec[i]))
            end
          elsif enumer.is_a?(Module)
            file.write(getConstantName(enumer,rec[i]))
          elsif enumer.is_a?(Hash)
            for key in enumer.keys
              if enumer[key]==rec[i]
                file.write(key)
                break
              end
            end
          end
        else
          file.write(rec[i].inspect)
      end
    else
      file.write(rec[i].inspect)
    end
  end
  return record
end

def pbEachCommentedLine(f)
  lineno=1
  f.each_line {|line|
     if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
       line=line[3,line.length-3]
     end
     if !line[/^\#/] && !line[/^\s*$/]
       yield line, lineno
     end
     lineno+=1
  }
end

def pbEachPreppedLine(f)
  lineno=1
  f.each_line {|line|
     if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
       line=line[3,line.length-3]
     end
     line=prepline(line)
     if !line[/^\#/] && !line[/^\s*$/]
       yield line, lineno
     end
     lineno+=1
  }
end

def pbCompilerEachCommentedLine(filename)
  File.open(filename,"rb"){|f|
     FileLineData.file=filename
     lineno=1
     f.each_line {|line|
        if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
          line=line[3,line.length-3]
        end
        if !line[/^\#/] && !line[/^\s*$/]
          FileLineData.setLine(line,lineno)
          yield line, lineno
        end
        lineno+=1
     }
  }
end

def pbCompilerEachPreppedLine(filename)
  File.open(filename,"rb"){|f|
     FileLineData.file=filename
     lineno=1
     f.each_line {|line|
        if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
          line=line[3,line.length-3]
        end
        line=prepline(line)
        if !line[/^\#/] && !line[/^\s*$/]
          FileLineData.setLine(line,lineno)
          yield line, lineno
        end
        lineno+=1
     }
  }
end

def pbCompileShadowMoves(outputFile="Data/shadowmoves.dat",installRuntime=true)
  sections=[]
  if File.exists?("PBS/shadowmoves.txt")
    if pbIsSectionedPBSFile("PBS/shadowmoves.txt")
      seen={}
      for section in pbAltPBSParseLegacySections("PBS/shadowmoves.txt")
        data=pbAltPBSFieldHash(section)
        if !section[:id] || section[:id]==""
          raise _INTL("A Shadow move section has no species identifier.")
        end
        for field in section[:fields]
          if field[0]!="Moves"
            raise _INTL("Unknown Shadow move property {1} in section [{2}].",field[0],section[:id])
          end
        end
        if seen[section[:id]]
          raise _INTL("Shadow move section [{1}] is defined more than once.",section[:id])
        end
        seen[section[:id]]=true
        if !data["Moves"] || data["Moves"]==""
          raise _INTL("Shadow move section [{1}] is missing Moves.",section[:id])
        end
        values=data["Moves"].split(",")
        if values.length>4
          raise _INTL("Shadow move section [{1}] has {2} moves; at most 4 are supported.",section[:id],values.length)
        end
        species=parseSpecies(section[:id])
        moves=[]
        for value in values
          value=value.gsub(/^\s+/,"").gsub(/\s+$/ ,"")
          moves.push(parseMove(value)) if value!=""
        end
        sections[species]=moves if moves.length>0
      end
    else
      # Preserve the original parser, including its permissive handling of
      # unknown legacy move names and its four-move limit.
      pbCompilerEachCommentedLine("PBS/shadowmoves.txt"){|line,lineno|
         if line[ /^([^=]+)=(.*)$/ ]
           key=$1
           value=$2
           value=value.split(",")
           species=parseSpecies(key)
           moves=[]
           for i in 0...[4,value.length].min
             moves.push((parseMove(value[i]) rescue nil))
           end
           moves.compact!
           sections[species]=moves if moves.length>0
         end
      }
    end
  end
  save_data(sections,outputFile)
  AzureDataCache.clear("Data/shadowmoves.dat") if installRuntime && defined?(AzureDataCache)
  return sections
end

# Azure contains a small set of historical duplicate symbols/IDs that are
# already baked into saves and events. Their exact memberships are accepted;
# any additional or changed collision is an authoring error.
AZURE_LEGACY_DUPLICATE_SYMBOLS={
  :moves=>{
    "ORIGINPULSE"=>[661,671],"PRECIPICEBLADES"=>[662,672],
    "DRAGONASCENT"=>[663,673],"THOUSANDARROWS"=>[664,674],
    "THOUSANDWAVES"=>[665,675],"DIAMONDSTORM"=>[666,676],
    "STEAMERUPTION"=>[668,678],"DISHEARTEN"=>[1033,1049],
    "EPHEMERATE"=>[1034,1050],"ANTICLINE"=>[1035,1051]
  },
  :pokemon=>{"IRONMOTH"=>[994,994]},
  :abilities=>{
    "TOXICCHAIN"=>[371,396],"CARETAKER"=>[326,404],
    "BLOODTHIRSTY"=>[332,405],"SCAVENGER"=>[336,406],
    "EXECUTIONER"=>[342,407],"EVENTHORIZON"=>[346,408]
  },
  :trainer_types=>{"SCHOOLKID_F"=>[14,15],"HADIEN"=>[187,221]},
  :items=>{"GREENKEY"=>[606,625],"TM115"=>[885,1050],"TM116"=>[886,1051]}
} if !defined?(AZURE_LEGACY_DUPLICATE_SYMBOLS)

AZURE_LEGACY_DUPLICATE_IDS={
  :moves=>{318=>["BONECLUB","SPIKECANNON"],680=>["DIMPULSE","DIMZAP"]},
  :pokemon=>{306=>["AGGRON","DEOXYS"],994=>["IRONMOTH","IRONMOTH"]}
} if !defined?(AZURE_LEGACY_DUPLICATE_IDS)

# Compatibility names used by form scripts but intentionally sharing an
# existing numeric ability. They aren't separate localized ability records.
AZURE_LEGACY_ABILITY_ALIASES=[
  ["SPIRITED",72],
  ["SNOWVEIL",81],
  ["MAJESTY",213]
] if !defined?(AZURE_LEGACY_ABILITY_ALIASES)

def pbValidateAzureLegacyDuplicates(dataset,pairs)
  symbols={}
  ids={}
  for pair in pairs
    id=pair[0].to_i
    symbol=pair[1].to_s
    symbols[symbol]=[] if !symbols[symbol]
    symbols[symbol].push(id)
    ids[id]=[] if !ids[id]
    ids[id].push(symbol)
  end
  allowedSymbols=AZURE_LEGACY_DUPLICATE_SYMBOLS[dataset] || {}
  allowedIDs=AZURE_LEGACY_DUPLICATE_IDS[dataset] || {}
  for symbol in symbols.keys
    next if symbols[symbol].length<2
    actual=symbols[symbol].sort
    expected=allowedSymbols[symbol]
    if !expected || actual!=expected.sort
      raise _INTL("{1} symbol {2} has duplicate IDs {3}; this is not a documented legacy alias.",dataset,symbol,actual.join(","))
    end
  end
  for id in ids.keys
    next if ids[id].length<2
    actual=ids[id].sort
    expected=allowedIDs[id]
    if !expected || actual!=expected.sort
      raise _INTL("{1} ID {2} is shared by {3}; this is not a documented legacy alias.",dataset,id,actual.join(","))
    end
  end
end

AZURE_BT_TRAINER_PROPERTIES=[
  "Type","Name","BeginSpeech","EndSpeechWin","EndSpeechLose","PokemonNos"
] if !defined?(AZURE_BT_TRAINER_PROPERTIES)

AZURE_BT_POKEMON_EV_STATS=["HP","ATK","DEF","SPD","SA","SD"] if !defined?(AZURE_BT_POKEMON_EV_STATS)

def pbBattleFacilityConstantID(mod,value,label,allowBlank=false)
  text=value.nil? ? "" : value.to_s.strip
  return 0 if allowBlank && text==""
  AzurePBSValidation.required(text,label)
  if !text[/^[A-Z][A-Za-z0-9_]*$/] || !(mod.const_defined?(text) rescue false)
    AzurePBSValidation.error(_INTL("Unknown {1} {2}.",label,text))
  end
  return mod.const_get(text.to_sym)
end

# Reads one optional facility-Trainer source into Azure's historical six-field
# arrays. Missing files intentionally remain empty because Azure ships list
# declarations for facilities whose generated pools have never been authored.
def pbReadBTTrainerSource(filename)
  result={:records=>[],:names=>[],:begin_speech=>[],:win_speech=>[],
          :lose_speech=>[],:record_lines=>[]}
  return result if !safeExists?(filename)
  FileLineData.file=filename
  sectionKeys={}
  for section in pbAltPBSParseLegacySections(filename)
    AzurePBSValidation.source(section)
    sectionID=AzurePBSValidation.required(section[:id],"battle-facility Trainer section ID").to_s
    AzurePBSValidation.unique(sectionKeys,sectionID,"battle-facility Trainer section",section[:lineno])
    AzurePBSValidation.properties(section,AZURE_BT_TRAINER_PROPERTIES,
      _INTL("battle-facility Trainer section [{1}]",sectionID))
    data=pbAltPBSFieldHash(section)
    required=["Type","Name","BeginSpeech","EndSpeechWin","EndSpeechLose"]
    for key in required
      AzurePBSValidation.source(section,key)
      AzurePBSValidation.required(data[key],_INTL("{1} in battle-facility Trainer [{2}]",key,sectionID))
    end
    record=[]
    AzurePBSValidation.source(section,"Type")
    record[0]=pbBattleFacilityConstantID(PBTrainers,data["Type"],"Trainer type")
    record[1]=data["Name"].to_s
    record[2]=data["BeginSpeech"].to_s
    record[3]=data["EndSpeechWin"].to_s
    record[4]=data["EndSpeechLose"].to_s
    record[5]=[]
    if data["PokemonNos"] && data["PokemonNos"].to_s.strip!=""
      AzurePBSValidation.source(section,"PokemonNos")
      seenNumbers={}
      values=data["PokemonNos"].to_s.split(",",-1)
      for value in values
        number=AzurePBSValidation.integer(value,"PokemonNos entry",0)
        AzurePBSValidation.unique(seenNumbers,number,"PokemonNos entry",section[:lineno])
        record[5].push(number)
      end
    end
    result[:records].push(record)
    result[:names].push(record[1])
    result[:begin_speech].push(record[2])
    result[:win_speech].push(record[3])
    result[:lose_speech].push(record[4])
    result[:record_lines].push(section[:lineno])
  end
  return result
end

# Validates one optional facility-Pokemon source before converting each row to
# the PBPokemon object stored in trainerlists.dat.
def pbReadBTPokemonSource(filename)
  records=[]
  recordLines=[]
  return {:records=>records,:record_lines=>recordLines} if !safeExists?(filename)
  FileLineData.file=filename
  for rawline in pbAltPBSReadLines(filename)
    line=rawline[1]
    next if line[/^\s*#/] || line[/^\s*$/]
    FileLineData.setLine(line,rawline[0])
    pieces=line.strip.split(";",-1)
    if pieces.length!=5
      AzurePBSValidation.error(_INTL("Battle-facility Pokemon rows must contain exactly five semicolon-separated fields; found {1}.",pieces.length))
    end
    pbBattleFacilityConstantID(PBSpecies,pieces[0],"Pokemon species")
    pbBattleFacilityConstantID(PBItems,pieces[1],"held item",true)
    pbBattleFacilityConstantID(PBNatures,pieces[2],"nature")
    seenStats={}
    if pieces[3].to_s.strip!=""
      for stat in pieces[3].split(",",-1)
        stat=stat.to_s.strip.upcase
        if !AZURE_BT_POKEMON_EV_STATS.include?(stat)
          AzurePBSValidation.error(_INTL("Unknown battle-facility EV stat {1}; expected one of {2}.",stat,AZURE_BT_POKEMON_EV_STATS.join(", ")))
        end
        AzurePBSValidation.unique(seenStats,stat,"battle-facility EV stat",rawline[0])
      end
    end
    moveNames=pieces[4].split(",",-1)
    while moveNames.length>0 && moveNames[moveNames.length-1].to_s.strip==""
      moveNames.pop
    end
    AzurePBSValidation.count(moveNames,"battle-facility move list",1,4)
    seenMoves={}
    for moveName in moveNames
      moveName=moveName.to_s.strip
      pbBattleFacilityConstantID(PBMoves,moveName,"move")
      AzurePBSValidation.unique(seenMoves,moveName,"battle-facility move",rawline[0])
    end
    records.push(PBPokemon.fromInspected(line))
    recordLines.push(rawline[0])
  end
  return {:records=>records,:record_lines=>recordLines}
end

def pbCompileBTTrainers(filename,installMessages=true)
  result=pbReadBTTrainerSource(filename)
  if installMessages
    MessageTypes.addMessagesAsHash(MessageTypes::TrainerNames,result[:names])
    MessageTypes.addMessagesAsHash(MessageTypes::BeginSpeech,result[:begin_speech])
    MessageTypes.addMessagesAsHash(MessageTypes::EndSpeechWin,result[:win_speech])
    MessageTypes.addMessagesAsHash(MessageTypes::EndSpeechLose,result[:lose_speech])
  end
  return result[:records]
end

def pbCompileTownMap(dataOutput="Data/townmap.dat",installRuntime=true,
                     messagesOutput=nil)
  nonglobaltypes={
     "Name"=>[0,"s"],
     "Filename"=>[1,"s"],
     "Point"=>[2,"uussUUUU"]
  }
  rgnnames=[]
  placenames=[]
  placedescs=[]
  sections=[]
  regionKeys={}
  for section in pbAltPBSParseLegacySections("PBS/townmap.txt")
    currentmap=AzurePBSValidation.section_id(section,"Town map region ID",0,999)
    AzurePBSValidation.unique(regionKeys,currentmap,"town map region",section[:lineno])
    sections[currentmap]=[]
    propertyKeys={}
    for field in section[:fields]
      settingname=field[0]
      AzurePBSValidation.source(section,settingname)
      AzurePBSValidation.known_property(settingname,nonglobaltypes.keys,"town map")
      if settingname!="Point"
        AzurePBSValidation.unique(propertyKeys,settingname,
           _INTL("property in town map region {1}",currentmap),field[2] || section[:lineno])
      end
      schema=nonglobaltypes[settingname]
      fieldValue=field[1]
      if fieldValue.respond_to?(:force_encoding)
        fieldValue=fieldValue.dup.force_encoding("ASCII-8BIT")
      end
      record=pbGetCsvRecord(fieldValue,field[2] || section[:lineno] || 0,schema)
      messageRecord=pbGetCsvRecord(field[1],field[2] || section[:lineno] || 0,schema)
      if settingname=="Name"
        AzurePBSValidation.required(messageRecord,_INTL("Name in town map region {1}",currentmap))
        rgnnames[currentmap]=messageRecord
      elsif settingname=="Point"
        healing=[record[4],record[5],record[6]]
        healingCount=healing.compact.length
        if healingCount!=0 && healingCount!=3
          AzurePBSValidation.error(_INTL("Town map point {1},{2} must define all three healing spot values or none.",record[0],record[1]))
        end
        placenames.push(messageRecord[2])
        placedescs.push(messageRecord[3])
        sections[currentmap][schema[0]]=[] if !sections[currentmap][schema[0]]
        sections[currentmap][schema[0]].push(record)
      else   # Filename
        AzurePBSValidation.required(record,_INTL("Filename in town map region {1}",currentmap))
        sections[currentmap][schema[0]]=record
      end
    end
    AzurePBSValidation.source(section)
    AzurePBSValidation.required(rgnnames[currentmap],
       _INTL("Name in town map region {1}",currentmap))
    AzurePBSValidation.required(sections[currentmap][nonglobaltypes["Filename"][0]],
       _INTL("Filename in town map region {1}",currentmap))
    sections[currentmap][nonglobaltypes["Point"][0]]=[] if !sections[currentmap][nonglobaltypes["Point"][0]]
  end
  File.open(dataOutput,"wb"){|f|
     Marshal.dump(sections,f)
  }
  if installRuntime
    MessageTypes.setMessages(MessageTypes::RegionNames,rgnnames)
    MessageTypes.setMessagesAsHash(MessageTypes::PlaceNames,placenames)
    MessageTypes.setMessagesAsHash(MessageTypes::PlaceDescriptions,placedescs)
    AzureDataCache.clear("Data/townmap.dat") if defined?(AzureDataCache)
  end
  if messagesOutput
    messages=File.open("Data/messages.dat","rb"){|file| Marshal.load(file) }
    normalizedRegionNames=[]
    for i in 0...rgnnames.length
      normalizedRegionNames[i]=rgnnames[i] ? rgnnames[i] : ""
    end
    messages[MessageTypes::RegionNames]=normalizedRegionNames
    messages[MessageTypes::PlaceNames]=Messages.createHash(MessageTypes::PlaceNames,placenames)
    messages[MessageTypes::PlaceDescriptions]=Messages.createHash(MessageTypes::PlaceDescriptions,placedescs)
    File.open(messagesOutput,"wb"){|file| Marshal.dump(messages,file) }
  end
  return {:sections=>sections,:region_names=>rgnnames,
          :place_names=>placenames,:place_descriptions=>placedescs}
end



class PBTrainers; end

def pbCompileMetadata(outputFile="Data/metadata.dat",installRuntime=true)
  if pbUsesSplitMetadataPBS("PBS/metadata.txt","PBS/map_metadata.txt")
    sections=[]
    sections[0]=[]
    globalKeyMap={
      "Home"=>"Home",
      "WildBattleBGM"=>"WildBattleBGM",
      "TrainerBattleBGM"=>"TrainerBattleBGM",
      "WildVictoryBGM"=>"WildVictoryME",
      "TrainerVictoryBGM"=>"TrainerVictoryME",
      "SurfBGM"=>"SurfBGM",
      "BicycleBGM"=>"BicycleBGM"
    }
    globalSectionKeys={}
    playerProperties=["LegacyPlayerSlot","TrainerType","WalkCharset","CycleCharset",
                      "SurfCharset","RunCharset","DiveCharset","FishCharset","SurfFishCharset"]
    requiredPlayerProperties=["TrainerType","WalkCharset","CycleCharset","SurfCharset",
                              "RunCharset","DiveCharset","FishCharset","SurfFishCharset"]
    playerSlots=["PlayerA","PlayerB","PlayerC","PlayerD","PlayerE","PlayerF","PlayerG",
                 "PlayerH","PlayerI","PlayerJ","PlayerK","PlayerL","PlayerM","PlayerN",
                 "PlayerO","PlayerP","PlayerQ","PlayerR","PlayerS","PlayerT","PlayerU",
                 "PlayerV","PlayerW","PlayerX","PlayerY"]
    FileLineData.file="PBS/metadata.txt"
    playerSections=pbAltPBSParseLegacySections("PBS/metadata.txt")
    for section in playerSections
      sectionID=AzurePBSValidation.section_id(section,"Metadata section ID",0,25)
      AzurePBSValidation.unique(globalSectionKeys,sectionID,"metadata section",section[:lineno])
      allowedProperties=sectionID==0 ? globalKeyMap.keys : playerProperties
      AzurePBSValidation.properties(section,allowedProperties,
         _INTL("metadata section [{1}]",sectionID),true)
      data=pbAltPBSFieldHash(section)
      if sectionID==0
        for key in data.keys
          mappedKey=globalKeyMap[key]
          next if !mappedKey
          schema=PokemonMetadata::GlobalTypes[mappedKey]
          next if !schema
          AzurePBSValidation.source(section,key)
          sections[0][schema[0]]=pbGetCsvRecord(data[key],section[:lineno] || 0,schema)
        end
      else
        for key in requiredPlayerProperties
          AzurePBSValidation.source(section,key)
          AzurePBSValidation.required(data[key],_INTL("{1} in player metadata section [{2}]",key,sectionID))
        end
        if data["LegacyPlayerSlot"] && data["LegacyPlayerSlot"]!="" &&
           data["LegacyPlayerSlot"]!=playerSlots[sectionID-1]
          AzurePBSValidation.source(section,"LegacyPlayerSlot")
          AzurePBSValidation.error(_INTL("LegacyPlayerSlot {1} does not match metadata section [{2}] ({3}).",
             data["LegacyPlayerSlot"],sectionID,playerSlots[sectionID-1]))
        end
        playerIndex=sectionID-1
        playerData=[]
        AzurePBSValidation.source(section,"TrainerType")
        playerData[0]=parseTrainer(data["TrainerType"]) if data["TrainerType"] && data["TrainerType"]!=""
        playerData[1]=data["WalkCharset"]
        playerData[2]=data["CycleCharset"]
        playerData[3]=data["SurfCharset"]
        playerData[4]=data["RunCharset"]
        playerData[5]=data["DiveCharset"]
        playerData[6]=data["FishCharset"]
        playerData[7]=data["SurfFishCharset"]
        sections[0][MetadataPlayerA+playerIndex]=playerData
      end
    end
    mapKeyMap={
      "Outdoor"=>"Outdoor",
      "ShowArea"=>"ShowArea",
      "Bicycle"=>"Bicycle",
      "BicycleAlways"=>"BicycleAlways",
      "HealingSpot"=>"HealingSpot",
      "Weather"=>"Weather",
      "MapPosition"=>"MapPosition",
      "DiveMap"=>"DiveMap",
      "DarkMap"=>"DarkMap",
      "SafariMap"=>"SafariMap",
      "SnapEdges"=>"SnapEdges",
      "Dungeon"=>"Dungeon",
      "BattleBack"=>"BattleBack",
      "WildBattleBGM"=>"WildBattleBGM",
      "TrainerBattleBGM"=>"TrainerBattleBGM",
      "WildVictoryBGM"=>"WildVictoryME",
      "TrainerVictoryBGM"=>"TrainerVictoryME",
      "MapSize"=>"MapSize"
    }
    mapSectionKeys={}
    FileLineData.file="PBS/map_metadata.txt"
    mapSections=pbAltPBSParseLegacySections("PBS/map_metadata.txt")
    for section in mapSections
      mapid=AzurePBSValidation.section_id(section,"Map metadata section ID",1,999)
      AzurePBSValidation.unique(mapSectionKeys,mapid,"map metadata section",section[:lineno])
      AzurePBSValidation.properties(section,mapKeyMap.keys+["Name"],
         _INTL("map metadata section [{1}]",mapid),true)
      sections[mapid]=[] if !sections[mapid]
      data=pbAltPBSFieldHash(section)
      for key in data.keys
        mappedKey=mapKeyMap[key]
        next if !mappedKey
        schema=PokemonMetadata::NonGlobalTypes[mappedKey]
        next if !schema
        AzurePBSValidation.source(section,key)
        sections[mapid][schema[0]]=pbGetCsvRecord(data[key],section[:lineno] || 0,schema)
      end
    end
    if sections[0][MetadataHome]==nil
      raise _INTL("The entry Home is required in split metadata.txt section [0].")
    end
    if sections[0][MetadataPlayerA]==nil
      raise _INTL("At least one player entry is required in split metadata.txt.")
    end
    File.open(outputFile,"wb"){|f|
       Marshal.dump(sections,f)
    }
    pbInvalidateMetadataData if installRuntime && defined?(pbInvalidateMetadataData)
    return sections
  end
  sections=[]
  currentmap=-1
  pbCompilerEachCommentedLine("PBS/metadata.txt") {|line,lineno|
     if line[/^\s*\[\s*(\d+)\s*\]\s*$/]
       sectionname=$~[1]
       if currentmap==0
         if sections[currentmap][MetadataHome]==nil
           raise _INTL("The entry Home is required in metadata.txt section [{1}]",sectionname)
         end
         if sections[currentmap][MetadataPlayerA]==nil
           raise _INTL("The entry PlayerA is required in metadata.txt section [{1}]",sectionname)
         end
       end
       currentmap=sectionname.to_i
       sections[currentmap]=[]
     else
       if currentmap<0
         raise _INTL("Expected a section at the beginning of the file\n{1}",FileLineData.linereport)
       end
       if !line[/^\s*(\w+)\s*=\s*(.*)$/]
         raise _INTL("Bad line syntax (expected syntax like XXX=YYY)\n{1}",FileLineData.linereport)
       end
       matchData=$~
       schema=nil
       FileLineData.setSection(currentmap,matchData[1],matchData[2])
       if currentmap==0
         schema=PokemonMetadata::GlobalTypes[matchData[1]]
       else
         schema=PokemonMetadata::NonGlobalTypes[matchData[1]]
       end
       if schema
         record=pbGetCsvRecord(matchData[2],lineno,schema)
         sections[currentmap][schema[0]]=record
       end
     end
  }
  File.open(outputFile,"wb"){|f|
     Marshal.dump(sections,f)
  }
  pbInvalidateMetadataData if installRuntime && defined?(pbInvalidateMetadataData)
  return sections
end

def pbCompileItems(dataOutput="Data/pokmanitems.rxdata",
                   scriptOutput="Scripts/PBItems.rb",installRuntime=true,
                   messagesOutput=nil)
  records=[]
  records[0] = []
  records2=[]
  constants=""
  itemnames=[]
  itemdescs=[]
  maxValue=0
  sourceRecords=[]
  if pbIsSectionedPBSFile("PBS/items.txt")
    FileLineData.file="PBS/items.txt"
    allowedFields=["LegacyItemID","Name","Pocket","Price","Description",
                   "FieldUse","BattleUse","Type","Move"]
    for section in pbAltPBSParseLegacySections("PBS/items.txt")
      AzurePBSValidation.properties(section,allowedFields,
         _INTL("item section [{1}]",section[:id]))
      data=pbAltPBSFieldHash(section)
      for required in ["LegacyItemID","Name","Pocket","Price","Description",
                        "FieldUse","BattleUse","Type"]
        if !data.has_key?(required)
          AzurePBSValidation.source(section)
          raise _INTL("Item section [{1}] is missing {2}.",section[:id],required)
        end
      end
      row=[data["LegacyItemID"],section[:id],data["Name"],data["Pocket"],data["Price"],
           data["Description"],data["FieldUse"],data["BattleUse"],data["Type"],data["Move"]]
      sourceRecords.push(AzurePBSValidation.item(row,_INTL("section [{1}]",section[:id]),section))
    end
  else
    pbCompilerEachCommentedLine("PBS/items.txt"){|line,lineno|
       row=pbGetCsvRecord(line,lineno,[0,"vnsuusuuUN"])
       if line.to_s.gsub(/^\s+/,"").gsub(/\s+$/ ,"")!=""
         AzurePBSValidation.error(_INTL("Item row contains more than 10 CSV fields."))
       end
       sourceRecords.push(AzurePBSValidation.item(row,_INTL("line {1}",lineno)))
    }
  end
  pbValidateAzureLegacyDuplicates(:items,sourceRecords.map {|record| [record[0],record[1]] })
  for linerecord in sourceRecords
     record=SerialRecord.new
     record[ITEMID]        = linerecord[0]
     constant=linerecord[1]
     constants+="#{constant}=#{record[0]}\n"
     record[ITEMNAME]      = linerecord[2]
     itemnames[record[0]]=linerecord[2]
     record[ITEMPOCKET]    = linerecord[3]
     record[ITEMPRICE]     = linerecord[4]
     record[ITEMDESC]      = linerecord[5]
     itemdescs[record[0]]=linerecord[5]
     record[ITEMUSE]       = linerecord[6]
     record[ITEMBATTLEUSE] = linerecord[7]
     record[ITEMTYPE]      = linerecord[8]
     if linerecord[9]!="" && linerecord[9]
       record[ITEMMACHINE] = parseMove(linerecord[9])
     else
       record[ITEMMACHINE] = 0
     end
     maxValue=[maxValue,record[0]].max
     records[record[ITEMID]] = record
  end
  File.open(dataOutput,"wb"){|file|
    Marshal.dump(records,file)
  }
  if installRuntime
    $ItemData=records
    AzureDataCache.clear("Data/pokmanitems.rxdata") if defined?(AzureDataCache)
    PBItemData.clear_cache if defined?(PBItemData)
    MessageTypes.setMessages(MessageTypes::Items,itemnames)
    MessageTypes.setMessages(MessageTypes::ItemDescriptions,itemdescs)
  end
  if messagesOutput
    messages=File.open("Data/messages.dat","rb"){|file| Marshal.load(file) }
    normalizedNames=[]
    normalizedDescriptions=[]
    for i in 0...itemnames.length
      normalizedNames[i]=itemnames[i] ? itemnames[i] : ""
    end
    for i in 0...itemdescs.length
      normalizedDescriptions[i]=itemdescs[i] ? itemdescs[i] : ""
    end
    messages[MessageTypes::Items]=normalizedNames
    messages[MessageTypes::ItemDescriptions]=normalizedDescriptions
    File.open(messagesOutput,"wb"){|file| Marshal.dump(messages,file) }
  end
  #writeSerialRecords("Data/items.dat",records)
  code="class PBItems\n#{constants}"
  code+="\ndef PBItems.getName(id)\nreturn pbGetMessage(MessageTypes::Items,id)\nend\n"
  code+="\ndef PBItems.getCount\nreturn #{records.length}\nend\n"
  code+="\ndef PBItems.maxValue\nreturn #{maxValue}\nend\nend"
  eval(code) if installRuntime
  if scriptOutput
    if scriptOutput=="Scripts/PBItems.rb"
      pbAddScript(code,"PBItems")
    else
      File.open(scriptOutput,"w"){|file| file.write(code) }
    end
  end
  Graphics.update if installRuntime
  return {:records=>records,:code=>code,:names=>itemnames,
          :descriptions=>itemdescs,:maxValue=>maxValue}
end

def pbConnectionSide(value)
  return nil if value.nil?
  sides={"n"=>"N","north"=>"N","e"=>"E","east"=>"E",
         "s"=>"S","south"=>"S","w"=>"W","west"=>"W"}
  return sides[value.to_s.strip.downcase]
end

def pbConnectionPoint(value,label,section=nil)
  AzurePBSValidation.required(value,label)
  values=value.to_s.split(",",-1)
  AzurePBSValidation.count(values,label,2,2)
  first=values[0].to_s.strip
  second=values[1].to_s.strip
  side=pbConnectionSide(first)
  if side
    offset=AzurePBSValidation.integer(second,_INTL("offset in {1}",label))
    return [side,offset]
  end
  x=AzurePBSValidation.integer(first,_INTL("X coordinate in {1}",label))
  y=AzurePBSValidation.integer(second,_INTL("Y coordinate in {1}",label))
  return [x,y]
end

def pbConnectionRecordKey(record)
  forward=record.collect {|value| "#{value.class}:#{value}" }.join("|")
  reverse=[record[3],record[4],record[5],record[0],record[1],record[2]].collect {|value|
     "#{value.class}:#{value}"
  }.join("|")
  return [forward,reverse].sort[0]
end

def pbValidateConnectionRecord(record,label,named=false)
  if named
    record[0]=AzurePBSValidation.integer(record[0],_INTL("Map1 in {1}",label),1,999)
    record[3]=AzurePBSValidation.integer(record[3],_INTL("Map2 in {1}",label),1,999)
    if record[0]==record[3]
      AzurePBSValidation.error(_INTL("{1} connects map {2} to itself.",label,record[0]))
    end
  end
  if !pbRgssExists?(sprintf("Data/Map%03d.rxdata",record[0])) &&
     !pbRgssExists?(sprintf("Data/Map%03d.rvdata",record[0]))
    print _INTL("Warning: Map {1}, as mentioned in the map\nconnection data, was not found.\n{2}",record[0],FileLineData.linereport)
  end
  if !pbRgssExists?(sprintf("Data/Map%03d.rxdata",record[3])) &&
     !pbRgssExists?(sprintf("Data/Map%03d.rvdata",record[3]))
    print _INTL("Warning: Map {1}, as mentioned in the map\nconnection data, was not found.\n{2}",record[3],FileLineData.linereport)
  end
  opposites={"N"=>"S","S"=>"N","E"=>"W","W"=>"E"}
  if opposites[record[1]] && record[4]!=opposites[record[1]]
    AzurePBSValidation.error(_INTL("The {1} side of the first map in {2} must connect to the {3} side of the second map.",
       record[1],label,opposites[record[1]]))
  end
  return record
end

def pbReadConnectionRecords(sourceFile="PBS/connections.txt")
  records=[]
  FileLineData.file=sourceFile
  if pbIsSectionedPBSFile(sourceFile)
    sectionKeys={}
    connectionKeys={}
    allowed=["Map1","Map1Point","Map2","Map2Point"]
    for section in pbAltPBSParseLegacySections(sourceFile)
      AzurePBSValidation.source(section)
      sectionID=AzurePBSValidation.required(section[:id],"Map connection section name").to_s.strip
      AzurePBSValidation.unique(sectionKeys,sectionID,"map connection section",section[:lineno])
      AzurePBSValidation.properties(section,allowed,"map connection")
      data=pbAltPBSFieldHash(section)
      for property in allowed
        AzurePBSValidation.source(section,property)
        AzurePBSValidation.required(data[property],_INTL("{1} in map connection {2}",property,sectionID))
      end
      AzurePBSValidation.source(section,"Map1")
      map1=AzurePBSValidation.integer(data["Map1"],_INTL("Map1 in map connection {1}",sectionID),1,999)
      AzurePBSValidation.source(section,"Map1Point")
      point1=pbConnectionPoint(data["Map1Point"],_INTL("Map1Point in map connection {1}",sectionID),section)
      AzurePBSValidation.source(section,"Map2")
      map2=AzurePBSValidation.integer(data["Map2"],_INTL("Map2 in map connection {1}",sectionID),1,999)
      AzurePBSValidation.source(section,"Map2Point")
      point2=pbConnectionPoint(data["Map2Point"],_INTL("Map2Point in map connection {1}",sectionID),section)
      record=[map1,point1[0],point1[1],map2,point2[0],point2[1]]
      pbValidateConnectionRecord(record,_INTL("map connection {1}",sectionID),true)
      AzurePBSValidation.unique(connectionKeys,pbConnectionRecordKey(record),
         "map connection record",section[:lineno])
      records.push(record)
    end
  else
    pbCompilerEachPreppedLine(sourceFile){|line,lineno|
       hashenum={
          "N"=>"N","North"=>"N",
          "E"=>"E","East"=>"E",
          "S"=>"S","South"=>"S",
          "W"=>"W","West"=>"W"
       }
       record=[]
       thisline=line.dup
       record.push(csvInt!(thisline,lineno))
       record.push(csvEnumFieldOrInt!(thisline,hashenum,"",sprintf("(line %d)",lineno)))
       record.push(csvInt!(thisline,lineno))
       record.push(csvInt!(thisline,lineno))
       record.push(csvEnumFieldOrInt!(thisline,hashenum,"",sprintf("(line %d)",lineno)))
       record.push(csvInt!(thisline,lineno))
       pbValidateConnectionRecord(record,_INTL("map connection on line {1}",lineno),false)
       records.push(record)
    }
  end
  return records
end

def pbCompileConnections(dataOutput="Data/connections.dat",installRuntime=true,
                         sourceFile="PBS/connections.txt")
  records=pbReadConnectionRecords(sourceFile)
  save_data(records,dataOutput)
  if installRuntime
    AzureDataCache.clear("Data/connections.dat") if defined?(AzureDataCache)
    MapFactoryHelper.clear if defined?(MapFactoryHelper) && MapFactoryHelper.respond_to?(:clear)
    Graphics.update
  end
  return records
end

def strsplit(str,re)
  ret=[]
  tstr=str
  while re=~tstr
    ret[ret.length]=$~.pre_match
    tstr=$~.post_match
  end
  ret[ret.length]=tstr if ret.length
  return ret
end

def canonicalize(c)
  return c
end

def pbGetConst(mod,item,err)
  isdef=false
  begin
    isdef=mod.const_defined?(item.to_sym)
    rescue
    raise sprintf(err,item)
  end
  raise sprintf(err,item) if !isdef
  return mod.const_get(item.to_sym)
end

def parseItem(item)
  clonitem=item.upcase
  clonitem.sub!(/^\s*/){}
  clonitem.sub!(/\s*$/){}
  return pbGetConst(PBItems,clonitem,
     _INTL("Undefined item constant name: %s\nName must consist only of letters, numbers, and\nunderscores and can't begin with a number.\nMake sure the item is defined in\nPBS/items.txt.\n{1}",
     FileLineData.linereport))
end

def parseSpecies(item)
  clonitem=item.upcase
  clonitem.gsub!(/^[\s\n]*/){}
  clonitem.gsub!(/[\s\n]*$/){}
  clonitem="NIDORANmA" if clonitem=="NIDORANMA"
  clonitem="NIDORANfE" if clonitem=="NIDORANFE"
  return pbGetConst(PBSpecies,clonitem,_INTL("Undefined species constant name: [%s]\nName must consist only of letters, numbers, and\nunderscores and can't begin with a number.\nMake sure the name is defined in\nPBS/pokemon.txt.\n{1}",FileLineData.linereport))
end

def parseMove(item)
  clonitem=item.upcase
  clonitem.sub!(/^\s*/){}
  clonitem.sub!(/\s*$/){}
  return pbGetConst(PBMoves,clonitem,_INTL("Undefined move constant name: %s\nName must consist only of letters, numbers, and\nunderscores and can't begin with a number.\nMake sure the name is defined in\nPBS/moves.txt.\n{1}",FileLineData.linereport))
end

def parseNature(item)
  clonitem=item.upcase
  clonitem.sub!(/^\s*/){}
  clonitem.sub!(/\s*$/){}
  return pbGetConst(PBNatures,clonitem,_INTL("Undefined nature constant name: %s\nName must consist only of letters, numbers, and\nunderscores and can't begin with a number.\nMake sure the name is defined in\nthe script section PBNatures.\n{1}",FileLineData.linereport))
end

def parseTrainer(item)
  clonitem=item.clone
  clonitem.sub!(/^\s*/){}
  clonitem.sub!(/\s*$/){}
  return pbGetConst(PBTrainers,clonitem,_INTL("Undefined Trainer constant name: %s\nName must consist only of letters, numbers, and\nunderscores and can't begin with a number.\nIn addition, the name must be defined\nin trainertypes.txt.\n{1}",FileLineData.linereport))
end

def pbFindScript(a,name)
  a.each{|i|
     next if !i
     return i if i[1]==name
  }
  return nil
end

def pbAddScript(script,sectionname)
  filename = "Scripts/" + sectionname + ".rb"
  File.open(filename,"w"){|f| f.write script}
end

def pbCompileEncounters(outputFile="Data/encounters.dat",installRuntime=true)
  if pbIsSectionedPBSFile("PBS/encounters.txt")
    FileLineData.file="PBS/encounters.txt"
    encounters={}
    mapKeys={}
    typeKeys={}
    thisenc=nil
    currentMapID=nil
    lastenctype=-1
    pbAltPBSReadLines("PBS/encounters.txt").each {|rawline|
      line=rawline[1].to_s.gsub(/\s+$/,"")
      next if line[/^\s*$/]
      next if line[/^\s*#/]
      FileLineData.setLine(line,rawline[0])
      if line[/^\s*\[\s*(\d+)(?:\s*,\s*\d+)?\s*\]\s*(?:#.*)?$/]
        AzurePBSValidation.encounter_map(thisenc,currentMapID)
        mapid=AzurePBSValidation.integer($~[1],"Encounter map ID",1,999)
        AzurePBSValidation.unique(mapKeys,mapid,"encounter map",rawline[0])
        thisenc=[EncounterTypes::EnctypeDensities.clone,[]]
        encounters[mapid]=thisenc
        currentMapID=mapid
        typeKeys={}
        lastenctype=-1
        next
      end
      cleanline=line.gsub(/\s+#.*$/,"")
      if cleanline[/^\s*([A-Za-z0-9_]+)(?:\s*,\s*(\d+))?\s*$/]
        raise _INTL("Encounter type header was defined before a map section.") if !thisenc
        typeName=$~[1]
        densityText=$~[2]
        lastenctype=findIndex(EncounterTypes::Names){|val| val==typeName}
        raise _INTL("Undefined encounter type {1}",typeName) if lastenctype<0
        AzurePBSValidation.unique(typeKeys,lastenctype,
           _INTL("encounter type for map {1}",currentMapID),rawline[0])
        thisenc[1][lastenctype]=[]
        if densityText
          if EncounterTypes::EnctypeCompileDens[lastenctype]==0
            AzurePBSValidation.error(_INTL("Encounter type {1} does not support a density value.",typeName))
          end
          thisenc[0][lastenctype]=AzurePBSValidation.integer(densityText,
             _INTL("Density for encounter type {1}",typeName),0,255)
        end
        next
      end
      if cleanline[/^\s*(\d+)\s*,\s*([^,]+)\s*,\s*(\d+)(?:\s*,\s*(\d+))?\s*$/]
        raise _INTL("Encounter data was defined before an encounter type header.") if lastenctype<0 || !thisenc
        weight=AzurePBSValidation.integer($~[1],"Encounter slot weight",1,100)
        species=parseSpecies($~[2])
        minlevel=AzurePBSValidation.integer($~[3],"Encounter minimum level",1,PBExperience::MAXLEVEL)
        maxlevel=$~[4] ? AzurePBSValidation.integer($~[4],"Encounter maximum level",1,PBExperience::MAXLEVEL) : minlevel
        if minlevel>maxlevel
          AzurePBSValidation.error(_INTL("Encounter minimum level {1} is greater than maximum level {2}.",minlevel,maxlevel))
        end
        slotindex=thisenc[1][lastenctype].length
        expectedSlots=EncounterTypes::EnctypeChances[lastenctype] || []
        if slotindex>=expectedSlots.length
          AzurePBSValidation.error(_INTL("Encounter type {1} has more than its required {2} slots.",
             EncounterTypes::Names[lastenctype],expectedSlots.length))
        end
        expected=expectedSlots[slotindex]
        if expected!=weight
          raise _INTL("Encounter weight {1} does not match the legacy slot weight {2} for {3}.",
             weight,expected,EncounterTypes::Names[lastenctype])
        end
        thisenc[1][lastenctype].push([species,minlevel,maxlevel])
        next
      end
      raise _INTL("Bad line syntax in encounters.txt: {1}",line)
    }
    AzurePBSValidation.encounter_map(thisenc,currentMapID)
    save_data(encounters,outputFile)
    pbInvalidateEncounterData if installRuntime && defined?(pbInvalidateEncounterData)
    return encounters
  end
  lines=[]
  linenos=[]
  FileLineData.file="PBS/encounters.txt"
  File.open("PBS/encounters.txt","rb"){|f|
     lineno=1
     f.each_line {|line|
        if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
          line=line[3,line.length-3]
        end
        line=prepline(line)
        if line.length!=0
          lines[lines.length]=line
          linenos[linenos.length]=lineno
        end
        lineno+=1
     }
  }
  encounters={}
  thisenc=nil
  lastenc=-1
  lastenclen=0
  needdensity=false
  lastmapid=-1
  mapKeys={}
  typeKeys={}
  i=0;
  while i<lines.length
    line=lines[i]
    FileLineData.setLine(line,linenos[i])
    mapid=line[/^\d+$/]
    if mapid
      AzurePBSValidation.encounter_map(thisenc,lastmapid)
      lastmapid=AzurePBSValidation.integer(mapid,"Encounter map ID",1,999)
      AzurePBSValidation.unique(mapKeys,lastmapid,"encounter map",linenos[i])
      thisenc=[EncounterTypes::EnctypeDensities.clone,[]]
      encounters[lastmapid]=thisenc
      typeKeys={}
      needdensity=true
      i+=1
      next
    end
    enc=findIndex(EncounterTypes::Names){|val| val==line}
    if enc>=0
      AzurePBSValidation.error("Encounter type header was defined before a map section.") if !thisenc
      AzurePBSValidation.unique(typeKeys,enc,
         _INTL("encounter type for map {1}",lastmapid),linenos[i])
      needdensity=false
      enclines=EncounterTypes::EnctypeChances[enc].length
      encarray=[]
      j=i+1; k=0
      while j<lines.length && k<enclines
        line=lines[j]
        FileLineData.setLine(lines[j],linenos[j])
        splitarr=strsplit(line,/\s*,\s*/)
        if !splitarr
          raise _INTL("In encounters.txt, expected a species entry line,\ngot \"{1}\" instead (probably too few entries in an encounter type).\nPlease check the format of the section numbered {2},\nwhich is just before this line.\n{3}",
             line,lastmapid,FileLineData.linereport)
        end
        AzurePBSValidation.count(splitarr,"Encounter slot",2,3)
        splitarr[2]=splitarr[1] if splitarr.length==2
        splitarr[1]=splitarr[1].to_i
        splitarr[2]=splitarr[2].to_i
        maxlevel=PBExperience::MAXLEVEL
        if splitarr[1]<=0 || splitarr[1]>maxlevel
          raise _INTL("Level number is not valid: {1}\n{2}",splitarr[1],FileLineData.linereport)
        end
        if splitarr[2]<=0 || splitarr[2]>maxlevel
          raise _INTL("Level number is not valid: {1}\n{2}",splitarr[2],FileLineData.linereport)
        end
        if splitarr[1]>splitarr[2]
          raise _INTL("Minimum level is greater than maximum level: {1}\n{2}",line,FileLineData.linereport)
        end
        splitarr[0]=parseSpecies(splitarr[0])
        linearr=splitarr
        encarray.push(linearr)
        thisenc[1][enc]=encarray
        j+=1
        k+=1
      end
      if j==lines.length && k<enclines
         raise _INTL("Reached end of file unexpectedly. There were too few entries in the last section, expected {1} entries.\nPlease check the format of the section numbered {2}.\n{3}",
            enclines,lastmapid,FileLineData.linereport)
      end
      i=j
    elsif needdensity
      needdensity=false
      nums=strsplit(line,/,/)
      if nums
        AzurePBSValidation.count(nums,"Encounter density list",3,3)
        for densityIndex in 0...nums.length
          nums[densityIndex]=AzurePBSValidation.integer(nums[densityIndex],
             "Encounter density",0,255)
        end
        for j in 0...EncounterTypes::EnctypeChances.length
          next if !EncounterTypes::EnctypeChances[j] ||
                  EncounterTypes::EnctypeChances[j].length==0
          next if EncounterTypes::EnctypeCompileDens[j]==0
          thisenc[0][j]=nums[EncounterTypes::EnctypeCompileDens[j]-1].to_i
        end
      else
        raise _INTL("Wrong syntax for densities in encounters.txt; got \"{1}\"\n{2}",line,FileLineData.linereport)
      end
      i+=1
    else
      raise _INTL("Undefined encounter type {1}, expected one of the following:\n{2}\n{3}",
         line,EncounterTypes::Names.inspect,FileLineData.linereport)
    end
  end
  AzurePBSValidation.encounter_map(thisenc,lastmapid)
  save_data(encounters,outputFile)
  pbInvalidateEncounterData if installRuntime && defined?(pbInvalidateEncounterData)
  return encounters
end

def pbCheckByte(x,valuename)
  if x<0 || x>255
    raise _INTL("The value \"{1}\" must be from 0 through 255 (0x00-0xFF in hex), got a value of {2}\n{3}",
       valuename,x,FileLineData.linereport)
  end
end

def pbCheckWord(x,valuename)
  if x<0 || x>65535
    raise _INTL("The value \"{1}\" must be from 0 through 65535 (0x0000-0xFFFF in hex), got a value of {2}\n{3}",
       valuename,x,FileLineData.linereport)
  end
end

def pbCheckSignedWord(x,valuename)
  if x<-32768 || x>32767
    raise _INTL("The value \"{1}\" must be from -32768 through 32767, got a value of {2}\n{3}",
       valuename,x,FileLineData.linereport)
  end
end

def pbCheckSignedByte(x,valuename)
  if x<-128 || x>127
    raise _INTL("The value \"{1}\" must be from -128 through 127, got a value of {2}\n{3}",
       valuename,x,FileLineData.linereport)
  end
end

def pbCompileMoves(dataOutput="Data/moves.dat",scriptOutput="Scripts/PBMoves.rb",
                   installRuntime=true,messagesOutput=nil)
  records=[]
  movenames=[]
  movedescs=[]
  movedata=[]
  movedata[0] = [0,0,0,0,0,0,0,0,0,0]
  maxValue=0
  if pbIsSectionedPBSFile("PBS/moves.txt")
    FileLineData.file="PBS/moves.txt"
    sections=pbAltPBSParseLegacySections("PBS/moves.txt")
    for section in sections
      next if !section[:id] || section[:id]==""
      label=_INTL("section [{1}]",section[:id])
      allowedFields=["LegacyMoveID","Name","Type","Category","Power","Accuracy",
                     "TotalPP","EffectChance","Priority","Description",
                     "LegacyFunctionCode","FunctionCode","LegacyTarget","Target",
                     "LegacyFlags","Flags"]
      AzurePBSValidation.properties(section,allowedFields,
         _INTL("move section [{1}]",section[:id]))
      data=pbAltPBSFieldHash(section)
      for required in ["LegacyMoveID","Name","Type","Category","Power","Accuracy",
                       "TotalPP","EffectChance","Priority"]
        if !data.has_key?(required)
          AzurePBSValidation.source(section)
          raise _INTL("Move section [{1}] is missing {2}.",section[:id],required)
        end
      end
      functionKeys=["LegacyFunctionCode","FunctionCode"].select {|key| data.has_key?(key) }
      targetKeys=["LegacyTarget","Target"].select {|key| data.has_key?(key) }
      flagKeys=["LegacyFlags","Flags"].select {|key| data.has_key?(key) }
      if functionKeys.length!=1
        AzurePBSValidation.source(section)
        raise _INTL("Move section [{1}] must define exactly one of LegacyFunctionCode or FunctionCode.",section[:id])
      end
      if targetKeys.length!=1
        AzurePBSValidation.source(section)
        raise _INTL("Move section [{1}] must define exactly one of LegacyTarget or Target.",section[:id])
      end
      if flagKeys.length>1
        AzurePBSValidation.source(section)
        raise _INTL("Move section [{1}] must not define both LegacyFlags and Flags.",section[:id])
      end
      raw=[data["LegacyMoveID"],section[:id],data["Name"],data[functionKeys[0]],
           data["Power"],data["Type"],data["Category"],data["Accuracy"],
           data["TotalPP"],data["EffectChance"],data[targetKeys[0]],data["Priority"],
           flagKeys.length==0 ? nil : data[flagKeys[0]],data["Description"]]
      record=AzurePBSValidation.move(raw,label,section)
      flags=pbAltPBSMoveFlagsToBitmask(record[12])
      pbCheckWord(record[3],_INTL("Function code"))
      pbCheckByte(record[4],_INTL("Base damage"))
      if record[6]==2 && record[4]!=0
        raise _INTL("Status moves must have a base damage of 0.")
      end
      if record[6]!=2 && record[4]==0
        record[6]=2
      end
      pbCheckByte(record[7],_INTL("Accuracy"))
      pbCheckByte(record[8],_INTL("Total PP"))
      pbCheckByte(record[9],_INTL("Additional Effect"))
      pbCheckWord(record[10],_INTL("Target"))
      pbCheckSignedByte(record[11],_INTL("Priority"))
      maxValue=[maxValue,record[0]].max
      movedata[record[0]]=[
        record[3],
        record[4],
        record[5],
        record[6],
        record[7],
        record[8],
        record[9],
        record[10],
        record[11],
        flags
      ]
      movenames[record[0]]=record[2]
      movedescs[record[0]]=record[13]
      records.push(record)
    end
  else
    pbCompilerEachPreppedLine("PBS/moves.txt"){|line,lineno|
        record=[]
        flags=0
        record=pbGetCsvRecord(line,lineno,[0,"vnsxueeuuuxiss",
          nil,nil,nil,nil,nil,PBTypes,["Physical","Special","Status"],
          nil,nil,nil,nil,nil,nil,nil])
        if line.to_s.gsub(/^\s+/,"").gsub(/\s+$/ ,"")!=""
          AzurePBSValidation.error(_INTL("Move row contains more than 14 CSV fields."))
        end
        record=AzurePBSValidation.move(record,_INTL("line {1}",lineno))
        pbCheckWord(record[3],_INTL("Function code"))
        flags|=1 if record[12][/a/]
        flags|=2 if record[12][/b/]
        flags|=4 if record[12][/c/]
        flags|=8 if record[12][/d/]
        flags|=16 if record[12][/e/]
        flags|=32 if record[12][/f/]
        flags|=64 if record[12][/g/]
        flags|=128 if record[12][/h/]
        flags|=256 if record[12][/i/]
        flags|=512 if record[12][/j/]
        flags|=1024 if record[12][/k/]
        flags|=2048 if record[12][/l/]
        flags|=4096 if record[12][/m/]
        flags|=8192 if record[12][/n/]
        flags|=16384 if record[12][/o/]
        flags|=32768 if record[12][/p/]
        pbCheckWord(record[3],_INTL("Function code"))
        pbCheckByte(record[4],_INTL("Base damage"))
        if record[6]==2 && record[4]!=0
          raise _INTL("Status moves must have a base damage of 0, use either Physical or Special\n{1}",FileLineData.linereport)
        end
        if record[6]!=2 && record[4]==0
          print _INTL(
            "Warning: Physical and special moves can't have a base damage of 0, changing to a Status move\n{1}",FileLineData.linereport)
          record[6]=2
        end
        pbCheckByte(record[7],_INTL("Accuracy"))
        pbCheckByte(record[8],_INTL("Total PP"))
        pbCheckByte(record[9],_INTL("Additional Effect"))
        pbCheckWord(record[10],_INTL("Target"))
        pbCheckSignedByte(record[11],_INTL("Priority"))
        maxValue=[maxValue,record[0]].max
        movedata[record[0]]=[                                             #movedata[fuckinpieceofshit][3]
          record[3],  # Function code
          record[4],  # Damage
          record[5],  # Type
          record[6],  # Category
          record[7],  # Accuracy
          record[8],  # Total PP
          record[9],  # Effect chance
          record[10], # Target
          record[11], # Priority
          flags,      # Flags
        ]
        movenames[record[0]]=record[2]  # Name
        movedescs[record[0]]=record[13] # Description
        records.push(record)
    }
  end
  pbValidateAzureLegacyDuplicates(:moves,records.map {|record| [record[0],record[1]] })
  #defaultdata=[0,0,0,0,0,0,0,0,0,0].pack("vCCCCCCvCv")
  $pkmn_move = movedata if installRuntime
  File.open(dataOutput,"wb"){|file|
     Marshal.dump(movedata,file)
  }
  if installRuntime
    MessageTypes.setMessages(MessageTypes::Moves,movenames)
    MessageTypes.setMessages(MessageTypes::MoveDescriptions,movedescs)
  end
  if messagesOutput
    messages=File.open("Data/messages.dat","rb"){|file| Marshal.load(file) }
    normalizedNames=[]
    normalizedDescriptions=[]
    for i in 0...movenames.length
      normalizedNames[i]=movenames[i] ? movenames[i] : ""
    end
    for i in 0...movedescs.length
      normalizedDescriptions[i]=movedescs[i] ? movedescs[i] : ""
    end
    messages[MessageTypes::Moves]=normalizedNames
    messages[MessageTypes::MoveDescriptions]=normalizedDescriptions
    File.open(messagesOutput,"wb"){|file| Marshal.dump(messages,file) }
  end
  code="class PBMoves\n"
  for rec in records
    code+="#{rec[1]}=#{rec[0]}\n"
  end
  code+="\ndef self.getName(id)\nreturn pbGetMessage(MessageTypes::Moves,id)\nend"
  code+="\ndef self.getCount\nreturn #{records.length}\nend"
  code+="\ndef self.maxValue\nreturn #{maxValue}\nend\nend"
  eval(code) if installRuntime
  if scriptOutput
    if scriptOutput=="Scripts/PBMoves.rb"
      pbAddScript(code,"PBMoves")
    else
      File.open(scriptOutput,"w"){|file| file.write(code) }
    end
  end
  if installRuntime
    PBMoveData.clear_cache if defined?(PBMoveData)
    AzureDataCache.clear("Data/moves.dat") if defined?(AzureDataCache)
  end
  return {:records=>records,:movedata=>movedata,:code=>code,
          :names=>movenames,:descriptions=>movedescs,:maxValue=>maxValue}
end

def pbCompileAbilities(scriptOutput="Scripts/PBAbilities.rb",
                       installRuntime=true,messagesOutput=nil)
  records=[]
  movenames=[]
  movedescs=[]
  maxValue=0
  if pbIsSectionedPBSFile("PBS/abilities.txt")
    FileLineData.file="PBS/abilities.txt"
    allowedFields=["LegacyAbilityID","Name","Description"]
    for section in pbAltPBSParseLegacySections("PBS/abilities.txt")
      AzurePBSValidation.properties(section,allowedFields,
         _INTL("ability section [{1}]",section[:id]))
      data=pbAltPBSFieldHash(section)
      for required in allowedFields
        if !data.has_key?(required)
          AzurePBSValidation.source(section)
          AzurePBSValidation.error(_INTL("Ability section [{1}] is missing {2}.",section[:id],required))
        end
      end
      record=AzurePBSValidation.ability(
         [data["LegacyAbilityID"],section[:id],data["Name"],data["Description"]],
         _INTL("section [{1}]",section[:id]),section)
      movenames[record[0]]=record[2]
      movedescs[record[0]]=record[3]
      maxValue=[maxValue,record[0]].max
      records.push(record)
    end
  else
    pbCompilerEachPreppedLine("PBS/abilities.txt"){|line,lineno|
       record=pbGetCsvRecord(line,lineno,[0,"vnss"])
       if line.to_s.gsub(/^\s+/,"").gsub(/\s+$/ ,"")!=""
         AzurePBSValidation.error(_INTL("Ability row contains more than 4 CSV fields."))
       end
       record=AzurePBSValidation.ability(record,_INTL("line {1}",lineno))
       movenames[record[0]]=record[2]
       movedescs[record[0]]=record[3]
       maxValue=[maxValue,record[0]].max
       records.push(record)
    }
  end
  pbValidateAzureLegacyDuplicates(:abilities,records.map {|record| [record[0],record[1]] })
  if installRuntime
    MessageTypes.setMessages(MessageTypes::Abilities,movenames)
    MessageTypes.setMessages(MessageTypes::AbilityDescs,movedescs)
  end
  if messagesOutput
    messages=File.open("Data/messages.dat","rb"){|file| Marshal.load(file) }
    normalizedNames=[]
    normalizedDescriptions=[]
    for i in 0...movenames.length
      normalizedNames[i]=movenames[i] ? movenames[i] : ""
    end
    for i in 0...movedescs.length
      normalizedDescriptions[i]=movedescs[i] ? movedescs[i] : ""
    end
    messages[MessageTypes::Abilities]=normalizedNames
    messages[MessageTypes::AbilityDescs]=normalizedDescriptions
    File.open(messagesOutput,"wb"){|file| Marshal.dump(messages,file) }
  end
  code="class PBAbilities\n"
  for rec in records
    code+="#{rec[1]}=#{rec[0]}\n"
    for abilityAlias in AZURE_LEGACY_ABILITY_ALIASES
      code+="#{abilityAlias[0]}=#{abilityAlias[1]}\n" if abilityAlias[1]==rec[0]
    end
  end
  code+="\ndef self.getName(id)\nreturn pbGetMessage(MessageTypes::Abilities,id)\nend"
  code+="\ndef self.getCount\nreturn #{maxValue}\nend\n"
  code+="\ndef self.maxValue\nreturn #{maxValue}\nend\nend\n"
  eval(code) if installRuntime
  if scriptOutput
    if scriptOutput=="Scripts/PBAbilities.rb"
      pbAddScript(code,"PBAbilities")
    else
      File.open(scriptOutput,"w"){|file| file.write(code) }
    end
  end
  PBAbilityData.clear_cache if installRuntime && defined?(PBAbilityData)
  return {:records=>records,:code=>code,:names=>movenames,
          :descriptions=>movedescs,:maxValue=>maxValue}
end

def pbExtractTrainers
  trainertypes=nil
  pbRgssOpen("Data/trainertypes.dat","rb"){|f|
     trainertypes=Marshal.load(f)
  }
  return if !trainertypes
  File.open("trainertypes.txt","wb"){|f|
     f.write(0xEF.chr)
     f.write(0xBB.chr)
     f.write(0xBF.chr)
     for i in 0...trainertypes.length
       next if !trainertypes[i]
       record=trainertypes[i]
       begin
         cnst=getConstantName(PBTrainers,record[0])
       rescue
         next
       end
       f.write(sprintf("%d,%s,%s,%d,%s,%s,%s,%s\n",
          record[0],csvquote(cnst),csvquote(record[2]),
          record[3],csvquote(record[4]),csvquote(record[5]),csvquote(record[6]),
          record[7] ? ["Male","Female","Mixed"][record[7]] : "Mixed"
       ))
     end
  }
end

def pbCompileTrainers(outputFiles=nil,installRuntime=true,messagesOutput=nil)
  outputFiles={} if !outputFiles
  trainerTypesOutput=outputFiles[:trainer_types] || "Data/trainertypes.dat"
  trainersOutput=outputFiles[:trainers] || "Data/trainers.dat"
  scriptOutput=outputFiles[:trainer_script] || "Scripts/PBTrainers.rb"
  trainerTypesFile=pbGetTrainerTypesPBSFilename
  FileLineData.file=trainerTypesFile
  # Trainer types
  records=[]
  trainernames=[]
  count=0
  maxValue=0
  if pbIsSectionedPBSFile(trainerTypesFile)
    allowedFields=["LegacyTrainerTypeID","Name","BaseMoney","BattleBGM",
                   "VictoryBGM","IntroBGM","Gender","SkillLevel"]
    for section in pbAltPBSParseLegacySections(trainerTypesFile)
      AzurePBSValidation.properties(section,allowedFields,
         _INTL("trainer type section [{1}]",section[:id]))
      data=pbAltPBSFieldHash(section)
      for required in ["LegacyTrainerTypeID","Name"]
        if !data.has_key?(required)
          AzurePBSValidation.source(section)
          AzurePBSValidation.error(_INTL("Trainer type section [{1}] is missing {2}.",section[:id],required))
        end
      end
      raw=[data["LegacyTrainerTypeID"],section[:id],data["Name"],data["BaseMoney"],
           data["BattleBGM"],data["VictoryBGM"],data["IntroBGM"],data["Gender"],data["SkillLevel"]]
      record=AzurePBSValidation.trainer_type(raw,_INTL("section [{1}]",section[:id]),section)
      trainernames[record[0]]=record[2]
      if records[record[0]]
        raise _INTL("Two trainer types have the same ID ({1}), which is not allowed.",record[0])
      end
      records[record[0]]=record
      maxValue=[maxValue,record[0]].max
    end
  else
    pbCompilerEachPreppedLine(trainerTypesFile){|line,lineno|
       record=pbGetCsvRecord(line,lineno,[0,"unsUSSSeU", # ID can be 0
          nil,nil,nil,nil,nil,nil,nil,{
          ""=>2,"Male"=>0,"M"=>0,"0"=>0,"Female"=>1,"F"=>1,"1"=>1,"Mixed"=>2,"X"=>2,"2"=>2
          },nil]
       )
       if line.to_s.gsub(/^\s+/,"").gsub(/\s+$/ ,"")!=""
         AzurePBSValidation.error(_INTL("Trainer type row contains more than 9 CSV fields."))
       end
       record=AzurePBSValidation.trainer_type(record,_INTL("line {1}",lineno))
       trainernames[record[0]]=record[2]
       if records[record[0]]
         raise _INTL("Two trainer types ({1} and {2}) have the same ID ({3}), which is not allowed.\n{4}",
            records[record[0]][1],record[1],record[0],FileLineData.linereport)
       end
       records[record[0]]=record
       maxValue=[maxValue,record[0]].max
    }
  end
  pbValidateAzureLegacyDuplicates(:trainer_types,records.compact.map {|record| [record[0],record[1]] })
  count=records.compact.length
  trainerTypeNames=trainernames.clone
  MessageTypes.setMessages(MessageTypes::TrainerTypes,trainerTypeNames) if installRuntime
  code="class PBTrainers\n"
  for rec in records
    next if !rec
    code+="#{rec[1]}=#{rec[0]}\n"
  end
  code+="\ndef self.getName(id)\nreturn pbGetMessage(MessageTypes::TrainerTypes,id)\nend"
  code+="\ndef self.getCount\nreturn #{count}\nend"
  code+="\ndef self.maxValue\nreturn #{maxValue}\nend\nend"
  eval(code) if installRuntime
  if scriptOutput
    if scriptOutput=="Scripts/PBTrainers.rb"
      pbAddScript(code,"PBTrainers")
    else
      File.open(scriptOutput,"w"){|file| file.write(code) }
    end
  end
  File.open(trainerTypesOutput,"wb"){|f|
     Marshal.dump(records,f)
  }
  # Individual trainers
  lines=[]
  linenos=[]
  FileLineData.file="PBS/trainers.txt"
  if pbIsSectionedPBSFile("PBS/trainers.txt")
    lines,linenos=pbAltPBSBuildLegacyTrainerLines("PBS/trainers.txt")
  else
    lineno=1
    File.open("PBS/trainers.txt","rb"){|f|
       f.each_line {|line|
          if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
            line=line[3,line.length-3]
          end
          line=prepline(line)
          if line!=""
            lines.push(line)
            linenos.push(lineno)
          end
          lineno+=1
       }
    }
  end
  nameoffset=0
  trainers=[]
  trainerKeys={}
  trainernames.clear
  i=0; loop do break unless i<lines.length
    FileLineData.setLine(lines[i],linenos[i])
    AzurePBSValidation.error(_INTL("Incomplete trainer record; expected trainer type, name/ID, and party data.")) if i+2>=lines.length
    trainername=parseTrainer(lines[i])
    FileLineData.setLine(lines[i+1],linenos[i+1])
    nameline=strsplit(lines[i+1],/\s*,\s*/)
    name=nameline[0]
    AzurePBSValidation.required(name,"Trainer name")
    raise _INTL("Trainer name too long\n{1}",FileLineData.linereport) if name.length>=0x10000
    trainernames.push(name)
    partyid=0
    if nameline[1] && nameline[1]!=""
      partyid=AzurePBSValidation.integer(nameline[1],"Trainer party ID",0,255)
    end
    trainerKey=[trainername,name,partyid]
    AzurePBSValidation.unique(trainerKeys,trainerKey,"trainer team",linenos[i])
    FileLineData.setLine(lines[i+2],linenos[i+2])
    items=strsplit(lines[i+2],/\s*,\s*/)
    items[0].gsub!(/^\s+/,"")   # Number of Pokémon
    numpoke=AzurePBSValidation.integer(items[0],"Trainer party size",1,6)
    AzurePBSValidation.error(_INTL("A Trainer can define at most 8 battle items.")) if items.length-1>8
    AzurePBSValidation.error(_INTL("Incomplete trainer party; expected {1} Pokemon rows.",numpoke)) if i+3+numpoke>lines.length
    realitems=[]
    for j in 1...items.length   # Items held by Trainer
      realitems.push(parseItem(items[j])) if items[j] && items[j]!=""
    end
    pkmn=[]
    for j in 0...numpoke
      FileLineData.setLine(lines[i+j+3],linenos[i+j+3])
      poke=strsplit(lines[i+j+3],/\s*,\s*/)
      begin
        # Species
        poke[TSPECIES]=parseSpecies(poke[TSPECIES])
      rescue
        raise _INTL("Expected a species name: {1}\n{2}",poke[0],FileLineData.linereport)
      end
      # Level
      poke[TPLEVEL]=poke[TPLEVEL].to_i
      raise _INTL("Bad level: {1} (must be from 1-{2})\n{3}",poke[TPLEVEL],
        PBExperience::MAXLEVEL,FileLineData.linereport) if poke[TPLEVEL]<=0 || poke[TPLEVEL]>PBExperience::MAXLEVEL
      # Held item
      if !poke[TPITEM] || poke[TPITEM]==""
        poke[TPITEM]=TPDEFAULTS[TPITEM]
      else
        poke[TPITEM]=parseItem(poke[TPITEM])
      end
      # Moves
      moves=[]
      for j in [TPMOVE1,TPMOVE2,TPMOVE3,TPMOVE4]
        moves.push(parseMove(poke[j])) if poke[j] && poke[j]!=""
      end
      for j in 0...4
        index=[TPMOVE1,TPMOVE2,TPMOVE3,TPMOVE4][j]
        if moves[j] && moves[j]!=0
          poke[index]=moves[j]
        else
          poke[index]=TPDEFAULTS[index]
        end
      end
      # Ability
      if !poke[TPABILITY] || poke[TPABILITY]==""
        poke[TPABILITY]=TPDEFAULTS[TPABILITY]
      else
        poke[TPABILITY]=poke[TPABILITY].to_i
        raise _INTL("Bad abilityflag: {1} (must be 0 or 1 or 2-5)\n{2}",poke[TPABILITY],FileLineData.linereport) if poke[TPABILITY]<0 || poke[TPABILITY]>5
      end
      # Gender
      if !poke[TPGENDER] || poke[TPGENDER]==""
        poke[TPGENDER]=TPDEFAULTS[TPGENDER]
      else
        if poke[TPGENDER]=="M"
          poke[TPGENDER]=0
        elsif poke[TPGENDER]=="F"
          poke[TPGENDER]=1
        else
          poke[TPGENDER]=poke[TPGENDER].to_i
          raise _INTL("Bad genderflag: {1} (must be M or F, or 0 or 1)\n{2}",poke[TPGENDER],FileLineData.linereport) if poke[TPGENDER]<0 || poke[TPGENDER]>1
        end
      end
      # Form
      if !poke[TPFORM] || poke[TPFORM]==""
        poke[TPFORM]=TPDEFAULTS[TPFORM]
      else
        poke[TPFORM]=poke[TPFORM].to_i
        raise _INTL("Bad form: {1} (must be 0 or greater)\n{2}",poke[TPFORM],FileLineData.linereport) if poke[TPFORM]<0
      end
      # Shiny
      if !poke[TPSHINY] || poke[TPSHINY]==""
        poke[TPSHINY]=TPDEFAULTS[TPSHINY]
      elsif poke[TPSHINY]=="shiny"
        poke[TPSHINY]=true
      else
        poke[TPSHINY]=csvBoolean!(poke[TPSHINY].clone)
      end
      # Nature
      if !poke[TPNATURE] || poke[TPNATURE]==""
        poke[TPNATURE]=TPDEFAULTS[TPNATURE]
      else
        poke[TPNATURE]=parseNature(poke[TPNATURE])
      end
      # IVs
      if !poke[TPIV] || poke[TPIV]==""
        poke[TPIV]=TPDEFAULTS[TPIV]
      else
        poke[TPIV]=poke[TPIV].to_i
        raise _INTL("Bad IV: {1} (must be from 0-31 (32 special case))\n{2}",poke[TPIV],FileLineData.linereport) if poke[TPIV]<0 || poke[TPIV]>32
      end
      # Happiness
      if !poke[TPHAPPINESS] || poke[TPHAPPINESS]==""
        poke[TPHAPPINESS]=TPDEFAULTS[TPHAPPINESS]
      else
        poke[TPHAPPINESS]=poke[TPHAPPINESS].to_i
        raise _INTL("Bad happiness: {1} (must be from 0-255)\n{2}",poke[TPHAPPINESS],FileLineData.linereport) if poke[TPHAPPINESS]<0 || poke[TPHAPPINESS]>255
      end
      # Nickname
      if !poke[TPNAME] || poke[TPNAME]==""
        poke[TPNAME]=TPDEFAULTS[TPNAME]
      else
        poke[TPNAME]=poke[TPNAME].to_s
        raise _INTL("Bad nickname: {1} (must be 1-20 characters)\n{2}",poke[TPNAME],FileLineData.linereport) if (poke[TPNAME].to_s).length>20
      end
      # Shadow
      if !poke[TPSHADOW] || poke[TPSHADOW]==""
        poke[TPSHADOW]=TPDEFAULTS[TPSHADOW]
      else
        poke[TPSHADOW]=csvBoolean!(poke[TPSHADOW].clone)
      end
      # Ball
      if !poke[TPBALL] || poke[TPBALL]==""
        poke[TPBALL]=TPDEFAULTS[TPBALL]
      else
        poke[TPBALL]=poke[TPBALL].to_i
        raise _INTL("Bad form: {1} (must be 0 or greater)\n{2}",poke[TPBALL],FileLineData.linereport) if poke[TPBALL]<0
      end
      # Pre Mega
      # Boss
      if !poke[TPBOSS] || poke[TPBOSS]==""
        poke[TPBOSS]=TPDEFAULTS[TPBOSS]
      else
        poke[TPBOSS]=poke[TPBOSS].to_sym
      end
      pkmn.push(poke)
    end
    i+=3+numpoke
    trainers.push([trainername,name,realitems,pkmn,partyid])
    nameoffset+=name.length
  end
  MessageTypes.setMessagesAsHash(MessageTypes::TrainerNames,trainernames) if installRuntime
  if messagesOutput
    messages=File.open("Data/messages.dat","rb"){|file| Marshal.load(file) }
    normalizedTrainerTypes=[]
    for i in 0...trainerTypeNames.length
      normalizedTrainerTypes[i]=trainerTypeNames[i] ? trainerTypeNames[i] : ""
    end
    messages[MessageTypes::TrainerTypes]=normalizedTrainerTypes
    messages[MessageTypes::TrainerNames]=Messages.createHash(MessageTypes::TrainerNames,trainernames)
    File.open(messagesOutput,"wb"){|file| Marshal.dump(messages,file) }
  end
  save_data(trainers,trainersOutput)
  if installRuntime
    PBTrainerTypeData.clear_cache if defined?(PBTrainerTypeData)
    AzureDataCache.clear("Data/trainertypes.dat") if defined?(AzureDataCache)
    AzureTrainerDataCache.replace(trainers) if defined?(AzureTrainerDataCache)
  end
  return {:trainer_types=>records,:trainers=>trainers,:code=>code,
          :trainer_type_names=>trainerTypeNames,:trainer_names=>trainernames,
          :count=>count,:maxValue=>maxValue}
end

def pbCompileBosses
  $bosscache = nil
  bossdata = {}
  # Remove existing constant if it exists to allow reloading
  Object.send(:remove_const, :BOSSINFOHASH) if Object.const_defined?(:BOSSINFOHASH)
  File.open("Scripts/BossInfo.rb"){|f| eval(f.read)}
  puts "Loaded #{BOSSINFOHASH.keys.length} bosses from BossInfo.rb"
  BOSSINFOHASH.each {|boss, data|
    bossdata[boss] = BossData.new(boss,data)
  }
  save_data(bossdata,"Data/bossdata.dat")
  puts "Boss data saved to Data/bossdata.dat (#{File.size("Data/bossdata.dat")} bytes)"
  AzureDataCache.clear("Data/bossdata.dat") if defined?(AzureDataCache)
  $bosscache = bossdata
end

def removeConstantValue(mod,value)
  for c in mod.constants
    if mod.const_get(c.to_sym)==value
      mod.send(:remove_const,c.to_sym)
    end
  end
end

def setConstantName(mod,value,name)
  for c in mod.constants
    if mod.const_get(c.to_sym)==value
      mod.send(:remove_const,c.to_sym)
    end
  end
  mod.const_set(name,value)
end

def getConstantName(mod,value) 
  for c in mod.constants
    return c if mod.const_get(c.to_sym)==value
  end
  raise _INTL("Value {1} not defined by a constant in {2}",value,mod.name) unless caller_locations[0].label == "pbPokemonBitmapFile"
end

def pbTMRS
  rstm=[:FOCUSPUNCH,:DRAGONCLAW,
     :WATERPULSE,:CALMMIND,:ROAR,:TOXIC,
     :HAIL,:BULKUP,:BULLETSEED,:HIDDENPOWER,
     :SUNNYDAY,:TAUNT,:ICEBEAM,:BLIZZARD,
     :HYPERBEAM,:LIGHTSCREEN,:PROTECT,
     :RAINDANCE,:GIGADRAIN,:SAFEGUARD,
     :FRUSTRATION,:SOLARBEAM,:IRONTAIL,
     :THUNDERBOLT,:THUNDER,:EARTHQUAKE,
     :RETURN,:DIG,:PSYCHIC,:SHADOWBALL,
     :BRICKBREAK,:DOUBLETEAM,:REFLECT,
     :SHOCKWAVE,:FLAMETHROWER,:SLUDGEBOMB,
     :SANDSTORM,:FIREBLAST,:ROCKTOMB,
     :AERIALACE,:TORMENT,:FACADE,:SECRETPOWER,
     :REST,:ENCHANT,:THIEF,:STEELWING,:SKILLSWAP,
     :SNATCH,:OVERHEAT,:CUT,:FLY,:SURF,:STRENGTH,
     :FLASH,:ROCKSMASH,:WATERFALL,:DIVE]
  ret=[]
  for i in 0...rstm.length
    ret.push((parseMove(rstm.to_s) rescue 0))
  end
  return ret
end

def pbCompileMachines(outputFile="Data/tm.dat")
  sectionname=nil
  sections=[]
  if safeExists?("PBS/tm.txt")
    FileLineData.file="PBS/tm.txt"
    sectionSymbols={}
    speciesSeen={}
    for rawline in pbAltPBSReadLines("PBS/tm.txt")
       lineno=rawline[0]
       line=rawline[1]
       FileLineData.setLine(line,lineno)
       if !line[/^\s*\#/] && !line[/^\s*$/]
         if line[/^\s*\[\s*(.*?)\s*\]\s*$/]
           symbol=AzurePBSValidation.constant_symbol($~[1],"TM move section")
           sectionname=parseMove(symbol)
           if sectionSymbols.has_key?(sectionname) && sectionSymbols[sectionname]!=symbol
             AzurePBSValidation.error(_INTL(
                "TM move sections {1} and {2} resolve to the same numeric move ID.",
                sectionSymbols[sectionname],symbol))
           end
           sectionSymbols[sectionname]=symbol
           sections[sectionname]=WordArray.new if !sections[sectionname]
           speciesSeen[sectionname]={} if !speciesSeen[sectionname]
         else
           if sectionname==nil
             AzurePBSValidation.error(_INTL(
                "Expected a [MOVE] section before TM compatibility entries."))
           end
           specieslist=AzurePBSValidation.tm_species_list(
              line,_INTL("Species compatibility list for {1}",sectionSymbols[sectionname]))
           for symbol in specieslist
             species=parseSpecies(symbol)
             next if speciesSeen[sectionname][species]
             speciesSeen[sectionname][species]=true
             sec=sections[sectionname]
             sec[sec.length]=species
           end
         end
       end
       if lineno%500==0
         Graphics.update
       end
       if lineno%50==0
         pbSetWindowText(_INTL("Processing line {1}",lineno))
       end
    end
  elsif safeExists?("Data/tmRS.dat")
    tmrs=pbTMRS()
    for i in 0...58
      next if !tmrs[i] || tmrs[i]==0
      sections[tmrs[i]]=[]
    end
    File.open("Data/tmRS.dat","rb"){|f|
       species=1
       while !f.eof?
         data=f.read(8)+"\0\0\0\0\0\0\0\0"
         for i in 0...58
           next if !tmrs[i] || tmrs[i]==0
           if (data[i>>3]&(1<<(i&7)))!=0
             sections[tmrs[i]].push(species)
           end
         end
         species+=1
       end
    }
  end
  save_data(sections,outputFile)
  return sections
end

def checkEnumField(ret,enumer)
  if enumer.is_a?(Module)
    begin
      if ret=="" || !enumer.const_defined?(ret)
        raise _INTL("Undefined value {1} in {2}\n{3}",ret,enumer.name,FileLineData.linereport)
      end
      rescue NameError
      raise _INTL("Incorrect value {1} in {2}\n{3}",ret,enumer.name,FileLineData.linereport)
    end
    return enumer.const_get(ret.to_sym)
  elsif enumer.is_a?(Symbol) || enumer.is_a?(String)
    enumer=Object.const_get(enumer.to_sym)
    begin
      if ret=="" || !enumer.const_defined?(ret)
        raise _INTL("Undefined value {1} in {2}\n{3}",ret,enumer.name,FileLineData.linereport)
      end
      rescue NameError
      raise _INTL("Incorrect value {1} in {2}\n{3}",ret,enumer.name,FileLineData.linereport)
    end
    return enumer.const_get(ret.to_sym)
  elsif enumer.is_a?(Array)
    idx=findIndex(enumer){|item| ret==item}
    if idx<0
      raise _INTL("Undefined value {1} (expected one of: {2})\n{3}",ret,enumer.inspect,FileLineData.linereport)
    end
    return idx
  elsif enumer.is_a?(Hash)
    value=enumer[ret]
    if value==nil
      raise _INTL("Undefined value {1} (expected one of: {2})\n{3}",ret,enumer.keys.inspect,FileLineData.linereport)
    end
    return value
  end
  raise _INTL("Enumeration not defined\n{1}",FileLineData.linereport)
end

def csvEnumField!(value,enumer,key,section)
  ret=csvfield!(value)
  return checkEnumField(ret,enumer)
end

def csvEnumFieldOrInt!(value,enumer,key,section)
  ret=csvfield!(value)
  if ret[/\-?\d+/]
    return ret.to_i
  end
  return checkEnumField(ret,enumer)
end

def pbEachFileSectionEx(f)
  lineno=1
  havesection=false
  sectionname=nil
  lastsection={}
  f.each_line {|line|
     if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
       line=line[3,line.length-3]
     end
     if !line[/^\#/] && !line[/^\s*$/]
       if line[/^\s*\[\s*(.*)\s*\]\s*$/]
         if havesection
           yield lastsection,sectionname
         end
         sectionname=$~[1]
         havesection=true
         lastsection={}
       else
        if sectionname==nil
          raise _INTL("Expected a section at the beginning of the file.  This error may also occur if the file was not saved in UTF-8.\n{1}",FileLineData.linereport)
        end
        if !line[/^\s*(\w+)\s*=\s*(.*)$/]
          raise _INTL("Bad line syntax (expected syntax like XXX=YYY)\n{1}",FileLineData.linereport)
        end
        r1=$~[1]
        r2=$~[2]
        lastsection[r1]=r2.gsub(/\s+$/,"")
      end
    end
    lineno+=1
    if lineno%1000==0
      Graphics.update
    end
    if lineno%100==0
      pbSetWindowText(_INTL("Processing line {1}",lineno))
    end
  }
  if havesection
    yield lastsection,sectionname
  end
end

def pbEachFileSection(f)
  pbEachFileSectionEx(f) {|section,name|
     if block_given? && name[/^\d+$/]
       yield section,name.to_i
     end
  }
end



class SignedWordArray
  include Enumerable

  def initialize(data=nil)
    if data
      @a=data.unpack("v*")
    else
      @a=[]
    end
  end

  def []=(i,value)
    @a[i]=value
  end

  def [](i)
    v=@a[i]
    return v<0x8000 ? v : -((~v)&0xFFFF)-1
  end

  def length;@a.length;end
  def size;@a.size;end

  def fillNils(length,value)
    for i in 0...length
      @a[i]=value if !@a[i]
    end
  end

  def each
    @a.each {|i| yield i}
  end

  def self._load(str)
    return self.new(str)
  end

  def _dump(depth=100)
    return @a.pack("v*")
  end
end



class ByteArray
  include Enumerable

  def initialize(data=nil)
    if data
      @a=data.unpack("C*")
    else
      @a=[]
    end
  end

  def []=(i,value)
    @a[i]=value
  end

  def [](i)
    return @a[i]
  end

  def length;@a.length;end
  def size;@a.size;end

  def fillNils(length,value)
    for i in 0...length
      @a[i]=value if !@a[i]
    end
  end

  def each
    @a.each {|i| yield i}
  end

  def self._load(str)
    return self.new(str)
  end

  def _dump(depth=100)
    return @a.pack("C*")
  end
end



class WordArray
  include Enumerable

  def initialize(data=nil)
    if data
      @a=data.unpack("v*")
    else
      @a=[]
    end
  end

  def []=(i,value)
    @a[i]=value
  end

  def [](i)
    return @a[i]
  end

  def length;@a.length;end
  def size;@a.size;end

  def fillNils(length,value)
    for i in 0...length
      @a[i]=value if !@a[i]
    end
  end

  def each
    @a.each {|i| yield i}
  end

  def self._load(str)
    return self.new(str)
  end

  def _dump(depth=100)
    return @a.pack("v*")
  end
end



def pbEachSection(f)
  lineno=1
  havesection=false
  sectionname=nil
  lastsection=[]
  f.each_line {|line|
     if lineno==1
       hasbom=false
       if line.respond_to?(:getbyte)
         hasbom=(line.bytesize>=3 && line.getbyte(0)==0xEF &&
                 line.getbyte(1)==0xBB && line.getbyte(2)==0xBF)
       else
         hasbom=(line[0]==0xEF && line[1]==0xBB && line[2]==0xBF)
       end
       if hasbom
         line=line.respond_to?(:byteslice) ? line.byteslice(3,line.bytesize-3) : line[3,line.length-3]
       end
     end
     if !line[/^\#/] && !line[/^\s*$/]
       if line[/^\s*\[\s*(.+?)\s*\]\s*$/]
         if havesection
           yield lastsection,sectionname
         end
         sectionname=$~[1]
         lastsection=[]
         havesection=true
       else
         if sectionname==nil
           raise _INTL("Expected a section at the beginning of the file (line {1}). Sections begin with '[name of section]'",lineno)
         end
         lastsection.push(line.gsub(/^\s+/,"").gsub(/\s+$/,""))
       end
     end
     lineno+=1
     if lineno%500==0
       Graphics.update
     end
  }
  if havesection
    yield lastsection,sectionname
  end
end

AZURE_TRAINER_LIST_PROPERTIES=["Trainers","Pokemon","Challenges"] if !defined?(AZURE_TRAINER_LIST_PROPERTIES)

def pbBattleFacilityRelativeFilename(value,label)
  filename=AzurePBSValidation.required(value,label).to_s.strip.gsub("\\","/")
  if filename[/^\//] || filename[/^[A-Za-z]:/] || filename.split("/").include?("..")
    AzurePBSValidation.error(_INTL("{1} must be a relative path inside the PBS directory; got {2}.",label,filename))
  end
  AzurePBSValidation.error(_INTL("{1} cannot name a directory.",label)) if filename[/\/$/]
  return filename
end

def pbBattleFacilitySourcePath(sourceDir,filename)
  base=sourceDir.to_s.gsub("\\","/").sub(/\/$/,"")
  return base=="" || base=="." ? filename : base+"/"+filename
end

def pbValidateTrainerLists(sourceFile="PBS/trainerlists.txt",sourceDir=nil)
  sourceDir=File.dirname(sourceFile) if !sourceDir
  FileLineData.file=sourceFile
  rawSections=pbAltPBSParseLegacySections(sourceFile)
  if rawSections.length==0
    FileLineData.setLine(nil,0)
    AzurePBSValidation.error("Battle-facility trainer lists must contain at least one section.")
  end
  lists=[]
  defaultLine=nil
  challengeKeys={}
  for section in rawSections
    FileLineData.file=sourceFile
    AzurePBSValidation.source(section)
    name=section[:id].to_s
    if name!="DefaultTrainerList" && name!="TrainerList"
      AzurePBSValidation.error(_INTL("Unknown battle-facility list section [{1}].",name))
    end
    if name=="DefaultTrainerList"
      if defaultLine
        AzurePBSValidation.error(_INTL("Duplicate DefaultTrainerList; the first definition is at line {1}.",defaultLine))
      end
      defaultLine=section[:lineno]
    end
    AzurePBSValidation.properties(section,AZURE_TRAINER_LIST_PROPERTIES,
      _INTL("battle-facility list section [{1}]",name))
    data=pbAltPBSFieldHash(section)
    AzurePBSValidation.source(section,"Trainers")
    trainerFile=pbBattleFacilityRelativeFilename(data["Trainers"],"Trainers file")
    AzurePBSValidation.source(section,"Pokemon")
    pokemonFile=pbBattleFacilityRelativeFilename(data["Pokemon"],"Pokemon file")
    challenges=[]
    if name!="DefaultTrainerList" && data["Challenges"]
      AzurePBSValidation.source(section,"Challenges")
      for challenge in data["Challenges"].to_s.split(",",-1)
        challenge=challenge.to_s.strip
        next if challenge==""
        AzurePBSValidation.unique(challengeKeys,challenge,"battle-facility challenge",section[:lineno])
        challenges.push(challenge)
      end
    end
    trainerPath=pbBattleFacilitySourcePath(sourceDir,trainerFile)
    pokemonPath=pbBattleFacilitySourcePath(sourceDir,pokemonFile)
    trainerResult=pbReadBTTrainerSource(trainerPath)
    pokemonResult=pbReadBTPokemonSource(pokemonPath)
    for trainerIndex in 0...trainerResult[:records].length
      for number in trainerResult[:records][trainerIndex][5]
        next if number<pokemonResult[:records].length
        FileLineData.file=trainerPath
        FileLineData.setLine("PokemonNos=#{trainerResult[:records][trainerIndex][5].join(',')}",
          trainerResult[:record_lines][trainerIndex])
        AzurePBSValidation.error(_INTL("PokemonNos entry {1} is outside the Pokemon dataset, which contains {2} records.",number,pokemonResult[:records].length))
      end
    end
    lists.push({
      :default=>(name=="DefaultTrainerList"),:lineno=>section[:lineno],
      :trainers_file=>trainerFile,:pokemon_file=>pokemonFile,
      :trainers_path=>trainerPath,:pokemon_path=>pokemonPath,
      :challenges=>challenges,:trainer_data=>trainerResult,
      :pokemon_data=>pokemonResult
    })
  end
  if !defaultLine
    FileLineData.file=sourceFile
    FileLineData.setLine(nil,0)
    AzurePBSValidation.error("Battle-facility trainer lists require exactly one DefaultTrainerList section.")
  end
  return lists
end

def pbTrainerListReferencedSources(sourceFile="PBS/trainerlists.txt",sourceDir=nil)
  return [] if !safeExists?(sourceFile)
  sourceDir=File.dirname(sourceFile) if !sourceDir
  ret=[]
  for section in pbAltPBSParseLegacySections(sourceFile)
    next if section[:id]!="DefaultTrainerList" && section[:id]!="TrainerList"
    data=pbAltPBSFieldHash(section)
    for pair in [["Trainers",data["Trainers"]],["Pokemon",data["Pokemon"]]]
      next if !pair[1] || pair[1].to_s.strip==""
      AzurePBSValidation.source(section,pair[0])
      filename=pbBattleFacilityRelativeFilename(pair[1],_INTL("{1} file",pair[0]))
      path=pbBattleFacilitySourcePath(sourceDir,filename)
      ret.push(path) if !ret.include?(path)
    end
  end
  return ret
end

def pbBattleFacilityMessageHash(messages,current=nil)
  ret=OrderedHash.new
  for message in messages
    next if !message
    key=Messages.stringToKey(message)
    value=(current && current[key] && current[key]==message) ? current[key] : message
    ret[key]=value
  end
  return ret
end

def pbMergeBattleFacilityMessageHash(messages,current)
  current=OrderedHash.new if !current
  for message in messages
    next if !message
    key=Messages.stringToKey(message)
    current[key]=message if !current[key] || current[key]!=message
  end
  return current
end

def pbCompileTrainerLists(dataOutput="Data/trainerlists.dat",installRuntime=true,
                          messagesOutput=nil,sourceFile="PBS/trainerlists.txt",
                          sourceDir=nil)
  if !safeExists?(sourceFile)
    if sourceFile=="PBS/trainerlists.txt"
      File.open(sourceFile,"wb"){|f|
        f.write(0xEF.chr); f.write(0xBB.chr); f.write(0xBF.chr)
        f.write("[DefaultTrainerList]\nTrainers=bttrainers.txt\nPokemon=btpokemon.txt\n")
      }
    else
      FileLineData.file=sourceFile
      FileLineData.setLine(nil,0)
      AzurePBSValidation.error(_INTL("Battle-facility list source {1} does not exist.",sourceFile))
    end
  end
  lists=pbValidateTrainerLists(sourceFile,sourceDir)
  sections=[]
  names=[]
  beginSpeech=[]
  winSpeech=[]
  loseSpeech=[]
  for list in lists
    trainers=list[:trainer_data][:records]
    pokemon=list[:pokemon_data][:records]
    sections.push([trainers,pokemon,list[:challenges],list[:trainers_file],
                   list[:pokemon_file],list[:default]])
    names.concat(list[:trainer_data][:names])
    beginSpeech.concat(list[:trainer_data][:begin_speech])
    winSpeech.concat(list[:trainer_data][:win_speech])
    loseSpeech.concat(list[:trainer_data][:lose_speech])
  end
  # Validation and reference checks finish before either compiled output is
  # replaced, so malformed authoring data cannot partially install.
  save_data(sections,dataOutput)
  if installRuntime
    MessageTypes.addMessagesAsHash(MessageTypes::TrainerNames,names)
    MessageTypes.setMessagesAsHash(MessageTypes::BeginSpeech,beginSpeech)
    MessageTypes.setMessagesAsHash(MessageTypes::EndSpeechWin,winSpeech)
    MessageTypes.setMessagesAsHash(MessageTypes::EndSpeechLose,loseSpeech)
    if defined?(pbInvalidateBTTrainerLists)
      pbInvalidateBTTrainerLists
    elsif defined?(AzureDataCache)
      AzureDataCache.clear("Data/trainerlists.dat")
    end
  end
  if messagesOutput
    messageDatabase=load_data("Data/messages.dat")
    messageDatabase[MessageTypes::TrainerNames]=pbMergeBattleFacilityMessageHash(
      names,messageDatabase[MessageTypes::TrainerNames])
    messageDatabase[MessageTypes::BeginSpeech]=pbBattleFacilityMessageHash(
      beginSpeech,messageDatabase[MessageTypes::BeginSpeech])
    messageDatabase[MessageTypes::EndSpeechWin]=pbBattleFacilityMessageHash(
      winSpeech,messageDatabase[MessageTypes::EndSpeechWin])
    messageDatabase[MessageTypes::EndSpeechLose]=pbBattleFacilityMessageHash(
      loseSpeech,messageDatabase[MessageTypes::EndSpeechLose])
    File.open(messagesOutput,"wb"){|file| Marshal.dump(messageDatabase,file) }
  end
  return {:lists=>sections,:source_lists=>lists,:names=>names,
          :begin_speech=>beginSpeech,:win_speech=>winSpeech,
          :lose_speech=>loseSpeech}
end

AZURE_PHONE_SECTIONS=[
  ["<Generics>",:generics],
  ["<BattleRequests>",:battleRequests],
  ["<GreetingsMorning>",:greetingsMorning],
  ["<GreetingsEvening>",:greetingsEvening],
  ["<Greetings>",:greetings],
  ["<Bodies1>",:bodies1],
  ["<Bodies2>",:bodies2]
] if !defined?(AZURE_PHONE_SECTIONS)

def pbValidatePhoneSections(sourceFile="PBS/phone.txt")
  FileLineData.file=sourceFile
  allowed={}
  for definition in AZURE_PHONE_SECTIONS; allowed[definition[0]]=true; end
  sections=[]
  sectionKeys={}
  current=nil
  for rawline in pbAltPBSReadLines(sourceFile)
    line=rawline[1]
    next if line[/^\#/] || line[/^\s*$/]
    if line[/^\s*\[\s*(.+?)\s*\]\s*$/]
      name=$~[1]
      FileLineData.setLine(line,rawline[0])
      AzurePBSValidation.known_property(name,allowed.keys,"phone section")
      AzurePBSValidation.unique(sectionKeys,name,"phone section",rawline[0])
      current={:id=>name,:lineno=>rawline[0],:messages=>[]}
      sections.push(current)
      next
    end
    if !current
      FileLineData.setLine(line,rawline[0])
      AzurePBSValidation.error(_INTL("Expected a phone section before message text."))
    end
    message=line.gsub(/^\s+/,"").gsub(/\s+$/,"")
    if message==""
      FileLineData.setLine(line,rawline[0])
      AzurePBSValidation.error(_INTL("Phone messages cannot be blank."))
    end
    current[:messages].push([rawline[0],message])
  end
  for definition in AZURE_PHONE_SECTIONS
    if !sectionKeys.has_key?(definition[0])
      FileLineData.setLine(nil,0)
      AzurePBSValidation.error(_INTL("Required phone section [{1}] is missing.",definition[0]))
    end
  end
  for section in sections
    if section[:messages].length==0
      FileLineData.setLine("[#{section[:id]}]",section[:lineno])
      AzurePBSValidation.error(_INTL("Phone section [{1}] must contain at least one message.",section[:id]))
    end
  end
  return sections
end

def pbMergePhoneMessageHash(messages,hash)
  hash=OrderedHash.new if !hash
  for message in messages
    next if !message
    key=Messages.stringToKey(message)
    # Avoid replacing equal strings: their encoding metadata is part of the
    # marshaled message database and must remain byte-stable.
    hash[key]=message if !hash[key] || hash[key]!=message
  end
  return hash
end

def pbCompilePhoneData(dataOutput="Data/phone.dat",installRuntime=true,
                       messagesOutput=nil,sourceFile="PBS/phone.txt")
  return nil if !safeExists?(sourceFile)
  sourceSections=pbValidatePhoneSections(sourceFile)
  fields={}
  for definition in AZURE_PHONE_SECTIONS; fields[definition[0]]=definition[1]; end
  database=PhoneDatabase.new
  messages=[]
  File.open(sourceFile,"rb"){|f|
     pbEachSection(f){|section,name|
        database.send("#{fields[name]}=",section)
        messages.concat(section)
     }
  }
  save_data(database,dataOutput)
  if installRuntime
    # Phone message hashes can contain legacy/localized keys not referenced by
    # the current source. Update active keys without discarding those entries.
    runtimeCurrent=true
    for message in messages
      if pbGetMessageFromHash(MessageTypes::PhoneMessages,message)!=message
        runtimeCurrent=false
        break
      end
    end
    MessageTypes.addMessagesAsHash(MessageTypes::PhoneMessages,messages) if !runtimeCurrent
    pbInvalidatePhoneData(database)
  end
  if messagesOutput
    messageDatabase=load_data("Data/messages.dat")
    messageDatabase[MessageTypes::PhoneMessages]=pbMergePhoneMessageHash(
      messages,messageDatabase[MessageTypes::PhoneMessages])
    File.open(messagesOutput,"wb"){|file| Marshal.dump(messageDatabase,file) }
  end
  return {:database=>database,:messages=>messages,:source_sections=>sourceSections}
end

def frozenArrayValue(arr)
  typestring=""
  for i in 0...arr.length
    if i>0
      typestring+=((i%20)==0) ? ",\n" : ","
    end
    typestring+=arr[i].to_s
  end
  return "["+typestring+"].freeze"
end

def pbWriteDefaultTypes
  if !safeExists?("PBS/types.txt")
    File.open("PBS/types.txt","w"){|f|
       f.write(0xEF.chr)
       f.write(0xBB.chr)
       f.write(0xBF.chr)
fx=<<END
[0]
Name=Normal
InternalName=NORMAL
Weaknesses=FIGHTING
Immunities=GHOST

[1]
Name=Fighting
InternalName=FIGHTING
Weaknesses=FLYING,PSYCHIC
Resistances=ROCK,BUG,DARK

[2]
Name=Flying
InternalName=FLYING
Weaknesses=ROCK,ELECTRIC,ICE
Resistances=FIGHTING,BUG,GRASS
Immunities=GROUND

[3]
Name=Poison
InternalName=POISON
Weaknesses=GROUND,PSYCHIC
Resistances=FIGHTING,POISON,BUG,GRASS

[4]
Name=Ground
InternalName=GROUND
Weaknesses=WATER,GRASS,ICE
Resistances=POISON,ROCK
Immunities=ELECTRIC

[5]
Name=Rock
InternalName=ROCK
Weaknesses=FIGHTING,GROUND,STEEL,WATER,GRASS
Resistances=NORMAL,FLYING,POISON,FIRE

[6]
Name=Bug
InternalName=BUG
Weaknesses=FLYING,ROCK,FIRE
Resistances=FIGHTING,GROUND,GRASS

[7]
Name=Ghost
InternalName=GHOST
Weaknesses=GHOST,DARK
Resistances=POISON,BUG
Immunities=NORMAL,FIGHTING

[8]
Name=Steel
InternalName=STEEL
Weaknesses=FIGHTING,GROUND,FIRE
Resistances=NORMAL,FLYING,ROCK,BUG,GHOST,STEEL,GRASS,PSYCHIC,ICE,DRAGON,DARK
Immunities=POISON

[9]
Name=???
InternalName=QMARKS
IsPseudoType=true

[10]
Name=Fire
InternalName=FIRE
IsSpecialType=true
Weaknesses=GROUND,ROCK,WATER
Resistances=BUG,STEEL,FIRE,GRASS,ICE

[11]
Name=Water
InternalName=WATER
IsSpecialType=true
Weaknesses=GRASS,ELECTRIC
Resistances=STEEL,FIRE,WATER,ICE

[12]
Name=Grass
InternalName=GRASS
IsSpecialType=true
Weaknesses=FLYING,POISON,BUG,FIRE,ICE
Resistances=GROUND,WATER,GRASS,ELECTRIC

[13]
Name=Electric
InternalName=ELECTRIC
IsSpecialType=true
Weaknesses=GROUND
Resistances=FLYING,STEEL,ELECTRIC

[14]
Name=Psychic
InternalName=PSYCHIC
IsSpecialType=true
Weaknesses=BUG,GHOST,DARK
Resistances=FIGHTING,PSYCHIC

[15]
Name=Ice
InternalName=ICE
IsSpecialType=true
Weaknesses=FIGHTING,ROCK,STEEL,FIRE
Resistances=ICE

[16]
Name=Dragon
InternalName=DRAGON
IsSpecialType=true
Weaknesses=ICE,DRAGON
Resistances=FIRE,WATER,GRASS,ELECTRIC

[17]
Name=Dark
InternalName=DARK
IsSpecialType=true
Weaknesses=FIGHTING,BUG
Resistances=GHOST,DARK
Immunities=PSYCHIC

END
       f.write(fx)
    }
  end
end

def pbCompileTypes(dataOutput="Data/types.dat",scriptOutput="Scripts/PBTypes.rb",
                   installRuntime=true,messagesOutput=nil)
  pbWriteDefaultTypes
  typechart=[]
  types=[]
  typeIDs={}
  typeSymbols={}
  typeSections={}
  FileLineData.file="PBS/types.txt"
  for section in pbAltPBSParseLegacySections("PBS/types.txt")
    type=AzurePBSValidation.type(section)
    AzurePBSValidation.source(section)
    AzurePBSValidation.unique(typeIDs,type[0],"type ID",section[:lineno])
    AzurePBSValidation.source(section,"InternalName")
    AzurePBSValidation.unique(typeSymbols,type[2],"internal type symbol",section[:lineno])
    types[type[0]]=type
    typeSections[type[0]]=section
  end
  types.compact!
  maxValue=0
  for type in types; maxValue=[maxValue,type[0]].max; end
  pseudotypes=[]
  specialtypes=[]
  typenames=[]
  typeinames=[]
  typehash={}
  for type in types
    pseudotypes.push(type[0]) if type[3]
    typenames[type[0]]=type[1]
    typeinames[type[0]]=type[2]
    typehash[type[0]]=type
  end
  for type in types
    n=type[1]
    relationKeys=["Weaknesses","Resistances","Immunities"]
    for i in 0...relationKeys.length
      for relatedType in type[5+i]
        next if typeinames.include?(relatedType)
        AzurePBSValidation.source(typeSections[type[0]],relationKeys[i])
        AzurePBSValidation.error(_INTL("'{1}' is not a defined type ({2}, {3}).",
           relatedType,n,relationKeys[i]))
      end
    end
  end
  for i in 0..maxValue
    pseudotypes.push(i) if !typehash[i]
  end
  pseudotypes.sort!
  for type in types; specialtypes.push(type[0]) if type[4]; end
  specialtypes.sort!
  MessageTypes.setMessages(MessageTypes::Types,typenames) if installRuntime
  if messagesOutput
    messages=File.open("Data/messages.dat","rb"){|file| Marshal.load(file) }
    normalizedNames=[]
    for i in 0...typenames.length
      normalizedNames[i]=typenames[i] ? typenames[i] : ""
    end
    messages[MessageTypes::Types]=normalizedNames
    File.open(messagesOutput,"wb"){|file| Marshal.dump(messages,file) }
  end
  code="class PBTypes\n"
  for type in types
    code+="#{type[2]}=#{type[0]}\n"
  end
  code+="def PBTypes.getCount; return #{types.length}; end\n"
  code+="def PBTypes.maxValue; return #{maxValue}; end\n"
  code+="def PBTypes.getName(id)\nreturn pbGetMessage(MessageTypes::Types,id)\nend\n"
  count=maxValue+1
  for i in 0...count
    type=typehash[i]
    j=0; k=i; while j<count
      typechart[k]=2
      atype=typehash[j]
      if type && atype
        typechart[k]=4 if type[5].include?(atype[2]) # weakness
        typechart[k]=1 if type[6].include?(atype[2]) # resistance
        typechart[k]=0 if type[7].include?(atype[2]) # immune
      end
      j+=1
      k+=count
    end
  end
  code+="end\n"
  eval(code) if installRuntime
  save_data([pseudotypes,specialtypes,typechart],dataOutput)
  if scriptOutput
    if scriptOutput=="Scripts/PBTypes.rb"
      pbAddScript(code,"PBTypes")
    else
      File.open(scriptOutput,"w"){|file| file.write(code) }
    end
  end
  if installRuntime
    PBTypes.class_variable_set(:@@TypeData,nil) rescue nil
    PBTypeData.clear_cache if defined?(PBTypeData)
    Graphics.update
  end
  return {:types=>types,:pseudotypes=>pseudotypes,
          :specialtypes=>specialtypes,:typechart=>typechart,:code=>code,
          :names=>typenames,:maxValue=>maxValue}
end

def pbCompilePokemonData(outputFiles=nil,installRuntime=true,messagesOutput=nil)
  outputFiles={} if !outputFiles
  metricsOutput=outputFiles[:metrics] || "Data/metrics.dat"
  regionalsOutput=outputFiles[:regionals] || "Data/regionals.dat"
  evolutionsOutput=outputFiles[:evolutions] || "Data/evolutions.dat"
  dexdataOutput=outputFiles[:dexdata] || "Data/dexdata.dat"
  eggmovesOutput=outputFiles[:eggmoves] || "Data/eggEmerald.dat"
  movesOutput=outputFiles[:moves] || "Data/attacksRS.rxdata"
  scriptOutput=outputFiles[:species_script] || "Scripts/PBSpecies.rb"
  sections=[]
  requiredtypes={
     "Name"=>[0,"s"],
     "Kind"=>[0,"s"],
     "InternalName"=>[0,"c"],
     "Pokedex"=>[0,"S"],
     "Moves"=>[0,"*uE",nil,PBMoves],
     "Color"=>[1,"e",["Red","Blue","Yellow","Green","Black","Brown","Purple","Gray","White","Pink"]],
     "Type1"=>[3,"e",PBTypes],
     "BaseStats"=>[5,"uuuuuu"],
     "Rareness"=>[6,"u"],
     "GenderRate"=>[7,"e",{"AlwaysMale"=>0,"FemaleOneEighth"=>31,
        "Female25Percent"=>63,"Female50Percent"=>127,"Female75Percent"=>191,
        "FemaleSevenEighths"=>223,"AlwaysFemale"=>254,"Genderless"=>255}],
     "Happiness"=>[8,"u"],
     "GrowthRate"=>[9,"e",{"Medium"=>0,"MediumFast"=>0,"Erratic"=>1,
        "Fluctuating"=>2,"Parabolic"=>3,"MediumSlow"=>3,"Fast"=>4,"Slow"=>5}],
     "StepsToHatch"=>[10,"w"],
     "EffortPoints"=>[11,"uuuuuu"],
     "Compatibility"=>[13,"eg",{"1"=>1,"Monster"=>1,"2"=>2,"Water1"=>2,"Water 1"=>2,
        "3"=>3,"Bug"=>3,"4"=>4,"Flying"=>4,"5"=>5,"Field"=>5,"Ground"=>5,"6"=>6,
        "Fairy"=>6,"7"=>7,"Grass"=>7,"Plant"=>7,"8"=>8,"Human-like"=>8,"Human-Like"=>8,
        "Humanlike"=>8,"HumanLike"=>8,"Humanoid"=>8,"Humanshape"=>8,"Human"=>8,"9"=>9,"Water3"=>9,
        "Water 3"=>9,"10"=>10,"Mineral"=>10,"11"=>11,"Amorphous"=>11,"Indeterminate"=>11,
        "12"=>12,"Water2"=>12,"Water 2"=>12,"13"=>13,"Ditto"=>13,"14"=>14,"Dragon"=>14,
        "15"=>15,"Undiscovered"=>15,"No eggs"=>15,"NoEggs"=>15,"None"=>15,"NA"=>15},
        {"1"=>1,"Monster"=>1,"2"=>2,"Water1"=>2,"Water 1"=>2,
        "3"=>3,"Bug"=>3,"4"=>4,"Flying"=>4,"5"=>5,"Field"=>5,"Ground"=>5,"6"=>6,
        "Fairy"=>6,"7"=>7,"Grass"=>7,"Plant"=>7,"8"=>8,"Human-like"=>8,"Human-Like"=>8,
        "Humanlike"=>8,"HumanLike"=>8,"Humanoid"=>8,"Humanshape"=>8,"Human"=>8,"9"=>9,"Water3"=>9,
        "Water 3"=>9,"10"=>10,"Mineral"=>10,"11"=>11,"Amorphous"=>11,"Indeterminate"=>11,
        "12"=>12,"Water2"=>12,"Water 2"=>12,"13"=>13,"Ditto"=>13,"14"=>14,"Dragon"=>14,
        "15"=>15,"Undiscovered"=>15,"No eggs"=>15,"NoEggs"=>15,"None"=>15,"NA"=>15}],
     #"Compatibility"=>[31,"uu"],
     "Height"=>[14,"f"],
     "Weight"=>[15,"f"],
     "BaseEXP"=>[16,"w"],
  }
  optionaltypes={
     "BattlerPlayerY"=>[0,"i"],
     "BattlerEnemyY"=>[0,"i"],
     "BattlerAltitude"=>[0,"i"],
     "EggMoves"=>[0,"*E",PBMoves],
     "FormNames"=>[0,"S"],
     "RegionalNumbers"=>[0,"*w"],
     "Evolutions"=>[0,"*ses",nil,PBEvolution],
     "Habitat"=>[2,"e",["","Grassland","Forest","WatersEdge","Sea","Cave","Mountain","RoughTerrain","Urban","Rare"]],
     "Type2"=>[4,"e",PBTypes],
     "Abilities"=>[12,"eg",PBAbilities,PBAbilities],
     "HiddenAbility"=>[17,"e",PBAbilities],
     "WildItemCommon"=>[18,"*E",PBItems],
     "WildItemUncommon"=>[19,"*E",PBItems],
     "WildItemRare"=>[20,"*E",PBItems]
  }
  currentmap=-1
  dexdatas=[]
  eggmoves=[]
  entries=[]
  kinds=[]
  speciesnames=[]
  moves=[]
  evolutions=[]
  regionals=[]
  formnames=[]
  metrics=[SignedWordArray.new,SignedWordArray.new,SignedWordArray.new]
  constants=""
  speciesConstants={}
  maxValue=0
  pokemonsections=[]
  if pbUsesAltPokemonPBS("PBS/pokemon.txt")
    pokemonsections=pbAltPBSBuildLegacyPokemonSections("PBS/pokemon.txt","PBS/pokemon_metrics.txt","PBS/regional_dexes.txt")
  else
    File.open("PBS/pokemon.txt","rb"){|f|
      FileLineData.file="PBS/pokemon.txt"
      pbEachFileSection(f){|lastsection,currentmap| pokemonsections.push([lastsection,currentmap]) }
    }
  end
  duplicatePairs=[]
  for pokemonsection in pokemonsections
    internalName=pokemonsection[0]["InternalName"]
    duplicatePairs.push([pokemonsection[1],internalName]) if internalName && internalName!=""
  end
  pbValidateAzureLegacyDuplicates(:pokemon,duplicatePairs)
  FileLineData.file="PBS/pokemon.txt"
  for pokemonsection in pokemonsections
    lastsection=pokemonsection[0]
    currentmap=pokemonsection[1]
      dexdata=[0,0,0,0,0,[0,0,0,0,0,0],0,0,0,0,0,[0,0,0,0,0,0],[0,0],[0,0],0,0,0,0,0,0,0,0] #just initialize the whole fuckin thing
      thesemoves=[]
      theseevos=[]
      if (!lastsection["Type2"] || lastsection["Type2"]=="") && (!lastsection["Type1"] || lastsection["Type1"]=="")
        raise _INTL("No Pokemon type is defined in section {1} (PBS/pokemon.txt)",currentmap)
      end
      lastsection["Type2"]=lastsection["Type1"].clone if (!lastsection["Type2"] || lastsection["Type2"]=="") &&
                                                           lastsection["Type1"] && lastsection["Type1"]!=""
      if false && (!lastsection["Type2"] || lastsection["Type2"]=="")
        lastsection["Type2"]=lastsection["Type1"].clone if lastsection["Type1"] && lastsection["Type1"]!=""
        if !lastsection["Type1"] || lastsection["Type1"]==""
          raise _INTL("No Pokémon type is defined in section {2} (PBS/pokemon.txt)",key,sectionDisplay) if hash==requiredtypes
          next
        end
        lastsection["Type2"]=lastsection["Type1"].clone
      end
      [requiredtypes,optionaltypes].each{|hash|
        for key in hash.keys
          FileLineData.setSection(currentmap,key,lastsection[key])
          maxValue=[maxValue,currentmap].max
          sectionDisplay=currentmap.to_s
          next if hash[key][0]<0
          if currentmap==0
            raise _INTL("A Pokemon species can't be numbered 0 (PBS/pokemon.txt)")
          end
          if !lastsection[key] || lastsection[key]==""
            raise _INTL("Required entry {1} is missing or empty in section {2} (PBS/pokemon.txt)",key,sectionDisplay) if hash==requiredtypes
            next
          end
          secvalue=lastsection[key]
          rtschema=hash[key]
          schema=hash[key][1]
          valueindex=0
          loop do
            sublist=-1
            check = false
            for i in 0...schema.length
              next if schema[i,1]=="*"
              sublist+=1
              minus1=(schema[0,1]=="*") ? -1 : 0
              if schema[i,1]=="g" && secvalue==""
                if key=="Compatibility"
                  dexdata[rtschema[0]][sublist]=dexdata[rtschema[0]][sublist-1]
                end
                break
              end
              case schema[i,1]
                when "e", "g"
                  value=csvEnumField!(secvalue,rtschema[2+i+minus1],key,sectionDisplay)
                when "E"
                  value=csvEnumField!(secvalue,rtschema[2+i+minus1],key,sectionDisplay)
                when "i"
                  value=csvInt!(secvalue,key)
                when "u"
                  value=csvPosInt!(secvalue,key)
                when "w"
                  value=csvPosInt!(secvalue,key)
                when "f"
                  value=csvFloat!(secvalue,key,sectionDisplay)
                  value=(value*10).round
                  if value<=0
                    raise _INTL("Value '{1}' can't be less than or close to 0 (section {2}, PBS/pokemon.txt)",key,currentmap)
                  end
                when "c", "s"
                  value=csvfield!(secvalue)
                when "S"
                  value=secvalue
                  secvalue=""
              end
              if key=="BaseStats" || key=="EffortPoints"
                dexdata[rtschema[0]][sublist]=value
              elsif key=="Abilities" || key=="Compatibility"
                dexdata[rtschema[0]][sublist]=value || 0
              elsif key=="EggMoves"
                eggmoves[currentmap]=[] if !eggmoves[currentmap]
                eggmoves[currentmap].push(value)
              elsif key=="Moves"
                thesemoves.push(value)
              elsif key=="RegionalNumbers"
                regionals[valueindex]=[] if !regionals[valueindex]
                regionals[valueindex][currentmap]=value
              elsif key=="Evolutions"
                theseevos.push(value)
              elsif key=="InternalName"
                raise _INTL("Invalid internal name: {1} (section {2}, PBS/pokemon.txt)",value,currentmap) if !value[/^(?![0-9])\w*$/]
                constants+="#{value}=#{currentmap}\n"
                speciesConstants[value]=currentmap
              elsif key=="Kind"
                raise _INTL("Kind {1} is greater than 20 characters long (section {2}, PBS/pokemon.txt)",value,currentmap) if value.length>20
                kinds[currentmap]=value
              elsif key=="Pokedex"
                entries[currentmap]=value
              elsif key=="BattlerPlayerY"
                pbCheckSignedWord(value,key)
                metrics[0][currentmap]=value
              elsif key=="BattlerEnemyY"
                pbCheckSignedWord(value,key)
                metrics[1][currentmap]=value
              elsif key=="BattlerAltitude"
                pbCheckSignedWord(value,key)
                metrics[2][currentmap]=value
              elsif key=="Name"
                raise _INTL("Species name {1} is greater than 20 characters long (section {2}, PBS/pokemon.txt)",value,currentmap) if value.length>20
                speciesnames[currentmap]=value
              elsif key=="FormNames"
                formnames[currentmap]=value
              else
                dexdata[rtschema[0]]=value
              end
              valueindex+=1
            end
            break if secvalue==""
            break if schema[0,1]!="*"
          end
        end
      }
      movelist=[]
      evolist=[]
      for i in 0...thesemoves.length/2
        movelist.push([thesemoves[i*2],thesemoves[i*2+1],i])
      end
      movelist.sort!{|a,b| a[0]==b[0] ? a[2]<=>b[2] : a[0]<=>b[0]}
      for i in movelist; i.pop; end
      for i in 0...theseevos.length/3
        evolist.push([theseevos[i*3],theseevos[i*3+1],theseevos[i*3+2]])
      end
      moves[currentmap]=movelist
      evolutions[currentmap]=evolist
      dexdatas[currentmap]=dexdata
  end
  if dexdatas.length==0
    raise _INTL("No Pokémon species are defined in pokemon.txt")
  end
  count=dexdatas.compact.length
  code="module PBSpecies\n#{constants}"
  for i in 0...speciesnames.length
    speciesnames[i]="????????" if !speciesnames[i]
  end
  code+="def PBSpecies.getName(id)\nreturn pbGetMessage(MessageTypes::Species,id)\nend\n"
  code+="def PBSpecies.getCount\nreturn #{count}\nend\n"
  code+="def PBSpecies.maxValue\nreturn #{maxValue}\nend\nend"
  eval(code) if installRuntime
  if scriptOutput=="Scripts/PBSpecies.rb"
    pbAddScript(code,"PBSpecies")
  else
    File.open(scriptOutput,"w"){|file| file.write(code) }
  end
  resolveSpecies=proc {|value,label|
    symbol=value.to_s.upcase.gsub(/^\s+|\s+$/,'')
    symbol="NIDORANmA" if symbol=="NIDORANMA" && speciesConstants.has_key?("NIDORANmA")
    symbol="NIDORANfE" if symbol=="NIDORANFE" && speciesConstants.has_key?("NIDORANfE")
    id=speciesConstants[symbol]
    if id.nil?
      raise _INTL("Undefined species constant name: {1} ({2}, PBS/pokemon.txt)",value,label)
    end
    id
  }
  for e in 0...evolutions.length
    evolist=evolutions[e]
    next if !evolist
    for i in 0...evolist.length
      FileLineData.setSection(i,"Evolutions","")
      evonib=evolist[i][1]
      evolist[i][0]=resolveSpecies.call(evolist[i][0],"Evolutions")
      case PBEvolution::EVOPARAM[evonib]
        when 1
          evolist[i][2]=csvPosInt!(evolist[i][2])
        when 2
          evolist[i][2]=csvEnumField!(evolist[i][2],PBItems,"Evolutions",i)
        when 3
          evolist[i][2]=csvEnumField!(evolist[i][2],PBMoves,"Evolutions",i)
        when 4
          evolist[i][2]=resolveSpecies.call(evolist[i][2],"Evolutions")
        when 5
          evolist[i][2]=csvEnumField!(evolist[i][2],PBTypes,"Evolutions",i)
        else
          evolist[i][2]=0
      end
      evolist[i][3]=0
    end
  end
  _EVODATAMASK=0xC0
  _EVONEXTFORM=0x00
  _EVOPREVFORM=0x40
  for e in 0...evolutions.length
    evolist=evolutions[e]
    next if !evolist
    parent=nil
    child=-1
    for f in 0...evolutions.length
      evolist=evolutions[f]
      next if !evolist || e==f
      for g in evolist
        if g[0]==e && (g[3]&_EVODATAMASK)==_EVONEXTFORM
          parent=g
          child=f
          break
        end
      end
      break if parent
    end
    if parent
      evolutions[e]=[[child,parent[1],parent[2],_EVOPREVFORM]].concat(evolutions[e])
    end
  end
  metrics[0].fillNils(dexdatas.length,0) # player Y
  metrics[1].fillNils(dexdatas.length,0) # enemy Y
  metrics[2].fillNils(dexdatas.length,0) # altitude
  save_data(metrics,metricsOutput)
  # Write regionals.dat in binary format expected by pbAllRegionalSpecies/pbGetRegionalNumber
  # Format: numRegions (2 bytes), numDexDatas (2 bytes), then for each region,
  # numDexDatas entries where each entry is the regional dex number for that national species
  File.open(regionalsOutput,"wb"){|f|
    numRegions = regionals.length
    numDexDatas = maxValue + 1  # Need entries for species 0..maxValue
    f.fputw(numRegions)
    f.fputw(numDexDatas)
    for regionIndex in 0...numRegions
      regionData = regionals[regionIndex] || []
      for speciesIndex in 0...numDexDatas
        regionalNum = regionData[speciesIndex] || 0
        f.fputw(regionalNum)
      end
    end
  }
  File.open(evolutionsOutput,"wb"){|f|
     mx=[maxValue,evolutions.length-1].max
     offset=mx*8
     for i in 1..mx
       f.fputdw(offset)
       f.fputdw(evolutions[i] ? evolutions[i].length*5 : 0)
       offset+=evolutions[i] ? evolutions[i].length*5 : 0
     end
     for i in 1..mx
       next if !evolutions[i]
       for j in evolutions[i]
         f.fputb(j[3]|j[1])
         f.fputw(j[2])
         f.fputw(j[0])
       end
     end
  }
  $pkmn_dex = dexdatas if installRuntime
  File.open(dexdataOutput,"wb"){|f|
    Marshal.dump(dexdatas,f)
  }
  $pkmn_egg = eggmoves if installRuntime
  File.open(eggmovesOutput,"wb"){|f|
    Marshal.dump(eggmoves,f)
  }
  if installRuntime
    MessageTypes.setMessages(MessageTypes::Species,speciesnames)
    MessageTypes.setMessages(MessageTypes::Kinds,kinds)
    MessageTypes.setMessages(MessageTypes::Entries,entries)
    MessageTypes.setMessages(MessageTypes::FormNames,formnames)
  end
  if messagesOutput
    messages=File.open("Data/messages.dat","rb"){|file| Marshal.load(file) }
    for pair in [[MessageTypes::Species,speciesnames],
                 [MessageTypes::Kinds,kinds],[MessageTypes::Entries,entries],
                 [MessageTypes::FormNames,formnames]]
      normalized=[]
      for i in 0...pair[1].length
        normalized[i]=pair[1][i] ? pair[1][i] : ""
      end
      messages[pair[0]]=normalized
    end
    File.open(messagesOutput,"wb"){|file| Marshal.dump(messages,file) }
  end
  $pkmn_moves = moves if installRuntime
  File.open(movesOutput,"wb"){|f|
    Marshal.dump(moves,f)
  }
  if installRuntime
    PBSpeciesData.clear_cache if defined?(PBSpeciesData)
    AzureDataCache.clear("Data/dexdata.dat") if defined?(AzureDataCache)
    AzureDataCache.clear("Data/eggEmerald.dat") if defined?(AzureDataCache)
    AzureDataCache.clear("Data/attacksRS.rxdata") if defined?(AzureDataCache)
    AzureDataCache.clear("Data/metrics.dat") if defined?(AzureDataCache)
    AzureEvolutionDataCache.clear if defined?(AzureEvolutionDataCache)
    AzureRegionalDexCache.clear if defined?(AzureRegionalDexCache)
  end
  return {:dexdata=>dexdatas,:eggmoves=>eggmoves,:moves=>moves,
          :evolutions=>evolutions,:metrics=>metrics,:regionals=>regionals,
          :code=>code,:speciesnames=>speciesnames,:kinds=>kinds,
          :entries=>entries,:formnames=>formnames,:maxValue=>maxValue}
end

datafiles=[
   "encounters.dat",
   "trainertypes.dat",
   "connections.dat",
   "pokmanitems.rxdata",
   "metadata.dat",
   "townmap.dat",
   "trainers.dat",
   "attacksRS.rxdata",
   "dexdata.dat",
   "eggEmerald.dat",
   "evolutions.dat",
   "regionals.dat",
   "types.dat",
   "tm.dat",
   "phone.dat",
   "trainerlists.dat",
   "shadowmoves.dat",
   "Constants.rxdata",
   "bossdata.dat"
]

textfiles=[
   "moves.txt",
   "abilities.txt",
   "encounters.txt",
   "trainers.txt",
   "trainertypes.txt",
   "trainer_types.txt",
   "items.txt",
   "connections.txt",
   "metadata.txt",
   "map_metadata.txt",
   "townmap.txt",
   "pokemon.txt",
   "pokemon_metrics.txt",
   "regional_dexes.txt",
   "phone.txt",
   "trainerlists.txt",
   "shadowmoves.txt",
   "tm.txt",
   "types.txt"
]

begin

def pbGenerateMoveRoute(commands)
  route=RPG::MoveRoute.new
  route.repeat=false
  route.skippable=true
  route.list.clear
  i=0;while i<commands.length
    case commands[i]
      when PBMoveRoute::Wait, PBMoveRoute::SwitchOn,
           PBMoveRoute::SwitchOff, PBMoveRoute::ChangeSpeed,
           PBMoveRoute::ChangeFreq, PBMoveRoute::Opacity,
           PBMoveRoute::Blending, PBMoveRoute::PlaySE,
           PBMoveRoute::Script
        route.list.push(RPG::MoveCommand.new(commands[i],[commands[i+1]]))
        i+=1
      when PBMoveRoute::ScriptAsync
        route.list.push(RPG::MoveCommand.new(PBMoveRoute::Script,[commands[i+1]]))
        route.list.push(RPG::MoveCommand.new(PBMoveRoute::Wait,[0]))
        i+=1
      when PBMoveRoute::Jump
        route.list.push(RPG::MoveCommand.new(commands[i],[commands[i+1],commands[i+2]]))
        i+=2
      when PBMoveRoute::Graphic
        route.list.push(RPG::MoveCommand.new(commands[i],[commands[i+1],commands[i+2],commands[i+3],commands[i+4]]))
        i+=4
      else
        route.list.push(RPG::MoveCommand.new(commands[i]))
    end
    i+=1
  end
  route.list.push(RPG::MoveCommand.new(0))
  return route
end

def pbPushMoveRoute(list,character,route,indent=0)
  if route.is_a?(Array)
    route=pbGenerateMoveRoute(route)
  end
  for i in 0...route.list.length
    list.push(RPG::EventCommand.new(
       i==0 ? 209 : 509,indent,
       i==0 ? [character,route] : [route.list[i-1]]))
  end
end

def pbPushMoveRouteAndWait(list,character,route,indent=0)
  pbPushMoveRoute(list,character,route,indent)
  pbPushEvent(list,210,[],indent)
end

def pbPushWait(list,frames,indent=0)
  pbPushEvent(list,106,[frames],indent)
end

def pbPushEvent(list,cmd,params=nil,indent=0)
  list.push(RPG::EventCommand.new(cmd,indent,params ? params : []))
end

def pbPushEnd(list)
  list.push(RPG::EventCommand.new(0,0,[]))
end

def pbPushComment(list,cmt,indent=0)
  textsplit2=cmt.split(/\n/)
  for i in 0...textsplit2.length
    list.push(RPG::EventCommand.new(i==0 ? 108 : 408,indent,[textsplit2[i].gsub(/\s+$/,"")]))
  end
end

def pbPushText(list,text,indent=0)
  return if !text
  textsplit=text.split(/\\m/)
  for t in textsplit
    first=true
    textsplit2=t.split(/\n/)
    for i in 0...textsplit2.length
      textchunk=textsplit2[i].gsub(/\s+$/,"")
      if textchunk && textchunk!=""
        list.push(RPG::EventCommand.new(first ? 101 : 401,indent,[textchunk]))
        first=false
      end
    end
  end
end

def pbPushScript(list,script,indent=0)
  return if !script
  first=true
  textsplit2=script.split(/\n/)
  for i in 0...textsplit2.length
    textchunk=textsplit2[i].gsub(/\s+$/,"")
    if textchunk && textchunk!=""
      list.push(RPG::EventCommand.new(first ? 355 : 655,indent,[textchunk]))
      first=false
    end
  end
end

def pbPushExit(list,indent=0)
  list.push(RPG::EventCommand.new(115,indent,[]))
end

def pbPushElse(list,indent=0)
  list.push(RPG::EventCommand.new(0,indent,[]))
  list.push(RPG::EventCommand.new(411,indent-1,[]))
end

def pbPushBranchEnd(list,indent=0)
  list.push(RPG::EventCommand.new(0,indent,[]))
  list.push(RPG::EventCommand.new(412,indent-1,[]))
end

def pbPushBranch(list,script,indent=0)
  list.push(RPG::EventCommand.new(111,indent,[12,script]))
end

def pbPushSelfSwitch(list,swtch,switchOn,indent=0)
  list.push(RPG::EventCommand.new(123,indent,[swtch,switchOn ? 0 : 1]))
end

def safequote(x)
  x=x.gsub(/\"\#\'\\/){|a| "\\"+a }
  x=x.gsub(/\t/,"\\t")
  x=x.gsub(/\r/,"\\r")
  x=x.gsub(/\n/,"\\n")
  return x
end

def safequote2(x)
  x=x.gsub(/\"\#\'\\/){|a| "\\"+a }
  x=x.gsub(/\t/,"\\t")
  x=x.gsub(/\r/,"\\r")
  x=x.gsub(/\n/," ")
  return x
end

def pbEventId(event)
  list=event.pages[0].list
  return nil if list.length==0
  codes=[]
  i=0;while i<list.length
    codes.push(list[i].code)
    i+=1
  end
end



class MapData
  def initialize
    @mapinfos=pbLoadRxData("Data/MapInfos")
    @system=pbLoadRxData("Data/System")
    @tilesets=pbLoadRxData("Data/Tilesets")
    @mapxy=[]
    @mapWidths=[]
    @mapHeights=[]
    @maps=[]
    @registeredSwitches={}
  end

  def registerSwitch(switch)
    if @registeredSwitches[switch]
      return @registeredSwitches[switch]
    end
    for id in 1..5000
      name=@system.switches[id]
      if !name || name=="" || name==switch
        @system.switches[id]=switch
        @registeredSwitches[switch]=id
        return id
      end
    end
    return 1
  end

  def saveTilesets
    filename="Data/Tilesets"
    filename+=".rxdata"
    save_data(@tilesets,filename)
    filename="Data/System"
    filename+=".rxdata"
    save_data(@system,filename)
  end

  def switchName(id)
    return @system.switches[id] || ""
  end

  def mapFilename(mapID)
    filename=sprintf("Data/map%03d",mapID)
    filename+=".rxdata"
    return filename
  end

  def getMap(mapID)
    if @maps[mapID]
      return @maps[mapID]
    else
      begin
        @maps[mapID]=load_data(mapFilename(mapID))
        return @maps[mapID]
        rescue
        return nil
      end
    end
  end

  def isPassable?(mapID,x,y)
    map=getMap(mapID)
    return false if !map
    return false if x<0 || x>=map.width || y<0 || y>=map.height
    passages=@tilesets[map.tileset_id].passages
    priorities=@tilesets[map.tileset_id].priorities
    for i in [2, 1, 0]
      tile_id = map.data[x, y, i]
      return false if tile_id == nil
      return false if passages[tile_id] & 0x0f == 0x0f
      return true if priorities[tile_id] == 0
    end
    return true
  end

  def setCounterTile(mapID,x,y)
    map=getMap(mapID)
    return if !map
    passages=@tilesets[map.tileset_id].passages
    for i in [2, 1, 0]
      tile_id = map.data[x, y, i]
      next if tile_id == 0 || tile_id==nil || !passages[tile_id]
      passages[tile_id]|=0x80
      break
    end
  end

  def isCounterTile?(mapID,x,y)
    map=getMap(mapID)
    return false if !map
    passages=@tilesets[map.tileset_id].passages
    for i in [2, 1, 0]
      tile_id = map.data[x, y, i]
      return false if tile_id == nil
      return true if passages[tile_id] && passages[tile_id] & 0x80 == 0x80
    end
    return false
  end

  def saveMap(mapID)
    save_data(getMap(mapID),mapFilename(mapID)) rescue nil
  end

  def getEventFromXY(mapID,x,y)
    return nil if x<0 || y<0
    mapPositions=@mapxy[mapID]
    if mapPositions
      return mapPositions[y*@mapWidths[mapID]+x]
    else
      map=getMap(mapID)
      return nil if !map
      @mapWidths[mapID]=map.width
      @mapHeights[mapID]=map.height
      mapPositions=[]
      width=map.width
      for e in map.events.values
        mapPositions[e.y*width+e.x]=e if e
      end
      @mapxy[mapID]=mapPositions
      return mapPositions[y*width+x]
    end
  end

  def getEventFromID(mapID,id)
    map=getMap(mapID)
    return nil if !map
    return map.events[id]
  end

  def mapinfos
    return @mapinfos
  end
end



class TrainerChecker
  def initialize
    @trainers=nil
    @trainertypes=nil
    @dontaskagain=false
  end

  def pbTrainerTypeCheck(symbol)
    ret=true
    if $DEBUG
      return if @dontaskagain
      if !hasConst?(PBTrainers,symbol)
        ret=false
      else
        trtype=PBTrainers.const_get(symbol)
        @trainertypes=load_data("Data/trainertypes.dat") if !@trainertypes
        if !@trainertypes || !@trainertypes[trtype]
          ret=false
        end
      end
      if !ret
        if Kernel.pbConfirmMessage(_INTL("Add new trainer named {1}?",symbol))
          pbTrainerTypeEditorNew(symbol.to_s)
          @trainers=nil
          @trainertypes=nil
        end
#        if pbMapInterpreter
#          pbMapInterpreter.command_end rescue nil
#        end
      end
    end
    return ret
  end

  def pbTrainerBattleCheck(trtype,trname,trid)
    if $DEBUG
      return if @dontaskagain
      if trtype.is_a?(String) || trtype.is_a?(Symbol)
        pbTrainerTypeCheck(trtype)
        return if !hasConst?(PBTrainers,trtype)
        trtype=PBTrainers.const_get(trtype)
      end
      @trainers=load_data("Data/trainers.dat") if !@trainers
      if @trainers
        for trainer in @trainers
          name=trainer[1]
          thistrainerid=trainer[0]
          thispartyid=trainer[4]
          next if name!=trname || thistrainerid!=trtype || thispartyid!=trid
          return
        end
      end
      cmd=pbMissingTrainer(trtype,trname,trid)
      if cmd==2
        @dontaskagain=true
        Graphics.update
      end
      @trainers=nil
      @trainertypes=nil
    end
  end
end



def pbCompileTrainerEvents(mustcompile)
  pbSetWindowText(_INTL("Pokemon Azure")) if !mustcompile
  return if !mustcompile
  mapdata=MapData.new
  t = Time.new.to_i
  Graphics.update
  trainerChecker=TrainerChecker.new
  for id in mapdata.mapinfos.keys.sort
    changed=false
    map=mapdata.getMap(id)
    next if !map || !mapdata.mapinfos[id]
    pbSetWindowText(_INTL("Processing map {1} ({2})",id,mapdata.mapinfos[id].name))
    for key in map.events.keys
      if Time.new.to_i - t >= 5
        Graphics.update
        t = Time.new.to_i
      end
      newevent=pbConvertToTrainerEvent(map.events[key],trainerChecker)
      if newevent
        changed=true
        map.events[key]=newevent
      end
      newevent=pbConvertToItemEvent(map.events[key])
      if newevent
        changed=true
        map.events[key]=newevent
      end
      newevent=pbFixEventUse(map.events[key],id,mapdata)
      if newevent
        changed=true
        map.events[key]=newevent
      end
    end
    if Time.new.to_i - t >= 5
      Graphics.update
      t = Time.new.to_i
    end
    changed=true if pbCheckCounters(map,id,mapdata)
    if changed
      mapdata.saveMap(id)
      mapdata.saveTilesets
    end
  end
  changed=false
  if Time.new.to_i-t>=5
    Graphics.update
    t=Time.new.to_i
  end
  commonEvents=pbLoadRxData("Data/CommonEvents")
  pbSetWindowText(_INTL("Processing common events"))
  for key in 0...commonEvents.length
    newevent=pbFixEventUse(commonEvents[key],0,mapdata)
    if newevent
      changed=true
      map.events[key]=newevent
    end
  end
  if changed
    save_data(commonEvents,"Data/CommonEvents.rxdata")
  end
  pbSetWindowText(_INTL("Pokemon Azure"))
end

def isPlainEvent?(event)
  return event && event.pages.length<=1 &&
         event.pages[0].list.length<=1 &&
         event.pages[0].move_type==0 &&
         event.pages[0].condition.switch1_valid==false &&
         event.pages[0].condition.switch2_valid==false &&
         event.pages[0].condition.variable_valid==false &&
         event.pages[0].condition.self_switch_valid==false
end

def isPlainEventOrMart?(event)
  return event &&
         event.pages.length<=1 &&
         event.pages[0].move_type==0 &&
         event.pages[0].condition.switch1_valid==false &&
         event.pages[0].condition.switch2_valid==false &&
         event.pages[0].condition.variable_valid==false &&
         event.pages[0].condition.self_switch_valid==false &&
         ((event.pages[0].list.length<=1) || (
         event.pages[0].list.length<=12 &&
         event.pages[0].graphic.character_name!="" &&
         event.pages[0].list[0].code==355 &&
         event.pages[0].list[0].parameters[0][/^pbPokemonMart/]) || (
         event.pages[0].list.length>8 &&
         event.pages[0].graphic.character_name!="" &&
         event.pages[0].list[0].code==355 &&
         event.pages[0].list[0].parameters[0][/^Kernel\.pbSetPokemonCenter/])
         )
end

def applyPages(page,pages)
  for i in pages
    i.graphic=page.graphic
    i.walk_anime=page.walk_anime
    i.step_anime=page.step_anime
    i.direction_fix=page.direction_fix
    i.through=page.through
    i.always_on_top=page.always_on_top
  end
end

def isLikelyCounter?(thisEvent,otherEvent,mapID,mapdata)
  # Check whether other event is likely on a counter tile
  yonderX=otherEvent.x+(otherEvent.x-thisEvent.x)
  yonderY=otherEvent.y+(otherEvent.y-thisEvent.y)
  return true if mapdata.isCounterTile?(mapID,otherEvent.x,otherEvent.y)
  return thisEvent.pages[0].graphic.character_name!="" &&
         otherEvent.pages[0].graphic.character_name=="" &&
         otherEvent.pages[0].trigger==0 &&
         mapdata.isPassable?(mapID,thisEvent.x,thisEvent.y) &&
         !mapdata.isPassable?(mapID,otherEvent.x,otherEvent.y) &&
         mapdata.isPassable?(mapID,yonderX,yonderY)
end

def isLikelyPassage?(thisEvent,mapID,mapdata)
  return false if !thisEvent || thisEvent.pages.length==0
  return false if thisEvent.pages.length!=1
  if thisEvent.pages[0].graphic.character_name=="" &&
     thisEvent.pages[0].list.length<=12 &&
     thisEvent.pages[0].list.any? {|cmd| cmd.code==201 } &&
#     mapdata.isPassable?(mapID,thisEvent.x,thisEvent.y+1) &&
     mapdata.isPassable?(mapID,thisEvent.x,thisEvent.y) &&
     !mapdata.isPassable?(mapID,thisEvent.x-1,thisEvent.y) &&
     !mapdata.isPassable?(mapID,thisEvent.x+1,thisEvent.y) &&
     !mapdata.isPassable?(mapID,thisEvent.x-1,thisEvent.y-1) &&
     !mapdata.isPassable?(mapID,thisEvent.x+1,thisEvent.y-1)
    return true
  else
    return false
  end
end

def pbCheckCounters(map,mapID,mapdata)
  todelete=[]
  changed=false
  for key in map.events.keys
    event=map.events[key]
    next if !event
    firstCommand=event.pages[0].list[0]
    if isPlainEventOrMart?(event)
      # Empty event, check for counter events
      neighbors=[]
      neighbors.push(mapdata.getEventFromXY(mapID,event.x,event.y-1))
      neighbors.push(mapdata.getEventFromXY(mapID,event.x,event.y+1))
      neighbors.push(mapdata.getEventFromXY(mapID,event.x-1,event.y))
      neighbors.push(mapdata.getEventFromXY(mapID,event.x+1,event.y))
      neighbors.compact!
      for otherEvent in neighbors
        next if isPlainEvent?(otherEvent)
        if isLikelyCounter?(event,otherEvent,mapID,mapdata)
          mapdata.setCounterTile(mapID,otherEvent.x,otherEvent.y)
          savedPage=event.pages[0]
          event.pages=otherEvent.pages
          applyPages(savedPage,event.pages)
          todelete.push(otherEvent.id)
          changed=true
        end
      end
    end
  end
  for key in todelete
    map.events.delete(key)
  end
  return changed
end

def pbAddPassageList(event,mapdata)
  return if !event || event.pages.length==0
  page=RPG::Event::Page.new
  page.condition.switch1_valid=true
  page.condition.switch1_id=mapdata.registerSwitch('s:tsOff?("A")')
  page.graphic.character_name=""
  page.trigger=3 # Autorun
  page.list.clear
  list=page.list
  pbPushBranch(list,"get_character(0).onEvent?")
  pbPushEvent(list,208,[0],1)
  pbPushWait(list,6,1)
  pbPushEvent(list,208,[1],1)
  pbPushMoveRouteAndWait(list,-1,[PBMoveRoute::Down],1)
  pbPushBranchEnd(list,1)
  pbPushScript(list,"setTempSwitchOn(\"A\")")
  pbPushEnd(list)
  event.pages.push(page)
end

def pbUpdateDoor(event,mapdata)
  changed=false
  return false if event.is_a?(RPG::CommonEvent)
  if event.pages.length>=2 &&
     event.pages[event.pages.length-1].condition.switch1_valid &&
     event.pages[event.pages.length-1].condition.switch1_id==12 &&
     event.pages[event.pages.length-1].list.length>5 &&
     event.pages[event.pages.length-1].graphic.character_name!="" &&
     mapdata.switchName(event.pages[event.pages.length-1].condition.switch1_id)!='s:tsOff?("A")' &&
     event.pages[event.pages.length-1].list[0].code==111
    event.pages[event.pages.length-1].condition.switch1_id=mapdata.registerSwitch('s:tsOff?("A")')
    changed=true
  end
  if event.pages.length>=2 &&
     event.pages[event.pages.length-1].condition.switch1_valid &&
     event.pages[event.pages.length-1].list.length>5 &&
     event.pages[event.pages.length-1].graphic.character_name!="" &&
     mapdata.switchName(event.pages[event.pages.length-1].condition.switch1_id)=='s:tsOff?("A")' &&
     event.pages[event.pages.length-1].list[0].code==111
    list=event.pages[event.pages.length-2].list
    transferCommand=list.find_all {|cmd| cmd.code==201 }
    if transferCommand.length==1 && !list.any?{|cmd| cmd.code==208 }
      list.clear
      pbPushMoveRouteAndWait(list,0,[
         PBMoveRoute::PlaySE,RPG::AudioFile.new("Entering Door"),PBMoveRoute::Wait,2,
         PBMoveRoute::TurnLeft,PBMoveRoute::Wait,2,
         PBMoveRoute::TurnRight,PBMoveRoute::Wait,2,
         PBMoveRoute::TurnUp,PBMoveRoute::Wait,2])
      pbPushMoveRouteAndWait(list,-1,[
         PBMoveRoute::ThroughOn,PBMoveRoute::Up,PBMoveRoute::ThroughOff])
      pbPushEvent(list,208,[0]) # Change Transparent Flag
      pbPushMoveRouteAndWait(list,0,[PBMoveRoute::Wait,2,
         PBMoveRoute::TurnRight,PBMoveRoute::Wait,2,
         PBMoveRoute::TurnLeft,PBMoveRoute::Wait,2,
         PBMoveRoute::TurnDown,PBMoveRoute::Wait,2])
      pbPushEvent(list,223,[Tone.new(-255,-255,-255),6])
      pbPushWait(list,8)
      pbPushEvent(list,208,[1])
      pbPushEvent(list,transferCommand[0].code,transferCommand[0].parameters)
      pbPushEvent(list,223,[Tone.new(0,0,0),6])
      pbPushEnd(list)
      list=event.pages[event.pages.length-1].list
      list.clear
      pbPushBranch(list,"get_character(0).onEvent?")
      pbPushEvent(list,208,[0],1)
      pbPushMoveRouteAndWait(list,0,[
         PBMoveRoute::TurnLeft,PBMoveRoute::Wait,6],1)
      pbPushEvent(list,208,[1],1)
      pbPushMoveRouteAndWait(list,-1,[PBMoveRoute::Down],1)
      pbPushMoveRouteAndWait(list,0,[
         PBMoveRoute::TurnUp,PBMoveRoute::Wait,2,
         PBMoveRoute::TurnRight,PBMoveRoute::Wait,2,
         PBMoveRoute::TurnDown,PBMoveRoute::Wait,2],1)
      pbPushBranchEnd(list,1)
      pbPushScript(list,"setTempSwitchOn(\"A\")")
      pbPushEnd(list)
      changed=true
    end
  end
  return changed
end

def pbEventIsEmpty?(e)
  return true if !e
  if e.is_a?(RPG::CommonEvent)
    return false
  else
    return e.pages.length==0
  end
end

def pbEachPage(e)
  return true if !e
  if e.is_a?(RPG::CommonEvent)
    yield e
  else
    e.pages.each {|page| yield page }
  end
end

def pbChangeScript(script,re)
  tmp=script[0].gsub(re){ yield($~) }
  if script[0]!=tmp
    script[0]=tmp; return true
  end
  return false
end

def pbChangeScripts(script)
  changed=false
  changed|=pbChangeScript(script,/\$game_variables\[(\d+)\](?!\s*(?:\=|\!|<|>))/){|m| "pbGet("+m[1]+")" }
  changed|=pbChangeScript(script,/\$Trainer\.party\[\s*pbGet\((\d+)\)\s*\]/){|m| "pbGetPokemon("+m[1]+")" }
  return changed
end

def pbFixEventUse(event,mapID,mapdata)
  return nil if pbEventIsEmpty?(event)
  changed=false
  trainerMoneyRE=/^\s*\$Trainer\.money\s*(<|<=|>|>=)\s*(\d+)\s*$/
  itemBallRE=/^\s*(Kernel\.)?pbItemBall/
  if pbUpdateDoor(event,mapdata)
    changed=true
  end
  pbEachPage(event) do |page|
    i=0
    list=page.list
    while i<list.length
      params=list[i].parameters
      if list[i].code==655
        x=[params[0]]
        changed|=pbChangeScripts(x)
        params[0]=x[0]
      elsif list[i].code==355
        lastScript=i
        if !params[0].is_a?(String)
          i+=1
          next
        end
        x=[params[0]]
        changed|=pbChangeScripts(x)
        params[0]=x[0]
        if params[0][0,1]!="f" && params[0][0,1]!="p" && params[0][0,1]!="K"
          i+=1
          next
        end
        script=" "+params[0]
        j=i+1
        while j<list.length
          break if list[j].code!=655
          script+=list[j].parameters[0]
          lastScript=j
          j+=1
        end
        script.gsub!(/\s+/,"")
        # Using old method of recovering
        if script=="foriin$Trainer.partyi.healend"
          for j in i..lastScript
            list.delete_at(i)
          end
          list.insert(i,
             RPG::EventCommand.new(314,list[i].indent,[0]) # Recover All
          )
          changed=true
        elsif script=="pbFadeOutIn(99999){foriin$Trainer.partyi.healend}"
          oldIndent=list[i].indent
          for j in i..lastScript
            list.delete_at(i)
          end
          list.insert(i,
             RPG::EventCommand.new(223,oldIndent,[Tone.new(-255,-255,-255),6]), # Fade to black
             RPG::EventCommand.new(106,oldIndent,[6]), # Wait
             RPG::EventCommand.new(314,oldIndent,[0]), # Recover All
             RPG::EventCommand.new(223,oldIndent,[Tone.new(0,0,0),6]), # Fade to normal
             RPG::EventCommand.new(106,oldIndent,[6]) # Wait
          )
          changed=true
        end
      elsif list[i].code==108
        if params[0][/SellItem\s*\(\s*(\w+)\s*\,\s*(\d+)\s*\)/]
          itemname=$1
          cost=$2.to_i
          if hasConst?(PBItems,itemname)
            oldIndent=list[i].indent
            list.delete_at(i)
            newEvents=[]
            if cost==0
              pbPushBranch(newEvents,"$PokemonBag.pbCanStore?(PBItems:"+":#{itemname})",oldIndent)
              pbPushText(newEvents,_INTL("Here you go!"),oldIndent+1)
              pbPushScript(newEvents,"Kernel.pbReceiveItem(PBItems:"+":#{itemname})",oldIndent+1)
              pbPushElse(newEvents,oldIndent+1)
              pbPushText(newEvents,_INTL("You have no room left in the Bag."),oldIndent+1)
              pbPushBranchEnd(newEvents,oldIndent+1)
            else
              pbPushEvent(newEvents,111,[7,cost,0],oldIndent)
              pbPushBranch(newEvents,"$PokemonBag.pbCanStore?(PBItems:"+":#{itemname})",oldIndent+1)
              pbPushEvent(newEvents,125,[1,0,cost],oldIndent+2)
              pbPushText(newEvents,_INTL("\\GHere you go!"),oldIndent+2)
              pbPushScript(newEvents,"Kernel.pbReceiveItem(PBItems:"+":#{itemname})",oldIndent+2)
              pbPushElse(newEvents,oldIndent+2)
              pbPushText(newEvents,_INTL("\\GYou have no room left in the Bag."),oldIndent+2)
              pbPushBranchEnd(newEvents,oldIndent+2)
              pbPushElse(newEvents,oldIndent+1)
              pbPushText(newEvents,_INTL("\\GYou don't have enough money."),oldIndent+1)
              pbPushBranchEnd(newEvents,oldIndent+1)
            end
            list[i,0]=newEvents # insert 'newEvents' at index 'i'
            changed=true
          end
        end
      elsif list[i].code==115 && i==list.length-2
        # Superfluous exit command
        list.delete_at(i)
        changed=true
      elsif list[i].code==201 && list.length<=8
        if params[0]==0
          # Transfer back to door
          e=mapdata.getEventFromXY(params[1],params[2],params[3]-1)
          if e && e.pages.length>=2 &&
             e.pages[e.pages.length-1].condition.switch1_valid &&
             e.pages[e.pages.length-1].condition.switch1_id==12 &&
             mapdata.switchName(e.pages[e.pages.length-1].condition.switch1_id)!='s:tsOff?("A")' &&
             e.pages[e.pages.length-1].list.length>5 &&
             e.pages[e.pages.length-1].list[0].code==111
            e.pages[e.pages.length-1].condition.switch1_id=mapdata.registerSwitch('s:tsOff?("A")')
            mapdata.saveMap(params[1])
            changed=true
          end
          if isLikelyPassage?(e,params[1],mapdata)
            pbAddPassageList(e,mapdata)
            mapdata.saveMap(params[1])
            changed=true
          end
          if e && e.pages.length>=2 &&
             e.pages[e.pages.length-1].condition.switch1_valid &&
            mapdata.switchName(e.pages[e.pages.length-1].condition.switch1_id)=='s:tsOff?("A")'
            # If this is really a door, move transfer target to it
            params[3]-=1
            params[5]=1 # No fade
            changed=true
          end
          deletedRoute=nil
          deleteMoveRouteAt=proc{|list,_i|
             arr=[]
             if list[_i] && list[_i].code==209
               arr.push(list[_i]);list.delete_at(_i)
               while _i<list.length
                 break if !list[_i] || list[_i].code!=509
                 arr.push(list[_i]);list.delete_at(_i)
               end
             end
             next arr
          }
          insertMoveRouteAt=proc{|list,_i,route|
             _j=route.length-1
             while _j>=0
               list.insert(_i,route[_j])
               _j-=1
             end
          }
          if params[4]==0 && # Retain direction
             i+1<list.length && list[i+1].code==209 && list[i+1].parameters[0]==-1
            route=list[i+1].parameters[1]
            if route && route.list.length<=2
              # Delete superfluous move route command if necessary
              if route.list[0].code==16 # Player/Turn Down
                deleteMoveRouteAt.call(list,i+1); params[4]=2; changed=true
              elsif route.list[0].code==17 # Left
                deleteMoveRouteAt.call(list,i+1); params[4]=4; changed=true
              elsif route.list[0].code==18 # Right
                deleteMoveRouteAt.call(list,i+1); params[4]=6; changed=true
              elsif route.list[0].code==19 # Up
                deleteMoveRouteAt.call(list,i+1); params[4]=8; changed=true
              elsif (route.list[0].code==1 || route.list[0].code==2 ||
                 route.list[0].code==3 || route.list[0].code==4) && list.length==4
                params[4]=[0,2,4,6,8][route.list[0].code]
                deletedRoute=deleteMoveRouteAt.call(list,i+1); changed=true
              end
            end
          elsif params[4]==0 && i>3
            for j in 0...i
              if list[j].code==209 && list[j].parameters[0]==-1
                route=list[j].parameters[1]
                oldlistlength=list.length
                if route && route.list.length<=2
                  # Delete superfluous move route command if necessary
                  if route.list[0].code==16 # Player/Turn Down
                    deleteMoveRouteAt.call(list,j); params[4]=2; changed=true;i-=(oldlistlength-list.length)
                  elsif route.list[0].code==17 # Left
                    deleteMoveRouteAt.call(list,j); params[4]=4; changed=true;i-=(oldlistlength-list.length)
                  elsif route.list[0].code==18 # Right
                    deleteMoveRouteAt.call(list,j); params[4]=6; changed=true;i-=(oldlistlength-list.length)
                  elsif route.list[0].code==19 # Up
                    deleteMoveRouteAt.call(list,j); params[4]=8; changed=true;i-=(oldlistlength-list.length)
                  end
                end
              end
            end
          elsif params[4]==0 && # Retain direction
             i+2<list.length &&
             list[i+1].code==223 &&
             list[i+2].code==209 &&
             list[i+2].parameters[0]==-1
            route=list[i+2].parameters[1]
            if route && route.list.length<=2
              # Delete superfluous move route command if necessary
              if route.list[0].code==16 # Player/Turn Down
                deleteMoveRouteAt.call(list,i+2); params[4]=2; changed=true
              elsif route.list[0].code==17 # Left
                deleteMoveRouteAt.call(list,i+2); params[4]=4; changed=true
              elsif route.list[0].code==18 # Right
                deleteMoveRouteAt.call(list,i+2); params[4]=6; changed=true
              elsif route.list[0].code==19 # Up
                deleteMoveRouteAt.call(list,i+2); params[4]=8; changed=true
              end
            end
          end
        end
        # If this is the only event command, convert to a full event
        if list.length==2 || (list.length==3 && (list[0].code==250 || list[1].code==250))
          params[5]=1 # No fade
          fullTransfer=list[i]
          indent=list[i].indent
          (list.length-1).times { list.delete_at(0) }
          list.insert(0,
             RPG::EventCommand.new(250,indent,[RPG::AudioFile.new("Exit Door",80,100)]), # Play SE
             RPG::EventCommand.new(223,indent,[Tone.new(-255,-255,-255),6]), # Fade to black
             RPG::EventCommand.new(106,indent,[8]), # Wait
             fullTransfer, # Transfer event
             RPG::EventCommand.new(223,indent,[Tone.new(0,0,0),6]) # Fade to normal
          )
          changed=true
        end
        if deletedRoute
          insertMoveRouteAt.call(list,list.length-1,deletedRoute)
          changed=true
        end
      elsif list[i].code==101
        if list[i].parameters[0][0,1]=="\\"
          newx=list[i].parameters[0].clone
          newx.sub!(/^\\[Bb]\s+/,"\\b")
          newx.sub!(/^\\[Rr]\s+/,"\\r")
          newx.sub!(/^\\[Pp][Gg]\s+/,"\\pg")
          newx.sub!(/^\\[Pp][Oo][Gg]\s+/,"\\pog")
          newx.sub!(/^\\[Gg]\s+/,"\\G")
          newx.sub!(/^\\[Cc][Nn]\s+/,"\\CN")
          if list[i].parameters[0]!=newx
            list[i].parameters[0]=newx
            changed=true
          end
        end
        lines=1
        j=i+1; while j<list.length
          break if list[j].code!=401
          if lines%4==0
            list[j].code=101
            changed=true
          end
          lines+=1
          j+=1
        end
        if lines>=2 && list[i].parameters[0].length>0 && list[i].parameters[0].length<=20 &&
           !list[i].parameters[0][/\\n/]
          # Very short line
          list[i].parameters[0]+="\\n"+list[i+1].parameters[0]
          list.delete_at(i+1)
          i-=1 # revisit this text command
          changed=true
        elsif lines>=3 && list[i+lines] && list[i+lines].code==101
          # Check whether a sentence is being broken midway
          # between two Text commands
          lastLine=list[i+lines-1].parameters[0].sub(/\s+$/,"")
          if lastLine.length>0 && !lastLine[/[\\<]/] && lastLine[/[^\.,\!\?\;\-\"]$/]
            message=list[i].parameters[0]
            j=i+1; while j<list.length
              break if list[j].code!=401
              message+="\n"+list[j].parameters[0]
              j+=1
            end
            punct=[message.rindex(". "),message.rindex(".\n"),
               message.rindex("!"),message.rindex("?"),-1].compact.max
            if punct==-1
              punct=[message.rindex(", "),message.rindex(",\n"),-1].compact.max
            end
            if punct!=-1
              # Delete old message
              indent=list[i].indent
              newMessage=message[0,punct+1].split("\n")
              nextMessage=message[punct+1,message.length].sub(/^\s+/,"").split("\n")
              list[i+lines].code=401
              lines.times { list.delete_at(i) }
              j=nextMessage.length-1;while j>=0
                list.insert(i,RPG::EventCommand.new(
                j==0 ? 101 : 401,indent,[nextMessage[j]]))
                j-=1
              end
              j=newMessage.length-1;while j>=0
                list.insert(i,RPG::EventCommand.new(
                j==0 ? 101 : 401,indent,[newMessage[j]]))
                j-=1
              end
              changed=true
              i+=1
              next
            end
          end
        end
      elsif list[i].code==111 && list[i].parameters[0]==12
        x=[list[i].parameters[1]]
        changed|=pbChangeScripts(x)
        list[i].parameters[1]=x[0]
        script=x[0]
        if script[trainerMoneyRE]
          # Checking money directly
          operator=$1
          amount=$2.to_i
          params[0]=7
          if operator=="<"
            params[2]=1
            params[1]=amount-1
          elsif operator=="<="
            params[2]=1
            params[1]=amount
          elsif operator==">"
            params[2]=0
            params[1]=amount+1
          elsif operator==">="
            params[2]=0
            params[1]=amount
          end
          changed=true
        elsif script[itemBallRE] && i>0
          # Using pbItemBall on non-item events
          list[i].parameters[1]=script.sub(/pbItemBall/,"pbReceiveItem")
          changed=true
        elsif script[/^\s*(Kernel\.)?(pbTrainerBattle|pbDoubleTrainerBattle)/]
          # Empty trainer battle conditional branches
          j=i+1
          isempty=true
          elseIndex=-1
          # Check if page is empty
          while j<page.list.length
            if list[j].indent<=list[i].indent
              if list[j].code==411 # Else
                elseIndex=j
              else
                break
              end
            end
            if list[j].code!=0 && list[j].code!=411
              isempty=false
              break
            end
            j+=1
          end
          if isempty
            if elseIndex>=0
              list.insert(elseIndex+1,
                 RPG::EventCommand.new(115,list[i].indent+1,[]) # Exit Event Processing
              )
            else
              list.insert(i+1,
                 RPG::EventCommand.new(0,list[i].indent+1,[]), # Empty Event
                 RPG::EventCommand.new(411,list[i].indent,[]), # Else
                 RPG::EventCommand.new(115,list[i].indent+1,[]) # Exit Event Processing
              )
            end
            changed=true
          end
        end
      end
      i+=1
    end
  end
  return changed ? event : nil
end

def pbConvertToItemEvent(event)
  return nil if !event || event.pages.length==0
  ret=RPG::Event.new(event.x,event.y)
  name=event.name
  ret.name=event.name
  ret.id=event.id
  ret.pages=[]
  itemid=nil
  itemname=""
  hidden=false
  if name[/^HiddenItem\:\s*(\w+)\s*$/]
    itemname=$1
    return nil if !hasConst?(PBItems,itemname)
    itemid=PBItems.const_get(itemname)
    ret.name="HiddenItem"
    hidden=true
  elsif name[/^Item\:\s*(\w+)\s*$/]
    itemname=$1
    return nil if !hasConst?(PBItems,itemname)
    itemid=PBItems.const_get(itemname)
    ret.name="Item"
  else
    return nil
  end
  # Event page 1
  page=RPG::Event::Page.new
  if !hidden
    page.graphic.character_name="Object ball"
  end
  page.list=[]
  pbPushBranch(page.list,
     sprintf("Kernel.pbItemBall(PBItems:"+":%s)",itemname))
  pbPushSelfSwitch(page.list,"A",true,1)
  pbPushElse(page.list,1)
  pbPushBranchEnd(page.list,1)
  pbPushEnd(page.list)
  ret.pages.push(page)
  # Event page 2
  page=RPG::Event::Page.new
  page.condition.self_switch_valid=true
  page.condition.self_switch_ch="A"
  ret.pages.push(page)
  return ret
end

def pbStartsWith(s,pfx)
  return s[0,pfx.length]==pfx
end

def pbConvertToTrainerEvent(event,trainerChecker)
  return nil if !event || event.pages.length==0
  ret=RPG::Event.new(event.x,event.y)
  ret.name=event.name
  ret.id=event.id
  commands=[]
  list=event.pages[0].list
  return nil if list.length<2
  isFirstCommand=false
  i=0; while i<list.length
    if list[i].code==108
      command=list[i].parameters[0]
      j=i+1; while j<list.length
        break if list[j].code!=408
        command+="\n"+list[j].parameters[0]
        j+=1
      end
      if command[/^(Battle\:|Type\:|Name\:|EndSpeech\:|VanishIfSwitch\:|EndBattle\:|RegSpeech\:|BattleID\:|EndIfSwitch\:|DoubleBattle\:|Backdrop\:|Continue\:|Outcome\:)/i]
        commands.push(command)
        isFirstCommand=true if i==0
      end
    end
    i+=1
  end
  return nil if commands.length==0
  if isFirstCommand && !event.name[/Trainer/]
    ret.name="Trainer(3)"
  elsif isFirstCommand && event.name[/^\s*Trainer\s+\((\d+)\)\s*$/]
    ret.name="Trainer(#{$1})"
  end
  firstpage=Marshal::load(Marshal.dump(event.pages[0]))
  firstpage.trigger=2
  firstpage.list=[]
  trtype=nil
  trname=nil
  battles=[]
  endbattles=[]
  realcommands=[]
  endspeeches=[]
  regspeech=nil
  backdrop=nil
  battleid=0
  endifswitch=[]
  vanishifswitch=[]
  doublebattle=false
  continue=false
  outcome=0
  for command in commands
    if command[/^Battle\:\s*([\s\S]+)$/i]
      battles.push($~[1])
      pbPushComment(firstpage.list,command)
    elsif command[/^Type\:\s*([\s\S]+)$/i]
      trtype=$~[1].gsub(/^\s+/,"").gsub(/\s+$/,"")
      pbPushComment(firstpage.list,command)
    elsif command[/^Name\:\s*([\s\S]+)$/i]
      trname=$~[1].gsub(/^\s+/,"").gsub(/\s+$/,"")
      pbPushComment(firstpage.list,command)
    elsif command[/^EndSpeech\:\s*([\s\S]+)$/i]
      endspeeches.push($~[1].gsub(/^\s+/,"").gsub(/\s+$/,""))
      pbPushComment(firstpage.list,command)
    elsif command[/^EndIfSwitch\:\s*([\s\S]+)$/i]
      endifswitch.push(($~[1].gsub(/^\s+/,"").gsub(/\s+$/,"")).to_i)
      pbPushComment(firstpage.list,command)
    elsif command[/^DoubleBattle\:\s*([\s\S]+)$/i]
      value=$~[1].gsub(/^\s+/,"").gsub(/\s+$/,"")
      doublebattle=true if value.upcase=="TRUE" || value.upcase=="YES"
      pbPushComment(firstpage.list,command)
    elsif command[/^VanishIfSwitch\:\s*([\s\S]+)$/i]
      vanishifswitch.push(($~[1].gsub(/^\s+/,"").gsub(/\s+$/,"")).to_i)
      pbPushComment(firstpage.list,command)
    elsif command[/^Backdrop\:\s*([\s\S]+)$/i]
      backdrop=$~[1].gsub(/^\s+/,"").gsub(/\s+$/,"")
      pbPushComment(firstpage.list,command)
    elsif command[/^RegSpeech\:\s*([\s\S]+)$/i]
      regspeech=$~[1].gsub(/^\s+/,"").gsub(/\s+$/,"")
      pbPushComment(firstpage.list,command)
    elsif command[/^EndBattle\:\s*([\s\S]+)$/i]
      endbattles.push($~[1].gsub(/^\s+/,"").gsub(/\s+$/,""))
      pbPushComment(firstpage.list,command)
    elsif command[/^BattleID\:\s*(\d+)$/i]
      battleid=$~[1].to_i
      pbPushComment(firstpage.list,command)
    elsif command[/^Continue\:\s*([\s\S]+)$/i]
      value=$~[1].gsub(/^\s+/,"").gsub(/\s+$/,"")
      continue=true if value.upcase=="TRUE" || value.upcase=="YES"
      pbPushComment(firstpage.list,command)
    elsif command[/^Outcome\:\s*(\d+)$/i]
      outcome=$~[1].to_i
      pbPushComment(firstpage.list,command)
    end
  end
  if battles.length<=0
    return nil
  end
  if firstpage.graphic.character_name=="" && hasConst?(PBTrainers,trtype)
    trainerid=getConst(PBTrainers,trtype)
    if trainerid
      filename=pbTrainerCharNameFile(trainerid)
      if FileTest.image_exist?("Graphics/Characters/"+filename)
        firstpage.graphic.character_name=sprintf(filename)
      end
    end
  end
  safetrcombo=sprintf("PBTrainers:"+":%s,\"%s\"",trtype,safequote(trname))
  safetrcombo2=sprintf(":%s,\"%s\"",trtype,safequote(trname))
  introplay=sprintf("pbTrainerIntro(:%s)",trtype)
  pbPushScript(firstpage.list,introplay)
  pbPushScript(firstpage.list,"Kernel.pbNoticePlayer(get_character(0))")
  pbPushText(firstpage.list,battles[0])
  if battles.length>1
    pbPushScript(firstpage.list,sprintf("Kernel.pbTrainerCheck(%s,%d,%d)",safetrcombo2,battles.length,battleid))
  end
  if backdrop
    pbPushScript(firstpage.list,sprintf("$PokemonGlobal.nextBattleBack=\"%s\"",safequote(backdrop)))
  end
  espeech=(endspeeches[0]) ? endspeeches[0] : "..."
  # Run trainer check now, except in editor
  trainerChecker.pbTrainerBattleCheck(trtype,trname,battleid) if !$INEDITOR
  pbPushBranch(firstpage.list,
     sprintf("pbTrainerBattle(%s,_I(\"%s\"),%s,%d,%s,%d)",
     safetrcombo,safequote2(espeech),
     doublebattle ? "true" : "false",
     battleid,
     continue ? "true" : "false",
     outcome)
  )
  if battles.length>1
    pbPushScript(firstpage.list,sprintf("pbPhoneRegisterBattle(_I(\"%s\"),get_character(0),%s,%d)",regspeech,safetrcombo,battles.length),1)
  end
  pbPushSelfSwitch(firstpage.list,"A",true,1)
  pbPushBranchEnd(firstpage.list,1)
  pbPushScript(firstpage.list,"pbTrainerEnd",0)
  pbPushEnd(firstpage.list)
  secondpage=Marshal::load(Marshal.dump(firstpage))
  secondpage.list=[]
  secondpage.trigger=0
  secondpage.condition=firstpage.condition.clone
  thirdpage=Marshal::load(Marshal.dump(secondpage))
  thirdpage.list=secondpage.list.clone
  thirdpage.condition=secondpage.condition.clone
  secondpage.condition.self_switch_valid=true
  secondpage.condition.self_switch_ch="A"
  thirdpage.condition.self_switch_valid=true
  thirdpage.condition.self_switch_ch="B"
  for i in 1...battles.length
    if endspeeches.length==0
      espeech="..."
    else
      espeech=(endspeeches[i]) ? endspeeches[i] : endspeeches[endspeeches.length-1]
    end
    if endbattles.length==0
      ebattle=nil
    else
      ebattle=(endbattles[i]) ? endbattles[i] : endbattles[endbattles.length-1]
    end
    if i==battles.length-1
      pbPushBranch(thirdpage.list,sprintf("pbPhoneBattleCount(%s)>=%d",safetrcombo,i))
      pbPushBranch(secondpage.list,sprintf("pbPhoneBattleCount(%s)>%d",safetrcombo,i))
    else
      pbPushBranch(thirdpage.list,sprintf("pbPhoneBattleCount(%s)==%d",safetrcombo,i))
      pbPushBranch(secondpage.list,sprintf("pbPhoneBattleCount(%s)==%d",safetrcombo,i))
    end
    pbPushText(secondpage.list,ebattle,1)
    pbPushScript(secondpage.list,sprintf("pbPhoneRegisterBattle(_I(\"%s\"),get_character(0),%s,%d)",regspeech,safetrcombo,battles.length),1)
    pbPushExit(secondpage.list,1)
    pbPushBranchEnd(secondpage.list,1)
    pbPushScript(thirdpage.list,introplay,1)
    pbPushText(thirdpage.list,battles[i],1)
    # Run trainer check now, except in editor
    trainerChecker.pbTrainerBattleCheck(trtype,trname,battleid+i) if !$INEDITOR
    if backdrop
      pbPushScript(thirdpage.list,sprintf("$PokemonGlobal.nextBattleBack=\"%s\"",safequote(backdrop)),1)
    end
    pbPushBranch(thirdpage.list,
       sprintf("pbTrainerBattle(%s,_I(\"%s\"),%s,%d,%s,%d)",
       safetrcombo,safequote2(espeech),
       doublebattle ? "true" : "false",
       battleid+i,
       continue ? "true" : "false",
       outcome),1
    )
    pbPushScript(thirdpage.list,
       sprintf("pbPhoneIncrement(%s,%d)",safetrcombo,battles.length),2)
    pbPushSelfSwitch(thirdpage.list,"A",true,2)
    pbPushSelfSwitch(thirdpage.list,"B",false,2)
    pbPushScript(thirdpage.list,"pbTrainerEnd",2)
    pbPushBranchEnd(thirdpage.list,2)
    pbPushExit(thirdpage.list,1)
    pbPushBranchEnd(thirdpage.list,1)
  end
  ebattle=(endbattles[0]) ? endbattles[0] : "..."
  pbPushText(secondpage.list,ebattle)
  if battles.length>1
    pbPushScript(secondpage.list,sprintf("pbPhoneRegisterBattle(_I(\"%s\"),get_character(0),%s,%d)",regspeech,safetrcombo,battles.length),1)
  end
  pbPushEnd(secondpage.list)
  pbPushEnd(thirdpage.list)
  if battles.length==1
    ret.pages=[firstpage,secondpage]
  else
    ret.pages=[firstpage,thirdpage,secondpage]
  end
  for endswitch in endifswitch
    ebattle=(endbattles[0]) ? endbattles[0] : "..."
    endIfSwitchPage=Marshal::load(Marshal.dump(secondpage))
    endIfSwitchPage.condition=secondpage.condition.clone
    if endIfSwitchPage.condition.switch1_valid
      endIfSwitchPage.condition.switch2_valid=true
      endIfSwitchPage.condition.switch2_id=endswitch
    else
      endIfSwitchPage.condition.switch1_valid=true
      endIfSwitchPage.condition.switch1_id=endswitch
    end
    endIfSwitchPage.condition.self_switch_valid=false
    endIfSwitchPage.list=[]
    pbPushText(endIfSwitchPage.list,ebattle)
    pbPushEnd(endIfSwitchPage.list)
    ret.pages.push(endIfSwitchPage)
  end
  for endswitch in vanishifswitch
    ebattle=(endbattles[0]) ? endbattles[0] : "..."
    endIfSwitchPage=Marshal::load(Marshal.dump(secondpage))
    endIfSwitchPage.graphic.character_name="" # make blank
    endIfSwitchPage.condition=secondpage.condition.clone
    if endIfSwitchPage.condition.switch1_valid
      endIfSwitchPage.condition.switch2_valid=true
      endIfSwitchPage.condition.switch2_id=endswitch
    else
      endIfSwitchPage.condition.switch1_valid=true
      endIfSwitchPage.condition.switch1_id=endswitch
    end
    endIfSwitchPage.condition.self_switch_valid=false
    endIfSwitchPage.list=[]
    pbPushEnd(endIfSwitchPage.list)
    ret.pages.push(endIfSwitchPage)
  end
  return ret
end

def pbCompileAnimations
  begin
    pbanims=load_data("Data/PkmnAnimations.rxdata")
  rescue
    pbanims=PBAnimations.new
  end
  move2anim=[[],[]]
=begin
  if $RPGVX
    anims=load_data("Data/Animations.rvdata")
  else
    anims=load_data("Data/Animations.rxdata")
  end
  for anim in anims
    next if !anim || anim.frames.length==1
    found=false
    for i in 0...pbanims.length
      if pbanims[i] && pbanims[i].id==anim.id
        found=true if pbanims[i].array.length>1
        break
      end
    end
    if !found
      pbanims[anim.id]=pbConvertRPGAnimation(anim)
    end
  end
=end
  for i in 0...pbanims.length
    next if !pbanims[i]
    if pbanims[i].name[/^OppMove\:\s*(.*)$/]
      if Kernel.hasConst?(PBMoves,$~[1])
        moveid=PBMoves.const_get($~[1])
        move2anim[1][moveid]=i
      end
    elsif pbanims[i].name[/^Move\:\s*(.*)$/]
      if Kernel.hasConst?(PBMoves,$~[1])
        moveid=PBMoves.const_get($~[1])
        move2anim[0][moveid]=i
      end
    end
  end
  save_data(pbanims,"Data/PkmnAnimations.rxdata")
  # PkmnAnimations is the source for move2anim. Save the derived index last so
  # its timestamp accurately records that it reflects this animation file.
  save_data(move2anim,"Data/move2anim.dat")
end

# Each entry retains Azure's existing compiler and compiled file format. This
# table only describes freshness and dependency relationships so development
# builds can avoid recompiling unrelated databases.
AZURE_PBS_COMPILE_STEPS=[
  {:id=>:types,
   :label=>"type data",
   :sources=>["PBS/types.txt"],
   :outputs=>["Data/types.dat","Scripts/PBTypes.rb"],
   :dependencies=>[]},
  {:id=>:town_map,
   :label=>"town map data",
   :sources=>["PBS/townmap.txt"],
   :outputs=>["Data/townmap.dat"],
   :dependencies=>[]},
  {:id=>:connections,
   :label=>"map connection data",
   :sources=>["PBS/connections.txt"],
   :outputs=>["Data/connections.dat"],
   :dependencies=>[]},
  {:id=>:abilities,
   :label=>"ability data",
   :sources=>["PBS/abilities.txt"],
   :outputs=>["Scripts/PBAbilities.rb"],
   :dependencies=>[]},
  {:id=>:moves,
   :label=>"move data",
   :sources=>["PBS/moves.txt"],
   :outputs=>["Data/moves.dat","Scripts/PBMoves.rb"],
   :dependencies=>[:types]},
  {:id=>:items,
   :label=>"item data",
   :sources=>["PBS/items.txt"],
   :outputs=>["Data/pokmanitems.rxdata","Scripts/PBItems.rb"],
   :dependencies=>[:moves]},
  {:id=>:pokemon,
   :label=>"Pokemon data",
   :sources=>["PBS/pokemon.txt","PBS/pokemon_metrics.txt","PBS/regional_dexes.txt"],
   :outputs=>["Data/metrics.dat","Data/regionals.dat","Data/evolutions.dat",
              "Data/dexdata.dat","Data/eggEmerald.dat","Data/attacksRS.rxdata",
              "Scripts/PBSpecies.rb"],
   :dependencies=>[:types,:abilities,:moves,:items]},
  {:id=>:machines,
   :label=>"machine data",
   :sources=>["PBS/tm.txt"],
   :outputs=>["Data/tm.dat"],
   :dependencies=>[:moves,:pokemon]},
  {:id=>:trainers,
   :label=>"Trainer data",
   :sources=>["PBS/trainertypes.txt","PBS/trainer_types.txt","PBS/trainers.txt"],
   :outputs=>["Data/trainertypes.dat","Data/trainers.dat","Scripts/PBTrainers.rb"],
   :dependencies=>[:abilities,:moves,:items,:pokemon]},
  {:id=>:battle_facility,
   :label=>"battle-facility Trainer data",
   :sources=>["PBS/trainerlists.txt"],
   :outputs=>["Data/trainerlists.dat"],
   :dependencies=>[:trainers,:pokemon,:moves,:items]},
  {:id=>:phone,
   :label=>"phone data",
   :sources=>["PBS/phone.txt"],
   :outputs=>["Data/phone.dat"],
   :dependencies=>[:trainers]},
  {:id=>:metadata,
   :label=>"metadata",
   :sources=>["PBS/metadata.txt","PBS/map_metadata.txt"],
   :outputs=>["Data/metadata.dat"],
   :dependencies=>[:trainers]},
  {:id=>:encounters,
   :label=>"encounter data",
   :sources=>["PBS/encounters.txt"],
   :outputs=>["Data/encounters.dat"],
   :dependencies=>[:pokemon]},
  {:id=>:bosses,
   :label=>"boss data",
   :sources=>["Scripts/BossInfo.rb"],
   :outputs=>["Data/bossdata.dat"],
   :dependencies=>[:abilities,:moves,:items,:pokemon]},
  {:id=>:shadow_moves,
   :label=>"shadow move data",
   :sources=>["PBS/shadowmoves.txt"],
   :outputs=>["Data/shadowmoves.dat"],
   :dependencies=>[:moves,:pokemon]},
  {:id=>:animations,
   :label=>"animation index",
   :sources=>["Data/PkmnAnimations.rxdata"],
   :outputs=>["Data/move2anim.dat"],
   :dependencies=>[:moves]}
] if !defined?(AZURE_PBS_COMPILE_STEPS)

def pbAzurePBSCompileSources(step)
  sources=step[:sources].clone
  case step[:id]
  when :trainers
    sources.delete("PBS/trainertypes.txt")
    sources.delete("PBS/trainer_types.txt")
    sources.unshift(pbGetTrainerTypesPBSFilename)
  when :pokemon
    if !pbUsesAltPokemonPBS("PBS/pokemon.txt")
      sources.delete("PBS/pokemon_metrics.txt")
      sources.delete("PBS/regional_dexes.txt")
    end
  when :metadata
    if !pbUsesSplitMetadataPBS("PBS/metadata.txt","PBS/map_metadata.txt")
      sources.delete("PBS/map_metadata.txt")
    end
  when :battle_facility
    sources.concat(pbTrainerListReferencedSources("PBS/trainerlists.txt"))
  end
  return sources
end

def pbAzurePBSCompileStepStatus(step)
  sources=pbAzurePBSCompileSources(step)
  missingOutputs=[]
  for output in step[:outputs]
    missingOutputs.push(output) if !safeExists?(output)
  end
  return {:changed=>true,:reason=>:missing_output,:files=>missingOutputs} if missingOutputs.length>0
  existingSources=[]
  for source in sources
    existingSources.push(source) if safeExists?(source)
  end
  return {:changed=>false,:reason=>:no_source,:files=>sources} if existingSources.length==0
  latestSource=existingSources[0]
  for source in existingSources
    latestSource=source if File.mtime(source)>File.mtime(latestSource)
  end
  oldestOutput=step[:outputs][0]
  for output in step[:outputs]
    oldestOutput=output if File.mtime(output)<File.mtime(oldestOutput)
  end
  if File.mtime(latestSource)>File.mtime(oldestOutput)
    return {:changed=>true,:reason=>:newer_source,:files=>[latestSource,oldestOutput]}
  end
  return {:changed=>false,:reason=>:current,:files=>[]}
rescue SystemCallError
  return {:changed=>true,:reason=>:unreadable_file,:files=>sources+step[:outputs]}
end

# Returns the ordered set of directly stale datasets and all dependants which
# must be rebuilt to keep symbolic IDs and compiled references consistent.
def pbPBSCompilePlan
  scheduled={}
  statuses={}
  for step in AZURE_PBS_COMPILE_STEPS
    status=pbAzurePBSCompileStepStatus(step)
    statuses[step[:id]]=status
    scheduled[step[:id]]=true if status[:changed]
  end
  changed=true
  while changed
    changed=false
    for step in AZURE_PBS_COMPILE_STEPS
      next if scheduled[step[:id]]
      for dependency in step[:dependencies]
        if scheduled[dependency]
          scheduled[step[:id]]=true
          statuses[step[:id]]={:changed=>true,:reason=>:dependency,:files=>[dependency]}
          changed=true
          break
        end
      end
    end
  end
  plan=[]
  for step in AZURE_PBS_COMPILE_STEPS
    next if !scheduled[step[:id]]
    plan.push({:step=>step,:status=>statuses[step[:id]]})
  end
  return plan
end

def pbRunAzurePBSCompileStep(id)
  case id
  when :types;         pbCompileTypes
  when :town_map;      pbCompileTownMap
  when :connections;   pbCompileConnections
  when :abilities;     pbCompileAbilities
  when :moves;         pbCompileMoves
  when :items;         pbCompileItems
  when :pokemon;       pbCompilePokemonData
  when :machines;      pbCompileMachines
  when :trainers;      pbCompileTrainers
  when :battle_facility; pbCompileTrainerLists
  when :phone;         pbCompilePhoneData
  when :metadata;      pbCompileMetadata
  when :encounters;    pbCompileEncounters
  when :bosses;        pbCompileBosses
  when :shadow_moves;  pbCompileShadowMoves
  when :animations;    pbCompileAnimations
  else
    raise _INTL("Unknown incremental compiler step: {1}",id)
  end
end

def pbRefreshAzureCompiledData(plan)
  ids=[]
  for entry in plan; ids.push(entry[:step][:id]); end
  AzureDataCache.clear if defined?(AzureDataCache)
  PBMoveData.clear_cache if ids.include?(:moves) && defined?(PBMoveData)
  PBItemData.clear_cache if ids.include?(:items) && defined?(PBItemData)
  PBAbilityData.clear_cache if ids.include?(:abilities) && defined?(PBAbilityData)
  PBSpeciesData.clear_cache if ids.include?(:pokemon) && defined?(PBSpeciesData)
  PBTrainerTypeData.clear_cache if ids.include?(:trainers) && defined?(PBTrainerTypeData)
  PBEncounterData.clear_cache if ids.include?(:encounters) && defined?(PBEncounterData)
  if ids.include?(:metadata)
    PBGlobalMetadataData.clear_cache if defined?(PBGlobalMetadataData)
    PBMapMetadataData.clear_cache if defined?(PBMapMetadataData)
  end
  AzureTrainerDataCache.clear if ids.include?(:trainers) && defined?(AzureTrainerDataCache)
  pbInvalidateBTTrainerLists if ids.include?(:battle_facility) && defined?(pbInvalidateBTTrainerLists)
  $tmData=nil if ids.include?(:machines) && defined?($tmData)
  if ids.include?(:animations)
    pbInvalidateBattleAnimationIndex if defined?(pbInvalidateBattleAnimationIndex)
    $pkmn_animations=nil if defined?($pkmn_animations)
  end
  if ids.include?(:types) && PBTypes.respond_to?(:class_variable_set)
    PBTypes.class_variable_set(:@@TypeData,nil) rescue nil
    PBTypeData.clear_cache if defined?(PBTypeData)
  end
  if ids.include?(:metadata) && defined?($PokemonTemp) && $PokemonTemp
    $PokemonTemp.pokemonMetadata=nil
  end
  if ids.include?(:encounters) && defined?($PokemonEncounters) && $PokemonEncounters &&
     defined?($game_map) && $game_map
    $PokemonEncounters.setup($game_map.map_id)
  end
end

# Compiles only the supplied/current plan. It deliberately excludes
# pbCompileTrainerEvents, whose map mutation pass belongs to Compile All Data.
def pbCompileChangedData(plan=nil)
  plan=pbPBSCompilePlan if !plan
  return [] if plan.length==0
  FileLineData.clear
  if (!$INEDITOR || LANGUAGES.length<2) && safeExists?("Data/messages.dat")
    MessageTypes.loadMessageFile("Data/messages.dat")
  end
  log=nil
  begin
    log=File.open("Data/compile_changed.log","wb")
    log.write("Pokemon Azure incremental compile - #{Time.now}\r\n")
    for entry in plan
      step=entry[:step]
      message=_INTL("Compiling {1}",step[:label])
      yield(message) if block_given?
      log.write("#{message}\r\n")
      log.flush
      pbRunAzurePBSCompileStep(step[:id])
    end
    MessageTypes.saveMessages
    pbRefreshAzureCompiledData(plan)
    log.write("Completed #{plan.length} step(s).\r\n")
  rescue Exception
    log.write("FAILED: #{$!.class}: #{$!.message}\r\n") if log
    raise
  ensure
    log.close if log
  end
  return plan
end

def pbCompileAllData(mustcompile,notrainers=false)
  #compilerruntime = Time.now
  FileLineData.clear
  if mustcompile
    if (!$INEDITOR || LANGUAGES.length<2) && pbRgssExists?("Data/messages.dat")
      MessageTypes.loadMessageFile("Data/messages.dat")
    end
    # No dependencies
    yield(_INTL("Compiling type data"))
    pbCompileTypes
    # No dependencies
    yield(_INTL("Compiling town map data"))
    pbCompileTownMap
    # No dependencies
    yield(_INTL("Compiling map connection data"))
    pbCompileConnections
    # No dependencies
    yield(_INTL("Compiling ability data"))
    pbCompileAbilities
    # Depends on PBTypes
    yield(_INTL("Compiling move data"))
    pbCompileMoves
    # Depends on PBMoves
    yield(_INTL("Compiling item data"))
    pbCompileItems
    # Depends on PBMoves, PBItems, PBTypes, PBAbilities
    yield(_INTL("Compiling Pokemon data"))
    pbCompilePokemonData
    # Depends on PBSpecies, PBMoves
    yield(_INTL("Compiling machine data"))
    pbCompileMachines
    # Depends on PBSpecies, PBItems, PBMoves
    yield(_INTL("Compiling Trainer data"))
    pbCompileTrainers
    # Depends on PBTrainers
    yield(_INTL("Compiling phone data"))
    pbCompilePhoneData
    # Depends on PBTrainers
    yield(_INTL("Compiling metadata"))
    pbCompileMetadata
    # Depends on PBTrainers
    yield(_INTL("Compiling battle Trainer data"))
    pbCompileTrainerLists
    # Depends on PBSpecies
    yield(_INTL("Compiling encounter data"))
    pbCompileEncounters
    # Depends on BossInfo.rb (not PBS)
    yield(_INTL("Compiling boss data"))
    pbCompileBosses
    # Depends on PBSpecies, PBMoves
    yield(_INTL("Compiling shadow move data"))
    pbCompileShadowMoves
    yield(_INTL("Compiling animations"))
    pbCompileAnimations
    return if notrainers
    yield(_INTL("Compiling messages"))
  else
    if (!$INEDITOR || LANGUAGES.length<2) && safeExists?("Data/messages.dat")
      MessageTypes.loadMessageFile("Data/messages.dat")
    end
  end
  pbCompileTrainerEvents(mustcompile)
  pbSetTextMessages
  MessageTypes.saveMessages
  if !$INEDITOR && LANGUAGES.length>=2
    pbLoadMessages("Data/"+LANGUAGES[$PokemonSystem.language][1])
  end
  #pbCombineScripts
  #totalcompilertime = Time.now - compilerruntime
  #print totalcompilertime
end

def pbImportNewMaps
  return false if !$DEBUG
  mapfiles={}
  # Get IDs of all maps in the Data folder
  Dir.chdir("Data"){
     mapdata=sprintf("Map*.%s","rxdata","rxdata")
     for map in Dir.glob(mapdata)
       if map[/map(\d+)\.rxdata/i]
         mapfiles[$1.to_i(10)]=true
       end
     end
  }
  mapinfos=pbLoadRxData("Data/MapInfos")
  maxOrder=0
  # Exclude maps found in mapinfos
  for id in mapinfos.keys
    next if !mapinfos.id
    if mapfiles[id]
      mapfiles.delete(id)
    end
    maxOrder=[maxOrder,mapinfos[id].order].max
  end
  # Import maps not found in mapinfos
  maxOrder+=1
  imported=false
  for id in mapfiles.keys
    next if id==999 # Ignore 999 (random dungeon map)
    mapname=sprintf("MAP%03d",id)
    mapinfo=RPG::MapInfo.new
    mapinfo.order=maxOrder
    maxOrder+=1
    mapinfo.name=mapname
    mapinfos[id]=mapinfo
    imported=true
  end
  if imported
    save_data(mapinfos,"Data/MapInfos.rxdata")
    Kernel.pbMessage(_INTL("New maps copied to the Data folder were successfully imported.",id))
  end
  return imported
end

def pbAltPBSEnsureDirectory(path)
  parts=path.gsub("\\","/").split("/")
  current=""
  for part in parts
    next if !part || part==""
    current=(current=="") ? part : current+"/"+part
    next if FileTest.directory?(current)
    Dir.mkdir(current)
  end
end

def pbAltPBSWriteText(path,lines)
  File.open(path,"wb"){|f|
     f.write(0xEF.chr)
     f.write(0xBB.chr)
     f.write(0xBF.chr)
     f.write(lines.join("\r\n"))
     f.write("\r\n") if lines.length>0
  }
end

def pbAltPBSCopyFile(source,destination)
  data=nil
  File.open(source,"rb"){|f| data=f.read }
  directory=File.dirname(destination).gsub("\\","/")
  pbAltPBSEnsureDirectory(directory) if directory && directory!="." && directory!=""
  File.open(destination,"wb"){|f| f.write(data) }
end

def pbAltPBSAppendSection(lines,header,fields,comments=nil)
  lines.push("#-------------------------------") if lines.length>0
  if comments
    for comment in comments
      next if !comment || comment==""
      lines.push("# #{comment}")
    end
  end
  lines.push("[#{header}]")
  for field in fields
    next if !field || !field[0]
    next if field[1]==nil || field[1]==""
    lines.push("#{field[0]} = #{field[1]}")
  end
end

def pbAltPBSReadLines(filename)
  lines=[]
  lineno=0
  File.open(filename,"rb"){|f|
     f.each_line {|line|
        lineno+=1
        if lineno==1 && line.respond_to?(:getbyte) && line.bytesize>=3 &&
           line.getbyte(0)==0xEF && line.getbyte(1)==0xBB && line.getbyte(2)==0xBF
          line=line.byteslice(3,line.bytesize-3) || ""
        end
        line=line.dup.force_encoding("UTF-8") if line.respond_to?(:force_encoding)
        line=line.gsub(/\r\n$/,"")
        line=line.gsub(/\n$/,"")
        lines.push([lineno,line])
     }
  }
  return lines
end

def pbAltPBSParseLegacySections(filename)
  FileLineData.file=filename
  sections=[]
  current=nil
  for rawline in pbAltPBSReadLines(filename)
    line=rawline[1]
    if line[/^\s*#(.*)$/]
      if current
        comment=$~[1].to_s.gsub(/^\s+/,"").gsub(/\s+$/,"")
        current[:comments].push(comment)
      end
      next
    end
    next if line[/^\s*$/]
    if line[/^\s*\[\s*(.*?)\s*\]\s*$/]
      current={:id=>$~[1],:fields=>[],:comments=>[],:lineno=>rawline[0]}
      sections.push(current)
      next
    end
    if !current
      raise _INTL("Expected a section at the beginning of {1}",filename)
    end
    if line[/^\s*([^=]+?)\s*=\s*(.*)$/]
      current[:fields].push([$~[1],$~[2],rawline[0]])
      next
    end
    FileLineData.setLine(line,rawline[0])
    AzurePBSValidation.error(_INTL("Bad line syntax in {1}; expected Property = Value.",filename))
  end
  return sections
end

def pbAltPBSFieldHash(section)
  ret={}
  for field in section[:fields]
    ret[field[0]]=field[1]
  end
  return ret
end

def pbAltPBSStatName(index)
  return ["HP","ATTACK","DEFENSE","SPEED","SPECIAL_ATTACK","SPECIAL_DEFENSE"][index]
end

def pbAltPBSEffortToPairs(value)
  return nil if !value || value==""
  stats=strsplit(value,/\s*,\s*/)
  return nil if !stats || stats.length<6
  pairs=[]
  for i in 0...6
    amount=stats[i].to_i
    next if amount<=0
    pairs.push(pbAltPBSStatName(i))
    pairs.push(amount.to_s)
  end
  return nil if pairs.length==0
  return pairs.join(",")
end

def pbAltPBSExpandLegacyIV(value)
  return nil if !value || value==""
  iv=value.to_i
  return "31,31,31,0,31,31" if iv==32
  return [iv,iv,iv,iv,iv,iv].join(",")
end

def pbAltPBSNormalizeGender(value)
  return nil if !value || value==""
  return "male" if value=="M" || value=="0"
  return "female" if value=="F" || value=="1"
  return value
end

def pbAltPBSNormalizeBoolean(value)
  return nil if !value || value==""
  return "true" if value=="shiny"
  return value.downcase if value=="true" || value=="false"
  return value
end

def pbAltPBSConstantName(mod,value)
  return nil if value==nil
  begin
    return getConstantName(mod,value)
  rescue
    return value.to_s
  end
end

def pbIsSectionedPBSFile(filename)
  for rawline in pbAltPBSReadLines(filename)
    line=rawline[1].to_s.gsub(/^\s+/,"").gsub(/\s+$/,"")
    next if line==""
    next if line[0,1]=="#"
    return !!(line[/^\[/])
  end
  return false
end

def pbAltPBSMoveFlagsToBitmask(flags)
  value=0
  return value if !flags
  value|=1 if flags[/a/]
  value|=2 if flags[/b/]
  value|=4 if flags[/c/]
  value|=8 if flags[/d/]
  value|=16 if flags[/e/]
  value|=32 if flags[/f/]
  value|=64 if flags[/g/]
  value|=128 if flags[/h/]
  value|=256 if flags[/i/]
  value|=512 if flags[/j/]
  value|=1024 if flags[/k/]
  value|=2048 if flags[/l/]
  value|=4096 if flags[/m/]
  value|=8192 if flags[/n/]
  value|=16384 if flags[/o/]
  value|=32768 if flags[/p/]
  return value
end

def pbUsesSplitMetadataPBS(metadataFile,mapMetadataFile)
  return false if !safeExists?(mapMetadataFile)
  sections=pbAltPBSParseLegacySections(metadataFile)
  for section in sections
    next if section[:id].to_i==0
    data=pbAltPBSFieldHash(section)
    return true if data["TrainerType"] || data["WalkCharset"] || data["RunCharset"]
  end
  return false
end

def pbGetTrainerTypesPBSFilename(baseDir="PBS")
  return baseDir+"/trainer_types.txt" if safeExists?(baseDir+"/trainer_types.txt")
  return baseDir+"/trainertypes.txt"
end

def pbUsesAltPokemonPBS(filename)
  for rawline in pbAltPBSReadLines(filename)
    line=rawline[1].to_s.gsub(/^\s+/,"").gsub(/\s+$/,"")
    next if line==""
    next if line[0,1]=="#"
    if line[/^\[\s*(.*?)\s*\]$/]
      return !$~[1][/^\d+$/]
    end
    return false
  end
  return false
end

def pbAltPBSLegacyEffortPoints(value)
  return nil if !value || value==""
  values=[0,0,0,0,0,0]
  statMap={
    "HP"=>0,
    "ATTACK"=>1,
    "ATK"=>1,
    "DEFENSE"=>2,
    "DEF"=>2,
    "SPEED"=>3,
    "SPD"=>3,
    "SPECIAL_ATTACK"=>4,
    "SPATK"=>4,
    "SP_ATTACK"=>4,
    "SPECIAL_DEFENSE"=>5,
    "SPDEF"=>5,
    "SP_DEFENSE"=>5
  }
  arr=strsplit(value,/\s*,\s*/)
  return nil if !arr || arr.length==0
  if arr.length==6 && arr.all?{|entry| entry[/^\d+$/]}
    return arr.join(",")
  end
  i=0
  while i<arr.length
    stat=arr[i].to_s.upcase
    amount=(arr[i+1] || "0").to_i
    statIndex=statMap[stat]
    raise _INTL("Unknown EV stat {1} in alt Pokemon data.",arr[i]) if statIndex==nil
    values[statIndex]=amount
    i+=2
  end
  return values.join(",")
end

def pbAltPBSFirstValue(value)
  return nil if !value || value==""
  values=strsplit(value,/\s*,\s*/)
  return values && values.length>0 ? values[0] : value
end

def pbAltPBSReadRegionalDexMap(filename,speciesCounts=nil)
  regionalMap={}
  return regionalMap if !safeExists?(filename)
  currentRegion=nil
  dexNumber=0
  regionKeys={}
  regionSpecies={}
  FileLineData.file=filename
  pbAltPBSReadLines(filename).each {|rawline|
    line=rawline[1].to_s
    next if line[/^\s*$/]
    next if line[/^\s*#/]
    if line[/^\s*\[\s*(\d+)\s*\]\s*(?:#.*)?$/]
      FileLineData.setLine(line,rawline[0])
      currentRegion=AzurePBSValidation.integer($~[1],"Regional dex ID",0,65535)
      AzurePBSValidation.unique(regionKeys,currentRegion,"regional dex",rawline[0])
      regionSpecies[currentRegion]={}
      dexNumber=0
      next
    end
    FileLineData.setLine(line,rawline[0])
    AzurePBSValidation.error("Regional dex data was defined before a region section.") if currentRegion==nil
    speciesList=AzurePBSValidation.csv_values(line,"Regional dex species list")
    for species in speciesList
      species=AzurePBSValidation.constant_symbol(species,"Regional dex species symbol")
      if speciesCounts && !speciesCounts.has_key?(species)
        AzurePBSValidation.error(_INTL("Regional dex {1} references undefined Pokemon {2}.",currentRegion,species))
      end
      AzurePBSValidation.unique(regionSpecies[currentRegion],species,
         _INTL("species in regional dex {1}",currentRegion),rawline[0])
      dexNumber+=1
      regionalMap[species]=[] if !regionalMap[species]
      regionalMap[species][currentRegion]=dexNumber
    end
  }
  return regionalMap
end

def pbAltPBSReadMetricsMap(filename,speciesCounts=nil)
  metricsMap={}
  return metricsMap if !safeExists?(filename)
  metricCounts={}
  for section in pbAltPBSParseLegacySections(filename)
    symbol=AzurePBSValidation.pokemon_metrics(section)
    if speciesCounts && !speciesCounts.has_key?(symbol)
      AzurePBSValidation.source(section)
      AzurePBSValidation.error(_INTL("Pokemon metrics section [{1}] has no matching Pokemon section.",symbol))
    end
    metricCounts[symbol]=(metricCounts[symbol] || 0)+1
    if speciesCounts && metricCounts[symbol]>speciesCounts[symbol]
      AzurePBSValidation.source(section)
      AzurePBSValidation.error(_INTL("Pokemon metrics section [{1}] is defined more often than its Pokemon section.",symbol))
    end
    metricsMap[section[:id]]=pbAltPBSFieldHash(section)
  end
  return metricsMap
end

def pbAltPBSBuildLegacyPokemonSections(pokemonFile,metricsFile,regionalDexFile)
  sections=[]
  sourceSections=pbAltPBSParseLegacySections(pokemonFile)
  validatedSections=[]
  speciesCounts={}
  for section in sourceSections
    validated=AzurePBSValidation.pokemon_section(section)
    speciesCounts[validated[:symbol]]=(speciesCounts[validated[:symbol]] || 0)+1
    validatedSections.push([section,validated])
  end
  metricsMap=pbAltPBSReadMetricsMap(metricsFile,speciesCounts)
  regionalMap=pbAltPBSReadRegionalDexMap(regionalDexFile,speciesCounts)
  for validatedSection in validatedSections
    section=validatedSection[0]
    validated=validatedSection[1]
    data=pbAltPBSFieldHash(section)
    currentmap=validated[:id]
    legacy={}
    legacy["InternalName"]=section[:id]
    legacy["Name"]=data["Name"] || data["LegacyName"]
    legacy["Kind"]=data["Category"] || data["Kind"] || data["LegacyKind"]
    legacy["Pokedex"]=data["Pokedex"] || data["LegacyPokedex"]
    legacy["Moves"]=data["Moves"] || data["LegacyMoves"]
    legacy["Color"]=data["Color"] || data["LegacyColor"]
    if data["Types"] && data["Types"]!=""
      types=strsplit(data["Types"],/\s*,\s*/)
      legacy["Type1"]=types[0]
      legacy["Type2"]=(types[1] && types[1]!="") ? types[1] : types[0]
    else
      legacy["Type1"]=data["Type1"] || data["LegacyType1"]
      legacy["Type2"]=data["Type2"] || data["LegacyType2"]
    end
    legacy["BaseStats"]=data["BaseStats"] || data["LegacyBaseStats"]
    legacy["Rareness"]=data["Rareness"] || data["CatchRate"] || data["LegacyRareness"]
    legacy["GenderRate"]=data["GenderRate"] || data["GenderRatio"] || data["LegacyGenderRate"]
    legacy["Happiness"]=data["Happiness"] || data["LegacyHappiness"]
    legacy["GrowthRate"]=data["GrowthRate"] || data["LegacyGrowthRate"]
    legacy["StepsToHatch"]=data["StepsToHatch"] || data["HatchSteps"] || data["LegacyStepsToHatch"]
    legacy["EffortPoints"]=data["LegacyEffortPoints"] || pbAltPBSLegacyEffortPoints(data["EVs"] || data["EffortPoints"])
    legacy["Compatibility"]=data["Compatibility"] || data["EggGroups"] || data["LegacyCompatibility"]
    legacy["Height"]=data["Height"] || data["LegacyHeight"]
    legacy["Weight"]=data["Weight"] || data["LegacyWeight"]
    legacy["BaseEXP"]=data["BaseEXP"] || data["BaseExp"] || data["LegacyBaseEXP"]
    legacy["EggMoves"]=data["EggMoves"] || data["LegacyEggMoves"]
    legacy["FormNames"]=data["FormNames"] || data["LegacyFormNames"]
    legacy["Evolutions"]=data["Evolutions"] || data["LegacyEvolutions"]
    legacy["Habitat"]=data["Habitat"] || data["LegacyHabitat"]
    legacy["Abilities"]=data["Abilities"] || data["LegacyAbilities"]
    legacy["HiddenAbility"]=data["HiddenAbility"] || data["LegacyHiddenAbility"] ||
                            pbAltPBSFirstValue(data["HiddenAbilities"] || data["LegacyHiddenAbilities"])
    legacy["WildItemCommon"]=data["WildItemCommon"] || data["LegacyWildItemCommon"]
    legacy["WildItemUncommon"]=data["WildItemUncommon"] || data["LegacyWildItemUncommon"]
    legacy["WildItemRare"]=data["WildItemRare"] || data["LegacyWildItemRare"]
    if data["RegionalNumbers"] && data["RegionalNumbers"]!=""
      legacy["RegionalNumbers"]=data["RegionalNumbers"]
    elsif regionalMap[section[:id]]
      values=[]
      for regionIndex in 0...regionalMap[section[:id]].length
        next if regionalMap[section[:id]][regionIndex]==nil
        values[regionIndex]=regionalMap[section[:id]][regionIndex].to_s
      end
      compactValues=[]
      for value in values
        compactValues.push(value ? value : "0")
      end
      legacy["RegionalNumbers"]=compactValues.join(",") if compactValues.length>0
    elsif data["LegacyRegionalNumbers"] && data["LegacyRegionalNumbers"]!=""
      legacy["RegionalNumbers"]=data["LegacyRegionalNumbers"]
    end
    metricData=metricsMap[section[:id]] || {}
    legacy["BattlerPlayerY"]=metricData["LegacyBattlerPlayerY"] || metricData["BattlerPlayerY"] || data["LegacyBattlerPlayerY"]
    legacy["BattlerEnemyY"]=metricData["LegacyBattlerEnemyY"] || metricData["BattlerEnemyY"] || data["LegacyBattlerEnemyY"]
    legacy["BattlerAltitude"]=metricData["LegacyBattlerAltitude"] || metricData["BattlerAltitude"] || data["LegacyBattlerAltitude"]
    sections.push([legacy,currentmap])
  end
  return sections
end

def pbAltPBSTrainerGenderToLegacy(value)
  return "" if !value || value==""
  normalized=value.to_s.downcase
  return "M" if normalized=="male" || normalized=="m"
  return "F" if normalized=="female" || normalized=="f"
  return value
end

def pbAltPBSTrainerBooleanToLegacy(value,shiny=false)
  return "" if !value || value==""
  normalized=value.to_s.downcase
  return "shiny" if shiny && normalized=="true"
  return "false" if normalized=="false"
  return "true" if normalized=="true"
  return value
end

def pbAltPBSTrainerBallToLegacy(value)
  return "" if !value || value==""
  return value if value.to_s[/^\d+$/]
  begin
    return pbGetBallType(parseItem(value)).to_s
  rescue
    return value
  end
end

def pbAltPBSTrainerIVToLegacy(value,legacyValue=nil)
  return legacyValue if legacyValue && legacyValue!=""
  return "" if !value || value==""
  values=strsplit(value,/\s*,\s*/)
  return value if !values || values.length<=1
  nums=values.map{|entry| entry.to_i}
  return "32" if nums==[31,31,31,0,31,31]
  return nums[0].to_s if nums.uniq.length==1
  raise _INTL("IV spread {1} cannot be represented by the legacy trainer compiler without LegacyIV.",value)
end

def pbAltPBSTrainerPokemonField?(key)
  return ["Item","Moves","AbilityIndex","Gender","Form","Shiny","Nature","IV",
          "LegacyIV","Happiness","Name","Shadow","Ball","LegacyHiddenPower",
          "HiddenPower","HPEV","AttackEV","DefenseEV","SpeedEV",
          "SpecialAttackEV","SpecialDefenseEV","PreMega","Boss","OverrideHP",
          "OverrideAttack","OverrideDefense","OverrideSpeed",
          "OverrideSpecialAttack","OverrideSpecialDefense"].include?(key)
end

def pbAltPBSApplyTrainerPokemonField(poke,key,value)
  case key
    when "Item"
      poke[TPITEM]=value
    when "Moves"
      moves=strsplit(value,/\s*,\s*/)
      poke[TPMOVE1]=moves[0] || ""
      poke[TPMOVE2]=moves[1] || ""
      poke[TPMOVE3]=moves[2] || ""
      poke[TPMOVE4]=moves[3] || ""
    when "AbilityIndex"
      poke[TPABILITY]=value
    when "Gender"
      poke[TPGENDER]=pbAltPBSTrainerGenderToLegacy(value)
    when "Form"
      poke[TPFORM]=value
    when "Shiny"
      poke[TPSHINY]=pbAltPBSTrainerBooleanToLegacy(value,true)
    when "Nature"
      poke[TPNATURE]=value
    when "IV"
      poke[TPIV]=pbAltPBSTrainerIVToLegacy(value,poke[TPIV])
    when "LegacyIV"
      poke[TPIV]=value
    when "Happiness"
      poke[TPHAPPINESS]=value
    when "Name"
      poke[TPNAME]=value
    when "Shadow"
      poke[TPSHADOW]=pbAltPBSTrainerBooleanToLegacy(value,false)
    when "Ball"
      poke[TPBALL]=pbAltPBSTrainerBallToLegacy(value)
    when "LegacyHiddenPower", "HiddenPower"
      poke[TPHIDDENPOWER]=value
    when "HPEV"
      poke[TPHPEV]=value
    when "AttackEV"
      poke[TPATKEV]=value
    when "DefenseEV"
      poke[TPDEFEV]=value
    when "SpeedEV"
      poke[TPSPEEV]=value
    when "SpecialAttackEV"
      poke[TPSPAEV]=value
    when "SpecialDefenseEV"
      poke[TPSPDEV]=value
    when "PreMega"
      poke[TPPREMEGA]=value
    when "Boss"
      poke[TPBOSS]=value
    when "OverrideHP"
      poke[TPHPOB]=value
    when "OverrideAttack"
      poke[TPATKOB]=value
    when "OverrideDefense"
      poke[TPDEFOB]=value
    when "OverrideSpeed"
      poke[TPSPEOB]=value
    when "OverrideSpecialAttack"
      poke[TPSPAOB]=value
    when "OverrideSpecialDefense"
      poke[TPSPDOB]=value
  end
end

def pbAltPBSBuildLegacyTrainerLines(filename)
  outputLines=[]
  outputLineNos=[]
  current=nil
  currentPokemon=nil
  flushTrainer=proc{|trainer|
    if !trainer
      nil
    else
    FileLineData.setLine("[#{trainer[:trainertype]},#{trainer[:name]},#{trainer[:partyid]}]",trainer[:lineno])
    AzurePBSValidation.required(trainer[:trainertype],"Trainer type")
    AzurePBSValidation.required(trainer[:name],"Trainer name")
    AzurePBSValidation.integer(trainer[:partyid],"Trainer party ID",0,255,true)
    AzurePBSValidation.count(trainer[:pokemon],"Trainer Pokemon list",1,6)
    AzurePBSValidation.count(trainer[:items],"Trainer battle item list",0,8)
    nameLine=trainer[:name].to_s
    nameLine+=",#{trainer[:partyid]}" if trainer[:partyid] && trainer[:partyid]!=""
    itemLine=trainer[:pokemon].length.to_s
    if trainer[:items] && trainer[:items].length>0
      itemLine+=","+trainer[:items].join(",")
    end
    outputLines.push(trainer[:trainertype].to_s)
    outputLineNos.push(trainer[:lineno])
    outputLines.push(nameLine)
    outputLineNos.push(trainer[:lineno])
    outputLines.push(itemLine)
    outputLineNos.push(trainer[:lineno])
    for pokemonData in trainer[:pokemon]
      outputLines.push(pokemonData[0].join(","))
      outputLineNos.push(pokemonData[1])
    end
    end
  }
  pbAltPBSReadLines(filename).each {|rawline|
    lineno=rawline[0]
    line=rawline[1].to_s
    next if line[/^\s*$/]
    next if line[/^\s*#/]
    if line[/^\s*\[\s*(.*?)\s*\]\s*$/]
      flushTrainer.call(current)
      headerParts=strsplit($~[1],/\s*,\s*/)
      FileLineData.setLine(line,lineno)
      AzurePBSValidation.count(headerParts,"Trainer section header",2,3)
      AzurePBSValidation.required(headerParts[0],"Trainer type")
      AzurePBSValidation.required(headerParts[1],"Trainer name")
      AzurePBSValidation.integer(headerParts[2],"Trainer party ID",0,255,true)
      current={
        :trainertype=>headerParts[0],
        :name=>headerParts[1],
        :partyid=>headerParts[2],
        :items=>[],
        :pokemon=>[],
        :lineno=>lineno
      }
      currentPokemon=nil
      next
    end
    raise _INTL("Expected a trainer section before data in alt trainers.txt.") if !current
    if line[/^\s*Pokemon\s*=\s*(.*)$/]
      values=strsplit($~[1],/\s*,\s*/)
      FileLineData.setLine(line,lineno)
      AzurePBSValidation.count(values,"Pokemon entry",2,2)
      AzurePBSValidation.required(values[0],"Pokemon species")
      AzurePBSValidation.integer(values[1],"Pokemon level",1,PBExperience::MAXLEVEL)
      poke=Array.new(TPDEFAULTS.length,"")
      poke[TSPECIES]=values[0]
      poke[TPLEVEL]=values[1]
      current[:pokemon].push([poke,lineno])
      currentPokemon=poke
      next
    end
    if !line[/^\s*(\w+)\s*=\s*(.*)$/]
      raise _INTL("Bad line syntax in alt trainers.txt: {1}",line)
    end
    key=$~[1]
    value=$~[2]
    FileLineData.setLine(line,lineno)
    isPokemonSubfield=(currentPokemon && (line[/^\s+/] || pbAltPBSTrainerPokemonField?(key)))
    if isPokemonSubfield
      AzurePBSValidation.known_property(key,["Item","Moves","AbilityIndex","Gender","Form","Shiny","Nature","IV",
        "LegacyIV","Happiness","Name","Shadow","Ball","LegacyHiddenPower","HiddenPower","HPEV","AttackEV",
        "DefenseEV","SpeedEV","SpecialAttackEV","SpecialDefenseEV","PreMega","Boss","OverrideHP",
        "OverrideAttack","OverrideDefense","OverrideSpeed","OverrideSpecialAttack","OverrideSpecialDefense"],
        "Trainer Pokemon")
      if key=="Moves"
        moves=strsplit(value,/\s*,\s*/) || []
        AzurePBSValidation.count(moves,"Trainer Pokemon move list",0,4)
      end
      pbAltPBSApplyTrainerPokemonField(currentPokemon,key,value)
    else
      AzurePBSValidation.known_property(key,["Items","LoseText","LegacyTrainerTypeID"],"Trainer")
      case key
        when "Items"
          current[:items]=strsplit(value,/\s*,\s*/) || []
        when "LoseText", "LegacyTrainerTypeID"
          next
      end
    end
  }
  flushTrainer.call(current)
  return [outputLines,outputLineNos]
end

def pbExportAltPokemonPBS(outputDir,sourceDir="PBS")
  pokemonFile=sourceDir+"/pokemon.txt"
  metricsFile=sourceDir+"/pokemon_metrics.txt"
  regionalDexFile=sourceDir+"/regional_dexes.txt"
  if pbUsesAltPokemonPBS(pokemonFile)
    pbAltPBSCopyFile(pokemonFile,outputDir+"/pokemon.txt")
    pbAltPBSCopyFile(metricsFile,outputDir+"/pokemon_metrics.txt") if safeExists?(metricsFile)
    pbAltPBSCopyFile(regionalDexFile,outputDir+"/regional_dexes.txt") if safeExists?(regionalDexFile)
    return
  end
  pokemonLines=[]
  metricsLines=[]
  regionalDexes=[]
  pokemonLines.push("# Generated from the legacy PBS layout.")
  pokemonLines.push("# Alternate forms remain script-backed in Scripts/PokemonMultipleForms.rb.")
  metricsLines.push("# Generated from legacy battler metric fields that do not map cleanly to v21 metrics.")
  for section in pbAltPBSParseLegacySections(pokemonFile)
    data=pbAltPBSFieldHash(section)
    next if !data["InternalName"] || data["InternalName"]==""
    handled={}
    fields=[]
    comments=[]
    comments.push("Legacy species ID #{section[:id]}")
    fields.push(["LegacySpeciesID",section[:id].to_s]); handled["LegacySpeciesID"]=true
    fields.push(["Name",data["Name"]]); handled["Name"]=true
    if data["Type1"] && data["Type1"]!=""
      types=[data["Type1"]]
      if data["Type2"] && data["Type2"]!="" && data["Type2"]!=data["Type1"]
        types.push(data["Type2"])
      end
      fields.push(["Types",types.join(",")])
    end
    handled["Type1"]=true
    handled["Type2"]=true
    fields.push(["BaseStats",data["BaseStats"]]); handled["BaseStats"]=true
    fields.push(["GenderRatio",data["GenderRate"]]); handled["GenderRate"]=true
    fields.push(["GrowthRate",data["GrowthRate"]]); handled["GrowthRate"]=true
    fields.push(["BaseExp",data["BaseEXP"]]); handled["BaseEXP"]=true
    evs=pbAltPBSEffortToPairs(data["EffortPoints"])
    fields.push(["EVs",evs]); handled["EffortPoints"]=true
    fields.push(["CatchRate",data["Rareness"]]); handled["Rareness"]=true
    fields.push(["Happiness",data["Happiness"]]); handled["Happiness"]=true
    fields.push(["Abilities",data["Abilities"]]); handled["Abilities"]=true
    fields.push(["HiddenAbilities",data["HiddenAbility"]]); handled["HiddenAbility"]=true
    fields.push(["Moves",data["Moves"]]); handled["Moves"]=true
    fields.push(["EggMoves",data["EggMoves"]]); handled["EggMoves"]=true
    fields.push(["EggGroups",data["Compatibility"]]); handled["Compatibility"]=true
    fields.push(["HatchSteps",data["StepsToHatch"]]); handled["StepsToHatch"]=true
    fields.push(["Height",data["Height"]]); handled["Height"]=true
    fields.push(["Weight",data["Weight"]]); handled["Weight"]=true
    fields.push(["Color",data["Color"]]); handled["Color"]=true
    fields.push(["Habitat",data["Habitat"]]); handled["Habitat"]=true
    fields.push(["Category",data["Kind"]]); handled["Kind"]=true
    fields.push(["Pokedex",data["Pokedex"]]); handled["Pokedex"]=true
    fields.push(["Evolutions",data["Evolutions"]]); handled["Evolutions"]=true
    fields.push(["WildItemCommon",data["WildItemCommon"]]); handled["WildItemCommon"]=true
    fields.push(["WildItemUncommon",data["WildItemUncommon"]]); handled["WildItemUncommon"]=true
    fields.push(["WildItemRare",data["WildItemRare"]]); handled["WildItemRare"]=true
    fields.push(["LegacyRegionalNumbers",data["RegionalNumbers"]]); handled["RegionalNumbers"]=true
    fields.push(["LegacyFormNames",data["FormNames"]]); handled["FormNames"]=true
    handled["BattlerPlayerY"]=true
    handled["BattlerEnemyY"]=true
    handled["BattlerAltitude"]=true
    for field in section[:fields]
      next if handled[field[0]]
      next if field[0]=="InternalName"
      fields.push(["Legacy#{field[0]}",field[1]])
    end
    pbAltPBSAppendSection(pokemonLines,data["InternalName"],fields,comments)
    if data["BattlerPlayerY"] || data["BattlerEnemyY"] || data["BattlerAltitude"]
      metricFields=[]
      metricFields.push(["LegacyBattlerPlayerY",data["BattlerPlayerY"]])
      metricFields.push(["LegacyBattlerEnemyY",data["BattlerEnemyY"]])
      metricFields.push(["LegacyBattlerAltitude",data["BattlerAltitude"]])
      pbAltPBSAppendSection(metricsLines,data["InternalName"],metricFields,nil)
    end
    if data["RegionalNumbers"] && data["RegionalNumbers"]!=""
      numbers=strsplit(data["RegionalNumbers"],/\s*,\s*/)
      for regionIndex in 0...numbers.length
        regnum=numbers[regionIndex].to_i
        next if regnum<=0
        regionalDexes[regionIndex]=[] if !regionalDexes[regionIndex]
        regionalDexes[regionIndex][regnum]=data["InternalName"]
      end
    end
  end
  regionalLines=[]
  regionalLines.push("# Generated from legacy RegionalNumbers entries.")
  regionalLines.push("# Exact source values are also preserved per species in pokemon.txt.")
  for regionIndex in 0...regionalDexes.length
    next if !regionalDexes[regionIndex]
    pbAltPBSAppendSection(regionalLines,regionIndex.to_s,[],nil)
    lineBuffer=[]
    for dexnum in 1...regionalDexes[regionIndex].length
      species=regionalDexes[regionIndex][dexnum]
      next if !species || species==""
      lineBuffer.push(species)
      if lineBuffer.length>=10
        regionalLines.push(lineBuffer.join(","))
        lineBuffer=[]
      end
    end
    regionalLines.push(lineBuffer.join(",")) if lineBuffer.length>0
  end
  pbAltPBSWriteText(outputDir+"/pokemon.txt",pokemonLines)
  pbAltPBSWriteText(outputDir+"/pokemon_metrics.txt",metricsLines)
  pbAltPBSWriteText(outputDir+"/regional_dexes.txt",regionalLines)
end

def pbExportAltMovesPBS(outputDir,sourceDir="PBS")
  movesFile=sourceDir+"/moves.txt"
  if pbIsSectionedPBSFile(movesFile)
    pbAltPBSCopyFile(movesFile,outputDir+"/moves.txt")
    return
  end
  lines=[]
  lines.push("# Generated from the legacy move CSV.")
  lines.push("# LegacyFunctionCode/LegacyTarget/LegacyFlags are preserved for compiler compatibility.")
  schema=[0,"vnsxueeuuuxiss",
        nil,nil,nil,nil,nil,PBTypes,["Physical","Special","Status"],
        nil,nil,nil,nil,nil,nil,nil]
  pbCompilerEachPreppedLine(movesFile){|line,lineno|
     record=pbGetCsvRecord(line,lineno,schema)
     fields=[]
     fields.push(["LegacyMoveID",record[0].to_s])
     fields.push(["Name",record[2]])
     fields.push(["Type",pbAltPBSConstantName(PBTypes,record[5])])
     fields.push(["Category",["Physical","Special","Status"][record[6]]])
     fields.push(["Power",record[4].to_s])
     fields.push(["Accuracy",record[7].to_s])
     fields.push(["TotalPP",record[8].to_s])
     fields.push(["EffectChance",record[9].to_s])
     fields.push(["Priority",record[11].to_s])
     fields.push(["Description",record[13]])
     fields.push(["LegacyFunctionCode",record[3]])
     fields.push(["LegacyTarget",record[10].to_s])
     fields.push(["LegacyFlags",record[12]])
     pbAltPBSAppendSection(lines,record[1],fields,nil)
  }
  pbAltPBSWriteText(outputDir+"/moves.txt",lines)
end

def pbExportAltAbilitiesPBS(outputDir,sourceDir="PBS")
  abilitiesFile=sourceDir+"/abilities.txt"
  if pbIsSectionedPBSFile(abilitiesFile)
    pbAltPBSCopyFile(abilitiesFile,outputDir+"/abilities.txt")
    return
  end
  lines=[]
  lines.push("# Generated from the legacy ability CSV.")
  pbCompilerEachPreppedLine(abilitiesFile){|line,lineno|
     record=pbGetCsvRecord(line,lineno,[0,"vnss"])
     fields=[]
     fields.push(["LegacyAbilityID",record[0].to_s])
     fields.push(["Name",record[2]])
     fields.push(["Description",record[3]])
     pbAltPBSAppendSection(lines,record[1],fields,nil)
  }
  pbAltPBSWriteText(outputDir+"/abilities.txt",lines)
end

def pbExportAltItemsPBS(outputDir,sourceDir="PBS")
  itemsFile=sourceDir+"/items.txt"
  if pbIsSectionedPBSFile(itemsFile)
    pbAltPBSCopyFile(itemsFile,outputDir+"/items.txt")
    return
  end
  lines=[]
  lines.push("# Named item sections with Azure's legacy runtime fields preserved.")
  pbCompilerEachCommentedLine(itemsFile){|line,lineno|
    record=pbGetCsvRecord(line,lineno,[0,"vnsuusuuUN"])
    fields=[]
    fields.push(["LegacyItemID",record[0].to_s])
    fields.push(["Name",record[2]])
    fields.push(["Pocket",record[3].to_s])
    fields.push(["Price",record[4].to_s])
    fields.push(["Description",record[5]])
    fields.push(["FieldUse",record[6].to_s])
    fields.push(["BattleUse",record[7].to_s])
    fields.push(["Type",record[8].to_s])
    fields.push(["Move",record[9]]) if record[9] && record[9]!=""
    pbAltPBSAppendSection(lines,record[1],fields,nil)
  }
  pbAltPBSWriteText(outputDir+"/items.txt",lines)
end

def pbExportAltMetadataPBS(outputDir,sourceDir="PBS")
  metadataFile=sourceDir+"/metadata.txt"
  mapMetadataFile=sourceDir+"/map_metadata.txt"
  if pbUsesSplitMetadataPBS(metadataFile,mapMetadataFile)
    pbAltPBSCopyFile(metadataFile,outputDir+"/metadata.txt")
    pbAltPBSCopyFile(mapMetadataFile,outputDir+"/map_metadata.txt") if safeExists?(mapMetadataFile)
    return
  end
  metadataLines=[]
  mapMetadataLines=[]
  metadataLines.push("# Generated from legacy metadata.txt.")
  mapMetadataLines.push("# Generated from legacy metadata.txt map sections.")
  playerKeys=["PlayerA","PlayerB","PlayerC","PlayerD","PlayerE","PlayerF","PlayerG","PlayerH","PlayerI",
              "PlayerJ","PlayerK","PlayerL","PlayerM","PlayerN","PlayerO","PlayerP","PlayerQ","PlayerR",
              "PlayerS","PlayerT","PlayerU","PlayerV","PlayerW","PlayerX","PlayerY"]
  sections=pbAltPBSParseLegacySections(metadataFile)
  for section in sections
    data=pbAltPBSFieldHash(section)
    if section[:id].to_i==0
      handled={}
      globalFields=[]
      globalFields.push(["Home",data["Home"]]); handled["Home"]=true
      globalFields.push(["WildBattleBGM",data["WildBattleBGM"]]); handled["WildBattleBGM"]=true
      globalFields.push(["TrainerBattleBGM",data["TrainerBattleBGM"]]); handled["TrainerBattleBGM"]=true
      globalFields.push(["WildVictoryBGM",data["WildVictoryME"]]); handled["WildVictoryME"]=true
      globalFields.push(["TrainerVictoryBGM",data["TrainerVictoryME"]]); handled["TrainerVictoryME"]=true
      globalFields.push(["SurfBGM",data["SurfBGM"]]); handled["SurfBGM"]=true
      globalFields.push(["BicycleBGM",data["BicycleBGM"]]); handled["BicycleBGM"]=true
      for playerKey in playerKeys
        handled[playerKey]=true if data[playerKey] && data[playerKey]!=""
      end
      extraGlobalFields=[]
      for field in section[:fields]
        next if handled[field[0]]
        extraGlobalFields.push(["Legacy#{field[0]}",field[1]])
      end
      for extraField in extraGlobalFields
        globalFields.push(extraField)
      end
      pbAltPBSAppendSection(metadataLines,"0",globalFields,nil)
      playerIndex=1
      for playerKey in playerKeys
        next if !data[playerKey] || data[playerKey]==""
        values=strsplit(data[playerKey],/\s*,\s*/)
        playerFields=[]
        playerFields.push(["LegacyPlayerSlot",playerKey])
        playerFields.push(["TrainerType",values[0]])
        playerFields.push(["WalkCharset",values[1]])
        playerFields.push(["CycleCharset",values[2]])
        playerFields.push(["SurfCharset",values[3]])
        playerFields.push(["RunCharset",values[4]])
        playerFields.push(["DiveCharset",values[5]])
        playerFields.push(["FishCharset",values[6]])
        playerFields.push(["SurfFishCharset",values[7]])
        pbAltPBSAppendSection(metadataLines,playerIndex.to_s,playerFields,nil)
        playerIndex+=1
      end
    else
      handled={}
      mapFields=[]
      comment=nil
      for entry in section[:comments]
        next if !entry || entry==""
        next if entry[/^-+$/]
        comment=entry
        break
      end
      mapFields.push(["Name",comment]) if comment
      handled["Name"]=true if comment
      mapFields.push(["Outdoor",data["Outdoor"]]); handled["Outdoor"]=true
      mapFields.push(["ShowArea",data["ShowArea"]]); handled["ShowArea"]=true
      mapFields.push(["Bicycle",data["Bicycle"]]); handled["Bicycle"]=true
      mapFields.push(["BicycleAlways",data["BicycleAlways"]]); handled["BicycleAlways"]=true
      mapFields.push(["HealingSpot",data["HealingSpot"]]); handled["HealingSpot"]=true
      mapFields.push(["Weather",data["Weather"]]); handled["Weather"]=true
      mapFields.push(["MapPosition",data["MapPosition"]]); handled["MapPosition"]=true
      mapFields.push(["DiveMap",data["DiveMap"]]); handled["DiveMap"]=true
      mapFields.push(["DarkMap",data["DarkMap"]]); handled["DarkMap"]=true
      mapFields.push(["SafariMap",data["SafariMap"]]); handled["SafariMap"]=true
      mapFields.push(["SnapEdges",data["SnapEdges"]]); handled["SnapEdges"]=true
      mapFields.push(["Dungeon",data["Dungeon"]]); handled["Dungeon"]=true
      mapFields.push(["BattleBack",data["BattleBack"]]); handled["BattleBack"]=true
      mapFields.push(["WildBattleBGM",data["WildBattleBGM"]]); handled["WildBattleBGM"]=true
      mapFields.push(["TrainerBattleBGM",data["TrainerBattleBGM"]]); handled["TrainerBattleBGM"]=true
      mapFields.push(["WildVictoryBGM",data["WildVictoryME"]]); handled["WildVictoryME"]=true
      mapFields.push(["TrainerVictoryBGM",data["TrainerVictoryME"]]); handled["TrainerVictoryME"]=true
      mapFields.push(["MapSize",data["MapSize"]]); handled["MapSize"]=true
      for field in section[:fields]
        next if handled[field[0]]
        mapFields.push(["Legacy#{field[0]}",field[1]])
      end
      pbAltPBSAppendSection(mapMetadataLines,sprintf("%03d",section[:id].to_i),mapFields,nil)
    end
  end
  pbAltPBSWriteText(outputDir+"/metadata.txt",metadataLines)
  pbAltPBSWriteText(outputDir+"/map_metadata.txt",mapMetadataLines)
end

def pbExportAltEncountersPBS(outputDir,sourceDir="PBS")
  encountersFile=sourceDir+"/encounters.txt"
  if pbIsSectionedPBSFile(encountersFile)
    pbAltPBSCopyFile(encountersFile,outputDir+"/encounters.txt")
    return
  end
  lines=[]
  linenos=[]
  File.open(encountersFile,"rb"){|f|
     lineno=1
     f.each_line {|line|
        if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
          line=line[3,line.length-3]
        end
        line=prepline(line)
        if line.length!=0
          lines.push(line)
          linenos.push(lineno)
        end
        lineno+=1
     }
  }
  encounters={}
  encounterOrder=[]
  thisenc=nil
  needdensity=false
  lastmapid=-1
  i=0
  while i<lines.length
    line=lines[i]
    mapid=line[/^\d+$/]
    if mapid
      thisenc=[EncounterTypes::EnctypeDensities.clone,[]]
      encounters[mapid.to_i]=thisenc
      encounterOrder.push(mapid.to_i)
      needdensity=true
      lastmapid=mapid.to_i
      i+=1
      next
    end
    enc=findIndex(EncounterTypes::Names){|val| val==line}
    if enc>=0
      needdensity=false
      enclines=EncounterTypes::EnctypeChances[enc].length
      encarray=[]
      j=i+1
      k=0
      while j<lines.length && k<enclines
        splitarr=strsplit(lines[j],/\s*,\s*/)
        break if !splitarr || splitarr.length<2
        splitarr[2]=splitarr[1] if splitarr.length==2
        splitarr[0]=parseSpecies(splitarr[0])
        splitarr[1]=splitarr[1].to_i
        splitarr[2]=splitarr[2].to_i
        encarray.push(splitarr)
        j+=1
        k+=1
      end
      thisenc[1][enc]=encarray
      i=j
    elsif needdensity
      needdensity=false
      nums=strsplit(line,/,/)
      for j in 0...EncounterTypes::EnctypeChances.length
        next if !EncounterTypes::EnctypeChances[j] ||
                EncounterTypes::EnctypeChances[j].length==0
        next if EncounterTypes::EnctypeCompileDens[j]==0
        thisenc[0][j]=nums[EncounterTypes::EnctypeCompileDens[j]-1].to_i
      end
      i+=1
    else
      i+=1
    end
  end
  output=[]
  output.push("# Generated from the legacy encounter slot format.")
  for mapid in encounterOrder
    entry=encounters[mapid]
    next if !entry
    pbAltPBSAppendSection(output,sprintf("%03d",mapid),[],nil)
    for enc in 0...EncounterTypes::Names.length
      next if !entry[1][enc] || entry[1][enc].length==0
      density=entry[0][enc]
      if EncounterTypes::EnctypeCompileDens[enc]>0
        output.push("#{EncounterTypes::Names[enc]},#{density}")
      else
        output.push(EncounterTypes::Names[enc])
      end
      for index in 0...entry[1][enc].length
        slot=entry[1][enc][index]
        species=pbAltPBSConstantName(PBSpecies,slot[0])
        chance=EncounterTypes::EnctypeChances[enc][index]
        if slot[1]==slot[2]
          output.push("    #{chance},#{species},#{slot[1]}")
        else
          output.push("    #{chance},#{species},#{slot[1]},#{slot[2]}")
        end
      end
    end
  end
  pbAltPBSWriteText(outputDir+"/encounters.txt",output)
end

def pbExportAltTrainerTypesPBS(outputDir,sourceDir="PBS")
  lines=[]
  lines.push("# Generated from the legacy trainer type CSV.")
  trainerTypesFile=pbGetTrainerTypesPBSFilename(sourceDir)
  if pbIsSectionedPBSFile(trainerTypesFile)
    pbAltPBSCopyFile(trainerTypesFile,outputDir+"/trainer_types.txt")
    return
  end
  schema=[0,"unsUSSSeU",nil,nil,nil,nil,nil,nil,nil,{
        ""=>2,"Male"=>0,"M"=>0,"0"=>0,"Female"=>1,"F"=>1,"1"=>1,"Mixed"=>2,"X"=>2,"2"=>2
        },nil]
  pbCompilerEachPreppedLine(trainerTypesFile){|line,lineno|
     record=pbGetCsvRecord(line,lineno,schema)
     fields=[]
     fields.push(["LegacyTrainerTypeID",record[0].to_s])
     fields.push(["Name",record[2]])
     fields.push(["BaseMoney",record[3].to_s]) if record[3]!=nil
     fields.push(["BattleBGM",record[4]])
     fields.push(["VictoryBGM",record[5]])
     fields.push(["IntroBGM",record[6]])
     fields.push(["Gender",["Male","Female","Mixed"][record[7] || 2]])
     fields.push(["SkillLevel",record[8].to_s]) if record[8]!=nil
     pbAltPBSAppendSection(lines,record[1],fields,nil)
  }
  pbAltPBSWriteText(outputDir+"/trainer_types.txt",lines)
end

def pbExportAltTrainersPBS(outputDir,sourceDir="PBS")
  trainersFile=sourceDir+"/trainers.txt"
  if pbIsSectionedPBSFile(trainersFile)
    pbAltPBSCopyFile(trainersFile,outputDir+"/trainers.txt")
    return
  end
  rawlines=[]
  linenos=[]
  lineno=1
  File.open(trainersFile,"rb"){|f|
     f.each_line {|line|
        if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
          line=line[3,line.length-3]
        end
        line=prepline(line)
        if line!=""
          rawlines.push(line)
          linenos.push(lineno)
        end
        lineno+=1
     }
  }
  lines=[]
  lines.push("# Generated from the legacy trainer block format.")
  lines.push("# Custom keys preserve data that does not exist in the stock v21 trainer schema.")
  i=0
  while i<rawlines.length
    trainertype=rawlines[i]
    nameline=strsplit(rawlines[i+1],/\s*,\s*/)
    trainername=nameline[0]
    partyid=nameline[1]
    items=strsplit(rawlines[i+2],/\s*,\s*/)
    numpoke=items[0].to_i
    header=(partyid && partyid!="") ? "#{trainertype},#{trainername},#{partyid}" : "#{trainertype},#{trainername}"
    fields=[]
    begin
      fields.push(["LegacyTrainerTypeID",parseTrainer(trainertype).to_s])
    rescue
    end
    if items.length>1
      helditems=[]
      for itemIndex in 1...items.length
        helditems.push(items[itemIndex]) if items[itemIndex] && items[itemIndex]!=""
      end
      fields.push(["Items",helditems.join(",")]) if helditems.length>0
    end
    pbAltPBSAppendSection(lines,header,fields,nil)
    for j in 0...numpoke
      poke=strsplit(rawlines[i+j+3],/\s*,\s*/)
      lines.push("Pokemon = #{poke[TSPECIES]},#{poke[TPLEVEL]}")
      moveList=[]
      for moveIndex in [TPMOVE1,TPMOVE2,TPMOVE3,TPMOVE4]
        moveList.push(poke[moveIndex]) if poke[moveIndex] && poke[moveIndex]!=""
      end
      lines.push("    Item = #{poke[TPITEM]}") if poke[TPITEM] && poke[TPITEM]!=""
      lines.push("    Moves = #{moveList.join(",")}") if moveList.length>0
      lines.push("    AbilityIndex = #{poke[TPABILITY]}") if poke[TPABILITY] && poke[TPABILITY]!=""
      gender=pbAltPBSNormalizeGender(poke[TPGENDER])
      lines.push("    Gender = #{gender}") if gender && gender!=""
      lines.push("    Form = #{poke[TPFORM]}") if poke[TPFORM] && poke[TPFORM]!=""
      shiny=pbAltPBSNormalizeBoolean(poke[TPSHINY])
      lines.push("    Shiny = #{shiny}") if shiny && shiny!=""
      lines.push("    Nature = #{poke[TPNATURE]}") if poke[TPNATURE] && poke[TPNATURE]!=""
      if poke[TPIV] && poke[TPIV]!=""
        lines.push("    IV = #{pbAltPBSExpandLegacyIV(poke[TPIV])}")
        lines.push("    LegacyIV = #{poke[TPIV]}")
      end
      lines.push("    Happiness = #{poke[TPHAPPINESS]}") if poke[TPHAPPINESS] && poke[TPHAPPINESS]!=""
      lines.push("    Name = #{poke[TPNAME]}") if poke[TPNAME] && poke[TPNAME]!=""
      shadow=pbAltPBSNormalizeBoolean(poke[TPSHADOW])
      lines.push("    Shadow = #{shadow}") if shadow && shadow!=""
      lines.push("    Ball = #{poke[TPBALL]}") if poke[TPBALL] && poke[TPBALL]!=""
      lines.push("    LegacyHiddenPower = #{poke[TPHIDDENPOWER]}") if poke[TPHIDDENPOWER] && poke[TPHIDDENPOWER]!=""
      lines.push("    HPEV = #{poke[TPHPEV]}") if poke[TPHPEV] && poke[TPHPEV]!=""
      lines.push("    AttackEV = #{poke[TPATKEV]}") if poke[TPATKEV] && poke[TPATKEV]!=""
      lines.push("    DefenseEV = #{poke[TPDEFEV]}") if poke[TPDEFEV] && poke[TPDEFEV]!=""
      lines.push("    SpeedEV = #{poke[TPSPEEV]}") if poke[TPSPEEV] && poke[TPSPEEV]!=""
      lines.push("    SpecialAttackEV = #{poke[TPSPAEV]}") if poke[TPSPAEV] && poke[TPSPAEV]!=""
      lines.push("    SpecialDefenseEV = #{poke[TPSPDEV]}") if poke[TPSPDEV] && poke[TPSPDEV]!=""
      lines.push("    PreMega = #{poke[TPPREMEGA]}") if poke[TPPREMEGA] && poke[TPPREMEGA]!=""
      lines.push("    Boss = #{poke[TPBOSS]}") if poke[TPBOSS] && poke[TPBOSS]!=""
      lines.push("    OverrideHP = #{poke[TPHPOB]}") if poke[TPHPOB] && poke[TPHPOB]!=""
      lines.push("    OverrideAttack = #{poke[TPATKOB]}") if poke[TPATKOB] && poke[TPATKOB]!=""
      lines.push("    OverrideDefense = #{poke[TPDEFOB]}") if poke[TPDEFOB] && poke[TPDEFOB]!=""
      lines.push("    OverrideSpeed = #{poke[TPSPEOB]}") if poke[TPSPEOB] && poke[TPSPEOB]!=""
      lines.push("    OverrideSpecialAttack = #{poke[TPSPAOB]}") if poke[TPSPAOB] && poke[TPSPAOB]!=""
      lines.push("    OverrideSpecialDefense = #{poke[TPSPDOB]}") if poke[TPSPDOB] && poke[TPSPDOB]!=""
    end
    i+=3+numpoke
  end
  pbAltPBSWriteText(outputDir+"/trainers.txt",lines)
end

def pbExportAltShadowMovesPBS(outputDir,sourceDir="PBS")
  source=sourceDir+"/shadowmoves.txt"
  return if !safeExists?(source)
  if pbIsSectionedPBSFile(source)
    pbAltPBSCopyFile(source,outputDir+"/shadowmoves.txt")
    return
  end
  lines=[]
  for rawline in pbAltPBSReadLines(source)
    line=rawline[1].to_s.gsub(/^\s+/,"").gsub(/\s+$/ ,"")
    next if line=="" || line[0,1]=="#"
    if !line[/^([^=]+)=(.*)$/]
      raise _INTL("Bad Shadow move line at {1}: {2}",rawline[0],line)
    end
    species=$~[1].to_s.gsub(/^\s+/,"").gsub(/\s+$/ ,"")
    moves=$~[2].to_s.gsub(/^\s+/,"").gsub(/\s+$/ ,"")
    pbAltPBSAppendSection(lines,species,[["Moves",moves]],nil)
  end
  pbAltPBSWriteText(outputDir+"/shadowmoves.txt",lines)
end

def pbConnectionPointText(first,second)
  sideNames={"N"=>"North","E"=>"East","S"=>"South","W"=>"West"}
  first=sideNames[first] if sideNames[first]
  return "#{first},#{second}"
end

def pbExportAltConnectionsPBS(outputDir,sourceDir="PBS")
  source=sourceDir+"/connections.txt"
  return if !safeExists?(source)
  if pbIsSectionedPBSFile(source)
    pbAltPBSCopyFile(source,outputDir+"/connections.txt")
    return
  end
  records=pbReadConnectionRecords(source)
  lines=[]
  if records.length==0
    lines.push("# No map connections are currently defined.")
    lines.push("# Add sections with Map1, Map1Point, Map2, and Map2Point properties.")
  end
  for i in 0...records.length
    record=records[i]
    fields=[
      ["Map1",record[0]],
      ["Map1Point",pbConnectionPointText(record[1],record[2])],
      ["Map2",record[3]],
      ["Map2Point",pbConnectionPointText(record[4],record[5])]
    ]
    pbAltPBSAppendSection(lines,sprintf("Connection_%03d",i+1),fields,nil)
  end
  pbAltPBSWriteText(outputDir+"/connections.txt",lines)
end

AZURE_PBS_TRACKED_FILES=[
  "pokemon.txt","pokemon_metrics.txt","regional_dexes.txt",
  "moves.txt","abilities.txt","items.txt","types.txt","tm.txt",
  "encounters.txt","connections.txt","townmap.txt","metadata.txt",
  "map_metadata.txt","phone.txt","shadowmoves.txt","trainerlists.txt",
  "trainers.txt","trainertypes.txt","trainer_types.txt","README.txt"
] if !defined?(AZURE_PBS_TRACKED_FILES)

def pbAzurePBSTrackedFiles(sourceDir="PBS")
  files=AZURE_PBS_TRACKED_FILES.clone
  listSource=sourceDir+"/trainerlists.txt"
  if safeExists?(listSource)
    for filename in pbTrainerListReferencedSources(listSource,"")
      files.push(filename) if !files.include?(filename)
    end
  end
  return files
end

def pbExportAltPBSFiles(outputDir="PBS/AltMigration",sourceDir="PBS")
  pbAltPBSEnsureDirectory(outputDir)
  pbExportAltPokemonPBS(outputDir,sourceDir)
  pbExportAltMovesPBS(outputDir,sourceDir)
  pbExportAltAbilitiesPBS(outputDir,sourceDir)
  pbExportAltItemsPBS(outputDir,sourceDir)
  pbExportAltMetadataPBS(outputDir,sourceDir)
  pbExportAltEncountersPBS(outputDir,sourceDir)
  pbExportAltTrainerTypesPBS(outputDir,sourceDir)
  pbExportAltTrainersPBS(outputDir,sourceDir)
  pbExportAltShadowMovesPBS(outputDir,sourceDir)
  pbExportAltConnectionsPBS(outputDir,sourceDir)
  # These formats are already sectioned/keyed, or do not yet have a safe
  # alternate compiler. Include exact copies so the export is a complete,
  # self-contained authoring snapshot rather than a partial PBS directory.
  passThrough=["types.txt","tm.txt","townmap.txt",
               "phone.txt","trainerlists.txt"]
  for filename in passThrough
    source=sourceDir+"/"+filename
    pbAltPBSCopyFile(source,outputDir+"/"+filename) if safeExists?(source)
  end
  for filename in pbAzurePBSTrackedFiles(sourceDir)
    next if AZURE_PBS_TRACKED_FILES.include?(filename)
    source=sourceDir+"/"+filename
    pbAltPBSCopyFile(source,outputDir+"/"+filename) if safeExists?(source)
  end
  notes=[]
  notes.push("# Generated by pbExportAltPBSFiles.")
  notes.push("# Alternate forms remain in Scripts/PokemonMultipleForms.rb for now.")
  notes.push("# Legacy-only fields are preserved with Legacy* keys or custom extension keys.")
  pbAltPBSWriteText(outputDir+"/README.txt",notes)
  return outputDir
end

def pbInstallAltPBSFiles(targetDir="PBS",backupRoot="PBS/LegacyBackup")
  timestamp=Time.new.strftime("%Y%m%d-%H%M%S")
  backupDir=backupRoot+"/"+timestamp
  pbAltPBSEnsureDirectory(targetDir)
  pbAltPBSEnsureDirectory(backupDir)
  for filename in pbAzurePBSTrackedFiles(targetDir)
    source=targetDir+"/"+filename
    next if !safeExists?(source)
    pbAltPBSCopyFile(source,backupDir+"/"+filename)
  end
  pbExportAltPBSFiles(targetDir,backupDir)
  legacyTrainerTypesFile=targetDir+"/trainertypes.txt"
  if safeExists?(legacyTrainerTypesFile) && safeExists?(targetDir+"/trainer_types.txt")
    File.delete(legacyTrainerTypesFile) rescue nil
  end
  return backupDir
end

def pbUniqueTimestampedPBSDirectory(root)
  timestamp=Time.new.strftime("%Y%m%d-%H%M%S")
  path=root+"/"+timestamp
  suffix=2
  while FileTest.directory?(path)
    path=root+"/"+timestamp+"-"+suffix.to_s
    suffix+=1
  end
  return path
end

def pbLogPBSTool(message)
  File.open("Data/pbs_tools.log","ab"){|f| f.write("#{Time.now}: #{message}\r\n") }
rescue
end

# Creates a new directory and never overwrites the active PBS sources.
def pbExportNamedPBSSnapshot(sourceDir="PBS",exportRoot="PBS/NamedExport")
  outputDir=pbUniqueTimestampedPBSDirectory(exportRoot)
  pbExportAltPBSFiles(outputDir,sourceDir)
  pbLogPBSTool("Exported named PBS snapshot to #{outputDir}")
  return outputDir
end

def pbPBSBackupDirectories(backupRoot)
  return [] if !FileTest.directory?(backupRoot)
  directories=[]
  for path in Dir.glob(backupRoot+"/*")
    directories.push(path.gsub("\\","/")) if FileTest.directory?(path)
  end
  directories.sort! {|a,b| File.mtime(b)<=>File.mtime(a) }
  return directories
end

def pbAvailablePBSBackups
  ret=[]
  for root in ["PBS/LegacyBackup","PBS/RestoreBackup"]
    for path in pbPBSBackupDirectories(root)
      ret.push([root,path])
    end
  end
  ret.sort! {|a,b| File.mtime(b[1])<=>File.mtime(a[1]) }
  return ret
end

def pbBackupCurrentPBS(targetDir="PBS",backupRoot="PBS/RestoreBackup")
  backupDir=pbUniqueTimestampedPBSDirectory(backupRoot)
  pbAltPBSEnsureDirectory(backupDir)
  for filename in pbAzurePBSTrackedFiles(targetDir)
    source=targetDir+"/"+filename
    pbAltPBSCopyFile(source,backupDir+"/"+filename) if safeExists?(source)
  end
  return backupDir
end

# Restores only the known active PBS files. The current set is backed up first,
# and files absent from the selected snapshot are removed from the restored set
# so split/legacy formats cannot accidentally coexist.
def pbRestorePBSBackup(backupDir,targetDir="PBS",backupRoot="PBS/LegacyBackup")
  root=File.expand_path(backupRoot).gsub("\\","/")
  sourceDir=File.expand_path(backupDir).gsub("\\","/")
  if File.dirname(sourceDir).gsub("\\","/")!=root || !FileTest.directory?(sourceDir)
    raise _INTL("The selected PBS backup is outside {1}.",backupRoot)
  end
  safetyDir=pbBackupCurrentPBS(targetDir,"PBS/RestoreBackup")
  trackedFiles=pbAzurePBSTrackedFiles(targetDir)
  for filename in pbAzurePBSTrackedFiles(sourceDir)
    trackedFiles.push(filename) if !trackedFiles.include?(filename)
  end
  for filename in trackedFiles
    source=sourceDir+"/"+filename
    destination=targetDir+"/"+filename
    if safeExists?(source)
      pbAltPBSCopyFile(source,destination)
    elsif safeExists?(destination)
      File.delete(destination)
    end
  end
  pbLogPBSTool("Restored PBS from #{backupDir}; previous files saved to #{safetyDir}")
  return safetyDir
end

def pbMigratePBSFilesToAltFormat(targetDir="PBS",backupRoot="PBS/LegacyBackup",recompile=true)
  backupDir=pbInstallAltPBSFiles(targetDir,backupRoot)
  if recompile
    pbCompileAllData(true){|msg|
      pbSetWindowText(msg) if defined?(pbSetWindowText)
    }
  end
  return backupDir
end

if false
  latesttexttime=0
  mustcompile=false
  mustcompile|=pbImportNewMaps
  mustcompile|=!(PBSpecies.respond_to?("maxValue") rescue false)
  if !safeIsDirectory?("PBS")
    Dir.mkdir("PBS") rescue nil
    pbSaveAllData()
    mustcompile=true
  end
  for i in 0...datafiles.length
    begin
      File.open("Data/#{datafiles[i]}"){|file|
         latestdatatime=[latestdatatime,file.mtime.to_i].max
      }
    rescue SystemCallError
      mustcompile=true
    end
  end
  for i in 0...textfiles.length
    begin
      File.open("PBS/#{textfiles[i]}"){|file|
         latesttexttime=[latesttexttime,file.mtime.to_i].max
      }
    rescue SystemCallError
    end
  end
  mustcompile=mustcompile || (latesttexttime>=latestdatatime)
  Input.update
  if Input.press?(Input::CTRL)
    mustcompile=true
  end
=begin
  if mustcompile
    for i in 0...datafiles.length
      begin
        File.delete("Data/#{datafiles[i]}")
        rescue SystemCallError
      end
    end
  end
=end
  pbCompileAllData(mustcompile){|msg| pbSetWindowText(msg) }
end



rescue Exception
e=$!
if "#{e.class}"=="Reset" || e.is_a?(Reset) || e.is_a?(SystemExit)
  raise e
end
pbPrintException(e)
=begin
for i in 0...datafiles.length
  begin
    File.delete("Data/#{datafiles[i]}")
  rescue SystemCallError
  end
end
=end
if e.is_a?(Hangup)
  raise Reset.new
end
loop do
  Graphics.update
end
end
