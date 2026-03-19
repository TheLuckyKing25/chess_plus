## Tile Modifier Branch

The following are currently implemented: 
- Icy 
- Sticky
- Springy
- Conveyer
- Cog 

All modifiers can be added to the board and customized with the modification menu before a game starts.

## Info

All logic for adding and editing modifiers on the board can be found in tile_modifier_menu.gd.

Each modifier has its implementation in its own script, inheriting some baseline functions from modifier_basic.gd and expanding upon them as needed.

The remainder of the logic, like when modifiers are applied and game logic, can be found in game_board.gd.

Turn-end modifiers, like Conveyer, are applied in a loop until no more movement occurs. This allows chain reactions like Conveyer into another Conveyer to work properly.

## TODO / KNOWN ISSUES

- NOTE: I read the Cog description wrong at first, so currently it changes a pieces moveset while standing on Cog, rather than rotating a pieces remaining moves in a turn.
- NOTE: Multiple modifiers on the same tile haven't been tested yet, but SHOULD work in theory.
- TODO: Pieces still need to be affected when passing through modifiers, not just landing on them.
- TODO: Edge cases need to be tested for pieces that have special movement, such as knights.
- TODO: Add the remaining properties.
- BUG: Deleting a modifier from the customization section of the modification menu will cause the game to crash if you try to place said modifier afterward.