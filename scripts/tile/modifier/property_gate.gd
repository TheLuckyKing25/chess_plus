class_name PropertyGate
extends TileModifier

@export var is_active: bool = true

func _init():
	flag = ModifierType.PROPERTY_GATE

func blocks_passage(context, piece, tile, movement) -> bool:
	return is_active
