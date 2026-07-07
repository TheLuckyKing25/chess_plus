class_name PostMoveMovement
extends PieceRule


const RULE_NAME: String = "post_move_movement"


@export var new_movement: AbstractMovement


var has_rule_been_applied: bool = false


static func _handle_change(board_data: BoardData, value: Variant):
	var pieces: Array = value.keys()
	for piece: PieceData in pieces:
		var post_move_movement: AbstractMovement = value.get(piece)
		piece.type.base_movement = post_move_movement


static func _handle_merge(accum_value: Dictionary, merging_value:Dictionary):
	accum_value.merge(merging_value,true)


func _init():
	var change_handler_function: Callable = Callable(PostMoveMovement,"_handle_change")
	BoardChange.add_change_handler(RULE_NAME,change_handler_function)
	var merge_handler_function: Callable = Callable(PostMoveMovement,"_handle_merge")
	BoardChange.add_merge_handler(RULE_NAME,merge_handler_function)


func evaluate_rule_application(current_change: BoardChange, piece: PieceData):
	var _piece_filter: Callable = func(accum, array): return accum + [array.get(BoardData.PIECE_DATA_INDEX)]
	var _validity_filter: Callable = func(item): return is_instance_valid(item)

	var changed_board_rep:Dictionary = current_change.changed_data.get(BoardChange.BOARD_REP_RULE_NAME)
	var moved_pieces = changed_board_rep.values().reduce(_piece_filter,[]).filter(_validity_filter)
	if not has_rule_been_applied and not piece.has_moved and piece in moved_pieces:
		var change_info: Dictionary[PieceData, AbstractMovement] = {piece: new_movement.duplicate_deep()}
		current_change.add_change(RULE_NAME, change_info)
		has_rule_been_applied = true
