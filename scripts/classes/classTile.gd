
class_name Tile
extends Node

## Color of the mesh object
var color: Color: 
	set(new_color):
		color = new_color
		mesh.get_surface_override_material(0).albedo_color = new_color

var highlighted: bool = true:
	set(state): 
		if !state:
			mesh.get_surface_override_material(0).albedo_color = color
## Mixes the current color of the tiles with the specified color.
var highlight_color: Color: 
	set(new_color):
		highlighted = true
		highlight_color = new_color
		mesh.get_surface_override_material(0).albedo_color *= new_color


## Position of the tile on the board
var relative_position: Vector2i


## Node containing the Mesh and CollisionBox
var object_tile: Node3D:
	set(node):
		object_tile = node
		mesh = node.find_child("Mesh")
		collision = node.find_child("Collision")
var mesh: MeshInstance3D
var collision: CollisionShape3D


## Piece on the tile, if any
var occupant: Piece = null

var is_selected: bool = false:
	set(state):
		if not is_threatened:
			highlighted = state
			if state:
				highlight_color = Global.COLOR_SELECT

var is_valid_tile: bool = false:
	set(state):
		if not is_threatened:
			highlighted = state
			if state:
				highlight_color = Global.COLOR_TILE_VALID_MOVE

var is_threatened: bool = false:
	set(state):
		highlighted = state
		if state:
			highlight_color = Global.COLOR_THREATENED

func _init(tile_position: Vector2i, tile_object: Node3D) -> void:
	relative_position = tile_position
	object_tile = tile_object
	match (tile_position[0] + tile_position[1]) % 2:
		0: 
			color = Global.COLOR_TILE_LIGHT 
		1: 
			color = Global.COLOR_TILE_DARK
