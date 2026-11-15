# Tribute implementation

Tributes are reusable held items. The working held item applies its attunement to the first move slot. Both the Bag and party item menus use the shared attunement handler. Item suppression pauses battle effects, and in-battle item removal preserves Tributes.

| Attunement | Base behavior |
| --- | --- |
| Null | 1.3× damage |
| Meadow | 1.3× healing |
| Splash | Drains 25% of damage dealt |
| Flame | 1.5× damage on the first turn after entry |
| Blank | Uses the holder's primary type and deals 1.2× damage |
| Fist | Uses Attack and deals 1.2× damage |
| Mind | Uses Special Attack and deals 1.2× damage |
| Zap | Adds a stage to the inscribed attack's stat gains |
| Icicle | Bypasses type, ability, and move-effect blocks on the inscribed status move |
| Stone | Crushes eligible targets on hit |
| Pixie | Gives the inscribed status move a 20-power attack of the holder's primary type |
| Sky | Adds +1 priority at full HP for a single-hit attack of at most 60 power |
| Spooky | Vanishes on the first turn and strikes at 1.5× on the second |
| Dread | Adds a stage to the inscribed move's stat drops |
| Earth | Targets all other active Pokémon and removes contact |
| Iron | Goes last and deals 1.5× damage |
| Toxic | Faints the user after executing the inscribed status move |
| Insect | Bypasses accuracy and Protect-style defenses |
| Draco | Temporarily uses an assigned relearnable move in the first slot with separate battle PP |

`PBS/items.txt` defines item IDs and descriptions. `Scripts/Tributes.rb` owns the attunement unlock switches and the 90 Heroic matches. Form-specific Heroic matches take precedence. Tangrowth's Meadow form is selected in `Scripts/PokemonMultipleForms.rb`, and the remaining Heroic effects use the standard battle hooks.

Older saves migrate item IDs 1036 and 1037 to Meadow and Spooky. Save loading updates held copies and inventories and unlocks the attunement for already-owned copies.

Run the Tribute checks using the headless battle engine.

```powershell
pwsh -NoProfile -File tools/preservation/Invoke-BattleSimulation.ps1 -CatalogAudit tributes
```
