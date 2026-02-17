@icon("res://assets/icons/WhiteKing.tres")

class_name KingPiece
extends Piece


const KING_MOVE_DISTANCE: int = 1


func _on_ready() -> void:
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
