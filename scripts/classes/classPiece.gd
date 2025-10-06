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

## Color of the mesh object
var mesh_color: Color:
	set(color):
		mesh_color = color
		mesh.get_surface_override_material(0).albedo_color = color
		
var outline: MeshInstance3D

## Color of the outline object
var outline_color: Color:
	set(color):
		outline_color = color
		outline.material_override.albedo_color = color

var collision: CollisionShape3D

## Tile that the piece is on/parented
var tile_parent: Tile:
	set(tile):
		tile_parent = tile
				
var player_parent: Player:
	set(player):
		player_parent = player
		parity = 1 if player.color != Global.PLAYER_COLOR[0] else -1

var parity: int # determines which direction is the front

## Directions the piece can move in.
var movement_direction: Array[Vector2i] = []
## The distance covered by the movement directions.
var movement_distance: int = 1

var valid_movements: Array[Tile] = []
var valid_threatening_movements: Array[Tile] = []

var has_moved: bool = false

var is_selected: bool = false:
	set(state):
		outline.visible = state
		tile_parent.is_selected = state
		for tile in valid_movements:
			tile.is_valid_tile = state
		for tile in valid_threatening_movements:
			tile.is_threatened = state
		if state:
			outline_color = Global.COLOR_SELECT

var is_captured: bool = false:
	set(state):
		if state:
			collision.disabled = state
			object_piece.visible = !state
			object_piece.translate(Vector3(0,-5,0)) 
			
var is_threatened: bool = false:
	set(state):
		outline.visible = state
		tile_parent.is_threatened = state
		if state:
			outline_color = Global.COLOR_THREATENED

func _init(player: Player, tile: Tile, piece_object: Node3D) -> void:
	object_piece = piece_object
	player_parent = player
	tile_parent = tile
	
func calculate_movements():
	valid_movements = []
	valid_threatening_movements = []
	for direction in movement_direction:
		for distance in range(1,movement_distance+1):
			var new_position = tile_parent.relative_position + (direction * distance * parity)
			var new_tile = Global.find_tile_from_position(new_position)
			if not new_tile: 
				break
			if not new_tile.occupant:
				if self is Pawn and direction != movement_direction[0]:
					break
				valid_movements.append(new_tile)
			elif new_tile.occupant:
				if Global.is_same_team(self, new_tile.occupant) or (
						self is Pawn and direction == movement_direction[0]
					):
					break
				valid_threatening_movements.append(new_tile)
				break
