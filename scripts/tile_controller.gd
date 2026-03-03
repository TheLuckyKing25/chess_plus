class_name TileController
extends GameNode3D

signal clicked(tile:TileController)

# Standard Tile Colors
const BASE_COLOR: Color = Color(0.75, 0.5775, 0.435, 1) 
const LIGHT_COLOR = BASE_COLOR * 4/3
const DARK_COLOR = BASE_COLOR * 2/3 + Color(0,0,0,1)

# State Tile Colors
const THREATENED_COLOR = Color(1, 0.2, 0.2, 1)
const VALID_COLOR = Color(0.6, 1, 0.6, 1)
const SELECT_COLOR = Color(0.1, 1, 1, 1)
const CHECKED_COLOR = Color(1, 0.2, 0.2, 1)
const CHECKING_COLOR = Color(1, 1, 0.25)
const SPECIAL_COLOR = Color(1,1,1,1)
const MOVE_CHECKING_COLOR = Color(1, 0.392, 0.153)

var tile_material: StandardMaterial3D
var mouseover_material: StandardMaterial3D
var state_material: StandardMaterial3D

var occupant: PieceController = null:
	set(new_occupant):
		if occupant:
			occupant.clicked.disconnect(Callable(self, "_on_occupant_clicked"))
		if new_occupant:
			new_occupant.clicked.connect(Callable(self, "_on_occupant_clicked"))
		occupant = new_occupant

var is_mouse_on_tile: bool = false

func _ready() -> void:	
	stats.changed.connect(Callable(self,"_on_stats_changed"))
	tile_material = $Tile_Mesh.material_override
	state_material = tile_material.next_pass
	state_material.albedo_color = Color(1,1,1,0)
	mouseover_material = state_material.next_pass
	match (stats.file + stats.rank) % 2:
		0: tile_material.albedo_color = LIGHT_COLOR
		1: tile_material.albedo_color = DARK_COLOR

	$Tile_Modifiers.modifiers = stats.modifier_order


func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if is_mouse_on_tile and event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)

func _on_occupant_clicked(piece: PieceController):
	clicked.emit(self)


func clear_states():
	_unselect()
	_unthreaten()
	_hide_castling()
	stats.is_checked_movement = false
	stats.is_movement = false

#region Mouse Over
func _on_mouse_entered() -> void:
	is_mouse_on_tile = true
	mouseover_material.render_priority = 1
	mouseover_material.albedo_color = Color(1,1,1,0.25)


func _on_mouse_exited() -> void:
	mouseover_material.albedo_color = Color(1,1,1,0)
	mouseover_material.render_priority = 0
	is_mouse_on_tile = false
#endregion


func tile_checked_movement():
	state_material.albedo_color = COLOR_PALETTE.MOVE_CHECKING_TILE_COLOR
	state_material.emission_enabled = false


func _on_stats_changed():
	state_material.albedo_color.a = 0
	state_material.emission_enabled = false
	
	if stats.is_checked_movement:
		state_material.albedo_color = MOVE_CHECKING_COLOR
	elif stats.is_special:
		state_material.albedo_color = SPECIAL_COLOR
		state_material.emission_enabled = true
	elif stats.is_checking:
		state_material.albedo_color = CHECKING_COLOR
	elif stats.is_checked:
		state_material.albedo_color = CHECKED_COLOR	
	elif stats.is_threatened:
		state_material.albedo_color = THREATENED_COLOR
	elif stats.is_selected:
		state_material.albedo_color = SELECT_COLOR			
	elif stats.is_movement:
		state_material.albedo_color = VALID_COLOR
		

		


		

		

	
