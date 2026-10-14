# Phase 5 Step 3: Release Interaction Smoke Matrix

## Result

The production runtime and the isolated mkxp-z 2.4.2/Ruby 3.1 candidate passed
their release interaction gates. Production completed a forced cold script
import, stayed alive for 15 seconds, and changed neither error log. The
candidate ran the normal engine, timing, and removable-developer-tool probes
before a candidate-only interaction fixture. The fixture wrote only to its
package-local save directory. SHA-256 snapshots showed no change to production
`Data`, `PBS`, `Scripts`, or saves, and neither candidate error log changed.

## Scenario matrix

| Scenario | Production/release evidence | Candidate interaction | Result |
| --- | --- | --- | --- |
| Cold startup | Forced `!script_order.csv` reimport; alive after 15 seconds; error logs unchanged | Candidate scripts imported on Ruby 3.1 and process remained alive after all fixtures | PASS |
| Old-save load | Existing Azure save copied read-only into the isolated package | Header validation and complete hydration of all 16 sequential Marshal objects; saved map 44 restored | PASS |
| Save round trip | Production save tree hash remained unchanged | All 16 objects written and reloaded inside the package; class order, trainer name, and map ID preserved | PASS |
| New game | Exact production branch constructors and start data used | Fresh runtime globals, map factory, player, storage, bag, encounters, and achievements initialized at map 39 `(24,10)` | PASS |
| Load UI | Existing Azure load panel implementation retained | Continue panel rendered, refreshed, and disposed with the old-save trainer/map data | PASS |
| Pause menu | Existing Azure visibility/action implementation retained | Headless scene received the six expected commands for this state: Bag, Achievements, trainer card, Save, Options, and Quit Game | PASS |
| Debug/editor | Static audit locks 57 debug commands and lazy developer tools | Real debug menu rendered and exited through injected Back input; keyed `CommandList` identity and all 30 tracked compiler inputs were checked | PASS |
| Map transfer | Focused 145-map parity/performance evidence remains current | Map 1 used the exact object preloaded for audio inspection, installed it, then cleared the one-shot handoff | PASS |
| Single battle | Seeded AI evidence locks scores, command, target, RNG order, and checksum | Full noninteractive 1v1 battle initialized both active slots and ended with decision 1 after one turn | PASS |
| Double battle | Seeded AI evidence locks scores, command, targets, RNG order, and checksum | Full noninteractive 2v2 battle initialized all four active slots and ended with decision 1 after one turn | PASS |
| Performance | Phase 3 has 58 reconciled captures and two documented deferrals | Runtime load, transfer, both battles, and 1,000 release cache hits were timed; cache reads took about 0.0004 seconds | PASS |

## Battle scope

The live smoke battles use Azure's actual `PokeBattle_Battle#pbStartBattle`
core and `PokeBattle_DebugSceneNoLogging`, with a deterministic scene subclass
that always chooses the first usable move and first living opposing target.
Presentation-only callbacks are no-ops, so the fixture tests battle setup,
command/AI execution, damage, judgment, and teardown without requiring human
input. This complements rather than replaces the seeded decision evidence in
`runtime_performance/ai_decision.closeout.status.txt`.

## Repeatability and isolation

Build a fresh package with:

```powershell
pwsh -NoProfile -File tools/preservation/Build-EngineTestPackage.ps1 `
  -OutputRoot tools/engine_test/package-ruby31-smoke `
  -ReleaseSmoke
```

Run its bounded gate with:

```powershell
pwsh -NoProfile -File tools/preservation/Test-ReleaseSmokePackage.ps1 `
  -PackageRoot tools/engine_test/package-ruby31-smoke
```

The runner rejects packages outside `tools/engine_test`, snapshots production
trees and saves, requires fresh PASS results from all four candidate fixtures,
checks that the candidate remains alive, and fails on any error-log mutation.
The generated package is ignored and disposable; the fixture and runner are
the permanent reproducible test assets.
