module AzureCatalogTributes
  class Scenario < AzureAbilityFixture::Scenario
    attr_reader :user, :foe, :ally, :foe_ally, :outer_ally, :outer_foe, :scene

    def configure(item,species,move,form: 0,format: :single,foe_species: :EEVEE,
                  foe_move: :CELEBRATE,other_move: :CELEBRATE)
      battle(:NONE,:NONE,user_species: species,user_moves: [move,other_move].uniq,
        foe_species: foe_species,foe_moves: [foe_move],
        ally: (:NONE if format!=:single),foe_ally: (:NONE if format!=:single),
        outer_ally: (:NONE if format==:triple),outer_foe: (:NONE if format==:triple))
      pokemon=@user.pokemon
      pokemon.setItem(item) if item
      pokemon.form=form if pokemon.form!=form
      pokemon.hp=pokemon.totalhp
      @user.pbInitialize(pokemon,@user.pokemonIndex,false)
      @battle.eachActiveBattlerIndex do |index|
        battler=@battle.battlers[index]
        battler.turncount=0
        battler.define_singleton_method(:pbWait) { |_frames| }
        next if [@user,@foe].include?(battler)
        battler.moves[0]=self.move(:CELEBRATE,battler)
      end
      @battle.define_singleton_method(:pbWait) { |_frames| }
      @scene.define_singleton_method(:partyBetweenKO1) { |_opposing=true| }
      @user.moves[0]
    end

    def battle_state
      @battle
    end

    def equip(item,battler=@user)
      battler.pokemon.setItem(item || 0)
      battler.item=battler.pokemon.item
    end

    def strike(user=@user,target=@foe)
      attack=user.moves[0]
      @battle.lastMoveUsed=attack.id
      @battle.lastMoveUser=user.index
      target.damagestate.reset
      user.grazed=false
      target.moldbroken=false
      effects=[]
      effects[PBEffects::TotalDamage]=0
      user.pbProcessMoveAgainstTarget(attack,user,target,1,effects,false,[target.index],false)
      return target.damagestate.hplost
    end

    def move_stat_source(attack=@user.moves[0])
      @battle.pbWithStatChangeSource([:move,attack.id]) { yield }
    end

    def attack_turn(move_symbol=nil)
      @battle.eachActiveBattlerIndex do |index|
        battler=@battle.battlers[index]
        next if battler.isFainted?
        slot=move_symbol && battler==@user ? battler.moves.index { |move| move && move.id==PBMoves.const_get(move_symbol) } : 0
        assert(slot && @battle.pbRegisterMove(index,slot,false),"Could not register #{battler.name}'s move in slot #{slot}")
        target=index.even? ? @foe : @user
        @battle.pbRegisterTarget(index,target.index)
      end
      @battle.pbAttackPhase
    end

    def advance_round
      @battle.pbEndOfRoundWithStall if @battle.decision==0
      @battle.instance_variable_set(:@turncount,@battle.turncount+1)
    end
  end

  def self.probe(audit,name,route)
    audit.check(:tribute,name,route) do
      Graphics.update
      AzureAbilityFixture.setup_new_game
      srand(146_001)
      yield Scenario.new
    end
  end

  def self.run(audit)
    %w[AzureTributeCoreCases AzureTributeItemCases AzureTributeLifecycleCases AzureTributeChargeCases AzureTributeAICases].each do |suite|
      load File.join(__dir__,"#{suite}.rb")
      Object.const_get(suite,false).run(audit)
    end
  end
end
