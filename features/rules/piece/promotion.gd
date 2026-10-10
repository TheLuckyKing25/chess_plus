class_name Promotion
extends Rule


const RULE_NAME: StringName = &"promote"

const INFO_PROMOTING_PIECE_LABEL: StringName = &"promoting_piece"
const INFO_PROMOTE_TO_LABEL: StringName = &"promote_to"

const FLAG_IS_PROMOTING_LABEL: StringName = &"piecePromoted"

const RULE_INFO_STRUCT: Dictionary = {
		INFO_PROMOTING_PIECE_LABEL: null,
		INFO_PROMOTE_TO_LABEL: null
		}


@export var promotion_options: Array[Constants.TypePiece]


static func _make_change(board: BoardObject, change_data:BoardChange):
	if not change_data.move_info.info.flags.get(FLAG_IS_PROMOTING_LABEL): return

	var promotion_info: Dictionary = change_data.move_info.info.get(RULE_NAME)
	var promoting_piece: PieceObject = promotion_info.get(INFO_PROMOTING_PIECE_LABEL)
	var promoting_to: PieceObject = promotion_info.get(INFO_PROMOTE_TO_LABEL)
	promoting_piece.change_piece_type(promoting_to)


# TODO: Have this class instantiate the requested promotion piece and include
# that instantiated piece in the Change Data instead of just the name
static func _reverse_change(board: BoardObject, change_data:BoardChange):
	if not change_data.move_info.info.flags.get(FLAG_IS_PROMOTING_LABEL): return

	var promotion_info: Dictionary = change_data.move_info.info.get(RULE_NAME)
	var promoted_piece: PieceObject = promotion_info.get(INFO_PROMOTE_TO_LABEL)
	var original_piece: PieceObject = promotion_info.get(INFO_PROMOTING_PIECE_LABEL)
	promoted_piece.change_piece_type(original_piece)


func _ready():
	var change_handler:Callable = Callable(Promotion,"_make_change")
	BoardChange.make_change_handlers.add_handler(RULE_NAME,change_handler)
	BoardChange.MoveStruct.add_key(RULE_NAME, {})
	BoardChange.MoveStruct.add_flag(FLAG_IS_PROMOTING_LABEL)


func evaluate_rule(board: BoardObject, current_changes:BoardChange):
	var piece: PieceObject = owner
	var changed_data: Dictionary = current_changes.change_data

	var is_piece_moving: bool = piece == changed_data.move_info.info.moving_piece
	var is_on_promotion_rank: bool = piece.player_ownership.player.promotion_rank == changed_data.move_info.info.target_tile.rank_index
	var is_rule_applicable: bool = is_on_promotion_rank and is_piece_moving

	if is_rule_applicable:
		var first_promotion_option: Constants.TypePiece = promotion_options.front()
		var move_info = current_changes.move_info
		var change_info: Dictionary = RULE_INFO_STRUCT.duplicate()
		var promoting_to_uid: StringName = Constants.PIECE_SCENE_UID_DICT.get(first_promotion_option)
		var promoted_piece: PieceObject = load(promoting_to_uid).instantiate()
		current_changes.move_info.set_flag(FLAG_IS_PROMOTING_LABEL,true)
		change_info.set(INFO_PROMOTING_PIECE_LABEL, piece)
		change_info.set(INFO_PROMOTE_TO_LABEL, promoted_piece)

		move_info.add_info(RULE_NAME, change_info)
