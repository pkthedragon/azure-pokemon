## Tribute System

Tributes are attunable held items that only affect the holder's inscribed move.
The inscribed move is always move slot 1 in battle.

The active tribute list is:

- `NULLTRIBUTE`
- `MEADOWTRIBUTE`
- `SPLASHTRIBUTE`
- `FLAMETRIBUTE`
- `BLANKTRIBUTE`
- `FISTTRIBUTE`
- `MINDTRIBUTE`
- `ZAPTRIBUTE`
- `ICICLETRIBUTE`
- `DREADTRIBUTE`
- `SPOOKYTRIBUTE`

All tribute items are treated as unlosable while held in battle, and all 11
share the same bag attunement flow from `Scripts/PokemonItemEffects.rb`.

## Tribute Effects

### Null Tribute
- Applies a `1.2x` final damage multiplier to the inscribed damaging move.

### Meadow Tribute
- Applies a `1.3x` multiplier to healing performed by the inscribed move.
- The shared healing helper is used for direct healing, draining, ally healing,
  weather healing, and custom healing moves so Meadow stays consistent.

### Splash Tribute
- After the inscribed damaging move deals damage, the user heals `25%` of the
  damage dealt.
- Liquid Ooze reverses this recovery into damage, matching other drain effects.

### Flame Tribute
- Applies a `1.5x` final damage multiplier to the inscribed damaging move while
  `turncount <= 1`, which means the first turn after entering battle.

### Blank Tribute
- Changes the inscribed move's type to the user's primary type.
- Applies a `1.1x` final damage multiplier to the inscribed damaging move.

### Fist Tribute
- The inscribed damaging move uses Attack plus Attack stage modifiers.
- Also applies a `1.1x` damage multiplier.

### Mind Tribute
- The inscribed damaging move uses Special Attack plus Special Attack stage
  modifiers.
- Also applies a `1.1x` damage multiplier.

### Zap Tribute
- Whenever the inscribed move raises a stat, that stat is raised by one
  additional stage.

### Icicle Tribute
- The inscribed damaging move gets an independent `10%` freeze chance on hit.
- This secondary effect respects common secondary-effect blockers such as
  Sheer Force, Shield Dust, Lucky Chant, Substitutes, and partial hits.

### Dread Tribute
- Whenever the inscribed move lowers a stat, that stat is lowered by one
  additional stage.

### Spooky Tribute
- The inscribed damaging move becomes a two-turn vanish strike.
- Turn 1: the user vanishes and becomes untargetable like Shadow Force.
- Turn 2: the stored attack resolves and gains a `1.5x` damage multiplier.

## Heroic Layer

Heroic forms are an extension layer on top of tributes.

Current heroic implementation:

- `TANGROWTH` + `MEADOWTRIBUTE`
  - Uses form `1`
  - During harsh sunlight, the inscribed healing move heals `2.0x` instead of
    the normal Meadow `1.3x`

The heroic helper functions live in `Scripts/Tributes.rb`:

- `pbIsHeroicPokemon?`
- `pbGetHeroicForm`
- `pbGetHeroicTribute`
- `pbGetHeroicEffect`

## Cleanup Notes

- Legacy one-off tribute items are no longer part of the tribute system.
- Tribute behavior should be implemented through the shared helpers in
  `Scripts/PokeBattle_Move.rb` and the battle-effect hooks that call them.
