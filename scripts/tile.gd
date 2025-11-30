extends Game


signal tile_selected(tile:Node3D)


signal move_processed(piece: Piece, move: Dictionary, castling_rook: Piece)


signal rook_discovered(piece: Piece, direction: Direction)


signal castle


@export var board_position: Vector2i


@export var occupant: Piece = null:
	set(piece):
		if en_passant_occupant:
			en_passant_occupant = null
		if castling_occupant:
			castling_occupant = null
		occupant = piece

var modifier_flags: int = 0:
	set(new_modifier_flags):
		var difference: int = new_modifier_flags - modifier_flags
		if difference > 0:
			modifier_order.push_front(difference)
		elif difference < 0:
			modifier_order.erase(abs(difference))
		modifier_flags = new_modifier_flags

@export var modifier_order: Array[TileModifierFlag] = []:
	set(new_modifier_order):
		if modifier_order.size() > new_modifier_order.size():
			tile_modifiers(modifier_order[-1],unset_flag_func)
		elif modifier_order.size() < new_modifier_order.size():
			tile_modifiers(new_modifier_order[-1],set_flag_func)
		elif modifier_order.size() == new_modifier_order.size():
			for modifier in modifier_order:
				if modifier != new_modifier_order[modifier_order.find(modifier)-1]:
					tile_modifiers(modifier,unset_flag_func)
					tile_modifiers(new_modifier_order[modifier_order.find(modifier)-1],set_flag_func)
				
		modifier_order = new_modifier_order
		$Tile_Object/Tile_Modifiers.modifiers = modifier_order


var en_passant_occupant: Piece = null


var castling_occupant: Piece = null


var checked_by: Array[Piece] = []


var moveset: MoveRule

var set_flag_func = Callable(self,"set_flag")
var unset_flag_func = Callable(self,"unset_flag")
var toggle_flag_func = Callable(self,"toggle_flag")
var flag_is_enabled_func = Callable(self,"flag_is_enabled")

var modifier_function_dict: Dictionary[TileModifierFlag,Callable] = {
	TileModifierFlag.CONDITION_ICEY: Callable(self,"flag_is_enabled")
}

var neighboring_tiles: Dictionary[int, Node3D] = {
	Direction.NORTH: null,
	Direction.NORTHEAST:null,
	Direction.EAST:null,
	Direction.SOUTHEAST:null,
	Direction.SOUTH:null,
	Direction.SOUTHWEST:null,
	Direction.WEST:null,
	Direction.NORTHWEST:null
}

func _on_ready() -> void:
	tile_selected.connect(Callable(owner,"_on_tile_selected"))
	board_position = Vector2i(name.substr(6,1).to_int(),name.substr(8,1).to_int())
	match (board_position.x + board_position.y) % 2:
		0: $Tile_Object.tile_color = COLOR_PALETTE.TILE_COLOR_LIGHT
		1: $Tile_Object.tile_color = COLOR_PALETTE.TILE_COLOR_DARK
	occupant = find_child("*_P*", false, true)
	$Tile_Object/Tile_Modifiers.modifiers = modifier_order


func _on_rook_discovered(rook, direction) -> void:
	moveset = MoveRule.new(ActionType.BRANCH, PurposeType.CASTLING,0,0)
	for move_rule in occupant.castling_move_rules:
		if move_rule.direction == direction:
			moveset.branches.append(move_rule.new())
	_on_moves_recieved(occupant, moveset, rook)


func _on_occupant_selected() -> void:
	tile_state(TileStateFlag.SELECTED, set_flag_func)
	moveset = MoveRule.new(ActionType.BRANCH, PurposeType.STANDARD_MOVEMENT,0,0)
	for move_rule in occupant.move_rules:
		moveset.branches.append(move_rule.new())
	_on_moves_recieved(occupant, moveset)
	if piece_is_king(occupant) and not piece_has_moved(occupant):
		moveset = MoveRule.new(ActionType.BRANCH, PurposeType.ROOK_FINDING,0,0)
		for move_rule in occupant.rook_finding_move_rules:
			moveset.branches.append(move_rule.new())
		_on_moves_recieved(occupant, moveset)


func _on_input_event(
		camera: Node, 
		event: InputEvent, 
		event_position: Vector3, 
		normal: Vector3, 
		shape_idx: int
		) -> void:
	if ( 	owner.selected_piece
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
		if result and _is_valid_move_state():
			var clicked_object = result.collider.get_parent()	
			tile_selected.emit(self)


func _is_valid_move_state() -> bool:
	return (	
			tile_state(TileStateFlag.SPECIAL, flag_is_enabled_func)
			or tile_state(TileStateFlag.MOVEMENT, flag_is_enabled_func)
			or (	
					tile_state(TileStateFlag.THREATENED, flag_is_enabled_func) 
					and en_passant_occupant
			)
	)


func _on_castle() -> void:
	castling_occupant.piece_clicked.emit(castling_occupant)
	tile_selected.emit(self)


func _toggle_rook_castling_tile_connection(assigned_move) -> void:
	if neighboring_tiles[assigned_move.direction].is_connected("castle", Callable(self,"_on_castle")):
		neighboring_tiles[assigned_move.direction].castle.disconnect(Callable(self,"_on_castle"))
	else:
		neighboring_tiles[assigned_move.direction].castle.connect(Callable(self,"_on_castle"))


func _on_moves_recieved(source_piece: Piece, moves, castling_rook: Piece = null) -> void:
	
	#tile conditions and properties
	for modifier in modifier_order:
		
		if (	
				tile_modifiers(TileModifierFlag.PROPERTY_COG,flag_is_enabled_func)
				and modifier == TileModifierFlag.PROPERTY_COG
				):
			moves.rotate_clockwise()
		if (
				tile_modifiers(TileModifierFlag.CONDITION_STICKY,flag_is_enabled_func)
				and modifier == TileModifierFlag.CONDITION_STICKY
				):
			moves.distance = 0
		if (
				tile_modifiers(TileModifierFlag.CONDITION_ICEY,flag_is_enabled_func) 
				and modifier == TileModifierFlag.CONDITION_ICEY
				and not piece_is_knight(source_piece)
				and neighboring_tiles[moves.direction] 
				and (
						not neighboring_tiles[moves.direction].occupant
						or piece_is_opponent_of(neighboring_tiles[moves.direction].occupant, source_piece)
						)
				and not pieces_are_different(source_piece, occupant)
				):
			_send_to_tile(source_piece, moves, moves.direction, castling_rook)
			return
	
	
	#DETERMINE TILE STATE FROM MOVES
	var assigned_move: MoveRule = moves
	if moves.distance > 0:
		moves.distance -= 1
	
	if assigned_move.is_checking_movement():
		if assigned_move.is_threatening():
			checked_by.append(source_piece)
			
			if piece_is_opponent_of(source_piece, occupant):	
				if not piece_is_king(occupant): return
				if occupant.piece_state(PieceStateFlag.CHECKED,flag_is_enabled_func):
					print("END GAME")
				tile_state(TileStateFlag.CHECKED, set_flag_func)
				occupant.piece_state(PieceStateFlag.CHECKED,set_flag_func)
				return
		
	elif assigned_move.is_castling_movement():
		if checked_by: return
		
		if assigned_move.action_flag_is_enabled(ActionType.SPECIAL) and assigned_move.distance == 0:
			tile_state(TileStateFlag.SPECIAL, set_flag_func)
			return
		
		castling_occupant = castling_rook
		castling_occupant.piece_state(PieceStateFlag.SPECIAL,set_flag_func)
		_toggle_rook_castling_tile_connection(assigned_move)
			
	elif assigned_move.is_finding_castling_rook():
		if occupant and pieces_are_different(source_piece, occupant):
			if _piece_is_valid_castling_rook(source_piece, occupant):
				_send_to_king(source_piece, occupant, assigned_move.direction)
			return
	else:
		if (	piece_is_opponent_of(source_piece, occupant) 
				and assigned_move.is_threatening()
			):
			tile_state(TileStateFlag.THREATENED, set_flag_func)
			occupant.piece_state(PieceStateFlag.THREATENED,set_flag_func)
		
		if move_is_blocked(assigned_move, source_piece, occupant): 
			return
			
		if (	not occupant 
				and assigned_move.action_flag_is_enabled(ActionType.MOVE)
			):
			tile_state(TileStateFlag.MOVEMENT, set_flag_func)
			if piece_is_king(source_piece) and checked_by.size() != 0:
				tile_state(TileStateFlag.THREATENED, set_flag_func)
		
		
		if _piece_threatened_by_en_passant(source_piece):
			en_passant_occupant = source_piece
		
		if _piece_is_threat_to_en_passant_piece(source_piece, assigned_move, en_passant_occupant):
			tile_state(TileStateFlag.THREATENED, set_flag_func)
			en_passant_occupant.piece_state(PieceStateFlag.THREATENED,set_flag_func)


	#SEND MOVES TO NEIGHBORING TILES
	if moves.distance == 0 and moves.is_branching_movement():
		for branching_move in moves.branches:
			branching_move.purpose = moves.purpose
			if neighboring_tiles[branching_move.direction]:
				_send_to_tile(source_piece, branching_move, branching_move.direction, castling_rook)
	elif moves.distance > 0:
		_send_to_tile(source_piece, moves, moves.direction, castling_rook)
		

func clear_checks() -> void:
	checked_by = []
	tile_state(TileStateFlag.CHECKED, unset_flag_func)
	if occupant:
		occupant.piece_state(PieceStateFlag.CHECKED,unset_flag_func)


func clear_move_states() -> void:
	tile_state(TileStateFlag.SELECTED, unset_flag_func)
	tile_state(TileStateFlag.MOVEMENT, unset_flag_func)
	tile_state(TileStateFlag.THREATENED, unset_flag_func)
	tile_state(TileStateFlag.SPECIAL, unset_flag_func)
	if occupant:
		occupant.piece_state(PieceStateFlag.THREATENED,unset_flag_func)
		occupant.piece_state(PieceStateFlag.SPECIAL,unset_flag_func)


func discover_checks() -> void:
	if occupant:
		moveset = MoveRule.new(ActionType.BRANCH, PurposeType.CHECK_DETECTING,0,0)
		for move_rule in occupant.move_rules:
			moveset.branches.append(move_rule.new())
		_on_moves_recieved(occupant, moveset.new())


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


func tile_state(flag: TileStateFlag, function:Callable):
	var result = function.call($Tile_Object.state, flag) 
	if typeof(result) == TYPE_BOOL:
		return result
	$Tile_Object.state = result
	$Tile_Object.apply_state()
	

func tile_modifiers(flag: TileModifierFlag, function:Callable):
	var result = function.call(modifier_flags, flag) 
	if typeof(result) == TYPE_BOOL:
		return result
	modifier_flags = result

func clear_en_passant(player:int) -> void:
	if en_passant_occupant and en_passant_occupant.player == player:
		en_passant_occupant = null


func clear_castling_occupant() -> void:
	if castling_occupant and piece_has_moved(castling_occupant):
		castling_occupant = null


func find_neighbors() -> void:
	var neighbors: Array[Node] = get_tree().get_nodes_in_group("Tile").filter(is_neighbor)
	for tile in neighbors:
		var position_difference = board_position - tile.board_position
		match position_difference:
			Vector2i(-1,0): neighboring_tiles[Direction.NORTH] = tile
			Vector2i(-1,1): neighboring_tiles[Direction.NORTHEAST] = tile
			Vector2i(0,1): neighboring_tiles[Direction.EAST] = tile
			Vector2i(1,1): neighboring_tiles[Direction.SOUTHEAST] = tile
			Vector2i(1,0): neighboring_tiles[Direction.SOUTH] = tile
			Vector2i(1,-1): neighboring_tiles[Direction.SOUTHWEST] = tile
			Vector2i(0,-1): neighboring_tiles[Direction.WEST] = tile
			Vector2i(-1,-1): neighboring_tiles[Direction.NORTHWEST] = tile


func _send_to_tile(piece:Node3D, moves, direction: Direction, castling_rook:Node3D = null) -> void:
	move_processed.connect(Callable(neighboring_tiles[direction],"_on_moves_recieved"))
	move_processed.emit(piece, moves, castling_rook)
	move_processed.disconnect(Callable(neighboring_tiles[direction],"_on_moves_recieved"))


func _send_to_king(king:Node3D, rook: Node3D, direction: Direction) -> void:	
	rook_discovered.connect(Callable(king.get_parent(),"_on_rook_discovered"))
	rook_discovered.emit(rook, direction)
	rook_discovered.disconnect(Callable(king.get_parent(),"_on_rook_discovered"))


func _piece_is_valid_castling_rook(piece: Piece, occupying_piece: Piece) -> bool:
	return (
			piece and occupying_piece
			and piece_is_rook(occupying_piece)
			and not piece_has_moved(occupying_piece)
			and not piece_is_opponent_of(piece, occupying_piece)
	)


func _piece_threatened_by_en_passant(piece: Piece) -> bool:
	return (	
			piece_is_pawn(piece)
			and not piece_has_moved(piece) 
			and abs(piece.get_parent().board_position - board_position) == Vector2i(1,0)
	)


func _piece_is_threat_to_en_passant_piece(piece:Piece, assigned_move:MoveRule, en_passant_piece: Piece) -> bool:
	return (
			piece_is_pawn(piece)
			and en_passant_piece 
			and assigned_move.is_threatening() 
			and piece_is_opponent_of(piece, en_passant_piece)
	)


func move_is_blocked(move:MoveRule ,source_piece: Piece, occupant_piece: Piece):
	return (
			pieces_are_different(source_piece,occupant)
			and not move.is_jumping()
	)
