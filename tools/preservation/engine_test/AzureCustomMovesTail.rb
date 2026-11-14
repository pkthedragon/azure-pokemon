module AzureCustomMovesTail
  module Checks
    def custom_tail_roll(percent)
      @battle.define_singleton_method(:pbRandom) do |limit|
        limit==100 ? percent : 1 % limit
      end
    end

    def custom_tail_details(name,power,accuracy,pp)
      data=move(name)
      equal([power,accuracy,pp],[data.basedamage,data.accuracy,data.totalpp])
      data
    end

    def custom_tail_damage(name)
      @foe.damagestate.reset
      move(name).pbCalcDamage(@user,@foe,PokeBattle_Move::NOCRITICAL | PokeBattle_Move::NOWEIGHTING)
    end

    def custom_tail_harsh_sun
      @battle.weather=PBWeather::SUNNYDAY
      @battle.weatherduration=-1
      @battle.field.effects[PBEffects::HarshSunlight]=true
    end
  end

  def self.register(suite)
    AzureAbilityFixture::Scenario.include(Checks)

    suite.test(:GLACIALSLAM) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      slam=custom_tail_details(:GLACIALSLAM,120,80,10)
      assert(PBStuff::PINNINGMOVE.include?(slam.id),"Glacial Slam lost Pinning")
      custom_tail_roll(80)
      equal(0,hit(:GLACIALSLAM))
      equal(@user.totalhp-@user.totalhp/2,@user.hp)
      custom_tail_roll(0)
      assert(hit(:GLACIALSLAM)>0,"Glacial Slam failed an accurate hit")
      equal(PBStatuses::FROZEN,@foe.status)
    end

    suite.test(:TOUGHLOVE) do
      battle(:NONE,:MAGICGUARD,foe_species: :SNORLAX)
      custom_tail_details(:TOUGHLOVE,35,85,15)
      @user.hp=1
      custom_tail_roll(0)
      assert(hit(:TOUGHLOVE)>0,"Tough Love did not hit")
      equal(5,@foe.effects[PBEffects::MultiTurn])
      5.times { round }
      equal(0,@foe.effects[PBEffects::MultiTurn])
      equal(1+5*(@user.totalhp/8),@user.hp)
    end

    suite.test(:FAERIEFIB) do
      battle(:NONE,:NONE)
      assert(move(:FAERIEFIB).isSoundBased?,"Faerie Fib lost its sound flag")
      baseline=custom_tail_damage(:FAERIEFIB)
      @foe.spatk*=2
      assert(custom_tail_damage(:FAERIEFIB)>baseline,"Faerie Fib did not use the target's Special Attack")
    end

    suite.test(:SKYSCRAPER) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      skyscraper=move(:SKYSCRAPER)
      @foe.hp=@foe.totalhp/2
      assert(skyscraper.pbIsCritical?(@user,@foe),"Skyscraper did not crit at half HP")
      @foe.ability=PBAbilities::SHELLARMOR
      assert(!skyscraper.pbIsCritical?(@user,@foe),"Skyscraper bypassed Shell Armor")
      @foe.ability=PBAbilities::BALLFETCH
      @foe.hp=@foe.totalhp/2+1
      assert(!skyscraper.pbIsCritical?(@user,@foe),"Skyscraper crit above half HP")
    end

    suite.test(:SPIRITFIST) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      spirit_fist=move(:SPIRITFIST)
      assert(spirit_fist.pbIsPhysical?(spirit_fist.type) && spirit_fist.isPunchingMove?,
             "Spirit Fist lost its physical punching category")
      @foe.defense=100
      @foe.spdef=100
      baseline=custom_tail_damage(:SPIRITFIST)
      @foe.defense=200
      equal(baseline,custom_tail_damage(:SPIRITFIST))
      @foe.spdef=200
      assert(custom_tail_damage(:SPIRITFIST)<baseline,"Spirit Fist ignored the target's Special Defense")
    end

    suite.test(:BONFIRE) do
      battle(:NONE,:NONE,user_species: :CHARMANDER,ally: :NONE)
      move(:BONFIRE).pbEffect(@user,nil)
      equal(5,@user.pbOwnSide.effects[PBEffects::Bonfire])
      @battle.pbOnActiveOne(@user)
      equal(6,@user.pbOwnSide.effects[PBEffects::Bonfire])
      @user.hp=1
      @ally.hp=1
      round
      equal(1+@user.totalhp/8,@user.hp)
      equal(1+@ally.totalhp/8,@ally.hp)
      equal(5,@user.pbOwnSide.effects[PBEffects::Bonfire])
    end

    suite.test(:HALLUCINATE) do
      battle(:NONE,:NONE)
      custom_tail_details(:HALLUCINATE,80,100,15)
      baseline=custom_tail_damage(:HALLUCINATE)
      @user.spdef*=2
      assert(custom_tail_damage(:HALLUCINATE)>baseline,"Hallucinate did not use the user's Special Defense")
    end

    suite.test(:DISFIGURE) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      custom_tail_roll(0)
      @foe.pbOwnSide.effects[PBEffects::EtherealCloak]=3
      assert(hit(:DISFIGURE)>0,"Disfigure dealt no damage")
      equal(0,@foe.effects[PBEffects::Wounded])
      @foe.pbOwnSide.effects[PBEffects::EtherealCloak]=0
      @foe.hp=@foe.totalhp
      assert(hit(:DISFIGURE)>0,"Disfigure dealt no damage")
      equal(3,@foe.effects[PBEffects::Wounded])
      equal(0,@foe.effects[PBEffects::HealBlock])
    end

    suite.test(:SNUFFOUT) do
      battle(:NONE,:NONE)
      attack=custom_tail_details(:SNUFFOUT,110,70,10)
      custom_tail_roll(99)
      @foe.instance_variable_set(:@totalhp,100)
      @foe.hp=50
      assert(!attack.pbAccuracyCheck(@user,@foe),"Snuff Out cannot miss at exactly half HP")
      @foe.hp=49
      assert(attack.pbAccuracyCheck(@user,@foe),"Snuff Out missed under half HP")
    end

    suite.test(:CALTROPS) do
      battle(:NONE,:NONE)
      hazard=custom_tail_details(:CALTROPS,0,0,20)
      4.times { hazard.pbEffect(@user,nil) }
      equal(3,@foe.pbOwnSide.effects[PBEffects::Caltrops])
      @foe.item=PBItems::HEAVYDUTYBOOTS
      @battle.pbOnActiveOne(@foe)
      equal(0,@foe.effects[PBEffects::Wounded])
      @foe.item=0
      @battle.pbOnActiveOne(@foe)
      equal(3,@foe.effects[PBEffects::Wounded])
    end

    suite.test(:AFTERSHOCK) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      attack=move(:AFTERSHOCK)
      assert(attack.hasHighCriticalRate?,"Aftershock lost its high critical-hit rate")
      custom_tail_roll(0)
      assert(hit(:AFTERSHOCK)>0,"Aftershock did not hit")
      equal(PBStatuses::PARALYSIS,@foe.status)
      hp_after_hit=@foe.hp
      round
      assert(@foe.hp<hp_after_hit,"Aftershock failed to repeat at end of turn")
      equal(0,@foe.effects[PBEffects::Aftershock])
    end

    suite.test(:OVERCHARGE) do
      battle(:NONE,:NONE,foe_species: :SANDSHREW)
      custom_tail_roll(0)
      equal(0,hit(:OVERCHARGE))
      equal(PBStatuses::BURN,@foe.status)
      battle(:NONE,:VOLTABSORB,foe_species: :SNORLAX)
      custom_tail_roll(0)
      equal(0,hit(:OVERCHARGE))
      equal(PBStatuses::BURN,@foe.status)
    end

    suite.test(:LOCUSTSWARM) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      equal(10,custom_tail_details(:LOCUSTSWARM,120,100,10).addlEffect)
      custom_tail_roll(9)
      assert(hit(:LOCUSTSWARM)>0,"Locust Swarm did not hit")
      assert(@user.hp<@user.totalhp,"Locust Swarm did not deal recoil")
      equal(3,@foe.effects[PBEffects::Wounded])
    end

    suite.test(:FRACTURE) do
      battle(:NONE,:NONE)
      fracture=custom_tail_details(:FRACTURE,1,90,15)
      assert(fracture.isSoundBased?,"Fracture lost its sound flag")
      @foe.define_singleton_method(:weight) { 80 }
      equal(120,fracture.pbBaseDamage(1,@user,@foe))
      @foe.define_singleton_method(:weight) { 2000 }
      equal(20,fracture.pbBaseDamage(1,@user,@foe))
    end

    suite.test(:PRESSUREPLATE) do
      battle(:NONE,:NONE)
      damage=move(:TACKLE,@foe).pbCalcDamage(@foe,@user)
      move(:PRESSUREPLATE).pbEffect(@user,nil)
      equal(5,@foe.pbOwnSide.effects[PBEffects::PressurePlate])
      equal(0,@user.pbOwnSide.effects[PBEffects::PressurePlate])
      pp=@foe.moves[0].pp
      @foe.pbReducePP(@foe.moves[0])
      equal(pp-2,@foe.moves[0].pp)
      equal((damage*1.2).round,move(:TACKLE,@foe).pbCalcDamage(@foe,@user))
    end

    suite.test(:STALAGBITE) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      attack=move(:STALAGBITE)
      assert(PBStuff::BITEMOVE.include?(attack.id),"Stalagbite lost its Biting tag")
      rolls=[0,10,9]
      @battle.define_singleton_method(:pbRandom) { |limit| limit==100 ? (rolls.shift || 0) : 1 % limit }
      assert(hit(:STALAGBITE)>0,"Stalagbite did not hit")
      equal(0,@foe.status)
      equal(-1,@foe.stages[PBStats::DEFENSE])
    end

    suite.test(:DEMORALIZE) do
      battle(:NONE,:NONE)
      assert(move(:DEMORALIZE).isSoundBased?,"Demoralize lost its sound flag")
      assert(move(:DEMORALIZE).pbEffect(@user,@foe)>=0,"Demoralize failed")
      equal(PBStatuses::CRUSHED,@foe.status)
    end

    suite.test(:PETRIFY) do
      battle(:NONE,:NONE)
      custom_tail_roll(99)
      assert(hit(:PETRIFY)>0,"Petrify did not hit")
      equal(PBStatuses::PARALYSIS,@foe.status)
    end

    suite.test(:THOUGHTBOMB) do
      battle(:NONE,:NONE)
      bomb=move(:THOUGHTBOMB)
      assert(bomb.hasHighCriticalRate? && PBStuff::BOMBMOVE.include?(bomb.id),
             "Thought Bomb lost Bomb or high critical-hit classification")
    end

    suite.test(:UNWIND) do
      battle(:NONE,:NONE,user_species: :SLOWPOKE,foe_species: :SNORLAX)
      custom_tail_roll(0)
      assert(hit(:UNWIND)>0,"Unwind did not hit")
      assert(!@user.pbHasType?(:PSYCHIC) && @user.pbHasType?(:WATER),"Unwind did not shed Psychic")
      @battle.instance_variable_set(:@turncount,1)
      assert(!@user.pbHasType?(:PSYCHIC),"Psychic typing returned a turn early")
      @battle.instance_variable_set(:@turncount,2)
      assert(@user.pbHasType?(:PSYCHIC),"Psychic typing did not return")
    end

    suite.test(:TRAGICSLIP) do
      battle(:NONE,:NONE,foe_species: :RATTATA)
      equal(20,move(:TRAGICSLIP).pbBaseDamage(1,@user,@foe))
      battle(:NONE,:NONE,foe_species: :WAILORD)
      equal(120,move(:TRAGICSLIP).pbBaseDamage(1,@user,@foe))
    end

    suite.test(:CATNAP) do
      battle(:NONE,:NONE)
      @user.hp=1
      move(:CATNAP).pbEffect(@user,@user)
      equal(1+@user.totalhp*2/3,@user.hp)
      equal(2,@user.effects[PBEffects::Yawn])
    end

    suite.test(:FLAMEBREATH) do
      battle(:NONE,:NONE)
      breath=move(:FLAMEBREATH)
      assert(breath.isContactMove? && breath.pbIsSpecial?(breath.type),"Flame Breath lost special contact")
      assert(breath.pbIsCritical?(@user,@foe),"Flame Breath did not crit")
    end

    suite.test(:TRINITYFORCE) do
      battle(:NONE,:NONE,user_moves: [:TRINITYFORCE,:TACKLE,:PROTECT])
      attack=custom_tail_details(:TRINITYFORCE,90,90,9)
      equal(PBTypes::NORMAL,attack.type)
      assert(PBStuff::LIGHTMOVE.include?(attack.id),"Trinity Force lost Light")
      equal(117,attack.pbBaseDamage(90,@user,@foe))
      equal(30,attack.addlEffect)
      custom_tail_roll(0)
      hit(:TRINITYFORCE)
      assert([PBStatuses::BURN,PBStatuses::FROZEN,PBStatuses::PARALYSIS].include?(@foe.status),
             "Trinity Force did not apply a status")
    end

    suite.test(:JETSTREAM) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      @battle.weather=PBWeather::SANDSTORM
      @battle.weatherduration=4
      @user.pbOwnSide.effects[PBEffects::Tailwind]=3
      custom_tail_roll(0)
      hit(:JETSTREAM)
      round
      equal(4,@battle.weatherduration)
      equal(3,@user.pbOwnSide.effects[PBEffects::Tailwind])
      @user.hp=0
      @user.pbFaint
      equal(0,@battle.pbWeather)
      equal(0,@user.pbOwnSide.effects[PBEffects::Tailwind])

      battle(:NONE,:NONE,foe_species: :SNORLAX)
      custom_tail_roll(0)
      @battle.weather=PBWeather::SANDSTORM
      @battle.weatherduration=4
      hit(:JETSTREAM)
      @battle.weather=PBWeather::SANDSTORM
      @battle.weatherduration=4
      @user.pbOwnSide.effects[PBEffects::Tailwind]=3
      @user.hp=0
      @user.pbFaint
      equal(PBWeather::SANDSTORM,@battle.pbWeather)
      equal(3,@user.pbOwnSide.effects[PBEffects::Tailwind])
    end

    suite.test(:VILEMERCY) do
      battle(:NONE,:NONE)
      custom_tail_roll(0)
      baseline=custom_tail_damage(:TACKLE)
      move(:VILEMERCY).pbEffect(@user,nil)
      equal(4,@battle.field.effects[PBEffects::VileMercy])
      equal((baseline*0.8).floor,custom_tail_damage(:TACKLE))
      round
      equal(PBStatuses::POISON,@user.status)
      equal(PBStatuses::POISON,@foe.status)
    end

    suite.test(:LOTUSBLOOM) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      custom_tail_details(:LOTUSBLOOM,100,100,10)
      custom_tail_roll(0)
      assert(hit(:LOTUSBLOOM)>0,"Lotus Bloom did not hit immediately")
      equal(0,@battle.field.effects[PBEffects::GrassyTerrain])
      @foe.hp=1
      hit(:LOTUSBLOOM)
      equal(5,@battle.field.effects[PBEffects::GrassyTerrain])
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      custom_tail_roll(0)
      custom_tail_harsh_sun
      hit(:LOTUSBLOOM)
      equal(5,@battle.field.effects[PBEffects::GrassyTerrain])
    end

    suite.test(:FOULGAMBIT) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      custom_tail_details(:FOULGAMBIT,85,100,10)
      custom_tail_roll(0)
      @user.hp=1
      hit(:FOULGAMBIT)
      equal(1,@user.hp)
      @foe.hp=10
      hit(:FOULGAMBIT)
      equal(0,@foe.hp)
      equal(11,@user.hp)
    end

    suite.test(:RETRIBUTION) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      custom_tail_roll(0)
      hit(:RETRIBUTION)
      equal(-2,@user.stages[PBStats::ATTACK])
      equal(0,@user.stages[PBStats::SPATK])
    end

    suite.test(:SWELTERINGSTRIKE) do
      battle(:NONE,:NONE,foe_species: :SLOWPOKE)
      attack=custom_tail_details(:SWELTERINGSTRIKE,80,100,10)
      equal(8,attack.pbTypeModWithField(PBTypes::WATER,@user,@foe))
      custom_tail_roll(0)
      assert(hit(:SWELTERINGSTRIKE)>0,"Sweltering Strike did not hit")
      assert(!@foe.pbHasType?(:WATER) && @foe.pbHasType?(:PSYCHIC),"Sweltering Strike did not remove Water")
      @battle.instance_variable_set(:@turncount,2)
      assert(@foe.pbHasType?(:WATER),"Water typing did not return")
    end

    suite.test(:ERGOPROXY) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      @foe.type1=PBTypes::GROUND
      @foe.type2=PBTypes::GROUND
      custom_tail_roll(0)
      assert(hit(:ERGOPROXY)>0,"Ergo Proxy did not deal damage: #{@scene.messages.inspect}")
      assert(@user.pbHasType?(:GROUND) && @foe.pbHasType?(:GHOST),"Ergo Proxy did not exchange typing")
    end

    suite.test(:DUSTBOWL) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      custom_tail_roll(99)
      attack=move(:DUSTBOWL)
      assert(!attack.pbAccuracyCheck(@user,@foe),"Dust Bowl cannot miss outside Sandstorm")
      @battle.weather=PBWeather::SANDSTORM
      @battle.weatherduration=5
      assert(attack.pbAccuracyCheck(@user,@foe),"Dust Bowl missed in Sandstorm")
      custom_tail_roll(9)
      hit(:DUSTBOWL)
      equal(PBMoves::DUSTBOWL,@foe.effects[PBEffects::MultiTurnAttack])
      equal(5,@foe.effects[PBEffects::MultiTurn])
    end

    suite.test(:SUNFURY) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      custom_tail_details(:SUNFURY,85,100,5)
      @user.pbOwnSide.effects[PBEffects::Spikes]=1
      custom_tail_roll(0)
      assert(hit(:SUNFURY)>0,"Sunfury did not strike immediately")
      equal(0,@foe.pbOwnSide.effects[PBEffects::ScorchingGround])
      @foe.hp=@foe.totalhp
      custom_tail_harsh_sun
      assert(hit(:SUNFURY)>0,"Sunfury missed in harsh sunlight")
      equal(5,@foe.pbOwnSide.effects[PBEffects::ScorchingGround])
      equal(1,@user.pbOwnSide.effects[PBEffects::Spikes])
    end

    suite.test(:TALESEND) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      attack=custom_tail_details(:TALESEND,70,100,10)
      tags=[PBStuff::PIERCINGMOVE,PBStuff::SLASHINGMOVE,PBStuff::BLUDGEONINGMOVE]
      assert(tags.all? { |tag| tag.include?(attack.id) },"Tale's End lost a strike tag")
      custom_tail_roll(0)
      @foe.instance_variable_set(:@totalhp,400)
      @foe.hp=400
      damage=move(:TALESEND).pbCalcDamage(@user,@foe)
      @foe.hp=101+damage
      hit(:TALESEND)
      equal(101,@foe.hp)
      @foe.hp=100+damage
      hit(:TALESEND)
      equal(0,@foe.hp)
    end
  end
end
