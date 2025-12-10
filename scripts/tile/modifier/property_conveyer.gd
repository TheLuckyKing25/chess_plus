class_name PropertyConveyer
extends TileModifier

enum ConveyerDirection{
	NORTH = GameNode3D.Direction.NORTH,
	EAST = GameNode3D.Direction.EAST,
	SOUTH = GameNode3D.Direction.SOUTH,
	WEST = GameNode3D.Direction.WEST,
}

@export var direction: ConveyerDirection

const flag = GameNode3D.TileModifierFlag.PROPERTY_CONVEYER
