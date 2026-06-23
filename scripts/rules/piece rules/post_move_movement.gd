class_name PostMoveMovement
extends PieceRule

enum ValueIndex {
	PIECE = 0,
	NEW_MOVEMENT = 1,
}


@export var new_movement: AbstractMovement


var has_rule_been_applied: bool = false


static func _handle_post_move_movement(board_data: BoardData, value: Variant):
	var pieces: Array = value.keys()
	for piece: PieceData in pieces:
		var new_movement: AbstractMovement = value.get(piece)
		piece.type.base_movement = new_movement


func _init():
	BoardChange.add_handler("post_move_movement",Callable(PostMoveMovement,"_handle_post_move_movement"))


func evaluate_rule_application(current_change: BoardChange, piece: PieceData):
	if piece.has_moved and not has_rule_been_applied:
		current_change.add_change("post_move_movement", {piece:new_movement.duplicate_deep()})
		has_rule_been_applied = true
