class_name Queen 
extends Piece

func _init(player: Player, parent_tile: Tile, piece_object: Node3D) -> void:
	movement_direction = Global.QUEEN_MOVEMENT_DIRECTIONS
	movement_distance = Global.MovementDistance.QUEEN
	object_piece = piece_object
	player_parent = player
	tile_parent = parent_tile

func calculate_all_movements():
	all_movements = []
	for direction in movement_direction:
		var path: Array[Tile] = []

		for distance in range(1,movement_distance+1):
			var position_transform = (direction * distance * parity)
			var new_position = tile_parent.board_position + position_transform
			var new_tile = Global.find_tile_from_position(new_position)
			
			if not new_tile: 
				break

			path.append(new_tile)
		all_movements.append(path)

func validate_movements():
	valid_movements = []
	valid_threatening_movements = []
	
	for path in all_movements:
		var valid_path: Array[Tile] = []
		var king_check = false
		for tile in path:
			var occupant = 	tile.occupant
			if occupant:
				if occupant in player_parent.pieces:
					break
				if king_check:
					break
			
				
				if occupant.is_opponent_king(player_parent):
					Global.threaten_king_tiles += valid_path
					Global.threaten_king_movement.append(valid_path.back())
					Global.threaten_king_pieces.append(self)
					king_check = true
					continue
					
				valid_threatening_movements.append(tile)
				break
			elif not occupant:
				if king_check:
					Global.threaten_king_movement.append(tile)
					break
				elif tile in Global.opponent(player_parent).king.full_valid_movements:
					Global.threaten_king_movement.append(tile)
				valid_path.append(tile)
				continue
		valid_movements += valid_path
