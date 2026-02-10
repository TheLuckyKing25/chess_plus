extends GameNode3D


@export_color_no_alpha var tile_color: Color:
	set(base_color):
		tile_color = base_color
		tile_material.albedo_color = base_color

var tile_material: StandardMaterial3D


var mouseover_material: StandardMaterial3D


var state_material: StandardMaterial3D


var state: int = TileStateFlag.NONE:
	set(flag):
		state = flag
		apply_state()


func _on_ready() -> void:
	tile_material = $Tile_Mesh.get_surface_override_material(0)
	state_material = tile_material.next_pass
	state_material.albedo_color = Color(1,1,1,0)
	mouseover_material = state_material.next_pass
	
		
func _on_mouse_entered() -> void:
	mouseover_material.render_priority = 1
	mouseover_material.albedo_color = Color(1,1,1,0.25)


func _on_mouse_exited() -> void:
	mouseover_material.albedo_color = Color(1,1,1,0)
	mouseover_material.render_priority = 0


func tile_checked_movement():
	state_material.albedo_color = COLOR_PALETTE.MOVE_CHECKING_TILE_COLOR
	state_material.emission_enabled = false


func apply_state():
	state_material.albedo_color.a = 0
	state_material.emission_enabled = false
	
	if state & 1 << TileStateFlag.MOVEMENT:
		state_material.albedo_color = COLOR_PALETTE.VALID_TILE_COLOR
		
	if state & 1 << TileStateFlag.SELECTED:
		state_material.albedo_color = COLOR_PALETTE.SELECT_TILE_COLOR
		
	if state & 1 << TileStateFlag.THREATENED:
		state_material.albedo_color = COLOR_PALETTE.THREATENED_TILE_COLOR
		
	if state & 1 << TileStateFlag.CHECKED:
		state_material.albedo_color = COLOR_PALETTE.CHECKED_TILE_COLOR
		
	if state & 1 << TileStateFlag.CHECKING:
		state_material.albedo_color = COLOR_PALETTE.CHECKING_TILE_COLOR
		
	if state & 1 << TileStateFlag.SPECIAL:
		state_material.albedo_color =  COLOR_PALETTE.SPECIAL_TILE_COLOR
		state_material.emission_enabled = true
	
	if state & 1 << TileStateFlag.CHECKED_MOVEMENT:
		state_material.albedo_color = COLOR_PALETTE.MOVE_CHECKING_TILE_COLOR
