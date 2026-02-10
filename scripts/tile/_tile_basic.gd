extends GameNode3D

signal clicked(tile:Node3D)


@export var board_position: Vector2i


var occupant: Piece:
	set(piece):		
		if occupant:
			occupant.clicked.disconnect(Callable(self, "_on_occupant_clicked"))
		if piece:
			piece.clicked.connect(Callable(self, "_on_occupant_clicked"))
		
		occupant = piece


@export var modifier_order: Array[TileModifier] = []:
	set(new_modifier_order):
		modifier_order = new_modifier_order
		$Tile_Object/Tile_Modifiers.modifiers = modifier_order


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

func _set_check():
	tile_state(Flag.set_func, TileStateFlag.CHECKED)
	occupant._set_check()
	
func _unset_check():
	tile_state(Flag.unset_func, TileStateFlag.CHECKED)
	occupant._unset_check()

func tile_state(function:Callable, flag: TileStateFlag):
	var result = function.call($Tile_Object.state, flag) 
	if typeof(result) == TYPE_BOOL:
		return result
	$Tile_Object.state = result
	$Tile_Object.apply_state()
