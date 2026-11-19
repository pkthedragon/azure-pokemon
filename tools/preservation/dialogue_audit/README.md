# Event dialogue and Logium place-name audit

Reviewed all 145 map files (2,895 events, 4,549 pages, 5,963 message blocks)
and all 100 common events (514 message blocks).

Added 2,839 name boxes: 2,377 map messages across 62 maps and 462 common-event
messages. Removed one redundant `Warren:` prefix from an already named message.
The reviewable before/after text and speaker evidence are in
`dialogue-changes.tsv`. Pages are numbered from one; command indices from zero.

Speaker decisions follow authored labels, introductions, established story
characters, local exchanges, and movement cues. Unlabelled continuations were
reviewed individually. Generic trainers were not named from battle metadata.
Written books/inscriptions, narration, item and level-cap notices, Pokemon cries,
machine prompts, and unattributed player pauses remain unboxed. Intentional
hidden identities stay `???` until their introductions.

The library attic scene is Map049 EV004 page 1: 19 Minerva messages and nine
Percy messages now have boxes. Command 56, the player's silent response, remains
plain. Percy retains his own box for the farewell after Minerva leaves.

Replaced the old A/B/C town wording with Logium Shore/Uptown/Port in event
dialogue, taxi choices and matching branches, region-map labels, source metadata,
and the Lighthouse Key description. The shorthand “Logium Town A and B” now
names both Shore and Uptown. Historical PBS backups and the internal tileset
asset filename are preserved.

## Validation

- Compared every property of all 145 maps and CommonEvents before and after.
  Only approved message strings and town-name substitutions differ. Command
  codes/order/indentation, event conditions, switches, variables, movement,
  graphics, collision, and all raw tile-table payloads are unchanged.
- Reloaded each candidate through native Ruby Marshal and compared its complete
  structural signature with the intended result before installation.
- Verified all 2,840 installed message edits and scanned all event commands again:
  no old A/B/C wording remains.
- Verified compiled Messages/OrderedHash strings and key order without a broad
  recompile. Only 49 place-name references changed, with no key collisions.
  The region map changes only three labels. Modern item data changes only item
  662's description; legacy item data preserves the other 1,090 record payloads.
- Recorded hashes for every changed file in `file-manifest.json`; scan and edit
  totals are in `summary.json`.

All 26 representative native `Interpreter#command_101` checks passed, including
the attic, later story scenes, TV speaker changes and quoted dialogue. Named
windows rendered visible text, removed their control/inline labels from the body,
and disposed correctly; four narration/notification controls stayed unboxed.
Native region-map, modern/legacy item and OrderedHash/message lookups passed,
including a scan of all 30,292 compiled message-string references. Results are
recorded in `native-smoke.txt`.
