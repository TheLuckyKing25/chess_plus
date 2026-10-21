# documents the changes made to the board during a half turn
class_name BoardChange
extends Resource

const NEW_BOARD_INFO_LABEL: StringName = &"new_board_info"
const NEXT_PLAYER_LABEL: StringName = &"next_player"

const MOVE_INFO_LABEL: StringName = &"move_info"
const MOVING_PIECE_LABEL: StringName = &"moving_piece"
const STARTING_TILE_LABEL: StringName = &"starting_tile"
const TARGET_TILE_LABEL: StringName = &"target_tile"
const CAPTURES_LABEL: StringName = &"captures"


static var make_change_handlers: ChangeHandlerList = ChangeHandlerList.new(MoveObject._make_change, SwitchPlayer._make_change, Capture._make_change)


static var reverse_change_handlers: ChangeHandlerList = ChangeHandlerList.new()


var change_data: Dictionary[StringName, Variant] = {
	NEW_BOARD_INFO_LABEL: BoardChangeStruct.new(),
	MOVE_INFO_LABEL: MoveStruct.new()
}


var board_info: BoardChangeStruct:
	get: return change_data.get(NEW_BOARD_INFO_LABEL)


var move_info: MoveStruct:
	get: return change_data.get(MOVE_INFO_LABEL)


static func apply_change(change: BoardChange, board: BoardObject) -> void:
	for change_func:Callable in make_change_handlers.handler_list:
		change_func.call(board, change)
	change.change_data.get(MOVE_INFO_LABEL).reset_flags()
	change.change_data.get(NEW_BOARD_INFO_LABEL).reset_flags()
	board.valid_destinations = BoardSearch.search(board)


static func print_change(change: BoardChange) -> void:
	var formatted_change: Dictionary = {}
	formatted_change = change.change_data.duplicate()
	formatted_change.set(NEW_BOARD_INFO_LABEL,formatted_change.get(NEW_BOARD_INFO_LABEL).info)
	formatted_change.set(MOVE_INFO_LABEL,formatted_change.get(MOVE_INFO_LABEL).info)

	Debug.Printer.print_pretty_json("BoardChanges", formatted_change, 1)




class ChangeHandlerList:
	var handler_list: Array[Callable] = []

	func _init(...handlers:Array) -> void:
		handler_list.append_array(handlers)


	func add_handler(name: String, function: Callable) -> void:
		if function in handler_list: return
		handler_list.append(function)


class Capture:
	const CAPTURED_PIECE_LABEL: StringName = &"captured_piece"
	const OCCUPYING_TILE_LABEL: StringName = &"occupying_tile"

	const struct: Dictionary = {
		CAPTURED_PIECE_LABEL: null,
		OCCUPYING_TILE_LABEL: null,
	}

	static func new_struct() -> Dictionary:
		return struct.duplicate(true)

	static func _make_change(board: BoardObject, change_data: BoardChange) -> void:
		var captures_array: Array = change_data.move_info.info.get(BoardChange.CAPTURES_LABEL)
		for info in captures_array:
			var captured_piece: PieceObject = info.get(CAPTURED_PIECE_LABEL)

			if not is_instance_valid(captured_piece): continue
			var tile: TileObject = board.tile_grid.find_tile_occupied_by(captured_piece)

			# For cases where the moved piece captures another piece
			# without landing on the captured piece's tile.
			# EX. en passant
			if is_instance_valid(tile):
				tile.occupant = null if tile.occupant == captured_piece else tile.occupant

			captured_piece.add_to_group(Constants.Groups.IS_CAPTURED)
			board.tile_grid.remove_object_from_board(captured_piece)


class MoveObject:
	static func _make_change(board: BoardObject, change_data: BoardChange) -> void:
		var starting_tile: TileObject = change_data.move_info.info.get(BoardChange.STARTING_TILE_LABEL)
		var target_tile: TileObject = change_data.move_info.info.get(BoardChange.TARGET_TILE_LABEL)
		board.tile_grid.move_occupant(starting_tile, target_tile)


class SwitchPlayer:
	static func _make_change(board: BoardObject, change_data: BoardChange) -> void:
		board.player_component.player_to_move = change_data.board_info.info.next_player


class BoardChangeStruct:
	static var struct: Dictionary = {
		NEXT_PLAYER_LABEL: null
	}


	static var flags: Dictionary[StringName,bool] = {}


	static func add_flag(name: StringName) -> void:
		if name in flags.keys():
			return
		flags.set(name, false)


	static func add_key(name: StringName, default_value: Variant) -> void:
		if name in struct.keys():
			return
		struct.set(name,null)


	var info: Dictionary


	func _init():
		info = struct.duplicate(true)
		add_info(&"flags",flags.duplicate(true))


	func add_info(variable_name: String, new_data:Variant) -> void:
		var current_data: Variant = info.get(variable_name)

		var new_data_type:int = typeof(new_data)
		var current_data_type:int = typeof(current_data)
		var do_types_match: bool = new_data_type == current_data_type
		var are_both_dictionaries: bool = do_types_match and new_data_type == TYPE_DICTIONARY
		var are_both_arrays: bool = do_types_match and new_data_type == TYPE_ARRAY

		if info.has(variable_name) and are_both_dictionaries:
			current_data.merge(new_data)
		elif info.has(variable_name) and are_both_arrays:
			current_data.append_array(new_data)
		else:
			info.set(variable_name,new_data)


	func set_flag(flag_name: String, value: bool):
		info.flags.set(flag_name, value)


	func reset_flags():
		for key in info.flags:
			info.flags.set(key, false)


class MoveStruct:
	static var struct: Dictionary = {
		MOVING_PIECE_LABEL: null,
		STARTING_TILE_LABEL: null,
		TARGET_TILE_LABEL: null,
		CAPTURES_LABEL: []
	}


	static var flags: Dictionary[StringName,bool] = {}


	static func add_flag(name: StringName) -> void:
		if name in flags.keys():
			return
		flags.set(name, false)


	static func add_key(name: StringName, default_value: Variant) -> void:
		if name in struct.keys():
			return
		struct.set(name,null)


	var info: Dictionary


	func _init():
		info = struct.duplicate(true)
		add_info(&"flags",flags.duplicate(true))


	func add_info(variable_name: String, new_data:Variant) -> void:
		var current_data: Variant = info.get(variable_name)

		var new_data_type:int = typeof(new_data)
		var current_data_type:int = typeof(current_data)
		var do_types_match: bool = new_data_type == current_data_type
		var are_both_dictionaries: bool = do_types_match and new_data_type == TYPE_DICTIONARY
		var are_both_arrays: bool = do_types_match and new_data_type == TYPE_ARRAY

		if info.has(variable_name) and are_both_dictionaries:
			current_data.merge(new_data)
		elif info.has(variable_name) and are_both_arrays:
			current_data.append_array(new_data)
		else:
			info.set(variable_name,new_data)


	func set_flag(flag_name: String, value: bool):
		info.flags.set(flag_name, value)


	func reset_flags():
		for key in info.flags:
			info.flags.set(key, false)
