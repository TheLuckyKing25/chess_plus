class_name ConditionIcy
extends TileModifier

## The number of turns that the Icy condition remains on a tile, 
## from  [code]0[/code]  to  [code]1000[/code] .[br]
## Setting it to  [code]-1[/code]  means infinite lifetime.
@export_range(-1,1000,1.0,"suffix: turns") var lifetime: int

const flag = GameNode3D.TileModifierFlag.CONDITION_ICY
