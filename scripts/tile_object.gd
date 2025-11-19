extends AnimatableBody3D


@export_color_no_alpha var tile_color: Color:
	set(base_color):
		tile_material.albedo_color = base_color
		mouseover_material.albedo_color = base_color + Color(0.2,0.2,0.2)
		tile_color = base_color

@export_color_no_alpha var state_color: Color:
	set(base_color):
		state_material.albedo_color = base_color
		mouseover_material.albedo_color = base_color + Color(0.2,0.2,0.2)
		state_color = base_color

@export_custom(PROPERTY_HINT_RESOURCE_TYPE,"") var tile_material: StandardMaterial3D:
	get:
		mouseover_material.albedo_color = tile_material.albedo_color + Color(0.2,0.2,0.2)
		return tile_material
	
@export_custom(PROPERTY_HINT_RESOURCE_TYPE,"") var state_material: StandardMaterial3D:
	get:
		mouseover_material.albedo_color = state_material.albedo_color + Color(0.2,0.2,0.2)
		return state_material
	
@export_custom(PROPERTY_HINT_RESOURCE_TYPE,"") var mouseover_material: StandardMaterial3D


var state = Game.TileStateFlag.TILE_STATE_FLAG_NONE:
	set(flag):
		state = flag
		apply_state()


func _on_ready() -> void:
	$Tile_Mesh.set_surface_override_material(0, tile_material)
		
		
func _on_mouse_entered() -> void:
	$Tile_Mesh.get_surface_override_material(0).next_pass = mouseover_material


func _on_mouse_exited() -> void:
	$Tile_Mesh.get_surface_override_material(0).next_pass = null


func tile_checked_movement():
	state_color = tile_color * Game.COLOR_PALETTE.MOVE_CHECKING_TILE_COLOR
	$Tile_Mesh.set_surface_override_material(0,state_material)
	$Tile_Mesh.get_surface_override_material(0).emission_enabled = false


func apply_state():
	tile_material.albedo_color = tile_color
	$Tile_Mesh.set_surface_override_material(0,tile_material)
	$Tile_Mesh.get_surface_override_material(0).emission_enabled = false
	
	if state & 1 << Game.TileStateFlag.TILE_STATE_FLAG_MOVEMENT:
		state_color = tile_color * Game.COLOR_PALETTE.VALID_TILE_COLOR
		$Tile_Mesh.set_surface_override_material(0,state_material)
		$Tile_Mesh.get_surface_override_material(0).emission_enabled = false
		
	if state & 1 << Game.TileStateFlag.TILE_STATE_FLAG_SELECTED:
		state_color = tile_color * Game.COLOR_PALETTE.SELECT_TILE_COLOR
		$Tile_Mesh.set_surface_override_material(0,state_material)
		$Tile_Mesh.get_surface_override_material(0).emission_enabled = false
		
	if state & 1 << Game.TileStateFlag.TILE_STATE_FLAG_THREATENED:
		state_color = tile_color * Game.COLOR_PALETTE.THREATENED_TILE_COLOR
		$Tile_Mesh.set_surface_override_material(0,state_material)
		$Tile_Mesh.get_surface_override_material(0).emission_enabled = false
		
	if state & 1 << Game.TileStateFlag.TILE_STATE_FLAG_CHECKED:
		state_color = tile_color * Game.COLOR_PALETTE.CHECKED_TILE_COLOR
		$Tile_Mesh.set_surface_override_material(0,state_material)
		$Tile_Mesh.get_surface_override_material(0).emission_enabled = false
		
	if state & 1 << Game.TileStateFlag.TILE_STATE_FLAG_CHECKING:
		state_color = tile_color * Game.COLOR_PALETTE.CHECKING_TILE_COLOR
		$Tile_Mesh.set_surface_override_material(0,state_material)
		$Tile_Mesh.get_surface_override_material(0).emission_enabled = false
		
	if state & 1 << Game.TileStateFlag.TILE_STATE_FLAG_SPECIAL_MOVEMENT:
		state_color = Game.COLOR_PALETTE.SPECIAL_TILE_COLOR
		$Tile_Mesh.set_surface_override_material(0,state_material)
		$Tile_Mesh.get_surface_override_material(0).emission_enabled = true
