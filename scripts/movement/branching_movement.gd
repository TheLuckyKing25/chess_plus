@tool
class_name BranchingMovement extends AbstractMovement


@export var branches: Array[AbstractMovement]


func set_direction_parity(direction_parity: int) -> void:
	if branches.is_empty():
		return
	for branch in branches:
		branch.set_direction_parity(direction_parity)


func apply_movement(current_tile:TileDataChess, _board: BoardData) -> Dictionary[TileDataChess,ObjectStateComponent.Type]:
	var tiles: Dictionary[TileDataChess,ObjectStateComponent.Type] = {}

	# apply modifiers

	if branches.is_empty():
		return {}
	for branch in branches:
		tiles.merge(branch.apply_movement(current_tile, _board))
	return tiles
