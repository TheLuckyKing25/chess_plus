class_name Bishop 
extends Piece

func _init(player: Player, parent_tile: Tile, piece_object: Node3D) -> void:
	movement_direction = Global.BISHOP_MOVEMENT_DIRECTIONS
	movement_distance = Global.MovementDistance.BISHOP
	object = piece_object
	player_parent = player
	tile_parent = parent_tile
	mesh_color = player.color

func calculate_complete_moveset():
	complete_moveset = []
	for direction in movement_direction:
		var max_outward_path: Array[Tile] = []

		for distance in range(1,movement_distance+1):
			var position_transform = (direction * distance * parity)
			var new_position = tile_parent.board_position + position_transform
			var new_tile = Global.tile_from_position(new_position)
			
			if not new_tile: 
				break

			max_outward_path.append(new_tile)
		complete_moveset.append(max_outward_path)

func generate_valid_moveset():
	valid_moveset = []
	threatening_moveset = []
	
	for max_outward_path in complete_moveset:
		var valid_path: Array[Tile] = []
		var king_check = false
		for tile in max_outward_path:
			var occupant = 	tile.occupant
			if occupant:
				if tile.is_occupied_by_friendly_piece_of(player_parent):
					break
				if king_check:
					break
			
				
				if occupant.is_opponent_king_of(player_parent):
					Global.checking_tiles += valid_path
					Global.checked_king_moveset.append(valid_path.back())
					Global.checking_pieces.append(self)
					king_check = true
					continue
					
				threatening_moveset.append(tile)
				break
			elif not occupant:
				if king_check:
					Global.checked_king_moveset.append(tile)
					break
				elif tile in Global.opponent(player_parent).king.possible_moveset:
					Global.checked_king_moveset.append(tile)
				valid_path.append(tile)
				continue
		valid_moveset.append_array(valid_path)
