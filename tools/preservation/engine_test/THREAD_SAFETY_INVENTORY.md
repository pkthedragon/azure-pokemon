# Phase 4 Step 3: thread-safety inventory

## Decision

Do not port Rejuvenation's `ThreadLoader` into Azure. The inventory is complete,
and none of the three worker scopes meets Azure's requirement that background
work be private, immutable file/data processing with publication performed on
the main thread. This is a closed rejection, not an unmeasured deferral.

Azure keeps script import, compiled-data activation, compiler fallbacks, RGSS
objects, mutable globals, and editor-owned data on the main thread. No production
code changes are needed for this step.

## Rejuvenation worker inventory

| Worker | Work performed | Synchronization boundary | Azure result |
| --- | --- | --- | --- |
| Script loader | Evaluates 181 external Ruby scripts, loads mods, mutates constants/classes/method tables and global event handlers | Joined before leaving the intro | Reject: evaluation mutates the live Ruby program and has no isolated publication step |
| Main-menu data | Calls three cache methods for the Pokédex, metadata, and map infos and assigns them directly into shared `$cache` | Joined immediately before the load-menu scene starts | Reject: shared cache publication is unsynchronized; the Pokédex method may invoke a compiler |
| Runtime data | Calls 22 cache methods and two direct `load_data` operations, then assigns all results into shared `$cache` | Joined before new-game/load-save runtime setup | Reject: includes 18 compile-capable cache methods plus mutable tilesets, RPG animations, common events, and battle-animation data |

Rejuvenation deliberately falls back to synchronous loading on Kirin because
thread joining is unreliable there. Its worker bodies contain no mutex around
`$cache`, no private result object, and no main-thread atomic publication phase.
The fact that its join points usually avoid consumers seeing partial state does
not make the writers themselves safe against reset, compiler, mod, or engine API
interactions.

## Azure boundary inventory

| Boundary | Current behavior | Measured cost | Eligibility |
| --- | --- | ---: | --- |
| External script import | mkxp imports 201 ordered Ruby files before `Main` | Covered by the cold-start gate | Reject: structural Ruby mutation and top-level registrations must remain ordered and synchronous |
| Title data | Loads mutable `System` plus cached immutable `MapInfos` | 0.011164 s, 3,827 allocations | Reject: there is no material latency left to hide and `System` is an engine-owned mutable object |
| Gameplay activation | Loads CommonEvents and five immutable compiled tables, assigning six globals | 0.150072 s, 25,318 allocations | Reject as currently written: globals and `AzureDataCache` module state are unsynchronized, and `load_data` has no documented cross-thread contract |
| Map/event visual data | Lazily loads tilesets and RPG animations | Outside title/runtime activation | Reject: both are mutable RGSS/editor-owned collections |
| Existing Azure thread | Starts a replacement game process after a successful font installation, then immediately exits | User-confirmed maintenance path | Retain: it does not read or publish live game data |

The prior title-time ownership work already removes 0.064487 seconds and 21,671
allocations from the title boundary without concurrency. The remaining gameplay
activation is short, deterministic, idempotent, and happens only after the user
chooses Continue, New Game, or Mystery Gift.

## Unsafe operations that must remain on the main thread

- Evaluating scripts or mods and changing constants, classes, methods, event
  handlers, or load order.
- Assigning `$data_common_events`, `$pkmn_dex`, `$pkmn_move`, `$pkmn_egg`,
  `$ItemData`, `$bosscache`, or any editor/runtime global.
- Reading, replacing, invalidating, or collecting statistics in the current
  unsynchronized `AzureDataCache` entry hashes.
- Invoking compiler fallbacks, message/UI methods, Graphics, Input, Audio,
  Bitmap, Sprite, RPG Maker data editors, or map setup.
- Loading or publishing mutable CommonEvents, tilesets, maps, RPG animations,
  or battle animations.
- Assuming mkxp's `load_data` and archive/path resolution APIs are safe on a
  worker thread without an explicit engine guarantee.

## Only acceptable future background design

A later implementation may be reconsidered only if profiling identifies a new
material stall. A worker would be limited to ordinary Ruby file reads into a
private immutable byte buffer, with no globals, cache access, compiler fallback,
RGSS object construction, engine APIs, messages, or editor interaction. The
main thread would join the worker, validate the complete result, deserialize if
needed, and atomically publish it. Cancellation/reset behavior and worker errors
would need focused tests before such a path could become production code.

That design is not justified by the current 11 ms title boundary or 150 ms
post-selection activation boundary, so Phase 4 Step 3 closes with no
`ThreadLoader` port.

## Preservation checks

- Production contains no `ThreadLoader` implementation.
- The only `Thread.new` site remains the font-install restart process.
- The Ruby 3.1 candidate package, full 29-check preservation audit, and cold
  production startup passed before this inventory was recorded.
- Step 3 changes documentation and audit evidence only; gameplay behavior and
  loading ownership remain unchanged.
