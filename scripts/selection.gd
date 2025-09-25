extends AnimatableBody3D

@export var camera: Camera3D
	
# Checks if the piece has been clicked on, makes the outline visible if true
func _on_input_piece_event(camera: Node, event: InputEvent, 
		event_position: Vector3, normal: Vector3, shape_idx: int
) -> void:
	if (
			event is InputEventMouseButton
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
			var clicked_object = result.collider.get_parent()
			Global.select_piece(
					Global.find_piece_from_object(clicked_object)
			)

# checks if a piece has been selected and the tile has been clicked on.
func _on_input_tile_event(camera: Node, event: InputEvent, 
		event_position: Vector3, normal: Vector3, shape_idx: int
) -> void:
	if (
			Global.selected_piece
			and event is InputEventMouseButton
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
			var clicked_object = result.collider.get_parent()
			Global.selected_tile = (
					Global.find_tile_from_object(clicked_object)
			)
