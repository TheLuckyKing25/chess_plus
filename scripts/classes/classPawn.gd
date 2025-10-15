class_name Pawn 
extends Piece

var pawn_threatening_movement: Array[Tile] = []
var capture_direction

func _init(player: Player, parent_tile: Tile, piece_object: Node3D):
	movement_direction = Global.PAWN_MOVEMENT_DIRECTIONS
	capture_direction = Global.PAWN_CAPTURE_DIRECTIONS
	movement_distance = Global.MovementDistance.PAWN_INITIAL
	object_piece = piece_object
	player_parent = player
	tile_parent = parent_tile

func calculate_all_movements():
	pawn_threatening_movement = []
	all_movements = []
	var path: Array[Tile] = []

	for distance in range(1,movement_distance+1):
		var position_transform = (movement_direction[0] * distance * parity)
		var new_position = tile_parent.board_position + position_transform
		var new_tile = Global.find_tile_from_position(new_position)
		
		if not new_tile: 
			break
	
		path.append(new_tile)
	all_movements.append(path)
	
	for direction in capture_direction:
		var position_transform = (direction * parity)
		var new_position = tile_parent.board_position + position_transform
		var new_tile = Global.find_tile_from_position(new_position)
		
		if not new_tile: 
			break
		pawn_threatening_movement.append(new_tile)

func validate_movements():
	valid_movements = []
	valid_threatening_movements = []
	
	for tile in all_movements[0]:
		if tile.occupant:
			break
		else:
			valid_movements.append(tile)
			
	for tile in pawn_threatening_movement:
		var occupant = 	tile.occupant
		if not occupant:
			
			if tile in Global.opponent(player_parent).king.full_valid_movements:
				Global.threaten_king_movement.append(tile)
			continue
		
			
		if occupant in player_parent.pieces:
			break
			
		elif occupant.is_opponent_king(player_parent):
			Global.threaten_king_tiles.append(tile)
			Global.threaten_king_pieces.append(self)
			break
		valid_threatening_movements.append(tile)
		break

			
				
