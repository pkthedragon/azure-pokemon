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

Ability-adjusted encounter weights and high-level ability rolls now work on
per-roll clones. This preserves their intended one-roll effect without
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
- `MapInfos` lookups used by transitions, roaming, messages, and map names.
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
2. Preload title-screen data first and defer nonessential runtime data until a
   save is selected. This should be staged before attempting Rejuvenation's
   threaded loader.
3. Add a bounded map cache only after proving cached `RPG::Map` records are
   immutable. A safe design must invalidate edited maps and must not preserve
   transient event-page mutations across transfers.
4. Benchmark map setup, event refresh, encounter generation, party menus,
   battle startup, and AI turns before optimizing. Port measured bottlenecks,
   not file-name-equivalent Rejuvenation code.
5. Audit large per-frame event loops and sprite allocations. Preserve callback
   order and event timing when introducing indexes or object reuse.
6. Consider cached battle animation and tileset objects only with explicit
   ownership/refcount tests; Azure already has a weak bitmap cache.

### Priority 4: engine/tooling migrations

1. Test a Ruby 3.1/current mkxp-z executable as a separate engine package.
   Validate Win32API shims, audio, input, fonts, videos, save Marshal loading,
   updater behavior, and every native DLL before replacing Azure's executable.
2. Add frame-skip/turbo timing tests so messages, timers, weather, credits, and
   play time remain based on intended game time.
3. Evaluate Rejuvenation's asynchronous `ThreadLoader` only after all data
   loaders are thread-safe and no RGSS graphics or message APIs are called off
   the main thread.
4. Add profiler and validator developer builds. Profiling must be removable
   from release builds and validation must never mutate game data.
5. Adopt registry-driven menu/pause/party commands where it reduces merge
   conflicts, while retaining every Azure command and its enable/visibility
   conditions.

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
- Background script/data loading is deferred because a startup smoke test
  cannot prove thread safety.
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

The current audit has 59 known warnings, all from documented duplicate or
aliased legacy IDs and sections. All tracked compiled outputs are current with
their active PBS sources.
