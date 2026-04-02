class_name PropertyGate
extends TileModifier

@export var is_active: bool = false:
	set(value):
		is_active = value
		is_blocking = value

func _init():
	name = "Gate"
	flag = ModifierType.PROPERTY_GATE
	is_blocking = is_active
