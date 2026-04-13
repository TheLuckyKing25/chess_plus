class_name CurrentMove
extends RefCounted


var starting_tile: TileObject


var current_tile: TileObject:
	set(new_current_tile):
		next_tile = get_next_tile(new_current_tile, remaining_movement.direction)
		current_tile = new_current_tile


var remaining_movement: Movement:
	set(new_remaining_movement):
		next_tile = get_next_tile(current_tile, new_remaining_movement.direction)
		remaining_movement = new_remaining_movement

var next_tile: TileObject


func get_next_tile(current_tile: TileObject, direction:Movement.Direction):
	var next_tile_position: Vector2i = (
			current_tile.data.board_position
			+ Movement.neighboring_tiles[direction]
			)

	if (	next_tile_position.x > Match.board.data.rank_count-1
			or next_tile_position.x < 0
			or next_tile_position.y > Match.board.data.file_count-1
			or next_tile_position.y < 0
			):
		return # next_tile does not exist

	return Match.board.data.tile_array[
			Match.board.data.get_index(
					next_tile_position.x,
					next_tile_position.y
					)
			]
