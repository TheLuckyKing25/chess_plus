@tool
class_name BranchingMovement extends AbstractMovement


@export var branches: Array[AbstractMovement]


func set_facing_direction(facing_direction: int) -> void:
	if branches.is_empty():
		return
	for branch in branches:
		branch.set_facing_direction(facing_direction)


func apply_movement(current_tile:TileObject, _board: BoardObject) -> Dictionary[TileObject,StringName]:
	var tiles: Dictionary[TileObject,StringName] = {}

	# apply modifiers

	if branches.is_empty():
		return {}
	for branch in branches:
		tiles.merge(branch.apply_movement(current_tile, _board))
	return tiles
