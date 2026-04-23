class_name SlidingMovement extends AbstractMovement

## The distance that this move will extend out to.
## Setting the value to  [code]-1[/code]  will make the value
## equal to the largest side length of the board.
@export_range(-1,8,1,"or_greater") var distance: int = 0

@export var direction: Direction:
	set(cardinal):
		direction = (cardinal % 8) as Direction
	get():
		return direction as Direction

# Actions performed by the piece on a tile
@export var is_move := false # Tile unoccupied
@export var is_threaten := false # Tile occupied by opponent
@export var is_castling := false # Used for castling movements, flag set on last moverule of a branch

@export var next_movement: AbstractMovement

var is_branching: bool:
	get():
		if next_movement is BranchingMovement:
			return false
		else:
			return true

func set_direction_parity(direction_parity: int) -> void:
	direction = ((direction + direction_parity) % 8) as Direction
	if next_movement:
		next_movement.set_direction_parity(direction_parity)

func set_max_distance(max_distance:int) -> void:
	if distance == -1:
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
