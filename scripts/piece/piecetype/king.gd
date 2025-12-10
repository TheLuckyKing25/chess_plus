extends Piece


const KING_MOVE_DISTANCE: int = 1


const ROOK_DETECTION_DISTANCE: int = 8


const CASTLING_MOVE_DISTANCE: int = 2


var rook_finding_move_rules: Array[MoveRule]


var castling_move_rules: Array[MoveRule] 


func _on_ready() -> void:
	piece_clicked.connect(Callable(owner,"_on_piece_clicked"))
	connect_to_tile()
	direction_parity = -2 * (parity - 1)
	
	move_rules = [
		MoveRule.new( ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET,KING_MOVE_DISTANCE,(Direction.NORTH + direction_parity)),
		MoveRule.new( ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET,KING_MOVE_DISTANCE,(Direction.NORTHEAST + direction_parity)),
		MoveRule.new( ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET,KING_MOVE_DISTANCE,(Direction.EAST + direction_parity)),
		MoveRule.new( ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET,KING_MOVE_DISTANCE,(Direction.SOUTHEAST + direction_parity)),
		MoveRule.new( ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET,KING_MOVE_DISTANCE,(Direction.SOUTH + direction_parity)),
		MoveRule.new( ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET,KING_MOVE_DISTANCE,(Direction.SOUTHWEST + direction_parity)),
		MoveRule.new( ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET,KING_MOVE_DISTANCE,(Direction.WEST + direction_parity)),
		MoveRule.new( ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET,KING_MOVE_DISTANCE,(Direction.NORTHWEST + direction_parity)),
	]
	
	rook_finding_move_rules = [
		MoveRule.new(ActionType.JUMP, PurposeType.UNSET, ROOK_DETECTION_DISTANCE, (Direction.EAST + direction_parity)),
		MoveRule.new(ActionType.JUMP, PurposeType.UNSET, ROOK_DETECTION_DISTANCE, (Direction.WEST + direction_parity)),
	]
	
	castling_move_rules = [
		MoveRule.new(ActionType.JUMP|ActionType.SPECIAL,PurposeType.UNSET,CASTLING_MOVE_DISTANCE, (Direction.EAST + direction_parity)),
		MoveRule.new(ActionType.JUMP|ActionType.SPECIAL,PurposeType.UNSET,CASTLING_MOVE_DISTANCE, (Direction.WEST + direction_parity)),
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
			piece_clicked.emit(self)
