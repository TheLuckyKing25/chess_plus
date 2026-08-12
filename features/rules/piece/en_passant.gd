class_name EnPassant
extends Rule


const RULE_NAME: String = "en_passant"
const EN_PASSANT_GROUP: StringName = "EnPassant"


static var current_en_passant: Dictionary = {}


static func _handle_change(board_data: BoardObject, value: Dictionary):
	if not current_en_passant.is_empty():
		_clear_current_en_passant(board_data)
	if not value.is_empty():
		_set_new_en_passant(value)
	board_data.recalculate_valid_destinations()


static func _clear_current_en_passant(board_data: BoardObject):
	if board_data.current_changes.changed_data.move.moving_player == current_en_passant.clear_on_player_turn_end:
		current_en_passant.tile.remove_from_group(EN_PASSANT_GROUP)
		current_en_passant.piece.remove_from_group(EN_PASSANT_GROUP)
		current_en_passant = {}


static func _set_new_en_passant(value:Dictionary):
	current_en_passant = value
	var piece: PieceObject = value.piece
	piece.add_to_group(EN_PASSANT_GROUP)
	var tile: TileObject = value.tile
	tile.add_to_group(EN_PASSANT_GROUP)


func _ready():
	var change_handler_function: Callable = Callable(EnPassant,"_handle_change")
	BoardChange.add_change_handler(RULE_NAME,change_handler_function)
	if not owner.threatenable_groups.has(EN_PASSANT_GROUP):
		owner.threatenable_groups.append(EN_PASSANT_GROUP)


func evaluate_rule(board: BoardObject):
	_set_en_passant(board)
	_check_for_en_passant_capture(board)


func _set_en_passant(board: BoardObject):
	const APPLICABLE_DISTANCE:int = 2

	var move: Dictionary = board.current_changes.changed_data.move

	var starting_tile: TileObject = move.from
	var destination_tile: TileObject = move.to
	var movement_delta: Vector2i = destination_tile.position_vector - starting_tile.position_vector
	var movement_distance: Vector2i = abs(movement_delta)
	var is_rule_applicable: bool = (
			(movement_distance.x >= APPLICABLE_DISTANCE or movement_distance.y >= APPLICABLE_DISTANCE)
			and owner == move.occupant
			)

	if is_rule_applicable:
		var movement_direction: Vector2i = movement_delta.sign()
		var en_passant_tile_position:Vector2i = destination_tile.position_vector - movement_direction
		var en_passant_tile: TileObject = board.tile_grid.get_tile_at_position(en_passant_tile_position)
		var changed_info: Dictionary = {
			"piece": owner,
			"tile": en_passant_tile,
			"clear_on_player_turn_end": PlayerComponent.opponent(owner.player_ownership.player)
			}
		board.current_changes.add_change(RULE_NAME, changed_info)
	else:
		board.current_changes.add_change(RULE_NAME, {})


func _check_for_en_passant_capture(board: BoardObject):
	var current_changes: BoardChange = board.current_changes
	var changed_data: Dictionary = current_changes.changed_data

	var is_en_passant: bool = current_en_passant.get("tile") == changed_data.move.to
	var is_moving_piece: bool = owner == changed_data.move.occupant
	if is_en_passant and is_moving_piece:
		current_changes.add_change(BoardChange.CAPTURED_RULE_NAME,[current_en_passant.get("piece")])
