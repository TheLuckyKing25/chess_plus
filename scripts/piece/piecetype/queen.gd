@icon("res://assets/icons/WhitePawn.tres")

class_name QueenPiece
extends Piece


const QUEEN_MOVE_DISTANCE: int = 8


func _on_ready() -> void:
	move_rules = [
		MoveRule.new(ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET,QUEEN_MOVE_DISTANCE,(Direction.NORTH + direction_parity)),
		MoveRule.new(ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET,QUEEN_MOVE_DISTANCE,(Direction.NORTHEAST + direction_parity)),
		MoveRule.new(ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET,QUEEN_MOVE_DISTANCE,(Direction.EAST + direction_parity)),
		MoveRule.new(ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET,QUEEN_MOVE_DISTANCE,(Direction.SOUTHEAST + direction_parity)),
		MoveRule.new(ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET,QUEEN_MOVE_DISTANCE,(Direction.SOUTH + direction_parity)),
		MoveRule.new(ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET,QUEEN_MOVE_DISTANCE,(Direction.SOUTHWEST + direction_parity)),
		MoveRule.new(ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET,QUEEN_MOVE_DISTANCE,(Direction.WEST + direction_parity)),
		MoveRule.new(ActionType.MOVE|ActionType.THREATEN,PurposeType.UNSET,QUEEN_MOVE_DISTANCE,(Direction.NORTHWEST + direction_parity)),
	]
			
