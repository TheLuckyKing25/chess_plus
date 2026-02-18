@icon("res://assets/icons/WhiteKnight.tres")

class_name KnightPiece
extends Piece


const KNIGHT_OUTWARD_MOVE_DISTANCE: int = 2


const KNIGHT_SIDEWAYS_MOVE_DISTANCE: int = 1


func _on_ready() -> void:
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
