## Tile Modifier Branch

The following are currently implemented: 
- Icy 
- Sticky
- Conveyer
- Springy
- Cog 
- Poison Trap
- Wall
- King's Favor*
- Button
- Lever*
- Gate

All modifiers can be added to the board and customized with the modification menu before a game starts.

## Info

All logic for adding and editing modifiers on the board can be found in tile_modifier_menu.gd.

Each modifier has its implementation in its own script, inheriting some baseline functions from _modifier_basic.gd and expanding upon them as needed.

Modifiers use hooks such as on_piece_enter and on_turn_end during _resolve_branching_movement to interact with gameplay.

The remainder of the logic, like when modifiers are applied and game logic, can be found in move_list.gd and board_object.gd.

Turn-end modifiers, like Conveyer, are applied in a loop until no more movement occurs. This allows chain reactions like Conveyer into another Conveyer to work properly.

## TODO / KNOWN ISSUES

- NOTE: Cog currently changes a pieces moveset while standing on it, rather than rotating a pieces remaining moves in a turn.
- NOTE: Multiple modifiers on the same tile haven't been tested yet, but SHOULD work in theory.
- NOTE: King's Favor currently triggers the promotion menu correctly, but promotion logic seems to be unfinished, so it doesn't actually do anything yet.
- NOTE: Lever currently only triggers on the tile, not yet for passing through.
- NOTE: Button toggles gates within radius once per piece occupancy (does not retrigger every turn while occupied).
- TODO: Pieces still need to be affected when passing through modifiers, not just landing on them.
- TODO: Edge cases need to be tested for pieces that have special movement, such as knights.
- TODO: Add the Prism and Smoke modifiers.
- TODO: Add custom icons so each modifier is visually distinct.
- BUG: Deleting a modifier from the customization section of the modification menu will cause the game to crash if you try to place said modifier afterward.