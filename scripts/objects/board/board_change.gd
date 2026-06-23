# documents the changes made to the board during a half turn
class_name BoardChange
extends Resource

# not constant, allowing for additional functions to be
# added depending on the rules selected at the start of the match
static var _handler_function_lookup: Dictionary[String, Callable] = {
	"board_representation": _handle_board_representation,
	"player_to_move": _handle_player_to_move,
	"captured": _handle_captures,
}


static var history: Array[BoardChange] = []


var changed_data: Dictionary[String, Variant] = {
	# variable_name: data_changed,
}


static func merge_changes(changes: Array[BoardChange], merge_with_previous: bool = false) -> BoardChange:
	var merged_change: BoardChange = BoardChange.new()
	for board_change: BoardChange in changes:
		_merge_recursive(merged_change.changed_data,board_change.changed_data, true)
		#merged_change.changed_data.merge(board_change.changed_data,true)
	if merge_with_previous:
		history[-1].changed_data.merge(merged_change.changed_data)
	return merged_change


static func _merge_recursive(merged_values: Variant, new_values: Variant, overwrite: bool = false):
	if merged_values is Dictionary and new_values is Dictionary:
		merged_values.merge(_merge_dictionaries(merged_values,new_values,overwrite))
		return merged_values
	elif merged_values is Array and new_values is Array:
		for item in new_values:
			if not item in merged_values:
				merged_values.append(item)
		return merged_values
	#else:
		#merged_values.merge(new_values, overwrite)


static func _merge_dictionaries(merged_values: Dictionary, new_values: Dictionary, overwrite: bool = false):
	for key in new_values.keys():
		if merged_values.has(key):
			if merged_values.get(key) is Dictionary and new_values.get(key) is Dictionary:
				merged_values.set(key, _merge_recursive(merged_values.get(key),new_values.get(key), overwrite))
			elif merged_values.get(key) is Array and new_values.get(key) is Array:
				merged_values.set(key, _merge_recursive(merged_values.get(key),new_values.get(key), overwrite))
			else:
				merged_values.set(key,new_values.get(key))
		else:
			merged_values.set(key,new_values.get(key))

	return merged_values


static func add_handler(name: String, function: Callable):
	if name in _handler_function_lookup.keys() and _handler_function_lookup.get(name) == function:
		return
	_handler_function_lookup.set(name,function)


static func apply_change(change: BoardChange, board_data: BoardData) -> void:
	for key in change.changed_data.keys():
		if _handler_function_lookup.has(key):
			_handler_function_lookup.get(key).call(board_data, change.changed_data.get(key))

	ObjectStateComponent.clear_intermediate_states()

	if is_instance_valid(board_data.assigned_object):
		board_data.assigned_object.turn_changed.emit()

	if change.changed_data.has("board_representation"):
		change.commit()
	else:
		history[-1].changed_data.merge(change.changed_data)
		DebugPrinter.print_pretty(BoardChange.merge_changes(history).changed_data)


static func _handle_board_representation(board_data: BoardData, value: Variant) -> void:
	var new_board_representation: Dictionary = Dictionary(board_data.board_representation)
	new_board_representation.merge(value,true)
	board_data.board_representation = new_board_representation

	if is_instance_valid(board_data.assigned_object):
		for move: Array in value.values():
			move.get(BoardData.TILE_DATA).occupant = move.get(BoardData.PIECE_DATA)
			if is_instance_valid(move.get(BoardData.PIECE_DATA)):
				move.get(BoardData.PIECE_DATA).has_moved = true
				if is_instance_valid(board_data.assigned_object):
					board_data.assigned_object.audio_piece_move.play()


static func _handle_player_to_move(board_data: BoardData, value: Variant) -> void:
	board_data.player_to_move = value.data


static func _handle_captures(board_data: BoardData, value: Variant) -> void:
	for piece in value:
		piece.is_captured = true
		if is_instance_valid(board_data.assigned_object):
			board_data.assigned_object.audio_piece_capture.play()


# adds a change to the dictionary
func add_change(variable_name: String, new_data:Variant) -> void:
	var current_data: Variant = changed_data.get(variable_name)
	if changed_data.has(variable_name) and new_data is Dictionary and current_data is Dictionary:
		current_data.merge(new_data)
	elif changed_data.has(variable_name) and new_data is Array and current_data is Array:
		current_data.append(new_data)
	else:
		changed_data.set(variable_name,new_data)


func commit() -> void:
	history.append(self)
