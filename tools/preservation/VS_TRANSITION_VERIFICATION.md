# VS transition rendering regression

## Reproduction

Use the actual Kara battle condition from Map006 EV023 page 2, command 58,
through `Interpreter#update` and `pbTrainerBattle`, with a live `Scene_Map`.
Compare ordinary entry with entry immediately after `Graphics.freeze`.

Before the fix, both runs reported a handled, 168-update VS animation. Ordinary
entry advanced the native `Graphics.frame_count` by 168 in 4.17 seconds. Frozen
entry advanced it by **zero**, completing the same Ruby animation loops in
0.36 seconds. The battle could then proceed normally after its own transition.

Snapshots at animation updates 35, 80 and 128 were byte-identical between the
working and frozen runs. `Graphics.snap_to_bitmap` renders the scene graph even
when the native display is frozen; snapshots alone cannot verify presentation.
No explicit freeze was found in Kara's events, so this reproduces a display-state
failure, rather than establishing where the player's run acquired that state.

## Change

The custom VS intro releases an inherited freeze with `Graphics.transition(0)`
before its first animation update. Bars use pre-tiled sprite strips with a moving
source rectangle, and portraits, text, logo and flashes have explicit layers.
The two bar canvases are allocated once (512 KiB total at 512 by 384 resolution)
and disposed after their sprites. Scrolling performs no bitmap redraws.

The Normal/Intense trainer data and artwork are unchanged.

## Native verification

The actual Map006 EV023 interpreter route passed against the workspace game
executable and runtime:

| Entry state | Before: presented frames | After: presented frames |
| --- | ---: | ---: |
| Ordinary | 168 | 168 |
| Inherited `Graphics.freeze` | 0 | 168 |

The fixed ordinary and frozen runs took 4.16 and 3.86 seconds respectively.
Animation snapshots at updates 35, 80 and 128 match the working pre-fix control
exactly, including both portraits and the scrolling bars.

Kara and Percy each completed all 168 updates and entered battle. In an
18-stage comparison per trainer, every VS band from update 10 through 168
matched the working baseline pixel-for-pixel. The visible bars also matched
at updates 1 and 5; the overworld behind them differed. At reveal, all opaque
source portrait pixels matched: Troy 12,008; Kara 10,236; Percy 10,368.

The isolated package's executable, `mkxp.json`, `Game.ini`, Ruby/RGSS DLLs and
script bootstrap matched the workspace files exactly. Source scripts were
loaded from the tested workspace copy.

## Reusable check

`engine_test/AzureVsTransitionFixture.rb` runs the actual Kara event in both
entry states, checks native frame advancement, captures update 80, and verifies
that battle-entry state is restored. It also includes a frozen negative control.

Copy the fixture into `Data/Mods` in an isolated temporary game package. Set
`AZURE_VS_REPORT` to an absolute report filename and `AZURE_VS_OUTPUT` to an
existing output directory, and launch the package with a temporary save profile.
The fixture exits after writing `result=PASS` or `result=FAIL`; it must never be
added to the production script order.

The reusable fixture was run against both versions. The old helper failed on
inherited freeze (168 logical updates, zero native frames) and exited cleanly.
The fixed helper passed both cases (168 logical updates and native frames each),
with the frozen negative control still reporting zero native frames.
