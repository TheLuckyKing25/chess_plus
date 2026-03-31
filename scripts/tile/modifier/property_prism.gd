class_name PropertyPrism
extends TileModifier

func _init():
	flag = ModifierType.PROPERTY_PRISM
	can_modify_movement = true

func modify_movement(movement: Movement) -> void:
	if movement == null:
		return
	if movement.distance <= 1:
		return
	if movement.is_branching:
		return

	var left_branch := movement.get_duplicate()
	left_branch.distance -= 1
	left_branch.rotate_movement(7)

	var right_branch := movement.get_duplicate()
	right_branch.distance -= 1
	right_branch.rotate_movement(1)

	movement.distance = 1
	movement.is_branching = true
	movement.branches = [left_branch, right_branch]
