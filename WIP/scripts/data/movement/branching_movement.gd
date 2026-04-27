@tool
class_name BranchingMovement extends AbstractMovement

@export var branches: Array[AbstractMovement]


func set_direction_parity(direction_parity: int) -> void:
	if branches.is_empty():
		return
	for branch in branches:
		branch.set_direction_parity(direction_parity)


func get_duplicate() -> AbstractMovement:
	var duplicated_movement: BranchingMovement = duplicate()
	var duplicated_movement_branches:Array[AbstractMovement] = []

	for branch in branches:
		duplicated_movement_branches.append(branch.get_duplicate())
	duplicated_movement.branches = duplicated_movement_branches
	return duplicated_movement
