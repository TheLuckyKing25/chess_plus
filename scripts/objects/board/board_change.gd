# documents the changes made to the board during a half turn
class_name BoardChange
extends Resource

static var _change_function_lookup: Dictionary[String, Callable] = {
	"board_representation": _change_board_representation,
	"captured": _change_board_representation, # placeholder function to prevent error
	"player_to_move": _change_player_to_move,
}


static var history: Array[BoardChange] = []


var changed_data: Dictionary[String, Variant] = {
	# variable_name: data_changed,
}


# merge all changes in the given array of BoardChanges.
static func concatenate_changes(changes: Array[BoardChange]):
	pass


static func apply(change: BoardChange, board_data: BoardData):
	for key in change.changed_data.keys():
		if _change_function_lookup.has(key):
			_change_function_lookup.get(key).call(board_data, change.changed_data.get(key))

	ObjectStateComponent.clear_intermediate_states()

	change.commit()
	#DebugPrinter.print_pretty(history)


static func _change_board_representation(board_data: BoardData, value: Variant):
	var new_board_representation: Dictionary = Dictionary(board_data.board_representation)
	new_board_representation.merge(value,true)
	board_data.board_representation = new_board_representation

	if board_data.assigned_object != null:
		var piece_moves_to: Array = value.values().filter(
				func(change): return true if change[BoardData.PIECE_DATA] != null else false
			)
		for move: Array in piece_moves_to:
			move.get(BoardData.PIECE_DATA).assigned_object.move(move.get(BoardData.TILE_DATA).assigned_object)

		var piece_moves_from: Array = value.values().filter(
				func(change): return false if change[BoardData.PIECE_DATA] != null else true
			)
		for move: Array in piece_moves_from:
			move.get(BoardData.TILE_DATA).occupant = null


static func _change_player_to_move(board_data: BoardData, value: Variant):
	board_data.player_to_move = value.data


# adds a change to the dictionary
func add_change(variable_name: String, data:Variant):
	if changed_data.has(variable_name) and data is Dictionary and changed_data.get(variable_name) is Dictionary:
		changed_data.get(variable_name).merge(data)
	else:
		changed_data.set(variable_name,data)


func commit():
	history.append(self)
