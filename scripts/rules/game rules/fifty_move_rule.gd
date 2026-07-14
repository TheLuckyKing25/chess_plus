# counts the number of moves
class_name FiftyMoveRule
extends GameRule

const TURNS_UNTIL_DRAW: int = 50
const RULE_NAME: String = "half_move_clock"


static func _handle_change(board_data: BoardObject, value: Variant):
	#var full_turn_count: int = floor(count/2)
	#if full_turn_count == TURNS_UNTIL_DRAW:
		# DRAW
	pass


static func _handle_merge(accum_value: Variant, merging_value:Variant):
	return merging_value


func _init():
	var change_function:Callable = Callable(FiftyMoveRule,"_handle_change")
	BoardChange.add_change_handler(RULE_NAME, change_function)
	var merge_function:Callable = Callable(FiftyMoveRule,"_handle_merge")
	BoardChange.add_merge_handler(RULE_NAME, merge_function)
	resource_name = "FiftyMoveRule"


func evaluate_rule_application(current_change: BoardChange, board:BoardObject):
	var _piece_filter: Callable = func(item):return (item is PieceObject)
	var _occupied_tile_filter: Callable = func(array:Array): return array.any(_piece_filter)

	var current_count: int = 0

	var changed_board_rep: Dictionary = current_change.changed_data.get(BoardChange.BOARD_REP_RULE_NAME)
	var destination: Array = changed_board_rep.values().filter(_occupied_tile_filter).front()

	var pawn_config: PieceConfig = load(Constants.piece_config.get(Constants.TypePiece.PAWN))
	var was_pawn_moved: bool = destination.get(BoardObject.PIECE_DATA_INDEX).type.name == pawn_config.name
	var was_piece_captured:bool = current_change.changed_data.has(BoardChange.CAPTURED_RULE_NAME)
	if not was_piece_captured and not was_pawn_moved:
		if not board.board_history.is_empty():
			var prev_change:Dictionary = board.board_history.back().changed_data
			var prev_count: int = prev_change.get(RULE_NAME)
			current_count = prev_count + 1
		else:
			current_count = 1
	current_change.add_change(RULE_NAME, current_count)
