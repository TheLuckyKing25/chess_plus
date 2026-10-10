@tool
class_name JumpingMovement extends Movement


@export_range(-16,16,1,"suffix:Ranks") var rank_origin_offset:int
@export_range(-16,16,1,"suffix:Files") var file_origin_offset:int


var offset_vector: Vector2i:
	get: return Vector2i(rank_origin_offset,file_origin_offset)

@export var is_move := false
@export var is_threaten := false


@export var next_movement: Movement


var is_branching: bool:
	get: return not next_movement is BranchingMovement


func set_facing_direction(facing_direction:int):
	if facing_direction == 4:
		rank_origin_offset *= -1
		file_origin_offset *= -1
	if is_instance_valid(next_movement):
		next_movement.set_facing_direction(facing_direction)


func generate_movement_map(
		previous_tile:TileObject,
		_board: BoardObject,
		moving_object:InteractableGameObject
	) -> Dictionary[TileObject,StringName]:

	var tiles: Dictionary[TileObject,StringName] = {}

	# find next_tile
	var next_position:Vector2i = previous_tile.position_vector + offset_vector

	if _board.tile_grid.get_tile_at_position(next_position) == null:
		return {}

	var next_tile:TileObject = _board.tile_grid.get_tile_at_position(next_position)
	var next_tile_state: StringName = ObjectStateComponent.STATE_NONE
	if not is_instance_valid(next_tile):
		return {}

	# enter next_tile
		# apply modifiers of next_tile

	if is_move and not next_tile.is_in_group(Constants.Groups.IS_OCCUPIED):
		next_tile_state = ObjectStateComponent.STATE_MOVEMENT
		tiles.set(next_tile,next_tile_state)


	if is_threaten and super._is_in_any_group(next_tile, moving_object.threatenable_groups) and not next_tile in _board.valid_selections:
		next_tile_state = ObjectStateComponent.STATE_THREATENED
		tiles.set(next_tile,next_tile_state)


	if next_tile_state == ObjectStateComponent.STATE_NONE:
		return {}

	# exit next_tile

	if next_movement != null:
		tiles.merge(next_movement.generate_movement_map(next_tile, _board, moving_object))

	return tiles
