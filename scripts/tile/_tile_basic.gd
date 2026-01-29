extends GameNode3D

signal clicked(tile:Node3D)

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
		
		if tile_occupant:
			tile_occupant.clicked.disconnect(Callable(self, "_on_occupant_clicked"))
		if piece:
			piece.clicked.connect(Callable(self, "_on_occupant_clicked"))
		
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
	match (board_position.x + board_position.y) % 2:
		0: $Tile_Object.tile_material.albedo_color = COLOR_PALETTE.TILE_COLOR_LIGHT
		1: $Tile_Object.tile_material.albedo_color = COLOR_PALETTE.TILE_COLOR_DARK
	tile_occupant = find_child("*_P*", false, true)
	if tile_occupant:
		tile_occupant.clicked.connect(Callable(self, "_on_occupant_clicked"))
	$Tile_Object/Tile_Modifiers.modifiers = modifier_order


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
			clicked.emit(self)

func _on_occupant_clicked(piece: Node3D):
	clicked.emit(self)

func _select():
	tile_state(Flag.set_func, TileStateFlag.SELECTED)
	if tile_occupant:
		tile_occupant._select()

func _unselect():
	tile_state(Flag.unset_func, TileStateFlag.SELECTED)
	if tile_occupant:
		tile_occupant._unselect()

func _threaten():
	tile_state(Flag.set_func, TileStateFlag.THREATENED)
	if tile_occupant:
		tile_occupant._threaten()

func _unthreaten():
	tile_state(Flag.unset_func, TileStateFlag.THREATENED)
	if tile_occupant:
		tile_occupant._unthreaten()


















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


func _on_selected() -> void:
	#if piece_is_king(occupant) and not piece_has_moved(occupant):
		#_moveset = MoveRule.new(ActionType.BRANCH, PurposeType.ROOK_FINDING,0,0)
		#for move_rule in occupant.rook_finding_move_rules:
			#_moveset.branches.append(move_rule.new())
		#_on_moves_recieved(occupant, _moveset)
	pass


func _on_rook_discovered(rook, direction) -> void:
	_moveset = MoveRule.new(ActionType.BRANCH, PurposeType.CASTLING,0,0)
	for move_rule in tile_occupant.castling_move_rules:
		if move_rule.direction == direction:
			_moveset.branches.append(move_rule.new_duplicate())
	#_on_moves_recieved(tile_occupant, _moveset, rook)


func _on_castle() -> void:
	_castling_occupant.piece_clicked.emit(_castling_occupant)
	#selected.emit(self)


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

func discover_checks() -> void:
	if tile_occupant:
		_moveset = MoveRule.new(ActionType.BRANCH, PurposeType.CHECK_DETECTING,0,0,tile_occupant.move_rules)
		_moveset = _moveset.new_duplicate()
		#_on_moves_recieved(tile_occupant, _moveset)


func tile_state(function:Callable, flag: TileStateFlag):
	var result = function.call($Tile_Object.state, flag) 
	if typeof(result) == TYPE_BOOL:
		return result
	$Tile_Object.state = result
	$Tile_Object.apply_state()
