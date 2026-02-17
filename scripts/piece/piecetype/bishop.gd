@icon("res://assets/icons/WhiteBishop.tres")

class_name BishopPiece
extends Piece

const BISHOP_MOVE_DISTANCE: int = 8


func _on_ready() -> void:
	direction_parity = -2 * (parity - 1)

	move_rules = [
		MoveRule.new(ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET,BISHOP_MOVE_DISTANCE,(Direction.NORTHEAST + direction_parity)),
		MoveRule.new(ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET,BISHOP_MOVE_DISTANCE,(Direction.SOUTHWEST + direction_parity)),
		MoveRule.new(ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET,BISHOP_MOVE_DISTANCE,(Direction.NORTHWEST + direction_parity)),
		MoveRule.new(ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET,BISHOP_MOVE_DISTANCE,(Direction.SOUTHEAST + direction_parity)),
	]
