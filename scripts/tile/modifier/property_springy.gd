class_name PropertySpringy
extends TileModifier

# The springy property "springs" the piece that enters it to a given space on the board.

@export var destination: Vector2i = Vector2i(4, 4)

func _init():
	flag = ModifierEnums.TileModifierFlag.PROPERTY_SPRINGY

func on_turn_end(board, tile) -> void:
	if tile == null or tile.occupant == null:
		return
	
	if destination.x < 0 or destination.x >= board.data.rank_count:
		return
	if destination.y < 0 or destination.y >= board.data.file_count:
		return
	
	var target_tile = board.data.tile_array[board.data.get_index(destination.x, destination.y)]
	print("Springy target:", destination, " occupant:", target_tile.occupant)
	if target_tile == null:
		return
	if target_tile == tile:
		return
	if target_tile.occupant != null:
		return
	
	board.perform_move(Move.new(tile, target_tile))
	board.end_turn_modifier_moved = true
