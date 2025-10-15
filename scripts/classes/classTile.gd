
class_name Tile
extends Node

## Color of the mesh object
var color: Color: 
	set(new_color):
		color = new_color
		mesh.get_surface_override_material(0).albedo_color = new_color

var state_color: Color: 
	set(new_color):
		state_color = new_color
		mesh.get_surface_override_material(0).albedo_color = new_color

## Position of the tile on the board
var board_position: Vector2i

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

enum {
		T_STATE_NONE,
		T_STATE_SELECTED,
		T_STATE_VALID,
		T_STATE_THREATENED,
		T_STATE_CHECKED,
		T_STATE_CHECKING,
		T_STATE_MOVE_CHECKING,
	}

var state_order: Array = []

func previous_state():
	if len(state_order) > 1:
		set_state(state_order.pop_back())
	else:
		set_state(T_STATE_NONE)

var state

func _init(tile_position: Vector2i, tile_object: Node3D) -> void:
	board_position = tile_position
	object_tile = tile_object
	match (tile_position[0] + tile_position[1]) % 2:
		0: 
			color = Global.game_color[Global.TILE_LIGHT]
		1: 
			color = Global.game_color[Global.TILE_DARK]
	
func is_occupied_by_opponent_piece(player: Player):
	return occupant and occupant in Global.opponent(player).pieces

func set_state(new_state):
	var previous_state = state
	if previous_state != T_STATE_NONE and new_state != T_STATE_NONE:
		state_order.append(previous_state)
	match new_state:
		T_STATE_NONE: 
			state_color = color
			state_order.clear()
		T_STATE_SELECTED: 
			if previous_state != T_STATE_CHECKED:
				state_color = color * Global.game_color[Global.SELECT_TILE]
		T_STATE_VALID:
			if previous_state != T_STATE_MOVE_CHECKING:
				state_color = color * Global.game_color[Global.VALID_TILE]
		T_STATE_THREATENED:
			state_color = Global.game_color[Global.THREATENED_TILE]
		T_STATE_CHECKED: 
			state_color = color * Global.game_color[Global.CHECKED_TILE]
		T_STATE_CHECKING: 
			if Global.setting[Global.SHOW_CHECKING_PIECE_PATH]:
				state_color = color * Global.game_color[Global.CHECKING_TILE]
		T_STATE_MOVE_CHECKING: 
			state_color = color * Global.game_color[Global.CHECKING_TILE]
	state = new_state
