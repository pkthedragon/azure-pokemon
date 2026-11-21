#pk code
module AzureEvolutionDataCache
  EVOTYPEMASK=0x3F
  EVODATAMASK=0xC0
  EVONEXTFORM=0x00
  EVOPREVFORM=0x40

  def self.data
    return AzureDataCache.fetch("Data/evolutions.dat") {|path| parse(path) }
  end

  def self.parse(path)
    records=[]
    pbRgssOpen(path,"rb") {|file|
      for species in 1..PBSpecies.maxValue
        file.pos=(species-1)*8
        offset=file.fgetdw
        length=file.fgetdw
        entries=[]
        if length>0
          file.pos=offset
          consumed=0
          while consumed<length
            evo=file.fgetb
            entries.push([evo&EVOTYPEMASK,file.fgetw,file.fgetw,evo&EVODATAMASK].freeze)
            consumed+=5
          end
        end
        records[species]=entries.freeze
      end
    }
    return records.freeze
  end

  def self.records(species)
    return [].freeze if !species || species<=0
    return data[species] || [].freeze
  end

  def self.forward(species)
    ret=[]
    for record in records(species)
      ret.push([record[0],record[1],record[2]].freeze) if record[3]==EVONEXTFORM
    end
    return ret.freeze
  end

  def self.previous_record(species)
    for record in records(species)
      return record if record[3]==EVOPREVFORM
    end
    return nil
  end

  def self.clear; AzureDataCache.clear("Data/evolutions.dat"); end
end


def pbGetEvolvedFormData(species,pokemon=nil)
  # Alternate evo methods for forms 
  if pokemon!=nil
    formcheck = MultipleForms.call("getEvo",pokemon)
    if formcheck!=nil
      return formcheck
    end
  end  
  ret=[]
  for record in AzureEvolutionDataCache.forward(species)
    ret.push(record.clone)
  end
  return ret
end

def pbEvoDebug()
  _EVOTYPEMASK=0x3F
  _EVODATAMASK=0xC0
  pbRgssOpen("Data/evolutions.dat","rb"){|f|
     for species in 1..PBSpecies.maxValue
       f.pos=(species-1)*8
       offset=f.fgetdw
       length=f.fgetdw
       puts PBSpecies.getName(species)
       if length>0
         f.pos=offset
         i=0; loop do break unless i<length
           evo=f.fgetb
           evonib=evo&_EVOTYPEMASK
           level=f.fgetw
           poke=f.fgetw
           puts sprintf("type=%02X, data=%02X, name=%s, level=%d",
              evonib,evo&_EVODATAMASK,PBSpecies.getName(poke),level)
           if poke==0
             p f.eof?
             break
           end
           i+=5
         end
       end
     end
  }
end

def pbGetPreviousForm(species)
  record=AzureEvolutionDataCache.previous_record(species)
  return record ? record[2] : species
end

def pbGetMinimumLevel(species)
  ret=-1
  for record in AzureEvolutionDataCache.records(species)
    evonib=record[0]
    level=record[1]
    poke=record[2]
    if poke<=PBSpecies.maxValue && record[3]==AzureEvolutionDataCache::EVOPREVFORM &&
       [PBEvolution::Level,PBEvolution::LevelMale,
       PBEvolution::LevelFemale,PBEvolution::AttackGreater,
       PBEvolution::AtkDefEqual,PBEvolution::DefenseGreater,
       PBEvolution::Silcoon,PBEvolution::Cascoon,
       PBEvolution::Ninjask,PBEvolution::Shedinja].include?(evonib)
      ret=(ret==-1) ? level : [ret,level].min
      break
    end
  end
  return (ret==-1) ? 1 : ret
end

def pbGetBabySpecies(species)
  ret=species
  record=AzureEvolutionDataCache.previous_record(species)
  ret=record[2] if record && record[2]<=PBSpecies.maxValue
  if ret!=species
    ret=pbGetBabySpecies(ret)
  end
  return ret
end

def pbGetLessBabySpecies(species)
  ret=species
  record=AzureEvolutionDataCache.previous_record(species)
  ret=record[2] if record && record[2]<=PBSpecies.maxValue
 # if ret!=species
 #   ret=pbGetBabySpecies(ret)
 # end
  return ret
end
