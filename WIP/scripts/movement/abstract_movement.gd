class_name AbstractMovement extends Resource


func _init() -> void:
	resource_local_to_scene = true


func set_max_distance(max_distance:int) -> void:
	pass


func set_direction_parity(direction_parity: int) -> void:
	pass


# Godot's duplicate function does not duplicate this resource completely
# while this funtion does
func get_duplicate() -> AbstractMovement:
	return null


func apply_movement(current_tile:TileObject):
	pass
