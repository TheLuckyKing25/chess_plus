extends Node3D

signal tile_selected(tile:Node3D)

signal move_processed(piece: Node3D, move: Dictionary, castling_rook: Node3D)

signal rook_discovered(piece: Node3D, direction: Game.Direction)

signal castle()

@export var board_position: Vector2i

@export var occupant: Node3D = null:
	set(piece):
		if en_passant_occupant:
			en_passant_occupant = null
		if castling_occupant:
			castling_occupant = null
		occupant = piece

var en_passant_occupant: Node3D = null

var castling_occupant: Node3D = null

var checked_by: Array = []

var moveset: MoveRule

var neighboring_tiles: Dictionary[int, Node3D] = {
	Game.Direction.NORTH: null,
	Game.Direction.NORTHEAST:null,
	Game.Direction.EAST:null,
	Game.Direction.SOUTHEAST:null,
	Game.Direction.SOUTH:null,
	Game.Direction.SOUTHWEST:null,
	Game.Direction.WEST:null,
	Game.Direction.NORTHWEST:null
}


func _on_ready():
	tile_selected.connect(Callable(owner,"_on_tile_selected"))
	board_position = Vector2i(name.substr(6,1).to_int(),name.substr(8,1).to_int())
	match (board_position.x + board_position.y) % 2:
		0: $Tile_Object.tile_color = Game.COLOR_PALETTE.TILE_COLOR_LIGHT
		1: $Tile_Object.tile_color = Game.COLOR_PALETTE.TILE_COLOR_DARK
	occupant = find_child("*_P*", false, true)


func _on_rook_discovered(rook, direction):
	moveset = MoveRule.new(MoveRule.MoveType.BRANCH,-1,0)
	for move_rule in occupant.castling_move_rules:
		if move_rule.direction == direction:
			moveset.branches.append(move_rule)
	_on_moves_recieved(occupant, moveset.decode_into_movement(), rook)


func _on_occupant_selected():
	set_tile_state_flag(Game.TileStateFlag.TILE_STATE_FLAG_SELECTED)
	moveset = MoveRule.new(MoveRule.MoveType.BRANCH,-1,0,occupant.move_rules)
	_on_moves_recieved(occupant, moveset.decode_into_movement())
	if occupant.is_in_group("King") and not occupant.is_in_group("has_moved"):
		moveset = MoveRule.new(MoveRule.MoveType.BRANCH,-1,0,occupant.rook_finding_move_rules)
		_on_moves_recieved(occupant, moveset.decode_into_movement())


func _on_occupant_unselected():
	unset_tile_state_flag(Game.TileStateFlag.TILE_STATE_FLAG_SELECTED)
	moveset = MoveRule.new(MoveRule.MoveType.BRANCH,-1,0,occupant.move_rules)
	_on_moves_recieved(occupant, moveset.decode_into_movement())
	if occupant.is_in_group("King") and not occupant.is_in_group("has_moved"):
		moveset = MoveRule.new(MoveRule.MoveType.BRANCH,-1,0,occupant.rook_finding_move_rules)
		_on_moves_recieved(occupant, moveset.decode_into_movement())


func _on_input_event(
		camera: Node, 
		event: InputEvent, 
		event_position: Vector3, 
		normal: Vector3, 
		shape_idx: int
) -> void:
	if (	owner.selected_piece
			and event is InputEventMouseButton
			and event.is_pressed()
			and event.button_index == MOUSE_BUTTON_LEFT
			):
		var mouse_pos = event.position
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos)*1000
		var space_state = get_world_3d().direct_space_state
		var result = space_state.intersect_ray(
				PhysicsRayQueryParameters3D.create(from,to)
				)
		if result and _is_valid_move():
			var clicked_object = result.collider.get_parent()	
			tile_selected.emit(self)


func _is_valid_move():
	return (	
			tile_state_flag_is_enabled(Game.TileStateFlag.TILE_STATE_FLAG_SPECIAL_MOVEMENT) 
			or tile_state_flag_is_enabled(Game.TileStateFlag.TILE_STATE_FLAG_MOVEMENT) 
			or (	tile_state_flag_is_enabled(Game.TileStateFlag.TILE_STATE_FLAG_THREATENED) 
					and en_passant_occupant
					)
			)

func _on_castle():
	castling_occupant.piece_clicked.emit(castling_occupant)
	tile_selected.emit(self)

func _toggle_rook_castling_tile_connection(assigned_move):
	if neighboring_tiles[assigned_move.direction].is_connected("castle", Callable(self,"_on_castle")):
		neighboring_tiles[assigned_move.direction].castle.disconnect(Callable(self,"_on_castle"))
	else:
		neighboring_tiles[assigned_move.direction].castle.connect(Callable(self,"_on_castle"))


func _on_moves_recieved(piece:Node3D, moves, castling_rook: Node3D = null):
	var assigned_move: MoveRule
	
	if typeof(moves) == TYPE_ARRAY:
		assigned_move = moves.pop_front()
	elif moves is MoveRule:
		assigned_move = moves
	
	
	if assigned_move.move_flag_is_enabled(MoveRule.MoveType.CHECK):
		
		if occupant and not occupant.is_in_group("King") and occupant != piece: return
		if not assigned_move.move_flag_is_enabled(MoveRule.MoveType.THREATEN): return
			
		checked_by.append(piece)
		
		if not (occupant and occupant.is_in_group("King") and occupant.player != piece.player): return
		
		if occupant.piece_state_flag_is_enabled(Game.PieceStateFlag.PIECE_STATE_FLAG_CHECKED):
			print("END GAME")
			
		toggle_tile_state_flag(Game.TileStateFlag.TILE_STATE_FLAG_CHECKED)
		occupant.toggle_piece_state_flag(Game.PieceStateFlag.PIECE_STATE_FLAG_CHECKED)
	
	elif (	assigned_move.move_flag_is_enabled(MoveRule.MoveType.CASTLING) 
			and assigned_move.move_flag_is_enabled(MoveRule.MoveType.JUMP)
			):
				
		if checked_by: return
			
		if assigned_move.move_flag_is_enabled(MoveRule.MoveType.SPECIAL):
			toggle_tile_state_flag(Game.TileStateFlag.TILE_STATE_FLAG_SPECIAL_MOVEMENT)
			return
		else:
			castling_occupant = castling_rook
			castling_occupant.toggle_piece_state_flag(Game.PieceStateFlag.PIECE_STATE_FLAG_SPECIAL)
			_toggle_rook_castling_tile_connection(assigned_move)
			
	elif assigned_move.move_flag_is_enabled(MoveRule.MoveType.CASTLING):
		if occupant:
			if (	occupant.is_in_group("Rook") 
					and not occupant.is_in_group("has_moved")
					and occupant.player == piece.player
					):
				_send_to_king(piece, occupant, assigned_move.direction)
			return
	else:
		if (	occupant 
				and assigned_move.move_flag_is_enabled(MoveRule.MoveType.THREATEN) 
				and occupant.player != piece.player
				):
			toggle_tile_state_flag(Game.TileStateFlag.TILE_STATE_FLAG_THREATENED)
			occupant.toggle_piece_state_flag(Game.PieceStateFlag.PIECE_STATE_FLAG_THREATENED)
		
		if (	occupant
				and not assigned_move.move_flag_is_enabled(MoveRule.MoveType.JUMP) 
				and occupant != piece
				): 
			return
			
		if not occupant and assigned_move.move_flag_is_enabled(MoveRule.MoveType.MOVEMENT):
			toggle_tile_state_flag(Game.TileStateFlag.TILE_STATE_FLAG_MOVEMENT)
			if piece.is_in_group("King") and checked_by.size() != 0:
				toggle_tile_state_flag(Game.TileStateFlag.TILE_STATE_FLAG_THREATENED)
		
		
		if (	piece.is_in_group("Pawn")
				and not piece.is_in_group("has_moved") 
				and abs(piece.get_parent().board_position - board_position) == Vector2i(1,0)
				):
			en_passant_occupant = piece
		
		if (	piece.is_in_group("Pawn") 
				and en_passant_occupant 
				and assigned_move.move_flag_is_enabled(MoveRule.MoveType.THREATEN) 
				and en_passant_occupant.player != piece.player
				):
			toggle_tile_state_flag(Game.TileStateFlag.TILE_STATE_FLAG_THREATENED)
			en_passant_occupant.toggle_piece_state_flag(Game.PieceStateFlag.PIECE_STATE_FLAG_THREATENED)


	if moves is MoveRule and assigned_move.move_flag_is_enabled(MoveRule.MoveType.BRANCH):
		for move_path in assigned_move.branches:
			if move_path is MoveRule:
				move_path = move_path.decode_into_movement()
			if neighboring_tiles[move_path[0].direction]:
				_send_to_tile(piece, move_path, move_path[0].direction, castling_rook)
	elif typeof(moves) == TYPE_ARRAY:
		if moves.size() == 1 and neighboring_tiles[moves[0].direction]:
			_send_to_tile(piece, moves[0], moves[0].direction, castling_rook)
		elif moves.size() > 1 and neighboring_tiles[moves[0].direction]:
			_send_to_tile(piece, moves, moves[0].direction, castling_rook)
		

func clear_checks():
	checked_by = []
	unset_tile_state_flag(Game.TileStateFlag.TILE_STATE_FLAG_CHECKED)
	if occupant:
		occupant.unset_piece_state_flag(Game.PieceStateFlag.PIECE_STATE_FLAG_CHECKED)


func discover_checks():
	if occupant:
		moveset = MoveRule.new(MoveRule.MoveType.BRANCH|MoveRule.MoveType.CHECK,-1,0,occupant.move_rules)
		_on_moves_recieved(occupant, moveset.decode_into_movement())


func set_tile_state_flag(flag: Game.TileStateFlag):
	$Tile_Object.state |= 1 << flag
	$Tile_Object.apply_state()


func toggle_tile_state_flag(flag: Game.TileStateFlag):
	$Tile_Object.state ^= 1 << flag
	$Tile_Object.apply_state()
	
	
func tile_state_flag_is_enabled(flag: Game.TileStateFlag):
	return $Tile_Object.state & (1 << flag)


func unset_tile_state_flag(flag: Game.TileStateFlag):
	$Tile_Object.state &= ~(1 << flag)
	$Tile_Object.apply_state()


func is_neighbor(tile: Node3D) -> bool:
	var neighbor_x = tile.board_position.x
	var neighbor_y = tile.board_position.y
	var neighbor_x_diff = abs(neighbor_x - board_position.x)
	var neighbor_y_diff = abs(neighbor_y - board_position.y)
	return (
			neighbor_x_diff == 1 and neighbor_y_diff == 0
			or neighbor_x_diff == 0 and neighbor_y_diff == 1
			or neighbor_x_diff == 1 and neighbor_y_diff == 1
			) 


func clear_en_passant(player:int):
	if en_passant_occupant and en_passant_occupant.player == player:
		en_passant_occupant = null


func clear_castling_occupant():
	if castling_occupant and castling_occupant.is_in_group("has_moved"):
		castling_occupant = null


func find_neighbors():
	var neighbors: Array[Node] = get_tree().get_nodes_in_group("Tile").filter(is_neighbor)
	for tile in neighbors:
		var position_difference = board_position - tile.board_position
		match position_difference:
			Vector2i(-1,0): 
				neighboring_tiles[Game.Direction.NORTH] = tile
			Vector2i(-1,1): 
				neighboring_tiles[Game.Direction.NORTHEAST] = tile
			Vector2i(0,1): 
				neighboring_tiles[Game.Direction.EAST] = tile
			Vector2i(1,1): 
				neighboring_tiles[Game.Direction.SOUTHEAST] = tile
			Vector2i(1,0): 
				neighboring_tiles[Game.Direction.SOUTH] = tile
			Vector2i(1,-1): 
				neighboring_tiles[Game.Direction.SOUTHWEST] = tile
			Vector2i(0,-1): 
				neighboring_tiles[Game.Direction.WEST] = tile
			Vector2i(-1,-1): 
				neighboring_tiles[Game.Direction.NORTHWEST] = tile


func _send_to_tile(piece:Node3D, moves, direction: Game.Direction, castling_rook:Node3D = null):
	move_processed.connect(Callable(neighboring_tiles[direction],"_on_moves_recieved"))
	move_processed.emit(piece, moves, castling_rook)
	move_processed.disconnect(Callable(neighboring_tiles[direction],"_on_moves_recieved"))


func _send_to_king(king:Node3D, rook: Node3D, direction: Game.Direction):	
	rook_discovered.connect(Callable(king.get_parent(),"_on_rook_discovered"))
	rook_discovered.emit(rook, direction)
	rook_discovered.disconnect(Callable(king.get_parent(),"_on_rook_discovered"))
