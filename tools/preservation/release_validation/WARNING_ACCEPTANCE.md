# Phase 5 Step 2: Warning Acceptance

## Result

The Azure preservation audit's 59 existing warnings have been reviewed and
classified into six exact compatibility categories. They are accepted as
known legacy state, not treated as repaired or hidden. The audit removes a
warning from the release-blocking set only when its message matches a known
category, its symbol or ID is explicitly allowlisted, and every category has
the expected count. A new symbol, changed alias, new warning type, missing
accepted warning, or count drift produces an audit failure.

`Audit-Azure.ps1 -WarningsAsErrors` therefore means "fail on every unaccepted
warning." It passes only while all 59 accepted warnings continue to match the
reviewed policy and the unaccepted count remains zero.

## Accepted categories

### Generated constant duplicates: 22

The generated Ruby constant modules contain ten move, one species, three item,
six ability, and two trainer-type duplicate assignments. Ruby's last
assignment is Azure's established effective mapping. The compiler's
`AZURE_LEGACY_DUPLICATE_SYMBOLS` contract independently rejects any new,
removed, or changed symbolic collision. Renumbering these constants without a
versioned save, map-event, and compiled-data migration would break numeric
compatibility.

Exit criterion: replace this acceptance only as part of an explicit ID
migration that updates all persisted and event-script consumers.

### PBS duplicate sections: 20

The source PBS files contain the source counterparts of the reviewed constant
duplicates: ten moves, Iron Moth in both species and metrics, six abilities,
and two trainer types. The legacy compiler uses the later section for the
effective symbolic mapping. Their symbol allowlist and total are fixed by the
audit, while line numbers may move when unrelated source rows are edited.

Exit criterion: consolidate a section only after verifying its effective
record is unchanged and regenerating all dependent data in an isolated compile.

### Shared legacy numeric IDs: 3

Move IDs 318 and 680 and species ID 306 are established numeric aliases. The
compiler's `AZURE_LEGACY_DUPLICATE_IDS` contract locks their exact symbol pairs.
They are preserved because saves, events, and compiled records can contain
these numeric values.

Exit criterion: remove an alias only through a versioned migration with old
save and representative event-map coverage.

### Repeated item definitions: 3

`GREENKEY`, `TM115`, and `TM116` each occur twice in the legacy item source.
The later numeric mapping remains effective, consistent with the generated
constants and compiler policy.

Exit criterion: consolidate only after proving byte/semantic compiled-data
equivalence and numeric save compatibility.

### Unresolved optional abilities: 6

`CUTEINFATUATE`, `PURIFYING`, `SEGUE`, `AFTERLIFE`, `FLAMEEATER`, and
`KEYHOLDER` are referenced by optional form definitions but have no authored
ability data/ID. The existing `getID` behavior leaves those optional slots
unavailable. Inventing IDs or effects would create new game behavior rather
than preserve Azure functionality.

Exit criterion: author and test the intended data and battle behavior, then
remove the corresponding symbol from the acceptance list.

### Shadow-move legacy rows: 5

Two source rows reference the unknown spellings `SHADOWSHEAD` and `SHADOWAVE`,
which the permissive parser drops. Later rows for `VANILLITE`, `ARCHEN`, and
`TOXICROAK` replace earlier rows according to the existing last-valid-row
behavior. The audit fixes the exact affected move/species allowlist.

Exit criterion: correct or consolidate these rows only with a preservation
fixture that confirms the intended effective species-to-move table.

## Release rule

The standard audit summary reports only unaccepted warnings. A separate
accepted-warning line reports the reviewed total and category count. Release
validation requires zero failures, zero unaccepted warnings, exactly 59
accepted warnings across the six categories above, and a successful
`-WarningsAsErrors` execution.
