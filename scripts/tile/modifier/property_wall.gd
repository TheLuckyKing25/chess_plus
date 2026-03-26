class_name PropertyWall
extends TileModifier

func _init():
	flag = ModifierEnums.TileModifierFlag.PROPERTY_WALL

func blocks_passage(context, piece, tile, movement) -> bool:
	return not movement.is_jump
