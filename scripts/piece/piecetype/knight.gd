extends Piece


const KNIGHT_OUTWARD_MOVE_DISTANCE: int = 2


const KNIGHT_SIDEWAYS_MOVE_DISTANCE: int = 1


func _on_ready() -> void:
	direction_parity = -2 * (parity - 1)

	move_rules = [
		MoveRule.new(ActionType.JUMP|ActionType.BRANCH,PurposeType.UNSET, KNIGHT_OUTWARD_MOVE_DISTANCE, (Direction.NORTH + direction_parity),[
			MoveRule.new(ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET, KNIGHT_SIDEWAYS_MOVE_DISTANCE, (Direction.EAST + direction_parity)), 
			MoveRule.new(ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET, KNIGHT_SIDEWAYS_MOVE_DISTANCE, (Direction.WEST + direction_parity)),
		]),
		MoveRule.new(ActionType.JUMP|ActionType.BRANCH,PurposeType.UNSET, KNIGHT_OUTWARD_MOVE_DISTANCE, (Direction.EAST + direction_parity),[
			MoveRule.new(ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET, KNIGHT_SIDEWAYS_MOVE_DISTANCE, (Direction.NORTH + direction_parity)), 
			MoveRule.new(ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET, KNIGHT_SIDEWAYS_MOVE_DISTANCE, (Direction.SOUTH + direction_parity)),
		]),
		MoveRule.new(ActionType.JUMP|ActionType.BRANCH,PurposeType.UNSET, KNIGHT_OUTWARD_MOVE_DISTANCE, (Direction.SOUTH + direction_parity),[
			MoveRule.new(ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET, KNIGHT_SIDEWAYS_MOVE_DISTANCE, (Direction.EAST + direction_parity)), 
			MoveRule.new(ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET, KNIGHT_SIDEWAYS_MOVE_DISTANCE, (Direction.WEST + direction_parity)),
		]),
		MoveRule.new(ActionType.JUMP|ActionType.BRANCH,PurposeType.UNSET, KNIGHT_OUTWARD_MOVE_DISTANCE, (Direction.WEST + direction_parity) ,[
			MoveRule.new(ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET, KNIGHT_SIDEWAYS_MOVE_DISTANCE, (Direction.NORTH + direction_parity)), 
			MoveRule.new(ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET, KNIGHT_SIDEWAYS_MOVE_DISTANCE, (Direction.SOUTH + direction_parity)),
		]),
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
			#var clicked_object = result.collider.get_parent()
			clicked.emit(self)
