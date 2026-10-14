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

The check temporarily advances the `Scripts/!script_order.csv` timestamp with
a five-minute cache/skew margin and restores it afterward. Every invocation
therefore exercises the external-script loader's cold import path, including
on filesystems with coarse or future-skewed timestamps, and catches parse
errors that a warm launch of the existing script archive can miss.

The audit verifies the current Azure source of truth rather than comparing it
with Rejuvenation. It checks:

- sectioned PBS identifiers against the generated `PB*` modules;
- duplicate legacy identifiers;
- Pokémon, move, ability, item, type, evolution, trainer, and TM references;
- move function codes against `PokeBattle_Move_XXX` executor classes;
- the presence and script-order registration of Azure-exclusive systems;
- the presence and freshness of key compiled data outputs.

Warnings report compiled outputs that may need regeneration. Use
`-WarningsAsErrors` for a release gate after compiling the PBS data.

This is a preservation gate, not proof that every graphical or event-driven
path works. Each migration task should also run a focused smoke test for the
subsystem it changes.

See `REJUVENATION_PORT_MATRIX.md` for the implemented Rejuvenation-inspired
ports, compatibility constraints, current phase, ordered next-step checklist,
completion gates, and intentionally deferred engine migrations.
