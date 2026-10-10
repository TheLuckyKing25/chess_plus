## Allows an object with a [MovementComponent] to have different [Movement] for its first move
class_name AlternateFirstMovement
extends Rule


const RULE_NAME: String = "movement_changed"


const _FLAG_IS_MOVEMENT_CHANGING_LABEL: StringName = &"pieceMovementChanged"


const _AFFECTED_PIECE_LABEL: StringName = &"affected_piece"
const _CURRENT_MOVEMENT_LABEL: StringName = &"current_movement"
const _NEW_MOVEMENT_LABEL: StringName = &"new_movement"


const RULE_INFO_STRUCT:Dictionary = {
	_AFFECTED_PIECE_LABEL: null,
	_CURRENT_MOVEMENT_LABEL: null,
	_NEW_MOVEMENT_LABEL: null
}


@export var movement_component: MovementComponent
@export var alternate_movement: Movement

# the base movement which was overwritten by this rule
var _overwritten_movement: Movement


static func _make_change(board_data: BoardObject, change_data:BoardChange):
	if not change_data.move_info.info.flags.get(_FLAG_IS_MOVEMENT_CHANGING_LABEL):
		return
	var change_info: Dictionary = change_data.move_info.info.get(RULE_NAME)
	var base_movement: Movement = change_info.get(_NEW_MOVEMENT_LABEL)
	var piece: PieceObject = change_info.get(_AFFECTED_PIECE_LABEL)
	base_movement.set_facing_direction(piece.player_ownership.player.facing_direction)
	piece.movement_component.base_movement = base_movement
	piece.movement_component.reset_movement()


static func _reverse_change(board_data: BoardObject, change_data:BoardChange):
	if not change_data.move_info.info.flags.get(_FLAG_IS_MOVEMENT_CHANGING_LABEL):
		return
	var change_info: Dictionary = change_data.move_info.info.get(RULE_NAME)
	var altered_movement: Movement = change_info.get(_NEW_MOVEMENT_LABEL)
	var piece: PieceObject = change_info.get(_AFFECTED_PIECE_LABEL)
	altered_movement.set_facing_direction(piece.player_ownership.player.facing_direction)
	piece.movement_component.base_movement = altered_movement
	piece.movement_component.reset_movement()


func _ready():
	var make_change_handler: Callable = Callable(AlternateFirstMovement,"_make_change")
	BoardChange.make_change_handlers.add_handler(RULE_NAME, make_change_handler)

	var reverse_change_handler: Callable = Callable(AlternateFirstMovement,"_reverse_change")
	BoardChange.reverse_change_handlers.add_handler(RULE_NAME,reverse_change_handler)

	BoardChange.MoveStruct.add_key(RULE_NAME,{})
	BoardChange.MoveStruct.add_flag(_FLAG_IS_MOVEMENT_CHANGING_LABEL)

	_overwritten_movement = movement_component.base_movement
	movement_component.base_movement = alternate_movement


func evaluate_rule(board:BoardObject, current_changes:BoardChange):
	var move_info: BoardChange.MoveStruct = current_changes.move_info
	var piece: PieceObject = owner
	var is_rule_applicable: bool = (
			piece == current_changes.change_data.move_info.info.moving_piece
			and not piece.is_in_group(Constants.Groups.HAS_MOVED)
		)

	if is_rule_applicable:
		var rule_info: Dictionary = RULE_INFO_STRUCT.duplicate()
		rule_info.set(_AFFECTED_PIECE_LABEL, piece)
		rule_info.set(_CURRENT_MOVEMENT_LABEL, piece.movement_component.base_movement)
		rule_info.set(_NEW_MOVEMENT_LABEL, _overwritten_movement)

		move_info.add_info(RULE_NAME, rule_info)
		move_info.set_flag(_FLAG_IS_MOVEMENT_CHANGING_LABEL, true)
