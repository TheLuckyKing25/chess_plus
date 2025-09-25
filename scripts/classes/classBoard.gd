class_name Board
extends Node

## Node containing the tiles and pieces
var board: Node3D
var base: Node3D
var color: Color:
	set(new_color):
		color = new_color
		base.get_surface_override_material(0).albedo_color = new_color

func _init(new_board: Node3D, new_base: Node3D) -> void:
	board = new_board
	base = new_base
