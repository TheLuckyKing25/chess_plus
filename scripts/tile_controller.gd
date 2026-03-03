class_name TileController
extends GameNode3D

signal clicked(tile:TileController)

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
	tile_material = $Tile_Mesh.material_override
	state_material = tile_material.next_pass
	state_material.albedo_color = Color(1,1,1,0)
	mouseover_material = state_material.next_pass

func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if is_mouse_on_tile and event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)

func _on_occupant_clicked(piece: PieceController):
	clicked.emit(self)

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
