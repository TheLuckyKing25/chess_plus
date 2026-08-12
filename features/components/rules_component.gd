class_name RulesComponent
extends Node
@export var active_rules: Dictionary[StringName,Rule] = {
	# RuleName: Rule,
}


func _ready() -> void:
	await owner.ready
	var rules: Array = get_children()
	if rules.is_empty(): return
	for rule:Rule in rules:
		active_rules.set(rule.name,rule)
	_verify_ruled_state()


func evaluate_rules(board: BoardObject):
	for rule:Rule in active_rules.values():
		rule.evaluate_rule(board)
	_verify_ruled_state()


func _verify_ruled_state():
	if get_child_count() > 0:
		owner.add_to_group(Constants.GROUPS.IS_RULED)
	else:
		owner.remove_from_group(Constants.GROUPS.IS_RULED)
