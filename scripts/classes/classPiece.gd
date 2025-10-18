class_name Piece
extends Node

## Node containing the Mesh, Outline, and CollisionBox
var object: Node3D:
	set(node):
		object = node
		mesh_object = node.find_child("Mesh")
		outline_object = node.find_child("Outline")
		collision_object = node.find_child("Collision")

var mesh_object: MeshInstance3D
var outline_object: MeshInstance3D
var collision_object: CollisionShape3D

## Color of the mesh object
var mesh_color: Color:
	set(color):
		mesh_color = color
		mesh_object.get_surface_override_material(0).albedo_color = color
		
## Color of the mesh object
var outline_color: Color:
	set(color):
		outline_color = color
		outline_object.material_override.albedo_color = color

## Tile that the piece is on/parented
var tile_parent: Tile
				
var player_parent: Player:
	set(player):
		player_parent = player
		parity = 1 if player.color != Global.game_color[Global.PLAYER][0] else -1

var parity: int ## determines which direction is the front


var movement_direction: Array[Vector2i] ## Directions the piece can move in.
var movement_distance: int ## The distance covered by the movement directions.

var complete_moveset = []

var valid_moveset: Array[Tile] = []
var threatening_moveset: Array[Tile] = []
var castling_moveset: Array[Tile] = []

var possible_moveset: Array[Tile]:
	get: 
		return valid_moveset + threatening_moveset + castling_moveset

var has_moved: bool = false

enum {
		P_STATE_NONE,
		P_STATE_SELECTED,
		P_STATE_THREATENED,
		P_STATE_CAPTURED,
		P_STATE_CHECKED,
		P_STATE_CHECKING,
		P_STATE_SPECIAL,
	}

var state_order: Array = []

func previous_state():
	if not state_order.is_empty():
		set_state(state_order.pop_back())
	else:
		set_state(P_STATE_NONE)

var current_state = P_STATE_NONE
	
func _init(player: Player, tile: Tile, piece_object: Node3D) -> void:
	object = piece_object
	player_parent = player
	tile_parent = tile
	mesh_color = player.color

func calculate_complete_moveset():
	pass

func generate_valid_moveset():
	pass

func is_same_piece(piece: Piece):
	return self == piece

func is_opponent_piece_of(player:Player):
	return self in Global.opponent(player).pieces

func is_friendly_piece_of(player:Player):
	return self in player.pieces

func is_opponent_king_of(player:Player):
	return self is King and self.is_opponent_piece_of(player)


func _set_outline_to(new_color:= Color(0,0,0)):
	if new_color == Color(0,0,0):
		outline_object.visible = false
		return
	outline_object.visible = true
	outline_color = new_color
	
func set_state(new_state):
	match new_state:
		P_STATE_NONE: 
			_set_outline_to()
			tile_parent.set_state(tile_parent.T_STATE_NONE)
			state_order.clear()
		P_STATE_SELECTED:
			if current_state != P_STATE_NONE:
				state_order.append(current_state)
			_set_outline_to(Global.game_color[Global.SELECT_PIECE])
			tile_parent.set_state(tile_parent.T_STATE_SELECTED)

			for tile in valid_moveset:
				if self is King and tile in Global.checked_king_moveset:
					tile.set_state(tile.T_STATE_MOVE_CHECKING)
				else:
					tile.set_state(tile.T_STATE_VALID)
			for tile in threatening_moveset:
				tile.set_state(tile.T_STATE_THREATENED)
				tile.occupant.set_state(tile.occupant.P_STATE_THREATENED)
		P_STATE_THREATENED:
			if current_state != P_STATE_NONE:
				state_order.append(current_state)
			_set_outline_to(Global.game_color[Global.THREATENED_PIECE])
			tile_parent.set_state(tile_parent.T_STATE_THREATENED)
		P_STATE_CAPTURED:
			object.visible = false
			collision_object.disabled = true
			object.translate(Vector3(0,-5,0)) 
		P_STATE_CHECKED: 
			if current_state != P_STATE_NONE:
				state_order.append(current_state)
			_set_outline_to(Global.game_color[Global.CHECKED_PIECE])
			tile_parent.set_state(tile_parent.T_STATE_CHECKED)
		P_STATE_CHECKING: 
			if current_state != P_STATE_NONE:
				state_order.append(current_state)
			_set_outline_to(Global.game_color[Global.CHECKING_PIECE])
			tile_parent.set_state(tile_parent.T_STATE_CHECKING)
		P_STATE_SPECIAL:
			if current_state != P_STATE_NONE:
				state_order.append(current_state)
			_set_outline_to(Global.game_color[Global.SPECIAL_PIECE])
	current_state = new_state
