class_name EnPassant
extends Rule

const RULE_NAME: String = "en_passant"
const GROUP_NAME: StringName = &"EnPassant"

const PROVOKING_PIECE_LABEL: StringName = &"provoking_piece"
const TRIGGER_TILE_LABEL: StringName = &"trigger_tile"
const PLAYER_TURN_CLEAR_LABEL: StringName = &"clear_on_player_turn_end"

const FLAG_IS_EN_PASSANT_CAPTURE_LABEL: StringName = &"isEnPassantCapture"


const RULE_INFO_STRUCT: Dictionary = {
	PROVOKING_PIECE_LABEL: null,  # piece that is the target of en passant
	TRIGGER_TILE_LABEL:  null,    # the tile that will trigger the en passant
	PLAYER_TURN_CLEAR_LABEL: null # when the en passant expires.
}


## While true: enables Game Objects with this rule to be threatened by En Passant
@export var provoke_en_passant:bool


## While true: enables Game Objects with this rule to perform En Passant
@export var perform_en_passant_capture:bool


static var active_en_passant: Dictionary = {}


static func _make_change(board_data: BoardObject, change_data:BoardChange):
	if not active_en_passant.is_empty():
		_clear_active_en_passant(change_data)
	if not change_data.move_info.info.get(RULE_NAME).is_empty():
		_set_new_en_passant(change_data)


static func _clear_active_en_passant(changes:BoardChange):
	var move_info: Dictionary = changes.move_info.info
	var current_player: Player = move_info.moving_piece.player_ownership.player
	if  current_player == active_en_passant.get(PLAYER_TURN_CLEAR_LABEL):
		active_en_passant.get(TRIGGER_TILE_LABEL).remove_from_group(GROUP_NAME)
		active_en_passant.get(PROVOKING_PIECE_LABEL).remove_from_group(GROUP_NAME)
		active_en_passant = {}


static func _set_new_en_passant(change_data:BoardChange):
	active_en_passant = change_data.move_info.info.get(RULE_NAME)
	var piece: PieceObject = active_en_passant.get(PROVOKING_PIECE_LABEL)
	var tile: TileObject = active_en_passant.get(TRIGGER_TILE_LABEL)
	piece.add_to_group(GROUP_NAME)
	tile.add_to_group(GROUP_NAME)


static func _reverse_change(board_data: BoardObject, change_data:BoardChange):
	if not active_en_passant.is_empty():
		_clear_active_en_passant(change_data)
	if not change_data.move_info.info.get(RULE_NAME).is_empty():
		_set_new_en_passant(change_data)






func _ready():
	var change_handler: Callable = Callable(EnPassant,"_make_change")
	BoardChange.make_change_handlers.add_handler(RULE_NAME, change_handler)
	BoardChange.MoveStruct.add_key(RULE_NAME, {})
	BoardChange.MoveStruct.add_flag(FLAG_IS_EN_PASSANT_CAPTURE_LABEL)

	if not owner.threatenable_groups.has(GROUP_NAME):
		owner.threatenable_groups.append(GROUP_NAME)


func evaluate_rule(board: BoardObject, changes:BoardChange):
	if provoke_en_passant:
		_set_en_passant(board, changes)
	if perform_en_passant_capture:
		_check_for_en_passant_capture(board, changes)


func _set_en_passant(board: BoardObject, changes:BoardChange):
	const APPLICABLE_DISTANCE:int = 2

	var move: BoardChange.MoveStruct = changes.move_info

	var starting_tile: TileObject = move.info.get(BoardChange.STARTING_TILE_LABEL)
	var destination_tile: TileObject = move.info.get(BoardChange.TARGET_TILE_LABEL)
	var movement_delta: Vector2i = destination_tile.position_vector - starting_tile.position_vector
	var movement_distance: Vector2i = abs(movement_delta)
	var is_rule_applicable: bool = (
			(movement_distance.x >= APPLICABLE_DISTANCE or movement_distance.y >= APPLICABLE_DISTANCE)
			and owner == move.info.moving_piece
			)

	if is_rule_applicable:
		var movement_direction: Vector2i = movement_delta.sign()
		var en_passant_tile_position:Vector2i = destination_tile.position_vector - movement_direction
		var en_passant_tile: TileObject = board.tile_grid.get_tile_at_position(en_passant_tile_position)

		var opponent: Player = PlayerComponent.opponent(owner.player_ownership.player)

		var rule_info: Dictionary = RULE_INFO_STRUCT.duplicate()
		rule_info.set(PROVOKING_PIECE_LABEL, owner)
		rule_info.set(TRIGGER_TILE_LABEL, en_passant_tile)
		rule_info.set(PLAYER_TURN_CLEAR_LABEL, opponent)
		move.add_info(RULE_NAME, rule_info)
	else:
		move.add_info(RULE_NAME, {})


func _check_for_en_passant_capture(board: BoardObject, changes:BoardChange):
	var move_info: BoardChange.MoveStruct = changes.move_info

	var is_en_passant: bool = active_en_passant.get(TRIGGER_TILE_LABEL) == move_info.info.target_tile
	var is_moving_piece: bool = owner == move_info.info.moving_piece
	if is_en_passant and is_moving_piece:
		var capture_dict: Dictionary = BoardChange.Capture.new_struct()
		var provoking_piece: PieceObject = active_en_passant.get(PROVOKING_PIECE_LABEL)
		capture_dict.set(BoardChange.Capture.CAPTURED_PIECE_LABEL, provoking_piece)
		var occupying_tile: TileObject = board.tile_grid.find_tile_occupied_by(provoking_piece)
		capture_dict.set(BoardChange.Capture.OCCUPYING_TILE_LABEL, occupying_tile)
		move_info.add_info(BoardChange.CAPTURES_LABEL,[capture_dict])
		move_info.set_flag(FLAG_IS_EN_PASSANT_CAPTURE_LABEL,true)
