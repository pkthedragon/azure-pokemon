class PokeBattle_Pokemon
  def form
    v=MultipleForms.call("getForm",self)
    if v!=nil
      self.form=v if !@form || v!=@form
      return v
    end
    return @form || 0
  end
  
  def form=(value)
    @form=value
    self.calcStats
    MultipleForms.call("onSetForm",self,value)
    if defined?($game_variables) && respond_to?(:applyMysticGimmighoulProgress)
      applyMysticGimmighoulProgress($game_variables[695])
    end
  end
  
  def hasMegaForm?
    v=MultipleForms.call("getMegaForm",self)
    return v!=nil
  end
  
  def hasZMove?
    canuse=false
    pkmn=self
    case pkmn.item
    when getID(PBItems,:NORMALIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==0
          canuse=true
        end
      end   
    when getID(PBItems,:FIGHTINIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==1
          canuse=true
        end
      end     
    when getID(PBItems,:FLYINIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==2
          canuse=true
        end
      end   
    when getID(PBItems,:POISONIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==3
          canuse=true
        end
      end           
    when getID(PBItems,:GROUNDIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==4
          canuse=true
        end
      end    
    when getID(PBItems,:ROCKIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==5
          canuse=true
        end
      end           
    when getID(PBItems,:BUGINIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==6
          canuse=true
        end
      end  
    when getID(PBItems,:GHOSTIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==7
          canuse=true
        end
      end           
    when getID(PBItems,:STEELIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==8
          canuse=true
        end
      end           
    when getID(PBItems,:FIRIUMZ)
      canuse=false
      for move in pkmn.moves
        if move.type==10
          canuse=true
        end
      end       
    when getID(PBItems,:WATERIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==11
          canuse=true
        end
      end           
    when getID(PBItems,:GRASSIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==12
          canuse=true
        end
      end               
    when getID(PBItems,:ELECTRIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==13
          canuse=true
        end
      end          
    when getID(PBItems,:PSYCHIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==14
          canuse=true
        end
      end   
    when getID(PBItems,:ICIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==15
          canuse=true
        end
      end               
    when getID(PBItems,:DRAGONIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==16
          canuse=true
        end
      end               
    when getID(PBItems,:DARKINIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==17
          canuse=true
        end
      end           
    when getID(PBItems,:FAIRIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.type==18
          canuse=true
        end
      end                     
    when getID(PBItems,:ALORAICHIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:THUNDERBOLT)
          canuse=true
        end
      end
      if pkmn.species!=26 || pkmn.form!=1
        canuse=false
      end 
    when getID(PBItems,:DECIDIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:SPIRITSHACKLE)
          canuse=true
        end
      end
      if pkmn.species!=724
        canuse=false
      end          
    when getID(PBItems,:INCINIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:DARKESTLARIAT)
          canuse=true
        end
      end
      if pkmn.species!=727
        canuse=false
      end           
    when getID(PBItems,:PRIMARIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:SPARKLINGARIA)
          canuse=true
        end
      end
      if pkmn.species!=724
        canuse=false
      end  
    when getID(PBItems,:EEVIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:LASTRESORT)
          canuse=true
        end
      end
      if pkmn.species!=133
        canuse=false
      end           
    when getID(PBItems,:PIKANIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:VOLTTACKLE)
          canuse=true
        end
      end
      if pkmn.species!=25
        canuse=false
      end    
    when getID(PBItems,:SNORLIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:GIGAIMPACT)
          canuse=true
        end
      end
      if pkmn.species!=143
        canuse=false
      end      
    when getID(PBItems,:MEWNIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:PSYCHIC)
          canuse=true
        end
      end
      if pkmn.species!=151
        canuse=false
      end   
    when getID(PBItems,:TAPUNIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:NATURESMADNESS)
          canuse=true
        end
      end
      if !(pokemon.species==785 || pokemon.species==786 || pokemon.species==787 || pokemon.species==788)
        canuse=false
      end   
    when getID(PBItems,:MARSHADIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:SPECTRALTHIEF)
          canuse=true
        end
      end  
    when getID(PBItems,:KOMMONIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:CLANGINGSCALES)
          canuse=true
        end
      end
      if pkmn.species!=784
        canuse=false
      end      
    when getID(PBItems,:LYCANIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:STONEEDGE)
          canuse=true
        end
      end
      if pkmn.species!=745
        canuse=false
      end              
    when getID(PBItems,:MIMIKIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:PLAYROUGH)
          canuse=true
        end
      end
      if pkmn.species!=778
        canuse=false
      end 
    when getID(PBItems,:SOLGANIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:SUNSTEELSTRIKE)
          canuse=true
        end
      end
      if pkmn.species!=791 && !(pkmn.species==800 && pkmn.form==1) 
        canuse=false
      end   
    when getID(PBItems,:LUNALIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:MOONGEISTBEAM)
          canuse=true
        end
      end
      if pkmn.species!=792 && !(pkmn.species==800 && pkmn.form==2) 
        canuse=false
      end              
    when getID(PBItems,:ULTRANECROZIUMZ)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:PHOTONGEYSER)
          canuse=true
        end
      end
      if pkmn.species!=800 || pkmn.form==0
        canuse=false
      end 
    end
    return canuse
  end  
  
  def isMega?
    v=MultipleForms.call("getMegaForm",self)
    return (v!=nil && v==@form)
  end
  
  def makeMega
    v=MultipleForms.call("getMegaForm",self)
    self.form=v if v!=nil
  end
  
  def makeUnmega
    v=MultipleForms.call("getUnmegaForm",self)
    self.form=v if v!=nil
  end
  
  def megaName
    v=MultipleForms.call("getMegaName",self)
    return v if v!=nil
    return ""
  end
  
  alias __mf_baseStats baseStats
  alias __mf_ability ability
  alias __mf_type1 type1
  alias __mf_type2 type2
  alias __mf_height height
  alias __mf_weight weight
  alias __mf_getMoveList getMoveList
  alias __mf_isCompatibleWithMove? isCompatibleWithMove?
  alias __mf_wildHoldItems wildHoldItems
  alias __mf_baseExp baseExp
  alias __mf_evYield evYield
  alias __mf_initialize initialize
  
  def baseStats
    v=MultipleForms.call("getBaseStats",self)
    return v if v!=nil
    return self.__mf_baseStats
  end
  
  def ability
    v=MultipleForms.call("ability",self)
    return v if v!=nil
    return self.__mf_ability
  end
  
  def type1
    v=MultipleForms.call("type1",self)
    return v if v!=nil
    return self.__mf_type1
  end
  
  def type2
    v=MultipleForms.call("type2",self)
    return v if v!=nil
    return self.__mf_type2
  end
  
  def height
    v=MultipleForms.call("height",self)
    return v if v!=nil
    return self.__mf_height
  end
  
  def weight
    v=MultipleForms.call("weight",self)
    return v if v!=nil
    return self.__mf_weight
  end
  
  def getMoveList
    v=MultipleForms.call("getMoveList",self)
    return v if v!=nil
    return self.__mf_getMoveList
  end
  
  def isCompatibleWithMove?(move)
    v=MultipleForms.call("getMoveCompatibility",self)
    if v!=nil
      return v.any? {|j| j==move }
    end
    return self.__mf_isCompatibleWithMove?(move)
  end
  
  def wildHoldItems
    v=MultipleForms.call("wildHoldItems",self)
    return v if v!=nil
    return self.__mf_wildHoldItems
  end
  
  def baseExp
    v=MultipleForms.call("baseExp",self)
    return v if v!=nil
    return self.__mf_baseExp
  end
  
  def evYield
    v=MultipleForms.call("evYield",self)
    return v if v!=nil
    return self.__mf_evYield
  end
  
  def initialize(*args)
    __mf_initialize(*args)
    f=MultipleForms.call("getFormOnCreation",self)
    if f
      self.form=f
      self.resetMoves
    end
  end
end



class PokeBattle_RealBattlePeer
  def pbOnEnteringBattle(battle,pokemon)
    f=MultipleForms.call("getFormOnEnteringBattle",pokemon)
    if f
      pokemon.form=f
    end
  end
end

class PokeBattle_Battle
  def pbBelongsToPlayer?(pokemon)
    if @player.is_a?(Array) && @player.length>1
      return pokemon==0
    else
      return (pokemon%2)==0
    end
    return false
  end
end

module MultipleForms
  @@formSpecies=HandlerHash.new(:PBSpecies)
  
  def self.copy(sym,*syms)
    @@formSpecies.copy(sym,*syms)
  end
  
  def self.register(sym,hash)
    @@formSpecies.add(sym,hash)
  end
  
  def self.registerIf(cond,hash)
    @@formSpecies.addIf(cond,hash)
  end
  
  def self.hasFunction?(pokemon,func)
    spec=(pokemon.is_a?(Numeric)) ? pokemon : pokemon.species
    sp=@@formSpecies[spec]
    return sp && sp[func]
  end
  
  def self.getFunction(pokemon,func)
    spec=(pokemon.is_a?(Numeric)) ? pokemon : pokemon.species
    sp=@@formSpecies[spec]
    return (sp && sp[func]) ? sp[func] : nil
  end
  
  def self.call(func,pokemon,*args)
    sp=@@formSpecies[pokemon.species]
    return nil if !sp || !sp[func]
    return sp[func].call(pokemon,*args)
  end
  
  def self.call2(func,pokemon,*args)       #For when only given a species
    sp=@@formSpecies[pokemon.species]
    return nil if !sp || !sp[func]
    return sp[func].call(pokemon,*args)
  end  
end



def drawSpot(bitmap,spotpattern,x,y,red,green,blue)
  height=spotpattern.length
  width=spotpattern[0].length
  for yy in 0...height
    spot=spotpattern[yy]
    for xx in 0...width
      if spot[xx]==1
        xOrg=(x+xx)<<1
        yOrg=(y+yy)<<1
        color=bitmap.get_pixel(xOrg,yOrg)
        r=color.red+red
        g=color.green+green
        b=color.blue+blue
        color.red=[[r,0].max,255].min
        color.green=[[g,0].max,255].min
        color.blue=[[b,0].max,255].min
        bitmap.set_pixel(xOrg,yOrg,color)
        bitmap.set_pixel(xOrg+1,yOrg,color)
        bitmap.set_pixel(xOrg,yOrg+1,color)
        bitmap.set_pixel(xOrg+1,yOrg+1,color)
      end   
    end
  end
end

def pbSpindaSpots(pokemon,bitmap)
  spot1=[
    [0,0,1,1,1,1,0,0],
    [0,1,1,1,1,1,1,0],
    [1,1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1,1],
    [0,1,1,1,1,1,1,0],
    [0,0,1,1,1,1,0,0]
  ]
  spot2=[
    [0,0,1,1,1,0,0],
    [0,1,1,1,1,1,0],
    [1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1],
    [0,1,1,1,1,1,0],
    [0,0,1,1,1,0,0]
  ]
  spot3=[
    [0,0,0,0,0,1,1,1,1,0,0,0,0],
    [0,0,0,1,1,1,1,1,1,1,0,0,0],
    [0,0,1,1,1,1,1,1,1,1,1,0,0],
    [0,1,1,1,1,1,1,1,1,1,1,1,0],
    [0,1,1,1,1,1,1,1,1,1,1,1,0],
    [1,1,1,1,1,1,1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1,1,1,1,1,1,1],
    [0,1,1,1,1,1,1,1,1,1,1,1,0],
    [0,1,1,1,1,1,1,1,1,1,1,1,0],
    [0,0,1,1,1,1,1,1,1,1,1,0,0],
    [0,0,0,1,1,1,1,1,1,1,0,0,0],
    [0,0,0,0,0,1,1,1,0,0,0,0,0]
  ]
  spot4=[
    [0,0,0,0,1,1,1,0,0,0,0,0],
    [0,0,1,1,1,1,1,1,1,0,0,0],
    [0,1,1,1,1,1,1,1,1,1,0,0],
    [0,1,1,1,1,1,1,1,1,1,1,0],
    [1,1,1,1,1,1,1,1,1,1,1,0],
    [1,1,1,1,1,1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1,1,1,1,1,0],
    [0,1,1,1,1,1,1,1,1,1,1,0],
    [0,0,1,1,1,1,1,1,1,1,0,0],
    [0,0,0,0,1,1,1,1,1,0,0,0]
  ]
  id=pokemon.personalID
  h=(id>>28)&15
  g=(id>>24)&15
  f=(id>>20)&15
  e=(id>>16)&15
  d=(id>>12)&15
  c=(id>>8)&15
  b=(id>>4)&15
  a=(id)&15
  if pokemon.isShiny?
    drawSpot(bitmap,spot1,b+33,a+25,-120,-120,-20)
    drawSpot(bitmap,spot2,d+21,c+24,-120,-120,-20)
    drawSpot(bitmap,spot3,f+39,e+7,-120,-120,-20)
    drawSpot(bitmap,spot4,h+15,g+6,-120,-120,-20)
  else
    drawSpot(bitmap,spot1,b+33,a+25,0,-115,-75)
    drawSpot(bitmap,spot2,d+21,c+24,0,-115,-75)
    drawSpot(bitmap,spot3,f+39,e+7,0,-115,-75)
    drawSpot(bitmap,spot4,h+15,g+6,0,-115,-75)
  end
end

MultipleForms.register(:UNOWN,{
    "getFormOnCreation"=>proc{|pokemon|
      next rand(28)
    }
  })


MultipleForms.register(:FLABEBE,{
    "getFormOnCreation"=>proc{|pokemon|
      next rand(5)
    }
  })
MultipleForms.register(:FLOETTE,{
    "getFormOnCreation"=>proc{|pokemon|
      next rand(5)
    }
  })
MultipleForms.register(:FLORGES,{
    "getFormOnCreation"=>proc{|pokemon|
      next rand(5)
    }
  })

MultipleForms.register(:SPINDA,{
    "alterBitmap"=>proc{|pokemon,bitmap|
      pbSpindaSpots(pokemon,bitmap)
    }
  })

MultipleForms.register(:CASTFORM,{
    "type1"=>proc{|pokemon|
      next if pokemon.form==0              # Normal Form
      case pokemon.form
      when 1; next getID(PBTypes,:FIRE)  # Sunny Form
      when 2; next getID(PBTypes,:WATER) # Rainy Form
      when 3; next getID(PBTypes,:ICE)   # Snowy Form
      end
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0              # Normal Form
      case pokemon.form
      when 1; next getID(PBTypes,:FIRE)  # Sunny Form
      when 2; next getID(PBTypes,:WATER) # Rainy Form
      when 3; next getID(PBTypes,:ICE)   # Snowy Form
      end
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0                  # Normal Forme
      next if !isConst?(pokemon.item,PBItems,:CASTCREST) # No crest
      case pokemon.form
      when 1; next [ 70, 70, 70,100, 90, 70] # Sunny Form
      when 2; next [100, 70, 80, 70, 70, 80] # Rainy Form
      when 3; next [ 70, 70, 70, 90,100, 70] # Snowy Form
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:DEOXYS,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0                 # Normal Forme
      case pokemon.form
      when 1; next [50,180, 20,150,180, 20] # Attack Forme
      when 2; next [50, 70,160, 90, 70,160] # Defense Forme
      when 3; next [50, 95, 90,180, 95, 90] # Speed Forme
      end
    },
    "evYield"=>proc{|pokemon|
      next if pokemon.form==0      # Normal Forme
      case pokemon.form
      when 1; next [0,2,0,0,1,0] # Attack Forme
      when 2; next [0,0,2,0,0,1] # Defense Forme
      when 3; next [0,0,0,3,0,0] # Speed Forme
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1 ; movelist=[[1,:LEER],[1,:WRAP],[7,:NIGHTSHADE],[13,:TELEPORT],
          [19,:TAUNT],[25,:PURSUIT],[31,:PSYCHIC],[37,:SUPERPOWER],
          [43,:PSYCHOSHIFT],[49,:ZENHEADBUTT],[55,:COSMICPOWER],
          [61,:ZAPCANNON],[67,:PSYCHOBOOST],[73,:HYPERBEAM]]
      when 2 ; movelist=[[1,:LEER],[1,:WRAP],[7,:NIGHTSHADE],[13,:TELEPORT],
          [19,:KNOCKOFF],[25,:SPIKES],[31,:PSYCHIC],[37,:SNATCH],
          [43,:PSYCHOSHIFT],[49,:ZENHEADBUTT],[55,:IRONDEFENSE],
          [55,:AMNESIA],[61,:RECOVER],[67,:PSYCHOBOOST],
          [73,:COUNTER],[73,:MIRRORCOAT]]
      when 3 ; movelist=[[1,:LEER],[1,:WRAP],[7,:NIGHTSHADE],[13,:DOUBLETEAM],
          [19,:KNOCKOFF],[25,:PURSUIT],[31,:PSYCHIC],[37,:SWIFT],
          [43,:PSYCHOSHIFT],[49,:ZENHEADBUTT],[55,:AGILITY],
          [61,:RECOVER],[67,:PSYCHOBOOST],[73,:EXTREMESPEED]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:BURMY,{
    "getFormOnCreation"=>proc{|pokemon|
      env=pbGetEnvironment()
      maps=[1,54,55,90]   # Map IDs for sandy form
	    next 3 if pokemon.form==3
      if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
        next 2 # Trash Cloak
      elsif env==PBEnvironment::Sand ||
        env==PBEnvironment::Rock ||
        env==PBEnvironment::Cave ||
        ($game_map && maps.include?($game_map.map_id))
        next 1 # Sandy Cloak
      else
        next 0 # Plant Cloak
      end
    },
    "getFormOnEnteringBattle"=>proc{|pokemon|
      env=pbGetEnvironment()
      maps=[1,54,55,90]   # Map IDs for sandy form
	    next 3 if pokemon.form==3
      if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
        next 2 # Trash Cloak
      elsif env==PBEnvironment::Sand ||
        env==PBEnvironment::Rock ||
        env==PBEnvironment::Cave ||
        ($game_map && maps.include?($game_map.map_id))
        next 1 # Sandy Cloak
      else
        next 0 # Plant Cloak
      end
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form!=3
      next getID(PBTypes,:BUG)    # Mystic
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form!=3
      next getID(PBTypes,:NORMAL)    # Mystic
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form!=3
      next [36, 29, 45, 40, 29, 45]   # Mystic
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form!=3 # Only Mystic form
      if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
        next getID(PBAbilities,:OVERCOAT)
      end
      if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:FURCOAT)
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form!=3      # Use default moveset for base form
      movelist=[]
      case pokemon.form            # Mystic
      when 3 ; movelist=[[1,:DEFENSECURL],[10,:ROLLOUT],[15,:SILVERWIND],[20,:HEADBUTT]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 3; movelist=[# TMs
        :CHARM]
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:WORMADAM,{
    "getFormOnCreation"=>proc{|pokemon|
      env=pbGetEnvironment()
	  next 3 if pokemon.form==3
      if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
        next 2 # Trash Cloak
      elsif env==PBEnvironment::Sand || env==PBEnvironment::Rock ||
        env==PBEnvironment::Cave
        next 1 # Sandy Cloak
      else
        next 0 # Plant Cloak
      end
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form!=3
      next getID(PBTypes,:BUG)    # Mystic
    },
    "type2"=>proc{|pokemon|
      case pokemon.form
      when 1; next getID(PBTypes,:GROUND) # Sandy Cloak
      when 2; next getID(PBTypes,:STEEL)  # Trash Cloak
      when 3; next getID(PBTypes,:NORMAL) # Mystic
      end
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0              # Plant Cloak
      case pokemon.form
      when 1; next [60,79,105,36,59, 85] # Sandy Cloak
      when 2; next [60,69, 95,36,69, 95] # Trash Cloak
      when 3; next [85, 59, 60, 36, 79, 105]   # Mystic
      end
    },
    "evYield"=>proc{|pokemon|
      next if pokemon.form==0      # Plant Cloak
      case pokemon.form
      when 1; next [0,0,2,0,0,0] # Sandy Cloak
      when 2; next [0,0,1,0,0,1] # Trash Cloak
      end
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form!=3 # Only Mystic form
      if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
        next getID(PBAbilities,:OVERCOAT)
      end
      if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:FURCOAT)
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1 ; movelist=[[0,:HIDDENPOWER],[1,:EARTHPOWER],[1,:PESTER],
          [1,:DEFENSECURL],[1,:BUGBITE],[5,:CONFUSION],[10,:DEFENSECURL],[15,:BUGBITE],
          [20,:PROTECT],[23,:PSYBEAM],[26,:ROCKBLAST],[26,:SILVERWIND],
          [29,:ROCKPOLISH],[32,:CARAPACESHOT],[35,:COUNTER],[35,:MIRRORCOAT],[38,:EARTHPOWER],
          [41,:STICKYWEB],[44,:PSYCHIC],[47,:FISSURE],[50,:BUGBUZZ],[55,:QUIVERDANCE]]
	  when 2 ; movelist=[[0,:HIDDENPOWER],[1,:EARTHPOWER],[1,:PESTER],
          [1,:DEFENSECURL],[1,:BUGBITE],[5,:CONFUSION],[10,:DEFENSECURL],[15,:BUGBITE],
          [20,:PROTECT],[23,:PSYBEAM],[26,:MIRRORSHOT],[26,:SILVERWIND],
          [29,:IRONDEFENSE],[32,:CARAPACESHOT],[35,:COUNTER],[35,:MIRRORCOAT],[38,:FLASHCANNON],
          [41,:STICKYWEB],[44,:PSYCHIC],[47,:STEELBEAM],[50,:BUGBUZZ],[55,:QUIVERDANCE]]
      when 3 ; movelist=[[0,:BEAUTIFY],[1,:SUCKERPUNCH],[1,:DEFENSECURL],[1,:ROLLOUT],
                      [1,:SILVERWIND],[10,:ROLLOUT],[15,:SILVERWIND],[20,:HEADBUTT],
                      [23,:LIFEDEW],[26,:STRUGGLEBUG],[29,:ROUND],[32,:PSYBEAM],
                      [35,:ROOST],[38,:PROTECT],[41,:COTTONGUARD],[44,:PSYCHIC],
                      [47,:HYPERVOICE],[50,:HEALINGWISH]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 3; movelist=[# TMs
        :ALLYSWITCH,:ASSURANCE,:ATTRACT,:BODYPRESS,:BODYSLAM,:BUGBITE,:BUGBUZZ,:CHARM,:COACHING,:CONFIDE,:DOUBLETEAM,:DREAMEATER,:EARTHQUAKE,:ELECTROWEB,:ENDEAVOR,:ENDURE,:FACADE,:FLASH,:FRUSTRATION,:GIGAIMPACT,:HAIL,:HELPINGHAND,:HIDDENPOWER,:HYPERBEAM,:HYPERVOICE,:ICYWIND,:INFESTATION,:IRONDEFENSE,:IRRITATION,:LEECHLIFE,:MAGICCOAT,:PROTECT,:PSYCHUP,:PSYCHIC,:RAINDANCE,:REST,:RETRIBUTION,:RETURN,:ROOST,:ROUND,:SAFEGUARD,:SECRETPOWER,:SERAPHSEMBRACE,:SHADOWBALL,:SIGNALBEAM,:SKILLSWAP,:SKITTERSMACK,:SLEEPTALK,:SNORE,:STRUGGLEBUG,:SUBSTITUTE,:SUCKERPUNCH,:SUNNYDAY,:SWIFT,:TELEKINESIS,:TERRAINPULSE,:THIEF,:TOXIC,:UPROAR]
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:SHELLOS,{
    "getFormOnCreation"=>proc{|pokemon|
      maps=[]   
      # Map IDs for second form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    }
  })

MultipleForms.copy(:SHELLOS,:GASTRODON)

MultipleForms.register(:ROTOM,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0     # Normal Form
      next [50,65,107,86,105,107] # All alternate forms
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0               # Normal Form
      case pokemon.form
      when 1; next getID(PBTypes,:FIRE)   # Heat, Microwave
      when 2; next getID(PBTypes,:WATER)  # Wash, Washing Machine
      when 3; next getID(PBTypes,:ICE)    # Frost, Refrigerator
      when 4; next getID(PBTypes,:FLYING) # Fan
      when 5; next getID(PBTypes,:GRASS)  # Mow, Lawnmower
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
      moves=[
        :OVERHEAT,  # Heat, Microwave
        :HYDROPUMP, # Wash, Washing Machine
        :BLIZZARD,  # Frost, Refrigerator
        :AIRSLASH,  # Fan
        :LEAFSTORM  # Mow, Lawnmower
      ]
      moves.each{|move|
        pbDeleteMoveByID(pokemon,getID(PBMoves,move))
      }
      if form>0
        pokemon.pbLearnMove(moves[form-1])
      end
      if pokemon.moves.find_all{|i| i.id!=0}.length==0
        pokemon.pbLearnMove(:THUNDERSHOCK)
      end
    }
  })

MultipleForms.register(:GIRATINA,{
    "ability"=>proc{|pokemon|
      next if pokemon.form==0           # Altered Forme
      next getID(PBAbilities,:LEVITATE) # Origin Forme
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0 # Altered Forme
      next 6500               # Origin Forme
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0       # Altered Forme
      next [150,120,100,90,120,100] # Origin Forme
    },
    "getForm"=>proc{|pokemon|
      maps=[49,50,51,72,73]   # Map IDs for Origin Forme
      if isConst?(pokemon.item,PBItems,:GRISEOUSORB) ||
        ($game_map && maps.include?($game_map.map_id))
        next 1
      end
      next 0
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:SHAYMIN,{
    "type2"=>proc{|pokemon|
      next if pokemon.form==0     # Land Forme
      next getID(PBTypes,:FLYING) # Sky Forme
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0              # Land Forme
      next getID(PBAbilities,:SERENEGRACE) # Sky Forme
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0 # Land Forme
      next 52                 # Sky Forme
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0      # Land Forme
      next [100,103,75,127,120,75] # Sky Forme
    },
    "evYield"=>proc{|pokemon|
      next if pokemon.form==0 # Land Forme
      next [0,0,0,3,0,0]      # Sky Forme
    },
    "getForm"=>proc{|pokemon|
      next 0 if PBDayNight.isNight?(pbGetTimeNow) ||
      pokemon.hp<=0 || pokemon.status==PBStatuses::FROZEN
      next nil
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1 ; movelist=[[1,:GROWTH],[10,:MAGICALLEAF],[19,:LEECHSEED],
          [28,:QUICKATTACK],[37,:SWEETSCENT],[46,:NATURALGIFT],
          [55,:WORRYSEED],[64,:AIRSLASH],[73,:ENERGYBALL],
          [82,:SWEETKISS],[91,:LEAFSTORM],[100,:SEEDFLARE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:ARCEUS,{
    "type1"=>proc{|pokemon|
      types=[:NORMAL,:FIGHTING,:FLYING,:POISON,:GROUND,
        :ROCK,:BUG,:GHOST,:STEEL,:QMARKS,
        :FIRE,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,
        :ICE,:DRAGON,:DARK,:FAIRY]
      next getID(PBTypes,types[pokemon.form])
    },
    "type2"=>proc{|pokemon|
      types=[:NORMAL,:FIGHTING,:FLYING,:POISON,:GROUND,
        :ROCK,:BUG,:GHOST,:STEEL,:QMARKS,
        :FIRE,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,
        :ICE,:DRAGON,:DARK,:FAIRY]
      next getID(PBTypes,types[pokemon.form])
    },
    "getForm"=>proc{|pokemon|
      if $fefieldeffect == 35
        if $fecounter == 1
          form = 0
          loop do
            form = rand(19)
            break if form != 9
          end
          next form
        end
      else
        next 1  if isConst?(pokemon.item,PBItems,:FISTPLATE) || isConst?(pokemon.item,PBItems,:FIGHTINIUMZ2)
        next 2  if isConst?(pokemon.item,PBItems,:SKYPLATE) || isConst?(pokemon.item,PBItems,:FLYINIUMZ2)
        next 3  if isConst?(pokemon.item,PBItems,:TOXICPLATE) || isConst?(pokemon.item,PBItems,:POISONIUMZ2)
        next 4  if isConst?(pokemon.item,PBItems,:EARTHPLATE) || isConst?(pokemon.item,PBItems,:GROUNDIUMZ2)
        next 5  if isConst?(pokemon.item,PBItems,:STONEPLATE) || isConst?(pokemon.item,PBItems,:ROCKIUMZ2)
        next 6  if isConst?(pokemon.item,PBItems,:INSECTPLATE) || isConst?(pokemon.item,PBItems,:BUGINIUMZ2)
        next 7  if isConst?(pokemon.item,PBItems,:SPOOKYPLATE) || isConst?(pokemon.item,PBItems,:GHOSTIUMZ2)
        next 8  if isConst?(pokemon.item,PBItems,:IRONPLATE) || isConst?(pokemon.item,PBItems,:STEELIUMZ2)
        next 10 if isConst?(pokemon.item,PBItems,:FLAMEPLATE) || isConst?(pokemon.item,PBItems,:FIRIUMZ2)
        next 11 if isConst?(pokemon.item,PBItems,:SPLASHPLATE) || isConst?(pokemon.item,PBItems,:WATERIUMZ2)
        next 12 if isConst?(pokemon.item,PBItems,:MEADOWPLATE) || isConst?(pokemon.item,PBItems,:GRASSIUMZ2)
        next 13 if isConst?(pokemon.item,PBItems,:ZAPPLATE) || isConst?(pokemon.item,PBItems,:ELECTRIUMZ2)
        next 14 if isConst?(pokemon.item,PBItems,:MINDPLATE) || isConst?(pokemon.item,PBItems,:PSYCHIUMZ2)
        next 15 if isConst?(pokemon.item,PBItems,:ICICLEPLATE) || isConst?(pokemon.item,PBItems,:ICIUMZ2)
        next 16 if isConst?(pokemon.item,PBItems,:DRACOPLATE) || isConst?(pokemon.item,PBItems,:DRAGONNIUMZ2)
        next 17 if isConst?(pokemon.item,PBItems,:DREADPLATE) || isConst?(pokemon.item,PBItems,:DARKINIUMZ2)
        next 18 if isConst?(pokemon.item,PBItems,:PIXIEPLATE) || isConst?(pokemon.item,PBItems,:FAIRIUMZ2)
        next 0
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:BASCULIN,{
    "getFormOnCreation"=>proc{|pokemon|
      next rand(2)
    },
    "ability"=>proc{|pokemon|
    next if pokemon.form==0               # Incarnate Forme
    if pokemon.abilityflag && pokemon.abilityflag!=2
      next getID(PBAbilities,:ROCKHEAD) # Therian Forme
    end
    },
    "wildHoldItems"=>proc{|pokemon|
      next if pokemon.form==0                 # Red-Striped
      next [0,getID(PBItems,:DEEPSEASCALE),0] # Blue-Striped
    }
  })

MultipleForms.register(:DARMANITAN,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "When wounded, it stops moving. It goes as still as stone to meditate, sharpening its mind and spirit." if pokemon.form==1  # Normal Zen Mode
      next "Though it has a gentle disposition, it's also very strong. It will quickly freeze the snowball on its head before going for a headbutt." if pokemon.form==2  # Galar
      next "Darmanitan takes this form when enraged. It won't stop spewing flames until its rage has settled, even if its body starts to melt." if pokemon.form==3  # Galar Zen Mode
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[]  
      # Map IDs for Galarian form
      if $game_map && maps.include?($game_map.map_id)
        next 2
      else
        next 0
      end
    },
    "height"=>proc{|pokemon|
      next if pokemon.form!=2      # Normal
      next 1.7                     # Galarian
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form!=2      # Normal
      next 120                      # Galarian
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0      # Standard Mode
      next [105,30,105,55,140,105] if pokemon.form==1  # Normal Zen Mode
      next if pokemon.form==2  # Galar
      next [105,160,135,55,30,55] if pokemon.form==1  # Galar Zen Mode
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:FIRE) if pokemon.form==1      # Zen
      next getID(PBTypes,:ICE) if pokemon.form==2      # Galar
      next getID(PBTypes,:ICE) if pokemon.form==3      # Galar Zen
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:PSYCHIC) if pokemon.form==1      # Zen
      next getID(PBTypes,:ICE) if pokemon.form==2      # Galar
      next getID(PBTypes,:FIRE) if pokemon.form==3      # Galar Zen
    },
    "evYield"=>proc{|pokemon|
      next [0,0,0,0,2,0] if pokemon.form==2      # Zen Mode
      next # Otherwise
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form!=2      # Normal
      movelist=[]
      case pokemon.form            # Galarian
      when 1 ; movelist=[[0,:ICICLECRASH],[1,:ICICLECRASH],[1,:POWDERSNOW],[1,:TACKLE],[1,:TAUNT],[1,:BITE],
          [12,:AVALANCHE],[16,:WORKUP],[20,:ICEFANG],[24,:HEADBUTT],
          [28,:ICEPUNCH],[32,:UPROAR],[38,:BELLYDRUM],
          [44,:BLIZZARD],[50,:THRASH],[56,:SUPERPOWER]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      next if pokemon.form==1 # Normal-Zen Mode
      if pokemon.abilityIndex==0 || pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==0) || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:GORILLATACTICS)
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:ZENMODE)  
      end
    },"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:DEERLING,{
    "getForm"=>proc{|pokemon|
      time=pbGetTimeNow
      next (time.month-1)%4
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.copy(:DEERLING,:SAWSBUCK)

MultipleForms.register(:TORNADUS,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0     # Incarnate Forme
      next [79,100,80,121,110,90] # Therian Forme
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0                # Incarnate Forme
      if pokemon.abilityflag && pokemon.abilityflag!=2
        next getID(PBAbilities,:REGENERATOR) # Therian Forme
      end
    },
    "evYield"=>proc{|pokemon|
      next if pokemon.form==0 # Incarnate Forme
      next [0,0,0,3,0,0]      # Therian Forme
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:THUNDURUS,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0     # Incarnate Forme
      next [79,105,70,101,145,80] # Therian Forme
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0               # Incarnate Forme
      if pokemon.abilityflag && pokemon.abilityflag!=2
        next getID(PBAbilities,:VOLTABSORB) # Therian Forme
      end
    },
    "evYield"=>proc{|pokemon|
      next if pokemon.form==0 # Incarnate Forme
      next [0,0,0,0,3,0]      # Therian Forme
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:LANDORUS,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0    # Incarnate Forme
      next [89,145,90,71,105,80] # Therian Forme
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0               # Incarnate Forme
      if pokemon.abilityflag && pokemon.abilityflag!=2
        next getID(PBAbilities,:INTIMIDATE) # Therian Forme
      end
    },
    "evYield"=>proc{|pokemon|
      next if pokemon.form==0 # Incarnate Forme
      next [0,3,0,0,0,0]      # Therian Forme
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:KYUREM,{
    "getBaseStats"=>proc{|pokemon|
      case pokemon.form
      when 1; next [125,120, 90,95,170,100] # White Kyurem
      when 2; next [125,170,100,95,120, 90] # Black Kyurem
      else;   next                          # Kyurem
      end
    },
    "ability"=>proc{|pokemon|
      case pokemon.form
      when 1; next getID(PBAbilities,:TURBOBLAZE) # White Kyurem
      when 2; next getID(PBAbilities,:TERAVOLT)   # Black Kyurem
      else;   next                                # Kyurem
      end
    },
    "evYield"=>proc{|pokemon|
      case pokemon.form
      when 1; next [0,0,0,0,3,0] # White Kyurem
      when 2; next [0,3,0,0,0,0] # Black Kyurem
      else;   next               # Kyurem
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[[1,:ICYWIND],[1,:DRAGONRAGE],[8,:IMPRISON],
          [15,:ANCIENTPOWER],[22,:ICEBEAM],[29,:DRAGONBREATH],
          [36,:SLASH],[43,:FUSIONFLARE],[50,:ICEBURN],
          [57,:DRAGONPULSE],[64,:NOBLEROAR],[71,:ENDEAVOR],
          [78,:BLIZZARD],[85,:OUTRAGE],[92,:HYPERVOICE]]
      when 2; movelist=[[1,:ICYWIND],[1,:DRAGONRAGE],[8,:IMPRISON],
          [15,:ANCIENTPOWER],[22,:ICEBEAM],[29,:DRAGONBREATH],
          [36,:SLASH],[43,:FUSIONBOLT],[50,:FREEZESHOCK],
          [57,:DRAGONPULSE],[64,:NOBLEROAR],[71,:ENDEAVOR],
          [78,:BLIZZARD],[85,:OUTRAGE],[92,:HYPERVOICE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:KELDEO,{
    "getForm"=>proc{|pokemon|
      next 1 if pokemon.knowsMove?(:SECRETSWORD) # Resolute Form
      next 0                                     # Ordinary Form
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:MELOETTA,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0     # Aria Forme
      next [100,128,90,128,77,77] # Pirouette Forme
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0       # Aria Forme
      next getID(PBTypes,:FIGHTING) # Pirouette Forme
    },
    "evYield"=>proc{|pokemon|
      next if pokemon.form==0 # Aria Forme
      next [0,1,1,1,0,0]      # Pirouette Forme
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:GENESECT,{
    "getForm"=>proc{|pokemon|
      next 1 if isConst?(pokemon.item,PBItems,:SHOCKDRIVE)
      next 2 if isConst?(pokemon.item,PBItems,:BURNDRIVE)
      next 3 if isConst?(pokemon.item,PBItems,:CHILLDRIVE)
      next 4 if isConst?(pokemon.item,PBItems,:DOUSEDRIVE)
      next 0
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:MEOWSTIC,{
    "ability"=>proc{|pokemon|
      next if pokemon.gender==0 # Male Meowstic
      #### JERICHO - 015 - START
      if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        #### JERICHO - 015 - END
        next getID(PBAbilities,:COMPETITIVE) # Female Meowstic
      end
    },
    
    "getMoveList"=>proc{|pokemon|
      next if pokemon.gender==0 # Male Meowstic
      movelist=[]
      case pokemon.gender
      when 1 ; movelist=[[1,:STOREDPOWER],[1,:MEFIRST],[1,:MAGICALLEAF],[1,:SCRATCH],
          [1,:LEER],[1,:COVET],[1,:CONFUSION],[5,:COVET],[9,:CONFUSION],[13,:LIGHTSCREEN],
          [17,:PSYBEAM],[19,:FAKEOUT],[22,:DISARMINGVOICE],[25,:PSYSHOCK],[28,:CHARGEBEAM],
          [31,:SHADOWBALL],[35,:EXTRASENSORY],[40,:PSYCHIC],
          [43,:ROLEPLAY],[45,:SIGNALBEAM],[48,:SUCKERPUNCH],
          [50,:FUTURESIGHT],[53,:STOREDPOWER]] # Female Meowstic
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    }
  })

MultipleForms.register(:AEGISLASH,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0 # Shield Forme
      next [60,140,50,60,140,50] if pokemon.form==1  # Blade Forme
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:ZYGARDE,{
    "dexEntry"=>proc{|pokemon|
      case pokemon.form      
      when 0
        next  # 50%
      when 1
        next "Its sharp fangs make short work of finishing off its enemies, but it’s unable to maintain this body indefinitely. After a period of time, it falls apart." # 10%
      when 2
        next "This is Zygarde’s form at times when it uses its overwhelming power to suppress those who endanger the ecosystem." # 100%
      end
    },
    "getBaseStats"=>proc{|pokemon|
      case pokemon.form
      when 0 # 50%
        next   
      when 1 # 10%       
        next [54,100,71,115,61,85] 
      when 2 # 100%
        next [216,100,121,85,91,95] 
      end   
    },
    "height"=>proc{|pokemon|
      case pokemon.form
      when 0 # 50%
        next   
      when 1 # 10%       
        next 1.2
      when 2 # 100%
        next 4.5
      end  
    },
    "weight"=>proc{|pokemon|
      case pokemon.form
      when 0 # 50%
        next   
      when 1 # 10%       
        next 33.5
      when 2 # 100%
        next 610.0
      end  
      next 490 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:HOOPA,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0     
      next [80,160,60,80,170,130] # Unbound Forme
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0       
      next getID(PBTypes,:DARK) # Unbound Forme
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0               
      if pokemon.abilityflag && pokemon.abilityflag!=2
        next getID(PBAbilities,:MAGICIAN) # Unbound Forme
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1 ; movelist=[[1,:HYPERSPACEFURY],[1,:TRICK],[1,:DESTINYBOND],[1,:ALLYSWITCH],
          [1,:CONFUSION],[6,:ASTONISH],[10,:MAGICCOAT],[15,:LIGHTSCREEN],
          [19,:PSYBEAM],[25,:SKILLSWAP],[29,:POWERSPLIT],[29,:GUARDSPLIT],
          [46,:KNOCKOFF],[50,:WONDERROOM],[50,:TRICKROOM],[55,:DARKPULSE],
          [75,:PSYCHIC],[85,:HYPERSPACEFURY]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "height"=>proc{|pokemon|
      next 65 if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 490 if pokemon.form==1
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })


MultipleForms.register(:ORICORIO,{
    "dexEntry"=>proc{|pokemon|
      case pokemon.form      
      when 0
        next  # Baile
      when 1
        next "It creates an electric charge by rubbing its feathers together. It dances over to its enemies and delivers shocking electrical punches." # Pom-Pom
      when 2
        next "This Oricorio relaxes by swaying gently. This increases its psychic energy, which it then fires at its enemies." # Pa'u
      when 3
        next "It summons the dead with its dreamy dancing. From their malice, it draws power with which to curse its enemies." # Sensu
      end
    },
    "type1"=>proc{|pokemon|
      case pokemon.form      
      when 0
        next #getID(PBTypes,:FIRE) # Baile
      when 1
        next getID(PBTypes,:ELECTRIC) # Pom-Pom
      when 2
        next getID(PBTypes,:PSYCHIC) # Pa'u
      when 3
        next getID(PBTypes,:GHOST) # Sensu
      end
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[405]   # Map IDs for second form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        maps=[406]   # Map IDs for second form
        if $game_map && maps.include?($game_map.map_id)
          next 2
        else
          maps=[408]   # Map IDs for second form
          if $game_map && maps.include?($game_map.map_id)
            next 3
          else
            next 0
          end
        end
      end
    }
  })

MultipleForms.register(:ROCKRUFF,{
  "ability"=>proc{|pokemon|
    next if pokemon.form==0 # Male Meowstic
    #### JERICHO - 015 - START
      #### JERICHO - 015 - END
    next getID(PBAbilities,:OWNTEMPO) # Female Meowstic
  }})

MultipleForms.register(:LYCANROC,{
    "dexEntry"=>proc{|pokemon|
      case pokemon.form
      when 1; next "They live alone without forming packs. They will only listen to orders from Trainers who can draw out their true power." # Midnight
      when 2; next "Bathed in the setting sun of evening, Lycanroc has undergone a special kind of evolution. An intense fighting spirit underlies its calmness." # Dusk
      else;   next     # Midday
      end
    },
    "height"=>proc{|pokemon|
      case pokemon.form
      when 1; next 1.1 # Midnight
      when 2; next 0.8 # Dusk
      else;   next     # Midday
      end
    },
    "getBaseStats"=>proc{|pokemon|
      case pokemon.form
      when 1; next [85,115, 75, 82, 55, 75] # Midnight
      when 2; next [75,117, 65,110, 55, 65] # Dusk
      else;   next                          # Midday
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Midday
      movelist=[]
      case pokemon.form            # Midnight
      when 1 ; movelist=[[0,:COUNTER],[1,:REVERSAL],[1,:TAUNT],
          [1,:TACKLE],[1,:LEER],[1,:SANDATTACK],
          [1,:BITE],[4,:SANDATTACK],[7,:BITE],[12,:HOWL],
          [15,:ROCKTHROW],[18,:ODORSLEUTH],[23,:ROCKTOMB],
          [26,:ROAR],[29,:STEALTHROCK],[34,:ROCKSLIDE],
          [37,:SCARYFACE],[40,:CRUNCH],[45,:ROCKCLIMB],
          [48,:STONEEDGE]]
      when 2 ; movelist=[[0,:THRASH],[1,:ACCELEROCK],[1,:BITE],
          [1,:COUNTER],[1,:LEER],[1,:SANDATTACK],
          [1,:TACKLE],[4,:SANDATTACK],[7,:BITE],[12,:HOWL],
          [15,:ROCKTHROW],[18,:ODORSLEUTH],[23,:ROCKTOMB],
          [26,:ROAR],[29,:STEALTHROCK],[34,:ROCKSLIDE],
          [37,:SCARYFACE],[40,:CRUNCH],[45,:ROCKCLIMB],
          [48,:STONEEDGE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :ROAR,:TOXIC,:BULKUP,:HIDDENPOWER,:TAUNT,:PROTECT,
          :FRUSTRATION,:RETURN,:BRICKBREAK,:DOUBLETEAM,:ROCKTOMB,
          :FACADE,:REST,:ENCHANT,:ROUND,:ECHOEDVOICE,:ROCKPOLISH,
          :STONEEDGE,:SWORDSDANCE,:ROCKSLIDE,:SWAGGER,:SLEEPTALK,
          :SUBSTITUTE,:SNARL,:CONFIDE,
          # Move Tutors
          :COVET,:DUALCHOP,:EARTHPOWER,:ENDEAVOR,:FIREPUNCH,
          :FOCUSPUNCH,:FOULPLAY,:HYPERVOICE,:IRONDEFENSE,:IRONHEAD,
          :IRONTAIL,:LASERFOCUS,:LASTRESORT,:OUTRAGE,:SNORE,
          :STEALTHROCK,:STOMPINGTANTRUM,:THROATCHOP,
          :THUNDERPUNCH,:UPROAR,:ZENHEADBUTT]
      when 2; movelist=[# TMs
          :ROAR,:TOXIC,:BULKUP,:HIDDENPOWER,:TAUNT,:PROTECT,
          :FRUSTRATION,:RETURN,:BRICKBREAK,:DOUBLETEAM,:ROCKTOMB,
          :FACADE,:REST,:ENCHANT,:ROUND,:ECHOEDVOICE,:ROCKPOLISH,
          :STONEEDGE,:SWORDSDANCE,:ROCKSLIDE,:SWAGGER,:SLEEPTALK,
          :SUBSTITUTE,:SNARL,:CONFIDE,
          # Move Tutors
          :COVET,:DRILLRUN,:EARTHPOWER,:ENDEAVOR,:HYPERVOICE,
          :IRONDEFENSE,:IRONHEAD,:IRONTAIL,:LASTRESORT,:OUTRAGE,
          :SNORE,:STEALTHROCK,:STOMPINGTANTRUM,:ZENHEADBUTT]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Midday
      if pokemon.form==1      # Midnight
        if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1) # Midnight
          next getID(PBAbilities,:VITALSPIRIT)
        elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
          next getID(PBAbilities,:NOGUARD)  
        end
      end
      if pokemon.form==2      # Dusk
        next getID(PBAbilities,:TOUGHCLAWS)
      end  
    },
    "getFormOnCreation"=>proc{|pokemon|
      #   maps=[321]   # Map IDs for second form
      #   if $game_map && maps.include?($game_map.map_id)
      #     next 1
      #   else
      #     next 0
      #   end
      daytime = PBDayNight.isDay?(pbGetTimeNow)
      dusktime = PBDayNight.isDusk?(pbGetTimeNow)
      # Map IDs for second form
      if daytime
        next 0
      else
        next 1
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:WISHIWASHI,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Solo
      next "At their appearance, even Gyarados will flee. When they team up to use Water Gun, its power exceeds that of Hydro Pump."     # School
    },
    "height"=>proc{|pokemon|
      next 8.2 if pokemon.form==1
      next
    },
    "weight"=>proc{|pokemon|
      next 78.6 if pokemon.form==1
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0      # Solo
      next [45,140,130,30,140,135]   # School
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })


MultipleForms.register(:SILVALLY,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Type: Normal
      next "Upon awakening, its RKS System is activated. By employing specific memories, this Pokémon can adapt its type to confound its enemies."     # All other types
    },
    "type1"=>proc{|pokemon|
      types=[:NORMAL,:FIGHTING,:FLYING,:POISON,:GROUND,
        :ROCK,:BUG,:GHOST,:STEEL,:QMARKS,
        :FIRE,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,
        :ICE,:DRAGON,:DARK,:FAIRY]
      next getID(PBTypes,types[pokemon.form])
    },
    "type2"=>proc{|pokemon|
      types=[:NORMAL,:FIGHTING,:FLYING,:POISON,:GROUND,
        :ROCK,:BUG,:GHOST,:STEEL,:QMARKS,
        :FIRE,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,
        :ICE,:DRAGON,:DARK,:FAIRY]
      next getID(PBTypes,types[pokemon.form])
    },
    "getForm"=>proc{|pokemon|
      next 9  if $fefieldeffect == 24 # ??? on Glitch Field
      next 17 if $fefieldeffect == 29 # Dark on Holy Field (Because Science is evil)
      next 1  if isConst?(pokemon.item,PBItems,:FIGHTINGMEMORY)
      next 2  if isConst?(pokemon.item,PBItems,:FLYINGMEMORY)
      next 3  if isConst?(pokemon.item,PBItems,:POISONMEMORY)
      next 4  if isConst?(pokemon.item,PBItems,:GROUNDMEMORY)
      next 5  if isConst?(pokemon.item,PBItems,:ROCKMEMORY)
      next 6  if isConst?(pokemon.item,PBItems,:BUGMEMORY)
      next 7  if isConst?(pokemon.item,PBItems,:GHOSTMEMORY)
      next 8  if isConst?(pokemon.item,PBItems,:STEELMEMORY)
      next 10 if isConst?(pokemon.item,PBItems,:FIREMEMORY)
      next 11 if isConst?(pokemon.item,PBItems,:WATERMEMORY)
      next 12 if isConst?(pokemon.item,PBItems,:GRASSMEMORY)
      next 13 if isConst?(pokemon.item,PBItems,:ELECTRICMEMORY)
      next 14 if isConst?(pokemon.item,PBItems,:PSYCHICMEMORY)
      next 15 if isConst?(pokemon.item,PBItems,:ICEMEMORY)
      next 16 if isConst?(pokemon.item,PBItems,:DRAGONMEMORY)
      next 17 if isConst?(pokemon.item,PBItems,:DARKMEMORY)
      next 18 if isConst?(pokemon.item,PBItems,:FAIRYMEMORY)
      next 0
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:MINIOR,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form!=6      # Core
      next "Originally making its home in the ozone layer, it hurtles to the ground when the shell enclosing its body grows too heavy."     # Meteor
    },
    "getFormOnCreation"=>proc{|pokemon|
      next rand(6)
    },
    "weight"=>proc{|pokemon|
      next 40.0 if pokemon.form==6
      next
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form!=6     # Core
      next [60,60,100,60,60,100]   # Meteor
    },
    "catchrate"=>proc{|pokemon|
      next 30 if pokemon.form==6
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:VIVILLON,{
    "getFormOnCreation"=>proc{|pokemon|
      next rand(9)  # Forms 0-8 are regular patterns, form 9 is Mystic
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form!=10
      next getID(PBTypes,:BUG)    # Mystic
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form!=10
      next getID(PBTypes,:DRAGON)    # Mystic
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form!=10
      next [52, 80, 50, 90, 89, 50]   # Mystic
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form!=10 # Only Mystic form
      if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
        next getID(PBAbilities,:SWARM)
      end
      if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:NATURALCURE)
      end
      if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:MULTISCALE)
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form!=10      # Use default moveset for regular forms
      movelist=[]
      # Mystic form movelist
      movelist=[[0,:TWISTER],[1,:DRAGONRUSH],[1,:HURRICANE],[1,:IRRITATION],
                [1,:EXTREMESPEED],[1,:GLARE],[12,:WINDVORTEX],[17,:ANCIENTPOWER],
                [21,:AGILITY],[25,:BREAKINGSWIPE],[31,:BLUESHIFT],[35,:XSCISSOR],
                [41,:ROOST],[45,:DRAGONDANCE],[50,:DRAGONPULSE],[55,:PESTILENTWAVE]]
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form!=10
      movelist=[]
      # Mystic form TM compatibility
      movelist=[:AGILITY,:AIRSLASH,:ATTRACT,:BREAKINGSWIPE,:BUGBITE,:BUGBUZZ,:BULKUP,:CALMMIND,:CONFIDE,:DEFOG,:DRACOMETEOR,:DRAGONCHEER,:DRAGONPULSE,:ELECTROWEB,:ENDURE,:FACADE,:FLASH,:FRUSTRATION,:GIGADRAIN,:GILDEDBARGAIN,:HIDDENPOWER,:HURRICANE,:HYPERBEAM,:INFESTATION,:IRONDEFENSE,:IRRITATION,:LIGHTSCREEN,:LOCUSTSWARM,:OUTRAGE,:POLLENPUFF,:PROTECT,:PSYCHUP,:RAINDANCE,:REFLECT,:REST,:RETURN,:ROOST,:ROUND,:SCALESHOT,:SCARYFACE,:SECRETPOWER,:SIGNALBEAM,:SLEEPTALK,:SNORE,:STRUGGLEBUG,:SUBSTITUTE,:SUNNYDAY,:SWAGGER,:SWORDSDANCE,:TAILWIND,:THIEF,:TOXIC,:UTURN,:XSCISSOR]
      next movelist
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:NECROZMA,{
    "dexEntry"=>proc{|pokemon|
      case pokemon.form
      when 1; next "This is its form while it is devouring the light of Solgaleo. It pounces on foes and then slashes them with the claws on its four limbs and back." # Dusk Mane Necrozma
      when 2; next "This is its form while it's devouring the light of Lunala. It grasps foes in its giant claws and rips them apart with brute force." # Dawn Wings Necrozma
      when 3; next "The light pouring out from all over its body affects living things and nature, impacting them in various ways." # Ultra Necrozma
      else;   next                          # Necrozma
      end
    },
    "getBaseStats"=>proc{|pokemon|
      case pokemon.form
      when 1; next [97,157,127, 77,113,109] # Dusk Mane Necrozma
      when 2; next [97,113,109, 77,157,127] # Dawn Wings Necrozma
      when 3; next [97,167, 97,129,167, 97] # Ultra Necrozma
      else;   next                          # Necrozma
      end
    },
    "height"=>proc{|pokemon|
      case pokemon.form
      when 1; next 3.8 # Dusk Mane Necrozma
      when 2; next 4.2 # Dawn Wings Necrozma
      when 3; next 7.5 # Ultra Necrozma
      else;   next     # Necrozma
      end
    },
    "weight"=>proc{|pokemon|
      case pokemon.form
      when 1; next 460 # Dusk Mane Necrozma
      when 2; next 350 # Dawn Wings Necrozma
      when 3; next 230 # Ultra Necrozma
      else;   next     # Necrozma
      end
    },
    "type1"=>proc{|pokemon|
      case pokemon.form
      when 1; next getID(PBTypes,:PSYCHIC) # Dusk Mane Necrozma
      when 2; next getID(PBTypes,:PSYCHIC) # Dawn Wings Necrozma
      when 3; next getID(PBTypes,:PSYCHIC) # Ultra Necrozma
      else;   next     # Necrozma
      end
    },
    "type2"=>proc{|pokemon|
      case pokemon.form
      when 1; next getID(PBTypes,:STEEL)  # Dusk Mane Necrozma
      when 2; next getID(PBTypes,:GHOST)  # Dawn Wings Necrozma
      when 3; next getID(PBTypes,:DRAGON) # Ultra Necrozma
      else;   next                        # Necrozma
      end
    },
    "ability"=>proc{|pokemon|
      case pokemon.form
      when 3; next (PBAbilities::NEUROFORCE) # Ultra
      else;   next                                # Other formes
      end
    },
    "evYield"=>proc{|pokemon|
      case pokemon.form
      when 1; next [0,3,0,0,0,0] # Dusk Mane Necrozma
      when 2; next [0,0,0,0,3,0] # Dawn Wings Necrozma
      when 3; next [0,1,0,1,1,0] # Ultra Necrozma
      else;   next               # Necrozma
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:ZACIAN,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "Able to cut down anything with a single strike, it became known as the Fairy King's Sword, and it inspired awe in friend and foe alike." # Crowned Sword
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next [92,170,115,148,80,115]   # Crowned Sword
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:FAIRY)    # Crowned Sword
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:STEEL)  # Crowned Sword
    },
    "weight"=>proc{|pokemon|
      next 355.0 if pokemon.form==1
      next
    },
    "getForm"=>proc{|pokemon|
      next 1  if isConst?(pokemon.item,PBItems,:RUSTEDSWORD)
      next 0
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:ZAMAZENTA,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "Its ability to deflect any attack led to it being known as the Fighting Master's Shield. It was feared and respected by all." # Crowned Shield
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next [92,130,145,128,80,145]   # Crowned Shield
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0       # Normal
      next getID(PBTypes,:FIGHTING) # Crowned Shield
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0    # Normal
      next getID(PBTypes,:STEEL) # Crowned Shield
    },
    "weight"=>proc{|pokemon|
      next 785.0 if pokemon.form==1
      next
    },
    "getForm"=>proc{|pokemon|
      next 1  if isConst?(pokemon.item,PBItems,:RUSTEDSHIELD)
      next 0
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:EISCUE,{
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0             # Ice Forme
      case pokemon.form
      when 1; next [75,80,70,130,65,50] # Noice Forme
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })
  
### Heroic Pokemon ###
MultipleForms.register(:TANGROWTH,{
    "getForm"=>proc{|pokemon|
      # Heroic Tangrowth - check if holding Meadow Tribute
      heroic_form = pbGetHeroicForm(pokemon) if defined?(pbGetHeroicForm)
      next heroic_form if heroic_form
      next 0
    }
  })
  
MultipleForms.register(:MISMAGIUS,{
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if ((pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)) || (pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)) || (pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0))) # Heroic
        next getID(PBAbilities,:ILLUSORYSHROUD) 
      end
    },
    "getForm"=>proc{|pokemon|
      next 1  if isConst?(pokemon.item,PBItems,:MISTRIBUTE)
      next 0
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
      moves=[
        :POLYMORPHIZE
      ]
      moves.each{|move|
        pbDeleteMoveByID(pokemon,getID(PBMoves,move))
      }
      if form>0
        pokemon.pbLearnMove(moves[form-1])
      end
      if pokemon.moves.find_all{|i| i.id!=0}.length==0
        pokemon.pbLearnMove(:HEX)
      end
    }
  })
### Regional Variants ###
MultipleForms.register(:RATTATA,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "With its incisors, it gnaws through doors and infiltrates people’s homes. Then, with a twitch of its whiskers, it steals whatever food it finds."     # Alola
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 38                      # Alola
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:DARK)    # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:NORMAL)  # Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[1,:TACKLE],[1,:TAILWHIP],[4,:QUICKATTACK],
          [7,:FOCUSENERGY],[10,:BITE],[13,:PURSUIT],
          [16,:HYPERFANG],[19,:ASSURANCE],[22,:CRUNCH],
          [25,:SUCKERPUNCH],[28,:SUPERFANG],[31,:DOUBLEEDGE],
          [34,:ENDEAVOR]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Alola
      when 1 ; eggmovelist=[:COUNTER,:FINALGAMBIT,:FURYSWIPES,:MEFIRST,
          :REVENGE,:REVERSAL,:SNATCH,:STOCKPILE,
          :SWALLOW,:SWITCHEROO,:UPROAR]
      end
      for i in eggmovelist
        i=getID(PBMoves,i)
      end
      next eggmovelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :TOXIC,:HIDDENPOWER,:SUNNYDAY,:TAUNT,:ICEBEAM,:BLIZZARD,
          :PROTECT,:RAINDANCE,:FRUSTRATION,:RETURN,:SHADOWBALL,
          :DOUBLETEAM,:SLUDGEBOMB,:TORMENT,:FACADE,:REST,:ENCHANT,
          :ROUND,:QUASH,:EMBARGO,:SHADOWCLAW,:GRASSKNOT,:SWAGGER,
          :SLEEPTALK,:UTURN,:SUBSTITUTE,:SNARL,:DARKPULSE,:CONFIDE,
          # Move Tutors
          :COVET,:ENDEAVOR,:ICYWIND,:IRONTAIL,:LASTRESORT,:SHOCKWAVE,
          :SNATCH,:SNORE,:SUPERFANG,:UPROAR,:ZENHEADBUTT]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    }, 
    "wildHoldItems"=>proc{|pokemon|
      next if pokemon.form==0                 # Normal
      next [0,getID(PBItems,:PECHABERRY),0]   # Alola
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
        next getID(PBAbilities,:GLUTTONY)
      elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:HUSTLE)
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:THICKFAT)  
      end
    },
    
    "getFormOnCreation"=>proc{|pokemon|
      maps=[55,58,59,91,144,194,209,218]   # Map IDs for second form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    },
    
    "getEvo"=>proc{|pokemon|
      next if pokemon.form==0                  # Normal
      next [[30,20,20]]                        # Alola    [LevelNight,20,Raticate]  
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:RATICATE,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "It forms a group of Rattata, which it assumes command of. Each group has its own territory, and disputes over food happen often."     # Alola
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 255                     # Alola
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:DARK)    # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:NORMAL)  # Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[0,:SCARYFACE],[1,:SWORDSDANCE],[1,:TACKLE],
          [1,:TAILWHIP],[1,:QUICKATTACK],[1,:FOCUSENERGY],
          [4,:QUICKATTACK],[7,:FOCUSENERGY],[10,:BITE],[13,:PURSUIT],
          [16,:HYPERFANG],[19,:ASSURANCE],[24,:CRUNCH],
          [29,:SUCKERPUNCH],[34,:SUPERFANG],[39,:DOUBLEEDGE],
          [44,:ENDEAVOR]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :ROAR,:TOXIC,:BULKUP,:VENOSHOCK,:HIDDENPOWER,:SUNNYDAY,
          :TAUNT,:ICEBEAM,:BLIZZARD,:HYPERBEAM,:PROTECT,:RAINDANCE,
          :FRUSTRATION,:RETURN,:SHADOWBALL,:DOUBLETEAM,:SLUDGEWAVE,
          :SLUDGEBOMB,:TORMENT,:FACADE,:REST,:ENCHANT,:THIEF,:ROUND,
          :QUASH,:EMBARGO,:SHADOWCLAW,:GIGAIMPACT,:SWORDSDANCE,
          :GRASSKNOT,:SWAGGER,:SLEEPTALK,:UTURN,:SUBSTITUTE,:SNARL,
          :DARKPULSE,:CONFIDE,
          # Move Tutors
          :COVET,:ENDEAVOR,:ICYWIND,:IRONTAIL,:KNOCKOFF,:LASTRESORT,
          :SHOCKWAVE,:SNATCH,:SNORE,:STOMPINGTANTRUM,:SUPERFANG,
          :THROATCHOP,:UPROAR,:ZENHEADBUTT]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "wildHoldItems"=>proc{|pokemon|
      next if pokemon.form==0                 # Normal
      next [0,getID(PBItems,:PECHABERRY),0]   # Alola
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next [75,71,70,77,40,80]   # Alola
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
        next getID(PBAbilities,:GLUTTONY)
      elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:HUSTLE)
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:THICKFAT)  
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[55,58,59,91,144]   # Map IDs for second form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    }
  })

MultipleForms.register(:RAICHU,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "It uses psychokinesis to control electricity. It hops aboard its own tail, using psychic power to lift the tail and move about while riding it."  # Alola
    },
    "height"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 7                       # Alola
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 210                    # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:PSYCHIC)  # Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[0,:PSYCHIC],[1,:SPEEDSWAP],[1,:THUNDERSHOCK],
          [1,:TAILWHIP],[1,:QUICKATTACK],[1,:THUNDERBOLT]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :PSYSHOCK,:CALMMIND,:TOXIC,:HIDDENPOWER,:HYPERBEAM,
          :LIGHTSCREEN,:PROTECT,:RAINDANCE,:SAFEGUARD,:FRUSTRATION,
          :THUNDERBOLT,:THUNDER,:RETURN,:PSYCHIC,:BRICKBREAK,
          :DOUBLETEAM,:REFLECT,:FACADE,:REST,:ENCHANT,:THIEF,
          :ROUND,:ECHOEDVOICE,:FOCUSBLAST,:FLING,:CHARGEBEAM,
          :GIGAIMPACT,:VOLTSWITCH,:THUNDERWAVE,:GRASSKNOT,:SWAGGER,
          :SLEEPTALK,:SUBSTITUTE,:WILDCHARGE,:CONFIDE,
          # Move Tutors
          :ALLYSWITCH,:COVET,:ELECTROWEB,:FOCUSPUNCH,:HELPINGHAND,
          :IRONTAIL,:KNOCKOFF,:LASERFOCUS,:MAGICCOAT,:MAGICROOM,
          :MAGNETRISE,:RECYCLE,:SHOCKWAVE,:SIGNALBEAM,:SNORE,
          :TELEKINESIS,:THUNDERPUNCH]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next [60,85,50,110,95,85]    # Alola
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0              # Normal   
      next getID(PBAbilities,:SURGESURFER) # Alola
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:SANDSHREW,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "It lives on snowy mountains. Its steel shell is very hard—so much so, it can’t roll its body up into a ball."  # Alola
    },
    "height"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 7                       # Alola
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 400                    # Alola
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:ICE)     # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:STEEL)   # Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[1,:SCRATCH],[1,:DEFENSECURL],[3,:BIDE],
          [5,:POWDERSNOW],[7,:ICEBALL],[9,:RAPIDSPIN],
          [11,:FURYCUTTER],[14,:METALCLAW],[17,:SWIFT],
          [20,:FURYSWIPES],[23,:IRONDEFENSE],[26,:SLASH],
          [30,:IRONHEAD],[34,:GYROBALL],[38,:SWORDSDANCE],
          [42,:HAIL],[46,:BLIZZARD]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Alola
      when 1 ; eggmovelist=[:AMNESIA,:CHIPAWAY,:COUNTER,:CRUSHCLAW,:CURSE,
          :ENDURE,:FLAIL,:ICICLECRASH,:ICICLESPEAR,
          :METALCLAW,:NIGHTSLASH,:HONECLAWS]
      end
      for i in eggmovelist
        i=getID(PBMoves,i)
      end
      next eggmovelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :WORKUP,:TOXIC,:HAIL,:HIDDENPOWER,:SUNNYDAY,:BLIZZARD,
          :PROTECT,:SAFEGUARD,:FRUSTRATION,:EARTHQUAKE,:RETURN,
          :LEECHLIFE,:BRICKBREAK,:DOUBLETEAM,:AERIALACE,:FACADE,:REST,
          :ENCHANT,:THIEF,:ROUND,:FLING,:SHADOWCLAW,:AURORAVEIL,
          :GYROBALL,:SWORDSDANCE,:BULLDOZE,:FROSTBREATH,:ROCKSLIDE,
          :XSCISSOR,:POISONJAB,:SWAGGER,:SLEEPTALK,:SUBSTITUTE,:CONFIDE,
          # Move Tutors
          :AQUATAIL,:COVET,:FOCUSPUNCH,:ICEPUNCH,:ICYWIND,:IRONDEFENSE,
          :IRONHEAD,:IRONTAIL,:KNOCKOFF,:SNORE,:STEALTHROCK,:SUPERFANG,
          :THROATCHOP]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next [50,75,90,40,10,35]     # Alola
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
        next getID(PBAbilities,:SNOWCLOAK)
      elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:SLUSHRUSH)  
      elsif pokemon.abilityIndex==2 && !pokemon.abilityflag
        check = (pokemon.personalID)&1
        next getID(PBAbilities,:SNOWCLOAK) if check==0
        next getID(PBAbilities,:SLUSHRUSH) if check==1
      end
    },
    "getFormOnCreation"=>proc{|pokemon|
    maps=[146,150,165,171,174,178,181,269,479,480,481,482,483,485,486,490,491] # Map IDs for second form
    if $game_map && maps.include?($game_map.map_id)
      next 1
    else
      next 0
    end
    },
    "getEvo"=>proc{|pokemon|
      next if pokemon.form==0                  # Normal
      next [[7,692,28]]                        # Alola    [Item,Ice Stone,Sandslash]  
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:SANDSLASH,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "This Pokémon’s steel spikes are sheathed in ice. Stabs from these spikes cause deep wounds and severe frostbite as well."  # Alola
    },
    "height"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 12                      # Alola
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 550                    # Alola
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:ICE)     # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:STEEL)   # Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[0,:ICICLESPEAR],[1,:METALBURST],[1,:ICICLECRASH],
          [1,:SLASH],[1,:DEFENSECURL],[1,:ICEBALL],
          [1,:METALCLAW]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :WORKUP,:TOXIC,:HAIL,:HIDDENPOWER,:SUNNYDAY,:BLIZZARD,
          :HYPERBEAM,:PROTECT,:SAFEGUARD,:FRUSTRATION,:EARTHQUAKE,
          :RETURN,:LEECHLIFE,:BRICKBREAK,:DOUBLETEAM,:AERIALACE,
          :FACADE,:REST,:ENCHANT,:THIEF,:ROUND,:FOCUSBLAST,:FLING,
          :SHADOWCLAW,:GIGAIMPACT,:AURORAVEIL,:GYROBALL,:SWORDSDANCE,
          :BULLDOZE,:FROSTBREATH,:ROCKSLIDE,:XSCISSOR,:POISONJAB,
          :SWAGGER,:SLEEPTALK,:SUBSTITUTE,:CONFIDE,
          # Move Tutors
          :AQUATAIL,:COVET,:DRILLRUN,:FOCUSPUNCH,:ICEPUNCH,:ICYWIND,
          :IRONDEFENSE,:IRONHEAD,:IRONTAIL,:KNOCKOFF,:SNORE,
          :STEALTHROCK,:SUPERFANG,:THROATCHOP]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next [75,100,120,65,25,65]     # Alola
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
        next getID(PBAbilities,:SNOWCLOAK)
      elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:SLUSHRUSH)  
      elsif pokemon.abilityIndex==2 && !pokemon.abilityflag
        check = (pokemon.personalID)&1
        next getID(PBAbilities,:SNOWCLOAK) if check==0
        next getID(PBAbilities,:SLUSHRUSH) if check==1
      end
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[146,150,165,171,174,178,181,269,479,480,481,482,483,485,486,490,491] # Map IDs for second form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:VULPIX,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "In hot weather, this Pokémon makes ice shards with its six tails and sprays them around to cool itself off."     # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:ICE)     # Alola
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:ICE)     # Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[1,:POWDERSNOW],[4,:TAILWHIP],[7,:ROAR],
          [9,:BABYDOLLEYES],[10,:ICESHARD],[12,:CONFUSERAY],
          [15,:ICYWIND],[18,:PAYBACK],[20,:MIST],
          [23,:FEINTATTACK],[26,:HEX],[28,:AURORABEAM],
          [31,:EXTRASENSORY],[34,:SAFEGUARD],[36,:ICEBEAM],
          [39,:IMPRISON],[42,:BLIZZARD],[44,:GRUDGE],                        
          [47,:CAPTIVATE],[50,:SHEERCOLD]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Alola
      when 1 ; eggmovelist=[:AGILITY,:CHARM,:DISABLE,:ENCORE,
          :EXTRASENSORY,:FLAIL,:FREEZEDRY,:HOWL,
          :HYPNOSIS,:MOONBLAST,:POWERSWAP,:SPITE,
          :SECRETPOWER,:TAILSLAP]
      end
      for i in eggmovelist
        i=getID(PBMoves,i)
      end
      next eggmovelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :ROAR,:TOXIC,:HAIL,:HIDDENPOWER,:ICEBEAM,:BLIZZARD,:PROTECT,
          :RAINDANCE,:SAFEGUARD,:FRUSTRATION,:RETURN,:DOUBLETEAM,
          :FACADE,:REST,:ENCHANT,:ROUND,:PAYBACK,:AURORAVEIL,:PSYCHUP,
          :FROSTBREATH,:SWAGGER,:SLEEPTALK,:SUBSTITUTE,:DARKPULSE,
          :CONFIDE,
          # Move Tutors
          :AQUATAIL,:COVET,:FOULPLAY,:HEALBELL,:ICYWIND,:IRONTAIL,
          :PAINSPLIT,:ROLEPLAY,:SNORE,:SPITE,:ZENHEADBUTT]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "wildHoldItems"=>proc{|pokemon|
      next if pokemon.form==0                 # Normal
      next [0,getID(PBItems,:SNOWBALL),0]     # Alola
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
        next getID(PBAbilities,:SNOWCLOAK)
      elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:SNOWWARNING)  
      elsif pokemon.abilityIndex==2 && !pokemon.abilityflag
        check = (pokemon.personalID)&1
        next getID(PBAbilities,:SNOWCLOAK) if check==0
        next getID(PBAbilities,:SNOWWARNING) if check==1
      end
    },
    "getEvo"=>proc{|pokemon|
      next if pokemon.form==0                  # Normal
      next [[7,692,38]]                        # Alola    [Item,Ice Stone,Ninetales]  
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:NINETALES,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "Possessing a calm demeanor, this Pokémon was revered as a deity incarnate before it was identified as a regional variant of Ninetales."     # Alola
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:ICE)     # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:FAIRY)   # Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[0,:DAZZLINGGLEAM],[1,:IMPRISON],[1,:NASTYPLOT],
          [1,:ICEBEAM],[1,:ICESHARD],[1,:CONFUSERAY],
          [1,:SAFEGUARD]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :PSYCHOCK,:CALMMIND,:ROAR,:TOXIC,:HAIL,:HIDDENPOWER,
          :ICEBEAM,:BLIZZARD,:HYPERBEAM,:PROTECT,:RAINDANCE,
          :SAFEGUARD,:FRUSTRATION,:RETURN,:DOUBLETEAM,:FACADE,
          :REST,:ENCHANT,:ROUND,:PAYBACK,:GIGAIMPACT,:AURORAVEIL,
          :PSYCHUP,:FROSTBREATH,:DREAMEATER,:SWAGGER,:SLEEPTALK,
          :SUBSTITUTE,:DARKPULSE,:DAZZLINGGLEAM,:CONFIDE,
          # Move Tutors
          :AQUATAIL,:COVET,:FOULPLAY,:HEALBELL,:ICYWIND,:IRONTAIL,
          :LASERFOCUS,:PAINSPLIT,:ROLEPLAY,:SNORE,:SPITE,
          :WONDERROOM,:ZENHEADBUTT]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "wildHoldItems"=>proc{|pokemon|
      next if pokemon.form==0                 # Normal
      next [0,getID(PBItems,:SNOWBALL),0]     # Alola
    },
    "evYield"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next [0,0,0,2,0,0]           # Alola
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next [73,67,75,109,81,100]   # Alola
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
        next getID(PBAbilities,:SNOWCLOAK)
      elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:SNOWWARNING)  
      elsif pokemon.abilityIndex==2 && !pokemon.abilityflag
        check = (pokemon.personalID)&1
        next getID(PBAbilities,:SNOWCLOAK) if check==0
        next getID(PBAbilities,:SNOWWARNING) if check==1
      end
    },
    
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:DIGLETT,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "Its head sports an altered form of whiskers made of metal. When in communication with its comrades, its whiskers wobble to and fro."  # Alola
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 10                      # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:STEEL)   # Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[1,:SANDATTACK],[1,:METALCLAW],[4,:GROWL],
          [7,:ASTONISH],[10,:MUDSLAP],[14,:MAGNITUDE],
          [18,:BULLDOZE],[22,:SUCKERPUNCH],[25,:MUDBOMB],
          [28,:EARTHPOWER],[31,:DIG],[35,:IRONHEAD],
          [39,:EARTHQUAKE],[43,:FISSURE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Alola
      when 1 ; eggmovelist=[:ANCIENTPOWER,:BEATUP,:ENDURE,:FEINTATTACK,
          :FINALGAMBIT,:HEADBUTT,:MEMENTO,:METALSOUND,
          :PURSUIT,:REVERSAL,:FLASH]
      end
      for i in eggmovelist
        i=getID(PBMoves,i)
      end
      next eggmovelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :WORKUP,:TOXIC,:HIDDENPOWER,:SUNNYDAY,:PROTECT,:FRUSTRATION,
          :EARTHQUAKE,:RETURN,:DOUBLETEAM,:SLUDGEBOMB,:SANDSTORM,
          :ROCKTOMB,:AERIALACE,:FACADE,:REST,:ENCHANT,:THIEF,:ROUND,
          :ECHOEDVOICE,:SHADOWCLAW,:BULLDOZE,:ROCKSLIDE,:SWAGGER,
          :SLEEPTALK,:SUBSTITUTE,:FLASHCANNON,:CONFIDE,:SLASHANDBURN,
          # Move Tutors
          :EARTHPOWER,:IRONDEFENSE,:IRONHEAD,:SNORE,
          :STEALTHROCK,:STOMPINGTANTRUM]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next [10,55,30,90,35,40]     # Alola
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1) # Alola
        next getID(PBAbilities,:TANGLINGHAIR) 
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[117,121,122,123,124]   # Map IDs for second form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    }
  })

MultipleForms.register(:DUGTRIO,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "Its shining gold hair provides it with protection. It’s reputed that keeping any of its fallen hairs will bring bad luck."  # Alola
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 666                     # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:STEEL)   # Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[0,:SANDTOMB],[1,:ROTOTILLER],[1,:NIGHTSLASH],
          [1,:TRIATTACK],[1,:SANDATTACK],[1,:METALCLAW],[1,:GROWL],
          [4,:GROWL],[7,:ASTONISH],[10,:MUDSLAP],[14,:MAGNITUDE],
          [18,:BULLDOZE],[22,:SUCKERPUNCH],[25,:MUDBOMB],
          [30,:EARTHPOWER],[35,:DIG],[41,:IRONHEAD],
          [47,:EARTHQUAKE],[53,:FISSURE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :WORKUP,:TOXIC,:HIDDENPOWER,:SUNNYDAY,:HYPERBEAM,:PROTECT,
          :FRUSTRATION,:EARTHQUAKE,:RETURN,:DOUBLETEAM,:SLUDGEWAVE,
          :SLUDGEBOMB,:SANDSTORM,:ROCKTOMB,:AERIALACE,:FACADE,:REST,
          :ENCHANT,:THIEF,:ROUND,:ECHOEDVOICE,:SHADOWCLAW,:GIGAIMPACT,
          :STONEEDGE,:BULLDOZE,:ROCKSLIDE,:SWAGGER,:SLEEPTALK,
          :SUBSTITUTE,:FLASHCANNON,:CONFIDE,:SLASHANDBURN,
          # Move Tutors
          :EARTHPOWER,:IRONDEFENSE,:IRONHEAD,:SNORE,
          :STEALTHROCK,:STOMPINGTANTRUM]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "evYield"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next [0,2,0,0,0,0]           # Alola
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next [35,100,60,110,50,70]     # Alola
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1) # Alola
        next getID(PBAbilities,:TANGLINGHAIR) 
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:MEOWTH,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "When its delicate pride is wounded, or when the gold coin on its forehead is dirtied, it flies into a hysterical rage." if pokemon.form==1  # Alola
      next "These daring Pokémon have coins on their foreheads. Darker coins are harder, and harder coins garner more respect among Meowth." # Galarian
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:DARK) if pokemon.form==1   # Alola
      next getID(PBTypes,:STEEL)    # GALAR
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:DARK) if pokemon.form==1   # Alola
      next getID(PBTypes,:STEEL)    # Galar
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alolan and Galarian
      when 1 ; movelist=[[1,:SCRATCH],[1,:GROWL],[6,:BITE],
          [9,:FAKEOUT],[14,:FURYSWIPES],[17,:SCREECH],
          [22,:FEINTATTACK],[25,:TAUNT],[30,:PAYDAY],
          [33,:SLASH],[38,:NASTYPLOT],[41,:ASSURANCE],
          [46,:CAPTIVATE],[49,:NIGHTSLASH],[50,:FEINT],
          [55,:DARKPULSE]]
      when 2 ; movelist=[[1,:FAKEOUT],[1,:GROWL],[4,:HONECLAWS],
          [8,:SCRATCH],[12,:PAYDAY],[16,:METALCLAW],
          [20,:TAUNT],[24,:SWAGGER],[29,:FURYSWIPES],
          [32,:SCREECH],[36,:SLASH],[40,:METALSOUND],
          [44,:THRASH]]  
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Alolan and Galarian
      when 1 ; eggmovelist=[:AMNESIA,:ASSIST,:CHARM,:COVET,:FLAIL,:FLATTER,
          :FOULPLAY,:HYPNOSIS,:PARTINGSHOT,:PUNISHMENT,
          :SNATCH,:SPITE]
      when 2 ; eggmovelist=[:COVET,:FLAIL,:SPITE,:DOUBLEEDGE,:CURSE,:NIGHTSLASH]
      end
      for i in eggmovelist
        i=getID(PBMoves,i)
      end
      next eggmovelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :WORKUP,:TOXIC,:HIDDENPOWER,:SUNNYDAY,:TAUNT,:PROTECT,
          :RAINDANCE,:FRUSTRATION,:THUNDERBOLT,:THUNDER,:RETURN,
          :SHADOWBALL,:DOUBLETEAM,:AERIALACE,:TORMENT,:FACADE,:REST,
          :ENCHANT,:THIEF,:ROUND,:ECHOEDVOICE,:QUASH,:EMBARGO,
          :SHADOWCLAW,:PAYBACK,:PSYCHUP,:DREAMEATER,:SWAGGER,
          :SLEEPTALK,:UTURN,:SUBSTITUTE,:DARKPULSE,:CONFIDE,
          # Move Tutors
          :COVET,:FOULPLAY,:GUNKSHOT,:HYPERVOICE,:ICEWIND,:IRONTAIL,
          :KNOCKOFF,:LASTRESORT,:SEEDBOMB,:SHOCKWAVE,:SNATCH,:SNORE,
          :SPITE,:THROATCHOP,:UPROAR,:WATERPULSE]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "evYield"=>proc{|pokemon|
      next if pokemon.form!=2      # Normal/Alola
      next [0,1,0,0,0,0]           # Galarian
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      case pokemon.form  
      when 1 ; next [40,35,35,90,50,40]     # Alola
      when 2 ; next [50,65,55,40,40,40]     # Galarian
      end
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      case pokemon.form
      when 1
        if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2) # Alola
          next getID(PBAbilities,:RATTLED)
        end
      when 2
        if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1) # Galar
          next getID(PBAbilities,:TOUGHCLAWS)    
        end
      end
    },
    "getEvo"=>proc{|pokemon|
      next if pokemon.form==0                  # Normal
      next [[4,28,53]]                          # Alola    [Happiness,,Persian]  
      next [[4,28,863]]                        # Galar    [Level,28,Perrserker]   
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    },
    "getFormOnCreation"=>proc{|pokemon|
      aMaps=[123,124]   # Map IDs for second form
      gMaps=[97,238]
      # Map IDs for alolan and galarian forms respectively
      if $game_map && aMaps.include?($game_map.map_id)
        next 1
      elsif $game_map && gMaps.include?($game_map.map_id)
        next 2
      else
        next 0
      end
    }
  })

MultipleForms.register(:PERSIAN,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "It looks down on everyone other than itself. Its preferred tactics are sucker punches and blindside attacks."  # Alola
    },
    "height"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 11                      # Alola
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 330                     # Alola
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:DARK)    # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:DARK)    # Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[0,:SWIFT],[1,:QUASH],[1,:PLAYROUGH],[1,:SWITCHEROO],
          [1,:SCRATCH],[1,:GROWL],[1,:BITE],[1,:FAKEOUT],[6,:BITE],                        
          [9,:FAKEOUT],[14,:FURYSWIPES],[17,:SCREECH],
          [22,:FEINTATTACK],[25,:TAUNT],[32,:POWERGEM],
          [37,:SLASH],[44,:NASTYPLOT],[49,:ASSURANCE],
          [56,:CAPTIVATE],[61,:NIGHTSLASH],[65,:FEINT],
          [69,:DARKPULSE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :WORKUP,:ROAR,:TOXIC,:HIDDENPOWER,:SUNNYDAY,:TAUNT,
          :HYPERBEAM,:PROTECT,:RAINDANCE,:FRUSTRATION,:THUNDERBOLT,
          :THUNDER,:RETURN,:SHADOWBALL,:DOUBLETEAM,:AERIALACE,:TORMENT,
          :FACADE,:REST,:ENCHANT,:THIEF,:ROUND,:ECHOEDVOICE,:QUASH,
          :EMBARGO,:SHADOWCLAW,:PAYBACK,:GIGAIMPACT,:PSYCHUP,
          :DREAMEATER,:SWAGGER,:SLEEPTALK,:UTURN,:SUBSTITUTE,:SNARL,
          :DARKPULSE,:CONFIDE,
          # Move Tutors
          :COVET,:FOULPLAY,:GUNKSHOT,:HYPERVOICE,:ICEWIND,:IRONTAIL,
          :KNOCKOFF,:LASTRESORT,:SEEDBOMB,:SHOCKWAVE,:SNATCH,:SNORE,
          :SPITE,:THROATCHOP,:UPROAR,:WATERPULSE]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next [65,60,60,115,75,65]    # Alola
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
        next getID(PBAbilities,:FURCOAT)
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:RATTLED)  
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[390,391]   # Map IDs for second form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    }
  })

MultipleForms.register(:GEODUDE,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "If you accidentally step on a Geodude sleeping on the ground, you’ll hear a crunching sound and feel a shock ripple through your entire body."  # Alola
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 203                     # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:ELECTRIC)# Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[1,:TACKLE],[1,:DEFENSECURL],[4,:CHARGE],
          [6,:ROCKPOLISH],[10,:ROLLOUT],[12,:SPARK],
          [16,:ROCKTHROW],[18,:SMACKDOWN],[22,:THUNDERPUNCH],
          [24,:SELFDESTRUCT],[28,:STEALTHROCK],[30,:ROCKBLAST],
          [34,:DISCHARGE],[36,:EXPLOSION],[40,:DOUBLEEDGE],
          [42,:STONEEDGE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Alola
      when 1 ; eggmovelist=[:AUTOTOMIZE,:BLOCK,:COUNTER,:CURSE,:ENDURE,:FLAIL,
          :MAGNETRISE,:ROCKCLIMB,:SCREECH,:WIDEGUARD]
      end
      for i in eggmovelist
        i=getID(PBMoves,i)
      end
      next eggmovelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :TOXIC,:HIDDENPOWER,:SUNNYDAY,:PROTECT,:FRUSTRATION,
          :SMACKDOWN,:THUNDERBOLT,:THUNDER,:EARTHQUAKE,:RETURN,
          :BRICKBREAK,:DOUBLETEAM,:FLAMETHROWER,:SANDSTORM,
          :FIREBLAST,:ROCKTOMB,:FACADE,:REST,:ENCHANT,:ROUND,
          :FLING,:CHARGEBEAM,:BRUTALSWING,:EXPLOSION,:ROCKPOLISH,
          :STONEEDGE,:VOLTSWITCH,:GYROBALL,:BULLDOZE,:ROCKSLIDE,
          :SWAGGER,:SLEEPTALK,:SUBSTITUTE,:NATUREPOWER,:CONFIDE,
          # Move Tutors
          :BLOCK,:EARTHPOWER,:ELECTROWEB,:FIREPUNCH,:FOCUSPUNCH,
          :IRONDEFENSE,:MAGNETRISE,:SNORE,:STEALTHROCK,
          :SUPERPOWER,:THUNDERPUNCH]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
        next getID(PBAbilities,:MAGNETPULL)  
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:GALVANIZE)       
      end
    },
    "wildHoldItems"=>proc{|pokemon|
      next if pokemon.form==0                 # Normal
      next [0,getID(PBItems,:CELLBATTERY),0]  # Alola
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:GRAVELER,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "They eat rocks and often get into a scrap over them. The shock of Graveler smashing together causes a flash of light and a booming noise."  # Alola
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 1100                    # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:ELECTRIC)# Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[1,:TACKLE],[1,:DEFENSECURL],[1,:CHARGE],[1,:ROCKPOLISH],
          [4,:CHARGE],[6,:ROCKPOLISH],[10,:ROLLOUT],[12,:SPARK],
          [16,:ROCKTHROW],[18,:SMACKDOWN],[22,:THUNDERPUNCH],
          [24,:SELFDESTRUCT],[30,:STEALTHROCK],[34,:ROCKBLAST],
          [40,:DISCHARGE],[44,:EXPLOSION],[50,:DOUBLEEDGE],
          [54,:STONEEDGE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :TOXIC,:HIDDENPOWER,:SUNNYDAY,:PROTECT,:FRUSTRATION,
          :SMACKDOWN,:THUNDERBOLT,:THUNDER,:EARTHQUAKE,:RETURN,
          :BRICKBREAK,:DOUBLETEAM,:FLAMETHROWER,:SANDSTORM,
          :FIREBLAST,:ROCKTOMB,:FACADE,:REST,:ENCHANT,:ROUND,
          :FLING,:CHARGEBEAM,:BRUTALSWING,:EXPLOSION,:ROCKPOLISH,
          :STONEEDGE,:VOLTSWITCH,:GYROBALL,:BULLDOZE,:ROCKSLIDE,
          :SWAGGER,:SLEEPTALK,:SUBSTITUTE,:NATUREPOWER,:CONFIDE,
          # Move Tutors
          :ALLYSWITCH,:BLOCK,:EARTHPOWER,:ELECTROWEB,:FIREPUNCH,
          :FOCUSPUNCH,:IRONDEFENSE,:MAGNETRISE,:SHOCKWAVE,:SNORE,
          :STEALTHROCK,:STOMPINGTANTRUM,:SUPERPOWER,:THUNDERPUNCH]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
        next getID(PBAbilities,:MAGNETPULL)  
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:GALVANIZE)       
      end
    },
    "wildHoldItems"=>proc{|pokemon|
      next if pokemon.form==0                 # Normal
      next [0,getID(PBItems,:CELLBATTERY),0]  # Alola
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[117,121,122]   # Map IDs for second form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    }
  })

MultipleForms.register(:GOLEM,{
    "getMegaForm"=>proc{|pokemon|
      next 2 if isConst?(pokemon.item,PBItems,:DEMONSTONE)
      next
    },
    "getUnmegaForm"=>proc{|pokemon|
      next 0 if pokemon.form==2
      next
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("Rift Golem") if pokemon.form==2
      next
    },
    
    "dexEntry"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Alola
        next "Because it can’t fire boulders at a rapid pace, it’s been known to seize nearby Geodude and fire them from its back."  # Alola
      when 2  # Rift
        next
      end
    },
    "getBaseStats"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Alola
        next
      when 2  # Rift
        next [100,100,150,10,100,150]
      end
    },
    "height"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Alola
        next 17
      when 2  # Rift
        next
      end
    },
    "weight"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Alola
        next 3160
      when 2  # Rift
        next 2560
      end
    },
    "type1"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Alola
        next
      when 2  # Rift
        next getID(PBTypes,:DARK)
      end
    },
    "type2"=>proc{|pokemon|
      case pokemon.form
      when 0  # Normal
        next
      when 1  # Alola
        next getID(PBTypes,:ELECTRIC)
      when 2  # Rift
        next getID(PBTypes,:FIGHTING)
      end
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[1,:HEAVYSLAM],[1,:TACKLE],[1,:DEFENSECURL],[1,:CHARGE],
          [1,:ROCKPOLISH],[4,:CHARGE],[6,:ROCKPOLISH],[10,:STEAMROLLER],
          [12,:SPARK],[16,:ROCKTHROW],[18,:SMACKDOWN],[22,:THUNDERPUNCH],
          [24,:SELFDESTRUCT],[30,:STEALTHROCK],[34,:ROCKBLAST],
          [40,:DISCHARGE],[44,:EXPLOSION],[50,:DOUBLEEDGE],
          [54,:STONEEDGE],[60,:HEAVYSLAM]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :ROAR,:TOXIC,:HIDDENPOWER,:SUNNYDAY,:HYPERBEAM,:PROTECT,
          :FRUSTRATION,:SMACKDOWN,:THUNDERBOLT,:THUNDER,:EARTHQUAKE,
          :RETURN,:BRICKBREAK,:DOUBLETEAM,:FLAMETHROWER,:SANDSTORM,
          :FIREBLAST,:ROCKTOMB,:FACADE,:REST,:ENCHANT,:ROUND,
          :ECHOEDVOICE,:FOCUSBLAST,:FLING,:CHARGEBEAM,:BRUTALSWING,
          :EXPLOSION,:GIGAIMPACT,:ROCKPOLISH,:STONEEDGE,:VOLTSWITCH,
          :GYROBALL,:BULLDOZE,:ROCKSLIDE,:SWAGGER,:SLEEPTALK,
          :SUBSTITUTE,:WILDCHARGE,:NATUREPOWER,:CONFIDE,
          # Move Tutors
          :ALLYSWITCH,:BLOCK,:EARTHPOWER,:ELECTROWEB,:FIREPUNCH,
          :FOCUSPUNCH,:IRONDEFENSE,:MAGNETRISE,:SHOCKWAVE,:SNORE,
          :STEALTHROCK,:STOMPINGTANTRUM,:SUPERPOWER,:THUNDERPUNCH]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      case pokemon.form
      when 0 # Normal
        next
      when 1 # Alola
        if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
          next getID(PBAbilities,:MAGNETPULL)  
        elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
          next getID(PBAbilities,:STURDY)
        elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
          next getID(PBAbilities,:GALVANIZE)       
        end
      when 2 # Rift
        next getID(PBAbilities,:CONTRARY)
      end  
    },
    "wildHoldItems"=>proc{|pokemon|
      case pokemon.form
      when 0
        next          # Normal
      when 1
        next [0,0,getID(PBItems,:CELLBATTERY)]  # Alola
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:GRIMER,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "The crystals on Grimer’s body are lumps of toxins. If one falls off, lethal poisons leak out."  # Alola
    },
    "height"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 7                       # Alola
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 420                    # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:DARK)    # Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[1,:POUND],[1,:POISONGAS],[4,:HARDEN],[7,:BITE],
          [12,:DISABLE],[15,:ACIDSPRAY],[18,:POISONFANG],
          [21,:MINIMIZE],[26,:FLING],[29,:KNOCKOFF],[32,:CRUNCH],
          [37,:SCREECH],[40,:GUNKSHOT],[43,:ACIDARMOR],
          [46,:BELCH],[48,:MEMENTO]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Alola
      when 1 ; eggmovelist=[:ASSURANCE,:CLEARSMOG,:CURSE,:IMPRISON,:MEANLOOK,
          :PURSUIT,:SCARYFACE,:SHADOWSNEAK,:SPITE,
          :SPITUP,:STOCKPILE,:SWALLOW,:POWERUPPUNCH]
      end
      for i in eggmovelist
        i=getID(PBMoves,i)
      end
      next eggmovelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :TOXIC,:VENOSHOCK,:HIDDENPOWER,:SUNNYDAY,:TAUNT,:PROTECT,
          :RAINDANCE,:FRUSTRATION,:RETURN,:SHADOWBALL,:DOUBLETEAM,
          :SLUDGEWAVE,:FLAMETHROWER,:SLUDGEBOMB,:FIREBLAST,:ROCKTOMB,
          :TORMENT,:FACADE,:REST,:ENCHANT,:THIEF,:ROUND,:FLING,
          :BRUTALSWING,:QUASH,:EMBARGO,:EXPLOSION,:PAYBACK,
          :ROCKPOLISH,:STONEEDGE,:ROCKSLIDE,:INFESTATION,:POISONJAB,
          :SWAGGER,:SLEEPTALK,:SUBSTITUTE,:SNARL,:CONFIDE,
          # Move Tutors
          :FIREPUNCH,:GASTROACID,:GIGADRAIN,:GUNKSHOT,:ICEPUNCH,
          :KNOCKOFF,:PAINSPLIT,:SHOCKWAVE,:SNORE,:THUNDERPUNCH]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
        next getID(PBAbilities,:POISONPOINT) 
      elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:GLUTTONY)     
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:POWEROFALCHEMY)       
      end
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[64,66,138]   # Map IDs for second form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:MUK,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form!=1      # Normal
      next "While it’s unexpectedly quiet and friendly, if it’s not fed any trash for a while, it will smash its Trainer’s furnishings and eat up the fragments."  # Alola
    },
    "height"=>proc{|pokemon|
      next if pokemon.form!=1      # Normal/PULSE
      next 10                      # Alola
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form!=1      # Normal/PULSE
      next 520                     # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form!=1      # Normal/PULSE
      next getID(PBTypes,:DARK)    # Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form!=1      # Normal/PULSE
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[0,:VENOMDRENCH],[1,:POUND],[1,:POISONGAS],[1,:HARDEN],
          [1,:BITE],[4,:HARDEN],[7,:BITE],[12,:DISABLE],[15,:ACIDSPRAY],
          [18,:POISONFANG],[21,:MINIMIZE],[26,:FLING],[29,:KNOCKOFF],
          [32,:CRUNCH],[37,:SCREECH],[40,:GUNKSHOT],[46,:ACIDARMOR],                        
          [52,:BELCH],[57,:MEMENTO]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :TOXIC,:VENOSHOCK,:HIDDENPOWER,:SUNNYDAY,:TAUNT,:HYPERBEAM,
          :PROTECT,:RAINDANCE,:FRUSTRATION,:RETURN,:SHADOWBALL,
          :BRICKBREAK,:DOUBLETEAM,:SLUDGEWAVE,:FLAMETHROWER,
          :SLUDGEBOMB,:FIREBLAST,:ROCKTOMB,:TORMENT,:FACADE,:REST,
          :ENCHANT,:THIEF,:ROUND,:FOCUSBLAST,:FLING,:BRUTALSWING,
          :QUASH,:EMBARGO,:EXPLOSION,:PAYBACK,:GIGAIMPACT,:ROCKPOLISH,
          :STONEEDGE,:ROCKSLIDE,:INFESTATION,:POISONJAB,:SWAGGER,
          :SLEEPTALK,:SUBSTITUTE,:SNARL,:DARKPULSE,:CONFIDE,
          # Move Tutors
          :BLOCK,:FIREPUNCH,:FOCUSPUNCH,:GASTROACID,:GIGADRAIN,
          :GUNKSHOT,:ICEPUNCH,:KNOCKOFF,:PAINSPLIT,:RECYCLE,
          :SHOCKWAVE,:SNORE,:SPITE,:THUNDERPUNCH]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "getUnmegaForm"=>proc{|pokemon|
      if pokemon.form == 2
        next 0
      else
        next nil
      end   
    },
    "getMegaName"=>proc{|pokemon|
      next _INTL("PULSE Muk") if pokemon.form==2     # PULSE
      next                                           # Normal/Alola
    },
    "getBaseStats"=>proc{|pokemon|
      next [105,105,70,40,97,250] if pokemon.form==2 # PULSE
      next                                           # Normal/Alola 
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      next getID(PBAbilities,:PROTEAN) if pokemon.form==2 # PULSE
      if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
        next getID(PBAbilities,:POISONPOINT) 
      elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:GLUTTONY)     
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:POWEROFALCHEMY)       
      end   
      next
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[64,66,138]   # Map IDs for second form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    }
  })

MultipleForms.register(:EXEGGUTOR,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "As it grew taller and taller, it outgrew its reliance on psychic powers, while within it awakened the power of the sleeping dragon."  # Alola
    },
    "height"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 109                     # Alola
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 4156                    # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:DRAGON)  # Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[0,:DRAGONHAMMER],[1,:SEEDBOMB],[1,:BARRAGE],
          [1,:HYPNOSIS],[1,:CONFUSION],[17,:PSYSHOCK],
          [27,:EGGBOMB],[37,:WOODHAMMER],[47,:LEAFSTORM]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :PSYSHOCK,:TOXIC,:HIDDENPOWER,:SUNNYDAY,:HYPERBEAM,
          :LIGHTSCREEN,:PROTECT,:FRUSTRATION,:SOLARBEAM,
          :EARTHQUAKE,:RETURN,:PSYCHIC,:BRICKBREAK,:DOUBLETEAM,
          :REFLECT,:FLAMETHROWER,:SLUDGEBOMB,:FACADE,:REST,:ENCHANT,
          :THIEF,:ROUND,:ENERGYBALL,:BRUTALSWING,:EXPLOSION,
          :GIGAIMPACT,:SWORDSDANCE,:PSYCHUP,:BULLDOZE,:DRAGONTAIL,
          :INFESTATION,:DREAMEATER,:GRASSKNOT,:SWAGGER,:SLEEPTALK,
          :SUBSTITUTE,:TRICKROOM,:NATUREPOWER,:CONFIDE,
          # Move Tutors
          :BLOCK,:DRACOMETEOR,:DRAGONPULSE,:GIGADRAIN,:GRAVITY,
          :IRONHEAD,:IRONTAIL,:KNOCKOFF,:LOWKICK,:OUTRAGE,:SEEDBOMB,
          :SKILLSWAP,:SNORE,:STOMPINGTANTRUM,:SUPERPOWER,:SYNTHESIS,
          :TELEKINESIS,:WORRYSEED,:ZENHEADBUTT]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next [95,105,85,45,125,75]   # Alola
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
        next getID(PBAbilities,:FRISK)
      elsif pokemon.abilityIndex==2 && !pokemon.abilityflag
        check = (pokemon.personalID)&1
        next getID(PBAbilities,:FRISK) if check==0
        next getID(PBAbilities,:HARVEST) if check==1
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:MAROWAK,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "The bones it possesses were once its mother’s. Its mother’s regrets have become like a vengeful spirit protecting this Pokémon."  # Alola
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 340                     # Alola
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:FIRE)    # Alola
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:GHOST)   # Alola
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Alola
      when 1 ; movelist=[[1,:GROWL],[1,:TAILWHIP],[1,:BONECLUB],[1,:FLAMEWHEEL],
          [3,:TAILWHIP],[7,:BONECLUB],[11,:FLAMEWHEEL],[13,:LEER],
          [17,:HEX],[21,:BONEMERANG],[23,:WILLOWISP],
          [27,:SHADOWBONE],[33,:THRASH],[37,:FLING],
          [43,:STOMPINGTANTRUM],[49,:ENDEAVOR],[53,:FLAREBLITZ],
          [59,:RETALIATE],[65,:BONERUSH]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
          :TOXIC,:HIDDENPOWER,:SUNNYDAY,:ICEBEAM,:BLIZZARD,:HYPERBEAM,
          :PROTECT,:RAINDANCE,:FRUSTRATION,:SMACKDOWN,:THUNDERBOLT,
          :THUNDER,:EARTHQUAKE,:RETURN,:SHADOWBALL,:BRICKBREAK,
          :DOUBLETEAM,:REFLECT,:FLAMETHROWER,:SANDSTORM,:FIREBLAST,
          :ROCKTOMB,:AERIALACE,:FACADE,:FLAMECHARGE,:REST,:ENCHANT,
          :THIEF,:ROUND,:ECHOEDVOICE,:FOCUSBLAST,:FALSESWIPE,
          :FLING,:BRUTALSWING,:WILLOWISP,:GIGAIMPACT,:STONEEDGE,
          :SWORDSDANCE,:BULLDOZE,:ROCKSLIDE,:DREAMEATER,:SWAGGER,
          :SLEEPTALK,:SUBSTITUTE,:DARKPULSE,:CONFIDE,:SLASHANDBURN,
          # Move Tutors
          :ALLYSWITCH,:EARTHPOWER,:ENDEAVOR,:FIREPUNCH,:FOCUSPUNCH,
          :HEATWAVE,:ICYWIND,:IRONDEFENSE,:IRONHEAD,:IRONTAIL,
          :KNOCKOFF,:LASERFOCUS,:OUTRAGE,:PAINSPLIT,:SNORE,:SPITE,
          :STEALTHROCK,:STOMPINGTANTRUM,:THROATCHOP,:THUNDERPUNCH,
          :UPROAR]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0) # Alola
        next getID(PBAbilities,:CURSEDBODY) 
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2) 
        next getID(PBAbilities,:ROCKHEAD)      
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:PONYTA,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "This Pokémon will look into your eyes and read the contents of your heart. If it finds evil there, it promptly hides away."     # Galarian
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[357,358,359,360,368]  
      # Map IDs for Galarian form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    },
    "height"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 0.8                     # Galarian
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 24                     # Galarian
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:PSYCHIC)    # Galarian
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:PSYCHIC)  # Galarian
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Galarian
      when 1 ; movelist=[[1,:TACKLE],[1,:GROWL],[5,:TAILWHIP],
          [10,:CONFUSION],[15,:FAIRYWIND],
          [20,:AGILITY],[25,:PSYBEAM],[30,:STOMP],
          [35,:HEALPULSE],[41,:TAKEDOWN],[45,:DAZZLINGGLEAM],
          [50,:PSYCHIC],[55,:HEALINGWISH]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:PASTELVEIL)
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:ANTICIPATION)  
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:RAPIDASH,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "Brave and prideful, this Pokémon dashes airily through the forest, its steps aided by the psychic power stored in the fur on its fetlocks."     # Galarian
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[]  
      # Map IDs for Galarian form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    },
    "height"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 1.7                     # Galarian
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 80                    # Galarian
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:PSYCHIC)    # Galarian
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:FAIRY)  # Galarian
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Galarian
      when 1 ; movelist=[[0,:PSYCHOCUT],[1,:PSYCHOCUT],[1,:MEGAHORN],
          [1,:TACKLE],[1,:QUICKATTACK],[1,:GROWL],
          [1,:TAILWHIP],[1,:CONFUSION],[15,:FAIRYWIND],
          [20,:AGILITY],[25,:PSYBEAM],[30,:STOMP],
          [35,:HEALPULSE],[43,:TAKEDOWN],[49,:DAZZLINGGLEAM],
          [56,:PSYCHIC],[63,:HEALINGWISH]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:PASTELVEIL)
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:ANTICIPATION)  
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:FARFETCHD,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "The stalks of leeks are thicker and longer in the Galar region. Farfetch'd that adapted to these stalks took on a unique form."     # Galarian
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[245]  
      # Map IDs for Galariann form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    },
    "height"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 0.8                     # Galarian
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 42                    # Galarian
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next [52,95,55,55,58,62]   # Galar
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:FIGHTING)    # Galarian
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:FIGHTING)  # Galarian
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Galarian
      when 1 ; movelist=[[1,:PECK],[1,:SANDATTACK],[5,:LEER],
          [10,:FURYCUTTER],[15,:ROCKSMASH],
          [20,:BRUTALSWING],[25,:DETECT],[30,:KNOCKOFF],
          [35,:DEFOG],[40,:BRICKBREAK],[45,:SWORDSDANCE],
          [50,:SLAM],[55,:LEAFBLADE],[60,:FINALGAMBIT],
          [65,:BRAVEBIRD]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Galar
      when 1 ; eggmovelist=[:QUICKATTACK,:FLAIL,:CURSE,:COVET,:NIGHTSLASH,
          :SIMPLEBEAM,:FEINT,:SKYATTACK,:COUNTER,:QUICKGUARD,
          :DOUBLEEDGE]
      end
      for i in eggmovelist
        i=getID(PBMoves,i)
      end
      next eggmovelist
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==0 || pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==0) || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:STEADFAST)
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:SCRAPPY)  
      end
    },
    "wildHoldItems"=>proc{|pokemon|
      next if pokemon.form==0                 # Normal
      next [getID(PBItems,:LEEK),0,0]   # Galarian
    },
    "getEvo"=>proc{|pokemon|
      next if pokemon.form==0                  # Normal
      next [[31,0,865]]                        # Galarian    [BattleCrits,3,Sirfetch'd]  
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:WEEZING,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "Long ago, during a time when droves of factories fouled the air with pollution, Weezing changed into this form for some reason."     # Galarian
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[257]  
      # Map IDs for Galariann form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    },
    "height"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 3                     # Galarian
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 16                     # Galarian
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:POISON)    # Galarian
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:FAIRY)  # Galarian
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Galarian
      when 1 ; movelist=[[0,:DOUBLEHIT],[1,:DOUBLEHIT],[1,:STRANGESTEAM],
          [1,:DEFOG],[1,:HEATWAVE],[1,:SMOG],[1,:SMOKESCREEN],
          [1,:HAZE],[1,:POISONGAS],[1,:TACKLE],[1,:FAIRYWIND],
          [1,:AROMATICMIST],[12,:CLEARSMOG],[16,:ASSURANCE],
          [20,:SLUDGE],[24,:AROMATHERAPY],[28,:SELFDESTRUCT],
          [32,:SLUDGEBOMB],[38,:TOXIC],[44,:BELCH],[50,:EXPLOSION],
          [56,:MEMENTO],[62,:DESTINYBOND],[68,:MISTYTERRAIN]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:MISTYSURGE)  
      end
    },
    "wildHoldItems"=>proc{|pokemon|
      next if pokemon.form==0                 # Normal
      next [0,0,getID(PBItems,:ELEMENTALSEED)]   # Galar
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:CORSOLA,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "Sudden climate change wiped out this ancient kind of Corsola. This Pokémon absorbs others' life-force through its branches."     # Galarian
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[]  
      # Map IDs for Galariann form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    },
    "height"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 0.6                     # Galarian
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 0.5                    # Galarian
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next [60,55,100,30,65,100]   # Galar
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:GHOST)    # Galarian
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:GHOST)  # Galarian
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Galarian
      when 1 ; movelist=[[1,:TACKLE],[1,:HARDEN],[5,:WATERGUN],[10,:AQUARING],
          [15,:ENDURE],[20,:ANCIENTPOWER],[25,:BUBBLEBEAM],
          [30,:FLAIL],[35,:LIFEDEW],[40,:POWERGEM],
          [45,:EARTHPOWER],[50,:RECOVER],[55,:MIRRORCOAT]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Galar
      when 1 ; eggmovelist=[:CONFUSERAY,:NATUREPOWER,:WATERPULSE,:HEADSMASH,:HAZE,
          :DESTINYBOND]
      end
      for i in eggmovelist
        i=getID(PBMoves,i)
      end
      next eggmovelist
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      if pokemon.abilityIndex==0 || pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==0) || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:WEAKARMOR)
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:CURSEDBODY)  
      end
    },
    "getEvo"=>proc{|pokemon|
      next if pokemon.form==0                  # Normal
      next [[4,38,864]]                        # Galarian    [Level,38,Cursola]  
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:ZIGZAGOON,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "Thought to be the oldest form of Zigzagoon, it moves in zigzags and wreaks havoc upon its surroundings."     # Galarian
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[12,95]  
      # Map IDs for Galariann form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:DARK)    # Galarian
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:NORMAL)  # Galarian
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Galarian
      when 1 ; movelist=[[1,:TACKLE],[1,:LEER],[3,:SANDATTACK],[6,:LICK],
          [9,:SNARL],[12,:HEADBUTT],[15,:BABYDOLLEYES],
          [18,:PINMISSILE],[21,:REST],[24,:TAKEDOWN],
          [27,:SCARYFACE],[30,:COUNTER],[33,:TAUNT],
          [36,:DOUBLEEDGE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Galar
      when 1 ; eggmovelist=[:PARTINGSHOT,:QUICKGUARD,:KNOCKOFF]
      end
      for i in eggmovelist
        i=getID(PBMoves,i)
      end
      next eggmovelist
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:LINOONE,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "This very aggressive Pokémon will recklessly challenge opponents stronger than itself."     # Galarian
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[12,95]  
      # Map IDs for Galarian form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:DARK)    # Galarian
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:NORMAL)  # Galarian
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Galarian
      when 1 ; movelist=[[0,:NIGHTSLASH],[1,:NIGHTSLASH],[1,:SWITCHEROO],
          [1,:PINMISSILE],[1,:BABYDOLLEYES],[1,:TACKLE],
          [1,:LEER],[1,:SANDATTACK],[1,:LICK],
          [9,:SNARL],[12,:HEADBUTT],[15,:HONECLAWS],
          [18,:FURYSWIPES],[23,:REST],[28,:TAKEDOWN],
          [33,:SCARYFACE],[38,:COUNTER],[43,:TAUNT],
          [48,:DOUBLEEDGE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEvo"=>proc{|pokemon|
      next if pokemon.form==0                  # Normal
      next [[30,35,862]]                        # Galarian    [LevelNight,35,Obstagoon]  
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:DARUMAKA,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "The colder they get, the more energetic they are. They freeze their breath to make snowballs, using them as ammo for playful snowball fights."  if pokemon.form==2   # Galarian
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[]  
      # Map IDs for Galariann form
      if $game_map && maps.include?($game_map.map_id)
        next 2
      else
        next 0
      end
    },
    "height"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 0.7 if pokemon.form==2                     # Galarian
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 40  if pokemon.form==2                    # Galarian
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:ICE) if pokemon.form==2    # Galarian
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:ICE) if pokemon.form==2  # Galarian
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Galarian
      when 2 ; movelist=[[1,:POWDERSNOW],[1,:TACKLE],[4,:TAUNT],[8,:BITE],
          [12,:AVALANCHE],[16,:WORKUP],[20,:ICEFANG],[24,:HEADBUTT],
          [28,:ICEPUNCH],[32,:UPROAR],[36,:BELLYDRUM],
          [40,:BLIZZARD],[44,:THRASH],[48,:SUPERPOWER]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Galar
      when 2 ; eggmovelist=[:FOCUSPUNCH,:HAMMERARM,:TAKEDOWN,:FLAMEWHEEL,:YAWN,
          :FREEZEDRY,:INCINERATE,:POWERUPPUNCH]
      end
      for i in eggmovelist
        i=getID(PBMoves,i)
      end
      next eggmovelist
    },
    "getEvo"=>proc{|pokemon|
      next if pokemon.form==0                  # Normal
      next [[7,652,555]] if pokemon.form==2    # Galarian    [Item,Ice Stone,Darmanitan]  
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:YAMASK,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "It's said that this Pokémon was formed when an ancient clay tablet was drawn to a vengeful spirit."     # Galarian
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[117,121]  
      # Map IDs for Galarian form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next [38,55,85,30,30,65]   # Galar
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:GROUND)    # Galarian
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:GHOST)  # Galarian
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Galarian
      when 1 ; movelist=[[1,:ASTONISH],[1,:PROTECT],[4,:HAZE],[8,:NIGHTSHADE],
          [10,:DISABLE],[14,:BRUTALSWING],[16,:CRAFTYSHIELD],
          [20,:HEX],[24,:MEANLOOK],[28,:SLAM],[32,:CURSE],
          [36,:SHADOWBALL],[40,:EARTHQUAKE],[44,:POWERSPLIT],
          [48,:GUARDSPLIT],[52,:DESTINYBOND]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Galar
      when 1 ; eggmovelist=[:MEMENTO]
      end
      for i in eggmovelist
        i=getID(PBMoves,i)
      end
      next eggmovelist
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      next getID(PBAbilities,:WANDERINGSPIRIT) # Galar
    },
    "getEvo"=>proc{|pokemon|
      next if pokemon.form==0                  # Normal
      next [[32,0,867]]                       # Galarian    [TakeDamage,49,Runerigas]  
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:STUNFISK,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "Its conspicuous lips lure prey in as it lies in wait in the mud. When prey gets close, Stunfisk clamps its jagged steel fins down on them."     # Galarian
    },
    "weight"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next 20.5                    # Galarian
    },
    "getBaseStats"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next [109,81,99,32,66,84]   # Galar
    },
    "type1"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:GROUND)    # Galarian
    },
    "type2"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next getID(PBTypes,:STEEL)  # Galarian
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Galarian
      when 1 ; movelist=[[1,:MUDSLAP],[1,:TACKLE],[1,:WATERGUN],[1,:METALCLAW],
          [5,:ENDURE],[10,:MUDSHOT],[15,:REVENGE],[20,:METALSOUND],
          [25,:SUCKERPUNCH],[30,:IRONDEFENSE],[35,:BOUNCE],
          [40,:MUDDYWATER],[45,:SNAPTRAP],[50,:FLAIL],[55,:FISSURE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Galar
      when 1 ; eggmovelist=[:YAWN,:ASTONISH,:CURSE,:SPITE,:PAINSPLIT,:REFLECTTYPE,:BIND,:COUNTER]
      end
      for i in eggmovelist
        i=getID(PBMoves,i)
      end
      next eggmovelist
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      next getID(PBAbilities,:MIMICRY)
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[221]   # Map IDs for second form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

MultipleForms.register(:MRMIME,{
    "dexEntry"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next "It can radiate chilliness from the bottoms of its feet. It'll spend the whole day tap-dancing on a frozen floor."     # Galarian
    },
    "getFormOnCreation"=>proc{|pokemon|
      maps=[]  
      # Map IDs for Galarian form
      if $game_map && maps.include?($game_map.map_id)
        next 1
      else
        next 0
      end
    },
    "height"=>proc{|pokemon|
      next 1.4 if pokemon.form==1 # Galarian
      next
    },
    "weight"=>proc{|pokemon|
      next 56.8 if pokemon.form==1 # Galarian
      next
    },
    "evYield"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      next [0,0,0,2,0,0]           # Galarian
    },
    "getBaseStats"=>proc{|pokemon|
      next [50,65,65,100,90,90] if pokemon.form==1 # Galarian
      next
    },
    "type1"=>proc{|pokemon|
      next getID(PBTypes,:ICE) if pokemon.form==1 # Galar
      next
    },
    "type2"=>proc{|pokemon|
      next getID(PBTypes,:PSYCHIC) if pokemon.form==1 # Galar
      next
    },
    "getMoveList"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      movelist=[]
      case pokemon.form            # Galarian
      when 1 ; movelist=[[1,:COPYCAT],[1,:ENCORE],[1,:ROLEPLAY],[1,:PROTECT],
          [1,:RECYCLE],[1,:MIMIC],[1,:LIGHTSCREEN],[1,:REFLECT],
          [1,:SAFEGUAR],[1,:DAZZLINGGLEAM],[1,:MISTYTERRAIN],
          [1,:POUND],[1,:RAPIDSPIN],[1,:BATONPASS],[1,:ICESHARD],
          [12,:CONFUSION],[16,:ALLYSWITCH],[20,:ICYWIND],
          [24,:DOUBLEKICK],[28,:PSYBEAM],[32,:HYPNOSIS],
          [36,:MIRRORCOAT],[40,:SUCKERPUNCH],[44,:FREEZEDRY],
          [48,:PSYCHIC],[52,:TEETERDANCE]]
      end
      for i in movelist
        i[1]=getConst(PBMoves,i[1])
      end
      next movelist
    },
    "getEggMoves"=>proc{|pokemon|
      next if pokemon.form==0      # Normal
      eggmovelist=[]
      case pokemon.form            # Galar
      when 1 ; eggmovelist=[:FAKEOUT,:CONFUSERAY,:POWERSPLIT,:TICKLE]
      end
      for i in eggmovelist
        i=getID(PBMoves,i)
      end
      next eggmovelist
    },
    "ability"=>proc{|pokemon|
      next if pokemon.form==0
      if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
        next getID(PBAbilities,:VITALSPIRIT)
      elsif pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
        next getID(PBAbilities,:SCREENCLEANER)
      elsif pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
        next getID(PBAbilities,:ICEBODY)  
      end
    },
    "getEvo"=>proc{|pokemon|
      next if pokemon.form==0                  # Normal
      next [[4,42,866]]                        # Galarian    [Level,42,Mr. Rime]  
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
  })

# Hisuian Forms

MultipleForms.register(:ZORUA,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next getID(PBTypes,:NORMAL)    # Hisuian
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next getID(PBTypes,:GHOST)    # Hisuian
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next [40,65,40,65,80,40]   # Hisuian
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Hisuian
     when 1 ; movelist=[[1,:SCRATCH],[1,:LEER],[4,:TORMENT],[8,:HONECLAWS],
                        [12,:SHADOWSNEAK],[16,:CURSE],[20,:TAUNT],
                        [24,:KNOCKOFF],[28,:SPITE],[32,:AGILITY],[36,:SHADOWBALL],
                        [40,:HEX],[44,:NASTYPLOT],[48,:FOULPLAY]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[]   # Map IDs for second form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:ZOROARK,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next getID(PBTypes,:NORMAL)    # Hisuian
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next getID(PBTypes,:GHOST)    # Hisuian
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   next [60,105,60,105,120,60]   # Hisuian
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0      # Normal
   movelist=[]
   case pokemon.form            # Hisuian
     when 1 ; movelist=[[0,:SHADOWCLAW],[1,:SCRATCH],[1,:LEER],[4,:TORMENT],[8,:HONECLAWS],
                        [12,:SHADOWSNEAK],[16,:CURSE],[20,:TAUNT],
                        [24,:KNOCKOFF],[28,:SPITE],[34,:AGILITY],[40,:SHADOWBALL],
                        [46,:HEX],[52,:NASTYPLOT],[58,:FOULPLAY]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"getFormOnCreation"=>proc{|pokemon|
   maps=[]   # Map IDs for second form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

# Mystic Forms (fully regenerated from Mystic Forms + Mystic Learnsets_TMs)

MultipleForms.register(:TORCHIC,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ROCK)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ROCK)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [50, 60, 70, 45, 40, 45]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:STURDY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:MERCILESS)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[1,:SCRATCH],[1,:GROWL],[5,:ROCKTHROW],[9,:PECK],
                      [10,:POISONGAS],[14,:METALCLAW],[18,:FURYATTACK],[19,:ROCKTOMB],
                      [23,:QUICKATTACK],[24,:SPIKECANNON],[28,:POWERGEM],[30,:BULKUP],
                      [32,:FOCUSENERGY],[33,:IRONDEFENSE],[37,:SMARTSTRIKE],[39,:LITHOFORM],
                      [41,:STEALTHROCK],[46,:STONEEDGE]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs 
	  :AGILITY,:ARENITEWALL,:BATONPASS,:CROSSPOISON,:CUT,:DISFIGURE,:EVISCERATE,:FALSESWIPE,:GUNKSHOT,:IRONDEFENSE,:KNOCKOFF,:LASERFOCUS,:LITHOFORM,:MEGAKICK,:MEGAPUNCH,:METEORBEAM,:PINMISSILE,:POISONSWEEP,:ROCKBLAST,:ROCKPOLISH,:SLASHANDBURN,:SLUDGEBOMB,:SLUDGEWAVE,:SMARTSTRIKE,:SPIKES,:STEALTHROCK,:STEELWING,:STONEEDGE,:SWIFT,:TOXIC,:TOXICSPIKES,:VENOMDRENCH,:VENOSHOCK,:VILEMERCY,:AERIALACE,:ATTRACT,:BRICKBREAK,:BULKUP,:BULLDOZE,:CONFIDE,:ENDURE,:FACADE,:FOCUSENERGY,:FRUSTRATION,:HIDDENPOWER,:POISONJAB,:PROTECT,:REST,:RETURN,:ROCKSLIDE,:ROCKSMASH,:ROCKTOMB,:ROCKYVERDICT,:ROUND,:SCARYFACE,:SECRETPOWER,:SLEEPTALK,:SMACKDOWN,:SNORE,:STRENGTH,:SUBSTITUTE,:SWORDSDANCE,:THUNDERPUNCH,:WORKUP]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
    "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
    }
})

MultipleForms.register(:COMBUSKEN,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ROCK)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [60, 85, 85, 60, 55, 60]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:STURDY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:MERCILESS)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[0,:POISONSWEEP],[1,:SCRATCH],[1,:GROWL],[1,:LITHOFORM],
                      [1,:IRONDEFENSE],[1,:ROCKTHROW],[1,:POISONGAS],[5,:ROCKTHROW],
                      [10,:PECK],[12,:POISONGAS],[14,:METALCLAW],[20,:FURYATTACK],
                      [25,:ROCKTOMB],[30,:BANEFULBUNKER],[31,:BULKUP],[36,:FOCUSENERGY],
                      [42,:ROCKSLIDE],[47,:SMARTSTRIKE],[50,:STEALTHROCK],[53,:POISONJAB],
                      [58,:STONEEDGE]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs 
	  :AGILITY,:ARENITEWALL,:BATONPASS,:CROSSPOISON,:CUT,:DISFIGURE,:EVISCERATE,:FALSESWIPE,:GUNKSHOT,:IRONDEFENSE,:KNOCKOFF,:LASERFOCUS,:LITHOFORM,:MEGAKICK,:MEGAPUNCH,:METEORBEAM,:PINMISSILE,:POISONSWEEP,:ROCKBLAST,:ROCKPOLISH,:SLASHANDBURN,:SLUDGEBOMB,:SLUDGEWAVE,:SMARTSTRIKE,:SPIKES,:STEALTHROCK,:STEELWING,:STONEEDGE,:SWIFT,:TOXIC,:TOXICSPIKES,:VENOMDRENCH,:VENOSHOCK,:VILEMERCY,:AERIALACE,:ATTRACT,:BRICKBREAK,:BULKUP,:BULLDOZE,:CONFIDE,:ENDURE,:FACADE,:FOCUSENERGY,:FRUSTRATION,:HIDDENPOWER,:POISONJAB,:PROTECT,:REST,:RETURN,:ROCKSLIDE,:ROCKSMASH,:ROCKTOMB,:ROCKYVERDICT,:ROUND,:SCARYFACE,:SECRETPOWER,:SLEEPTALK,:SMACKDOWN,:SNORE,:STRENGTH,:SUBSTITUTE,:SWORDSDANCE,:THUNDERPUNCH,:WORKUP]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:BLAZIKEN,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ROCK)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [80, 110, 120, 80, 70, 70]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:STURDY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:MERCILESS)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[0,:VILETOUCH],[1,:POISONSWEEP],[1,:PINMISSILE],[1,:SPIKECANNON],
                      [1,:DISFIGURE],[1,:LITHOFORM],[1,:IRONDEFENSE],[1,:ACCELEROCK],
                      [1,:SCRATCH],[1,:GROWL],[1,:ROCKTHROW],[1,:SANDATTACK],
                      [5,:ROCKTHROW],[10,:SANDATTACK],[14,:METALCLAW],[20,:FURYATTACK],
                      [25,:ROCKTOMB],[30,:BANEFULBUNKER],[31,:BULKUP],[37,:FOCUSENERGY],
                      [44,:ROCKSLIDE],[50,:SMARTSTRIKE],[56,:STEALTHROCK],[57,:POISONJAB],
                      [63,:STONEEDGE]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs 
	  :AGILITY,:ARENITEWALL,:BATONPASS,:CROSSPOISON,:CUT,:DISFIGURE,:EVISCERATE,:FALSESWIPE,:GUNKSHOT,:IRONDEFENSE,:KNOCKOFF,:LASERFOCUS,:LITHOFORM,:MEGAKICK,:MEGAPUNCH,:METEORBEAM,:PINMISSILE,:POISONSWEEP,:ROCKBLAST,:ROCKPOLISH,:SLASHANDBURN,:SLUDGEBOMB,:SLUDGEWAVE,:SMARTSTRIKE,:SPIKES,:STEALTHROCK,:STEELWING,:STONEEDGE,:SWIFT,:TOXIC,:TOXICSPIKES,:VENOMDRENCH,:VENOSHOCK,:VILEMERCY,:AERIALACE,:ATTRACT,:BRICKBREAK,:BULKUP,:BULLDOZE,:CONFIDE,:ENDURE,:FACADE,:FOCUSENERGY,:FRUSTRATION,:HIDDENPOWER,:POISONJAB,:PROTECT,:REST,:RETURN,:ROCKSLIDE,:ROCKSMASH,:ROCKTOMB,:ROCKYVERDICT,:ROUND,:SCARYFACE,:SECRETPOWER,:SLEEPTALK,:SMACKDOWN,:SNORE,:STRENGTH,:SUBSTITUTE,:SWORDSDANCE,:THUNDERPUNCH,:WORKUP]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:MUDKIP,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIGHTING)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIGHTING)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [50, 70, 50, 50, 50, 40]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SCRAPPY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:THICKFAT)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[1,:TACKLE],[1,:GROWL],[4,:KARATECHOP],[6,:FORESIGHT],
                      [9,:MUDSLAP],[9,:ROCKTHROW],[12,:FOCUSENERGY],[15,:ENDURE],
                      [17,:BITE],[18,:VACUUMWAVE],[20,:BIDE],[21,:ROCKSLIDE],
                      [27,:BULKUP],[28,:PROTECT],[30,:BRICKBREAK],[33,:CRUNCH],
                      [33,:SCREECH],[36,:SLAM],[41,:HAMMERARM],[44,:DRAGONDANCE]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "getMoveCompatibility"=>proc{|pokemon|
    next if pokemon.form==0
    movelist=[]
    case pokemon.form
    when 1; movelist=[# TMs 
		:AERIALACE,:AQUATAIL,:ATTRACT,:AURASPHERE,:BATTLECRY,:BODYPRESS,:BODYSLAM,
		:BREAKINGSWIPE,:BRICKBREAK,:BULKUP,:BULLDOZE,:COACHING,:CONFIDE,:DRAGONCHEER,
		:DRAGONCLAW,:DRAGONPULSE,:DRAGONTAIL,:DRAINPUNCH,:DUALCHOP,:EARTHQUAKE,
		:ENDEAVOR,:ENDURE,:FACADE,:FALSESWIPE,:FIREFANG,:FIREPUNCH,:FLING,:FOCUSBLAST,
		:FOCUSENERGY,:FOCUSPUNCH,:FRUSTRATION,:GILDEDBARGAIN,:GYROBALL,:HAIL,:HEATCRASH,
		:HEAVYSLAM,	:HELPINGHAND,:HIDDENPOWER,:HYPERVOICE,:ICEFANG,:ICEPUNCH,:IRONTAIL,
		:LOWKICK,:OUTRAGE,:POISONJAB,:PROTECT,:REST,:RETURN,:REVERSAL,:ROAR,:ROCKSLIDE,
		:ROCKSMASH,:ROCKTOMB,:ROCKYVERDICT,:ROUND,:SANDSTORM,:SCALESHOT,:SCARYFACE,
		:SCREECH,:SECRETPOWER,:SHADOWCLAW,:SHOWSTOPPER,:SLEEPTALK,:SMACKDOWN,:SNORE,
		:SOULJAVELIN,:STOMPINGTANTRUM,:STRENGTH,:SUBSTITUTE,:SUNNYDAY,:SWORDSDANCE,
		:TAILSLAP,:TAUNT,:THUNDERFANG,:THUNDERPUNCH,:VACUUMWAVE,:WORKUP,:XSCISSOR]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:MARSHTOMP,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIGHTING)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DRAGON)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [70, 85, 70, 60, 70, 50]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SCRAPPY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:THICKFAT)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[0,:BELLOW],[1,:DUALCHOP],[1,:SURF],[1,:TACKLE],
                      [1,:GROWL],[1,:KARATECHOP],[1,:MUDSLAP],[1,:FORESIGHT],
                      [4,:KARATECHOP],[9,:MUDSLAP],[12,:FOCUSENERGY],[18,:BITE],
                      [22,:RANCOR],[28,:ROCKSLIDE],[32,:PROTECT],[35,:BULKUP],
                      [38,:BRICKBREAK],[42,:SLAM],[45,:SCREECH],[48,:DUALCHOP],
                      [52,:DRAGONDANCE]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "getMoveCompatibility"=>proc{|pokemon|
    next if pokemon.form==0
    movelist=[]
    case pokemon.form
    when 1; movelist=[# TMs 
		:AERIALACE,:AQUATAIL,:ATTRACT,:AURASPHERE,:BATTLECRY,:BODYPRESS,:BODYSLAM,
		:BREAKINGSWIPE,:BRICKBREAK,:BULKUP,:BULLDOZE,:COACHING,:CONFIDE,:DRAGONCHEER,
		:DRAGONCLAW,:DRAGONPULSE,:DRAGONTAIL,:DRAINPUNCH,:DUALCHOP,:EARTHQUAKE,
		:ENDEAVOR,:ENDURE,:FACADE,:FALSESWIPE,:FIREFANG,:FIREPUNCH,:FLING,:FOCUSBLAST,
		:FOCUSENERGY,:FOCUSPUNCH,:FRUSTRATION,:GILDEDBARGAIN,:GYROBALL,:HAIL,:HEATCRASH,
		:HEAVYSLAM,	:HELPINGHAND,:HIDDENPOWER,:HYPERVOICE,:ICEFANG,:ICEPUNCH,:IRONTAIL,
		:LOWKICK,:OUTRAGE,:POISONJAB,:PROTECT,:REST,:RETURN,:REVERSAL,:ROAR,:ROCKSLIDE,
		:ROCKSMASH,:ROCKTOMB,:ROCKYVERDICT,:ROUND,:SANDSTORM,:SCALESHOT,:SCARYFACE,
		:SCREECH,:SECRETPOWER,:SHADOWCLAW,:SHOWSTOPPER,:SLEEPTALK,:SMACKDOWN,:SNORE,
		:SOULJAVELIN,:STOMPINGTANTRUM,:STRENGTH,:SUBSTITUTE,:SUNNYDAY,:SWORDSDANCE,
		:TAILSLAP,:TAUNT,:THUNDERFANG,:THUNDERPUNCH,:VACUUMWAVE,:WORKUP,:XSCISSOR]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:SWAMPERT,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIGHTING)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DRAGON)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [90, 110, 80, 90, 100, 60]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SCRAPPY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:THICKFAT)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[0,:DRAGONJAUNT],[1,:BELLOW],[1,:AURASPHERE],[1,:HAMMERARM],
                      [1,:CRUNCH],[1,:DUALCHOP],[1,:FORESIGHT],[1,:ROCKTHROW],
                      [1,:TACKLE],[1,:GROWL],[1,:KARATECHOP],[1,:MUDSLAP],
                      [4,:KARATECHOP],[9,:MUDSLAP],[12,:FOCUSENERGY],[18,:BIDE],
                      [22,:RANCOR],[28,:ROCKSLIDE],[32,:PROTECT],[39,:BRICKBREAK],
                      [44,:SLAM],[49,:SCREECH],[51,:DUALCHOP],[56,:ENDEAVOR],
                      [63,:CLOSECOMBAT]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "getMoveCompatibility"=>proc{|pokemon|
    next if pokemon.form==0
    movelist=[]
    case pokemon.form
    when 1; movelist=[# TMs 
		:AERIALACE,:AQUATAIL,:ATTRACT,:AURASPHERE,:BATTLECRY,:BODYPRESS,:BODYSLAM,
		:BREAKINGSWIPE,:BRICKBREAK,:BULKUP,:BULLDOZE,:COACHING,:CONFIDE,:DRAGONCHEER,
		:DRAGONCLAW,:DRAGONPULSE,:DRAGONTAIL,:DRAINPUNCH,:DUALCHOP,:EARTHQUAKE,
		:ENDEAVOR,:ENDURE,:FACADE,:FALSESWIPE,:FIREFANG,:FIREPUNCH,:FLING,:FOCUSBLAST,
		:FOCUSENERGY,:FOCUSPUNCH,:FRUSTRATION,:GILDEDBARGAIN,:GYROBALL,:HAIL,:HEATCRASH,
		:HEAVYSLAM,	:HELPINGHAND,:HIDDENPOWER,:HYPERBEAM,:HYPERVOICE,:ICEFANG,:ICEPUNCH,:IRONTAIL,
		:LOWKICK,:OUTRAGE,:POISONJAB,:PROTECT,:REST,:RETURN,:REVERSAL,:ROAR,:ROCKSLIDE,
		:ROCKSMASH,:ROCKTOMB,:ROCKYVERDICT,:ROUND,:SANDSTORM,:SCALESHOT,:SCARYFACE,
		:SCREECH,:SECRETPOWER,:SHADOWCLAW,:SHOWSTOPPER,:SLEEPTALK,:SMACKDOWN,:SNORE,
		:SOULJAVELIN,:STOMPINGTANTRUM,:STRENGTH,:SUBSTITUTE,:SUNNYDAY,:SWORDSDANCE,
		:TAILSLAP,:TAUNT,:THUNDERFANG,:THUNDERPUNCH,:VACUUMWAVE,:WORKUP,:XSCISSOR]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:TREECKO,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FLYING)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FLYING)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [40, 55, 45, 65, 70, 35]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:CLOUDNINE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:REGENERATOR)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[1,:POUND],[1,:LEER],[3,:GUST],[6,:MIST],
                      [9,:QUICKATTACK],[13,:FAIRYWIND],[17,:CONFUSION],[21,:AIRCUTTER],
                      [25,:AGILITY],[27,:COTTONGUARD],[29,:HALLUCINATE],[33,:MIRRORMOVE],
                      [37,:AIRSLASH],[41,:QUICKGUARD],[45,:EXTRASENSORY],[49,:CALMMIND]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
			:ACROBATICS,:AERIALACE,:AFTERYOU,:AGILITY,:AIRSLASH,:ALLURINGVOICE,:ALLYSWITCH,:ATTRACT,:AURASPHERE,:BATONPASS,:BOUNCE,:BREAKINGSWIPE,:BUGBUZZ,:CALMMIND,:CONDESCEND,:CONFIDE,:COVET,:CUT,:DAZZLINGGLEAM,:DEFOG,:DRAININGKISS,:DUALWINGBEAT,:FACADE,:FAERIEFIB,:FALSESWIPE,:FLING,:FLY,:FRUSTRATION,:HALLUCINATE,:HELPINGHAND,:HIDDENPOWER,:HONECLAWS,:HURRICANE,:HYPERVOICE,:ICYWIND,:INFESTATION,:IRONTAIL,:JETSTREAM,:MISTYEXPLOSION,:MISTYTERRAIN,:PROTECT,:PSYCHICNOISE,:PSYCHOCUT,:QUASH,:REST,:RETURN,:ROLEPLAY,:ROOST,:ROUND,:SCALESHOT,:SECRETPOWER,:SERAPHSEMBRACE,:SHADOWCLAW,:SIGNALBEAM,:SKITTERSMACK,:SKYDROP,:SLASHANDBURN,:SLEEPTALK,:SNORE,:SONICSCREAM,:STEELWING,:SUBSTITUTE,:TAILWIND,:TAUNT,:THIEF,:TRINITYFORCE,:UTURN,:WORKUP]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:GROVYLE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FLYING)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [50, 65, 65, 85, 95, 45]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:CLOUDNINE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:REGENERATOR)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[0,:MIMIC],[1,:POUND],[1,:LEER],[1,:MIST],
                      [1,:EXTRASENSORY],[1,:GUST],[1,:AIRSLASH],[1,:QUICKATTACK],
                      [6,:MIST],[9,:QUICKATTACK],[13,:FAIRYWIND],[18,:CONFUSION],
                      [20,:DRAININGKISS],[23,:WINDVORTEX],[25,:AIRCUTTER],[28,:AGILITY],
                      [33,:HALLUCINATE],[38,:MIRRORMOVE],[43,:EXTRASENSORY],[48,:AIRSLASH],
                      [53,:QUICKGUARD],[58,:MOONBLAST],[63,:CALMMIND]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
			:ACROBATICS,:AERIALACE,:AFTERYOU,:AGILITY,:AIRSLASH,:ALLURINGVOICE,:ALLYSWITCH,:ATTRACT,:AURASPHERE,:BATONPASS,:BOUNCE,:BREAKINGSWIPE,:BUGBUZZ,:CALMMIND,:CONDESCEND,:CONFIDE,:COVET,:CUT,:DAZZLINGGLEAM,:DEFOG,:DRAININGKISS,:DUALWINGBEAT,:FACADE,:FAERIEFIB,:FALSESWIPE,:FLING,:FLY,:FRUSTRATION,:HALLUCINATE,:HELPINGHAND,:HIDDENPOWER,:HONECLAWS,:HURRICANE,:HYPERVOICE,:ICYWIND,:INFESTATION,:IRONTAIL,:JETSTREAM,:MISTYEXPLOSION,:MISTYTERRAIN,:PROTECT,:PSYCHICNOISE,:PSYCHOCUT,:QUASH,:REST,:RETURN,:ROLEPLAY,:ROOST,:ROUND,:SCALESHOT,:SECRETPOWER,:SERAPHSEMBRACE,:SHADOWCLAW,:SIGNALBEAM,:SKITTERSMACK,:SKYDROP,:SLASHANDBURN,:SLEEPTALK,:SNORE,:SONICSCREAM,:STEELWING,:SUBSTITUTE,:TAILWIND,:TAUNT,:THIEF,:TRINITYFORCE,:UTURN,:WORKUP]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:SCEPTILE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FLYING)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [70, 85, 85, 105, 120, 65]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:CLOUDNINE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:REGENERATOR)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[0,:MISTYSTEP],[1,:MIMIC],[1,:TAILWIND],[1,:AURASPHERE],
                      [1,:POUND],[1,:GUST],[1,:EXTRASENSORY],[1,:LEER],
                      [1,:MIST],[1,:QUICKATTACK],[6,:MIST],[9,:QUICKATTACK],
                      [13,:FAIRYWIND],[18,:CONFUSION],[20,:DRAININGKISS],[23,:WINDVORTEX],
                      [25,:AIRCUTTER],[28,:AGILITY],[33,:HALLUCINATE],[39,:MIRRORMOVE],
                      [45,:EXTRASENSORY],[51,:AIRSLASH],[57,:QUICKGUARD],[63,:MOONBLAST],
                      [69,:CALMMIND]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
			:ACROBATICS,:AERIALACE,:AFTERYOU,:AGILITY,:AIRSLASH,:ALLURINGVOICE,:ALLYSWITCH,:ATTRACT,:AURASPHERE,:BATONPASS,:BOUNCE,:BREAKINGSWIPE,:BUGBUZZ,:CALMMIND,:CONDESCEND,:CONFIDE,:COVET,:CUT,:DAZZLINGGLEAM,:DEFOG,:DRAININGKISS,:DUALWINGBEAT,:FACADE,:FAERIEFIB,:FALSESWIPE,:FLING,:FLY,:FRUSTRATION,:HALLUCINATE,:HELPINGHAND,:HIDDENPOWER,:HONECLAWS,:HURRICANE,:HYPERVOICE,:ICYWIND,:INFESTATION,:IRONTAIL,:JETSTREAM,:MISTYEXPLOSION,:MISTYTERRAIN,:PROTECT,:PSYCHICNOISE,:PSYCHOCUT,:QUASH,:REST,:RETURN,:ROLEPLAY,:ROOST,:ROUND,:SCALESHOT,:SECRETPOWER,:SERAPHSEMBRACE,:SHADOWCLAW,:SIGNALBEAM,:SKITTERSMACK,:SKYDROP,:SLASHANDBURN,:SLEEPTALK,:SNORE,:SONICSCREAM,:STEELWING,:SUBSTITUTE,:TAILWIND,:TAUNT,:THIEF,:TRINITYFORCE,:UTURN,:WORKUP]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:FENNEKIN,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:WATER)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:WATER)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [62, 40, 45, 40, 60, 60]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:POWEROFALCHEMY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:HEALER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[1,:SCRATCH],[1,:TAILWHIP],[5,:BUBBLE],[11,:PLAYNICE],
                      [14,:ESSENCEFEED],[17,:LIFEDEW],[20,:BUBBLEBEAM],[25,:HELPINGHAND],
                      [27,:HEX],[31,:HEALPULSE],[35,:SCALD],[38,:HEALINGWISH],
                      [41,:SHADOWBALL],[43,:FOLLOWME],[46,:WISH],[48,:WATERSPOUT]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :ALLURINGVOICE,:ATTRACT,:AURASPHERE,:BRINE,:BURNINGJEALOUSY,:CALMMIND,:CONFIDE,:COSMICPOWER,:COVET,:DARKPULSE,:DAZZLINGGLEAM,:DELUGE,:DIVE,:DRAININGKISS,:DREAMEATER,:ECHOEDVOICE,:ENERGYBALL,:FACADE,:FAERIEFIB,:FAKETEARS,:FALSESWIPE,:FIREBLAST,:FIREFANG,:FIRESPIN,:FLAMECHARGE,:FLAMETHROWER,:FLASH,:FRUSTRATION,:GRASSKNOT,:HALLUCINATE,:HEALBELL,:HEATCRASH,:HEX,:HIDDENPOWER,:HYPERVOICE,:IRRITATION,:LIGHTSCREEN,:LIQUIDATION,:MAGICCOAT,:MAGICROOM,:MAGMADRIFT,:METRONOME,:NATUREPOWER,:OVERHEAT,:PERFORATE,:POWERGEM,:PROTECT,:PSYCHUP,:PSYCHICNOISE,:RAINDANCE,:REFLECT,:REST,:RETALIATE,:RETURN,:ROUND,:SAFEGUARD,:SCALD,:SCORCHINGSANDS,:SECRETPOWER,:SHADOWBALL,:SIGNALBEAM,:SKILLSWAP,:SLEEPTALK,:SNARL,:SNORE,:SUBSTITUTE,:SUNFURY,:SUNNYDAY,:SURF,:SWELTERINGSTRIKE,:SWIFT,:TEMPERFLARE,:TORMENT,:TRICK,:TRICKROOM,:TRINITYFORCE,:UNSTABLEMATTER,:WATERPULSE,:WHIRLPOOL,:WILLOWISP,:WONDERROOM,:WORKUP]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:BRAIXEN,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:WATER)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [90, 58, 59, 59, 73, 70]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:POWEROFALCHEMY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:HEALER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[0,:INCINERATE],[1,:SCRATCH],[1,:TAILWHIP],[1,:BUBBLE],
                      [5,:BUBBLE],[11,:PLAYNICE],[14,:ESSENCEFEED],[18,:LIFEDEW],
                      [22,:BUBBLEBEAM],[28,:BONFIRE],[31,:HEX],[36,:HEALPULSE],
                      [41,:SCALD],[45,:HEALINGWISH],[49,:SHADOWBALL],[52,:HEATWAVE],
                      [56,:WISH],[59,:WATERSPOUT]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :ALLURINGVOICE,:ATTRACT,:AURASPHERE,:BRINE,:BURNINGJEALOUSY,:CALMMIND,:CONFIDE,:COSMICPOWER,:COVET,:DARKPULSE,:DAZZLINGGLEAM,:DELUGE,:DIVE,:DRAININGKISS,:DREAMEATER,:ECHOEDVOICE,:ENERGYBALL,:FACADE,:FAERIEFIB,:FAKETEARS,:FALSESWIPE,:FIREBLAST,:FIREFANG,:FIRESPIN,:FLAMECHARGE,:FLAMETHROWER,:FLASH,:FRUSTRATION,:GRASSKNOT,:HALLUCINATE,:HEALBELL,:HEATCRASH,:HEX,:HIDDENPOWER,:HYPERVOICE,:IRRITATION,:LIGHTSCREEN,:LIQUIDATION,:MAGICCOAT,:MAGICROOM,:MAGMADRIFT,:METRONOME,:NATUREPOWER,:OVERHEAT,:PERFORATE,:POWERGEM,:PROTECT,:PSYCHUP,:PSYCHICNOISE,:RAINDANCE,:REFLECT,:REST,:RETALIATE,:RETURN,:ROUND,:SAFEGUARD,:SCALD,:SCORCHINGSANDS,:SECRETPOWER,:SHADOWBALL,:SIGNALBEAM,:SKILLSWAP,:SLEEPTALK,:SNARL,:SNORE,:SUBSTITUTE,:SUNFURY,:SUNNYDAY,:SURF,:SWELTERINGSTRIKE,:SWIFT,:TEMPERFLARE,:TORMENT,:TRICK,:TRICKROOM,:TRINITYFORCE,:UNSTABLEMATTER,:WATERPULSE,:WHIRLPOOL,:WILLOWISP,:WONDERROOM,:WORKUP]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:DELPHOX,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:WATER)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [114, 69, 75, 72, 104, 100]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:POWEROFALCHEMY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:HEALER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[0,:PYROCLASM],[1,:INCINERATE],[1,:RECOVER],[1,:FOLLOWME],
                      [1,:HELPINGHAND],[1,:MYSTICALFIRE],[1,:SCRATCH],[1,:TAILWHIP],
                      [1,:BUBBLE],[1,:PLAYNICE],[5,:BUBBLE],[11,:PLAYNICE],
                      [14,:ESSENCEFEED],[18,:LIFEDEW],[22,:BUBBLEBEAM],[28,:BONFIRE],
                      [31,:HEX],[38,:HEALPULSE],[45,:SCALD],[51,:HEALINGWISH],
                      [57,:SHADOWBALL],[62,:HEATWAVE],[68,:WISH],[74,:WATERSPOUT],
                      [80,:INFERNO]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :ALLURINGVOICE,:ATTRACT,:AURASPHERE,:BRINE,:BURNINGJEALOUSY,:CALMMIND,:CONFIDE,:COSMICPOWER,:COVET,:DARKPULSE,:DAZZLINGGLEAM,:DELUGE,:DIVE,:DRAININGKISS,:DREAMEATER,:ECHOEDVOICE,:ENERGYBALL,:FACADE,:FAERIEFIB,:FAKETEARS,:FALSESWIPE,:FIREBLAST,:FIREFANG,:FIRESPIN,:FLAMECHARGE,:FLAMETHROWER,:FLASH,:FRUSTRATION,:GRASSKNOT,:HALLUCINATE,:HEALBELL,:HEATCRASH,:HEX,:HIDDENPOWER,:HYPERVOICE,:IRRITATION,:LIGHTSCREEN,:LIQUIDATION,:MAGICCOAT,:MAGICROOM,:MAGMADRIFT,:METRONOME,:NATUREPOWER,:OVERHEAT,:PERFORATE,:POWERGEM,:PROTECT,:PSYCHUP,:PSYCHICNOISE,:RAINDANCE,:REFLECT,:REST,:RETALIATE,:RETURN,:ROUND,:SAFEGUARD,:SCALD,:SCORCHINGSANDS,:SECRETPOWER,:SHADOWBALL,:SIGNALBEAM,:SKILLSWAP,:SLEEPTALK,:SNARL,:SNORE,:SUBSTITUTE,:SUNFURY,:SUNNYDAY,:SURF,:SWELTERINGSTRIKE,:SWIFT,:TEMPERFLARE,:TORMENT,:TRICK,:TRICKROOM,:TRINITYFORCE,:UNSTABLEMATTER,:WATERPULSE,:WHIRLPOOL,:WILLOWISP,:WONDERROOM,:WORKUP]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:FROAKIE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:NORMAL)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:NORMAL)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [40, 44, 41, 71, 62, 56]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:AMPLIFY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:OBLIVIOUS)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[1,:POUND],[1,:GROWL],[5,:HELPINGHAND],[8,:DISARMINGVOICE],
                      [10,:COTTONSPORE],[14,:SWIFT],[18,:ROUND],[21,:BATTLECRY],
                      [25,:SING],[29,:FRACTURE],[35,:UPROAR],[39,:SONICSCREAM],
                      [43,:COTTONGUARD],[48,:HYPERVOICE]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :ALLURINGVOICE,:ATTRACT,:AURASPHERE,:BATTLECRY,:BRICKBREAK,:BULLETSEED,:CALMMIND,:CONFIDE,:DOUBLETEAM,:ECHOEDVOICE,:EMBARGO,:ENERGYBALL,:FACADE,:FAKETEARS,:FALSESWIPE,:FRUSTRATION,:GIGADRAIN,:GRASSKNOT,:GRASSYTERRAIN,:HEALBELL,:HELPINGHAND,:HIDDENPOWER,:HYPERVOICE,:LEAFBLADE,:LIGHTSCREEN,:LOTUSBLOOM,:MAGICALLEAF,:METRONOME,:NATUREPOWER,:PROTECT,:PSYCHUP,:PSYCHICNOISE,:RAINDANCE,:RECYCLE,:REFLECT,:REST,:RETALIATE,:RETURN,:ROLEPLAY,:ROUND,:SCREECH,:SECRETPOWER,:SEEDBOMB,:SLASHANDBURN,:SLEEPTALK,:SNARL,:SNORE,:SOLARBEAM,:SOLARBLADE,:SONICSCREAM,:SUBSTITUTE,:SUNNYDAY,:SWIFT,:SYNTHESIS,:TAUNT,:TRICK,:UTURN,:UPROAR,:WEATHERBALL,:WORKUP,:WORRYSEED,:XSCISSOR,:ZENHEADBUTT]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:FROGADIER,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:NORMAL)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GRASS)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [52, 56, 54, 97, 83, 63]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:AMPLIFY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:OBLIVIOUS)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[0,:MEGADRAIN],[1,:POUND],[1,:GROWL],[1,:HELPINGHAND],
                      [5,:HELPINGHAND],[8,:DISARMINGVOICE],[10,:COTTONSPORE],[14,:SWIFT],
                      [19,:ROUND],[23,:BATTLECRY],[28,:GIGADRAIN],[33,:FRACTURE],
                      [40,:UPROAR],[45,:SONICSCREAM],[50,:COTTONGUARD],[56,:HYPERVOICE]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :ALLURINGVOICE,:ATTRACT,:AURASPHERE,:BATTLECRY,:BRICKBREAK,:BULLETSEED,:CALMMIND,:CONFIDE,:DOUBLETEAM,:ECHOEDVOICE,:EMBARGO,:ENERGYBALL,:FACADE,:FAKETEARS,:FALSESWIPE,:FRUSTRATION,:GIGADRAIN,:GRASSKNOT,:GRASSYTERRAIN,:HEALBELL,:HELPINGHAND,:HIDDENPOWER,:HYPERVOICE,:LEAFBLADE,:LIGHTSCREEN,:LOTUSBLOOM,:MAGICALLEAF,:METRONOME,:NATUREPOWER,:PROTECT,:PSYCHUP,:PSYCHICNOISE,:RAINDANCE,:RECYCLE,:REFLECT,:REST,:RETALIATE,:RETURN,:ROLEPLAY,:ROUND,:SCREECH,:SECRETPOWER,:SEEDBOMB,:SLASHANDBURN,:SLEEPTALK,:SNARL,:SNORE,:SOLARBEAM,:SOLARBLADE,:SONICSCREAM,:SUBSTITUTE,:SUNNYDAY,:SWIFT,:SYNTHESIS,:TAUNT,:TRICK,:UTURN,:UPROAR,:WEATHERBALL,:WORKUP,:WORRYSEED,:XSCISSOR,:ZENHEADBUTT]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:GRENINJA,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:NORMAL)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GRASS)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [67, 72, 71, 122, 95, 103]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:AMPLIFY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:OBLIVIOUS)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[0,:NATURALORDER],[1,:MEGADRAIN],[1,:PETALDANCE],[1,:SNARL],
                      [1,:ROLEPLAY],[1,:NOBLEROAR],1,[:SING],[1,:POUND],[1,:GROWL],
                      [1,:HELPINGHAND],[1,:DISARMINGVOICE],[5,:HELPINGHAND],[8,:DISARMINGVOICE],
                      [10,:COTTONSPORE],[14,:SWIFT],[19,:ROUND],[23,:BATTLECRY],
                      [28,:GIGADRAIN],[33,:FRACTURE],[42,:UPROAR],[49,:SONICSCREAM],
                      [56,:COTTONGUARD],[68,:HYPERVOICE],[70,:PETALDANCE],[77,:BOOMBURST]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :ALLURINGVOICE,:ATTRACT,:AURASPHERE,:BATTLECRY,:BRICKBREAK,:BULLETSEED,:CALMMIND,:CONFIDE,:DOUBLETEAM,:ECHOEDVOICE,:EMBARGO,:ENERGYBALL,:FACADE,:FAKETEARS,:FALSESWIPE,:FRUSTRATION,:GIGADRAIN,:GRASSKNOT,:GRASSYTERRAIN,:HEALBELL,:HELPINGHAND,:HIDDENPOWER,:HYPERVOICE,:LEAFBLADE,:LIGHTSCREEN,:LOTUSBLOOM,:MAGICALLEAF,:METRONOME,:NATUREPOWER,:PROTECT,:PSYCHUP,:PSYCHICNOISE,:RAINDANCE,:RECYCLE,:REFLECT,:REST,:RETALIATE,:RETURN,:ROLEPLAY,:ROUND,:SCREECH,:SECRETPOWER,:SEEDBOMB,:SLASHANDBURN,:SLEEPTALK,:SNARL,:SNORE,:SOLARBEAM,:SOLARBLADE,:SONICSCREAM,:SUBSTITUTE,:SUNNYDAY,:SWIFT,:SYNTHESIS,:TAUNT,:TRICK,:UTURN,:UPROAR,:WEATHERBALL,:WORKUP,:WORRYSEED,:XSCISSOR,:ZENHEADBUTT]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:CHESPIN,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:BUG)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:BUG)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [56, 65, 61, 48, 38, 45]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:STATIC)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:ELECTRICSURGE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[1,:GROWL],[1,:TACKLE],[5,:PESTER],[8,:ROLLOUT],
                      [11,:SANDTOMB],[15,:DEFENSECURL],[18,:BUGBITE],[27,:TAKEDOWN],
                      [32,:PINMISSILE],[35,:DIG],[39,:CURSE],[42,:BODYSLAM],
                      [45,:PAINSPLIT],[48,:MEGAHORN]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :AFTERSHOCK,:ATTRACT,:BIND,:BLOCK,:BODYSLAM,:BREAKINGSWIPE,:BRICKBREAK,:BRUTALSWING,:BUGBITE,:BUGBUZZ,:CHARGEBEAM,:CONFIDE,:DATASURF,:DIG,:DRILLRUN,:ELECTRICTERRAIN,:ELECTROBALL,:ELECTROWEB,:ENDURE,:EXPLOSION,:FACADE,:FALSESWIPE,:FLASH,:FRUSTRATION,:GYROBALL,:HIDDENPOWER,:INFESTATION,:IRONDEFENSE,:IRONTAIL,:LEECHLIFE,:MEGAPUNCH,:MEGAHORN,:OVERCHARGE,:PAINSPLIT,:PINMISSILE,:PINCERGRIP,:POWERUPPUNCH,:PROTECT,:REST,:RETURN,:ROCKCLIMB,:ROCKSMASH,:ROUND,:SANDTOMB,:SCARYFACE,:SECRETPOWER,:SELFDESTRUCT,:SHOCKWAVE,:SIGNALBEAM,:SKITTERSMACK,:SLEEPTALK,:SMARTSTRIKE,:SNORE,:SPIKES,:STEELROLLER,:STRENGTH,:STRUGGLEBUG,:SUBSTITUTE,:SUPERCELLSLAM,:THUNDER,:THUNDERPUNCH,:THUNDERBOLT,:UTURN,:VOLTSWITCH,:WILDCHARGE,:WORKUP,:XSCISSOR,:ZAPCANNON]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:QUILLADIN,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:BUG)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ELECTRIC)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [61, 95, 78, 57, 56, 58]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:STATIC)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:ELECTRICSURGE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[0,:SPARK],[1,:GROWL],[1,:TACKLE],[5,:PESTER],
                      [8,:ROLLOUT],[11,:SANDTOMB],[15,:DEFENSECURL],[19,:BUGBITE],
                      [29,:ZINGZAP],[35,:PINMISSILE],[39,:DIG],[44,:CURSE],
                      [48,:WILDCHARGE],[52,:PAINSPLIT],[56,:MEGAHORN]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :AFTERSHOCK,:ATTRACT,:BIND,:BLOCK,:BODYSLAM,:BREAKINGSWIPE,:BRICKBREAK,:BRUTALSWING,:BUGBITE,:BUGBUZZ,:CHARGEBEAM,:CONFIDE,:DATASURF,:DIG,:DRILLRUN,:ELECTRICTERRAIN,:ELECTROBALL,:ELECTROWEB,:ENDURE,:EXPLOSION,:FACADE,:FALSESWIPE,:FLASH,:FRUSTRATION,:GYROBALL,:HIDDENPOWER,:INFESTATION,:IRONDEFENSE,:IRONTAIL,:LEECHLIFE,:MEGAPUNCH,:MEGAHORN,:OVERCHARGE,:PAINSPLIT,:PINMISSILE,:PINCERGRIP,:POWERUPPUNCH,:PROTECT,:REST,:RETURN,:ROCKCLIMB,:ROCKSMASH,:ROUND,:SANDTOMB,:SCARYFACE,:SECRETPOWER,:SELFDESTRUCT,:SHOCKWAVE,:SIGNALBEAM,:SKITTERSMACK,:SLEEPTALK,:SMARTSTRIKE,:SNORE,:SPIKES,:STEELROLLER,:STRENGTH,:STRUGGLEBUG,:SUBSTITUTE,:SUPERCELLSLAM,:THUNDER,:THUNDERPUNCH,:THUNDERBOLT,:UTURN,:VOLTSWITCH,:WILDCHARGE,:WORKUP,:XSCISSOR,:ZAPCANNON]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:CHESNAUGHT,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:BUG)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ELECTRIC)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [88, 122, 107, 74, 64, 75]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:STATIC)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:ELECTRICSURGE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[0,:STORMHOLD],[1,:SPARK],[1,:GYROBALL],[1,:SPIKECANNON],
                      [1,:BELLYDRUM],[1,:TACKLE],[1,:GROWL],[1,:PESTER],
                      [1,:ROLLOUT],[5,:PESTER],[8,:ROLLOUT],[11,:SANDTOMB],
                      [15,:DEFENSECURL],[19,:BUGBITE],[29,:ZINGZAP],[35,:PINMISSILE],
                      [41,:DIG],[48,:CURSE],[54,:WILDCHARGE],[60,:PAINSPLIT],
                      [66,:MEGAHORN],[72,:GYROBALL],[78,:AFTERSHOCK]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :AFTERSHOCK,:ATTRACT,:BIND,:BLOCK,:BODYSLAM,:BREAKINGSWIPE,:BRICKBREAK,:BRUTALSWING,:BUGBITE,:BUGBUZZ,:CHARGEBEAM,:CONFIDE,:DATASURF,:DIG,:DRILLRUN,:ELECTRICTERRAIN,:ELECTROBALL,:ELECTROWEB,:ENDURE,:EXPLOSION,:FACADE,:FALSESWIPE,:FLASH,:FRUSTRATION,:GYROBALL,:HIDDENPOWER,:INFESTATION,:IRONDEFENSE,:IRONTAIL,:LEECHLIFE,:MEGAPUNCH,:MEGAHORN,:OVERCHARGE,:PAINSPLIT,:PINMISSILE,:PINCERGRIP,:POWERUPPUNCH,:PROTECT,:REST,:RETURN,:ROCKCLIMB,:ROCKSMASH,:ROUND,:SANDTOMB,:SCARYFACE,:SECRETPOWER,:SELFDESTRUCT,:SHOCKWAVE,:SIGNALBEAM,:SKITTERSMACK,:SLEEPTALK,:SMARTSTRIKE,:SNORE,:SPIKES,:STEELROLLER,:STRENGTH,:STRUGGLEBUG,:SUBSTITUTE,:SUPERCELLSLAM,:THUNDER,:THUNDERPUNCH,:THUNDERBOLT,:UTURN,:VOLTSWITCH,:WILDCHARGE,:WORKUP,:XSCISSOR,:ZAPCANNON]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:FUECOCO,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GROUND)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GROUND)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [59, 36, 63, 45, 67, 40]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==0) || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:UNNERVE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:REVERB)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[1,:TACKLE],[1,:LEER],[5,:MUDSLAP],[7,:ASTONISH],
                      [12,:ROUND],[15,:MUDSHOT],[17,:CONFIDE],[21,:SNARL],
                      [25,:TORMENT],[28,:FRACTURE],[32,:HYPERVOICE],[36,:SCORCHINGSANDS]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :ALLURINGVOICE,:ARENITEWALL,:BATTLECRY,:BLOCK,:BREAKINGSWIPE,:BURNINGJEALOUSY,:CONFIDE,:CRUNCH,:DARKPULSE,:DIG,:DRILLRUN,:DUSTBOWL,:EARTHPOWER,:ECHOEDVOICE,:ENCORE,:ENDEAVOR,:ENDURE,:FACADE,:FAKETEARS,:FALSESWIPE,:FIREFANG,:FOULGAMBIT,:FOULPLAY,:FRUSTRATION,:GASTROACID,:GUNKSHOT,:HELPINGHAND,:HIDDENPOWER,:HONECLAWS,:HYPERVOICE,:ICEFANG,:IRRITATION,:KNOCKOFF,:LASHOUT,:METRONOME,:MUDSHOT,:OUTRAGE,:PAINSPLIT,:PAYDAY,:PAYBACK,:PHANTOMFORCE,:PINMISSILE,:PROTECT,:PSYCHICNOISE,:REST,:RETURN,:ROAR,:ROCKSLIDE,:ROLEPLAY,:ROUND,:SANDTOMB,:SANDSTORM,:SCARYFACE,:SCORCHINGSANDS,:SCREECH,:SECRETPOWER,:SHADOWBALL,:SIGNALBEAM,:SLEEPTALK,:SNARL,:SNORE,:SNUFFOUT,:SONICSCREAM,:STEALTHROCK,:STOMPINGTANTRUM,:SUBSTITUTE,:SUPERFANG,:SWAGGER,:THIEF,:THUNDERFANG,:TORMENT,:UPROAR]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:CROCALOR,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GROUND)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DARK)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [78, 49, 81, 58, 90, 55]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==0) || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:UNNERVE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:REVERB)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[0,:PURSUIT],[1,:TACKLE],[1,:LEER],[5,:MUDSLAP],
                      [7,:ASTONISH],[10,:BELLOW],[12,:ROUND],[15,:MUDSHOT],
                      [17,:CONFIDE],[24,:SNARL],[28,:TORMENT],[32,:FRACTURE],
                      [38,:HYPERVOICE],[42,:DARKPULSE],[47,:SCORCHINGSANDS]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :ALLURINGVOICE,:ARENITEWALL,:BATTLECRY,:BLOCK,:BREAKINGSWIPE,:BURNINGJEALOUSY,:CONFIDE,:CRUNCH,:DARKPULSE,:DIG,:DRILLRUN,:DUSTBOWL,:EARTHPOWER,:ECHOEDVOICE,:ENCORE,:ENDEAVOR,:ENDURE,:FACADE,:FAKETEARS,:FALSESWIPE,:FIREFANG,:FOULGAMBIT,:FOULPLAY,:FRUSTRATION,:GASTROACID,:GUNKSHOT,:HELPINGHAND,:HIDDENPOWER,:HONECLAWS,:HYPERVOICE,:ICEFANG,:IRRITATION,:KNOCKOFF,:LASHOUT,:METRONOME,:MUDSHOT,:OUTRAGE,:PAINSPLIT,:PAYDAY,:PAYBACK,:PHANTOMFORCE,:PINMISSILE,:PROTECT,:PSYCHICNOISE,:REST,:RETURN,:ROAR,:ROCKSLIDE,:ROLEPLAY,:ROUND,:SANDTOMB,:SANDSTORM,:SCARYFACE,:SCORCHINGSANDS,:SCREECH,:SECRETPOWER,:SHADOWBALL,:SIGNALBEAM,:SLEEPTALK,:SNARL,:SNORE,:SNUFFOUT,:SONICSCREAM,:STEALTHROCK,:STOMPINGTANTRUM,:SUBSTITUTE,:SUPERFANG,:SWAGGER,:THIEF,:THUNDERFANG,:TORMENT,:UPROAR]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:SKELEDIRGE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GROUND)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DARK)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [100, 66, 104, 75, 110, 75]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==0) || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:UNNERVE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:REVERB)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[0,:PHANTOMCALL],[1,:PURSUIT],[1,:SING],[1,:PAINSPLIT],
                      [1,:ALLURINGVOICE],[1,:TACKLE],[1,:LEER],[5,:MUDSLAP],
                      [7,:ASTONISH],[10,:BELLOW],[12,:ROUND],[15,:MUDSHOT],
                      [17,:CONFIDE],[24,:SNARL],[28,:TORMENT],[32,:FRACTURE],
                      [38,:DARKPULSE],[42,:HYPERVOICE],[47,:SCORCHINGSANDS],[47,:NASTYPLOT],
                      [58,:EARTHPOWER],[64,:SNUFFOUT]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :ALLURINGVOICE,:ARENITEWALL,:BATTLECRY,:BLOCK,:BREAKINGSWIPE,:BURNINGJEALOUSY,:CONFIDE,:CRUNCH,:DARKPULSE,:DIG,:DRILLRUN,:DUSTBOWL,:EARTHPOWER,:ECHOEDVOICE,:ENCORE,:ENDEAVOR,:ENDURE,:FACADE,:FAKETEARS,:FALSESWIPE,:FIREFANG,:FOULGAMBIT,:FOULPLAY,:FRUSTRATION,:GASTROACID,:GUNKSHOT,:HELPINGHAND,:HIDDENPOWER,:HONECLAWS,:HYPERVOICE,:ICEFANG,:IRRITATION,:KNOCKOFF,:LASHOUT,:METRONOME,:MUDSHOT,:OUTRAGE,:PAINSPLIT,:PAYDAY,:PAYBACK,:PHANTOMFORCE,:PINMISSILE,:PROTECT,:PSYCHICNOISE,:REST,:RETURN,:ROAR,:ROCKSLIDE,:ROLEPLAY,:ROUND,:SANDTOMB,:SANDSTORM,:SCARYFACE,:SCORCHINGSANDS,:SCREECH,:SECRETPOWER,:SHADOWBALL,:SIGNALBEAM,:SLEEPTALK,:SNARL,:SNORE,:SNUFFOUT,:SONICSCREAM,:STEALTHROCK,:STOMPINGTANTRUM,:SUBSTITUTE,:SUPERFANG,:SWAGGER,:THIEF,:THUNDERFANG,:TORMENT,:UPROAR]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:QUAXLY,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ICE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ICE)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [45, 55, 45, 65, 50, 50]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:OWNTEMPO)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:HALCYON)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[1,:GROWL],[1,:POUND],[5,:POWDERSNOW],[7,:FEATHERDANCE],
                      [10,:GUST],[13,:ICEBALL],[17,:DOUBLEHIT],[21,:ICYWIND],
                      [24,:DUALWINGBEAT],[28,:MIRRORMOVE],[31,:AIRSLASH],[35,:TRIPLEAXEL]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :ACROBATICS,:AERIALACE,:AFTERYOU,:AGILITY,:AIRSLASH,:ATTRACT,:AURORAVEIL,:AVALANCHE,:BATONPASS,:BEATUP,:BLIZZARD,:BODYSLAM,:BOUNCE,:BRICKBREAK,:BULKUP,:CALMMIND,:CHARM,:CONFIDE,:DUALWINGBEAT,:ECHOEDVOICE,:ENCORE,:FACADE,:FALSESWIPE,:FLASHFREEZE,:FRUSTRATION,:GLACIALSLAM,:HAIL,:HELPINGHAND,:HIDDENPOWER,:ICEBEAM,:ICEPUNCH,:ICICLESPEAR,:ICYWIND,:KNOCKOFF,:LOWSWEEP,:MEGAKICK,:METRONOME,:PHRENICASSAULT,:POISONSWEEP,:PROTECT,:PSYCHIC,:PSYCHICNOISE,:PSYCHICTERRAIN,:RAINDANCE,:REST,:RETURN,:ROCKSMASH,:ROOST,:ROUND,:SCRUTINIZE,:SECRETPOWER,:SLEEPTALK,:SLEETSTORM,:SNORE,:SPEEDSWAP,:STEELWING,:SUBSTITUTE,:SUCKERPUNCH,:SWIFT,:SWORDSDANCE,:TAILWIND,:TAUNT,:UTURN,:WORKUP,:ZENHEADBUTT]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:QUAXWELL,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ICE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:PSYCHIC)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [65, 70, 60, 85, 65, 65]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:OWNTEMPO)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:HALCYON)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[0,:HEARTSTAMP],[1,:GROWL],[1,:POUND],[5,:POWDERSNOW],
                      [7,:FEATHDERDANCE],[10,:GUST],[13,:ICEBALL],[17,:TEETERDANCE],
                      [19,:ICYWIND],[23,:PSYBEAM],[27,:DUALWINGBEAT],[32,:MIRRORMOVE],
                      [38,:AIRSLASH],[43,:PSYCHIC],[48,:TRIPLEAXEL]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :ACROBATICS,:AERIALACE,:AFTERYOU,:AGILITY,:AIRSLASH,:ATTRACT,:AURORAVEIL,:AVALANCHE,:BATONPASS,:BEATUP,:BLIZZARD,:BODYSLAM,:BOUNCE,:BRICKBREAK,:BULKUP,:CALMMIND,:CHARM,:CONFIDE,:DUALWINGBEAT,:ECHOEDVOICE,:ENCORE,:FACADE,:FALSESWIPE,:FLASHFREEZE,:FRUSTRATION,:GLACIALSLAM,:HAIL,:HELPINGHAND,:HIDDENPOWER,:ICEBEAM,:ICEPUNCH,:ICICLESPEAR,:ICYWIND,:KNOCKOFF,:LOWSWEEP,:MEGAKICK,:METRONOME,:PHRENICASSAULT,:POISONSWEEP,:PROTECT,:PSYCHIC,:PSYCHICNOISE,:PSYCHICTERRAIN,:RAINDANCE,:REST,:RETURN,:ROCKSMASH,:ROOST,:ROUND,:SCRUTINIZE,:SECRETPOWER,:SLEEPTALK,:SLEETSTORM,:SNORE,:SPEEDSWAP,:STEELWING,:SUBSTITUTE,:SUCKERPUNCH,:SWIFT,:SWORDSDANCE,:TAILWIND,:TAUNT,:UTURN,:WORKUP,:ZENHEADBUTT]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:QUAQUAVAL,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ICE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:PSYCHIC)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [85, 85, 75, 120, 85, 80]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:OWNTEMPO)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:HALCYON)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[0,:SWANDIVE],[1,:HEARTSTAMP],[1,:STOREDPOWER],[1,:EARTHPOWER],
                      [1,:GROWL],[1,:POUND],[5,:POWDERSNOW],[7,:FEATHERDANCE],
                      [10,:GUST],[13,:ICEBALL],[17,:TEETERDANCE],[21,:ICYWIND],
                      [27,:DUALWINGBEAT],[32,:MIRRORMOVE],[38,:ZENHEADBUTT],[43,:AIRSLASH],
                      [47,:PSYCHIC],[52,:ROOST],[58,:TRIPLEAXEL],[64,:BLIZZARD]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :ACROBATICS,:AERIALACE,:AFTERYOU,:AGILITY,:AIRSLASH,:ATTRACT,:AURORAVEIL,:AVALANCHE,:BATONPASS,:BEATUP,:BLIZZARD,:BODYSLAM,:BOUNCE,:BRICKBREAK,:BULKUP,:CALMMIND,:CHARM,:CONFIDE,:DUALWINGBEAT,:ECHOEDVOICE,:ENCORE,:FACADE,:FALSESWIPE,:FLASHFREEZE,:FRUSTRATION,:GLACIALSLAM,:HAIL,:HELPINGHAND,:HIDDENPOWER,:ICEBEAM,:ICEPUNCH,:ICICLESPEAR,:ICYWIND,:KNOCKOFF,:LOWSWEEP,:MEGAKICK,:METRONOME,:PHRENICASSAULT,:POISONSWEEP,:PROTECT,:PSYCHIC,:PSYCHICNOISE,:PSYCHICTERRAIN,:RAINDANCE,:REST,:RETURN,:ROCKSMASH,:ROOST,:ROUND,:SCRUTINIZE,:SECRETPOWER,:SLEEPTALK,:SLEETSTORM,:SNORE,:SPEEDSWAP,:STEELWING,:SUBSTITUTE,:SUCKERPUNCH,:SWIFT,:SWORDSDANCE,:TAILWIND,:TAUNT,:UTURN,:WORKUP,:ZENHEADBUTT]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:SPRIGATITO,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:STEEL)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:STEEL)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [45, 65, 45, 54, 40, 61]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:PINPOINT)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SKILLLINK)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[1,:SCRATCH],[1,:TAILWHIP],[5,:RAM],[7,:POISONSTING],
                      [10,:LOCKON],[13,:FURYSWIPES],[15,:METALCLAW],[17,:FURYATTACK],
                      [21,:SPIKECANNON],[25,:SHARPEN],[28,:PINMISSILE],[32,:SMARTSTRIKE],
                      [36,:LASTRESORT]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :ACROBATICS,:AGILITY,:ASSURANCE,:ATTRACT,:BRICKBREAK,:BULLETSEED,:CONFIDE,:COVET,:EMBARGO,:ENCORE,:ERGOPROXY,:FACADE,:FAKETEARS,:FALSESWIPE,:FLASHCANNON,:FLING,:FOCUSENERGY,:FOULPLAY,:FRUSTRATION,:HEX,:HIDDENPOWER,:HONECLAWS,:ICICLESPEAR,:KNOCKOFF,:LASHOUT,:LASTRESORT,:LOWKICK,:PAINSPLIT,:PAYDAY,:PAYBACK,:PERFORATE,:PINMISSILE,:POISONJAB,:POLTERGEIST,:PROTECT,:PSYCHOCUT,:QUASH,:REST,:RETALIATE,:RETURN,:REVERSAL,:ROUND,:SCARYFACE,:SECRETPOWER,:SHADOWCLAW,:SKITTERSMACK,:SLASHANDBURN,:SLEEPTALK,:SMARTSTRIKE,:SNARL,:SNORE,:SNUFFOUT,:SOULJAVELIN,:SPIKES,:SPITE,:STARDESTROYER,:STEALTHROCK,:SUBSTITUTE,:SUCKERPUNCH,:SWORDSDANCE,:TALESEND,:THIEF,:TORMENT,:TOXIC,:TRICK,:UTURN,:WORKUP,:XSCISSOR]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:FLORAGATO,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:STEEL)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GHOST)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [63, 83, 61, 63, 60, 80]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:PINPOINT)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SKILLLINK)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[0,:ASTONISH],[1,:SCRATCH],[1,:TAILWHIP],[5,:RAM],
                      [7,:POISONSTING],[10,:LOCKON],[13,:FURYSWIPES],[15,:METALCLAW],
                      [21,:SPIKECANNON],[24,:SHARPEN],[28,:SHADOWSNEAK],[33,:SHADOWCLAW],
                      [38,:PINMISSILE],[42,:LASTRESORT],[46,:PERFORATE]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :ACROBATICS,:AGILITY,:ASSURANCE,:ATTRACT,:BRICKBREAK,:BULLETSEED,:CONFIDE,:COVET,:EMBARGO,:ENCORE,:ERGOPROXY,:FACADE,:FAKETEARS,:FALSESWIPE,:FLASHCANNON,:FLING,:FOCUSENERGY,:FOULPLAY,:FRUSTRATION,:HEX,:HIDDENPOWER,:HONECLAWS,:ICICLESPEAR,:KNOCKOFF,:LASHOUT,:LASTRESORT,:LOWKICK,:PAINSPLIT,:PAYDAY,:PAYBACK,:PERFORATE,:PINMISSILE,:POISONJAB,:POLTERGEIST,:PROTECT,:PSYCHOCUT,:QUASH,:REST,:RETALIATE,:RETURN,:REVERSAL,:ROUND,:SCARYFACE,:SECRETPOWER,:SHADOWCLAW,:SKITTERSMACK,:SLASHANDBURN,:SLEEPTALK,:SMARTSTRIKE,:SNARL,:SNORE,:SNUFFOUT,:SOULJAVELIN,:SPIKES,:SPITE,:STARDESTROYER,:STEALTHROCK,:SUBSTITUTE,:SUCKERPUNCH,:SWORDSDANCE,:TALESEND,:THIEF,:TORMENT,:TOXIC,:TRICK,:UTURN,:WORKUP,:XSCISSOR]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:MEOWSCARADA,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:STEEL)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GHOST)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [76, 123, 70, 81, 70, 110]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:PINPOINT)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SKILLLINK)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[0,:CURTAINCALL],,[1,:ASTONISH],[1,:FELLSTINGER],[1,:NEEDLEARM],
                      [1,:SPIRITSHACKLE],[1,:FLING],[1,:SCRATCH],[1,:TAILWHIP],[5,:RAM],
                      [7,:POISONSTING],[10,:LOCKON],[13,:FURYSWIPES],[15,:METALCLAW],
                      [21,:SPIKECANNON],[24,:SHARPEN],[29,:SHADOWSNEAK],[33,:SHADOWCLAW],
                      [38,:PINMISSILE],[42,:SMARTSTRIKE],[47,:LASTRESORT],[52,:PERFORATE],
                      [58,:ENCORE],[64,:GUILLOTINE]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :ACROBATICS,:AGILITY,:ASSURANCE,:ATTRACT,:BRICKBREAK,:BULLETSEED,:CONFIDE,:COVET,:EMBARGO,:ENCORE,:ERGOPROXY,:FACADE,:FAKETEARS,:FALSESWIPE,:FLASHCANNON,:FLING,:FOCUSENERGY,:FOULPLAY,:FRUSTRATION,:HEX,:HIDDENPOWER,:HONECLAWS,:ICICLESPEAR,:KNOCKOFF,:LASHOUT,:LASTRESORT,:LOWKICK,:PAINSPLIT,:PAYDAY,:PAYBACK,:PERFORATE,:PINMISSILE,:POISONJAB,:POLTERGEIST,:PROTECT,:PSYCHOCUT,:QUASH,:REST,:RETALIATE,:RETURN,:REVERSAL,:ROUND,:SCARYFACE,:SECRETPOWER,:SHADOWCLAW,:SKITTERSMACK,:SLASHANDBURN,:SLEEPTALK,:SMARTSTRIKE,:SNARL,:SNORE,:SNUFFOUT,:SOULJAVELIN,:SPIKES,:SPITE,:STARDESTROYER,:STEALTHROCK,:SUBSTITUTE,:SUCKERPUNCH,:SWORDSDANCE,:TALESEND,:THIEF,:TORMENT,:TOXIC,:TRICK,:UTURN,:WORKUP,:XSCISSOR]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:POOCHYENA,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GHOST)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [35, 30, 35, 55, 30, 35]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:INTIMIDATE)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:SHADOWTAG)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:MERCILESS)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[1,:TACKLE],[4,:GROWL],[7,:EMBER],[10,:ESSENCEFEED],
                      [13,:SCARYFACE],[13,:INCINERATE],[16,:ROAR],[19,:CONFUSERAY],
                      [22,:OMINOUSWIND],[25,:WILLOWISP],[28,:SHADOWSNEAK],[28,:GRUDGE],
                      [31,:TORMENT],[34,:MYSTICALFIRE],[37,:CURSE],[40,:SHADOWBALL],
                      [43,:FIREBLAST],[46,:SNUFFOUT]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :ATTRACT,:BODYSLAM,:BURNINGJEALOUSY,:CONFIDE,:COVET,:CRUNCH,:DIG,:EMBARGO,:ENDURE,:EVISCERATE,:FACADE,:FIREBLAST,:FIREFANG,:FIRESPIN,:FLAMECHARGE,:FLAMETHROWER,:FOULGAMBIT,:FRUSTRATION,:HEX,:HIDDENPOWER,:ICEFANG,:INCINERATE,:IRONTAIL,:KNOCKOFF,:MAGMADRIFT,:MYSTICALFIRE,:OVERHEAT,:PAYBACK,:POLTERGEIST,:PROTECT,:REST,:RETALIATE,:RETURN,:ROAR,:ROCKSMASH,:ROUND,:SHADOWBALL,:SLEEPTALK,:SNARL,:SNUFFOUT,:SPITE,:STRENGTH,:SUBSTITUTE,:SUNNYDAY,:SUPERFANG,:SWAGGER,:TEMPERFLARE,:THUNDERFANG,:TORMENT,:TOXIC,:WILLOWISP]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:MIGHTYENA,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GHOST)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [70, 60, 70, 70, 90, 60]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:INTIMIDATE)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:SHADOWTAG)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:MERCILESS)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[0,:SMOG],[1,:GLARE],[1,:INFERNO],[1,:DARKPULSE],
                      [1,:MYSTICALFIRE],[1,:IMPRISON],[1,:TACKLE],[1,:GROWL],
                      [1,:EMBER],[1,:ESSENCEFEED],[4,:GROWL],[7,:EMBER],
                      [10,:ESSENCEFEED],[13,:INCINERATE],[16,:ROAR],[20,:CONFUSERAY],
                      [24,:OMINOUSWIND],[28,:WILLOWISP],[32,:SHADOWSNEAK],[32,:GRUDGE],
                      [36,:TORMENT],[40,:MYSTICALFIRE],[44,:CURSE],[48,:SHADOWBALL],
                      [52,:FIREBLAST],[56,:SNUFFOUT]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :ATTRACT,:BODYSLAM,:BURNINGJEALOUSY,:CONFIDE,:COVET,:CRUNCH,:DARKPULSE,:DIG,:EMBARGO,:ENDURE,:EVISCERATE,:FACADE,:FIREBLAST,:FIREFANG,:FIRESPIN,:FLAMECHARGE,:FLAMETHROWER,:FOULGAMBIT,:FRUSTRATION,:GIGAIMPACT,:HEX,:HIDDENPOWER,:ICEFANG,:INCINERATE,:IRONTAIL,:KNOCKOFF,:MAGMADRIFT,:MYSTICALFIRE,:OVERHEAT,:PAYBACK,:POLTERGEIST,:PROTECT,:REST,:RETALIATE,:RETURN,:ROAR,:ROCKSMASH,:ROUND,:SCARYFACE,:SHADOWBALL,:SLEEPTALK,:SNARL,:SNUFFOUT,:SPITE,:STRENGTH,:SUBSTITUTE,:SUNFURY,:SUNNYDAY,:SUPERFANG,:SWAGGER,:TEMPERFLARE,:THUNDERFANG,:TORMENT,:TOXIC,:WILLOWISP]
      end
      for i in 0...movelist.length
        movelist[i]=getConst(PBMoves,movelist[i])
      end
      next movelist
    },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:RIOLU,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [70, 40, 40, 35, 60, 40]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:OBLIVIOUS)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:INNERFOCUS)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:STEELWORKER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Riolu movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:LUCARIO,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GROUND)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [115, 90, 70, 70, 110, 70]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:REGENERATOR)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:INNERFOCUS)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:STEELWORKER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Lucario movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:GASTLY,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GHOST)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [80, 100, 30, 35, 35, 30]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:ILLUSION)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:INFILTRATOR)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Gastly movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:HAUNTER,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GHOST)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [95, 115, 45, 55, 50, 45]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:ILLUSION)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:INFILTRATOR)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Haunter movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:GENGAR,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GHOST)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [110, 130, 60, 75, 65, 60]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:ILLUSION)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:MAJESTY)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Gengar movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:ABRA,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [25, 15, 90, 20, 55, 105]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SHIELDDUST)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:WONDERSKIN)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:POWEROFALCHEMY)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Abra movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:KADABRA,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [40, 30, 105, 35, 70, 120]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SHIELDDUST)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:WONDERSKIN)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:POWEROFALCHEMY)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Kadabra movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:ALAKAZAM,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [55, 45, 120, 50, 95, 135]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SHIELDDUST)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:WONDERSKIN)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:POWEROFALCHEMY)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Alakazam movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:MACHOP,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DARK)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:STEEL)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [35, 70, 35, 80, 50, 35]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:PRESSURE)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:NOGUARD)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:STALKER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Machop movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:MACHOKE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DARK)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:STEEL)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [50, 80, 60, 100, 70, 45]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:PRESSURE)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:NOGUARD)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:STALKER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Machoke movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:MACHAMP,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DARK)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:STEEL)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [55, 90, 80, 130, 85, 65]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:PRESSURE)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:NOGUARD)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:STALKER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Machamp movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:STUFFUL,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:NORMAL)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GHOST)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [75, 70, 50, 45, 50, 50]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:CURSEDBODY)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:UNAWARE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:CUTEINFATUATE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Stufful movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:BEWEAR,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:NORMAL)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GHOST)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [125, 120, 60, 55, 60, 80]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:CURSEDBODY)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:UNAWARE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:UNNERVE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Bewear movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:VOLTORB,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:PSYCHIC)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [50, 30, 40, 55, 55, 100]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:TELEPATHY)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:SYNCHRONIZE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:LEVITATE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[1,:MIRACLEEYE],[1,:PSYWAVE],[4,:CONFUSION],[6,:POISONGAS],
                      [9,:CLEARSMOG],[11,:ROLLOUT],[13,:MIST],[16,:PSYBEAM],
                      [20,:HEX],[22,:SYNCHRONOISE],[26,:MEMENTO],[29,:SLUDGEBOMB],
                      [34,:REFLECT],[34,:LIGHTSCREEN],[41,:CORROSIVEGAS],[46,:GYROBALL],
                      [50,:DESTINYBOND]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :AGILITY,:ALLYSWITCH,:AMNESIA,:AURASPHERE,:CALMMIND,:CHARGEBEAM,:CONDESCEND,:CONFIDE,:CORROSIVEGAS,:COSMICPOWER,:ENDURE,:ERGOPROXY,:EXPLOSION,:FACADE,:FLASH,:FRUSTRATION,:GASTROACID,:GUARDSWAP,:GYROBALL,:HALLUCINATE,:HEX,:HIDDENPOWER,:LIGHTSCREEN,:MAGICCOAT,:MAGICROOM,:METRONOME,:MISTYEXPLOSION,:MYSTICALFIRE,:PROTECT,:PSYCHIC,:PSYCHICNOISE,:PSYCHICTERRAIN,:PSYSHOCK,:REFLECT,:REST,:RETURN,:ROUND,:SAFEGUARD,:SCREECH,:SCRUTINIZE,:SECRETPOWER,:SELFDESTRUCT,:SHADOWBALL,:SHOCKWAVE,:SLEEPTALK,:SLUDGEBOMB,:SNORE,:SOULJAVELIN,:SUBSTITUTE,:SUNNYDAY,:SWIFT,:TELEKINESIS,:TOXIC,:TRICKROOM,:UNSTABLEMATTER,:VENOSHOCK]
      end
	  },
	"onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:ELECTRODE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:PSYCHIC)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [70, 50, 60, 80, 80, 150]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:TELEPATHY)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:SYNCHRONIZE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:LEVITATE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[0,:MISTBALL],[1,:MIRACLEEYE],[1,:PSYWAVE],[4,:CONFUSION],
                      [6,:POISONGAS],[9,:CLEARSMOG],[11,:ROLLOUT],[13,:MIST],
                      [16,:PSYBEAM],[20,:HEX],[22,:SYNCHRONOISE],[26,:MEMENTO],
                      [29,:SLUDGEBOMB],[34,:REFLECT],[34,:LIGHTSCREEN],[41,:CORROSIVEGAS],
                      [46,:GYROBALL],[50,:DESTINYBOND]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :AGILITY,:ALLYSWITCH,:AMNESIA,:AURASPHERE,:CALMMIND,:CHARGEBEAM,:CONDESCEND,:CONFIDE,:CORROSIVEGAS,:COSMICPOWER,:ENDURE,:ERGOPROXY,:EXPLOSION,:FACADE,:FLASH,:FOCUSBLAST,:FRUSTRATION,:GASTROACID,:GIGAIMPACT,:GUARDSWAP,:GYROBALL,:HALLUCINATE,:HEX,:HIDDENPOWER,:HYPERBEAM,:LIGHTSCREEN,:MAGICCOAT,:MAGICROOM,:METRONOME,:MISTYEXPLOSION,:MYSTICALFIRE,:PROTECT,:PSYCHIC,:PSYCHICNOISE,:PSYCHICTERRAIN,:PSYSHOCK,:REFLECT,:REST,:RETURN,:ROUND,:SAFEGUARD,:SCREECH,:SCRUTINIZE,:SECRETPOWER,:SELFDESTRUCT,:SHADOWBALL,:SHOCKWAVE,:SLEEPTALK,:SLUDGEBOMB,:SNORE,:SOULJAVELIN,:SUBSTITUTE,:SUNNYDAY,:SWIFT,:TELEKINESIS,:TOXIC,:TRICKROOM,:UNSTABLEMATTER,:VENOSHOCK]
      end
	  },
  "onSetForm"=>proc{|pokemon,form|	  
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:SOLOSIS,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:WATER)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GHOST)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [50, 20, 45, 30, 105, 40]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:FILTER)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:STATIC)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:WATERABSORB)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Solosis movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:DUOSION,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:WATER)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GHOST)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [65, 30, 60, 40, 125, 50]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:FILTER)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:STATIC)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:WATERABSORB)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Duosion movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:REUNICLUS,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:WATER)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GHOST)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [110, 30, 85, 65, 125, 75]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:FILTER)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:STATIC)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:WATERABSORB)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Reuniclus movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:GOTHITA,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GRASS)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [45, 30, 50, 65, 55, 45]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:CHLOROPHYLL)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:NATURALSHROUD)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:DANCER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Gothita movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:GOTHORITA,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GRASS)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [60, 45, 70, 85, 75, 55]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:CHLOROPHYLL)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:NATURALSHROUD)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:DANCER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Gothorita movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:GOTHITELLE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GRASS)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [70, 55, 95, 110, 95, 65]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:CHLOROPHYLL)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:NATURALSHROUD)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:DANCER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Gothitelle movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:SKORUPI,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DRAGON)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DRAGON)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [65, 50, 90, 30, 40, 55]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:BATTLEARMOR)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:MOLDBREAKER)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:CONTRARY)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[1,:RANCOR],[1,:POISONSTING],[1,:GROWL],[5,:BELLOW],
                      [9,:BEATUP],[13,:ROAR],[16,:PINMISSILE],[20,:BREAKINGSWIPE],
                      [23,:POISONFANG],[27,:INCINERATE],[30,:SCREECH],[34,:TOXICSPIKES],
                      [38,:DRAGONCLAW],[41,:FELLSTINGER],[45,:SLUDGEBOMB],[47,:DRAGONDARTS],
                      [49,:SUPERPOWER]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :AQUATAIL,:ASSURANCE,:ATTRACT,:BEATUP,:BREAKINGSWIPE,:BRICKBREAK,:BRUTALSWING,:BUGBUZZ,:BULLDOZE,:CONFIDE,:CUT,:DIG,:DRAGONCHEER,:DRAGONCLAW,:DRAGONPULSE,:DRAGONTAIL,:DUALCHOP,:ENDURE,:FACADE,:FALSESWIPE,:FIREFANG,:FLASH,:FRUSTRATION,:HIDDENPOWER,:HONECLAWS,:ICEFANG,:INCINERATE,:IRONDEFENSE,:IRONTAIL,:IRRITATION,:KNOCKOFF,:LASHOUT,:LOCUSTSWARM,:OUTRAGE,:PINMISSILE,:PINCERGRIP,:POISONSWEEP,:PROTECT,:RAINDANCE,:REST,:RETURN,:ROAR,:ROCKSLIDE,:ROCKSMASH,:ROCKTOMB,:ROUND,:SCALESHOT,:SCARYFACE,:SCREECH,:SECRETPOWER,:SHADOWCLAW,:SKITTERSMACK,:SLEEPTALK,:SLUDGEBOMB,:SNORE,:STRENGTH,:SUBSTITUTE,:SUNNYDAY,:SWAGGER,:TAUNT,:THIEF,:THUNDERFANG,:TOXICSPIKES,:TRIATTACK,:UPROAR,:WORKUP,:XSCISSOR]
      end
	  },
  "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:DRAPION,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DRAGON)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DRAGON)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [95, 90, 110, 60, 70, 75]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:BATTLEARMOR)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:MOLDBREAKER)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:CONTRARY)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[0,:CRUNCH],[1,:CRUNCH],[1,:FLAMETHROWER],[1,:OUTRAGE],
                      [1,:HAMMERARM],[1,:ICEFANG],[1,:FIREFANG],[1,:THUNDERFANG],
                      [1,:RANCOR],[1,:POISONSTING],[1,:GROWL],[1,:BELLOW],
                      [5,:BELLOW],[9,:BEATUP],[13,:ROAR],[16,:PINMISSILE],
                      [20,:BREAKINGSWIPE],[23,:POISONFANG],[27,:INCINERATE],[30,:SCREECH],
                      [34,:TOXICSPIKES],[38,:DRAGONCLAW],[43,:FELLSTINGER],[49,:SLUDGEBOMB],
                      [53,:DRAGONDARTS],[57,:SUPERPOWER]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :AQUATAIL,:ASSURANCE,:ATTRACT,:BEATUP,:BREAKINGSWIPE,:BRICKBREAK,:BRUTALSWING,:BUGBUZZ,:BULLDOZE,:CONFIDE,:CUT,:DIG,:DRACOMETEOR,:DRAGONCHEER,:DRAGONCLAW,:DRAGONPULSE,:DRAGONTAIL,:DUALCHOP,:EARTHQUAKE,:ENDURE,:FACADE,:FALSESWIPE,:FIREFANG,:FLAMETHROWER,:FLASH,:FRUSTRATION,:GIGAIMPACT,:HIDDENPOWER,:HONECLAWS,:HYPERBEAM,:ICEFANG,:INCINERATE,:IRONDEFENSE,:IRONTAIL,:IRRITATION,:KNOCKOFF,:LASHOUT,:LOCUSTSWARM,:OUTRAGE,:PINMISSILE,:PINCERGRIP,:POISONSWEEP,:PROTECT,:RAINDANCE,:REST,:RETURN,:ROAR,:ROCKSLIDE,:ROCKSMASH,:ROCKTOMB,:ROUND,:SCALESHOT,:SCARYFACE,:SCREECH,:SECRETPOWER,:SHADOWCLAW,:SHOWSTOPPER,:SKITTERSMACK,:SLEEPTALK,:SLUDGEBOMB,:SNORE,:STRENGTH,:SUBSTITUTE,:SUNNYDAY,:SWAGGER,:TAUNT,:THIEF,:THUNDERFANG,:TOXICSPIKES,:TRIATTACK,:TRINITYFORCE,:UPROAR,:WORKUP,:XSCISSOR]
      end
	  },
  "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:CLAMPERL,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ICE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ICE)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [85, 55, 35, 32, 74, 64]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:PRISMARMOR)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SHELLARMOR)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Clamperl movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:HUNTAIL,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ICE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [75, 105, 52, 94, 104, 55]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:PRISMARMOR)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SHEERFORCE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Huntail movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:GOREBYSS,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ICE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [55, 52, 84, 114, 75, 105]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:PRISMARMOR)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:DAZZLING)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Gorebyss movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:LITWICK,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [20, 30, 55, 50, 65, 55]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:FLAMEBODY)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:ILLUMINATE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:MAGICGUARD)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Litwick movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:LAMPENT,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [55, 40, 60, 60, 95, 60]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:FLAMEBODY)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:ILLUMINATE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:MAGICGUARD)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Lampent movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:CHANDELURE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [80, 55, 90, 60, 145, 90]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:FLAMEBODY)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:ILLUMINATE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:MAGICGUARD)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Chandelure movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:AXEW,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GROUND)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIGHTING)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [46, 40, 57, 30, 87, 60]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:MOLDBREAKER)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:SANDFORCE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:GRENADIER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Axew movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:FRAXURE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GROUND)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIGHTING)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [66, 50, 67, 40, 117, 70]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:MOLDBREAKER)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:SANDFORCE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:GRENADIER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Fraxure movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:HAXORUS,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GROUND)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIGHTING)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [76, 70, 90, 60, 147, 97]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:MOLDBREAKER)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:SANDFORCE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:GRENADIER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Haxorus movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:MIMEJR,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:NORMAL)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:NORMAL)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [45, 60, 20, 90, 70, 25]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:PRANKSTER)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:ELDRITCH)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:TECHNICIAN)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Mime Jr. movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:PARAS,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:BUG)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:BUG)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [35, 70, 55, 55, 45, 25]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:RUNAWAY)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:ANGERPOINT)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:MOLDBREAKER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Paras movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:HONEDGE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:STEEL)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:STEEL)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [28, 100, 45, 37, 35, 80]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:LEVITATE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Honedge movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:CHINGLING,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FLYING)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FLYING)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [45, 30, 45, 50, 65, 50]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SOUNDPROOF)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:PURIFYING)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Chingling movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:CHIMECHO,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FLYING)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GHOST)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [75, 50, 65, 90, 95, 80]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SOUNDPROOF)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:PURIFYING)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Chimecho movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:RELLOR,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:NORMAL)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:NORMAL)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [30, 58, 41, 60, 31, 50]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:STURDY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:STALL)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Rellor movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:RAPIDASH,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=2
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=2
    next getID(PBTypes,:GROUND)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=2
    next [105, 100, 80, 65, 70, 80]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=2 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:THICKFAT)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:STAMINA)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:STALWART)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Rapidash movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==2
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:MUDSDALE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GROUND)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FLYING)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [85, 100, 55, 125, 100, 35]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:WINDRIDER)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:RUNAWAY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:DEFIANT)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Mudsdale movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:ELDEGOSS,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GRASS)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GHOST)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [60, 80, 50, 120, 90, 60]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:COTTONMOLT)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:NOGUARD)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SHEDSKIN)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[0,:OMINOUSWIND],[1,:OMINOUSWIND],[1,:LEAFAGE],[1,:STUNSPORE],
                      [4,:RAPIDSPIN],[8,:SPITE],[12,:RAZORLEAF],[16,:ESSENCEFEED],
                      [23,:LEAFTORNADO],[28,:PAINSPLIT],[34,:SHADOWBALL],[40,:CURSE],
                      [46,:LEAFSTORM],[52,:SING]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :ACROBATICS,:AIRSLASH,:ATTRACT,:BULLETSEED,:CHARM,:ENDURE,:ENERGYBALL,:ERGOPROXY,:FACADE,:FRUSTRATION,:GIGADRAIN,:GIGAIMPACT,:GRASSKNOT,:GRASSYTERRAIN,:HELPINGHAND,:HEX,:HIDDENPOWER,:HURRICANE,:HYPERBEAM,:HYPERVOICE,:JETSTREAM,:LIGHTSCREEN,:LOTUSBLOOM,:MAGICALLEAF,:PAINSPLIT,:PERFORATE,:POLLENPUFF,:POLTERGEIST,:PROTECT,:REST,:RETRIBUTION,:SEEDBOMB,:SHADOWBALL,:SLASHANDBURN,:SLEEPTALK,:SOLARBEAM,:SONICSCREAM,:SPITE,:SUBSTITUTE,:SUNNYDAY,:SYNTHESIS,:TAILWIND,:WILLOWISP,:WORRYSEED]
      end
	  },
  "onSetForm"=>proc{|pokemon,form|	  
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:MUK,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=3
    next getID(PBTypes,:POISON)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=3
    next getID(PBTypes,:GROUND)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=3
    next [105, 65, 105, 50, 100, 75]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=3 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:CURSEDBODY)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:SOLIDROCK)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:WANDERINGSPIRIT)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Muk movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==3
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:LIEPARD,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DARK)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ROCK)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [64, 106, 88, 88, 50, 50]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:STRONGJAW)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:UNBURDEN)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:PITCHBLACK)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[0,:ROCKTOMB],[1,:ROCKTOMB],[1,:THUNDERFANG],[1,:FIREFANG],
                      [1,:ICEFANG],[1,:SCRATCH],[1,:GROWL],[1,:ASSIST],
                      [1,:SANDATTACK],[3,:GROWL],[6,:ASSIST],[10,:SANDATTACK],
                      [12,:FURYSWIPES],[15,:PURSUIT],[19,:TORMENT],[22,:BITE],
                      [26,:IRONDEFENSE],[31,:ROCKSLIDE],[34,:CRUNCH],[38,:SHARPEN],
                      [43,:SUCKERPUNCH],[47,:STEALTHROCK],[50,:ROCKPOLISH],[55,:PSYCHICFANGS],
                      [58,:STONEEDGE]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :AERIALACE,:ASSURANCE,:ATTRACT,:CHARM,:CONFIDE,:COVET,:CRUNCH,:CUT,:DARKPULSE,:DOUBLETEAM,:DYNAMICPUNCH,:EARTHQUAKE,:ECHOEDVOICE,:EMBARGO,:ENCORE,:ENDURE,:EVISCERATE,:FACADE,:FAKETEARS,:FIREFANG,:FLASH,:FOULPLAY,:FRUSTRATION,:GIGAIMPACT,:GRASSKNOT,:GUNKSHOT,:HIDDENPOWER,:HONECLAWS,:HYPERBEAM,:HYPERVOICE,:ICEFANG,:IRONDEFENSE,:IRONTAIL,:KNOCKOFF,:LASHOUT,:LITHOFORM,:METEORBEAM,:PAYDAY,:PAYBACK,:POWERGEM,:PROTECT,:PSYCHUP,:RAINDANCE,:REST,:RETURN,:ROCKPOLISH,:ROCKSLIDE,:ROCKTOMB,:ROLEPLAY,:ROUND,:SCREECH,:SECRETPOWER,:SEEDBOMB,:SHADOWBALL,:SHADOWCLAW,:SLEEPTALK,:SMACKDOWN,:SNARL,:SNORE,:SNUFFOUT,:SPITE,:STEALTHROCK,:STONEEDGE,:SUBSTITUTE,:SUCKERPUNCH,:SUNNYDAY,:SWAGGER,:SWORDSDANCE,:TAUNT,:THIEF,:THUNDERFANG,:THUNDERWAVE,:TORMENT,:TOXIC,:TRICK,:UTURN]
      end
	  },
  "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:ROCKRUFF,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ICE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:NORMAL)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [45, 65, 40, 60, 30, 60]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SPIRITED)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:OWNTEMPO)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SLUSHRUSH)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Rockruff movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:LYCANROCMIDDAY,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ICE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIGHTING)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [75, 55, 65, 112, 115, 65]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SPIRITED)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:NOGUARD)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SCRAPPY)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Lycanroc-Midday movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:LYCANROCMIDNIGHT,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ICE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DARK)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [75, 115, 85, 82, 55, 75]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:STRONGJAW)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:LIMBER)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SLUSHRUSH)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Lycanroc-Midnight movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:LYCANROCDUSK,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ICE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GHOST)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [110, 117, 65, 75, 55, 65]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:STEADFAST)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:OWNTEMPO)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:FURCOAT)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Lycanroc-Dusk movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:CHARCADET,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ROCK)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ROCK)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [35, 50, 40, 40, 50, 40]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:STURDY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:BATTLEARMOR)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Charcadet movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:CERULEDGE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ROCK)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FLYING)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [80, 60, 75, 85, 125, 100]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:STURDY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:NOGUARD)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Ceruledge movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:ARMAROUGE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ROCK)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:WATER)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [80, 125, 100, 75, 60, 85]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:STURDY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:ROCKHEAD)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Armarouge movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:GIMMIGHOUL,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:STEEL)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:STEEL)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [75, 45, 70, 10, 30, 70]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:MAGNETPULL)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:FRIENDGUARD)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[1,:MAGNETBOMB],[1,:MAGNETRISE]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :ENDURE,:FLASHCANNON,:FRUSTRATION,:HIDDENPOWER,:LIGHTSCREEN,:MAGNETRISE,:PROTECT,:PSYCHIC,:PSYSHOCK,:REFLECT,:REST,:RETURN,:SUBSTITUTE,:TRICK,:ZENHEADBUTT]
      end
	  },
  "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:GHOLDENGO,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:STEEL)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:PSYCHIC)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [133, 84, 91, 87, 60, 95]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:ESOTERIC)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[1,:MAGNETBOMB],[1,:MAGNETRISE],[7,:PSYWAVE],[14,:GRAVITY],
                      [21,:PROTECT],[28,:CALMMIND],[35,:PSYCHIC],[42,:RECOVER],
                      [49,:METEORBEAM],[56,:REDSUNSZENITH],[63,:STARFALL],[70,:STARDESTROYER]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :CALMMIND,:CHARGEBEAM,:ELECTROBALL,:ENDURE,:FLASHCANNON,:FRUSTRATION,:GIGAIMPACT,:GRAVITY,:HEAVYSLAM,:HIDDENPOWER,:HYPERBEAM,:IRONDEFENSE,:IRONHEAD,:LIGHTSCREEN,:LOWKICK,:MAGICCOAT,:MAGNETRISE,:METEORBEAM,:PHRENICASSAULT,:POWERGEM,:PROTECT,:PSYCHIC,:PSYCHICNOISE,:PSYCHICTERRAIN,:PSYCHOCUT,:PSYSHOCK,:RAINDANCE,:REFLECT,:REST,:RETURN,:SANDSTORM,:SCRUTINIZE,:SHADOWBALL,:SHOCKWAVE,:SLEEPTALK,:STARDESTROYER,:SUBSTITUTE,:TELEKINESIS,:THIEF,:THUNDER,:THUNDERPUNCH,:THUNDERWAVE,:THUNDERBOLT,:TRICK,:UNSTABLEMATTER,:ZENHEADBUTT]
      end
	  },
  "onSetForm"=>proc{|pokemon,form|	  
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:AMAURA,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DRAGON)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ELECTRIC)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [67, 59, 63, 50, 77, 46]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:MOTORDRIVE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SPEEDBOOST)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Amaura movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:AURORUS,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DRAGON)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ELECTRIC)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [99, 77, 92, 72, 123, 58]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:MOTORDRIVE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SPEEDBOOST)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Aurorus movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:TYRUNT,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ICE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [89, 77, 45, 58, 45, 48]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:CORROSION)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:UNBURDEN)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Tyrunt movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:TYRANTRUM,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ICE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [121, 119, 69, 82, 59, 71]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:CORROSION)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:UNBURDEN)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Tyrantrum movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:CUFANT,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIGHTING)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIGHTING)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [49, 49, 72, 40, 40, 80]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SPIRITED)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:WATERABSORB)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Cufant movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:COPPERAJAH,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIGHTING)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIGHTING)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [80, 80, 122, 69, 30, 130]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SPIRITED)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:WATERABSORB)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Copperajah movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:FALINKS,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GRASS)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ELECTRIC)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [70, 65, 100, 60, 75, 100]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:DRIZZLE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:STORMDRAIN)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Falinks movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:ARROKUDA,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GRASS)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ROCK)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [40, 66, 41, 63, 30, 40]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:NOGUARD)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SNIPER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Arrokuda movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:BARRASKEWDA,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GRASS)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:STEEL)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [60, 136, 61, 123, 50, 60]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:LACERATE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SNIPER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Barraskewda movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:TOXEL,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ELECTRIC)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:PSYCHIC)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [40, 35, 35, 40, 54, 38]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:BATTLEARMOR)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:SOUNDPROOF)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:INSOMNIA)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Toxel movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:TOXTRICITYTRANCE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ELECTRIC)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:PSYCHIC)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [75, 70, 75, 70, 114, 98]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SEGUE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Toxtricity-Trance movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:TOXTRICITYDUBSTEP,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ELECTRIC)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:PSYCHIC)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [75, 70, 70, 114, 98, 75]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SEGUE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Toxtricity-Dubstep movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:SHIELDON,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GRASS)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GRASS)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [30, 118, 42, 30, 88, 42]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:DISGUISE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SAPSIPPER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Shieldon movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:BASTIODON,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GRASS)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GROUND)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [60, 168, 52, 30, 138, 47]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:DISGUISE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SAPSIPPER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Bastiodon movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:CRANIDOS,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:BUG)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:BUG)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [67, 58, 30, 125, 30, 40]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:ARENATRAP)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:STALL)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Cranidos movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:RAMPARDOS,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:BUG)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GROUND)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [97, 65, 58, 165, 50, 60]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:ARENATRAP)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:STALL)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Rampardos movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:TINKATINK,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:WATER)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:STEEL)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [45, 35, 64, 50, 58, 45]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SNIPER)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:MOLDBREAKER)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:MEGALAUNCHER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Tinkatink movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:TINKATUFF,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:WATER)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:STEEL)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [55, 45, 82, 65, 78, 55]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SNIPER)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:MOLDBREAKER)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:MEGALAUNCHER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Tinkatuff movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:TINKATON,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:WATER)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:STEEL)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [75, 70, 105, 85, 94, 77]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SNIPER)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:MOLDBREAKER)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:MEGALAUNCHER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Tinkaton movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:TOGEPI,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DRAGON)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DRAGON)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [35, 65, 65, 20, 20, 40]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SHEDSKIN)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:WONDERSKIN)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:CLEARBODY)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Togepi movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:TOGETIC,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DRAGON)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:PSYCHIC)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [55, 105, 40, 85, 40, 85]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:PIXILATE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Togetic movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:TOGEKISS,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DRAGON)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:PSYCHIC)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [85, 120, 80, 115, 50, 95]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:PERPETUAL)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:DAZZLING)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:PIXILATE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Togekiss movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:MIMIKYU,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:WATER)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GROUND)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [96, 50, 80, 90, 105, 55]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:DISGUISE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SANDVEIL)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Mimikyu movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:CARBINKSHELL,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ELECTRIC)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:STEEL)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [50, 50, 150, 50, 50, 150]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SHIELDSDOWN)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Carbink-Shell movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:CARBINKCORE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ELECTRIC)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:STEEL)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [50, 100, 50, 150, 100, 50]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SHIELDSDOWN)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Carbink-Core movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:TANDEMAUS,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:PSYCHIC)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:PSYCHIC)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [50, 40, 45, 50, 75, 45]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:COMPOUNDEYES)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:SYMBIOSIS)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:REGENERATOR)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[1,:DOUBLEHIT],[1,:BABYDOLLEYES],[5,:CONFUSION],[8,:ALLYSWITCH],
                      [11,:HIDDENPOWER],[14,:CELLSPLITTER],[18,:SWITCHEROO],[22,:PAINSPLIT],
                      [26,:VACUUMWAVE],[30,:PSYSHOCK],[33,:SKILLSWAP],[37,:AURASPHERE],
                      [41,:RECOVER],[46,:PSYCHIC]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :AERIALACE,:AGILITY,:ALLYSWITCH,:ATTRACT,:AURASPHERE,:BEATUP,:CALMMIND,:CHARGEBEAM,:CHARM,:CONFIDE,:COVET,:CRUNCH,:DIG,:ECHOEDVOICE,:ENCORE,:ENDURE,:ENERGYBALL,:FACADE,:FAKETEARS,:FIREFANG,:FRUSTRATION,:GRASSKNOT,:HELPINGHAND,:HIDDENPOWER,:HONECLAWS,:ICEFANG,:MAGICCOAT,:MAGICROOM,:MAGICALLEAF,:METRONOME,:PAINSPLIT,:PHRENICASSAULT,:PROTECT,:PSYCHIC,:PSYCHICNOISE,:PSYCHICTERRAIN,:PSYSHOCK,:RAINDANCE,:REST,:RETURN,:ROUND,:SCRUTINIZE,:SEEDBOMB,:SHADOWBALL,:SHADOWCLAW,:SKILLSWAP,:SLEEPTALK,:SNORE,:SOULJAVELIN,:SUBSTITUTE,:SUNNYDAY,:SUPERFANG,:SWIFT,:TAUNT,:THIEF,:THUNDERFANG,:THUNDERWAVE,:TRIATTACK,:TRICK,:TRINITYFORCE,:UTURN,:UNSTABLEMATTER,:WONDERROOM,:WORKUP]
      end
	  },
  "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:MAUSHOLD,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:PSYCHIC)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:PSYCHIC)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [75, 65, 70, 75, 111, 74]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:COMPOUNDEYES)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:SYMBIOSIS)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:REGENERATOR)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[1,:FOLLOWME],[1,:CALMMIND],[1,:DOUBLEHIT],[1,:BABYDOLLEYES],
                      [5,:CONFUSION],[8,:ALLYSWITCH],[11,:HIDDENPOWER],[14,:CELLSPLITTER],
                      [18,:SWITCHEROO],[22,:PAINSPLIT],[29,:VACUUMWAVE],[33,:PSYSHOCK],
                      [37,:SKILLSWAP],[41,:AURASPHERE],[46,:RECOVER],[53,:PSYCHIC]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :AERIALACE,:AGILITY,:ALLYSWITCH,:ATTRACT,:AURASPHERE,:BEATUP,:CALMMIND,:CHARGEBEAM,:CHARM,:CONFIDE,:COVET,:CRUNCH,:DIG,:ECHOEDVOICE,:ENCORE,:ENDURE,:ENERGYBALL,:FACADE,:FAKETEARS,:FIREFANG,:FRUSTRATION,:GIGAIMPACT,:GRASSKNOT,:HELPINGHAND,:HIDDENPOWER,:HONECLAWS,:HYPERBEAM,:ICEFANG,:MAGICCOAT,:MAGICROOM,:MAGICALLEAF,:METRONOME,:PAINSPLIT,:PHRENICASSAULT,:PROTECT,:PSYCHIC,:PSYCHICNOISE,:PSYCHICTERRAIN,:PSYSHOCK,:RAINDANCE,:REST,:RETURN,:ROUND,:SCRUTINIZE,:SEEDBOMB,:SHADOWBALL,:SHADOWCLAW,:SKILLSWAP,:SLEEPTALK,:SNORE,:SOULJAVELIN,:SUBSTITUTE,:SUNNYDAY,:SUPERFANG,:SWIFT,:TAUNT,:THIEF,:THUNDERFANG,:THUNDERWAVE,:TRIATTACK,:TRICK,:TRINITYFORCE,:UTURN,:UNSTABLEMATTER,:WONDERROOM,:WORKUP]
      end
	  },
  "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:HELIOPTILE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DARK)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [44, 61, 38, 70, 33, 43]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:STAKEOUT)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:INSOMNIA)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SCAVENGER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Helioptile movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:HELIOLISK,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DARK)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [62, 109, 55, 109, 52, 94]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:STAKEOUT)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:INSOMNIA)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SCAVENGER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Heliolisk movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:BOUNSWEET,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [32, 30, 38, 42, 30, 38]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:POISONPOINT)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:MAJESTY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:LIQUIDOOZE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Bounsweet movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:STEENEE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [62, 40, 48, 52, 40, 48]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:POISONPOINT)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:MAJESTY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:LIQUIDOOZE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Steenee movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:TSAREENA,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [72, 50, 98, 72, 120, 98]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:POISONPOINT)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:MAJESTY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:LIQUIDOOZE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Tsareena movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:NACLI,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:WATER)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:PSYCHIC)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [25, 55, 35, 55, 35, 75]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:PURIFYING)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:RAINDISH)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:CONTRARY)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Nacli movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:NACLSTACK,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:WATER)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:PSYCHIC)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [60, 65, 35, 60, 35, 100]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:PURIFYING)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:RAINDISH)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:CONTRARY)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Naclstack movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:GARGANACL,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:WATER)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:PSYCHIC)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [90, 100, 45, 100, 35, 130]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:PURIFYING)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:RAINDISH)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:CONTRARY)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Garganacl movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:SKIDDO,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ELECTRIC)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ELECTRIC)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [65, 62, 52, 66, 48, 57]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:STATIC)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:INNERFOCUS)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[1,:TACKLE],[1,:CHARGE],[7,:NUZZLE],[9,:TAILWHIP],
                      [12,:ELECTRIFY],[13,:SPARK],[16,:STEALTHROCK],[20,:SPIKYSHIELD],
                      [22,:TRAILBLAZE],[26,:ROCKTOMB],[30,:ZINGZAP],[34,:CURSE],
                      [38,:ROCKSLIDE],[42,:WILDCHARGE],[45,:HORNLEECH],[50,:ELECTRICTERRAIN]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :AERIALACE,:AFTERYOU,:AFTERSHOCK,:ATTRACT,:BATTLECRY,:BODYSLAM,:BOUNCE,:BRICKBREAK,:BULKUP,:BULLDOZE,:CHARGEBEAM,:CHARM,:CONFIDE,:DIG,:DOUBLETEAM,:ELECTRICTERRAIN,:ELECTROBALL,:ENDURE,:FACADE,:FRUSTRATION,:HELPINGHAND,:HIDDENPOWER,:IRONTAIL,:LIGHTSCREEN,:MEGAKICK,:OVERCHARGE,:POWERGEM,:PROTECT,:RAINDANCE,:REFLECT,:REST,:RETURN,:ROAR,:ROCKSLIDE,:ROCKSMASH,:ROCKTOMB,:ROUND,:SAFEGUARD,:SHOCKWAVE,:SLEEPTALK,:SNORE,:SONICSCREAM,:SPEEDSWAP,:STEALTHROCK,:STRENGTH,:SUBSTITUTE,:SUPERCELLSLAM,:SURF,:SWAGGER,:THUNDER,:THUNDERWAVE,:THUNDERBOLT,:TOXIC,:UPROAR,:VOLTSWITCH,:WILDCHARGE,:WORKUP,:ZAPCANNON,:ZENHEADBUTT]
      end
	  },
  "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:GOGOAT,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ELECTRIC)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ELECTRIC)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [100, 97, 68, 123, 62, 81]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:STATIC)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:ELECTROMORPHOSIS)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[0,:ENDURE],[1,:HEADSMASH],[1,:TACKLE],[1,:CHARGE],
                      [1,:NUZZLE],[1,:TAILWHIP],[7,:NUZZLE],[9,:TAILWHIP],
                      [12,:ELECTRIFY],[13,:SPARK],[16,:STEALTHROCK],[20,:SPIKYSHIELD],
                      [22,:TRAILBLAZE],[26,:ROCKTOMB],[30,:ZINGZAP],[34,:CURSE],
                      [40,:ROCKSLIDE],[47,:WILDCHARGE],[55,:HORNLEECH],[58,:ELECTRICTERRAIN]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :AERIALACE,:AFTERYOU,:AFTERSHOCK,:ATTRACT,:BATTLECRY,:BODYSLAM,:BOUNCE,:BRICKBREAK,:BULKUP,:BULLDOZE,:CHARGEBEAM,:CHARM,:CONFIDE,:DIG,:DOUBLETEAM,:EARTHQUAKE,:ELECTRICTERRAIN,:ELECTROBALL,:ENDURE,:FACADE,:FRUSTRATION,:GIGAIMPACT,:HELPINGHAND,:HIDDENPOWER,:HYPERBEAM,:IRONTAIL,:LIGHTSCREEN,:MEGAKICK,:OVERCHARGE,:POWERGEM,:PROTECT,:RAINDANCE,:REFLECT,:REST,:RETURN,:ROAR,:ROCKSLIDE,:ROCKSMASH,:ROCKTOMB,:ROUND,:SAFEGUARD,:SHOCKWAVE,:SLEEPTALK,:SNORE,:SONICSCREAM,:SPEEDSWAP,:STEALTHROCK,:STRENGTH,:SUBSTITUTE,:SUPERCELLSLAM,:SURF,:SWAGGER,:THUNDER,:THUNDERWAVE,:THUNDERBOLT,:TOXIC,:UPROAR,:VOLTSWITCH,:WILDCHARGE,:WORKUP,:ZAPCANNON,:ZENHEADBUTT]
      end
	  },
  "onSetForm"=>proc{|pokemon,form|
      pbSeenForm(pokemon)
  }
})

MultipleForms.register(:SKRELP,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DARK)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ELECTRIC)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [30, 60, 60, 60, 60, 50]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:ILLUMINATE)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:PRESSURE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:ABYSSAL)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Skrelp movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:DRAGALGE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DARK)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ELECTRIC)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [44, 75, 97, 90, 123, 65]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:ILLUMINATE)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:PRESSURE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:ABYSSAL)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Dragalge movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:DEDENNE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ELECTRIC)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ICE)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [67, 81, 67, 101, 58, 57]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:CHEEKPOUCH)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:FLUFFY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SNOWWARNING)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Dedenne movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:CRAMORANT,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ELECTRIC)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [55, 85, 70, 95, 85, 85]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:AFTERLIFE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:RECKLESS)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Cramorant movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:FEEBAS,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [80, 20, 10, 55, 20, 15]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:OBLIVIOUS)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:NOGUARD)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:RUNAWAY)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Feebas movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:MILOTIC,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DRAGON)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [125, 95, 79, 60, 100, 81]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:OBLIVIOUS)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:NOGUARD)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SERENEGRACE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Milotic movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:MOTHIM,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:BUG)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:NORMAL)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [70, 94, 66, 94, 50, 50]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:OVERCOAT)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:FURCOAT)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[0,:BEAUTIFY],[1,:SUCKERPUNCH],[1,:DEFENSECURL],[1,:ROLLOUT],
                      [1,:SILVERWIND],[10,:ROLLOUT],[15,:SILVERWIND],[20,:HEADBUTT],
                      [23,:ENDURE],[26,:SKITTERSMACK],[29,:FACADE],[32,:HEARTSTAMP],
                      [35,:AGILITY],[38,:QUICKATTACK],[41,:AMNESIA],[44,:ZENHEADBUTT],
                      [47,:BODYSLAM],[50,:FLAIL]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :AERIALACE,:AFTERYOU,:AGILITY,:AIRSLASH,:AMNESIA,:ATTRACT,:BODYSLAM,:BUGBITE,:BUGBUZZ,:CHARM,:CONFIDE,:COVET,:DEFOG,:DOUBLETEAM,:DREAMEATER,:DUALWINGBEAT,:ELECTROWEB,:ENDURE,:ENERGYBALL,:FACADE,:FLASH,:FRUSTRATION,:GIGAIMPACT,:HAIL,:HELPINGHAND,:HIDDENPOWER,:HYPERBEAM,:HYPERVOICE,:ICYWIND,:INFESTATION,:IRRITATION,:LEECHLIFE,:MAGICCOAT,:PINMISSILE,:PINCERGRIP,:PROTECT,:PSYCHUP,:RAINDANCE,:REST,:RETRIBUTION,:RETURN,:ROOST,:ROUND,:SAFEGUARD,:SECRETPOWER,:SERAPHSEMBRACE,:SHADOWBALL,:SIGNALBEAM,:SKILLSWAP,:SKITTERSMACK,:SLEEPTALK,:SNORE,:STEELWING,:STRUGGLEBUG,:SUBSTITUTE,:SUCKERPUNCH,:SUNNYDAY,:SWAGGER,:SWIFT,:TAILWIND,:THIEF,:TOXIC,:TRINITYFORCE,:UTURN,:ZENHEADBUTT]
      end
	  },
  "onSetForm"=>proc{|pokemon,form|	      if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:DRILBUR,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ICE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ICE)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [85, 68, 45, 60, 30, 40]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:HYPERCUTTER)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:TOUGHCLAWS)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:DRYSKIN)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Drilbur movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:EXCADRILL,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ICE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:WATER)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [135, 110, 65, 88, 50, 60]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:HYPERCUTTER)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:TOUGHCLAWS)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SWIFTSWIM)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Excadrill movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:VAPOREON,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FLYING)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FLYING)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [95, 65, 60, 130, 65, 110]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:CLOUDNINE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:UNAWARE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Vaporeon movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:JOLTEON,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:STEEL)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:STEEL)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [65, 65, 130, 60, 95, 110]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:HEAVYMETAL)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SPIRITED)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Jolteon movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:FLAREON,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ROCK)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ROCK)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [130, 95, 110, 65, 60, 65]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:STURDY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:GUTS)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Flareon movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:ESPEON,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:BUG)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:BUG)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [110, 60, 130, 65, 95, 65]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:MAGICGUARD)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:DAZZLING)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Espeon movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:UMBREON,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [110, 95, 65, 130, 60, 65]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:TINTEDLENS)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:POISONPOINT)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Umbreon movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:LEAFEON,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GROUND)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GROUND)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [65, 65, 95, 110, 60, 130]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SAPSIPPER)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SANDVEIL)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Leafeon movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:GLACEON,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GHOST)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GHOST)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [130, 110, 60, 95, 65, 65]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:ELDRITCH)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:FROSTPOINT)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Glaceon movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:SYLVEON,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIGHTING)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIGHTING)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [60, 130, 65, 110, 65, 95]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SCRAPPY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:LIMBER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Sylveon movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:WYVEON,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:NORMAL)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:NORMAL)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [65, 130, 95, 65, 110, 60]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:ANTICIPATION)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:FLUFFY)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Wyveon movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:SILICOBRA,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ROCK)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GRASS)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [46, 35, 50, 52, 75, 57]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:BEACON)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:FLOWERVEIL)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:MANAECHOES)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Silicobra movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:SANDACONDA,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ROCK)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GRASS)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [70, 65, 71, 72, 125, 107]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:BEACON)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:FLOWERVEIL)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:MANAECHOES)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Sandaconda movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:LICKITUNG,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GROUND)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GROUND)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [75, 75, 90, 30, 55, 60]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:UNNERVE)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:STALWART)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:WELLBAKEDBODY)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Lickitung movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:LICKILICKY,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GROUND)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GROUND)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [95, 95, 110, 50, 80, 85]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:UNNERVE)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:STALWART)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:WELLBAKEDBODY)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Lickilicky movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:LEDYBA,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:BUG)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GHOST)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [40, 80, 30, 55, 20, 40]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:JUSTIFIED)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:SUPERLUCK)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:IRONFIST)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Ledyba movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:LEDIAN,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:BUG)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GHOST)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [55, 110, 50, 85, 35, 55]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:JUSTIFIED)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:SUPERLUCK)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:IRONFIST)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Ledian movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:GLIGAR,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DARK)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [65, 105, 65, 75, 85, 35]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:BLOODTHIRSTY)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:SPIRITED)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:IMMOLATE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Gligar movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:GLISCOR,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DARK)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [75, 125, 75, 95, 95, 45]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:BLOODTHIRSTY)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:SPIRITED)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:IMMOLATE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Gliscor movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:PINECO,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ROCK)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ROCK)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [35, 65, 90, 35, 15, 50]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:STURDY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:WEAKARMOR)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Pineco movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:FORRETRESS,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ROCK)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIGHTING)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [60, 90, 140, 60, 40, 75]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SKILLLINK)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:BATTLEARMOR)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Forretress movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:SEEDOT,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FLYING)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FLYING)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [30, 40, 30, 50, 40, 30]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:EARLYBIRD)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:WINDRIDER)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:MOODY)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Seedot movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:NUZLEAF,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FLYING)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:WATER)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [60, 60, 40, 70, 70, 40]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:EARLYBIRD)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:WINDRIDER)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:MOODY)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Nuzleaf movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:SHIFTRY,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FLYING)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:WATER)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [90, 80, 60, 100, 90, 60]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:EARLYBIRD)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:WINDRIDER)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:MOODY)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Shiftry movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:FINNEON,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [56, 49, 49, 66, 61, 49]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:FLASHFIRE)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:ILLUMINATE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:MAGMAARMOR)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Finneon movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:LUMINEON,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [76, 69, 69, 91, 86, 69]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:FLASHFIRE)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:ILLUMINATE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:MAGMAARMOR)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Lumineon movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:TYMPOLE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GRASS)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GRASS)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [50, 50, 40, 64, 50, 40]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SWIFTSWIM)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:WATERABSORB)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:HYDRATION)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[1,:ABSORB],[1,:TAILWHIP],[4,:WATERSPORT],[5,:LEECHSEED],
                      [9,:WATERGUN],[12,:MEGADRAIN],[16,:SLUDGE],[20,:AQUARING],
                      [23,:WATERPULSE],[27,:GIGADRAIN],[31,:RAINDANCE],[34,:POISONJAB],
                      [38,:MUDDYWATER],[42,:LEAFSTORM],[45,:SLUDGEBOMB]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :AFTERYOU,:ATTRACT,:BOUNCE,:BULLDOZE,:BULLETSEED,:CONFIDE,:DELUGE,:DIG,:ECHOEDVOICE,:ENDURE,:ENERGYBALL,:FACADE,:FRUSTRATION,:GASTROACID,:GIGADRAIN,:GRASSKNOT,:GUNKSHOT,:HIDDENPOWER,:LOTUSBLOOM,:MAGICCOAT,:MAGICALLEAF,:PAYBACK,:POISONJAB,:POISONSWEEP,:PROTECT,:RAINDANCE,:REST,:RETURN,:ROCKSMASH,:ROUND,:SCREECH,:SECRETPOWER,:SEEDBOMB,:SLASHANDBURN,:SLEEPTALK,:SLUDGEWAVE,:SNORE,:SUBSTITUTE,:TOXIC,:UPROAR,:VENOSHOCK,:VILEMERCY,:WATERPULSE]
      end
	  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:PALPITOAD,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GRASS)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [69, 65, 55, 75, 65, 55]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SWIFTSWIM)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:WATERABSORB)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:NATURALCURE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[1,:ABSORB],[1,:TAILWHIP],[1,:WATERSPORT],[1,:LEECHSEED],
                      [1,:WATERGUN],[5,:LEECHSEED],[9,:WATERGUN],[12,:MEGADRAIN],
                      [16,:SLUDGE],[20,:AQUARING],[23,:WATERPULSE],[28,:GIGADRAIN],
                      [33,:RAINDANCE],[37,:POISONJAB],[42,:MUDDYWATER],[47,:LEAFSTORM],
                      [51,:SLUDGEBOMB]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :AFTERYOU,:ATTRACT,:BATTLECRY,:BOUNCE,:BRICKBREAK,:BULLDOZE,:BULLETSEED,:CONFIDE,:CORROSIVEGAS,:DELUGE,:DIG,:ECHOEDVOICE,:ENDURE,:ENERGYBALL,:EXPLOSION,:FACADE,:FLING,:FRUSTRATION,:GASTROACID,:GIGADRAIN,:GRASSKNOT,:GRASSYTERRAIN,:GUNKSHOT,:HIDDENPOWER,:HYPERVOICE,:KNOCKOFF,:LOTUSBLOOM,:LOWKICK,:MAGICCOAT,:MAGICALLEAF,:MISTYEXPLOSION,:MUDDYWATER,:PAYBACK,:POISONJAB,:POISONSWEEP,:PROTECT,:RAINDANCE,:REST,:RETURN,:ROCKSMASH,:ROUND,:SCREECH,:SECRETPOWER,:SEEDBOMB,:SELFDESTRUCT,:SLASHANDBURN,:SLEEPTALK,:SLUDGEBOMB,:SLUDGEWAVE,:SNORE,:STOMPINGTANTRUM,:STRENGTH,:SUBSTITUTE,:TOXIC,:UPROAR,:VENOSHOCK,:VILEMERCY,:WATERPULSE]
      end
	  },
  "onSetForm"=>proc{|pokemon,form|	      if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:SEISMITOAD,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GRASS)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [74, 85, 75, 105, 95, 75]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SWIFTSWIM)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:WATERABSORB)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:NATURALCURE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[0,:LIQUIDATION],[1,:ABSORB],[1,:TAILWHIP],[1,:WATERSPORT],
                      [1,:GASTROACID],[1,:LEECHSEED],[1,:WATERGUN],[5,:LEECHSEED],
                      [9,:WATERGUN],[12,:MEGADRAIN],[16,:SLUDGE],[20,:AQUARING],
                      [23,:WATERPULSE],[28,:GIGADRAIN],[33,:RAINDANCE],[39,:POISONJAB],
                      [44,:LIQUIDATION],[49,:MUDDYWATER],[53,:LEAFSTORM],[59,:SLUDGEBOMB]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :AFTERYOU,:ATTRACT,:BATTLECRY,:BOUNCE,:BRICKBREAK,:BULLDOZE,:BULLETSEED,:CONFIDE,:CORROSIVEGAS,:DELUGE,:DIG,:DRAINPUNCH,:ECHOEDVOICE,:ENDURE,:ENERGYBALL,:EXPLOSION,:FACADE,:FLING,:FOCUSBLAST,:FRUSTRATION,:GASTROACID,:GIGADRAIN,:GIGAIMPACT,:GRASSKNOT,:GRASSYTERRAIN,:GUNKSHOT,:HIDDENPOWER,:HYPERBEAM,:HYPERVOICE,:ICEPUNCH,:KNOCKOFF,:LIQUIDATION,:LOTUSBLOOM,:LOWKICK,:MAGICCOAT,:MAGICALLEAF,:MEGAKICK,:MEGAPUNCH,:MISTYEXPLOSION,:MUDDYWATER,:PAYBACK,:POISONJAB,:POISONSWEEP,:PROTECT,:RAINDANCE,:REST,:RETURN,:ROCKSMASH,:ROUND,:SCREECH,:SECRETPOWER,:SEEDBOMB,:SELFDESTRUCT,:SLASHANDBURN,:SLEEPTALK,:SLUDGEBOMB,:SLUDGEWAVE,:SNORE,:STOMPINGTANTRUM,:STRENGTH,:SUBSTITUTE,:THUNDERPUNCH,:TOXIC,:UPROAR,:VENOSHOCK,:VILEMERCY,:WATERPULSE]
      end
	  },
  "onSetForm"=>proc{|pokemon,form|	      if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:PIDOVE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:STEEL)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIGHTING)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [50, 55, 50, 36, 30, 43]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:HYPERCUTTER)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:HEAVYMETAL)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:WEAKARMOR)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Pidove movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:TRANQUILL,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:STEEL)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIGHTING)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [62, 77, 65, 50, 42, 62]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:HYPERCUTTER)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:HEAVYMETAL)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:WEAKARMOR)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Tranquill movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:UNFEZANT,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:STEEL)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIGHTING)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [80, 115, 93, 65, 55, 80]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:HYPERCUTTER)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:HEAVYMETAL)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:WEAKARMOR)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Unfezant movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:KLEFKI,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:NORMAL)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:PSYCHIC)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [75, 57, 80, 87, 91, 80]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:POWERSPOT)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:PROTEAN)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Klefki movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:BLIPBUG,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [20, 45, 25, 45, 20, 25]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:HALCYON)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:RUNAWAY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:CUTEINFATUATE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Blipbug movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:DOTTLER,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIGHTING)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [30, 50, 90, 50, 35, 80]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:HALCYON)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:STALWART)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:BATTLEARMOR)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Dottler movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:ORBEETLE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIGHTING)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [45, 90, 120, 80, 60, 110]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:HALCYON)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:STALWART)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:BATTLEARMOR)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Orbeetle movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:SPOINK,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ROCK)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ROCK)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [60, 80, 70, 60, 25, 35]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:ROCKHEAD)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:STURDY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:WEAKARMOR)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Spoink movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:GRUMPIG,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ROCK)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [80, 110, 90, 80, 45, 65]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:ILLUMINATE)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:STURDY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:PRESSURE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Grumpig movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:SCATTERBUG,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:BUG)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:BUG)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [27, 35, 35, 40, 38, 25]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SWARM)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:NATURALCURE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SHEDSKIN)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[1,:TACKLE],[1,:SCARYFACE],[6,:GLARE],[15,:POUNCE]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :IRRITATION,:SCARYFACE,:STRUGGLEBUG]
      end
	  },
  "onSetForm"=>proc{|pokemon,form|	  
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:SPEWPA,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:BUG)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:BUG)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [27, 29, 60, 22, 30, 45]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:OVERCOAT)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SHEDSKIN)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[0,:PROTECT],[1,:RAGE]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :HURRICANE,:IRONDEFENSE,:IRRITATION,:SCARYFACE,:STRUGGLEBUG]
      end
	  },
  "onSetForm"=>proc{|pokemon,form|	  
    if form==1
      pbSeenForm(pokemon)
    end
  }
})


MultipleForms.register(:SALANDIT,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FLYING)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FLYING)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [40, 71, 48, 77, 40, 44]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SAPSIPPER)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:AERILATE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Salandit movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:SALANDITPRIMORDIAL,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FLYING)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [40, 71, 48, 77, 40, 44]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SAPSIPPER)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:AERILATE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Salandit-Primordial movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:SALAZZLE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FLYING)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FLYING)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [60, 111, 68, 117, 60, 64]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SAPSIPPER)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:AERILATE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Salazzle movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:SALAZZLEPRIMORDIAL,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FLYING)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [60, 111, 68, 117, 60, 64]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SAPSIPPER)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:AERILATE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Salazzle-Primordial movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:SLUGMA,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [40, 20, 40, 40, 70, 40]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:CORROSION)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:AFTERMATH)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:LIQUIDOOZE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[1,:CHARGE],[1,:SMOG],[6,:FIRESPIN],[8,:CHARGEBEAM],
                      [13,:MINIMIZE],[15,:SLUDGE],[20,:INCINERATE],[22,:SHOCKWAVE],
                      [27,:VENOSHOCK],[29,:PARABOLICCHARGE],[34,:VOLTSWITCH],[36,:ACIDARMOR],
                      [41,:SLUDGEWAVE],[43,:EXPLOSION],[48,:DISCHARGE],[50,:SHELLSMASH]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :ATTRACT,:BODYSLAM,:CHARGEBEAM,:CONFIDE,:CORROSIVEGAS,:CROSSPOISON,:ELECTROWEB,:ENDURE,:FACADE,:FLASH,:FRUSTRATION,:GASTROACID,:GUNKSHOT,:HIDDENPOWER,:INCINERATE,:INFESTATION,:IRONDEFENSE,:MAGNETRISE,:OVERCHARGE,:PAINSPLIT,:PROTECT,:RAINDANCE,:REST,:RETURN,:ROUND,:SECRETPOWER,:SHOCKWAVE,:SLEEPTALK,:SLUDGEBOMB,:SLUDGEWAVE,:SNORE,:STRENGTH,:SUBSTITUTE,:SUNNYDAY,:THUNDERWAVE,:TOXIC,:TOXICSPIKES,:VENOMDRENCH,:VENOSHOCK,:VOLTSWITCH]
      end
	  },
  "onSetForm"=>proc{|pokemon,form|	      if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:MAGCARGO,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ELECTRIC)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [80, 30, 50, 50, 120, 80]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:CORROSION)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:BATTERY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:REGENERATOR)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    case pokemon.form            # Mystic
    when 1 ; movelist=[[0,:IONDELUGE],[1,:IONDELUGE],[1,:HEATWAVE],[1,:ENERGYBALL],
                      [1,:CHARGE],[1,:SMOG],[1,:FIRESPIN],[1,:CHARGEBEAM],
                      [6,:FIRESPIN],[8,:CHARGEBEAM],[13,:AUTOTOMIZE],[15,:SLUDGE],
                      [20,:FLAMEWHEEL],[22,:SHOCKWAVE],[27,:VENOSHOCK],[29,:PARABOLICCHARGE],
                      [34,:VOLTSWITCH],[36,:ACIDARMOR],[43,:SLUDGEWAVE],[47,:EXPLOSION],
                      [54,:DISCHARGE],[58,:SHELLSMASH]]
    end
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
    "getMoveCompatibility"=>proc{|pokemon|
      next if pokemon.form==0
      movelist=[]
      case pokemon.form
      when 1; movelist=[# TMs
		  :AFTERSHOCK,:ATTRACT,:BODYSLAM,:CHARGEBEAM,:CONFIDE,:CORROSIVEGAS,:CROSSPOISON,:DATASURF,:EARTHQUAKE,:ELECTRICTERRAIN,:ELECTROBALL,:ELECTROWEB,:ENDURE,:ENERGYBALL,:EXPLOSION,:FACADE,:FIRESPIN,:FLASH,:FRUSTRATION,:GASTROACID,:GIGAIMPACT,:GUNKSHOT,:HIDDENPOWER,:HYPERBEAM,:INCINERATE,:INFESTATION,:IRONDEFENSE,:LIGHTSCREEN,:MAGNETRISE,:OVERCHARGE,:OVERHEAT,:PAINSPLIT,:PROTECT,:RAINDANCE,:REFLECT,:REST,:RETURN,:ROCKSMASH,:ROUND,:SECRETPOWER,:SELFDESTRUCT,:SHOCKWAVE,:SLEEPTALK,:SLUDGEBOMB,:SLUDGEWAVE,:SNORE,:STRENGTH,:SUBSTITUTE,:SUNNYDAY,:SUPERCELLSLAM,:THUNDER,:THUNDERWAVE,:THUNDERBOLT,:TOXIC,:TOXICSPIKES,:VENOMDRENCH,:VENOSHOCK,:VOLTSWITCH,:WILDCHARGE,:ZAPCANNON]
      end
	  },
  "onSetForm"=>proc{|pokemon,form|	      if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:GIBLE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ELECTRIC)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FLYING)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [45, 70, 40, 45, 58, 42]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:AIRLOCK)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:INFILTRATOR)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Gible movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:GABITE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ELECTRIC)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FLYING)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [65, 90, 50, 82, 68, 55]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:AIRLOCK)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:INFILTRATOR)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Gabite movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:GARCHOMP,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ELECTRIC)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FLYING)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [95, 130, 80, 102, 108, 85]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:AIRLOCK)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:INFILTRATOR)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Garchomp movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:LARVITAR,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:BUG)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DARK)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [50, 64, 50, 45, 41, 50]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SWARM)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SNIPER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Larvitar movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:PUPITAR,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:BUG)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DARK)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [70, 84, 70, 65, 51, 70]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SWARM)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SNIPER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Pupitar movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:TYRANITAR,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:BUG)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DARK)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [100, 134, 110, 95, 61, 100]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:ADAPTABILITY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SNIPER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Tyranitar movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:DEINO,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ROCK)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GHOST)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [65, 50, 52, 38, 45, 50]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:EARTHEATER)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:ABYSSAL)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Deino movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:ZWEILOUS,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ROCK)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GHOST)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [85, 70, 72, 58, 65, 70]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:EARTHEATER)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:ABYSSAL)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Zweilous movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:HYDREIGON,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ROCK)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GHOST)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [125, 98, 105, 90, 90, 92]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:EARTHEATER)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:ABYSSAL)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Hydreigon movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:DREEPY,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:STEEL)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ICE)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [28, 30, 40, 82, 60, 30]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:KEENEYE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SNOWVEIL)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Dreepy movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:DRAKLOAK,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:STEEL)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ICE)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [68, 50, 60, 102, 80, 50]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:KEENEYE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SNOWVEIL)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Drakloak movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:DRAGAPULT,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:STEEL)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ICE)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [88, 75, 100, 142, 120, 75]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:BEACON)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SNOWVEIL)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Dragapult movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:DRATINI,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [50, 64, 45, 50, 50, 41]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SHEDSKIN)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SYNCHRONIZE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Dratini movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:DRAGONAIR,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [70, 84, 65, 70, 70, 61]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SHEDSKIN)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SYNCHRONIZE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Dragonair movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:DRAGONITE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FAIRY)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:NORMAL)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [100, 134, 100, 80, 95, 91]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:FRIENDGUARD)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:MULTISCALE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Dragonite movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:BAGON,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [30, 75, 45, 60, 50, 40]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SHEDSKIN)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:STRONGJAW)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Bagon movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:SHELGON,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [50, 100, 95, 60, 50, 50]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:SHEDSKIN)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:BATTLEARMOR)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Shelgon movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:SALAMENCE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:POISON)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:PSYCHIC)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [80, 135, 80, 110, 95, 100]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:ARENATRAP)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:STRONGJAW)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Salamence movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:BELDUM,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GRASS)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIGHTING)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [40, 30, 55, 35, 60, 80]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:LEVITATE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SPIRITED)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Beldum movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:METANG,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GRASS)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIGHTING)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [60, 50, 75, 55, 100, 80]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:LEVITATE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SPIRITED)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Metang movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:METAGROSS,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GRASS)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIGHTING)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [90, 70, 95, 80, 135, 130]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:LEVITATE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SPIRITED)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Metagross movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:GOOMY,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [35, 55, 50, 45, 40, 75]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:MAGMAARMOR)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:ROCKYPAYLOAD)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:GOOEY)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Goomy movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:SLIGGOO,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [40, 83, 83, 75, 58, 113]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:MAGMAARMOR)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:ROCKYPAYLOAD)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:GOOEY)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Sliggoo movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:GOODRA,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [70, 110, 100, 90, 80, 150]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:MAGMAARMOR)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:ROCKYPAYLOAD)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:GOOEY)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Goodra movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:JANGMOO,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GRASS)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GRASS)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [65, 45, 45, 45, 55, 45]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:INNERFOCUS)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:HYDRATION)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SERENEGRACE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Jangmo-o movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:HAKAMOO,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GRASS)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:WATER)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [90, 75, 55, 65, 70, 65]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:INNERFOCUS)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:HYDRATION)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SERENEGRACE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Hakamo-o movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:KOMMOO,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GRASS)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:WATER)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [125, 105, 75, 100, 110, 85]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:INNERFOCUS)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:HYDRATION)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SERENEGRACE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Kommo-o movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:FRIGIBAX,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GROUND)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [65, 75, 35, 55, 45, 45]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:MARVELSCALE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SUNBATHE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Frigibax movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:ARCTIBAX,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GROUND)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [90, 95, 45, 66, 62, 65]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:MARVELSCALE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:SUNBATHE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Arctibax movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:BAXCALIBUR,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GROUND)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [115, 145, 75, 92, 86, 87]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:MARVELSCALE)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:HEATSINK)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Baxcalibur movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:YANMA,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DRAGON)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ROCK)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [75, 65, 45, 95, 65, 45]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:ARENATRAP)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:SCAVENGER)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:OWNTEMPO)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Yanma movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:YANMEGA,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DRAGON)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ROCK)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [86, 56, 86, 116, 95, 76]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:ARENATRAP)
    end
    if pokemon.abilityIndex==1 || (pokemon.abilityflag && pokemon.abilityflag==1)
      next getID(PBAbilities,:SCAVENGER)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:OWNTEMPO)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Yanmega movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:POIPOLE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DRAGON)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DRAGON)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [67, 73, 67, 73, 73, 67]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:CLEARBODY)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:MOLDBREAKER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Poipole movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:NAGANADEL,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DRAGON)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:FIRE)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [73, 121, 73, 127, 73, 73]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:FLAMEEATER)
    end
    if pokemon.abilityIndex==2 || (pokemon.abilityflag && pokemon.abilityflag==2)
      next getID(PBAbilities,:TURBOBLAZE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Naganadel movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:ZERAORA,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ICE)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:ICE)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [88, 143, 102, 75, 80, 112]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:DEEPFREEZE)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Zeraora movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:MESPRIT,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GHOST)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GHOST)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [105, 105, 80, 105, 105, 80]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:KEYHOLDER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Mesprit movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:UXIE,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:STEEL)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:STEEL)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [75, 75, 75, 95, 130, 130]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:KEYHOLDER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Uxie movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:AZELF,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:WATER)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:WATER)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [115, 125, 125, 75, 70, 70]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:KEYHOLDER)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Azelf movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:HOOH,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GRASS)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DRAGON)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [106, 130, 154, 110, 90, 90]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:HARVESTMOON)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Ho-Oh movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:LUGIA,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:GROUND)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=1
    next getID(PBTypes,:DRAGON)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=1
    next [106, 90, 110, 90, 130, 154]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=1 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:DUSTDEVIL)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Lugia movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==1
      pbSeenForm(pokemon)
    end
  }
})

MultipleForms.register(:DEOXYS,{
  "type1"=>proc{|pokemon|
    next if pokemon.form!=4
    next getID(PBTypes,:NORMAL)    # Mystic
  },
  "type2"=>proc{|pokemon|
    next if pokemon.form!=4
    next getID(PBTypes,:NORMAL)    # Mystic
  },
  "getBaseStats"=>proc{|pokemon|
    next if pokemon.form!=4
    next [100, 100, 100, 100, 100, 100]   # Mystic
  },
  "ability"=>proc{|pokemon|
    next if pokemon.form!=4 # Only Mystic form
    if pokemon.abilityIndex==0 || (pokemon.abilityflag && pokemon.abilityflag==0)
      next getID(PBAbilities,:MOODY)
    end
  },
  "getMoveList"=>proc{|pokemon|
    next if pokemon.form==0      # Use default moveset for base form
    movelist=[]
    # TODO: Fill Mystic Deoxys movelist as [level,:MOVE] entries
    for i in movelist
      i[1]=getConst(PBMoves,i[1])
    end
    next movelist
  },
  "onSetForm"=>proc{|pokemon,form|
    if form==4
      pbSeenForm(pokemon)
    end
  }
})
