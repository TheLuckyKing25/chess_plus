class_name Knight 
extends Piece


func _init(player: Player, parent_tile: Tile, piece_object: Node3D):
	movement_direction = TYPE.KNIGHT.DIRECTION
	movement_distance = TYPE.KNIGHT.DISTANCE
	object = piece_object
	player_parent = player
	on_tile = parent_tile
	mesh_color = player.color


func calculate_complete_moveset() -> void:
	complete_moveset.clear()
	for direction in movement_direction:
		var max_outward_path: Array[Tile] = []

		for distance in range(1,movement_distance+1):
			var position_transform: Vector2i 
			var new_position: Vector2i
			var new_tile: Tile 
			
			position_transform = (direction * distance * parity)
			new_position = on_tile.board_position + position_transform
			new_tile = Tile.find_from_position(new_position)
			
			if not new_tile: 
				break
			
			max_outward_path.append(new_tile)
		complete_moveset.append(max_outward_path)


func generate_valid_moveset() -> void:
	valid_moveset.clear()
	threatening_moveset.clear()
	
	for max_outward_path in complete_moveset:
		for tile in max_outward_path:
			var occupant: Piece = tile.occupant
			if occupant:
				if tile.is_occupied_by_piece_of(player_parent):
					break
	
				if occupant.is_king_of(player_parent.opponent()):
					Global.checking_tiles.append(tile)
					Global.checking_pieces.append(self)
					continue
				threatening_moveset.append(tile)
			elif not occupant:
				if tile in player_parent.opponent().king.possible_moveset:
					Global.checked_king_moveset.append(tile)
			valid_moveset.append(tile)
