extends Piece


const PAWN_MOVE_DISTANCE_INITIAL: int = 2


const PAWN_MOVE_DISTANCE: int = 1


const PAWN_THREATEN_DISTANCE: int = 1


func _on_ready() -> void:
	piece_clicked.connect(Callable(owner,"_on_piece_clicked"))
	connect_to_tile()
	direction_parity = -2 * (parity - 1)
	move_rules = [
		MoveRule.new(ActionType.MOVE,PurposeType.UNSET,PAWN_MOVE_DISTANCE_INITIAL,(Direction.NORTH + direction_parity)),
		MoveRule.new(ActionType.THREATEN,PurposeType.UNSET,PAWN_THREATEN_DISTANCE,(Direction.NORTHEAST + direction_parity)),
		MoveRule.new(ActionType.THREATEN,PurposeType.UNSET,PAWN_THREATEN_DISTANCE,(Direction.NORTHWEST + direction_parity)),
		]


func _on_input_event(
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
			piece_clicked.emit(self)


func moved():
	move_rules[0].distance = PAWN_MOVE_DISTANCE
