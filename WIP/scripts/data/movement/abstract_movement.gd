@tool
class_name AbstractMovement extends Resource

enum Direction{
	NORTH = 0,
	NORTHEAST = 1,
	EAST = 2,
	SOUTHEAST = 3,
	SOUTH = 4,
	SOUTHWEST = 5,
	WEST = 6,
	NORTHWEST = 7,
	}

const neighboring_tiles: Dictionary[Direction, Vector2i] = {
	Direction.NORTH: Vector2i(1,0),
	Direction.NORTHEAST: Vector2i(1,1),
	Direction.EAST: Vector2i(0,1),
	Direction.SOUTHEAST: Vector2i(-1,1),
	Direction.SOUTH: Vector2i(-1,0),
	Direction.SOUTHWEST: Vector2i(-1,-1),
	Direction.WEST: Vector2i(0,-1),
	Direction.NORTHWEST: Vector2i(1,-1)
}

func _init() -> void:
	resource_local_to_scene = true

# Godot's duplicate function does not duplicate this resource completely
# while this funtion does
func get_duplicate() -> AbstractMovement:
	var duplicated_movement:AbstractMovement = duplicate(true)
	return duplicated_movement
	if duplicated_movement is BranchingMovement:
		var duplicated_movement_branches:Array[AbstractMovement] = []

		for branch in duplicated_movement.branches:
			duplicated_movement_branches.append(branch.get_duplicate())
		duplicated_movement.branches = duplicated_movement_branches
	return duplicated_movement

func set_max_distance(max_distance:int) -> void:
	pass
