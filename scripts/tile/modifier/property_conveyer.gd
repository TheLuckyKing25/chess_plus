class_name PropertyConveyer
extends TileModifier

enum ConveyerDirection{
	NORTH = Movement.Direction.NORTH,
	EAST = Movement.Direction.EAST,
	SOUTH = Movement.Direction.SOUTH,
	WEST = Movement.Direction.WEST,
}

@export var direction: ConveyerDirection

const flag = GameNode3D.TileModifierFlag.PROPERTY_CONVEYER
