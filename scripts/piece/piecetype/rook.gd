extends Piece


const ROOK_MOVE_DISTANCE: int = 8


func _on_ready() -> void:
	direction_parity = -2 * (parity - 1)
	move_rules = [
		MoveRule.new(ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET,ROOK_MOVE_DISTANCE,(Direction.NORTH + direction_parity)),
		MoveRule.new(ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET,ROOK_MOVE_DISTANCE,(Direction.EAST + direction_parity)),
		MoveRule.new(ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET,ROOK_MOVE_DISTANCE,(Direction.SOUTH + direction_parity)),
		MoveRule.new(ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET,ROOK_MOVE_DISTANCE,(Direction.WEST + direction_parity)),
	]
