@tool
class_name SlidingMovement extends Movement

## Use the longest side of the board as the move distance
@export var use_max_distance: bool = false:
	set(value):
		use_max_distance = value
		notify_property_list_changed()


# prevents neverending loop when getting distance
var _getting_distance: bool = false


## The distance that this move will extend out to.
@export_range(0,8,1,"or_greater") var distance: int = 0:
	get:
		if not _getting_distance:
			_getting_distance = true
			if use_max_distance and _getting_distance and distance == 0 and GameData.is_node_ready():
				distance = GameData.max_board_length - 1
		return distance


@export var direction: Constants.Direction:
	set(cardinal):
		direction = (cardinal % 8) as Constants.Direction
		resource_name = Constants.Direction.find_key(direction).capitalize()
	get():
		return direction as Constants.Direction


@export var is_move := false
@export var is_threaten := false


@export var next_movement: Movement


var is_branching: bool:
	get():
		if next_movement is BranchingMovement:
			return false
		else:
			return true

# in editor tool
func _validate_property(property: Dictionary) -> void:
	if property.name in ["distance"]:
		if use_max_distance:
			property.usage = PROPERTY_USAGE_NO_EDITOR


func set_facing_direction(facing_direction: int) -> void:
	direction = (direction + facing_direction) as Constants.Direction
	if next_movement:
		next_movement.set_facing_direction(facing_direction)


func set_max_distance(max_distance:int) -> void:
	if use_max_distance:
		distance = max_distance
	if next_movement:
		next_movement.set_max_distance(max_distance)


## direction_units is a positive integer between 1 and 7, including 1 and 7.
func rotate_movement(direction_units: int) -> void:
	direction += direction_units as Constants.Direction
	if next_movement:
		next_movement.rotate_movement(direction_units)


func change_movement_direction() -> void:
	pass


func change_movement_distance() -> void:
	pass


func generate_movement_map(current_tile:TileObject, _board: BoardObject, moving_object:InteractableGameObject) -> Dictionary[TileObject,StringName]:
	var tiles: Dictionary[TileObject,StringName] = {}
	# on current_tile
		# apply modifiers of current_tile

	while distance > 0:
		# find next tile
		var next_tile: TileObject = current_tile.neighbors[direction]
		var next_tile_state: StringName = ObjectStateComponent.STATE_NONE
		if next_tile == null:
			return {}

		if is_move and not next_tile.is_in_group(Constants.GROUPS.IS_OCCUPIED):
			next_tile_state = ObjectStateComponent.STATE_MOVEMENT
			tiles.set(next_tile,next_tile_state)

		if is_threaten and _is_in_any_group(next_tile, moving_object.threatenable_groups) and not next_tile in _board.valid_selections:
			next_tile_state = ObjectStateComponent.STATE_THREATENED
			tiles.set(next_tile,next_tile_state)
			return tiles

		if next_tile_state == ObjectStateComponent.STATE_NONE:
			return tiles

		distance -= 1
		tiles.merge(generate_movement_map(next_tile, _board, moving_object))
	return tiles


func _is_in_any_group(tile: TileObject, group_stringnames:Array) -> bool:
	var tile_groups: Array[StringName] = tile.get_groups()
	var filter_func:Callable = (
			func(tile_group: StringName) -> bool: return tile_group in group_stringnames
		)
	return tile_groups.any(filter_func)
