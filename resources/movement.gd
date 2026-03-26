class_name Movement
extends Resource

enum Direction{
	NONE = -1, ## Only to be used when  [param Distance]  equals  [code]0[/code].
	NORTH = 0,
	NORTHEAST = 1,
	EAST = 2,
	SOUTHEAST = 3,
	SOUTH = 4,
	SOUTHWEST = 5,
	WEST = 6,
	NORTHWEST = 7,
	}


enum Purpose{
	UNSET = 0,
	STANDARD_MOVEMENT = 1,
	GENERATE_ALL_MOVES = 2,
	}


static var neighboring_tiles: Dictionary[Direction, Vector2i] = {
	Direction.NORTH: Vector2i(1,0),
	Direction.NORTHEAST: Vector2i(1,1),
	Direction.EAST: Vector2i(0,1),
	Direction.SOUTHEAST: Vector2i(-1,1),
	Direction.SOUTH: Vector2i(-1,0),
	Direction.SOUTHWEST: Vector2i(-1,-1),
	Direction.WEST: Vector2i(0,-1),
	Direction.NORTHWEST: Vector2i(1,-1)
}

## The distance that this move will extend out to.
## Setting the value to  [code]-1[/code]  will make the value
## equal to the largest side length of the board.
@export_range(-1,8,1,"or_greater") var distance: int = 0

@export var direction: Direction:
	set(cardinal):
		if cardinal <= Direction.NONE:
			direction = Direction.NONE
		else:
			direction = (cardinal % 8) as Direction
	get():
		return direction as Direction


# Actions performed by the piece on a tile
@export var is_jump := false # Continue through occupied tile
@export var is_move := false # Tile unoccupied
@export var is_threaten := false # Tile occupied by opponent
@export var is_branching := false # Branch from tile, flag set on last moverule of a branch
@export var is_castling := false # Used for castling movements, flag set on last moverule of a branch


@export var branches: Array[Movement]

# Purpose of the movement
# The same throughout entire moveset
var purpose: Purpose = Purpose.UNSET


func _init() -> void:
	resource_local_to_scene = true

# Godot's duplicate function does not duplicate this resource completely
# while this funtion does
func get_duplicate() -> Movement:
	var duplicated_movement:Movement = duplicate(true)
	if duplicated_movement.is_branching:
		var duplicated_movement_branches:Array[Movement] = []
		for branch in duplicated_movement.branches:
			duplicated_movement_branches.append(branch.get_duplicate())
		duplicated_movement.branches = duplicated_movement_branches

	return duplicated_movement


func set_purpose_type(new_purpose: Purpose) -> void:
	purpose = new_purpose
	if is_branching:
		for branch in branches:
			branch.set_purpose_type(new_purpose)

func set_direction_parity(direction_parity: int) -> void:
	if direction != Direction.NONE:
		direction = ((direction + direction_parity) % 8) as Direction
	if is_branching:
		for branch in branches:
			branch.set_direction_parity(direction_parity)

func set_max_distance(max_distance:int) -> void:
	if distance == -1:
		distance = max_distance
	if is_branching:
		for branch in branches:
			branch.set_max_distance(max_distance)


func rotate_movement() -> void:
	pass

func change_movement_distance() -> void:
	pass
