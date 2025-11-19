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
		MoveRule.new( MoveRule.MoveType.MOVEMENT|MoveRule.MoveType.THREATEN, KING_MOVE_DISTANCE, (Game.Direction.NORTH + direction_parity)),
		MoveRule.new( MoveRule.MoveType.MOVEMENT|MoveRule.MoveType.THREATEN, KING_MOVE_DISTANCE, (Game.Direction.NORTHEAST + direction_parity)),
		MoveRule.new( MoveRule.MoveType.MOVEMENT|MoveRule.MoveType.THREATEN, KING_MOVE_DISTANCE, (Game.Direction.EAST + direction_parity)),
		MoveRule.new( MoveRule.MoveType.MOVEMENT|MoveRule.MoveType.THREATEN, KING_MOVE_DISTANCE, (Game.Direction.SOUTHEAST + direction_parity)),
		MoveRule.new( MoveRule.MoveType.MOVEMENT|MoveRule.MoveType.THREATEN, KING_MOVE_DISTANCE, (Game.Direction.SOUTH + direction_parity)),
		MoveRule.new( MoveRule.MoveType.MOVEMENT|MoveRule.MoveType.THREATEN, KING_MOVE_DISTANCE, (Game.Direction.SOUTHWEST + direction_parity)),
		MoveRule.new( MoveRule.MoveType.MOVEMENT|MoveRule.MoveType.THREATEN, KING_MOVE_DISTANCE, (Game.Direction.WEST + direction_parity)),
		MoveRule.new( MoveRule.MoveType.MOVEMENT|MoveRule.MoveType.THREATEN, KING_MOVE_DISTANCE, (Game.Direction.NORTHWEST + direction_parity)),
	]
	
	rook_finding_move_rules = [
		MoveRule.new( MoveRule.MoveType.CASTLING, ROOK_DETECTION_DISTANCE, (Game.Direction.EAST + direction_parity)),
		MoveRule.new( MoveRule.MoveType.CASTLING, ROOK_DETECTION_DISTANCE, (Game.Direction.WEST + direction_parity)),
	]
	
	castling_move_rules = [
		MoveRule.new( MoveRule.MoveType.JUMP|MoveRule.MoveType.CASTLING|MoveRule.MoveType.SPECIAL, CASTLING_MOVE_DISTANCE, (Game.Direction.EAST + direction_parity)),
		MoveRule.new( MoveRule.MoveType.JUMP|MoveRule.MoveType.CASTLING|MoveRule.MoveType.SPECIAL, CASTLING_MOVE_DISTANCE, (Game.Direction.WEST + direction_parity)),
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
