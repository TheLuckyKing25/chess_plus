class_name PropertyWall
extends TileModifier

func _init():
	name = "Wall"
	flag = ModifierType.PROPERTY_WALL
	color = Color(0.75,0.5,0.5)
	icon = load(Constants.ICON_PATHS.modifier.wall)
	is_blocking = true
