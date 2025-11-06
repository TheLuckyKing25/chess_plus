extends AnimatableBody3D

@export var camera: Camera3D
## Checks if the piece has been clicked on
func _on_input_piece_event(
		camera: Node, 
		event: InputEvent, 
		event_position: Vector3, 
		normal: Vector3, 
		shape_idx: int
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
			Piece.find_from_object(clicked_object).select()

## Checks if a piece has been selected and the tile has been clicked on.
func _on_input_tile_event(
		camera: Node, 
		event: InputEvent, 
		event_position: Vector3, 
		normal: Vector3, 
		shape_idx: int
) -> void:
	if (
			Piece.selected
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
			Tile.selected = (
					Tile.find_from_object(clicked_object)
			)		
			
var blink 
var entered: bool = false
var time = 0
var outline_color:Color = Color(0,0,0)
var blink_color:Color

func _process(delta: float) -> void:
	time += delta
	blink = (sin(5*time) + 1)/2
	blink_color = Color(0,0,0).lerp(Color(1,1,1), blink)

		
func _on_mouse_entered_piece() -> void:
	entered = true
	find_child("Outline").visible = true
		
func _on_mouse_exited_piece() -> void:
	find_child("Outline").material_override.albedo_color = outline_color
	entered = false
