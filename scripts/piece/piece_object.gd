extends GameNode3D


var piece_material: StandardMaterial3D


var outline_material: StandardMaterial3D
		

var mouseover_material: StandardMaterial3D


var state: PieceStateFlag = PieceStateFlag.NONE:
	set(flags):
		state = flags
		apply_state()


func _on_ready() -> void:
	piece_material = $Piece_Mesh.get_surface_override_material(0)
	mouseover_material = piece_material.next_pass
	outline_material = mouseover_material.next_pass
	outline_material.albedo_color = Color(0,0,0,0)
	

func _on_mouse_entered() -> void:
	mouseover_material.render_priority = 1
	mouseover_material.albedo_color = piece_material.albedo_color * 1.5


func _on_mouse_exited() -> void:
	mouseover_material.albedo_color = Color(0,0,0,0)
	mouseover_material.render_priority = 0


func apply_state():
	if state == PieceStateFlag.NONE:
		outline_material.albedo_color = Color(0,0,0,0)
		return
	if state & 1 << PieceStateFlag.CAPTURED:
		return
	if state & 1 << PieceStateFlag.CHECKED:
		outline_material.albedo_color = COLOR_PALETTE.CHECKED_PIECE_COLOR
		
	if state & 1 << PieceStateFlag.SELECTED:
		outline_material.albedo_color = COLOR_PALETTE.SELECT_PIECE_COLOR
		
	if state & 1 << PieceStateFlag.THREATENED:
		outline_material.albedo_color = COLOR_PALETTE.THREATENED_PIECE_COLOR
		
	if state & 1 << PieceStateFlag.CHECKING:
		outline_material.albedo_color = COLOR_PALETTE.CHECKING_PIECE_COLOR
		
	if state & 1 << PieceStateFlag.SPECIAL:
		outline_material.albedo_color = COLOR_PALETTE.SPECIAL_PIECE_COLOR
