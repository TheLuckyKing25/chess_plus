class_name PropertyPrism
extends TileModifier

func _init():
	name = "Prism"
	flag = ModifierType.PROPERTY_PRISM
	color = Color(0.7,0.8,0.9)
	can_modify_movement = true

#func modify_movement(movement: OLD_MOVEMENT_CLASS) -> void:
	#if movement == null:
		#return
	#if movement.distance <= 1:
		#return
	#if movement.is_branching:
		#return
#
	#var left_branch := movement.duplicate_deep()
	#left_branch.distance -= 1
	#left_branch.rotate_movement(7)
#
	#var right_branch := movement.duplicate_deep()
	#right_branch.distance -= 1
	#right_branch.rotate_movement(1)
#
	#movement.distance = 1
	#movement.is_branching = true
	#movement.branches = [left_branch, right_branch]
