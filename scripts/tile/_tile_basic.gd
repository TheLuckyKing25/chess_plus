extends GameNode3D

signal clicked(tile:Node3D)

signal move_processed(piece: Piece, move: MoveRule, castling_rook: Piece)


@export var board_position: Vector2i


@export var occupant: Piece = null:
	set(piece):
		if en_passant_occupant:
			en_passant_occupant = null
		
		if occupant:
			occupant.clicked.disconnect(Callable(self, "_on_occupant_clicked"))
		if piece:
			piece.clicked.connect(Callable(self, "_on_occupant_clicked"))
		
		occupant = piece


@export var modifier_order: Array[TileModifier] = []:
	set(new_modifier_order):
		modifier_order = new_modifier_order
		$Tile_Object/Tile_Modifiers.modifiers = modifier_order

var en_passant_occupant: Piece = null


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
	occupant = find_child("*_P*", false, true)
	if occupant:
		occupant.clicked.connect(Callable(self, "_on_occupant_clicked"))
	$Tile_Object/Tile_Modifiers.modifiers = modifier_order


func _on_input_event(
		camera: Node, 
		event: InputEvent, 
		event_position: Vector3, 
		normal: Vector3, 
		shape_idx: int
		) -> void:
	if ( 	event is InputEventMouseButton
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
		if result:
			#var clicked_object = result.collider.get_parent()	
			clicked.emit(self)

func _on_occupant_clicked(piece: Node3D):
	clicked.emit(self)

func _select():
	tile_state(Flag.set_func, TileStateFlag.SELECTED)
	if occupant:
		occupant._select()

func _unselect():
	tile_state(Flag.unset_func, TileStateFlag.SELECTED)
	if occupant:
		occupant._unselect()

func _threaten():
	tile_state(Flag.set_func, TileStateFlag.THREATENED)
	if occupant:
		occupant._threaten()

func _unthreaten():
	tile_state(Flag.unset_func, TileStateFlag.THREATENED)
	if occupant:
		occupant._unthreaten()

func _show_castling():
	tile_state(Flag.set_func, TileStateFlag.SPECIAL)
	if occupant:
		occupant._show_castling()

func _hide_castling():
	tile_state(Flag.unset_func, TileStateFlag.SPECIAL)
	if occupant:
		occupant._hide_castling()
















func _is_valid_move_state() -> bool:
	return (	
			tile_state(Flag.is_enabled_func,TileStateFlag.SPECIAL)
			or tile_state(Flag.is_enabled_func, TileStateFlag.MOVEMENT)
			or (	
					tile_state(Flag.is_enabled_func, TileStateFlag.THREATENED) 
					and en_passant_occupant
					and not occupant
			)
	)


func _clear_checks() -> void:
	_checked_by.clear()
	tile_state(Flag.unset_func, TileStateFlag.CHECKED)
	if occupant:
		occupant.piece_state(Flag.unset_func, PieceStateFlag.CHECKED)


func _clear_move_states() -> void:
	tile_state(Flag.unset_func, TileStateFlag.SELECTED)
	tile_state(Flag.unset_func, TileStateFlag.MOVEMENT)
	tile_state(Flag.unset_func, TileStateFlag.THREATENED)
	tile_state(Flag.unset_func, TileStateFlag.SPECIAL)
	_moveset = null
	_moving_piece = null
	if occupant:
		occupant.piece_state(Flag.unset_func, PieceStateFlag.THREATENED)
		occupant.piece_state(Flag.unset_func, PieceStateFlag.SPECIAL)


func _clear_en_passant(player:int) -> void:
	if en_passant_occupant and en_passant_occupant.player == player:
		en_passant_occupant = null

		
func _connect_to_neighboring_tile(moves, direction: Direction, castling_rook:Node3D = null) -> void:
	if neighboring_tiles[direction]:
		move_processed.connect(Callable(neighboring_tiles[direction],"_on_moves_recieved"))
		move_processed.emit(_moving_piece, moves, castling_rook)
		move_processed.disconnect(Callable(neighboring_tiles[direction],"_on_moves_recieved"))

func discover_checks() -> void:
	if occupant:
		_moveset = MoveRule.new(ActionType.BRANCH, PurposeType.CHECK_DETECTING,0,0,occupant.move_rules)
		_moveset = _moveset.new_duplicate()
		#_on_moves_recieved(tile_occupant, _moveset)


func tile_state(function:Callable, flag: TileStateFlag):
	var result = function.call($Tile_Object.state, flag) 
	if typeof(result) == TYPE_BOOL:
		return result
	$Tile_Object.state = result
	$Tile_Object.apply_state()
