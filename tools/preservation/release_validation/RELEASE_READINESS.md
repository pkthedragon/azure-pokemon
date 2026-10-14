# Phase 5 Step 4: Release Readiness

## Decision

Phase 5's automated release-validation scope is complete and the current tree
is ready to commit and push. This is a technical release-readiness decision,
not a claim that every story branch has received a human playthrough.

## Save compatibility

The candidate package copied every `.rxdata` save and historical backup from
the Azure save directory into a read-only fixture set. All 117 files loaded on
mkxp-z 2.4.2/Ruby 3.1.3, each with the expected 16-object sequential Marshal
layout. The run covered 1,872 objects, 234 stored Pokémon, and saves located on
maps 1, 5, 6, 8, 9, 14, 15, 19, 20, 44, 57, 88, 138, and 140.

Every file was written and loaded again only under the isolated package. The
object-class sequence, trainer identity, and saved map ID remained exact. All
stored Pokémon species, item, move, and explicit ability IDs resolved against
the current generated tables. Production saves were hash-checked before and
after and did not change.

## Numeric-ID lock

The compatibility fixture hashes the full effective integer-constant mapping,
sorted as `SYMBOL=ID`, for each persisted numeric namespace. The release gate
locks both count and SHA-256 digest:

| Namespace | Count | SHA-256 |
| --- | ---: | --- |
| Moves | 1,079 | `0698488654ADE273CB354A5474C0D52DA42B0598734C02DA921560297347D0CC` |
| Species | 1,034 | `BF299CCB7DA6862918DFA9E505062AA42A2DAAACF893488B162059EFBF0C45F2` |
| Items | 1,114 | `75A18582607BDE884C9BE2C6E8EBCFDCA600A565B9BB500C09FC1FE04914ED7B` |
| Abilities | 376 | `BCA84D9F2B26D63657A4D74DCA4AF1CB48E773B95D457A420304C3C57D0FA5C8` |
| Types | 21 | `1DBED5B28B1DB112973E749FA04C4D56B2DFA0E4D74E9C0BF365E3C31B44DE49` |
| Trainer types | 278 | `D4FC0484BE9DA081D698EC39336E202ECCB434AB32298EE008EBB3525F30CD7F` |

This complements the compiler's exact duplicate-symbol/ID policy. Any future
renumbering changes the digest and requires an explicit, versioned save and
event-data migration rather than silently passing release validation.

## Evidence archive

`RELEASE_EVIDENCE.sha256` records deterministic, LF-normalized SHA-256 hashes
for the preservation tools, fixtures, phase status captures, and decision documents.
`New-ReleaseEvidenceManifest.ps1 -Verify` rejects a missing, changed, duplicate,
or unexpected evidence entry. Generated candidate packages and local runtime
logs are intentionally excluded.

## Final automated gate

Release readiness requires all of the following at the same revision:

- clean isolated PBS compilation with 29 equivalent generated outputs;
- strict audit with zero failures and zero unaccepted warnings;
- exactly 59 reviewed warnings in six locked compatibility categories;
- production cold startup with unchanged error logs;
- candidate runtime, timing, tooling, interaction, and save-compatibility gates;
- deterministic single/double Battle AI checksum `2062664973`;
- unchanged production `Data`, `PBS`, `Scripts`, and save trees;
- a verified release evidence manifest and an exact production script order.

Manual extended story/event playtesting remains the appropriate follow-up for
content paths that cannot be made deterministic without changing gameplay.
