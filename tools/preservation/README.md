# Azure preservation audit

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
