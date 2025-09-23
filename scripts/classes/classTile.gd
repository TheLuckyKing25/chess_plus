class_name Tile
extends Node

## Color of the mesh object
var color: Color: 
	set(new_color):
		color = new_color
		mesh.get_surface_override_material(0).albedo_color = new_color
		
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

func _init(tile_color: Color, tile_position: Vector2i, 
		tile_object: Node3D
) -> void:
	relative_position = tile_position
	object_tile = tile_object
	color = tile_color
	for child in object_tile.find_children("*_P*","",false): 
		match child.name.get_slice("_", 0):
			"Pawn": occupant = Pawn.new(self, child)
			"Rook": occupant = Rook.new(self, child)
			"Bishop": occupant = Bishop.new(self, child)
			"Knight": occupant = Knight.new(self, child)
			"Queen": occupant = Queen.new(self, child)
			"King": occupant = King.new(self, child)
		child.find_child("Outline").visible = false
			
func is_occupied() -> bool: 
	return occupant != null
