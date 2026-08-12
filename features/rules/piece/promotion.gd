class_name Promotion
extends Rule


const RULE_NAME: StringName = "promote"


@export var promotion_options: Array[Constants.TypePiece]


static func _handle_change(board: BoardObject, value: Variant):
	var promoting_piece: PieceObject = value.keys().front()
	var promoting_to: StringName = Constants.PIECE_SCENE_UID_DICT.get(value.get(promoting_piece))
	promoting_piece.change_piece_type(promoting_to)


func _ready():
	var change_function:Callable = Callable(_handle_change)
	BoardChange.add_change_handler(RULE_NAME,change_function)


func evaluate_rule(board: BoardObject):
	var piece: PieceObject = owner
	var changed_data: Dictionary = board.current_changes.changed_data

	var is_piece_moving: bool = piece == changed_data.move.occupant
	var is_on_promotion_rank: bool = piece.player_ownership.player.promotion_rank == changed_data.move.to.rank
	var is_rule_applicable: bool = is_on_promotion_rank and is_piece_moving

	if is_rule_applicable:
		# TEMPORARY: FIRST PROMOTION OPTION IS CHOSEN
		var first_promotion_option: Constants.TypePiece = promotion_options.front()
		var change_info: Dictionary[PieceObject, Constants.TypePiece] = {piece: first_promotion_option}
		board.current_changes.add_change(RULE_NAME, change_info)
