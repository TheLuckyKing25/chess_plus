extends Piece


const PAWN_MOVE_DISTANCE_INITIAL: int = 2


const PAWN_MOVE_DISTANCE: int = 1


const PAWN_THREATEN_DISTANCE: int = 1


func _on_ready() -> void:
	direction_parity = -2 * (parity - 1)
	move_rules = [
		MoveRule.new(ActionType.MOVE,PurposeType.UNSET,PAWN_MOVE_DISTANCE_INITIAL,(Direction.NORTH + direction_parity)),
		MoveRule.new(ActionType.THREATEN,PurposeType.UNSET,PAWN_THREATEN_DISTANCE,(Direction.NORTHEAST + direction_parity)),
		MoveRule.new(ActionType.THREATEN,PurposeType.UNSET,PAWN_THREATEN_DISTANCE,(Direction.NORTHWEST + direction_parity)),
		]

func moved():
	move_rules[0].distance = PAWN_MOVE_DISTANCE

func promote():
	pass
