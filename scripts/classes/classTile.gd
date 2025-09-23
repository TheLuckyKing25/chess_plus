class_name Tile
extends Node

## Color of the mesh object
var color: Color
## Position of the tile on the board
var relative_position: Vector2i
## Node containing the Mesh and CollisionBox
var object_tile: Node3D
## Piece on the tile, if any
var occupant: Piece = null

func _init(tile_color: Color, tile_position: Vector2i, tile_object: Node3D) -> void:
	relative_position = tile_position
	object_tile = tile_object
	set_color(tile_color)
	for child in object_tile.find_children("*_P*","",false): 
		match child.name.get_slice("_", 0):
			"Pawn": occupant = Pawn.new(self, child)
			"Rook": occupant = Rook.new(self, child)
			"Bishop": occupant = Bishop.new(self, child)
			"Knight": occupant = Knight.new(self, child)
			"Queen": occupant = Queen.new(self, child)
			"King": occupant = King.new(self, child)
		child.find_child("Outline").visible = false
			
func get_object() -> Node3D: return object_tile
func get_position() -> Vector2i: return relative_position
func get_occupant() -> Piece: return occupant
func get_color() -> Color: return color

func is_occupied() -> bool: return occupant != null

func set_object(new_object: Node3D) -> void: object_tile = new_object
func set_position(position: Vector2i) -> void: relative_position = position
func set_occupant(new_occupant: Piece) -> void: occupant = new_occupant
func set_color(new_color: Color) -> void: 
	color = new_color
	object_tile.find_child("Mesh").get_surface_override_material(0).albedo_color = new_color
