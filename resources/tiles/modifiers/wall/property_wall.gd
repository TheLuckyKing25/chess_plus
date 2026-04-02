class_name PropertyWall
extends TileModifier

func _init():
	name = "Wall"
	flag = ModifierType.PROPERTY_WALL
	color = Color(0.75,0.5,0.5)
	icon = load("res://resources/tiles/modifiers/wall/icon_wall.svg")
	is_blocking = true
