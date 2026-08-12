@tool
class_name BranchingMovement extends Movement


@export var branches: Array[Movement]


func set_facing_direction(facing_direction: int) -> void:
	if branches.is_empty():
		return
	for branch in branches:
		branch.set_facing_direction(facing_direction)


func generate_movement_map(current_tile:TileObject, _board: BoardObject, moving_object:InteractableGameObject) -> Dictionary[TileObject,StringName]:
	var tiles: Dictionary[TileObject,StringName] = {}

	# apply modifiers

	if branches.is_empty():
		return {}
	for branch in branches:
		tiles.merge(branch.generate_movement_map(current_tile, _board, moving_object))
	return tiles
