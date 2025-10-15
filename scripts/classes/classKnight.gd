class_name Knight 
extends Piece

func _init(player: Player, parent_tile: Tile, piece_object: Node3D):
	movement_direction = Global.KNIGHT_MOVEMENT_DIRECTIONS
	movement_distance = Global.MovementDistance.KNIGHT
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
		for tile in path:
			var occupant = 	tile.occupant
			if occupant:
				if occupant in player_parent.pieces:
					break
	
				if occupant.is_opponent_king(player_parent):
					Global.threaten_king_tiles.append(tile)
					Global.threaten_king_pieces.append(self)
					continue
				valid_threatening_movements.append(tile)
			elif not occupant:
				if tile in Global.opponent(player_parent).king.full_valid_movements:
					Global.threaten_king_movement.append(tile)
			valid_movements.append(tile)
