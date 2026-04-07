class_name PropertySpringy
extends TileModifier

# The springy property "springs" the piece that enters it to a given space on the board.

@export var destination: Vector2i = Vector2i(4, 4)

func _init():
	name = "Springy"
	flag = ModifierType.PROPERTY_SPRINGY

func on_turn_end(tile) -> void:
	if tile == null or tile.occupant == null:
		return

	if destination.x < 0 or destination.x >= Match.board_data.rank_count:
		return
	if destination.y < 0 or destination.y >= Match.board_data.file_count:
		return

	var target_tile = Match.board_data.tile_array[Match.board_data.get_index(destination.x, destination.y)]
	print("Springy target:", destination, " occupant:", target_tile.occupant)
	if target_tile == null:
		return
	if target_tile == tile:
		return
	if target_tile.occupant != null:
		return

	Match.board_object.perform_move(Move.new(tile, target_tile))
	Match.board_object.end_turn_modifier_moved = true
