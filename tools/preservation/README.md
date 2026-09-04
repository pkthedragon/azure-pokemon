# Azure preservation audit

Run the audit from the project root before and after each modernization task:

```powershell
pwsh -NoProfile -File tools/preservation/Audit-Azure.ps1
```

Run the reusable load/startup check after the audit:

```powershell
pwsh -NoProfile -File tools/preservation/Test-Startup.ps1
```

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
ports, compatibility constraints, staged roadmap, and intentionally deferred
engine migrations.
