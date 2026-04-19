class_name PropertySpringy
extends TileModifier

# The springy property "springs" the piece that enters it to a given space on the board.

func _init():
	name = "Springy"
	flag = ModifierType.PROPERTY_SPRINGY
	components[DestinationComponent.NAME] = DestinationComponent.new()


func on_turn_end(tile) -> void:
	if tile == null or tile.occupant == null:
		return

	var target_tile = Match.board.data.tile_array[Match.get_board_index(components[DestinationComponent.NAME].vector.x, components[DestinationComponent.NAME].vector.y)]
	print("Springy target:", components[DestinationComponent.NAME].vector, " occupant:", target_tile.occupant)
	if target_tile == null:
		return
	if target_tile == tile:
		return
	if target_tile.occupant != null:
		return

	Match.board.perform_move(Move.new(tile, target_tile))
	Match.end_turn_modifier_moved = true
