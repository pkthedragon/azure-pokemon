# Rejuvenation-to-Azure modernization matrix

## Objective

Port the authoring and runtime improvements that make Rejuvenation easier to
develop and faster to run without replacing Azure's game rules, content,
numeric IDs, event interfaces, or save format. Rejuvenation is a reference
implementation, not a drop-in base-script replacement.

The comparison source is the extracted Rejuvenation 14 script tree. Battle AI
behavior is outside this matrix; Azure's AI and battle behavior are protected
by the separate move/function contracts in `Audit-Azure.ps1`.

## Preservation requirements

Every port must conserve all of the following unless it has its own explicit,
versioned migration:

- `PBMoves`, `PBItems`, `PBSpecies`, `PBAbilities`, `PBTypes`, and
  `PBTrainers` numeric values used by saves, map events, switches, variables,
  trainer data, and scripts.
- The existing array layouts in `moves.dat`, `pokmanitems.rxdata`,
  `dexdata.dat`, `trainers.dat`, and related compiled files.
- `PokeBattle_Move_XXX` function-code dispatch and every Azure custom move,
  ability, field, boss, Tribute, Hollow, PWT, minigame, and encounter hook.
- Marshal compatibility for `PokeBattle_Pokemon`, `PokeBattle_Trainer`,
  `PokemonSystem`, global metadata, map state, storage, and bag objects.
- The first-record behavior of duplicate legacy data until duplicate IDs have
  an explicit migration. IDs must never be silently renumbered.
- Script order, aliases, event callbacks, and public global helper methods used
  by RPG Maker events.
- Fresh map state on transfer. Caching mutable `RPG::Map` objects is not safe
  until all runtime map mutation sites have been audited.
- Azure's current visual timing by default. Performance options must be opt-in
  when they can change presentation.

## Implemented and verified

### Preservation gate

`Audit-Azure.ps1` now checks the source/constant relationship, cross-database
references, move executor coverage, Azure feature contracts, custom move
semantics, trainer-key uniqueness, machine moves, script order, and compiled
data freshness. It currently covers 1,041 moves, 1,033 species, 373 abilities,
278 trainer types, 21 types, and 1,114 effective item symbols.

### Script loading and battle completeness

- Restored missing script-order entries for the field database, field manual,
  and Trainer Index.
- Added a compatibility executor layer for every move function referenced by
  Azure's current PBS data.
- Added preservation contracts for Azure custom effects and end-of-round
  processing.

### Typed move registry

Rejuvenation's `MoveData` pattern was adapted behind `PBMoveData` rather than
replacing Azure's move arrays.

- Numeric construction remains supported.
- Symbolic PBS identifiers are accepted by `get`, `try_get`, and `exists?`.
- One immutable wrapper is reused per compiled move row.
- Replacing `moves.dat` or an individual row invalidates the affected cache.
- Unknown symbolic identifiers return `nil` from `try_get` instead of falling
  through Azure's legacy `getID` value of zero.

### Typed item registry

`PBItemData` provides the same compatibility approach for Azure's compiled item
rows. Numeric IDs, `$ItemData`, `PBItems`, bag contents, held items, and save
serialization remain unchanged.

- Numeric and symbolic lookup are available through `get`, `try_get`,
  `exists?`, and `each`.
- One read-only wrapper is reused per item row.
- Replacing `$ItemData`, replacing a row, or incrementally compiling items
  invalidates the wrapper cache.
- Field-use, battle-use, item-type, pocket, price, description, and machine move
  values remain the exact legacy numeric/string values.

### Typed ability registry

`PBAbilityData` adapts Rejuvenation's `AbilityData` lookup API without replacing
Azure's numeric `PBAbilities` constants or localized message tables. Numeric and
symbolic lookup are available through `get`, `try_get`, `exists?`, and `each`,
and one immutable wrapper is reused per effective ability ID. Names and
descriptions are resolved from `MessageTypes` on access rather than cached, so
language changes remain immediate. Ability compilation clears the wrapper cache.

### Typed type registry

`PBTypeData` exposes numeric and symbolic `get`, `try_get`, `exists?`, and
`each` APIs over the existing frozen `types.dat` object. Each immutable wrapper
derives its attacking-type weakness, resistance, and immunity IDs once and also
exposes pseudo/special classification. The established flattened chart remains
the battle API, avoiding a storage or effectiveness-semantics migration; names
remain dynamically localized. Type compilation invalidates both the old chart
cache and the typed wrappers.

### Typed species registry

`PBSpeciesData` provides immutable numeric/symbolic access to Azure's existing
marshaled species rows without changing `$pkmn_dex`, `PBSpecies`, Pokemon
objects, scripted form handlers, or saves. It exposes the complete compiled row,
localized Pokédex text, level-up and egg moves, and battler metrics; nested
arrays are frozen in each reused wrapper. Triple Triad now reads the same typed
base stats and types instead of interpreting marshaled `dexdata.dat` bytes as
the obsolete fixed-width format. Two unused legacy dex-file opens were removed
from Pokemon ability/item helpers. Pokemon compilation invalidates all related
wrappers and read-only cache entries.

### Typed metadata registries and split-format editing

`PBGlobalMetadataData`, `PBPlayerMetadataData`, and `PBMapMetadataData` expose
immutable named views over Azure's row-0 global/player slots and per-map numeric
slots. The existing `pbGetMetadata` array lookup remains the gameplay hot path.
`pbLoadMetadata` now reattaches the read-only compiled cache after data clears,
avoiding repeated Marshal loads, while compiler and editor saves explicitly
invalidate wrappers and replace the live row array.

The in-game metadata editor now preserves the active split authoring layout:
global/player data is written to `metadata.txt`, map data remains in
`map_metadata.txt`, enum and trainer-type values use the compiler's CSV writer,
and `metadata.dat` is saved after both sources. Legacy combined projects retain
their existing serializer.

### Source-aware split metadata validation

The shared named-section reader now retains section/property line numbers and
rejects malformed non-comment lines instead of silently discarding them. Split
metadata compilation validates unique numeric global/player IDs (0-25), map IDs
(1-999), unique known properties, required complete player profiles, trainer
type references, and `LegacyPlayerSlot` alignment. `Legacy*` compatibility
fields and map `Name` annotations remain accepted but intentionally do not alter
Azure's compiled numeric rows. The preservation audit independently verifies
global/player and map field shapes without regenerating `metadata.dat`.

### Typed encounter registry and cache-safe rolls

`PBEncounterData`, `PBEncounterTypeData`, and `PBEncounterSlotData` provide
immutable map, encounter-type, and slot views over Azure's unchanged
`encounters.dat` hash and numeric species IDs. Map lookup remains numeric while
encounter types accept numeric values or symbolic names such as `:Land`,
`:WaterNight`, and `:HeadbuttHigh`. The active `PokemonEncounters` object reuses
the cached wrapper's frozen legacy-shape arrays, and compiler/editor writes
explicitly invalidate them.

Ability-adjusted encounter weights and high-level ability rolls now use
per-roll local state. Weight arrays are copied only for an attraction ability,
and Pressure/Hustle/Vital Spirit adjust a local minimum-level value rather than
the compiled row. This preserves their intended one-roll effect without
progressively modifying `EncounterTypes::EnctypeChances` or a compiled
`[species,min,max]` slot shared by later encounters.

### Cached evolution and regional-dex auxiliaries

The fixed-width `evolutions.dat` and `regionals.dat` files remain byte-compatible
but are parsed only once per unchanged file. Release builds reuse the parsed
tables without filesystem calls; debug builds use the same modification-time
and size invalidation as other compiled data. Evolution, baby-species, minimum
level, forward/reverse Regional Dex, new-player region count, and typed species
lookups now share these caches. Legacy helpers still return independent mutable
arrays where they did before, while `PBSpeciesData` exposes frozen evolution
records for new code.

### Keyed trainer lookup

Rejuvenation compiles trainer teams into keyed hashes. Azure retains its
compiled trainer array but now builds an equivalent index by trainer type,
name, and party ID.

- Battle, rematch/phone, and Trainer Index lookup no longer scan every trainer.
- Duplicate behavior remains first-record-wins.
- Compiler and in-game editor writes refresh the index immediately.
- Difficulty modes and PWT wrappers still call the same trainer construction
  path after lookup.

### Keyed trainer-team authoring

`PBTrainerTeamData` and `PBTrainerPokemonData` expose immutable TeamData-style
views over Azure's unchanged five-field trainer records and full 32-field
Pokemon rows. The in-game trainer editor now owns one mutable keyed collection
for its session instead of repeatedly loading and scanning `trainers.dat`.
Create, edit, delete, duplicate detection, and free party-ID selection update the
key index immediately, then commit the exact legacy array and refresh the
runtime cache. Free-ID selection no longer constructs as many as 256 complete
opponent parties merely to test whether their keys exist.

### Source-aware trainer schema validation

Reusable `AzurePBSValidation` primitives now provide required-value, integer
range, list-size, known-property, and unique-key errors with the active PBS
file/line context. Trainer compilation applies them before writing outputs for
both named and legacy formats. It rejects incomplete records, duplicate
normalized team keys, party IDs outside 0-255, empty or oversized parties, more
than eight battle items, lossy move lists, malformed section headers, and
unknown trainer or Pokemon properties.

### Source-aware encounter schema validation

Both named and legacy encounter compilers now reject duplicate map/type keys,
invalid map IDs and densities, malformed slot rows, invalid level ranges,
inexact legacy slot counts or weights, and simultaneous Land-family/Cave tables
before writing `encounters.dat`. Named rows retain
file/line diagnostics, and the preservation audit independently checks the
active source's species references and complete slot schema. Azure's 15
encounter types, default densities, compiled array layout, and runtime
selection rules remain unchanged.
Azure's intentionally empty `[031]` and `[032]` map placeholders remain valid
and continue to compile as empty encounter records.

### Typed trainer-type registry

`PBTrainerTypeData` reuses one typed view per compiled trainer-type row while
retaining `trainertypes.dat` and `PBTrainers` numeric IDs. Existing trainer
money, AI skill, gender, intro music, battle music, and victory music helpers
now use the registry with their original defaults and multi-trainer ordering.
Numeric and symbolic `get`, `try_get`, `exists?`, and `each` APIs are available
for new code, and compiler/cache invalidation refreshes the wrappers.

### File-aware runtime data cache

`AzureDataCache` provides opt-in, read-only caching with automatic invalidation
when a compiled file's modification time or size changes. Editor/compiler code
continues to load independent mutable copies.

Release builds now return established cache entries without repeated
`File.mtime`/`File.size` calls because packaged compiled data is immutable.
Debug builds retain per-access signature checks, and explicit compiler
invalidation applies in either mode.

Current consumers include:

- move-to-animation mappings;
- battle sprite metrics;
- encounter tables;
- TM compatibility;
- trainer-type money, skill, gender, intro music, battle music, and victory
  music;
- Shadow move lists;
- `MapInfos` lookups used by transitions, roaming, messages, and map names;
- species, level-up move, egg-move, move, item, and boss runtime tables;
- battle-facility trainer and rental-Pokemon lists used throughout challenge
  setup, opponent generation, and battle speech.

This removes repeated disk reads and repeated Marshal decoding from frequently
used paths while leaving each compiled format intact.

The debug battle-facility generator requests an independent mutable load and
explicitly invalidates the shared entry after saving, so its add/sort workflow
cannot mutate live cached gameplay data.

In debug builds the cache now counts hits, loads, and signature-triggered
reloads per file. `Compiled Data Cache Stats` in the debug menu reports the
session hit rate and per-file counts; release builds pay no statistics cost.

### Title-time data ownership boundary

The title bootstrap now loads only `System` and cached `MapInfos`, the two
collections required before the player chooses an action. The former remains
the mutable RPG Maker engine global, while the latter is an immutable compiled
lookup. `Scene_Intro` and the window-skin lookup reuse that shared `System`
object instead of unmarshalling it again.

Continue, New Game, and Mystery Gift now cross one explicit
`pbLoadAzureRuntimeData` boundary. It loads mutable `CommonEvents` into its
engine-owned global and obtains the read-only species, move, egg-move, item,
and boss tables through `AzureDataCache`. The species level-up-move and
egg-move fallbacks also use the same cache. Item, move, species, and boss
compilers still install complete newly compiled objects and invalidate typed
and file-cache entries, so editor/debug replacement cannot leave a stale
runtime view. Tilesets and both animation collections remain separately
deferred and mutable/editor-owned.

The focused real-startup fixture preserved the exact title ownership signature
and verified that the gameplay boundary is idempotent and leaves all six
runtime collections present. On the test machine, the measured main-to-title
segment fell from approximately 0.07565 seconds and 25,498 allocations to
0.01116 seconds and 3,827 allocations. The deferred gameplay boundary took
approximately 0.15007 seconds and 25,318 allocations once. The benchmark
fixture was removed from the production script order after both captures;
evidence and the ownership classification are under
`tools/preservation/runtime_performance/`.

### Deferred battle-animation loading

Azure no longer unmarshals `Data/PkmnAnimations.rxdata` while constructing the
title scene or entering the save-selection screen. The file is 10,052,540
bytes, and the prior title-boundary load took approximately 1.284 seconds on
the test machine. `pbLoadBattleAnimations` now loads the same mutable
`PBAnimations` object at `PokeBattle_Scene#pbStartBattle`, before the battle
scene constructs its sprites. Common animations, move animations, capture
animations, and Z-Moves retain nil-safe calls to the same helper.

The collection deliberately does not use `AzureDataCache`: the animation
editor mutates and replaces it, while animation compilation already
invalidates it by assigning `nil`. This preserves those ownership rules and
avoids sharing an editor-mutated object through a read-only cache. The focused
engine check preserved 1,250 records, 1,137 named records, selection 11, and
the complete reloaded Marshal object graph. The first battle-boundary load took
approximately 1.162 seconds, a cached helper call approximately 0.000011
seconds, and explicit nil invalidation performed exactly one fresh load.
Evidence is under `tools/preservation/runtime_performance/`.

This ports Rejuvenation's useful principle of keeping title startup focused on
title data without adopting its asynchronous loader. The cost moves to the
battle transition, where the data is first required, and remains synchronous
on the RGSS main thread.

### Indexed battle-animation name lookup

Common effects and capture ball bursts no longer scan all 1,250 battle
animation records every time they play. A derived name index is created on the
first name lookup after the deferred collection loads. It records the first
index for each name, preserving the legacy result for all 41 duplicate names,
and is cleared when the editor mutates or replaces its collection and when the
compiler invalidates animation data. Collection replacement and length changes
also rebuild the index automatically.

The focused engine check compared all 1,096 distinct names with the legacy
linear search, plus a missing name, explicit in-place invalidation, collection
replacement, and append-driven invalidation. All results and the complete
Marshal graph remained exact. Across 50,000 common-animation queries, the
lookup time fell from approximately 11.409 to 0.115 seconds and allocations
from 274,935 to 175,896; the one-time index build took approximately 0.0022
seconds. The cold 10 MB animation load remains deferred and unchanged.
Evidence is under `tools/preservation/runtime_performance/`.

### Deferred mutable tileset loading

Azure no longer unmarshals `Data/Tilesets.rxdata` in `mainFunctionDebug` before
the title scene. The 1,261,971-byte file now loads through
`pbLoadTilesetData` at the first `Game_Map#setup` call. Passability minimaps and
live map tileset refreshes use the same helper, while `pbClearData` deliberately
uses `pbReloadTilesetData` to retain its previous forced-refresh behavior.

The collection remains in `$data_tilesets` and outside `AzureDataCache` because
the tileset editor replaces the array at runtime. The focused engine check
preserved all 53 array entries (52 populated records), the exact 1,262,151-byte
Marshal graph and fingerprint, every tested `Map002` tileset attribute, the
map-create callback object, editor-style replacement, and forced reload. The
old eager load took approximately 0.0108 seconds on the test machine; the first
deferred helper call took approximately 0.0042 seconds and a cached call took
approximately 0.000008 seconds. Evidence is under
`tools/preservation/runtime_performance/`.

For startup reliability, the same cold-import pass also corrected two existing
Ruby parse hazards: the field manual now uses a method-local switch mapping,
and trainer-record indices are class constants rather than dynamic constant
assignments inside a method. The repaired Battle AI conditional is covered by
a preservation contract as well as the executable startup gate.

### Deferred RPG animation loading

Azure's RPG Maker animation table, `Data/Animations.rxdata`, is now loaded on
the first requested map or event visual effect rather than in
`mainFunctionDebug`. `AnimationSprite`, character sprites, and shadow sprites
all route through `pbLoadRPGAnimations`. This table remains separate from the
10 MB `PkmnAnimations` battle-animation collection and preserves the existing
`$data_animations` global, including preassigned replacement and explicit nil
invalidation behavior.

The focused engine check preserved all 151 array entries (150 populated), the
exact 137,648-byte Marshal graph, and all three consumer routes. The old eager
load took approximately 0.0120 seconds on the test machine; the first deferred
load took approximately 0.0094 seconds and a cached helper call approximately
0.000006 seconds. This is a modest title-path improvement, retained because the
ownership boundary is narrow and fully covered. Evidence is under
`tools/preservation/runtime_performance/`.

### One-shot map transfer handoff

Cross-map transfers with active BGM or BGS previously deserialized the
destination in `Scene_Map#autofade` for audio comparison and then immediately
deserialized the same file again in `Game_Map#setup`. The first read now enters
`AzureMapTransferHandoff`; setup takes ownership of that exact object and clears
the handoff. Direct setup without autofade still performs one normal load,
mismatched IDs discard the pending object, and same-map transfers explicitly
clear it.

This is deliberately not a mutable-map cache. No `RPG::Map` survives after
setup consumes it, so live event-page state, editor writes, connected maps, and
later transfers cannot inherit stale mutations. The focused engine check
covered all 145 maps (4,307,628 source bytes, 3,851 events, 5,505 pages, and
37,750 event commands), reduced the simulated transfer path from 290 loads to
145, preserved object identity at setup, and proved that the consumed object is
not reused. The legacy two-pass benchmark spent approximately 4.574 seconds
across all maps, including 0.673 seconds in the immediately repeated loads; the
one-pass optimized run took approximately 0.331 seconds with the filesystem
already warm. Evidence is under `tools/preservation/runtime_performance/`.

The Phase 3 cache-decision closeout therefore rejects a persistent bounded map
cache. Five fresh-load passes covered 725 loads and 4,415,227 serialized bytes
per pass in approximately 5.938 seconds, with exact graphs and distinct
objects throughout. Mutating the 281-event `Map034` after setup did not affect
the next load; the editor's `MapData` copy was independent; explicit clear and
mismatched-ID paths discarded pending state; and `onMapCreate` fired once with
the exact handoff object. Azure currently defines no connected-map records, so
the mismatch path was also exercised as the synthetic neighboring-map case and
the dimension-only helper cache was cleared and rebuilt. These ownership costs
are required for correctness, while the already implemented one-shot handoff
removes the only proven duplicate read without retaining mutable state.

### Allocation-free event and map iteration

Azure's most frequent map loops no longer create temporary `Hash#values`
arrays. Map refresh, per-frame event/common-event updates, tile-event
passability, event lookup, and connected-map collision checks now use
`each_value`. Event page selection uses `reverse_each` instead of copying every
page array with `reverse` on every refresh.

This does not narrow refresh dispatch: every event and common event is still
visited in the same order, which preserves Azure's dynamic `s:` switch
expressions and script-driven page conditions. Across all 145 maps and 3,851
events, the focused check proved exact event and page order. On the 281-event
`Map034`, 20,000 hash iterations fell from approximately 20,009 allocations to
7 and from 1.207 to 1.083 seconds. One hundred all-event page scans fell from
approximately 770,207 allocations to 385,104 and from 0.478 to 0.259 seconds.
Evidence is under `tools/preservation/runtime_performance/`.

### Allocation-free map spriteset reconciliation

`Scene_Map#updateSpritesets` runs after every normal and mini map update. It
previously materialized the spriteset hash's keys and cloned that array before
updating active maps, disposing removed maps, and creating newly connected map
spritesets. It now uses `Hash#delete_if`, which retains hash insertion order,
updates and disposes in the same order, safely removes the current entry, and
leaves missing-map creation in its original second pass.

The focused matrix covered stable maps, middle removal, addition, simultaneous
removal/addition, and a nil removed entry. All five scenarios retained checksum
`2035679682`. Across 20,000 four-spriteset reconciliations, runtime fell from
approximately 0.0780 to 0.0286 seconds and allocations from 60,002 to 2. The
preservation audit requires the allocation-free reconciliation structure.

### Direct current-map spriteset lookup

`Scene_Map#spriteset` had 14 static callers in animation, radar, darkness,
location-window, achievement, and contest paths. None is a per-frame caller,
but every lookup still created a values array and a missing-map fallback made
a second one. The method now checks the map-ID-keyed entry directly, validates
its map object, and retains ordered `each_value` scans for stale-key and
first-entry fallback compatibility.

The focused matrix preserved first and middle hits, a missing-map fallback,
an empty hash, and the legacy nil-entry error. Across one million current-map
lookups, runtime fell from approximately 3.2827 to 1.0089 seconds and
allocations from 2,000,001 to 1. The audit rejects `@spritesets.values` and
requires both the direct lookup and ordered fallbacks.

### Allocation-free player and character event scans

Ten movement, collision, and interaction paths in `Game_Character` and
`Game_Player` previously materialized `Hash#values` arrays while checking map
events. They now use `Hash#each_value`, retaining insertion order, early
returns, multi-event start behavior, trainer/counter filters, jumping and
over-trigger rules, swim-to-land collision handling, and counter fallback.

The focused engine matrix exercised 16 outcomes across trainer/counter
discovery, direct and counter-facing lookup, character and swimming
passability, and here/there/touch triggers. The complete signature matched
before and after the rewrite. Across 20,000 scans of 281 events, runtime fell
from approximately 2.5725 to 2.3172 seconds and allocations from 20,002 to 2.
The preservation audit guards all four behavior groups and rejects a
reintroduced `events.values` scan in either class.

### Allocation-light encounter selection

The fixed totals for Azure's 15 encounter-weight tables are now calculated
once when `EncounterTypes` is defined. Ordinary wild rolls read the shared
weights without cloning them, the unowned-species candidate array is created
only while switch 74 is active, and selected compiled rows remain read-only.
Attraction abilities still receive an independent mutable weight array, while
Pressure, Hustle, and Vital Spirit change only a local minimum level.

The focused engine check covered all 32 encounter maps, 103 type tables, and
890 slots. A deterministic 250,000-roll test retained the exact checksum and
RNG-sequence hash, and direct legacy-versus-optimized comparisons matched 12
scenarios: ordinary selection, all six attraction abilities, all three
higher-level abilities, switch 74, and an egg party leader. The compiled graph
was unchanged. On the test machine, the ordinary selection benchmark fell
from approximately 2.088 to 1.046 seconds and from 2,030,539 to 1,280,539
allocations. Evidence is under `tools/preservation/runtime_performance/`.

### Allocation-free party-menu sprite iteration

The shared sprite-hash updater now walks values directly and uses a symbol for
the `update` capability check. Party-menu `ChangelingSprite` objects likewise
walk their bitmap hashes directly during frame updates and disposal. In a full
party this removes the temporary arrays created every frame by the six panel
ball/item helpers plus the cancel control; the shared helper also benefits
summary, bag, storage, and other sprite-hash screens.

The focused engine check preserved insertion-order updates, nil entries,
`RGSSError` suppression, exact update counts, party bitmap update order, and
disposal of every bitmap. Across 100,000 simulated frames with 15 active sprite
entries, the shared update loop fell from approximately 2.144 to 1.342 seconds
and from 3,100,002 allocations to 2. Thirteen party-style bitmap helpers fell
from approximately 1.509 to 1.302 seconds and from 1,300,002 allocations to 1.
Evidence is under `tools/preservation/runtime_performance/`.

### Deferred transient window-flash scan

`SpriteWindow#update` still materializes `@sprites.values` while a window flash
is active. Azure has no direct `SpriteWindow#flash` caller, and the scan does
not run during ordinary window updates when `@flash` is zero. A focused matrix
preserved insertion-order updates, exact duration countdown, disposed and
inactive behavior, and the legacy nil-sprite error. Forcing 100,000 active
frames across the normal 16-sprite window structure took approximately 0.7800
seconds and allocated 100,001 objects, about one array per forced frame.

Because the measured cost has no active Azure call path, this candidate is
documented and deferred rather than adding an unneeded production change. It
should be reconsidered only if a future feature begins calling
`SpriteWindow#flash` or runtime profiling observes the path.

### Deferred sprite and particle boundary scans

The remaining ranked collection candidates are lifecycle-bound rather than
steady-state hot paths. `Particle_Engine` materializes map event values only on
its first update, `Spriteset_Map` sorts event IDs only while constructing a
spriteset, and particle bitmap values are copied only during effect disposal.
There are no per-frame candidates in this group after initialization.

Across the 145-map, 3,851-event inventory, the largest one-time event set is
281 entries. The sorted spriteset keys intentionally preserve event-ID sprite
construction and draw order. These sites remain unchanged unless runtime
profiling later identifies meaningful setup or disposal cost; removing a few
lifecycle arrays does not justify weakening ordering clarity. Evidence is in
`sprite_ui_boundary_scans.deferred.status.txt`.

### Allocation-free AI rough-stat scaling

AI move scoring and switch evaluation call `pbRoughStat` from 532 source
locations. The method previously constructed the same multiplier and divisor
arrays for every nontrivial call. Those immutable stage tables are now frozen
class constants, leaving the stat, skill-tier, stage, floating-point, and
rounding calculations unchanged and consuming no battle RNG.

The focused engine check compared all five calculated stats at every stage
from -6 through +6 across six AI skill thresholds: 390 exact scenarios with
the same matrix checksum. Across one million deterministic calls, runtime fell
from approximately 1.985 to 1.785 seconds and allocations from 1,800,011 to 3.
Evidence is under `tools/preservation/runtime_performance/`.

### Deterministic AI decisions and rough-damage scaling

A seeded, end-to-end battle fixture now covers both single and double AI move
scoring, target selection, switch evaluation, command selection, and every AI
and battle RNG draw. It records the complete result signature so a performance
change cannot silently alter scores, targets, choices, or random-call order.
The two scenarios retain checksum `2062664973`; their focused regression checks
also prove normal move availability, both opposing Imprison slots, and that
each initialized battle move is bound to its active battler.

Building this fixture exposed two existing runtime faults in ordinary AI
scoring. `pbCanChooseMove?` used its two Imprison opponents without assigning
them, and `pbInitPokemon` gave each runtime move the underlying Pokemon as its
user even though move helpers require battler state. The opponent slots are now
bound before availability checks and initialized moves receive their battler;
the fixture exercises both repairs directly.

`pbRoughDamage` also rebuilt the same stage multiplier and divisor arrays on
every call. It now shares the frozen tables already used by `pbRoughStat`.
Across 5,000 deterministic Surf estimates, all damage results and RNG activity
were exact while allocations fell from 1,172,303 to 1,162,303, removing exactly
two short-lived arrays per estimate. Wall-clock variance at this scale was
larger than the timing difference, so this is recorded as a measured allocation
and GC-pressure improvement rather than a claimed direct speedup. Evidence is
under `tools/preservation/runtime_performance/`.

Ordinary rough-damage estimates also stopped rebuilding `PBMove` and
`PokeBattle_Move` objects when the supplied move is already canonical, belongs
to the current battle, and is bound to the evaluated battler. Normalization is
still mandatory for all eight weather, item, attacker, or field-sensitive move
families and whenever type, power, flags, name, battle, or user ownership can
change the legacy result. Struggle's special constructor and Glacial Slam's
compatibility function override retain their established behavior.

The focused routing matrix covered all 1,049 compiled move records plus
mutated power/type/flags/name, wrong-user, wrong-battle, Struggle, Glacial Slam,
and all eight context-sensitive cases. In a same-process comparison of 5,000
Surf estimates, canonical reuse preserved the exact damage checksum and zero
RNG calls while reducing runtime from approximately 2.792 to 2.740 seconds and
allocations from 982,303 to 942,304. The full seeded single/double decision
signature remained `2062664973`.

Two frequently repeated AI query helpers now avoid redundant container work.
`checkAIdamage` encodes its four battler slots and hard-switch flag into one
collision-free integer cache key instead of allocating and hashing a
three-element array on every lookup. `pbAIOrderedFoes` returns its constructed
list directly because its iterator already rejects nil/fainted battlers and
the primary target is explicitly excluded by index before remaining foes are
appended.

The focused check proved all 32 cache-key combinations are unique and compared
100 single/double, preferred-target, same-side, and fainted-battler ordering
scenarios with the legacy `compact.uniq` result. One million cache hits retained
damage `103`, checksum `266152896`, and zero RNG calls while runtime fell from
approximately 7.009 to 2.368 seconds and allocations from 6,454,037 to
3,454,037. Across 250,000 ordered-foe queries, order `[2,0]` and checksum
`372187424` remained exact while runtime fell from approximately 2.138 to 1.710
seconds and allocations from 2,977,719 to 2,227,719.

Single-pass ordered-foe checks now use a yielding iterator instead of first
materializing that same ordered list. The public `pbAIOrderedFoes` array helper
is retained for callers that store, combine, or revisit the targets, while
move, ability, memory, readiness, screen-damage, status-reflection, and switch
checks that scan once consume the iterator directly. Preferred-target
validation, primary-target fallback, fainted filtering, battler order, and
short-circuit behavior are unchanged.

The focused check covered seven single/double layouts with valid, invalid,
same-side, and fainted preferred targets. The iterator and retained array API
both produced ordering checksum `149169694`; eight move, ability, memory, and
readiness queries retained helper checksum `1933839760`. Across one million
two-foe move misses, runtime fell from approximately 5.241 to 4.579 seconds and
allocations from 2,000,002 to 1,000,002. The remaining allocation is the
existing variable-argument move list, not a foe collection.

That final query allocation is now removed as well. The six foe/ally move,
ability, memory, and readiness predicates accept either one numeric/symbolic
ID or an existing collection instead of Ruby variable arguments. All scalar
callers pass their ID directly; the four multi-value scoring patterns use
frozen redirection, screen-break, electric-immunity, and allied spread-damage
groups, while the existing `PBStuff::SCREENBREAKERMOVE` collection is passed
without splatting.

The focused check compared scalar hits/misses and collection hits/misses for
all six helpers, including sleeping-foe readiness and self-inclusive versus
other-ally ability scans. All 24 results retained checksum `900000016`.
Across one million two-foe scalar misses, runtime fell from approximately
4.668 to 3.573 seconds and allocations from 1,000,002 to 2.

Single-pass same-side queries likewise use the existing filtered battler
iterator instead of materializing `pbAIAllies` arrays. Dedicated helpers cover
existence/condition checks and preferred-index-or-first selection; stored ally
lists and the Magnetic Flux/Gear Up filtered collections retain arrays because
they are revisited. Helping Hand now performs one scan instead of a `find`
allocation followed by a second fallback allocation, and ally KO, protection,
Mud Sport, Water Sport, Ion Deluge, and immunity checks consume the iterator.

The focused check covered five layouts with no partner, self inclusion,
fainted partners, non-index ordering, a matching preferred index, and a missing
preferred index. Array and iterator results retained checksum `2016156807`.
Across one million two-ally failed predicates, runtime fell from approximately
3.453 to 3.122 seconds and allocations from 1,000,002 to 2. The preservation
audit rejects reintroduced `any?`, `empty?`, or `find` calls on materialized
`pbAIAllies` results.

Three ally-target scoring branches no longer allocate a mapped speed array to
find the maximum opposing speed. They retain the nonempty guard and instead
test that the candidate is strictly faster than every foe, which preserves the
legacy false result for empty lists and speed ties. The focused matrix covered
eight empty, singleton, faster, slower, tied, mixed-order, and negative-speed
cases with checksum `1751308814`. Across one million four-foe comparisons,
runtime fell from approximately 1.610 to 1.294 seconds and allocations from
1,000,002 to 2. The audit requires exactly three allocation-free scans and
rejects reintroduced `map.max` speed arrays.

Nineteen same-side target branches now scan `eachSameSideBattler` directly
instead of allocating `sameSideBattlers(false)` and then calling `include?`.
The helper intentionally uses the engine enumerator rather than index parity,
so it preserves active-slot membership, nil handling, self exclusion, fainted
battler inclusion, ordering, and rejection of same-parity objects that are not
actually present in the battle.

The focused check covered eight partner, self, opponent, nil-slot, fainted,
absent, reordered, and include-self cases with checksum `1123836486`. Across
one million absent-target checks, runtime fell from approximately 2.443 to
2.043 seconds and allocations from 1,000,002 to 3. The audit requires all 19
scoring sites to use the membership scan and rejects the allocating form.

Six immutable terrain, move-function, and Ability membership groups are now
shared as frozen AI constants instead of being rebuilt at nine scoring sites.
The values and exact `Array#include?` semantics are unchanged, including the
non-contiguous terrain IDs and move-function boundaries; only ownership and
allocation timing changed.

The focused check covered all members plus adjacent or representative misses
across 46 cases and retained checksum `1603738730`. Across one million failed
terrain lookups, runtime fell from approximately 0.565 to 0.314 seconds and
allocations from 1,000,002 to 2. The audit verifies every frozen group, requires
the exact nine uses, and rejects reintroduced literal membership arrays.

AI move-memory predicates now compare remembered IDs directly instead of
reconstructing a complete battle move for every requested-ID/memory pair.
Nature Power remains the sole exception because `pbChangeMove` replaces its ID
with the current field's move; accuracy checks likewise rebuild Nature Power
but read every ordinary move's already initialized accuracy, preserving
Struggle's special constructor behavior. Reversing the membership scan also
normalizes Nature Power at most once per remembered move rather than once per
requested ID. This benefits 219 `checkAImoves` call sites as well as
`checkAIHas?` and `checkAIaccuracy`.

The focused check compared all three predicates with their legacy
implementations across fields 0 through 45, five query shapes, ordinary moves,
Nature Power, and attacker-owned moves: all 506 results and RNG activity were
exact. Across 100,000 worst-case four-ID/four-memory misses, runtime fell from
approximately 20.727 to 0.472 seconds, allocations from 12,800,005 to 4, and
full move normalizations from 1,600,000 to zero. The seeded single/double
decision signature remained unchanged.

The same predicates now also accept a bare numeric move ID, so 88 one-move
queries no longer allocate a temporary one-element array while multi-move and
shared move-group queries retain their collection behavior. A focused matrix
covered both memory and attacker predicates for every numeric `PBMoves`
constant: all 2,154 collection results and the scalar equivalents retained
checksum `886775334`. A separate Nature Power case confirmed that both scalar
predicates still compare its field-resolved move rather than its source ID.
Across one million four-move misses, runtime fell from approximately 2.510 to
2.068 seconds and allocations from 1,000,002 to 2. The preservation audit also
rejects any reintroduced `[PBMoves::MOVE]` singleton call site.

The remaining 62 literal multi-move queries now reuse 16 frozen semantic
groups. This includes 36 Clear Smog/Haze checks and the repeated hazard
control, sleep-use, weather-accuracy, spread-move, weight-based, item, and
status groups. Reversed Sleep Talk/Snore and Low Kick/Grass Knot spellings were
merged because the predicate performs membership testing and never observes
query order. Dynamic queries and the existing shared `PBStuff` groups are
unchanged.

The focused check exercised first-member, last-member, miss, and empty-memory
cases through both memory and attacker predicates for all 16 groups. All 128
results retained checksum `1958265408`, and every shared group was frozen.
Across one million four-move misses, runtime fell from approximately 2.825 to
2.643 seconds and allocations from 1,000,002 to 2. The preservation audit now
rejects any reintroduced literal `PBMoves` query array.

After all AI allocation changes above, the seeded end-to-end closeout reran
both battle layouts from fresh deterministic state. The single battle retained
scores `[86, 28, 24, 30, 0]`, no explicit targets, no switch, Surf selection,
and AI draws `4:2,4:3`. The double battle retained scores
`[50, 44, 21, 30, 0]`, targets `[0, 2, 0, 2, -1]`, no switch, Surf targeting
slot 0, and draws `4:3,4:0,4:1,4:2,4:3,4:0,10:5`. Neither scenario consumed
battle RNG, every recorded field matched exactly, and the accumulated decision
checksum remained `2062664973`.

### Deterministic duplicate policy

Azure's historical duplicate symbols and numeric IDs are now an explicit
compatibility set instead of an open-ended compiler behavior. The item, move,
ability, trainer-type, and Pokemon compilers reject every new collision and any
membership change to a grandfathered collision before writing generated data.
The preservation audit independently proves that all 22 symbolic aliases and 4
shared numeric IDs in the active PBS sources match that policy exactly. No
legacy ID is renumbered and no existing alias resolution behavior is changed.

### Stable named ability and trainer-type schemas

Named ability and trainer-type sections now require their explicit legacy IDs,
preventing section reordering from silently renumbering constants referenced by
saves and events. Both named and legacy inputs share validation for constant
symbols and required display text. Ability descriptions are mandatory;
trainer-type base money and skill remain optional with their original defaults
but must be 0-255, and explicit genders must use a supported value. Excess CSV
columns, duplicate properties, and unknown properties fail with source context.
The documented duplicate ability and trainer-type symbols remain accepted with
their exact existing IDs and last-definition-wins constant behavior.

### Named Pokémon and auxiliary PBS validation

The named Pokémon adapter now validates each species before translating it to
Azure's legacy compiler schema. Explicit `LegacySpeciesID` values are mandatory
and limited to the 16-bit IDs used by evolution and regional-dex files. Section
symbols, supported property aliases, alias conflicts, required fields, type and
ability cardinality, six-stat ranges, level-up move pairs, evolution triples,
EV yields, egg groups, numeric ranges, dimensions, regional numbers, and
single-value legacy fields are checked with source-line context. Unknown and
repeated properties no longer disappear during translation. The ten historical
`LegacyFormName`/`Legacytoobig` properties remain explicitly accepted but
ignored because the original Azure compiler also ignored them.

`pokemon_metrics.txt` now rejects unknown/duplicate properties, invalid
symbols, unmatched species, excess duplicate sections, and values outside the
existing signed-word layout. `regional_dexes.txt` now rejects malformed or
duplicate regions, empty/duplicate entries, invalid symbols, and unknown
species while preserving list order and regional numbering.

The old malformed `InternalName=HAUNTER,CURSEDBODY` record had historically
compiled as `HAUNTER` because the CSV parser discarded the extra token. Its
named species and metrics headers are corrected to `HAUNTER`; the already
authored `HiddenAbilities = CURSEDBODY` remains unchanged. A trailing empty
token on `IRONJUGULIS`'s move list was also removed. Both repairs leave every
compiled gameplay field unchanged and make named round trips deterministic.
The compiler continues to emit the same `PBSpecies` constants, dex arrays,
level-up and egg moves, metrics, evolution binary, regional-dex binary, and
message tables.

### Named type-chart validation

The type compiler now reads `types.txt` through the same line-aware named PBS
parser as the newer authoring adapters while retaining Azure's numeric type
IDs, `PBTypes` constants, messages, pseudo/special arrays, and flattened
defender-by-attacker chart layout. Type IDs are explicitly limited to the
byte-safe 0-255 range used by existing compiled species data.

Every section now requires a display name and uppercase internal symbol.
Unknown or repeated properties, duplicate numeric IDs, duplicate symbols,
malformed Boolean values, empty/duplicate relationship entries, and a type
listed in more than one of Weaknesses/Resistances/Immunities are rejected with
the exact source line. The final section receives the same required-field
validation as every earlier section, closing an old end-of-file bypass. All
relationship targets are resolved only after the full symbol table is built,
so forward references remain supported. Azure's active 21 types and 144 chart
relationships compile to the same runtime semantics.

### Named move PBS validation

Both the named move format and the original 14-column CSV now pass through one
source-aware validator before producing Azure's unchanged numeric `moves.dat`
rows and `PBMoves` constants. Named sections require an explicit positive
`LegacyMoveID`, so reordering sections can no longer renumber save- and
event-facing move IDs. They also require every gameplay field rather than
silently turning missing or malformed values into zero.

The validator preserves decimal function/target values and accepts explicit or
traditional bare hexadecimal notation, checks all byte/word/signed-byte ranges,
requires a known type and exact Physical/Special/Status category, rejects
category/power contradictions, validates flag characters and duplication, and
rejects unknown or repeated properties. `LegacyFunctionCode`/`FunctionCode`,
`LegacyTarget`/`Target`, and `LegacyFlags`/`Flags` are supported as mutually
exclusive compatibility aliases. Empty descriptions and omitted zero flag sets
remain legal because Azure already contains three and 70 such records,
respectively. The original `DOUBLEKICK` `s` source token is explicitly
grandfathered as ignored (matching the legacy compiler's a-p runtime bitmask)
so round trips remain lossless without changing battle behavior. The existing
move symbol and numeric-ID aliases remain governed by the deterministic legacy
duplicate policy.

### Union-preserving TM compatibility validation

Azure's `tm.txt` compiler now validates move sections and species lists with
source-line-aware errors, rejects malformed symbols, unknown references, empty
CSV entries, and distinct move symbols that collide on one runtime numeric ID.
Repeated species are emitted only once per numeric move ID, reducing the
compiled membership arrays without affecting any consumer: the Pokédex,
machine checks, tutor screens, editor, and battle generator all use membership
tests and do not observe entry order or duplicate counts.

Repeated sections for the same move now merge instead of replacing the earlier
list. This is necessary for Azure's authored data: six moves have repeated
sections, and the old Azure/Rejuvenation parser silently discarded 31 valid
numeric compatibility pairs from the earlier `COSMICPOWER`, `HEX`,
`SUCKERPUNCH`, and `VACUUMWAVE` sections. The effective union contains 303
numeric moves and 52,657 unique move/species pairs. A SHA-256 preservation
contract locks that numeric map, while 1,260 redundant authored entries are
explicitly deduplicated. Six ignored empty entries and the `BLISSEy`/`GOlETT`
case typos were removed from the active PBS with no change to their old parsed
meaning. The activated `Data/tm.dat` was compiled to an isolated candidate,
reloaded through Ruby Marshal, and compared row-for-row against an independently
constructed 303-row numeric manifest. It matched the preservation SHA-256
exactly before installation. The prior compiled file remains recoverable at
`tools/preservation/tm_roundtrip/tm.before-union.dat`.

### Named item PBS support

Azure's item compiler now accepts both the existing 10-column CSV and named
item sections. The migration/export pipeline includes `items.txt` and preserves
the exact legacy fields:

- `LegacyItemID`
- `Name`
- `Pocket`
- `Price`
- `Description`
- `FieldUse`
- `BattleUse`
- `Type`
- optional `Move`

Both formats now share source-aware validation for symbols, display text,
positive IDs, the configured 1-8 pockets, nonnegative prices, field-use values
0-5, battle-use values 0-4, and optional item-type values 0-13. Machine moves
must appear exactly when `FieldUse` is 3 or 4, and excess legacy CSV columns are
rejected instead of ignored. Named `Type` remains a required property but may be
blank, preserving the existing `RIFTSEED` nil-type row during export and
round-trip compilation. The three grandfathered duplicate symbols retain their
exact last-definition-wins behavior. Migration remains opt-in and backs up the
original file; existing CSV projects compile unchanged.

### Controlled item-data activation

Item compilation now supports isolated data, constant-script, and message-file
outputs. Candidate builds therefore use Azure's normal parser and layouts
without replacing `$ItemData`, loaded `PBItems`, message tables, caches, or live
files. The normal no-argument compiler behavior remains unchanged.

The activated item bundle was independently compared against every effective
PBS field and generated constant before installation: 1,117 numeric records,
1,114 effective symbols, 10,053 compiled fields, and all machine-move IDs match.
The three documented aliases (`GREENKEY`, `TM115`, and `TM116`) still use their
last source definition. Twelve new Tribute records and four authored Tribute
description changes are now live. Deprecated IDs 1036 (`TANTRIBUTE`) and 1037
(`MISTRIBUTE`) remain as compatibility rows so old bags and saves never resolve
those numeric IDs to `nil`; they do not restore any removed battle effect.

`Data/pokmanitems.rxdata`, `Scripts/PBItems.rb`, and the item name/description
tables in `Data/messages.dat` were installed as one verified set. All non-item
message tables were proven unchanged. The previous files remain recoverable in
`tools/preservation/item_roundtrip/` as the three `before-activation` backups.

### Controlled Pokémon-data activation

Pokémon compilation now accepts isolated output paths for metrics, regional
dex data, evolutions, core dex rows, egg moves, level-up moves, generated
`PBSpecies`, and localized messages. Evolution references resolve against the
candidate's own symbol map, so isolated compilation never reopens or mutates
the loaded `PBSpecies` module. Normal no-argument compilation retains the same
live paths, globals, messages, and cache invalidation.

The named Pokémon sources compile to 1,035 constant rows, 1,034 effective
symbols, and 1,033 effective numeric dex records. All seven structural outputs
were reloaded through their real Ruby/custom binary readers and matched the
previous live files byte-for-byte, including movesets, egg moves, three metric
tables, 120 regional entries, and every forward/reverse evolution record. The
legacy `AGGRON`/`DEOXYS` numeric alias at ID 306 and duplicate `IRONMOTH` ID 994
remain unchanged. Exact mixed-case `NIDORANfE` and `NIDORANmA` spellings are
explicitly grandfathered; no other mixed-case constant is accepted.

The only semantic activation change is the missing form-name entry for Ogerpon
ID 1017. Correcting `LegacyFormnames` to `LegacyFormNames` now exposes
`Unmasked`, `Teal Mask`, `Wellspring Mask`, `Hearthflame Mask`, and
`Cornerstone Mask`; every other Pokémon and non-Pokémon message is unchanged.
The eight previous files remain recoverable under
`tools/preservation/pokemon_roundtrip/` as `before-activation` backups.

### Controlled trainer-data activation

Trainer compilation now accepts isolated output paths for `trainertypes.dat`,
`trainers.dat`, generated `PBTrainers`, and the two trainer message tables.
Candidate builds do not replace loaded constants, messages, typed registries,
the keyed team cache, or live files. Normal no-argument compilation retains
the established live outputs and now refreshes the trainer-type and keyed-team
caches after a successful write. Trainer-name hashing is performed once after
all teams parse instead of being rebuilt after every team.

The named sources compile to 280 trainer-type rows (278 effective symbols),
162 unique keyed teams, and 630 trainer Pokemon. `trainertypes.dat` and
`PBTrainers.rb` match the previous live files byte-for-byte. All trainer and
non-trainer message tables are semantically identical, so the installed
`messages.dat` was deliberately left untouched. Azure's duplicate
`SCHOOLKID_F` and `HADIEN` constants retain last-definition-wins behavior, and
all 23 historical mixed-case trainer constants (for example,
`POKEMONTRAINER_Troy`) retain their exact case-significant Ruby spellings.

The only two semantic differences in `trainers.dat` are the already-authored
changes to the sixth Pokemon in `[MYRON2,Myron,200]`: Mismagius now holds
`SPOOKYTRIBUTE` (ID 1150 instead of `MISTRIBUTE` ID 1037) and uses form 0
instead of form 1. Every other team field, key, item, move, stat, boss flag,
and override matches the prior binary. The activated data passed the real
typed/keyed runtime adapters for all 280 types, 162 teams, and 630 Pokemon.
Previous trainer binaries, constants, and messages remain recoverable under
`tools/preservation/trainer_roundtrip/` as `before-activation` backups.

### Controlled move-data activation

Move compilation now supports isolated `moves.dat`, generated `PBMoves`, and
move name/description message outputs. Candidate builds do not replace
`$pkmn_move`, loaded constants, messages, or typed caches. Normal compilation
retains the established output paths and explicitly invalidates both the typed
move registry and shared data cache after a successful live write.

The named source compiles to 1,051 authored rows, 1,041 effective symbols,
1,050 populated numeric records, and 541 distinct function codes. The
candidate `moves.dat` and `PBMoves.rb` match the prior live files
byte-for-byte. The candidate move message tables are semantically identical,
and every non-move table is unchanged, so the installed `messages.dat` was
deliberately retained without reserialization.

All documented last-definition symbol aliases remain exact, including the
weather-trio/signature-move block and `DISHEARTEN`, `EPHEMERATE`, and
`ANTICLINE`. Numeric aliases at IDs 318 (`BONECLUB`/`SPIKECANNON`) and 680
(`DIMPULSE`/`DIMZAP`) retain their shared compiled rows. The focused runtime
check loaded all 1,050 records through `PBMoveData`, verified every ten-field
wrapper, all 1,049 named nonzero moves, the 541 function codes, the aliases,
and immutable wrapper reuse. Static audit coverage separately requires every
authored function code to have an installed `PokeBattle_Move_XXX` executor.
Previous move data, constants, and messages remain recoverable under
`tools/preservation/move_roundtrip/` as `before-activation` backups.

### Controlled ability-data activation

Ability compilation now supports isolated generated `PBAbilities` and
ability name/description message outputs. Candidate builds do not replace
loaded constants, messages, or the typed ability cache. Normal compilation
keeps the established live paths and invalidates `PBAbilityData` only after a
successful live installation.

The named source compiles to 379 authored rows, 373 effective symbols, 379
localized numeric records, and a maximum legacy ID of 421. Generated constant
content matches the prior live module while making three form-script aliases
(`SPIRITED=72`, `SNOWVEIL=81`, and `MAJESTY=213`) explicit compiler policy so
future PBS compiles cannot erase them. The six documented duplicate symbols
retain their last-definition numeric mappings through IDs 396 and 404-408.

The activated messages add the authored names and descriptions for IDs
409-421 and install 26 previously authored description revisions. Every
non-ability message table is semantically unchanged. The focused installed
runtime check matched all 379 source names/descriptions and 373 effective
constants, enumerated all 379 records through `PBAbilityData`, verified all
nine compatibility/duplicate aliases, and confirmed immutable wrapper reuse.

Static reference auditing now checks module-qualified ability references and
the three generated-only aliases. It also reports six pre-existing optional
form placeholders (`CUTEINFATUATE`, `PURIFYING`, `SEGUE`, `AFTERLIFE`,
`FLAMEEATER`, and `KEYHOLDER`) that have script references but no authoritative
ability record. They remain warnings rather than guessed aliases or invented
save-facing IDs; those forms require a separate design-authorized data and
behavior pass. Previous constants and messages remain recoverable under
`tools/preservation/ability_roundtrip/` as `before-activation` backups.

### Controlled type-data activation

Type compilation now supports isolated `types.dat`, generated `PBTypes`, and
localized type-name outputs. Candidate builds do not replace loaded constants,
messages, the frozen chart, or typed wrappers. Normal compilation keeps the
established paths and invalidates `PBTypes` and `PBTypeData` only after a
successful live installation.

Azure's 21 numeric types remain authoritative, including pseudo type 9
(`QMARKS`) and the game-specific `SHADOW` and `DIMENSION` types at IDs 19 and
20. The compiled 21-by-21 chart contains 441 cells and 144 explicitly
non-neutral matchups; special-type IDs remain exactly 10-20. `types.dat`,
`PBTypes.rb`, and the complete candidate message file all match their prior
live files byte-for-byte, so message data was deliberately left untouched.

The focused runtime check compared every chart cell with a fresh source
compile, exercised all 9,261 dual-defender effectiveness combinations,
validated every name, constant, pseudo/special flag, and typed weakness,
resistance, and immunity list, and confirmed immutable cache reuse for all 21
`PBTypeData` records. Static auditing now requires every active
module-qualified type reference to resolve. That scan found and corrected the
old `FIGHT` typo in Ice Field's Ice Scales interaction, restoring its intended
Fighting-type damage reduction. Previous binaries, constants, and messages
remain recoverable under `tools/preservation/type_roundtrip/` as
`before-activation` backups.

### Controlled encounter-data activation

Encounter compilation now accepts an isolated output path and can suppress
runtime cache invalidation for candidate builds. Normal compilation retains
`Data/encounters.dat`, invalidates both `AzureDataCache` and
`PBEncounterData`, and returns the compiled map hash for verification and
tooling.

The named source compiles to 32 maps, 103 encounter-type tables, 890 slots,
and 71 unique species with authored levels from 3 through 35. Maps 31 and 32
remain intentional empty placeholders. The candidate and prior live
`encounters.dat` are byte-for-byte identical, including all densities,
numeric species IDs, level ranges, table positions, and legacy slot weights.

The focused runtime check compared every compiled row with all immutable
`PBEncounterData`, `PBEncounterTypeData`, and `PBEncounterSlotData` fields,
confirmed symbolic and numeric encounter-type lookup, exercised one legacy
weighted selection for every populated table, verified both empty maps, and
proved explicit invalidation replaces the shared data object and typed
wrappers. The source-aware candidate path left the active cache untouched.
The prior binary remains recoverable under
`tools/preservation/encounter_roundtrip/` as a `before-activation` backup.

### Controlled metadata activation

Metadata compilation now accepts an isolated output path and can suppress
runtime cache invalidation for candidate builds. Normal compilation retains
Azure's combined `Data/metadata.dat`, invalidates `AzureDataCache`, the legacy
`$PokemonTemp` value, and both typed metadata wrapper caches, and returns the
compiled rows for verification and tooling.

The split authoring sources compile to one global row, 10 player profiles, and
94 map rows containing 298 authored map fields through map ID 142. The
candidate, prior live file, and installed file are byte-for-byte identical at
4,169 bytes. This preserves all numeric row positions, player slots, map IDs,
global and per-map music fallback values, and event/save-facing array access.
Rejuvenation's separate symbol-keyed `meta.dat` and `maps.dat` representation
was deliberately not adopted because replacing Azure's numeric arrays would
break those compatibility guarantees without improving the hot read path.

The focused runtime check compared all global fields and player profile
members, every one of the 18 possible map metadata slots across all 94 maps,
all legacy `pbGetMetadata` reads, typed aliases, string/numeric lookup, missing
map behavior, immutable array views, wrapper reuse, and post-compile cache
replacement. Candidate compilation left the active legacy and typed objects
untouched. The prior binary remains recoverable under
`tools/preservation/metadata_roundtrip/` as a `before-activation` backup.

### Named Shadow move PBS support

`shadowmoves.txt` now accepts both the original `SPECIES=MOVE,...` lines and
named sections with a required `Moves` property. Named sections reject unknown
properties, duplicate species, missing move lists, unknown references, and more
than four moves. The legacy parser retains its original permissive behavior.
The export/snapshot pipeline converts legacy lines to the named form while
emitting the same species-indexed `shadowmoves.dat` arrays.

### Controlled Shadow move-data activation

Shadow move compilation now accepts an isolated output path, can suppress
runtime cache invalidation for candidate builds, and returns the compiled
species array for verification and tooling. Normal compilation keeps
`Data/shadowmoves.dat` and explicitly evicts its `AzureDataCache` entry after
installation, preventing the stale release-mode cache that could otherwise
survive a successful in-process compile.

The 97 legacy source rows compile to 94 effective species and 226 numeric move
slots, with one to four moves per species. The candidate, prior live file, and
installed file are byte-for-byte identical at 1,671 bytes. This includes the
historical last-valid-row-wins definitions for Vanillite, Archen, and
Toxicroak, plus the permissive removal of the unknown `SHADOWSHEAD` and
`SHADOWAVE` tokens. The audit now reports all five conditions as visible
compatibility warnings rather than silently correcting or reinterpreting
authored teams.

The focused runtime check compared every compiled species row and move ID,
verified the exact effective lists for all four rows affected by a typo or
duplicate, confirmed the default `SHADOWRUSH` fallback contract, and proved
both post-compile cache replacement and subsequent cache reuse. Rejuvenation's
embedding of Shadow moves into its incompatible species objects was not
adopted; Azure's separate numeric array is already cached and remains the
authoritative input used by `makeShadow`. The prior binary remains recoverable
under `tools/preservation/shadowmove_roundtrip/` as a `before-activation`
backup.

### Controlled town-map activation

Town-map compilation now accepts isolated data and full message-database
outputs, can suppress runtime installation, and returns all source-derived
rows and message inputs for verification. It validates unique numeric region
IDs, allowed and required properties, the eight-field point schema, complete
healing triples, and referenced map image files before replacing output.

Azure's one region and 19 points remain numeric arrays, including four healing
destinations, two switch-gated points, 10 unique place names, and six unique
descriptions. The candidate, prior live file, and installed `townmap.dat` are
byte-for-byte identical at 761 bytes. The complete candidate and installed
`messages.dat` are also byte-for-byte identical to the prior 1,618,294-byte
file, so region names, hash-keyed place names, descriptions, and every
unrelated localized category are unchanged. The compiler preserves Azure's
original binary string encoding in the marshaled map while retaining the
message database's established UTF-8 keys.

Rejuvenation's incompatible symbol-keyed town-map objects were not adopted.
Its shared runtime cache was: the region map, Pokédex nest map, and habitat
screens now reuse one `AzureDataCache` load instead of reopening and
unmarshaling the file for every screen. Region-map editor mode deliberately
loads a separate mutable copy. The focused runtime check verified all point
fields and localized lookups, editor isolation, post-compile cache replacement,
and subsequent cache reuse. The prior binaries remain recoverable under
`tools/preservation/townmap_roundtrip/` as `before-activation` backups.

### Controlled map-connection activation

Map connections now accept both Azure's original six-value CSV rows and named
PBS sections with `Map1`, `Map1Point`, `Map2`, and `Map2Point`. A point can be
written as an edge plus offset, such as `East,12`, or as exact `X,Y`
coordinates. The compiler reports source-aware errors for missing or unknown
properties, invalid map IDs, malformed points, self-connections, incompatible
edges, and symmetric duplicate records. It supports isolated source/output
paths, returns the compiled records, and invalidates runtime data only when an
active output is installed.

Azure intentionally has zero active map connections. Its comment-only source,
the prior live file, isolated candidate, and installed `connections.dat` all
produce the same empty four-byte Marshal array with SHA-256
`9140C85F1B09E03F67249BAC40BEB16B5B512B8915F702F44937B9011FF7205D`.
A two-record synthetic fixture additionally proved that legacy CSV, named PBS,
named export, and visual-editor serialization generate identical six-field
arrays and identical 45-byte binaries. Invalid edge pairings and reverse-order
duplicates were rejected before output was written.

Rejuvenation's game-specific `MAPCONNECTIONSHASH` was not adopted. Its useful
runtime strategy was adapted without changing Azure's public connection array:
raw records now use `AzureDataCache`, runtime edge resolution operates on
private clones, and a per-map index supplies hot map-update queries without
rescanning every connection. Azure's dormant cross-map relative-position bug
was also corrected: it now compares both map-ID slots and applies the same
bidirectional coordinate transform used by connected-map transfers. The
focused runtime check verified cache reuse, source immutability, exact edge
resolution, index membership, both relative-position directions, editor round
tripping, compiler/editor invalidation, and restoration of the intentionally
empty installed state. Evidence and the recoverable pre-activation binary are
under `tools/preservation/connection_roundtrip/`.

### Controlled phone-data activation

Rejuvenation 14 no longer compiles or runs the legacy phone-call database, so
its removal was not portable: Azure's `PhoneDatabase`, randomized call
composition, trainer placeholders, and localized hash lookups remain
authoritative. Azure's existing sectioned `phone.txt` format is retained while
its compiler now validates the exact seven supported category names, rejects
duplicates and unknown categories, requires every category, and ensures each
contains at least one message before writing output.

Phone compilation now accepts isolated source, data, and full message-database
paths; can suppress runtime installation; returns the database, flattened
message keys, and validated source sections; and explicitly invalidates the
runtime cache when installed. The full set remains two generic messages, two
battle requests, one morning greeting, one evening greeting, five general
greetings, four first bodies, and four second bodies. The unused `trainers`
field remains an empty array for Marshal compatibility.

The prior live, isolated candidate, editor round trip, and installed
`phone.dat` are byte-identical at 1,628 bytes with SHA-256
`2C67A686FE6CA7E218C004BA1EF61A3273113E7702ECD722A13C04DB27F25BB0`.
The complete 1,618,294-byte `messages.dat` also remains byte-identical with
SHA-256
`2E2727E8CEAF66E0755D3A5362D17AFB7F4E9A365DA4D3FE31627FD217E6218D`.
A no-op-aware ordered-hash merge leaves matching localized entries and their
Marshal encoding metadata untouched while still allowing genuinely new phone
keys to be added without deleting older keys.

The editor can now export to isolated paths, and the shared section reader was
fixed to recognize its UTF-8 BOM under both older and current Ruby byte-indexing
semantics. Focused tests verified all object fields, all 19 localized lookups,
candidate runtime isolation, editor recompilation, four invalid schemas,
cache reuse, post-compile cache replacement, and both installed binary hashes.
Evidence and recoverable pre-activation binaries are under
`tools/preservation/phone_roundtrip/`.

### Controlled battle-facility data activation

Azure's organized-battle storage remains authoritative. Each compiled list is
still the exact six-field array `[trainers, pokemon, challenges,
trainer_filename, pokemon_filename, default]`; each Trainer remains the
six-field array `[type, name, begin_speech, win_speech, lose_speech,
pokemon_numbers]`; and each rental entry remains a `PBPokemon`. Challenge IDs
continue to select the first matching non-default list and otherwise fall back
to the one required default list.

The compiler now validates list sections and their optional referenced files
before replacing output. It rejects unknown or duplicate properties, missing
required filenames, multiple/missing defaults, duplicate challenge routes,
unsafe paths, unknown Trainer/Pokemon/item/nature/move constants, malformed EV
or move lists, duplicate `PokemonNos`, and indices outside the referenced
Pokemon pool. Azure's ten currently absent pool files remain intentionally
valid: all five declarations compile them as empty arrays, preserving the live
behavior of the default plus eight challenge routes. Incremental compilation
tracks any referenced pools that are later authored, and named export,
backup, and restore discover those files from `trainerlists.txt` rather than
using a stale hard-coded list.

Compilation and editor export accept isolated paths, return their compiled
objects, and update runtime messages or caches only when explicitly installing.
Both generator write paths now invalidate the shared facility cache. Read-only
runtime requests reuse the cached list object, while generator/editor calls can
still request an independent mutable copy.

The installed 344-byte legacy `trainerlists.dat` remains unchanged with
SHA-256 `362F5D7DFD2859708A5628637F884F52362085767E9FA3526219C11530D39208`.
Ruby 3's isolated compile produces a 435-byte Marshal file because it records
string-encoding metadata, but its complete decoded object graph equals the
installed file. The isolated and editor-generated message databases are
byte-identical to the installed 1,618,294-byte file with SHA-256
`2E2727E8CEAF66E0755D3A5362D17AFB7F4E9A365DA4D3FE31627FD217E6218D`.
A non-empty fixture proved every Trainer and `PBPokemon` field plus editor
round-tripping; five invalid fixtures proved failure-before-write behavior; and
focused cache checks proved reuse, mutable isolation, and invalidation.
Evidence is under `tools/preservation/battle_facility_roundtrip/`.

Rejuvenation 14 retains a disabled version of this older compiler alongside
newer game-specific `bttrainers.rb` and `btpokemon.rb` object formats. Those
typed objects and their incompatible save/data boundary were not ported. The
portable improvements are strict source validation, dependency-aware builds,
isolated compilation, recoverable authoring files, and cache invalidation—all
adapted around Azure's numeric IDs, public methods, and Marshal layouts.

### Renderer frame skipping

Rejuvenation exposes mkxp's renderer frame-skip capability. Azure now has the
same opt-in `Frame Skip` option.

- Default is Off, including old saves with no setting.
- It only changes renderer behavior; game logic and configured frame rate are
  unchanged.
- A capability check makes the setting harmless on an engine build without the
  setter.

### Recoverable PBS authoring tools

The debug menu now exposes two explicit file-management actions:

- `Export Named PBS Snapshot` writes a new timestamped directory under
  `PBS/NamedExport` without changing active source files.
- `Restore PBS Backup` can select legacy migration backups or prior restore
  safety snapshots. It first copies the current active PBS set to a new
  `PBS/RestoreBackup` directory, then restores the selected set exactly.

The tracked set includes converted databases and pass-through databases such as
types, machines, named connections, town maps, phone data, Shadow moves, and
trainer lists. Operations are recorded in `Data/pbs_tools.log`; restore never
compiles or restarts implicitly.

### Read-only in-game PBS validation

The debug menu now includes `Validate PBS Data`. It runs the preservation audit
as a separate hidden process, reports the exact check/warning/failure summary,
and writes full diagnostics to `tools/preservation/pbs_validation.log`. The
command validates schemas, symbols, references, feature contracts, duplicate
policies, and compiled-data freshness without invoking a compiler or modifying
active PBS and compiled data. A missing audit script or unavailable PowerShell
runtime produces a visible failure result instead of being treated as success.

## Execution plan from the current checkpoint

The project has completed **Phase 4: engine and tooling evaluation** and all
four gates of **Phase 5: release validation**. The preservation and
runtime work in Phases 1 through 3 is complete, and the deterministic Battle
AI closeout retains checksum `2062664973`. Remaining Phase 2 ideas are bounded
extensions for data types Azure actually uses, not prerequisites for release
work. The automated migration and release-readiness plan is complete; future
work is an extended human playtest or a newly scoped optional port.

| Phase | Status | Exit condition |
| --- | --- | --- |
| 1. Preservation and comparison | Complete | Azure-only systems are inventoried and guarded by the audit. |
| 2. PBS and data tooling | Core complete | Existing named formats, isolated compilers, caches, round trips, and developer commands remain green; optional schemas are added only for used Azure features. |
| 3. Runtime and performance | Complete | Measured hot paths, title ownership, and map ownership are resolved; the aggregate performance and behavior suite passes. |
| 4. Engine and tooling evaluation | Complete | The isolated Ruby 3.1 package, timing matrix, threading decision, and removable-tool/menu decisions pass their automated gates. |
| 5. Release validation | Complete | Clean-data, strict audit, startup, focused interaction, all-save/numeric compatibility, and evidence archive gates pass from a release candidate. |

### Phase 3 ordered steps

1. **Inventory and rank remaining sprite/UI hot paths.** Inspect per-frame
   sprite, window, battle-scene, map-scene, and menu collections for temporary
   arrays, reflection, repeated lookups, or duplicated work. Capture call
   counts, time, and allocations in representative scenes before editing. Do
   not port a Rejuvenation implementation solely because its filename or class
   has a matching Azure counterpart.
2. **Optimize one measured collection at a time.** Start with the highest
   verified cost and preserve iteration order, nil/disposed-object handling,
   visibility rules, callbacks, rescue behavior, and bitmap ownership. Each
   change gets a focused baseline/optimized fixture and its own audit contract.
3. **Finish the title-time data ownership audit.** Identify remaining compiled
   datasets loaded before title/save selection, classify each as immutable,
   mutable-runtime, or editor-owned, and extend `AzureDataCache` only for
   proven-read-only data. Mutable collections must retain explicit reload or
   invalidation behavior.
4. **Resolve the map-cache decision with evidence.** Benchmark repeated map
   loads and test event mutation, connected maps, editor/debug replacement,
   transfer callbacks, and cache invalidation. Add a small bounded cache only
   if records can be isolated safely; otherwise document the one-shot transfer
   handoff as the final design.
5. **Close Phase 3.** Rerun all stored runtime fixtures, the seeded AI decision
   closeout, the full preservation audit, and a 15-second cold startup. Record
   aggregate results and remove every temporary fixture from the script order.

The initial Step 1 inventory is recorded in
`tools/preservation/runtime_performance/sprite_ui_inventory.status.txt`.
`Scene_Map#updateSpritesets`, `Scene_Map#spriteset`, and the ten
`Game_Player`/`Game_Character` event-value scans are now optimized and
verified. The transient window-flash collection and particle/setup boundary
scans were measured or reviewed and deferred because they have no active Azure
caller or do not run in the steady-state frame path. Menu command arrays remain
excluded because those collections are returned to or retained by the UI. The
ranked sprite/UI collection pass is complete. The title-time ownership audit is
also complete: only `System` and `MapInfos` remain at the title boundary, and
all gameplay collections retain explicit cache, compiler replacement, or
mutable-engine ownership. The Step 4 map-cache decision is also complete: the
one-shot transfer handoff is the final design, and a persistent mutable-map
cache is rejected. The Step 5 closeout reconciles all 57 stored runtime
captures (55 passes and two reviewed deferrals), retains seeded AI checksum
`2062664973`, passes 176 feature contracts inside the 27-check preservation
audit, and passes a 15-second cold startup without changing either error log.
No temporary fixture remains in the production script order. Phase 3 is
complete.

### Phase 4 ordered steps

1. Build a **separate, reversible** Ruby 3.1/current mkxp-z test package. Keep
   the production executable and save path unchanged while validating script
   import, native DLLs, Win32API shims, graphics, input, audio, fonts, video,
   networking/updater behavior, and Marshal save loading.
2. Add deterministic frame-skip/turbo timing tests for messages, movement,
   timers, weather, credits, animations, play time, and any logic coupled to
   rendered frames. Frame skip remains opt-in until these tests pass.
3. Perform a thread-safety inventory before considering `ThreadLoader`.
   Background loading is eligible only for pure file/data work; RGSS graphics,
   input, message, editor, and mutable global operations stay on the main
   thread. A failed inventory closes this item without a port.
4. Package profiling and validation as removable developer tooling, then
   evaluate registry-driven menu commands only where they reduce merge cost
   while preserving every Azure visibility and enable condition.

Phase 4 Step 1 now has a reproducible isolated package builder and startup
gate. The supplied Rejuvenation runtime provides mkxp-z 2.4.2 and Ruby 3.1.3,
compared with production mkxp-z 2.1.1 and Ruby 3.0.0. The generated package
copies `Data`, external scripts, PBS, and fonts; redirects saves to a local
test directory; and uses read-only junctions only for the large Audio and
Graphics trees. Production executable, runtime DLL, configuration, compiled
data, and save files remain unchanged.

The candidate run passed cold script import, bitmap/sprite rendering,
font measurement and drawing, input update, silent audio decoding, Win32API and
MCI bridge resolution, local hostname resolution, zlib/OpenSSL loading, and a
16-object copied-save Marshal load. Azure has no movie content or active
`Scene_Movie` call site, so the dormant video path is covered at its native MCI
boundary. The updater executable and configuration are bit-identical copies
and are not launched because doing so would perform an external download; the
engine swap does not participate in that updater process. The production save
tree and both candidate error-log locations were unchanged. Step 1's automated
compatibility gate is complete.

Phase 4 Step 2 is also complete. The deterministic candidate-engine fixture
ran frame skip both off and on at Azure's base rate of 44 FPS and all four
existing turbo rates (88, 110, 132, and 176 FPS), for ten scenarios total.
Frame skip changed only render scheduling: screen tone/flash/shake/weather,
pictures, timers, character waits, eight-step movement interpolation, and the
five-even-frame animation cadence produced identical logical outcomes. Timers
expressed in the active frame rate expired after one wall-clock second,
quarter/full-second message waits and the eight-second credits slide retained
their intended wall duration, and actual paced `Graphics.update` calls stayed
inside the test tolerance.

Azure's deliberate turbo semantics are preserved rather than silently
normalized: fixed-frame waits accelerate with turbo, and recorded play time
continues to divide by the fixed 44 FPS base, advancing at the selected turbo
multiplier. The isolated package remained alive for the 25-second gate, loaded
the copied old-save fixture, left production saves and error logs unchanged,
and passed the permanent audit evidence. Step 3 is the thread-safety inventory;
no background loader is eligible until that inventory proves its work is pure
file/data processing with no RGSS or mutable-global access.

Phase 4 Step 3 is complete and closes with a rejection of the `ThreadLoader`
port. Rejuvenation's three workers evaluate 181 live scripts, publish three
main-menu datasets directly into a shared cache, and publish 22 runtime cache
loads plus two direct engine loads. Eighteen referenced cache methods can invoke
compilers when output is missing, while the runtime group also includes mutable
tilesets, animations, and common events. There is no private result object,
mutex-protected publication, or documented cross-thread contract for the engine
`load_data` API.

Azure's corresponding work is not eligible either. Its 201 scripts perform
ordered structural Ruby mutations; its remaining title boundary is only 11 ms;
and its 150 ms post-selection activation writes six globals through an
unsynchronized cache, including mutable CommonEvents. The only existing Azure
thread starts a replacement process after confirmed font installation and does
not publish live game data. The complete inventory and narrowly permitted future
worker design are recorded in `engine_test/THREAD_SAFETY_INVENTORY.md`. No
production behavior changed. Step 4 is removable profiling/validation tooling
and the evidence-driven menu-registry evaluation.

Phase 4 Step 4 is complete. `Profiler.rb` and `AzurePBSValidator.rb` are no
longer imported by production script order; `AzureDeveloperTools` loads them on
the main thread only when requested and handles an omitted optional file. F10
and F11 profiling are debug-only, profiler output moved out of active `Data` to
`tools/preservation/profiler_latest.txt`, and the validator retains its
read-only separate-process audit. The Ruby 3.1 package proved both tools were
absent from initial import, then loaded both successfully during a 25-second
gate without changing error logs or production saves.

The registry evaluation rejects a broad `MenuHandlers` port. Azure's title,
pause, party, and final CyberNav override have non-equivalent save branches,
story switches, Achievements, Safari/Bug Contest behavior, dynamic hidden-move
returns, customization actions, and load-order ownership. Those four menus are
unchanged. The 57-command debug menu retains its existing stable string-keyed
`CommandList`, which already provides the useful identity mapping without a
Proc-backed gameplay rewrite. Detailed preserved conditions and the future
extension threshold are recorded in `engine_test/MENU_REGISTRY_EVALUATION.md`.
Phase 4 is complete.

Phase 5 Step 1 is complete. A fresh Ruby 3.1 package copied all production
inputs, then compiled the complete PBS/data pipeline inside the package without
installing over the working game. All 21 present authoring sources remained
byte-identical. All 29 generated outputs matched the pre-compile package state:
26 were byte-identical, while `pokmanitems.rxdata`, `trainerlists.dat`, and
`messages.dat` were decoded-object equivalent despite Ruby Marshal encoding
metadata differences. There were no missing or mismatched outputs. The compile
finished in 5.76 seconds, and SHA-256 snapshots proved production `Data`, `PBS`,
`Scripts`, saves, and both candidate error logs were unchanged.

Phase 5 Step 2 is complete. All 59 pre-existing audit warnings were reviewed
and placed into six exact compatibility categories: 22 generated constant
duplicates, 20 duplicate PBS sections, three shared legacy numeric IDs, three
repeated item definitions, six unresolved optional-form abilities, and five
legacy Shadow-move rows. Acceptance requires both an explicit symbol/ID
allowlist and the exact category count. New, renamed, removed, or otherwise
changed warnings remain release-blocking. `Audit-Azure.ps1 -WarningsAsErrors`
now passes with 33 checks, zero unaccepted warnings, zero failures, and all 59
accepted warnings accounted for. The rationale and removal criteria are in
`release_validation/WARNING_ACCEPTANCE.md`.

Phase 5 Step 3 is complete. Production passed a forced 15-second cold startup
without changing either error log. The isolated Ruby 3.1 candidate hydrated a
real 16-object Azure save, round-tripped it only inside the package, initialized
a new game at map 39 `(24,10)`, rendered the load and debug UI paths, preserved
the six expected pause-menu commands for the test state, and consumed the exact
one-shot transfer object for map 1. Full deterministic noninteractive 1v1 and
2v2 battle cores both ended with decision 1 after one turn. The existing seeded
AI checksum remained `2062664973`, and 1,000 cached move reads completed in
approximately 0.0004 seconds. Production `Data`, `PBS`, `Scripts`, saves, and
candidate error logs were unchanged. The complete scenario map and repeatable
commands are in `release_validation/RELEASE_SMOKE_MATRIX.md`. Phase 5 Step 4 is
the final old-save/numeric-ID compatibility archive and release-readiness gate.

Phase 5 Step 4 is complete. The Ruby 3.1 candidate loaded and package-locally
round-tripped all 117 available Azure saves and historical backups: 1,872
Marshal objects, 234 stored Pokémon, and 14 distinct saved map IDs. All stored
species, item, move, and explicit ability references resolved. Full effective
symbol-to-number tables are now locked by count and SHA-256 for moves, species,
items, abilities, types, and trainer types, complementing the compiler's exact
legacy-collision policy. The preservation tools, fixtures, status captures,
and decision documents are archived by `release_validation/RELEASE_EVIDENCE.sha256`.
Production trees, saves, and candidate error logs remained unchanged. Phase 5
and the planned Rejuvenation-to-Azure modernization program are complete;
extended manual content playtesting remains a separate release activity.

### Phase 5 release steps

1. Compile from a clean copy of the active PBS sources and run every round-trip
   comparison without installing temporary outputs over user data.
2. Run the audit with zero failures, review the documented warning set, and use
   `-WarningsAsErrors` after intended duplicate cleanup or explicit acceptance.
3. Run cold startup, new-game/load-save, map transfer, editor/debug, menu,
   single/double battle, and performance smoke scenarios on the release
   candidate and the candidate engine package.
4. Verify old saves and numeric IDs, archive benchmark/audit evidence, update
   this matrix, and only then prepare the requested commit or push.

For every numbered step, the required local gate is: focused behavior parity,
focused performance evidence where applicable, `Audit-Azure.ps1` with zero
failures, `Test-Startup.ps1 -Seconds 15` with no error-log change, and an exact
restoration of `Scripts/!script_order.csv`. If a measured change is not faster
or cannot prove Azure behavior parity, revert that change and record the result
instead of carrying speculative complexity forward.

## Rejuvenation improvements still suitable for staged ports

### Priority 1: authoring and validation

1. **Finish named PBS coverage.** Types, town maps, TM compatibility, phone
   text, and battle-facility lists were already sectioned in Azure; TM
   compatibility now has strict union-preserving validation, and Shadow moves
   and map connections have dual-format named compilers. Improve property names
   in the remaining older sectioned formats without changing compiled layouts.
2. **Schema-driven validation.** Move field requirements, enums, ranges, and
   reference types into reusable schemas so compiler errors identify the
   section, property, and source line consistently.
3. **Dependency-aware incremental compilation.** Implemented. The debug menu's
   `Compile Changed Data` action compares every active source with its own
   outputs, adds transitive dependants, preserves all compiled layouts, updates
   the affected runtime caches, and writes `Data/compile_changed.log`. It never
   runs the map-event mutation pass.
4. **Deterministic duplicate policy.** Implemented. Compiler writes reject new
   or changed collisions, while the preservation audit requires the documented
   compatibility set to match the current source exactly.
5. **Round-trip tests.** For each PBS format, export, compile, and compare all
   effective compiled fields and numeric IDs before installing the converted
   source.
6. **Developer commands.** Implemented. `Validate PBS Data`, `Compile Changed
   Data`, `Compile All`, `Export Named PBS Snapshot`, and `Restore PBS Backup`
   are exposed. Validation is read-only and writes its full result log outside
   active game data; compiler and file-management actions retain their own
   result logs.

### Priority 2: typed data without a save migration

1. **Immutable encounter adapter.** Implemented with cached map/type/slot views
   and explicit compiler/editor invalidation.
2. Keep numeric IDs and old arrays as the storage/API boundary; add symbolic
   `get`, `try_get`, `exists?`, and `each` APIs for new code.
3. **Consolidate species auxiliary lookups.** Implemented for dex, level-up
   moves, egg moves, metrics, evolution, and regional-dex files while continuing
   to generate every existing compiled file.
4. **Keyed `TeamData` editing model.** Implemented through immutable runtime
   adapters and a mutable editor collection that continues to emit Azure's
   trainer arrays.
5. Add typed definitions for fields, bosses, natures, marts, field notes,
   Pokédex groups, currencies, and passwords only where Azure has or intends to
   use the corresponding feature.

### Priority 3: additional runtime work

1. Expand `AzureDataCache` to other proven-read-only compiled datasets. Debug
   hit/load/reload instrumentation is implemented.
2. **Partially implemented.** The 10 MB mutable battle-animation collection is
   deferred from title/save selection to battle startup, and the mutable
   tileset collection is deferred to first map setup. RPG Maker animations are
   deferred to the first map/event visual effect. Continue auditing other
   title-time data before attempting Rejuvenation's threaded loader.
3. **One-shot transfer handoff finalized.** Autofade and map setup share one
   destination object without retaining it after setup. The measured ownership
   closeout rejects a persistent bounded cache because `RPG::Map` event graphs
   are mutable and editor-owned; fresh loads are required to isolate changes.
4. **Map setup, event iteration, encounter selection, party-menu updates,
   battle startup, and deterministic AI decisions benchmarked.** The measured
   encounter hot path avoids three ordinary-roll arrays while retaining the
   exact RNG sequence and special ability/switch behavior. Party and shared UI
   sprite iteration no longer constructs per-frame hash arrays or reflection
   strings. Battle-animation loading remains deferred, while repeated
   common-effect lookup uses an editor-aware first-match index. AI stat and
   rough-damage scaling now reuse immutable stage tables, while seeded single-
   and double-battle fixtures preserve scores, targets, commands, switching,
   and RNG order. Continue from the measured scoring profile and port measured
   bottlenecks, not file-name-equivalent Rejuvenation code.
5. **Partially implemented.** Hot map/event loops avoid temporary values and
   reversed-page arrays while preserving callback order and refresh scope.
   Shared sprite-hash updates and party bitmap helpers now avoid per-frame
   iteration allocations. Continue auditing other sprite collections.
6. **Mutable runtime ownership audited.** Battle animations, RPG Maker
   animations, and tilesets are deferred and globally reused. Mutable editor
   collections remain outside the immutable data cache so replacement remains
   safe. Azure already has a weak bitmap cache.

### Priority 4: engine/tooling migrations

1. **Reversible Ruby 3.1/current mkxp-z package implemented and gated.** The
   production runtime and save path remain untouched while the isolated package
   validates scripts, native bridges, rendering, input/audio, networking, and
   old-save Marshal loading.
2. **Frame-skip/turbo timing matrix implemented and gated.** Ten scenarios
   cover messages, movement, timers, weather, pictures, credits, animations,
   play time, render scheduling, and Azure's intentional turbo acceleration.
3. **Thread-safety inventory complete; `ThreadLoader` port rejected.** Script
   evaluation, shared cache/global publication, compiler fallbacks, mutable RGSS
   data, and undocumented engine loader behavior fail the worker-safety gate.
   Reconsider only a private immutable-byte worker with main-thread publication
   if future profiling proves a material stall.
4. **Profiler and validator packaged as removable developer tools.** Neither is
   in release startup order; both lazy-load on demand, profiling is debug-only,
   output stays outside active data, and validation remains read-only.
5. **Registry evaluation complete; broad gameplay-menu port rejected.** Azure's
   four gameplay menu implementations and all visibility/action conditions are
   preserved. The debug menu retains its 57 stable string-keyed commands.

## Ports intentionally deferred or excluded

- Rejuvenation story content, quests, passwords, dens, pools, blessings,
  custom UI, game-specific fields, bosses, and encounters are not generic
  engine improvements and should not overwrite Azure content.
- Rejuvenation battle rules and Battle AI are not interchangeable with Azure's
  custom battle stack.
- Replacing all numeric IDs with symbols in one migration would break saves and
  event scripts; symbolic APIs must remain adapters until a versioned save/map
  migration exists.
- Direct reuse of cached mutable map objects is deferred because Azure contains
  runtime map-editing tools and event utilities.
- Background script/data loading is rejected by the completed thread-safety
  inventory; script evaluation, shared globals/cache state, compiler fallbacks,
  mutable RGSS data, and the undocumented engine loader contract fail the gate.
- A full data-object/save-format replacement is deferred; it has a much larger
  compatibility surface than the performance benefit justifies.

## Verification protocol for every subsequent task

1. Capture the affected public methods, data fields, IDs, callbacks, and side
   effects before editing.
2. Add a focused preservation contract or data/reference check.
3. Run `tools/preservation/Audit-Azure.ps1` and require zero failures.
4. Start `Game.exe`, keep it alive for at least 10 seconds, and require no
   `errorlog.txt` change.
5. Run a focused interactive or automated scenario for the subsystem (battle,
   map transfer, save/load, editor round trip, menu, etc.). A startup check is
   not sufficient proof for an interaction-heavy feature.
6. Re-run the full audit after the focused scenario and record any new known
   warnings.

The current audit has zero unaccepted warnings and 59 explicitly accepted
legacy warnings across six locked categories. All tracked compiled outputs are
current with their active PBS sources.
