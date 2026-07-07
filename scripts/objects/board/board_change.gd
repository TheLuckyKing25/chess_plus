# documents the changes made to the board during a half turn
class_name BoardChange
extends Resource

const BOARD_REP_RULE_NAME:String = "board_representation"
const PLAYER_TO_MOVE_RULE_NAME:String = "player_to_move"
const CAPTURED_RULE_NAME:String = "captured"

# not constant, allowing for additional functions to be
# added depending on the rules selected at the start of the match
static var _change_handler_function_lookup: Dictionary[String, Callable] = {
	BOARD_REP_RULE_NAME: _handle_board_representation_change,
	PLAYER_TO_MOVE_RULE_NAME: _handle_player_to_move_change,
	CAPTURED_RULE_NAME: _handle_capture_change,
}


static var _merge_handler_function_lookup: Dictionary[String, Callable] = {
	BOARD_REP_RULE_NAME: _handle_board_representation_merge,
	PLAYER_TO_MOVE_RULE_NAME: _handle_player_to_move_merge,
	CAPTURED_RULE_NAME: _handle_capture_merge,
}


var changed_data: Dictionary[String, Variant] = {
	# variable_name: data_changed,
}


static func merge_changes(changes: Array[BoardChange]) -> BoardChange:
	var merged_change: BoardChange = BoardChange.new()
	for board_change: BoardChange in changes:
		for key in board_change.changed_data.keys():
			if not _merge_handler_function_lookup.has(key):
				continue

			var merging_value: Variant = board_change.changed_data.get(key)
			var default_value: Variant = (
					Array() if typeof(merging_value) == TYPE_ARRAY
					else Dictionary() if typeof(merging_value) == TYPE_DICTIONARY
					else null
				)
			var accum_value = merged_change.changed_data.get_or_add(key,default_value)

			var merge_function = _merge_handler_function_lookup.get(key)
			var merged_data = merge_function.call(accum_value, merging_value)

			if merged_data == null:
				continue
			merged_change.changed_data.set(key,merged_data)
	return merged_change


static func apply_change(change: BoardChange, board_data: BoardData) -> void:
	for key in change.changed_data.keys():
		if _change_handler_function_lookup.has(key):
			var change_function = _change_handler_function_lookup.get(key)
			change_function.call(board_data, change.changed_data.get(key))

	ObjectStateComponent.clear_intermediate_states()

	if is_instance_valid(board_data.assigned_object):
		board_data.assigned_object.turn_changed.emit()

	board_data.board_history.append(change)


#region Change Handlers
static func add_change_handler(name: String, function: Callable):
	if name in _change_handler_function_lookup.keys() and _change_handler_function_lookup.get(name) == function:
		return
	_change_handler_function_lookup.set(name,function)


static func _handle_board_representation_change(board_data: BoardData, value: Variant) -> void:
	var new_board_representation: Dictionary = Dictionary(board_data.board_representation)
	new_board_representation.merge(value,true)
	board_data.board_representation = new_board_representation

	if not is_instance_valid(board_data.assigned_object):
		return

	for move: Array in value.values():
		var move_piece_data: PieceData = move.get(BoardData.PIECE_DATA_INDEX)
		move.get(BoardData.TILE_DATA_INDEX).occupant = move_piece_data
		if is_instance_valid(move_piece_data):
			move_piece_data.has_moved = true
			if is_instance_valid(board_data.assigned_object):
				board_data.assigned_object.audio_piece_move.play()


static func _handle_player_to_move_change(board_data: BoardData, value: Variant) -> void:
	board_data.player_to_move = value.data


static func _handle_capture_change(board_data: BoardData, value: Variant) -> void:
	for piece in value:
		piece.is_captured = true
		if is_instance_valid(board_data.assigned_object):
			board_data.assigned_object.audio_piece_capture.play()
#endregion


#region Merge Handlers
static func add_merge_handler(name: String, function: Callable):
	if name in _merge_handler_function_lookup.keys() and _merge_handler_function_lookup.get(name) == function:
		return
	_merge_handler_function_lookup.set(name,function)


static func _handle_board_representation_merge(accum_value: Dictionary, merging_value:Dictionary):
	accum_value.merge(merging_value,true)


static func _handle_player_to_move_merge(accum_value: Variant, merging_value:Variant):
	return merging_value if is_instance_valid(merging_value) else accum_value


static func _handle_capture_merge(accum_value: Array, merging_value:Array):
	accum_value.append_array(merging_value)
#endregion


# adds a change to the dictionary
func add_change(variable_name: String, new_data:Variant) -> void:
	var current_data: Variant = changed_data.get(variable_name)
	if changed_data.has(variable_name) and new_data is Dictionary and current_data is Dictionary:
		current_data.merge(new_data)
	elif changed_data.has(variable_name) and new_data is Array and current_data is Array:
		current_data.append(new_data)
	else:
		changed_data.set(variable_name,new_data)
