class_name AlternateFirstMovement
extends Rule


const RULE_NAME: String = "different_first_movement"


@export var movement_component: MovementComponent
@export var alternate_movement: Movement

# the base movement which was overwritten by this rule
var overwritten_movement: Movement


static func _handle_change(board_data: BoardObject, value: Variant):
	var pieces: Array = value.keys()
	for indv_piece: PieceObject in pieces:
		var post_move_movement: Movement = value.get(indv_piece)
		post_move_movement.set_facing_direction(indv_piece.player_ownership.player.facing_direction)
		indv_piece.movement_component.base_movement = post_move_movement
		indv_piece.movement_component.reset_movement()


func _ready():
	var change_handler_function: Callable = Callable(AlternateFirstMovement,"_handle_change")
	BoardChange.add_change_handler(RULE_NAME,change_handler_function)
	overwritten_movement = movement_component.base_movement
	movement_component.base_movement = alternate_movement


func evaluate_rule(board:BoardObject):
	var piece: PieceObject = owner
	if piece == board.current_changes.changed_data.move.occupant and not piece.is_in_group("hasMoved"):
		var change_info: Dictionary[PieceObject, Movement] = {piece: overwritten_movement.duplicate_deep()}
		board.current_changes.add_change(RULE_NAME, change_info)
