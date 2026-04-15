class_name PropertyConveyer
extends TileModifier

# The conveyer property is similar to cog, with the exception that it automatically moves
# the player rather than changing their moveset for a turn.

func _init():
	name = "Conveyer"
	flag = ModifierType.PROPERTY_CONVEYER
	color = Color(0.5,0.5,0.5)
	can_force_movement = true
	components[DirectionComponent.NAME] = DirectionComponent.new()


#func modifier_strategy(current_move):
	#var possible_next_tile = current_move.get_next_tile(current_move.remaining_movement)
	#if (	possible_next_tile.tile != null
			#and not possible_next_tile.tile.is_occupied
			#):
		#is_forcing_next_tile = true
		#var altered_movement: Movement = Movement.new()
		#altered_movement.direction = components[DirectionComponent.NAME].value
		#altered_movement.branches.append(current_move.remaining_movement)
		#current_move.remaining_movement = altered_movement
#
	#elif not possible_next_tile.tile or possible_next_tile.tile.is_occupied:
		#is_forcing_next_tile = false


func on_turn_end(tile) -> void:
	if tile == null or tile.occupant == null:
		return

	var offset: Vector2i = Movement.neighboring_tiles[components[DirectionComponent.NAME].direction]
	var next_pos: Vector2i = tile.data.board_position + offset

	if next_pos.x < 0 or next_pos.x >= Match.board.data.rank_count:
		return
	if next_pos.y < 0 or next_pos.y >= Match.board.data.file_count:
		return

	var next_tile = Match.board.data.tile_array[Match.get_board_index(next_pos.x, next_pos.y)]
	if next_tile == null:
		return
	if next_tile.occupant != null:
		return

	Match.board.perform_move(Move.new(tile, next_tile))
	Match.board.end_turn_modifier_moved = true
