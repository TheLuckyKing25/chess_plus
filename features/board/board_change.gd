# documents the changes made to the board during a half turn
class_name BoardChange
extends Resource

const MOVE_RULE_NAME: StringName = &"move"
const NEXT_PLAYER_RULE_NAME: StringName = &"next_player"
const CAPTURED_RULE_NAME: StringName = &"captured"


# not constant, allowing for additional functions to be
# added depending on the rules selected at the start of the match
static var _change_handler_function_lookup: Dictionary[String, Callable] = {
	MOVE_RULE_NAME: _handle_move_change,
	NEXT_PLAYER_RULE_NAME: _handle_next_player_change,
	CAPTURED_RULE_NAME: _handle_capture_change,
}

var changed_data: Dictionary[StringName, Variant] = {}


#
#static func merge_changes(changes: Array[BoardChange]) -> BoardChange:
	#var merged_change: BoardChange = BoardChange.new()
	#for board_change: BoardChange in changes:
		#for key in board_change.changed_data.keys():
			#if not _merge_handler_function_lookup.has(key):
				#continue
#
			#var merging_value: Variant = board_change.changed_data.get(key)
			#var default_value: Variant = (
					#Array() if typeof(merging_value) == TYPE_ARRAY
					#else Dictionary() if typeof(merging_value) == TYPE_DICTIONARY
					#else null
				#)
			#var accum_value = merged_change.changed_data.get_or_add(key,default_value)
#
			#var merge_function = _merge_handler_function_lookup.get(key)
			#var merged_data = merge_function.call(accum_value, merging_value)
#
			#if merged_data == null:
				#continue
			#merged_change.changed_data.set(key,merged_data)
	#return merged_change


static func apply_change(change: BoardChange, board: BoardObject) -> void:
	for key:String in change.changed_data.keys():
		if _change_handler_function_lookup.has(key):
			var change_function = _change_handler_function_lookup.get(key)
			change_function.call(board, change.changed_data.get(key))

	ObjectStateComponent.clear_intermediate_states()

	if is_instance_valid(board):
		board.turn_changed.emit()

	board.board_history.append(change)


#region Change Handlers
static func add_change_handler(name: String, function: Callable) -> void:
	if name in _change_handler_function_lookup.keys() and _change_handler_function_lookup.get(name) == function:
		return
	_change_handler_function_lookup.set(name,function)


static func _handle_move_change(board: BoardObject, value: Variant) -> void:
	board.tile_grid.move_occupant(value.from, value.to)


static func _handle_next_player_change(board: BoardObject, value: Variant) -> void:
	board.player_component.player_to_move = value


static func _handle_capture_change(board: BoardObject, value: Variant) -> void:
	for object in value:
		board.tile_grid.capture(object)

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
