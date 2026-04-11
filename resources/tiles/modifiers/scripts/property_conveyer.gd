class_name PropertyConveyer
extends TileModifier

# The conveyer property is similar to cog, with the exception that it automatically moves
# the player rather than changing their moveset for a turn.

enum ConveyerDirection{
	NORTH = Movement.Direction.NORTH,
	NORTHEAST = Movement.Direction.NORTHEAST,
	EAST = Movement.Direction.EAST,
	SOUTHEAST = Movement.Direction.SOUTHEAST,
	SOUTH = Movement.Direction.SOUTH,
	SOUTHWEST = Movement.Direction.SOUTHWEST,
	WEST = Movement.Direction.WEST,
	NORTHWEST = Movement.Direction.NORTHWEST,
}


@export var direction: ConveyerDirection = ConveyerDirection.EAST

func _init():
	name = "Conveyer"
	flag = ModifierType.PROPERTY_CONVEYER
	color = Color(0.5,0.5,0.5)
	can_force_movement = true


func on_turn_end(tile) -> void:
	if tile == null or tile.occupant == null:
		return

	var offset: Vector2i = Movement.neighboring_tiles[direction]
	var next_pos: Vector2i = tile.data.board_position + offset

	if next_pos.x < 0 or next_pos.x >= Match.board.data.rank_count:
		return
	if next_pos.y < 0 or next_pos.y >= Match.board.data.file_count:
		return

	var next_tile = Match.board.data.tile_array[Match.board.data.get_index(next_pos.x, next_pos.y)]
	if next_tile == null:
		return
	if next_tile.occupant != null:
		return

	Match.board.perform_move(Move.new(tile, next_tile))
	Match.board.end_turn_modifier_moved = true
