class_name Piece
extends Node

## Node containing the Mesh, Outline, and CollisionBox
var object_piece: Node3D
## Tile that the piece is on/parented
var tile_parent: Tile

## Directions the piece can move in.
var movement_direction: Array[Vector2i] = []
## The distance covered by the movement directions.
var movement_distance: int = 1

var selected: bool = false
var captured: bool = false
var threatened: bool = false

## Color of the mesh object
var base_color: Color = Color(1,1,1)
## Color of the outline object
var outline_color: Color = Color(0,0,0)

func _init(tile: Tile, piece_object: Node3D) -> void:
	set_parent_tile(tile)
	set_object(piece_object)

func select() -> void: 
	selected = true
	object_piece.find_child("Outline").visible = true
func unselect() -> void: 
	selected = false
	object_piece.find_child("Outline").visible = false
	
func threaten() -> void:
	threatened = true
	object_piece.find_child("Outline").visible = true
func unthreaten() -> void:
	threatened = false
	object_piece.find_child("Outline").visible = false
	
func capture() -> void:
	captured = true
	object_piece.visible = false
	object_piece.translate(Vector3(0,-5,0)) 

func get_object() -> Node3D: return object_piece
func get_movement_directions() -> Array[Vector2i]: return movement_direction
func get_movement_distance() -> int: return movement_distance
func get_parent_tile() -> Tile: return tile_parent
func get_color_base() -> Color: return base_color
func get_color_outline() -> Color: return outline_color

func set_object(new_piece_object: Node3D) -> void: object_piece = new_piece_object
func set_movement_directions(directions: Array[Vector2i]) -> void: movement_direction = directions
func set_movement_distance(distance: int) -> void: movement_distance = distance
func set_parent_tile(new_tile: Tile) -> void: tile_parent = new_tile
func set_color_base(color: Color) -> void: 
	base_color = color
	object_piece.find_child("Mesh").get_surface_override_material(0).albedo_color = base_color
func set_color_outline(color: Color) -> void: 
	outline_color = color
	object_piece.find_child("Outline").material_override.albedo_color = outline_color
	object_piece.find_child("Outline").visible = false
