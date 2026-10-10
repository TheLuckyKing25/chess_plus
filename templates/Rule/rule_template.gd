class_name _CLASS_
extends Rule


const RULE_NAME: String = "_CLASS_SNAKE_CASE_"


const RULE_INFO_STRUCT:Dictionary = {

}

static func _make_change(board_data: BoardObject, change_data:BoardChange):
	pass


static func _reverse_change(board_data: BoardObject, value: Variant):
	pass


func _ready():
	var change_handler: Callable = Callable(_CLASS_,"_make_change")
	BoardChange.make_change_handlers.add_handler(RULE_NAME,change_handler)


func evaluate_rule(board: BoardObject, current_changes: BoardChange) -> void:
	# determine if rule is applicable to the current turn
	var is_rule_applicable: bool = false
	if is_rule_applicable:
		# determine what info is stored in the current BoardChange
		var change_info
		current_changes.add_change(RULE_NAME, change_info)
