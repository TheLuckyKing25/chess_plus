# meta-name: Empty Template
# meta-default: true
class_name _CLASS_
extends PieceRule


const RULE_NAME: String = "_CLASS_SNAKE_CASE_"


static func _make_change(board_data: BoardObject, change_data:BoardChange):
	pass


static func _handle_merge(accum_value: Variant, merging_value:Variant):
	pass


func _init():
	var change_handler: Callable = Callable(_CLASS_,"_make_change")
	BoardChange.make_change_handlers.add_handler(RULE_NAME,change_handler)


func evaluate_rule(current_change: BoardChange, piece: PieceObject):
	pass
