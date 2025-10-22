class_name Pawn 
extends Piece


var pawn_threatening_moveset: Array[Tile] = []


var capture_direction: Array


func _init(player: Player, parent_tile: Tile, piece_object: Node3D):
	movement_direction = DIRECTION[Type.PAWN][0]
	capture_direction = DIRECTION[Type.PAWN][1]
	movement_distance = DISTANCE[Type.PAWN][0]
	object = piece_object
	player_parent = player
	on_tile = parent_tile
	mesh_color = player.color


func calculate_complete_moveset() -> void:
	pawn_threatening_moveset.clear()
	complete_moveset.clear()
	var max_outward_path: Array[Tile] = []

	for distance in range(1,movement_distance+1):
		var position_transform: Vector2i 
		var new_position: Vector2i
		var new_tile: Tile 
		
		position_transform = (movement_direction[0] * distance * parity)
		new_position = on_tile.board_position + position_transform
		new_tile = Tile.find_from_position(new_position)
		
		if not new_tile: 
			break
	
		max_outward_path.append(new_tile)
	complete_moveset.append(max_outward_path)
	
	for direction in capture_direction:
		var position_transform: Vector2i 
		var new_position: Vector2i
		var new_tile: Tile 
		
		position_transform = (direction * parity)
		new_position = on_tile.board_position + position_transform
		new_tile = Tile.find_from_position(new_position)
		
		if not new_tile: 
			break
		pawn_threatening_moveset.append(new_tile)


func generate_valid_moveset() -> void:
	valid_moveset.clear()
	threatening_moveset.clear()
	
	for tile in complete_moveset[0]:
		if tile.occupant:
			break
		else:
			valid_moveset.append(tile)
			
	for tile in pawn_threatening_moveset:
		var occupant: Piece = tile.occupant
		if not occupant:
			
			if tile in player_parent.opponent().king.possible_moveset:
				Global.checked_king_moveset.append(tile)
			continue
		
			
		if tile.is_occupied_by_piece_of(player_parent):
			break
			
		elif occupant.is_king_of(player_parent.opponent()):
			Global.checking_tiles.append(tile)
			Global.checking_pieces.append(self)
			break
		threatening_moveset.append(tile)
		break
