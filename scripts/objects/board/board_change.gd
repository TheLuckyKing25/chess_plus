# documents the changes made to the board during a half turn
class_name BoardChange
extends Resource

# not constant, allowing for additional functions to be
# added depending on the rules selected at the start of the match
static var _change_function_lookup: Dictionary[String, Callable] = {
	"board_representation": _change_board_representation,
	"player_to_move": _change_player_to_move,
	"captured": _process_captures,
}


static var history: Array[BoardChange] = []


var changed_data: Dictionary[String, Variant] = {
	# variable_name: data_changed,
}


static func apply_change(change: BoardChange, board_data: BoardData) -> void:
	for key in change.changed_data.keys():
		if _change_function_lookup.has(key):
			_change_function_lookup.get(key).call(board_data, change.changed_data.get(key))

	ObjectStateComponent.clear_intermediate_states()

	if is_instance_valid(board_data.assigned_object):
		board_data.assigned_object.turn_changed.emit()

	change.commit()
	#DebugPrinter.print_pretty(history)


static func _change_board_representation(board_data: BoardData, value: Variant) -> void:
	var new_board_representation: Dictionary = Dictionary(board_data.board_representation)
	new_board_representation.merge(value,true)
	board_data.board_representation = new_board_representation

	if is_instance_valid(board_data.assigned_object):
		for move: Array in value.values():
			move.get(BoardData.TILE_DATA).occupant = move.get(BoardData.PIECE_DATA)
			if is_instance_valid(move.get(BoardData.PIECE_DATA)):
				move.get(BoardData.PIECE_DATA).has_moved = true


static func _change_player_to_move(board_data: BoardData, value: Variant) -> void:
	board_data.player_to_move = value.data


static func _process_captures(board_data: BoardData, value: Variant) -> void:
	for piece in value:
		piece.is_captured = true


# adds a change to the dictionary
func add_change(variable_name: String, data:Variant) -> void:
	if changed_data.has(variable_name) and data is Dictionary and changed_data.get(variable_name) is Dictionary:
		changed_data.get(variable_name).merge(data)
	elif changed_data.has(variable_name) and data is Array and changed_data.get(variable_name) is Array:
		changed_data.get(variable_name).append(data)
	else:
		changed_data.set(variable_name,data)


func commit() -> void:
	history.append(self)
