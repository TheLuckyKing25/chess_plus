## Tile Modifier Branch

All of the tile modifiers are currently implemented.

All modifiers: 
- Icy 
- Sticky
- Conveyer
- Springy
- Cog 
- Poison Trap
- Wall
- King's Favor
- Button
- Lever
- Gate
- Smokey
- Prism

All modifiers can be added to the board and customized with the modification menu before a game starts.

## Info

Each modifier has its implementation in its own script, inheriting some baseline functions from _modifier_basic.gd and expanding upon them as needed.

_apply_on_piece_enter is still being used in perform_move for Poison, King's Favor, Smokey, and Button

_apply_on_piece_pass is being used for Lever.

## TODO / KNOWN ISSUES

- NOTE: Multiple modifiers on the same tile haven't been tested yet, but SHOULD work in theory.
- BUG: Lever passthrough activation reconstructs the movement path to determine if a gate should be triggered. It does not trigger correctly if a piece's movement is modified by Prism.
- TODO: Edge cases need to be tested for pieces that have special movement, such as knights.