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

## Color of the mesh object
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
		parity = 1 if player.color != Global.game_color[Global.PLAYER][0] else -1

var parity: int # determines which direction is the front

## Directions the piece can move in.
var movement_direction: Array[Vector2i] = []
## The distance covered by the movement directions.
var movement_distance: int = 1

var all_movements = []

var valid_movements: Array[Tile] = []
var valid_threatening_movements: Array[Tile] = []

var full_valid_movements: Array[Tile]:
	get: 
		return valid_movements + valid_threatening_movements

var has_moved: bool = false

enum {
		P_STATE_NONE,
		P_STATE_SELECTED,
		P_STATE_THREATENED,
		P_STATE_CAPTURED,
		P_STATE_CHECKED,
		P_STATE_CHECKING,
	}

var state_order: Array = []

func previous_state():
	if len(state_order) > 1:
		set_state(state_order.pop_back())
	else:
		set_state(P_STATE_NONE)

var state
		
		
func _init(player: Player, tile: Tile, piece_object: Node3D) -> void:
	object_piece = piece_object
	player_parent = player
	tile_parent = tile

func calculate_all_movements():
	pass

func validate_movements():
	pass

func is_same_piece(piece: Piece):
	return self == piece

func is_opponent_piece(player:Player):
	return self in Global.opponent(player).pieces

func is_opponent_king(player:Player):
	return self is King and self.is_opponent_piece(player)

func set_state(new_state):
	var previous_state = state
	if previous_state != P_STATE_NONE and new_state != P_STATE_NONE:
		state_order.append(previous_state)
	match new_state:
		P_STATE_NONE: 
			outline.visible = false
			tile_parent.set_state(tile_parent.T_STATE_NONE)
			state_order.clear()
		P_STATE_SELECTED:
			outline.visible = true
			outline_color = Global.game_color[Global.SELECT_PIECE]
			tile_parent.set_state(tile_parent.T_STATE_SELECTED)

			for tile in valid_movements:
				if self is King and tile in Global.threaten_king_movement:
					tile.set_state(tile.T_STATE_MOVE_CHECKING)
				else:
					tile.set_state(tile.T_STATE_VALID)
			for tile in valid_threatening_movements:
				tile.set_state(tile.T_STATE_THREATENED)
				tile.occupant.set_state(tile.occupant.P_STATE_THREATENED)
		P_STATE_THREATENED:
			outline.visible = true
			outline_color = Global.game_color[Global.THREATENED_PIECE]
			tile_parent.set_state(tile_parent.T_STATE_THREATENED)
		P_STATE_CAPTURED:
			object_piece.visible = false
			collision.disabled = true
			object_piece.translate(Vector3(0,-5,0)) 
		P_STATE_CHECKED: 
			outline.visible = true
			outline_color = Global.game_color[Global.CHECKED_PIECE]
			tile_parent.set_state(tile_parent.T_STATE_CHECKED)
		P_STATE_CHECKING: 
			outline.visible = true
			outline_color = Global.game_color[Global.CHECKING_PIECE]
			tile_parent.set_state(tile_parent.T_STATE_CHECKING)
	state = new_state
