class_name _CLASS_
extends Rule


const RULE_NAME: String = "_CLASS_SNAKE_CASE_"


static func _handle_change(board_data: BoardObject, value: Variant):
	pass


func _ready():
	var change_handler_function: Callable = Callable(_CLASS_,"_handle_change")
	BoardChange.add_change_handler(RULE_NAME,change_handler_function)


func evaluate_rule(board: BoardObject) -> void:
	# determine if rule is applicable to the current turn
	var is_rule_applicable: bool = false
	if is_rule_applicable:
		# determine what info is stored in the current BoardChange
		var change_info
		board.current_changes.add_change(RULE_NAME, change_info)
