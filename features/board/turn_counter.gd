class_name TurnCounter
extends Rule


const RULE_NAME: String = "turn_counter"


static var current_count: int = 1


static var move_taken_this_turn: int = 0


static func _handle_change(board_data: BoardObject, value: Variant):
	if move_taken_this_turn == board_data.player_component.num_of_players:
		current_count += 1


func _ready():
	var change_handler_function: Callable = Callable(TurnCounter,"_handle_change")
	BoardChange.add_change_handler(RULE_NAME,change_handler_function)


func evaluate_rule(board: BoardObject) -> void:
	move_taken_this_turn += 1
	board.current_changes.add_change(RULE_NAME, current_count)
