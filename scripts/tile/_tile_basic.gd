class_name Tile
extends GameNode3D

signal clicked(tile:Node3D)

static var selected: Tile = null
static var en_passant: Tile = null

# Standard Tile Colors
const BASE_COLOR: Color = Color(0.75, 0.5775, 0.435, 1) 
const LIGHT_COLOR = BASE_COLOR * 4/3
const DARK_COLOR = BASE_COLOR * 2/3

# State Tile Colors
const THREATENED_COLOR = Color(1, 0.2, 0.2, 1)
const VALID_COLOR = Color(0.6, 1, 0.6, 1)
const SELECT_COLOR = Color(0.1, 1, 1, 1)
const CHECKED_COLOR = Color(1, 0.2, 0.2, 1)
const CHECKING_COLOR = Color(1, 1, 0.25)
const SPECIAL_COLOR = Color(1,1,1,1)
const MOVE_CHECKING_COLOR = Color(1, 0.392, 0.153)


var board_position: Vector2i

var rank: int:
	get():
		return board_position.y

var file: int:
	get():
		return board_position.x

var tile_material: StandardMaterial3D
var mouseover_material: StandardMaterial3D
var state_material: StandardMaterial3D


var state: int = TileStateFlag.NONE:
	set(flag):
		state = flag
		apply_state()


var occupant: Piece:
	set(piece):		
		if occupant:
			occupant.clicked.disconnect(Callable(self, "_on_occupant_clicked"))
		if piece:
			piece.clicked.connect(Callable(self, "_on_occupant_clicked"))
		
		occupant = piece


var modifier_order: Array[TileModifier] = []:
	set(new_modifier_order):
		modifier_order = new_modifier_order
		$Tile_Modifiers.modifiers = modifier_order


var is_mouse_on_tile: bool = false

func _on_ready() -> void:
	tile_material = $Tile_Mesh.get_surface_override_material(0)
	state_material = tile_material.next_pass
	state_material.albedo_color = Color(1,1,1,0)
	mouseover_material = state_material.next_pass
	match (file + rank) % 2:
		0: tile_material.albedo_color = LIGHT_COLOR
		1: tile_material.albedo_color = DARK_COLOR
	$Tile_Modifiers.modifiers = modifier_order


func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if ( 	is_mouse_on_tile 
			and event is InputEventMouseButton
			and event.is_pressed()
			and event.button_index == MOUSE_BUTTON_LEFT
			):
		clicked.emit(self)

func _on_occupant_clicked(piece: Piece):
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
	var result = function.call(state, flag) 
	if typeof(result) == TYPE_BOOL:
		return result
	state = result
	apply_state()
		
func _on_mouse_entered() -> void:
	is_mouse_on_tile = true
	mouseover_material.render_priority = 1
	mouseover_material.albedo_color = Color(1,1,1,0.25)


func _on_mouse_exited() -> void:
	mouseover_material.albedo_color = Color(1,1,1,0)
	mouseover_material.render_priority = 0
	is_mouse_on_tile = false


func tile_checked_movement():
	state_material.albedo_color = COLOR_PALETTE.MOVE_CHECKING_TILE_COLOR
	state_material.emission_enabled = false


func apply_state():
	state_material.albedo_color.a = 0
	state_material.emission_enabled = false
	
	if state & 1 << TileStateFlag.MOVEMENT:
		state_material.albedo_color = VALID_COLOR
		
	if state & 1 << TileStateFlag.SELECTED:
		state_material.albedo_color = SELECT_COLOR
		
	if state & 1 << TileStateFlag.THREATENED:
		state_material.albedo_color = THREATENED_COLOR
		
	if state & 1 << TileStateFlag.CHECKED:
		state_material.albedo_color = CHECKED_COLOR
		
	if state & 1 << TileStateFlag.CHECKING:
		state_material.albedo_color = CHECKING_COLOR
		
	if state & 1 << TileStateFlag.SPECIAL:
		state_material.albedo_color = SPECIAL_COLOR
		state_material.emission_enabled = true
	
	if state & 1 << TileStateFlag.CHECKED_MOVEMENT:
		state_material.albedo_color = MOVE_CHECKING_COLOR
