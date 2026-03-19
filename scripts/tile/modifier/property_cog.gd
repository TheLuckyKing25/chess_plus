class_name PropertyCog
extends TileModifier

# The cog property changes the direction a piece is able to move in. Currently, this is temporary
# and the piece gains its normal movement back after moving off the piece.

@export var rotation: int = 90

const DIRECTIONS = [
	GameNode3D.Direction.NORTH,
	GameNode3D.Direction.NORTHEAST,
	GameNode3D.Direction.EAST,
	GameNode3D.Direction.SOUTHEAST,
	GameNode3D.Direction.SOUTH,
	GameNode3D.Direction.SOUTHWEST,
	GameNode3D.Direction.WEST,
	GameNode3D.Direction.NORTHWEST,
]

func _init():
	flag = GameNode3D.TileModifierFlag.PROPERTY_COG

func _rotate_direction(direction: int) -> int:
	var index = DIRECTIONS.find(direction)
	if index == -1:
		return direction

	var steps = int(rotation / 45)
	var new_index = (index + steps + 8) % DIRECTIONS.size()

	return DIRECTIONS[new_index]

func modify_moveset(board, piece, tile, moveset):
	if moveset == null:
		return moveset
	
	for branch in moveset.branches:
		branch.direction = _rotate_direction(branch.direction)
	
	return moveset
