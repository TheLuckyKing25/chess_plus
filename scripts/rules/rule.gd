@abstract
class_name Rule
extends Node

@abstract func _ready()
func evaluate_rule_application(current_change: BoardChange, board:BoardObject):
	pass
@abstract func evaluate_rule(board:BoardObject)
