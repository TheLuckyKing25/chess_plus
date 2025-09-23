class_name Piece
extends Node

## Node containing the Mesh, Outline, and CollisionBox
var object_piece: Node3D:
	set(node):
		object_piece = node
		mesh = node.find_child("Mesh")
		outline = node.find_child("Outline")
		collision = node.find_child("Collision")
var mesh: MeshInstance3D
var outline: MeshInstance3D
var collision: CollisionShape3D

## Tile that the piece is on/parented
var tile_parent: Tile

## Directions the piece can move in.
var movement_direction: Array[Vector2i] = []

## The distance covered by the movement directions.
var movement_distance: int = 1

var selected: bool = false:
	set(state):
		outline.visible = true if state else false

var captured: bool = false:
	set(state):
		if state:
			object_piece.visible = false
			object_piece.translate(Vector3(0,-5,0)) 

var threatened: bool = false:
	set(state):
		outline.visible = true if state else false

## Color of the mesh object
var base_color: Color:
	set(color):
		base_color = color
		mesh.get_surface_override_material(0).albedo_color = color

## Color of the outline object
var outline_color: Color:
	set(color):
		outline_color = color
		outline.material_override.albedo_color = color
		outline.visible = false


func _init(tile: Tile, piece_object: Node3D) -> void:
	tile_parent = tile
	object_piece = piece_object
