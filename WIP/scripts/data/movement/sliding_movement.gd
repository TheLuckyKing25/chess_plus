@tool
class_name SlidingMovement extends AbstractMovement

@export var use_max_distance: bool = false:
	set(value):
		use_max_distance = value
		notify_property_list_changed()


## The distance that this move will extend out to.
@export_range(0,8,1,"or_greater") var distance: int = -1:
	get:
		if use_max_distance and distance == -1:
			return Board.current_board.max_length - 1
		else:
			return distance


@export var direction: Direction:
	set(cardinal):
		direction = (cardinal % 8) as Direction
		resource_name = Direction.keys()[direction].capitalize()
	get():
		return direction as Direction


@export var is_move := false
@export var is_threaten := false
@export var is_castling := false


@export var next_movement: AbstractMovement


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


func set_direction_parity(direction_parity: int) -> void:
	direction = (direction + direction_parity)
	if next_movement:
		next_movement.set_direction_parity(direction_parity)


func set_max_distance(max_distance:int) -> void:
	if use_max_distance:
		distance = max_distance
	if next_movement:
		next_movement.set_max_distance(max_distance)


## direction_units is a positive integer between 1 and 7, including 1 and 7.
func rotate_movement(direction_units: int) -> void:
	direction += direction_units
	if next_movement:
		next_movement.rotate_movement(direction_units)


func change_movement_direction() -> void:
	pass


func change_movement_distance() -> void:
	pass


func get_duplicate() -> AbstractMovement:
	var duplicated_movement: SlidingMovement = duplicate()
	if next_movement:
		duplicated_movement.next_movement = next_movement.get_duplicate()
	return duplicated_movement

func apply_movement(current_tile:TileObject):
	# on current_tile
		# apply modifiers of current_tile

	while distance > 0:
		# find next tile
		var next_tile: TileObject = current_tile.neighbors[direction]
		if next_tile == null:
			return

		distance -= 1
		apply_movement(next_tile)
