module AzureCustomMoveRegression
  # Type, power, accuracy, PP, category, priority from the move specification.
  EXPECTED={
    DRAGONJAUNT: [:DRAGON,50,100,10,0,2],
    MISTYSTEP: [:FAIRY,60,0,15,1,0],
    BREAKDOWN: [:DARK,80,100,15,1,0],
    SOULSIPHON: [:GHOST,80,100,5,1,0],
    PYRETICRITUAL: [:FIRE,80,100,5,1,0],
    BINDINGWORD: [:NORMAL,35,100,15,1,0],
    NIGHTFALL: [:DARK,65,100,20,0,0],
    GLACIALSTATE: [:ICE,80,100,10,0,-6],
    BOAST: [:DARK,90,100,10,1,0],
    ABSOLUTEZERO: [:ICE,100,90,5,0,0],
    THAUMATURGY: [:GRASS,80,100,10,1,0],
    RIPTIDE: [:WATER,100,80,10,0,0],
    CATHARSIS: [:FIGHTING,140,100,5,1,0],
    SCAPESHIFT: [:GRASS,1,90,5,1,0],
    STOKE: [:FIRE,90,100,10,0,0],
    ESSENCEFEED: [:GHOST,30,100,15,1,0],
    SHADOWBOX: [:GHOST,80,100,10,0,0],
    PERFORATE: [:GHOST,120,100,10,0,0],
    COLDVEIN: [:ICE,0,90,15,2,0],
    SLEETSTORM: [:ICE,80,100,15,1,0],
    SERAPHSEMBRACE: [:FAIRY,110,85,10,0,0],
    LITHOFORM: [:ROCK,110,85,10,1,0],
    RELICSHOT: [:ROCK,50,90,20,1,0],
    WINDVORTEX: [:FLYING,40,100,20,1,1],
    SONICSCREAM: [:FLYING,90,90,10,1,0],
    BATTLECRY: [:FIGHTING,60,100,20,1,0],
    SOULJAVELIN: [:FIGHTING,25,90,15,1,0],
    DELUGE: [:WATER,60,100,10,0,-4],
    TORPEDO: [:WATER,65,95,15,0,0],
    MAGMADRIFT: [:FIRE,90,100,15,1,0],
    BIORHYTHM: [:GRASS,150,100,5,0,0],
    SLASHANDBURN: [:GRASS,90,90,10,0,0],
    MASSHYSTERIA: [:PSYCHIC,110,100,10,0,0],
    UNSTABLEMATTER: [:PSYCHIC,150,100,20,1,-3],
    POISONSWEEP: [:POISON,50,100,10,0,0],
    EVISCERATE: [:DARK,100,80,10,0,0],
    PESTER: [:BUG,45,100,25,0,0],
    IRRITATION: [:BUG,60,100,10,0,0],
    DUNEDEFENSE: [:GROUND,0,100,10,2,0],
    BELLOW: [:DRAGON,60,100,5,1,0],
    RANCOR: [:DRAGON,50,90,10,0,0],
    STARDESTROYER: [:STEEL,130,90,5,1,0],
    SCRUTINIZE: [:PSYCHIC,60,100,20,1,0],
    PINCERGRIP: [:BUG,40,100,20,0,1],
    FLASHFREEZE: [:ICE,70,0,15,0,0],
    CONDESCEND: [:FAIRY,65,100,15,0,0],
    ROCKYVERDICT: [:ROCK,75,90,15,0,0],
    SHOWSTOPPER: [:FIGHTING,80,100,10,0,0],
    VILETOUCH: [:POISON,70,100,15,0,0],
    PYROCLASM: [:FIRE,75,100,10,1,0],
    NATURESCALL: [:GRASS,70,100,20,1,0],
    STORMHOLD: [:ELECTRIC,0,0,20,2,2],
    SWANDIVE: [:PSYCHIC,0,0,10,2,0],
    CURTAINSCALL: [:GHOST,25,90,10,0,0],
    BEAUTIFY: [:NORMAL,0,0,10,2,0],
    CELLSPLITTER: [:PSYCHIC,20,100,10,1,0],
    ELECTROGENESIS: [:ELECTRIC,0,0,5,2,0],
    REBUILD: [:GROUND,0,0,5,2,0],
    MOONRISE: [:FAIRY,0,0,5,2,0],
    LUCKYSTAR: [:BUG,18,0,10,0,0],
    STRATOSPHERE: [:FLYING,0,0,5,2,0],
    SPRITZ: [:FAIRY,20,100,15,0,2],
    SWEETTOOTH: [:FAIRY,80,100,10,0,0],
    MIRACLE: [:FAIRY,0,0,5,2,4],
    SLOBBER: [:NORMAL,60,90,15,0,0],
    BRAINSTORM: [:PSYCHIC,130,100,5,1,0],
    REDSUNSZENITH: [:PSYCHIC,100,100,5,1,0],
    BLUESHIFT: [:BUG,0,0,5,2,1],
    CORALBURST: [:WATER,80,100,10,1,0],
    CIRCADIANRRHYTHM: [:GROUND,0,0,5,2,0],
    NEEDLEBLAST: [:GRASS,15,100,20,1,0],
    ETHEREALCLOAK: [:POISON,0,0,5,2,0],
    KISSOFDEATH: [:FAIRY,40,100,5,0,0],
    CLOUDKILL: [:FLYING,80,100,10,0,0],
    RITEOFSPRING: [:GRASS,0,0,5,2,0],
    SLOUGHRAY: [:STEEL,90,100,5,1,0],
    TIDALSCOUR: [:WATER,100,100,5,0,0],
    ABRADINGGALE: [:FLYING,100,80,5,1,0],
    NEUROTOXIN: [:POISON,70,100,10,1,0],
    CALMINGWAKE: [:WATER,150,100,5,0,-3],
    REFRACTINGSTRIKE: [:FIRE,80,100,10,0,0],
    MOLTENSTANCE: [:FIRE,0,0,10,2,2],
    PIERCETHEVEIL: [:DARK,60,100,10,0,0],
    PESTILENCE: [:BUG,60,100,10,0,0],
    FERTILIZE: [:POISON,0,0,5,2,0],
    HORIZONFOCUS: [:FLYING,80,100,10,1,0],
    SHELLSHOCK: [:WATER,60,90,10,1,-6],
    FLAMEWREATH: [:FIRE,70,100,10,0,0],
    MYSTICHARVEST: [:GRASS,0,0,10,2,0],
    MUDBATH: [:GROUND,0,0,5,2,0],
    THREEFOLDSTRIKE: [:STEEL,30,90,10,nil,0],
    NATURALORDER: [:GRASS,80,100,10,0,0],
    FIERYIMPULSE: [:FIRE,0,0,10,2,0],
    TIDEBREAK: [:WATER,90,90,10,0,0],
    CLEANCUT: [:NORMAL,100,100,10,0,0],
    DISHEARTEN: [:GHOST,85,100,10,0,0],
    EPHEMERATE: [:PSYCHIC,0,100,5,2,0],
    ANTICLINE: [:GROUND,80,100,10,0,0],
    FOREBODE: [:PSYCHIC,60,100,5,1,3],
    CARAPACESHOT: [:BUG,80,100,10,1,0],
    BLINDINGASSAULT: [:NORMAL,40,100,5,0,1],
    EQUINOXHORN: [:NORMAL,85,100,10,0,0],
    BARRELBURST: [:WATER,120,100,5,1,0],
    DOUBLEDOSE: [:POISON,0,0,5,2,0],
    GLACIALSLAM: [:ICE,120,80,10,0,0],
    TOUGHLOVE: [:FAIRY,35,85,15,0,0],
    FAERIEFIB: [:FAIRY,90,100,10,1,0],
    SKYSCRAPER: [:FLYING,70,100,10,0,0],
    SPIRITFIST: [:FIGHTING,80,100,10,0,0],
    BONFIRE: [:FIRE,0,0,15,2,0],
    HALLUCINATE: [:PSYCHIC,80,100,15,1,0],
    DISFIGURE: [:POISON,90,90,10,0,0],
    SNUFFOUT: [:DARK,110,70,10,1,0],
    CALTROPS: [:DARK,0,0,20,2,0],
    AFTERSHOCK: [:ELECTRIC,60,90,10,0,0],
    OVERCHARGE: [:ELECTRIC,85,95,10,0,0],
    LOCUSTSWARM: [:BUG,120,100,10,1,0],
    FRACTURE: [:GROUND,1,90,15,1,0],
    PRESSUREPLATE: [:GROUND,0,0,10,2,0],
    STALAGBITE: [:ROCK,65,100,15,0,0],
    DEMORALIZE: [:DARK,0,0,10,2,0],
    UNDERTOW: [:WATER,0,0,10,2,0],
    PETRIFY: [:ROCK,20,100,10,1,0],
    THOUGHTBOMB: [:PSYCHIC,100,80,5,1,0],
    UNWIND: [:PSYCHIC,130,100,5,0,0],
    TRAGICSLIP: [:DARK,1,100,10,0,0],
    CATNAP: [:NORMAL,0,0,5,2,0],
    FLAMEBREATH: [:FIRE,60,90,10,1,0],
    TRINITYFORCE: [:NORMAL,90,90,9,1,0],
    ECHOPLASM: [:GHOST,110,100,5,1,0],
    JETSTREAM: [:FLYING,90,90,10,1,0],
    VILEMERCY: [:POISON,0,0,5,2,0],
    LOTUSBLOOM: [:GRASS,100,100,10,1,0],
    FOULGAMBIT: [:DARK,85,100,10,1,0],
    RETRIBUTION: [:NORMAL,130,90,5,0,0],
    INQUISITION: [:DRAGON,0,0,5,2,1],
    DATAMINE: [:ELECTRIC,80,100,10,nil,0],
    SWELTERINGSTRIKE: [:WATER,80,100,10,0,0],
    ERGOPROXY: [:GHOST,85,100,10,0,0],
    DUSTBOWL: [:GROUND,110,70,5,1,0],
    SUNFURY: [:FIRE,85,100,5,0,0],
    TALESEND: [:STEEL,70,100,10,0,0]
  }.freeze

  def self.run(source)
    $data_system=pbLoadRxData("Data/System")
    $mapinfos=pbCachedRxData("Data/MapInfos")
    $game_system=Game_System.new
    pbLoadAzureRuntimeData
    PBDebug.define_singleton_method(:logonerr) { |&block| block.call }
    $INTERNAL=false
    suite=AzureMoveRegression::Matrix.new
    %w[AzureCustomMovesNew AzureCustomMovesEarly AzureCustomMovesMiddle AzureCustomMovesTail
       AzureCustomMovesEarlyAdditional AzureCustomMovesMiddleAdditional AzureCustomMovesTailAdditional].each do |name|
      load File.join(source,name+".rb")
      Object.const_get(name).register(suite)
    end
    extra=suite.cases.keys-EXPECTED.keys
    missing=EXPECTED.keys-suite.cases.keys
    raise "Unexpected move cases: #{extra.join(', ')}" unless extra.empty?
    raise "Missing move cases: #{missing.join(', ')}" unless missing.empty?
    raise "Dimension Door must remain unavailable" if PBMoveData.exists?(:DIMENSIONDOOR)
    File.open(ENV.fetch("AZURE_BATTLE_SIMULATION_REPORT"),"wb") do |file|
      file.sync=true
      failures=EXPECTED.sum do |name,(type,power,accuracy,pp,category,priority)|
        AzureMoveRegression.run_case(file,name) do
          data=PBMoveData.get(name)
          actual=[data.type,data.basedamage,data.accuracy,data.totalpp,data.category,data.priority]
          expected=[PBTypes.const_get(type),power,accuracy,pp,category || data.category,priority]
          raise "Move data expected #{expected.inspect}, got #{actual.inspect}" unless actual==expected
          fixture=AzureAbilityFixture::Scenario.new
          fixture.battle(:NONE,:NONE)
          attack=fixture.move(name)
          raise "Missing battle executor" if attack.is_a?(PokeBattle_UnimplementedMove)
          fixture.instance_exec(&suite.cases.fetch(name))
        end
      end
      result=failures==0 ? "PASS" : "FAIL"
      file.puts("result=#{result} moves=#{EXPECTED.length} effect_cases=#{suite.cases.length} passed=#{EXPECTED.length-failures} failed=#{failures}")
    end
  end
end
