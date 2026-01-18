# Heroic Pokemon Implementation Guide

## Overview
Heroic Pokemon are special Pokemon that gain enhanced effects when holding specific tribute items. Each tribute has approximately 5 heroic Pokemon associated with it. When a heroic Pokemon holds its designated tribute, it:
1. Changes to a unique cosmetic form
2. Gains an enhanced version of the tribute's effect

## Current Implementation

### Heroic Tangrowth (Meadow Tribute)
**Location**: `Scripts/Tributes.rb` - HEROIC_POKEMON hash

**Effect**: When Heroic Tangrowth holds Meadow Tribute, healing moves gain 2x multiplier during harsh sunlight (instead of the standard 1.3x Meadow Tribute multiplier)

**Form**: Uses form 1 (defined in `Scripts/PokemonMultipleForms.rb`)

**Boss Battle**: Defined in `Scripts/BossInfo.rb` as `:HEROICTANGROWTH` and `:HEROICTANGROWTH_INTENSE`

## How to Add New Heroic Pokemon

### Step 1: Add to HEROIC_POKEMON Hash
Edit `Scripts/Tributes.rb` and add your Pokemon to the appropriate tribute:

```ruby
HEROIC_POKEMON = {
  :MEADOWTRIBUTE => {
    :TANGROWTH => {
      :form => 1,
      :description => "Healing becomes 2x during harsh sunlight instead of 1.3x",
      :effect => proc { |pokemon, battle|
        next {} if !battle
        if battle.pbWeather == PBWeather::SUNNYDAY
          next { :healing_multiplier => 2.0 }
        end
        next {}
      }
    },
    :NEWPOKEMON => {
      :form => 1,  # or whatever form number you want
      :description => "Brief description of the unique effect",
      :effect => proc { |pokemon, battle|
        # Your custom effect logic here
        # Return a hash with effect modifiers
        # Common modifiers:
        # - :healing_multiplier => Float (for healing moves)
        # - :damage_multiplier => Float (for damage-based tributes)
        # - :additional_effect => true/false (for special effects)
        # - :duration_boost => Integer (for time-based effects)
        next {}
      }
    }
  }
}
```

### Step 2: Register Form Change
Edit `Scripts/PokemonMultipleForms.rb` and register the form change:

```ruby
MultipleForms.register(:NEWPOKEMON,{
    "getForm"=>proc{|pokemon|
      # Heroic form check
      heroic_form = pbGetHeroicForm(pokemon) if defined?(pbGetHeroicForm)
      next heroic_form if heroic_form
      next 0  # Normal form
    },
    # Add ability changes if needed
    "ability"=>proc{|pokemon|
      next if pokemon.form==0 # Normal
      # Your custom ability for heroic form
      next getID(PBAbilities,:YOURABILITYHHERE)
    }
})
```

### Step 3: Implement Custom Effects

#### For Healing-Based Effects
The `apply_tribute_healing` function in `Scripts/PokeBattle_Move.rb` automatically handles heroic healing effects. Just set `:healing_multiplier` in your effect proc.

Example:
```ruby
:effect => proc { |pokemon, battle|
  # Double healing during rain
  if battle.pbWeather == PBWeather::RAINDANCE
    next { :healing_multiplier => 2.6 }  # 2x standard tribute effect
  end
  next {}
}
```

#### For Damage-Based Effects
For tributes like Flame Tribute or Splash Tribute that affect damage, add similar logic in `Scripts/PokeBattle_Move.rb`:

```ruby
def apply_tribute_damage(attacker, damage)
  return damage if !attacker || damage <= 0

  # Check for heroic effect
  if defined?(pbGetHeroicEffect)
    heroic_effect = pbGetHeroicEffect(attacker, @battle)
    if heroic_effect && heroic_effect[:damage_multiplier]
      return (damage * heroic_effect[:damage_multiplier]).floor
    end
  end

  return damage
end
```

#### For Special Effects
For unique effects that don't fit standard multipliers, check the heroic effect directly:

```ruby
# In your move effect code
if defined?(pbGetHeroicEffect)
  heroic_effect = pbGetHeroicEffect(attacker, @battle)
  if heroic_effect[:your_custom_flag]
    # Implement your custom effect
  end
end
```

### Step 4: Create Graphics (Optional)
If you want a visual change for the heroic form:
1. Create sprite files in `Graphics/Battlers/` and `Graphics/Characters/`
2. Name them according to form number (e.g., `001_1.png` for Bulbasaur form 1)

### Step 5: Add Boss Battle (Optional)
If your heroic Pokemon should appear as a boss, edit `Scripts/BossInfo.rb`:

```ruby
:HEROICNEWPOKEMON => {
    :name => "Heroic NewPokemon",
    :entryText => "The guardian NewPokemon attacks!",
    :shieldCount => 1,
    :immunities => {},
    :capturable => false,
    :moninfo => {
        :species => PBSpecies::NEWPOKEMON,
        :level => 22,
        :form => 1,  # Your heroic form
        :item => PBItems::YOURTRIBUTE,
        :moves => [...],
        :ability => PBAbilities::YOURABILITY,
        # ... other details
    },
    # ... rest of boss configuration
}
```

## Helper Functions

### Checking Heroic Status
```ruby
pbIsHeroicPokemon?(pokemon)  # Returns true if Pokemon is in heroic form
pbGetHeroicForm(pokemon)     # Returns form number, or nil
pbGetHeroicTribute(pokemon)  # Returns tribute symbol, or nil
pbGetHeroicEffect(pokemon, battle)  # Returns effect hash
```

### Available Effect Modifiers
- `:healing_multiplier` - Multiplier for healing moves (Float)
- `:damage_multiplier` - Multiplier for damage (Float)
- `:duration_boost` - Additional turns for time-based effects (Integer)
- `:cure_status` - Whether to cure status conditions (Boolean)
- Custom keys - Add your own as needed

## Example: Hypothetical Heroic Venusaur

```ruby
# In Scripts/Tributes.rb
:MEADOWTRIBUTE => {
  # ... existing entries ...
  :VENUSAUR => {
    :form => 1,
    :description => "Healing moves also cure the status of the ally",
    :effect => proc { |pokemon, battle|
      # This Pokemon's effect is handled specially in move code
      next { :cure_ally_status => true }
    }
  }
}

# In Scripts/PokemonMultipleForms.rb
MultipleForms.register(:VENUSAUR,{
    "getForm"=>proc{|pokemon|
      heroic_form = pbGetHeroicForm(pokemon) if defined?(pbGetHeroicForm)
      next heroic_form if heroic_form
      next 0
    }
})

# In move effect code for healing moves
if defined?(pbGetHeroicEffect)
  heroic_effect = pbGetHeroicEffect(attacker, @battle)
  if heroic_effect[:cure_ally_status] && !attacker.pbPartner.isFainted?
    attacker.pbPartner.status = 0
    attacker.pbPartner.statusCount = 0
    @battle.pbDisplay(_INTL("{1}'s ally was cured!",attacker.pbThis))
  end
end
```

## Existing Heroic Pokemon Implementations

### Meadow Tribute
1. **Tangrowth** (Form 1) - 2x healing during harsh sunlight
2. [Add more here as implemented]

### Other Tributes
[To be implemented - each tribute should have ~5 heroic Pokemon]

## Notes
- The healing implementation in `PokeBattle_MoveEffects.rb` has been updated for key moves
- To update additional healing moves, replace `if tribute_has?(attacker, :MEADOWTRIBUTE)` with `hpgain = apply_tribute_healing(attacker, hpgain) if defined?(apply_tribute_healing)`
- The system is designed to be easily extensible - just add to the HEROIC_POKEMON hash
- Heroic forms are cosmetic only unless you explicitly add ability changes
- Test thoroughly with different weather conditions and battle scenarios
