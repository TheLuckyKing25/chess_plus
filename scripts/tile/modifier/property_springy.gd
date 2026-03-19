class_name PropertySpringy
extends TileModifier

# The springy property "springs" the piece that enters it to a given space on the board.

@export var destination: Vector2i = Vector2i(4, 4)

func _init():
	flag = GameNode3D.TileModifierFlag.PROPERTY_SPRINGY

func on_turn_end(board, tile) -> void:
	if tile == null or tile.occupant == null:
		return
	
	if destination.x < 0 or destination.x >= board.num_board_rows:
		return
	if destination.y < 0 or destination.y >= board.num_board_columns:
		return
	
	var target_tile = board.board_array[destination.x][destination.y]
	print("Springy target:", destination, " occupant:", target_tile.occupant)
	if target_tile == null:
		return
	if target_tile == tile:
		return
	if target_tile.occupant != null:
		return
	
	board.move_piece_to_tile(tile.occupant, target_tile)
