# Normal Act One restoration provenance

The two supplied **Act One** tabs are the roster authority. These snapshots contain only those tabs; no Intense tab values or Act Two tab values were read for the restoration.

| Source | Tab and requested range | Populated rows | Snapshot |
| --- | --- | ---: | --- |
| [2.5 Battles](https://docs.google.com/spreadsheets/d/1ovhY3NdQzoUj77cJyPk-0bMCcsEeyUnNYG5SaP_FCZA/edit) | Act One (sheet ID 0), A1:AE1023 | 234 | main-act-one.source.json |
| [2.5 Sidequest Battles](https://docs.google.com/spreadsheets/d/1_f7GuOl6d-QCgBehR3Wp5bHRMotD6PGPXWM9vRBZD6E/edit) | Act One (sheet ID 0), A1:AE1052 | 280 | sidequests-act-one.source.json |

Snapshots were retrieved on 2026-11-18. Their SHA-256 hashes, exact trainer mappings, source rows, and the 90 current Act One trainer request keys are recorded in `restoration-manifest.json`.

## Scope and sources

`PBS/trainers.txt` gains **68 Normal teams** (235 Pokemon), bringing the total to 230. **26 sheet rosters** supply 101 of those Pokemon, including both Percy partner teams. Sheet species/forms, levels, held items, moves, abilities, natures, and supplied nicknames replace historical roster fields; unspecified gender, shininess, IVs, EVs, and trainer bag items retain historical Normal metadata where available.

The additions comprise 64 deleted historical Normal teams that still have current Act One event calls, Willberg's sheet team, a separate Bruce party 50, and the two fallback teams described below. Historical generic teams come from the parent of deletion commit `3e68d817d`. Seven deleted rows are excluded: obsolete Lin, Jessie, Gail, Binacle, and Irini encounters, plus Node and Jolly battles now gated to Act Two. Existing shared and later-Act rows remain intact.

**Percy party 4 and Corin party 0 have no authored Normal roster** in either supplied tab or any of the 81 historical trainer snapshots. To repair their current Act One requests, their existing corresponding teams (Percy 204 and Corin 200) are copied as explicit Normal fallbacks. These two additions are not represented as sheet-authored rosters. The concise history audit is stored in `unspecified-normal-history-audit.json`.

## Isolation and data normalization

The runtime contract remains Normal 0, Easy 1, Intense 2. Normal normally loads the unshifted party ID; Easy tries +100 and Intense tries +200 before the original fallback behavior. Bruce's existing party 0 serves shared fallback behavior, so the sheet roster is isolated at party 50 and selected only for Normal. Its `TOXICROAKBOSS_NORMAL` overlay supplies the sheet's on-entry Psychic/Fighting type change with zero shields.

Three Normal Pokemon use the optional `AbilityOverride` trailing field: Pride's Prinplup (Defiant), Davith's Doduo (Speed Boost), and Harper's Galarian Linoone (Intimidate). Existing Pokemon rows retain their original length. Fairy Feather has its own item ID 1159 and the 20% Fairy move boost; its icon falls back to the supplied Pixie Plate artwork. Typed Hidden Power moves use the existing fixed-type identifiers. Exact move identifiers take precedence over duplicate display labels, including `HEX` over `HEXDUMMY`; the sheet's spelling `Presents` maps to `PRESENT`.

The three supplied wild boss encounters use separate `_NORMAL` definitions in `Scripts/BossInfo.rb`, alongside Bruce's zero-shield trainer boss variant. The trainer manifest does not duplicate those runtime definitions. Bruce's actual trainer sendout applies his entry typing only in Normal mode; the existing wild and Intense entry paths remain unchanged.

The Options menu maps its displayed Easy/Normal/Intense order to the authored mode values 1/0/2. The current save's mode variable takes precedence over a stale cached preference, preventing Options from overwriting an event-selected mode.

## Preservation evidence

The source edit retains **all 143,223 original file bytes**, covering all **162 original teams**, including **131 Intense teams**. The preserved prefix SHA-256 is `2b7def74b025dac220e4c3057e9bda5d8b1ad24e0044a4f82e9fdd155788a846`. Source checks confirm that all 90 current Act One request keys exist, new team keys are unique, and added item/move references resolve. `git diff --check` passes.

Native compiler/runtime verification **passed**; see `native-verification.txt`. All 162 prior compiled trainer records, all 131 Intense teams, six original boss definitions, and existing item/message entries retain their original record graphs. Seeded runtime comparisons also preserve all 131 Intense and 31 shared-fallback trainer loads, plus the three original wild boss encounters. No Act Two trainer roster was added or edited.

The engine loaded all 68 added Normal teams and verified all 101 sheet Pokemon's abilities, including form handlers. Independent source comparisons also verified species/forms, levels, natures, moves, held items and supplied nicknames. Checks covered Bruce's actual trainer startup, Psychic/Fighting typing, zero-shield defeat, 230-team ability-override export/recompile, Fairy Feather damage and UTF-8 text, and Options preserving Intense even with a stale cached setting.

The five verified compiled outputs were installed into `Data/trainers.dat`, `Data/bossdata.dat`, `Data/pokmanitems.rxdata`, `Data/messages.dat` and `Scripts/PBItems.rb`; their SHA-256 hashes are recorded in `compiled-output-manifest.json`. Existing item/message entries were retained by an append-only merge to avoid unrelated string-encoding rewrites. Trainer types and `Scripts/PBTrainers.rb` remain byte-identical. No full compiled data backups are included here.
