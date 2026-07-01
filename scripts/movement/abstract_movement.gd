@tool
@abstract
class_name AbstractMovement extends Resource


func _init() -> void:
	resource_local_to_scene = true


func set_max_distance(max_distance:int) -> void:
	pass


@abstract func set_direction_parity(direction_parity: int) -> void
@abstract func apply_movement(current_tile:TileDataChess,_board: BoardData) -> Dictionary[TileDataChess,ObjectStateComponent.Type]
