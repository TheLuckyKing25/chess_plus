class_name RulesComponent
extends Node


var active_rules: Dictionary[StringName,Rule] = {
	# RuleName: RuleNode,
}


func _ready() -> void:
	var rules: Array = get_children()
	for rule:Rule in rules:
		active_rules.set(rule.name,rule)
	DebugPrinter.print_pretty(active_rules)


func evaluate_rules():
	for rule:Rule in active_rules.values():
		rule.evaluate_rule(get_parent())
