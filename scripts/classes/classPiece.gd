class_name Piece
extends Node

var tile: Tile
var object: Node3D

var movement_direction: Array[Vector2] = []
var movement_distance: int = 1

var selected: bool = false
var captured: bool = false
var threatened: bool = false

var base_color: Color = Color(1,1,1)
var outline_color: Color = Color(0,0,0)

func _init(tile: Tile, piece_object: Node3D):
	set_tile(tile)
	set_object(piece_object)
	
func select(): 
	selected = true
	object.find_child("Outline").visible = true
func unselect(): 
	selected = false
	object.find_child("Outline").visible = false
	
func threaten():
	threatened = true
	object.find_child("Outline").visible = true

func unthreaten():
	threatened = false
	object.find_child("Outline").visible = false

func get_object() -> Node3D: return object
func get_movement_directions() -> Array[Vector2]: return movement_direction
func get_movement_distance() -> int: return movement_distance
func get_tile() -> Tile: return tile
func get_base_color() -> Color: return base_color
func get_outline_color() -> Color: return outline_color

func set_object(piece_object: Node3D): object = piece_object
func set_movement_directions(directions: Array[Vector2]): movement_direction = directions
func set_movement_distance(distance: int): movement_distance = distance
func set_tile(new_tile: Tile): tile = new_tile
func set_base_color(color: Color): 
	base_color = color
	object.find_child("Mesh").get_surface_override_material(0).albedo_color = base_color
func set_outline_color(color: Color): 
	outline_color = color
	object.find_child("Outline").material_override.albedo_color = outline_color
	object.find_child("Outline").visible = false
