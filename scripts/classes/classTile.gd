class_name Tile
extends Node

var color: Color
var relative_position: Vector2
var object: Node3D
var occupant: Piece = null

func _init(tile_color: Color, tile_position: Vector2, tile_object: Node3D):
	relative_position = tile_position
	object = tile_object
	set_color(tile_color)
	for child in object.find_children("*_P*","",false): 
		match child.name.get_slice("_", 0):
			"Pawn": occupant = Pawn.new(self, child)
			"Rook": occupant = Rook.new(self, child)
			"Bishop": occupant = Bishop.new(self, child)
			"Knight": occupant = Knight.new(self, child)
			"Queen": occupant = Queen.new(self, child)
			"King": occupant = King.new(self, child)
		child.find_child("Outline").visible = false
			
func get_object() -> Node3D: return object
func get_position() -> Vector2: return relative_position
func get_occupant() -> Piece: return occupant
func get_color() -> Color: return color

func is_occupied() -> bool: return occupant != null

func set_object(new_object: Node3D): object = new_object
func set_position(position: Vector2): relative_position = position
func set_occupant(new_occupant: Piece): occupant = new_occupant
func set_color(tile_color: Color): 
	color = tile_color
	object.find_child("Mesh").get_surface_override_material(0).albedo_color = tile_color
