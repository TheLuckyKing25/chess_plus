class_name Promotion
extends PieceRule


const RULE_NAME: String = "promote"


@export var promotion_options: Array[PieceConfig]


static func _handle_change(board_data: BoardData, value: Variant):
	for piece:PieceData in value.keys():
		piece.type = value.get(piece)


static func _handle_merge(accum_value: Dictionary, merging_value:Dictionary):
	accum_value.merge(merging_value,true)


func _init():
	var change_function:Callable = Callable(Promotion,"_handle_change")
	BoardChange.add_change_handler(RULE_NAME,change_function)
	var merge_function:Callable = Callable(Promotion,"_handle_merge")
	BoardChange.add_merge_handler(RULE_NAME,merge_function)


func evaluate_rule_application(current_change: BoardChange, piece:PieceData):
	var _piece_filter: Callable = func(item):return (item is PieceData)
	var _occupied_tile_filter: Callable = func(array:Array): return array.any(_piece_filter)

	var recent_board_history_data = BoardChange.history.back().changed_data
	var changed_board_rep: Dictionary = recent_board_history_data.get(BoardChange.BOARD_REP_RULE_NAME)
	var destination: Array = changed_board_rep.values().filter(_occupied_tile_filter).front()

	var is_on_promotion_rank: bool = (piece.player.promotion_rank == destination.get(BoardData.TILE_DATA_INDEX).rank)
	if is_on_promotion_rank and piece == destination.get(BoardData.PIECE_DATA_INDEX):
		# TEMPORARY: FIRST PROMOTION OPTION IS CHOSEN
		var first_promotion_option: PieceConfig = promotion_options.front()
		var change_info: Dictionary[PieceData, PieceConfig] = {piece: first_promotion_option}
		current_change.add_change(RULE_NAME, change_info)
