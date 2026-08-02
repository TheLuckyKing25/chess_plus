@tool
@abstract
class_name Movement
extends Resource


func _init() -> void:
	resource_local_to_scene = true


func set_max_distance(max_distance:int) -> void:
	pass


@abstract func set_facing_direction(facing_direction: int) -> void
@abstract func apply_movement(current_tile:TileObject,_board: BoardObject) -> Dictionary[TileObject,StringName]
