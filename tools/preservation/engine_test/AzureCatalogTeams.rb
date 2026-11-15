module AzureCatalogTeams
  FIELDS=[0,1,2,3,7,9,13,16,18,21,24,26,29,33,34,35,36,37,42,43,47].freeze
  FORMATS=[1,2,3].freeze

  class Trace
    attr_reader :turns,:faints,:switches,:shifts

    def initialize(audit,case_id)
      @audit=audit
      @case_id=case_id
      @turns=0
      @faints=0
      @switches=0
      @shifts=0
      @sent_slots={}
    end

    def line(message)
      message=message.to_s.gsub(/[[:space:]]+/," ").strip
      @turns+=1 if message.start_with?("TURN ")
      @faints+=1 if message.start_with?("FAINT ")
      @shifts+=1 if message.start_with?("SHIFT ")
      if message.start_with?("SEND ")
        slot=message[/\[\d+\]/]
        @switches+=1 if @sent_slots[slot]
        @sent_slots[slot]=true
      end
      @audit.line("TRACE #{@case_id} #{message}")
    end
  end

  def self.party(owner,species,random,original_roster)
    return Array.new(6) do
      id,symbol=species.sample(random: random)
      pokemon=AzureCatalogSpecies.build(id,owner,symbol,0)
      known=pokemon.getMoveList.filter_map do |level,move|
        move if level<=65 && move && move>0 && $pkmn_move[move]
      end.uniq
      # The first seed set reproduces the original audit's type-based roster.
      attacks=known.select { |move| original_roster ? $pkmn_move[move][2]>0 : PBMoveData.get(move).basedamage>0 }
      slots=attacks.sample(2,random: random)
      slots+=known.reject { |move| slots.include?(move) }.sample(2,random: random)
      AzureCatalogSpecies.use_moves(pokemon,slots) if !slots.empty?
      pokemon
    end
  end

  def self.run(audit)
    load File.join(__dir__,"AzureBattleSimulation.rb") unless defined?(AzureBattleSimulation::Battle)
    load File.join(__dir__,"AzureCatalogSpecies.rb") unless defined?(AzureCatalogSpecies::FormBattle)
    pool=audit.catalog(:species,PBSpecies).map { |symbol,id| [id,symbol] }.uniq(&:first)
    original_pool=pool.reject { |id,_symbol| id==PBSpecies::DEOXYS }
    replacement=original_pool.index { |id,_symbol| id==PBSpecies::AGGRON }
    original_pool[replacement]=[PBSpecies::DEOXYS,:DEOXYS] if replacement
    weathers=[0,PBWeather::SUNNYDAY,PBWeather::RAINDANCE,PBWeather::HAIL,PBWeather::SANDSTORM]
    rounds=FIELDS.product(FORMATS).map { |field,active| [field,active,true] }
    rounds.concat([0,1,24,29,37,47].product(FORMATS).map { |field,active| [field,active,false] })
    rounds.each do |field,active,original_roster|
      field_index=FIELDS.index(field)
      seed=(original_roster ? 23000 : 24000)+field_index*3+active
      id="seed-#{seed}"
      audit.check(:team,id,"production-ai") do
        srand(seed)
        random=Random.new(seed)
        AzureCatalogSpecies.reset_field(field)
        player=PokeBattle_Trainer.new("Catalog A",0)
        opponent=PokeBattle_Trainer.new("Catalog B",0)
        $Trainer=player
        [player,opponent].each do |owner|
          owner.define_singleton_method(:skill) { 100 }
          owner.party=party(owner,original_roster ? original_pool : pool,random,original_roster)
        end
        trace=Trace.new(audit,id)
        weather=weathers[(field_index+active)%weathers.size]
        trace.line("CONFIG format=#{active} field=#{field} weather=#{weather}")
        [player,opponent].each do |owner|
          trace.line("TEAM #{owner.name} #{owner.party.map { |mon| "#{mon.species}[#{mon.moves.filter_map { |move| move.id if move.id>0 }.join(',')}]" }.join(' ')}")
        end
        engine,scene=AzureCatalogAudit.with_deadline(15) do
          AzureCatalogSpecies.battle(player,opponent,active,15,weather,report: trace,scripted: false)
        end
        raise "Battle never completed a turn or chose commands" if trace.turns==0 || scene.turn_actions==0
        "format=#{active} field=#{field} weather=#{weather} outcome=#{engine.limit_reached ? 'turn-limit' : engine.decision} " \
          "turns=#{trace.turns} commands=#{scene.turn_actions} faints=#{trace.faints} switches=#{trace.switches} shifts=#{trace.shifts}"
      end
    end
  end
end
