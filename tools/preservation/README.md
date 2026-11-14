# Azure preservation audit

## Command-line battle simulation

On Windows with PowerShell 7.2 or later, run a scenario from the project root.

```powershell
pwsh -NoProfile -File tools/preservation/Invoke-BattleSimulation.ps1 `
  -Scenario tools/preservation/engine_test/battle_scenarios/ai-triples.json `
  -Report "$env:TEMP/azure-battle.txt"
```

The runner starts the bundled battle engine on a private Windows desktop with
no visible game window. It uses an isolated runtime and save directory. The
real engine resolves moves, switching, abilities, held items, field effects,
and damage. The production trainer AI controls both teams, with optional
scripted commands for specific turns. Trainer bag items and overworld
progression are outside the simulation.

Omit `-Report` to print the transcript to the terminal. Use `-Seed 150` to
override the scenario seed, or `-TimeoutSeconds 180` to extend the process
timeout. Repeat the same scenario and seed on the same build to compare logs.

The [example scenarios](engine_test/battle_scenarios) include a single-battle
faint and reserve send-out, Wide Guard and Gravity in doubles, an AI-vs-AI
triple, simultaneous Binding Word traps, and a Commander lane shift that
cancels Tatsugiri's queued attack. Copy an example and edit its JSON to build
another scenario.

- Set `format` to `single`, `double`, or `triple`. Give each team's `party`
  enough Pokémon for its starting lanes. Additional Pokémon start on the
  bench. Pokémon use uppercase PBS identifiers for `species` and `moves`.
  Optional fields include `ability`, `item`, `level`, `form`, and starting `hp`.
- Set `seed`, `max_turns`, numeric `field`, or named `weather` as needed. The
  defaults are seed 1, 50 turns, no field effect, and no weather.
- In `actions`, specify a one-based `turn` and a zero-based battler `slot`.
  Player lanes are 0, 2, and 4. Opponent lanes are 1, 3, and 5. Give each
  action one of `move` (with optional `target` slot), `switch` (zero-based
  party index), or `shift` (allied battler slot). The AI chooses any action
  you leave unspecified.
- Use `expect` for ordered, case-sensitive log fragments and `reject` for
  fragments that must never occur. Invalid or unused scripted commands and
  failed assertions make the runner exit with a nonzero status.

`CHOOSE` records what was queued. `TARGET` records a target the engine actually
processed, and `HP` shows the resulting change. `STATE` includes HP, stat
stages, abilities, held items, active traps, and Commander links. The final
`result=PASS` means the scenario and its assertions completed. The separate
`OUTCOME` line identifies a win, draw, or turn limit.

Run the full ability regression suite with:

```powershell
pwsh -NoProfile -File tools/preservation/Test-Abilities.ps1
```

Run the 150 individual move checks and four shared mechanics regressions
without opening a game window. The report prints a result for each move.

```powershell
pwsh -NoProfile -File tools/preservation/Invoke-BattleSimulation.ps1 -MoveRegressions
```

## Preservation checks

Run the audit from the project root before and after each modernization task:

```powershell
pwsh -NoProfile -File tools/preservation/Audit-Azure.ps1
```

Run the reusable load/startup check after the audit:

```powershell
pwsh -NoProfile -File tools/preservation/Test-Startup.ps1
```

The startup check watches both the project log and mkxp-z's active Windows
`Saved Games/<Game.ini Title>/errorlog.txt`; a newly written error in either
location fails the check even if the game process remains alive.

The startup check performs four bounded launches: a forced cold miss, a warm
hit, an edited-script invalidation miss, and a restored-source warm hit. Every
launch must write a tokenized probe only after `Main` reaches the title
bootstrap, remain alive, and leave both error logs unchanged. A live process
or watchdog dialog without the title probe is a failure. The invalidation pass
temporarily changes only `Scripts/Settings.rb`'s timestamp, prevents that pass
from replacing the good cache, and restores the exact timestamp in `finally`.

`Data/Scripts.rxdata` is generated from the tracked
`AzureExternalScriptBootstrap.rb`. The runtime loader fingerprints the script
manifest plus every referenced source file's size and modification time,
caches unchanged source in `Data/AzureExternalScripts.cache`, and calls
`Graphics.update` at bounded intervals while importing and evaluating scripts
so mkxp-z never mistakes a cold import for a hung RGSS thread. Rebuild or verify
the embedded bootstrap with:

```powershell
pwsh -NoProfile -File tools/preservation/Build-ScriptBootstrap.ps1
pwsh -NoProfile -File tools/preservation/Build-ScriptBootstrap.ps1 -Verify
```

The audit verifies the current Azure source of truth rather than comparing it
with Rejuvenation. It checks:

- sectioned PBS identifiers against the generated `PB*` modules;
- duplicate legacy identifiers;
- Pokémon, move, ability, item, type, evolution, trainer, and TM references;
- move function codes against `PokeBattle_Move_XXX` executor classes;
- the presence and script-order registration of Azure-exclusive systems;
- the presence and freshness of key compiled data outputs.

The 59 reviewed legacy warnings are classified by exact symbol/ID allowlists
and counts. Use `-WarningsAsErrors` for the release gate; it fails on every
unaccepted warning while requiring the accepted set to remain exact.

Phase 5 release gates are reproducible with the package builder and the three
focused runners:

```powershell
pwsh -NoProfile -File tools/preservation/Test-ReleaseCompilePackage.ps1
pwsh -NoProfile -File tools/preservation/Test-ReleaseSmokePackage.ps1
pwsh -NoProfile -File tools/preservation/Test-ReleaseCompatibilityPackage.ps1
pwsh -NoProfile -File tools/preservation/New-ReleaseEvidenceManifest.ps1 -Verify
```

The generated packages stay under ignored `tools/engine_test/` directories;
their fixtures use package-local save paths and never install outputs into the
working game.

This is a preservation gate, not proof that every graphical or event-driven
path works. Each migration task should also run a focused smoke test for the
subsystem it changes.

See `REJUVENATION_PORT_MATRIX.md` for the implemented Rejuvenation-inspired
ports, compatibility constraints, current phase, ordered next-step checklist,
completion gates, and intentionally deferred engine migrations.
