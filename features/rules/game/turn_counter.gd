class_name TurnCounter
extends Rule


const RULE_NAME: String = &"turn_counter"


static var current_count: int = 1


static var move_taken_this_turn: int = 0


static func _make_change(board_data: BoardObject, change_data:BoardChange):
	if move_taken_this_turn == board_data.player_component.num_of_players:
		current_count += 1


func _ready():
	var change_handler: Callable = Callable(TurnCounter,"_make_change")
	BoardChange.BoardChangeStruct.add_key(RULE_NAME, 0)
	BoardChange.make_change_handlers.add_handler(RULE_NAME,change_handler)


func evaluate_rule(board: BoardObject, current_changes:BoardChange) -> void:
	move_taken_this_turn += 1
	current_changes.board_info.add_info(RULE_NAME, current_count)
