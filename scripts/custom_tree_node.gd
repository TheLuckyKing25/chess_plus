class_name CustomTreeNode
extends Resource


var tile: TileObject # node data


var remaining_movement: Movement


var next_tile: Array[CustomTreeNode] # children


var is_skipped:bool = false


func _init(tile: TileObject, remaining_movement:Movement):
	self.tile = tile
	self.remaining_movement = remaining_movement.get_duplicate()

	for modifier in tile.data.modifier_order:
		modifier.modifier_stratagy(self)
		if modifier.is_forcing_next_tile:
			is_skipped = true
			return

	find_possible_next_tiles(remaining_movement) # get move tree



func find_possible_next_tiles(movement:Movement):
	if movement.distance == 0 or movement.direction == Movement.Direction.NONE:
		if movement.is_branching:
			for branch in movement.branches:
				next_tile.append(get_next_tile(branch))
			return
		else:
			return # end of movement
	next_tile.append(get_next_tile(movement))


func get_next_tile(movement:Movement):
	var next_tile_position: Vector2i = (
			tile.data.board_position
			+ Movement.neighboring_tiles[movement.direction]
			)

	if (	next_tile_position.x > Match.board.data.rank_count-1
			or next_tile_position.x < 0
			or next_tile_position.y > Match.board.data.file_count-1
			or next_tile_position.y < 0
			):
		return # next_tile does not exist

	movement.distance -= 1
	return CustomTreeNode.new(
		Match.board.data.tile_array[
				Match.board.data.get_index(
						next_tile_position.x,
						next_tile_position.y
						)], movement)
