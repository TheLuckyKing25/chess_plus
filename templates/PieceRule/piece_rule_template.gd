# meta-name: Empty Template
# meta-default: true
class_name _CLASS_
extends PieceRule


const RULE_NAME: String = "_CLASS_SNAKE_CASE_"


static func _handle_change(board_data: BoardObject, value: Variant):
	pass


static func _handle_merge(accum_value: Variant, merging_value:Variant):
	pass


func _init():
	var change_handler_function: Callable = Callable(_CLASS_,"_handle_change")
	BoardChange.add_change_handler(RULE_NAME,change_handler_function)


func evaluate_rule(current_change: BoardChange, piece: PieceObject):
	pass
