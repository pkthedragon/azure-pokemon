module AzureTributeItemCases
  def self.with_choices(*choices)
    original = Kernel.method(:pbMessage)
    Kernel.define_singleton_method(:pbMessage) do |_message, options=nil, *_args|
      if options.is_a?(Array)
        raise "Unexpected Tribute menu" if choices.empty?
        choices.shift
      end
    end
    result = yield
    raise "The Tribute menu did not present all expected choices" unless choices.empty?
    return result
  ensure
    Kernel.define_singleton_method(:pbMessage,original)
  end

  def self.roster(species)
    pokemon = PokeBattle_Pokemon.new(species,30,$Trainer)
    $Trainer.party << pokemon
    return pokemon
  end

  def self.attunement_list
    pbUnlockTributeItem(:NULLTRIBUTE)
    pbUnlockTributeItem(:MEADOWTRIBUTE)
    names, items = pbBuildUnlockedTributeLists(:FLAMETRIBUTE)
    expected = [:FLAMETRIBUTE,:NULLTRIBUTE,:MEADOWTRIBUTE]
    raise "Unexpected unlocked list: #{items.inspect}" if items!=expected
    raise "Missing PBS names or Cancel" if names!=["Flame Tribute","Null Tribute","Meadow Tribute","Cancel"]
    TRIBUTE_ITEMS.each do |item|
      raise "Missing field route for #{item}" unless ItemHandlers::UseFromBag[item] && ItemHandlers::UseOnPokemon[item]
    end
    "all #{TRIBUTE_ITEMS.length} bag and party routes, unlock filtering, and current attunement verified"
  end

  def self.bag_attunement
    pbUnlockTributeItem(:NULLTRIBUTE)
    pbUnlockTributeItem(:MEADOWTRIBUTE)
    $PokemonBag.pbStoreItem(PBItems::NULLTRIBUTE,2)
    result = with_choices(1) { pbUseItem($PokemonBag,PBItems::NULLTRIBUTE) }
    raise "Bag handler did not use the Tribute" if result!=1
    quantities = [PBItems::NULLTRIBUTE,PBItems::MEADOWTRIBUTE].map { |item| $PokemonBag.pbQuantity(item) }
    raise "Attunement converted more than one copy: #{quantities.inspect}" if quantities!=[1,1]
    result = with_choices(2) { pbUseItem($PokemonBag,PBItems::NULLTRIBUTE) }
    raise "Cancel modified the Bag" if result!=0 || $PokemonBag.pbQuantity(PBItems::NULLTRIBUTE)!=1
    $PokemonBag.pbStoreItem(PBItems::MEADOWTRIBUTE,BAGMAXPERSLOT-1)
    result = with_choices(1) { pbUseItem($PokemonBag,PBItems::NULLTRIBUTE) }
    raise "Full destination lost or attuned the original" if result!=0 || $PokemonBag.pbQuantity(PBItems::NULLTRIBUTE)!=1
    "successful attunement converts exactly one copy and cancellation or lack of space preserves it"
  end

  def self.party_attunement
    pokemon = roster(PBSpecies::TANGROWTH)
    pbUnlockTributeItem(:NULLTRIBUTE)
    pbUnlockTributeItem(:MEADOWTRIBUTE)
    $PokemonBag.pbStoreItem(PBItems::NULLTRIBUTE)
    pokemon.setItem(:FLAMETRIBUTE)
    result = with_choices(1) { pbUseItemOnPokemon(PBItems::NULLTRIBUTE,pokemon,nil) }
    raise "Party item use did not attune the bag copy" unless result && $PokemonBag.pbQuantity(PBItems::MEADOWTRIBUTE)==1
    raise "Party item use changed the holder" if pokemon.item!=PBItems::FLAMETRIBUTE
    result = with_choices(2) { pbUseTribute(pokemon.item,pokemon,true) }
    raise "Held attunement failed" unless result && pokemon.item==PBItems::MEADOWTRIBUTE
    result = with_choices(0) { pbUseTribute(pokemon.item,pokemon,true) }
    raise "Held Tribute could not attune back" unless result && pokemon.item==PBItems::NULLTRIBUTE
    raise "Held attunement changed bag copies" if $PokemonBag.pbQuantity(PBItems::MEADOWTRIBUTE)!=1
    "party bag use targets the bag copy, while Attune Tribute changes the held copy"
  end

  def self.draco_assign
    pokemon = roster(PBSpecies::EEVEE)
    pokemon.moves = [PBMove.new(PBMoves::TACKLE),PBMove.new(0),PBMove.new(0),PBMove.new(0)]
    relearnable = pbGetRelearnableMoves(pokemon)
    raise "Missing relearnable fixture moves" if relearnable.empty?
    $PokemonBag.pbStoreItem(PBItems::DRACOTRIBUTE)
    original = PokemonScreen_Scene.instance_method(:pbChoosePokemon)
    PokemonScreen_Scene.define_method(:pbChoosePokemon) { 0 }
    result = with_choices(0,0) { pbUseItem($PokemonBag,PBItems::DRACOTRIBUTE) }
    raise "Bag selector failed to assign reusable Draco move" if result!=1 || pokemon.tributeDracoMove!=relearnable.first
    raise "Assigning altered the base move or consumed the item" if pokemon.moves.first.id!=PBMoves::TACKLE || !$PokemonBag.pbHasItem?(PBItems::DRACOTRIBUTE)
    pokemon.tributeDracoPP = 2
    pokemon.setItem(:DRACOTRIBUTE)
    result = with_choices(0,relearnable.length) { pbUseTribute(pokemon.item,pokemon,true) }
    raise "Held selector failed to clear the move and its PP" unless result && pokemon.tributeDracoMove==0 && pokemon.tributeDracoPP.nil?
    "actual party selector opens and closes, assignment keeps the original slot, and clearing resets stored PP"
  ensure
    PokemonScreen_Scene.define_method(:pbChoosePokemon,original) if original
  end

  def self.migration
    $game_system.remove_instance_variable(:@azure_tribute_item_ids)
    tangrowth = roster(PBSpecies::TANGROWTH)
    mismagius = roster(PBSpecies::MISMAGIUS)
    old_meadow = 1036
    old_spooky = 1037
    tangrowth.item = old_meadow
    mismagius.item = old_spooky
    $Trainer.party.delete(mismagius)
    $PokemonStorage[0,0] = mismagius
    $PokemonBag.pbStoreItem(PBItems::MEADOWTRIBUTE)
    $PokemonBag.pockets[6] << [old_meadow,2]
    $PokemonGlobal.pcItemStorage = PCItemStorage.new
    $PokemonGlobal.pcItemStorage.items << [old_spooky,3]
    load_screen = PokemonLoad.new(nil)
    2.times { load_screen.pbMigrateTributeItems }
    raise "Party or boxed held item lost" if tangrowth.item!=PBItems::MEADOWTRIBUTE || mismagius.item!=PBItems::SPOOKYTRIBUTE
    raise "Legacy bag or PC quantities changed" if $PokemonBag.pbQuantity(PBItems::MEADOWTRIBUTE)!=3 ||
      $PokemonGlobal.pcItemStorage.pbQuantity(PBItems::SPOOKYTRIBUTE)!=3
    raise "Legacy ownership did not unlock attunements" unless pbTributeUnlockedItem?(:MEADOWTRIBUTE) && pbTributeUnlockedItem?(:SPOOKYTRIBUTE)
    raise "Retired Tribute rows are still compiled" if PBItemData.try_get(old_meadow) || PBItemData.try_get(old_spooky)
    "idempotent migration preserves held items, Bag and PC quantities, and ownership of former attunements"
  end

  def self.run(audit)
    [:attunement_list,:bag_attunement,:party_attunement,:draco_assign,:migration].each do |test|
      audit.check(:tribute,:INVENTORY,test) do
        AzureAbilityFixture.setup_new_game
        public_send(test)
      end
    end
  end
end
