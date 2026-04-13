class_name ConditionIcy
extends TileModifier

func _init():
	name = "Icy"
	flag = ModifierType.CONDITION_ICY
	color = Color(0.75, 1, 1)
	icon = load("uid://cw82lp67yuedh")
	components[LifetimeComponent.NAME] = LifetimeComponent.new()

func modifier_strategy(current_move: CustomTreeNode):
	var possible_next_tile:CustomTreeNode = current_move.get_next_tile(current_move.remaining_movement)
	if (	possible_next_tile.tile != null
			and not possible_next_tile.tile.is_occupied
			):
		is_forcing_next_tile = true
		current_move.append(possible_next_tile.next_tile)
	elif not possible_next_tile.tile or possible_next_tile.tile.is_occupied:
		is_forcing_next_tile = false
