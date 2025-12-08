class_name PropertyCog
extends TileModifier

enum Rotation{
	CLOCKWISE = 0,
	COUNTERCLOCKWISE = 1,
}

## The
@export var rotation: Rotation

const flag = GameNode3D.TileModifierFlag.PROPERTY_COG
