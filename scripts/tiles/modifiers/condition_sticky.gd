class_name ConditionSticky
extends TileModifier

## The number of turns that the Sticky condition remains on a tile,
## from  [code]0[/code]  to  [code]1000[/code] .[br]
## Setting it to  [code]-1[/code]  means infinite lifetime.
#@export_range(-1,1000,1.0,"suffix: turns") var lifetime: int

func _init():
	name = "Sticky"
	flag = ModifierType.CONDITION_STICKY
	color = Color(0.1, 0.1, 0.1)
	icon = load("uid://8jo5aw846ekg")
	is_stopping = true
	components[LifetimeComponent.NAME] = LifetimeComponent.new()

func modifier_strategy(current_move: CustomTreeNode):
	current_move.remaining_movement.distance = 0
	current_move.remaining_movement.branches = []
