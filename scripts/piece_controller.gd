class_name PieceController
extends GameNode3D

signal clicked(piece: PieceController)

var is_mouse_on_piece: bool = false

var piece_material: StandardMaterial3D
var outline_material: StandardMaterial3D
var mouseover_material: StandardMaterial3D

func _set_mesh(mesh: Mesh):
	$Piece_Mesh.mesh = mesh
	piece_material = $Piece_Mesh.material_override
	mouseover_material = piece_material.next_pass
	outline_material = mouseover_material.next_pass
	outline_material.albedo_color = Color(0,0,0,0)

func _captured():
	visible = false
	$Collision.disabled = true

func promote():
	remove_from_group("Pawn")

	
func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if (	event is InputEventMouseButton
			and event.is_pressed()
			and event.button_index == MOUSE_BUTTON_LEFT
			and is_mouse_on_piece
		):
		clicked.emit(self)
	

func _on_mouse_entered() -> void:
	is_mouse_on_piece = true
	mouseover_material.render_priority = 2
	mouseover_material.albedo_color = piece_material.albedo_color * 1.5


func _on_mouse_exited() -> void:
	mouseover_material.albedo_color = Color(0,0,0,0)
	mouseover_material.render_priority = 0
	is_mouse_on_piece = false
