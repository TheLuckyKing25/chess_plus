class_name Pawn 
extends Piece


var pawn_threatening_moveset: Array[Tile] = []

var threatened_by_en_passant: bool = false
var en_passant_tile: Tile
var capture_direction: Array


func _init(player: Player, parent_tile: Tile, piece_object: Node3D):
	movement_direction = TYPE.PAWN.DIRECTION
	capture_direction = TYPE.PAWN.DIRECTION_CAPTURE
	movement_distance = TYPE.PAWN.DISTANCE_INITIAL
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

func is_en_passant_valid_from(threatened_tile:Tile):
	var new_tile_position_x = on_tile.board_position.x
	var new_tile_position_y = threatened_tile.board_position.y
	var new_tile_position = Vector2i(new_tile_position_x,new_tile_position_y)
	var piece = Tile.find_from_position(new_tile_position).occupant
	return piece is Pawn and piece.threatened_by_en_passant and threatened_tile == piece.en_passant_tile

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
		
			if is_en_passant_valid_from(tile):
				threatening_moveset.append(tile)
			
			continue
			
		if tile.is_occupied_by_piece_of(player_parent):
			continue
			
		elif occupant.is_king_of(player_parent.opponent()):
			Global.checking_tiles.append(tile)
			Global.checking_pieces.append(self)
			break
		
		threatening_moveset.append(tile)


func promote_to(placeholder_variable_piecetype: String):
	var new_piece_name = placeholder_variable_piecetype + "_" + object.name.get_slice("_", 1)
	var new_mesh = load(Piece.TYPE[placeholder_variable_piecetype.to_upper()].MESH)
	object.name = new_piece_name
	mesh_object.mesh = new_mesh
	outline_object.mesh = new_mesh
	player_parent.pawns.erase(self)
	Board.create_new_piece(player_parent, on_tile, object)
