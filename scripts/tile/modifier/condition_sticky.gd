class_name ConditionSticky
extends TileModifier

# The sticky condition blocks all movement indefinitely until the tile expires.

## The number of turns that the Sticky condition remains on a tile, 
## from  [code]0[/code]  to  [code]1000[/code] .[br]
## Setting it to  [code]-1[/code]  means infinite lifetime.
@export_range(-1,1000,1.0,"suffix: turns") var lifetime: int

func _init():
	flag = ModifierEnums.TileModifierFlag.CONDITION_STICKY

func blocks_movement(board, piece, tile) -> bool:
	return true
