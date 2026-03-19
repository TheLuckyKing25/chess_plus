class_name PropertyConveyer
extends TileModifier

# The conveyer property is similar to cog, with the exception that it automatically moves
# the player rather than changing their moveset for a turn.

enum ConveyerDirection{
	NORTH = GameNode3D.Direction.NORTH,
	NORTHEAST = GameNode3D.Direction.NORTHEAST,
	EAST = GameNode3D.Direction.EAST,
	SOUTHEAST = GameNode3D.Direction.SOUTHEAST,
	SOUTH = GameNode3D.Direction.SOUTH,
	SOUTHWEST = GameNode3D.Direction.SOUTHWEST,
	WEST = GameNode3D.Direction.WEST,
	NORTHWEST = GameNode3D.Direction.NORTHWEST,
}

@export var direction: ConveyerDirection = ConveyerDirection.EAST

func _init():
	flag = GameNode3D.TileModifierFlag.PROPERTY_CONVEYER

func on_turn_end(board, tile) -> void: # conceptually the same as icy, could probably consolidate
	if tile == null or tile.occupant == null:
		return
	
	var offset: Vector2i = board.neighboring_tiles[direction]
	var next_pos: Vector2i = tile.board_position + offset
	
	if next_pos.x < 0 or next_pos.x >= board.num_board_rows:
		return
	if next_pos.y < 0 or next_pos.y >= board.num_board_columns:
		return
	
	var next_tile = board.board_array[next_pos.x][next_pos.y]
	if next_tile == null:
		return
	if next_tile.occupant != null:
		return
	
	board.move_piece_to_tile(tile.occupant, next_tile)
