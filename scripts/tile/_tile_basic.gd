extends GameNode3D


signal tile_selected(tile:Node3D)
signal move_processed(piece: Piece, move: MoveRule, castling_rook: Piece)
signal rook_discovered(piece: Piece, direction: Direction)
signal castle


@export var board_position: Vector2i


@export var tile_occupant: Piece = null:
	set(piece):
		if en_passant_occupant:
			en_passant_occupant = null
		if _castling_occupant:
			_castling_occupant = null
		tile_occupant = piece

@export var modifier_order: Array[TileModifier] = []:
	set(new_modifier_order):
		modifier_order = new_modifier_order
		$Tile_Object/Tile_Modifiers.modifiers = modifier_order

var en_passant_occupant: Piece = null


var _castling_occupant: Piece = null


var _checked_by: Array[Piece] = []


var _moveset: MoveRule


var _moving_piece: Piece


var neighboring_tiles: Dictionary[Direction, Node3D] = {
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
	tile_occupant = find_child("*_P*", false, true)
	$Tile_Object/Tile_Modifiers.modifiers = modifier_order


func _is_neighbor(tile: Node3D) -> bool:
	var neighbor_x = tile.board_position.x
	var neighbor_y = tile.board_position.y
	var neighbor_x_diff = abs(neighbor_x - board_position.x)
	var neighbor_y_diff = abs(neighbor_y - board_position.y)
	return (
			neighbor_x_diff == 1 and neighbor_y_diff == 0
			or neighbor_x_diff == 0 and neighbor_y_diff == 1
			or neighbor_x_diff == 1 and neighbor_y_diff == 1
			) 


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
			#var clicked_object = result.collider.get_parent()	
			tile_selected.emit(self)


func _is_valid_move_state() -> bool:
	return (	
			tile_state(Flag.is_enabled_func,TileStateFlag.SPECIAL)
			or tile_state(Flag.is_enabled_func, TileStateFlag.MOVEMENT)
			or (	
					tile_state(Flag.is_enabled_func, TileStateFlag.THREATENED) 
					and en_passant_occupant
					and not tile_occupant
			)
	)


func _on_occupant_selected() -> void:
	tile_state(Flag.set_func, TileStateFlag.SELECTED)
	_moveset = MoveRule.new(ActionType.BRANCH, PurposeType.STANDARD_MOVEMENT,0,0,tile_occupant.move_rules)
	_moveset = _moveset.new_duplicate()
	_on_moves_recieved(tile_occupant, _moveset)
	#if piece_is_king(occupant) and not piece_has_moved(occupant):
		#_moveset = MoveRule.new(ActionType.BRANCH, PurposeType.ROOK_FINDING,0,0)
		#for move_rule in occupant.rook_finding_move_rules:
			#_moveset.branches.append(move_rule.new())
		#_on_moves_recieved(occupant, _moveset)


func _on_moves_recieved(source_piece: Piece, moves: MoveRule, castling_rook: Piece = null) -> void:
	var proceed = true
	_moveset = moves
	_moving_piece = source_piece
	
	if modifier_order.size() > 0:
		proceed = _apply_modifiers()
	
	if proceed:
		if _moveset.distance > 0:
			_moveset.distance -= 1
		#DETERMINE TILE STATE FROM MOVES	
		if _moveset.purpose == PurposeType.CHECK_DETECTING:
			proceed = _perform_check_detection()
			
		elif _moveset.purpose == PurposeType.CASTLING and _moveset.action_flag_is_enabled(ActionType.JUMP):
			proceed = _perform_castling(castling_rook)
				
		elif _moveset.purpose == PurposeType.ROOK_FINDING:
			proceed = _perform_rook_finding()
			
		else:
			proceed = _perform_show_movement()
			
	#SEND MOVES TO NEIGHBORING TILES
	if proceed:
		if _moveset.distance == 0 and _moveset.action_flag_is_enabled(ActionType.BRANCH):
			for branching_move in _moveset.branches:
				branching_move.purpose = _moveset.purpose
				if neighboring_tiles[branching_move.direction]:
					_connect_to_neighboring_tile(branching_move, branching_move.direction, castling_rook)
		elif _moveset.distance > 0:
			_connect_to_neighboring_tile(_moveset, _moveset.direction, castling_rook)


func _apply_modifiers():
	var slide_direction: Direction = _moveset.direction

	for modifier in modifier_order:
		match modifier.flag:
			TileModifierFlag.PROPERTY_COG:
				if modifier.rotation == modifier.Rotation.CLOCKWISE:
					_moveset.call_func_on_moves(Callable(_moveset,"rotate_clockwise"))
				elif modifier.rotation == modifier.Rotation.COUNTERCLOCKWISE:
					_moveset.call_func_on_moves(Callable(_moveset,"rotate_counterclockwise"))
			TileModifierFlag.CONDITION_STICKY:
				# Prevents the piece from moving further, 
				# but doesn't prevent movement if the piece is occupying the tile
				_moveset.distance = 0	
			TileModifierFlag.CONDITION_ICY:
				var neighboring_tile_occupant = neighboring_tiles[_moveset.direction].tile_occupant
				if ( 	not _moving_piece.is_in_group("Knight")
						and neighboring_tiles[_moveset.direction] 
						and (
								not neighboring_tile_occupant
								or _moving_piece.is_opponent_to(neighboring_tile_occupant)
								)
						and _moving_piece == tile_occupant
						):
					_connect_to_neighboring_tile(_moveset, slide_direction)
					return false
			TileModifierFlag.PROPERTY_CONVEYER:
				_connect_to_neighboring_tile(_moveset, modifier.direction)
				return false
			TileModifierFlag.PROPERTY_PRISM:
				pass
	return true


func _perform_check_detection():
	if _moveset.action_flag_is_enabled(ActionType.THREATEN):
		_checked_by.append(_moving_piece)
		
		if _moving_piece.is_opponent_to(tile_occupant):	
			if tile_occupant and not tile_occupant.is_in_group("King"): 
				return false
			if tile_occupant.piece_state(Flag.is_enabled_func, PieceStateFlag.CHECKED):
				print("END GAME")
			tile_state(Flag.set_func, TileStateFlag.CHECKED)
			tile_occupant.piece_state(Flag.set_func, PieceStateFlag.CHECKED)
			return false
	return true


func _perform_castling(castling_rook: Piece):
	if _checked_by: 
		return false
		
	if _moveset.action_flag_is_enabled(ActionType.SPECIAL) and _moveset.distance == 0:
		tile_state(Flag.set_func, TileStateFlag.SPECIAL)
		return false
	
	_castling_occupant = castling_rook
	_castling_occupant.piece_state(Flag.set_func, PieceStateFlag.SPECIAL)
	_toggle_rook_castling_tile_connection(_moveset)
	return true


func _perform_rook_finding():
	if tile_occupant and _moving_piece != tile_occupant:
		if _moving_piece.is_valid_castling_rook(tile_occupant):
			_send_to_king(_moving_piece, tile_occupant, _moveset.direction)
		return false
	return true


func _perform_show_movement():
	if (	_moving_piece.is_opponent_to(tile_occupant) 
			and _moveset.action_flag_is_enabled(ActionType.THREATEN)
		):
		tile_state(Flag.set_func, TileStateFlag.THREATENED)
		tile_occupant.piece_state(Flag.set_func, PieceStateFlag.THREATENED)
	
	if 	(	tile_occupant and _moving_piece != tile_occupant
			and not _moveset.action_flag_is_enabled(ActionType.JUMP)
			): 
		return false
		
	if (	not tile_occupant 
			and _moveset.action_flag_is_enabled(ActionType.MOVE)
		):
		tile_state(Flag.set_func, TileStateFlag.MOVEMENT)
		if _moving_piece and _moving_piece.is_in_group("King") and _checked_by.is_empty():
			tile_state(Flag.set_func, TileStateFlag.THREATENED)
	
	
	if _moving_piece.is_threatened_by_en_passant(board_position):
		en_passant_occupant = _moving_piece
	
	if _moving_piece.is_threat_to_en_passant_piece(_moveset, en_passant_occupant):
		tile_state(Flag.set_func, TileStateFlag.THREATENED)
		en_passant_occupant.piece_state(Flag.set_func, PieceStateFlag.THREATENED)
	
	return true


func _on_rook_discovered(rook, direction) -> void:
	_moveset = MoveRule.new(ActionType.BRANCH, PurposeType.CASTLING,0,0)
	for move_rule in tile_occupant.castling_move_rules:
		if move_rule.direction == direction:
			_moveset.branches.append(move_rule.new_duplicate())
	_on_moves_recieved(tile_occupant, _moveset, rook)


func _on_castle() -> void:
	_castling_occupant.piece_clicked.emit(_castling_occupant)
	tile_selected.emit(self)


func _toggle_rook_castling_tile_connection(assigned_move) -> void:
	if neighboring_tiles[assigned_move.direction].is_connected("castle", Callable(self,"_on_castle")):
		neighboring_tiles[assigned_move.direction].castle.disconnect(Callable(self,"_on_castle"))
	else:
		neighboring_tiles[assigned_move.direction].castle.connect(Callable(self,"_on_castle"))


func _clear_checks() -> void:
	_checked_by.clear()
	tile_state(Flag.unset_func, TileStateFlag.CHECKED)
	if tile_occupant:
		tile_occupant.piece_state(Flag.unset_func, PieceStateFlag.CHECKED)


func _clear_move_states() -> void:
	tile_state(Flag.unset_func, TileStateFlag.SELECTED)
	tile_state(Flag.unset_func, TileStateFlag.MOVEMENT)
	tile_state(Flag.unset_func, TileStateFlag.THREATENED)
	tile_state(Flag.unset_func, TileStateFlag.SPECIAL)
	_moveset = null
	_moving_piece = null
	if tile_occupant:
		tile_occupant.piece_state(Flag.unset_func, PieceStateFlag.THREATENED)
		tile_occupant.piece_state(Flag.unset_func, PieceStateFlag.SPECIAL)


func _clear_en_passant(player:int) -> void:
	if en_passant_occupant and en_passant_occupant.player == player:
		en_passant_occupant = null


func _clear_castling_occupant() -> void:
	if _castling_occupant and _castling_occupant.is_in_group("has_moved"):
		_castling_occupant = null
		

func _connect_to_neighboring_tile(moves, direction: Direction, castling_rook:Node3D = null) -> void:
	if neighboring_tiles[direction]:
		move_processed.connect(Callable(neighboring_tiles[direction],"_on_moves_recieved"))
		move_processed.emit(_moving_piece, moves, castling_rook)
		move_processed.disconnect(Callable(neighboring_tiles[direction],"_on_moves_recieved"))


func _send_to_king(king:Node3D, rook: Node3D, direction: Direction) -> void:	
	rook_discovered.connect(Callable(king.get_parent(),"_on_rook_discovered"))
	rook_discovered.emit(rook, direction)
	rook_discovered.disconnect(Callable(king.get_parent(),"_on_rook_discovered"))


func find_neighbors() -> void:
	var neighbors: Array[Node] = get_tree().get_nodes_in_group("Tile").filter(_is_neighbor)
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


func discover_checks() -> void:
	if tile_occupant:
		_moveset = MoveRule.new(ActionType.BRANCH, PurposeType.CHECK_DETECTING,0,0,tile_occupant.move_rules)
		_moveset = _moveset.new_duplicate()
		_on_moves_recieved(tile_occupant, _moveset)


func tile_state(function:Callable, flag: TileStateFlag):
	var result = function.call($Tile_Object.state, flag) 
	if typeof(result) == TYPE_BOOL:
		return result
	$Tile_Object.state = result
	$Tile_Object.apply_state()
