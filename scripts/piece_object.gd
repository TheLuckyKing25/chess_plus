extends Game

@export_color_no_alpha var piece_color: Color = Color(0.5,0.5,0.5):
	set(base_color):
		piece_material.albedo_color = base_color
		mouseover_material.albedo_color = base_color + Color(0.2,0.2,0.2)
@export_custom(PROPERTY_HINT_RESOURCE_TYPE,"") var piece_material: StandardMaterial3D

@export_color_no_alpha var outline_color: Color = Color(0,0,0):
	set(base_color):
		outline_material.albedo_color = base_color
@export_custom(PROPERTY_HINT_RESOURCE_TYPE,"") var outline_material: StandardMaterial3D
		
@export_custom(PROPERTY_HINT_RESOURCE_TYPE,"") var mouseover_material: StandardMaterial3D


var state: PieceStateFlag = PieceStateFlag.PIECE_STATE_NONE:
	set(flags):
		state = flags
		apply_state()


func _on_ready() -> void:
	$Piece_Mesh.set_surface_override_material(0, piece_material)
	$Outline.set_material_override(outline_material)


func _on_mouse_entered() -> void:
	$Piece_Mesh.get_surface_override_material(0).next_pass = mouseover_material


func _on_mouse_exited() -> void:
	$Piece_Mesh.get_surface_override_material(0).next_pass = null


func apply_state():
	if state == PieceStateFlag.PIECE_STATE_NONE:
		$Outline.visible = false
		return
	if state & 1 << PieceStateFlag.PIECE_STATE_CAPTURED:
		get_parent().translate(Vector3(0,-5,0)) 
		get_parent().visible = false
		$Collision.disabled = true
		get_parent().reparent(%Captured)
		return
	if state & 1 << PieceStateFlag.PIECE_STATE_CHECKED:
		$Outline.visible = true
		$Outline.material_override.albedo_color = COLOR_PALETTE.CHECKED_PIECE_COLOR
		
	if state & 1 << PieceStateFlag.PIECE_STATE_SELECTED:
		$Outline.visible = true
		$Outline.material_override.albedo_color = COLOR_PALETTE.SELECT_PIECE_COLOR
		
	if state & 1 << PieceStateFlag.PIECE_STATE_THREATENED:
		$Outline.visible = true
		$Outline.material_override.albedo_color = COLOR_PALETTE.THREATENED_PIECE_COLOR
		
	if state & 1 << PieceStateFlag.PIECE_STATE_CHECKING:
		$Outline.visible = true
		$Outline.material_override.albedo_color = COLOR_PALETTE.CHECKING_PIECE_COLOR
		
	if state & 1 << PieceStateFlag.PIECE_STATE_SPECIAL:
		$Outline.visible = true
		$Outline.material_override.albedo_color = COLOR_PALETTE.SPECIAL_PIECE_COLOR
