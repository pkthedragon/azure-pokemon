# Phase 4 Step 4: developer tooling and menu-registry evaluation

## Result

The profiler and PBS validator are now removable, lazily loaded developer
tools. A broad port of Rejuvenation's `MenuHandlers` registry is rejected for
Azure's title, pause, party, and CyberNav menus. Their current command ordering,
visibility conditions, indices, return values, and side effects remain
unchanged.

Azure's debug menu retains its existing `CommandList`: it already maps 57
stable string IDs to labels and dispatches on those IDs. This supplies the main
merge-safety benefit of a registry without moving gameplay actions into dozens
of load-time Proc objects.

## Removable developer tools

`Profiler.rb` and `AzurePBSValidator.rb` are no longer entries in
`Scripts/!script_order.csv`. `AzureDeveloperTools` loads either file on the main
thread only when its command is invoked. The loader checks file presence and
handles load failure, so a release package can omit both files.

- F10/F11 profiling is available only under `$DEBUG`.
- Profiling cannot be accidentally enabled by a release player.
- Profiler output moved from active `Data/Profiler.txt` to
  `tools/preservation/profiler_latest.txt`.
- `Validate PBS Data` appears when its optional tool file is present, loads the
  validator on demand, and retains its separate-process read-only audit.
- The Ruby 3.1 package proved that neither constant was preloaded or present in
  script order, then successfully loaded both optional files. The package ran
  for 25 seconds without changing error logs or production saves.

## Menu surfaces evaluated

| Surface | Azure behavior that must be preserved | Decision |
| --- | --- | --- |
| Title/load | Eight active identities with different save-present/save-absent branches, backup recovery, Mystery Gift access, language count, save-slot selection, and delete confirmation | Keep indexed builder; registry adds indirection without reducing the save-state branching |
| Pause | Ten active identities covering party/switch 986, Bug Contest, CyberNav ownership, Achievements, trainer card, Safari status/quit, save-disabled state, debug/switch 1495, and save-before-quit behavior | Reject registry port; Rejuvenation's options and conditions are not equivalent |
| Party | Summary, optional debug, four dynamic move slots, switch, mail/item, five Azure customization actions, Cancel, hidden-move returns, Fly setup, pouch restrictions, and egg rules | Reject registry port; action order and control-flow returns are tightly coupled to the selection loop |
| CyberNav | Nine active identities supplied by the later `Haru - ChangeTime` class definition, with phone data and switches 1176/1177/1210/1437/1492 | Reject registry port; registration earlier in load order could be overwritten or diverge from the final class |
| Debug | 57 stable string-keyed commands through `CommandList`, including five Azure authoring/cache commands | Retain current lightweight keyed mapping; it already avoids numeric dispatch drift |

## Why Rejuvenation's registry is not drop-in compatible

Rejuvenation's generic registry sorts Proc-backed entries by numeric order and
evaluates name, condition, and effect callbacks at runtime. Its standard pause
menu includes a direct Pokédex entry, optional quests/controls, different
trainer/debug gates, and different save/quit semantics. Azure instead routes
Pokédex through CyberNav, always exposes Achievements and the trainer card,
uses numeric story switches, and has distinct Safari/Bug Contest behavior.

The party registries also differ. Azure has five always-available non-egg
customization actions, special pouch restrictions, its own hidden-move/Fly
return protocol, and Mini Debug switch 1495. Converting these paths would be a
large behavioral rewrite with no runtime speed benefit and no demonstrated
merge-conflict reduction in this repository.

## Future extension policy

New debug-only authoring commands should continue using stable string IDs and
stay adjacent in `PokemonDebug.rb`. A generic registry should be reconsidered
only when at least two independent script modules need to add commands to the
same menu and cannot do so without repeatedly editing the menu core. Any future
conversion requires a command-by-command condition/action parity fixture before
replacing the indexed implementation.
