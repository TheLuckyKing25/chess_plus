extends AnimatableBody3D

@export var camera: Camera3D

func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if Global.piece_selected != null and (event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT):
		var mouse_pos = event.position
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos)*1000
		var space_state = get_world_3d().direct_space_state
		var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from,to))
		if result:
			var clicked_object = result.collider
			Global.tile_selected = clicked_object
			print(clicked_object)
			if Global.piece_selected != null:
				Global.piece_selected.global_position = Global.tile_selected.global_position * Vector3(1,0,1)
				Global.tile_selected = null
				Global.piece_selected = null
				
