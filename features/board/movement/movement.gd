@tool
@abstract
class_name Movement
extends Resource


func _init() -> void:
	resource_local_to_scene = true


func set_max_distance(max_distance:int) -> void:
	pass


@abstract func set_facing_direction(facing_direction: int) -> void
@abstract func generate_movement_map(current_tile:TileObject, _board: BoardObject, moving_object:InteractableGameObject) -> Dictionary[TileObject,StringName]


func _is_in_any_group(tile: TileObject, group_stringnames:Array) -> bool:
	var tile_groups: Array[StringName] = tile.get_groups()
	var filter_func:Callable = (
			func(tile_group: StringName) -> bool: return tile_group in group_stringnames
		)
	return tile_groups.any(filter_func)
