class_name PropertyWall
extends TileModifier

func _init():
	name = "Wall"
	flag = ModifierType.PROPERTY_WALL
	color = Color(0.75,0.5,0.5)
	icon = load("uid://ctd4y6jjqr4ta")
	is_blocking = true
