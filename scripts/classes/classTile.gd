
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
		T_STATE_SPECIAL,
	}

var state_order: Array = []

func previous_state():
	if not state_order.is_empty():
		set_state(state_order.pop_back())
	else:
		set_state(T_STATE_NONE)

var current_state = T_STATE_NONE

func _init(tile_position: Vector2i, tile_object: Node3D) -> void:
	board_position = tile_position
	object_tile = tile_object
	match (tile_position[0] + tile_position[1]) % 2:
		0: 
			color = Global.game_color[Global.TILE_LIGHT]
		1: 
			color = Global.game_color[Global.TILE_DARK]
	
func is_occupied_by_opponent_piece_of(player: Player):
	return occupant and occupant in Global.opponent(player).pieces
	
func is_occupied_by_friendly_piece_of(player: Player):
	return occupant and occupant in player.pieces

## Checks if a selected tile is within the valid movement of the piece
func is_valid_move(piece: Piece, player: Player) -> bool: 
	return (
		self in piece.possible_moveset 
		or (
			not Global.setting[Global.DEBUG_RESTRICT_MOVEMENT] 
			and not is_occupied_by_friendly_piece_of(player)
		)
	)

func _set_color_to(color_value:= Color(1,1,1)):
	state_color = color * color_value

func is_threatened_by(opposing_player:Player):
	return self in opposing_player.all_threatened_tiles
	
func set_state(new_state):
	if new_state != T_STATE_SPECIAL:
		mesh.get_surface_override_material(0).emission_enabled = false
	match new_state:
		T_STATE_NONE: 
			_set_color_to()
			state_order.clear()
		T_STATE_SELECTED: 
			if current_state != T_STATE_NONE:
				state_order.append(current_state)
			if current_state != T_STATE_CHECKED:
				_set_color_to(Global.game_color[Global.SELECT_TILE])
		T_STATE_VALID:
			if current_state != T_STATE_NONE:
				state_order.append(current_state)
			if current_state != T_STATE_MOVE_CHECKING:
				_set_color_to(Global.game_color[Global.VALID_TILE])
		T_STATE_THREATENED:
			if current_state != T_STATE_NONE:
				state_order.append(current_state)
			_set_color_to(Global.game_color[Global.THREATENED_TILE])
		T_STATE_CHECKED: 
			if current_state != T_STATE_NONE:
				state_order.append(current_state)
			_set_color_to(Global.game_color[Global.CHECKED_TILE])
		T_STATE_CHECKING: 
			if current_state != T_STATE_NONE:
				state_order.append(current_state)
			if Global.setting[Global.SHOW_CHECKING_PIECE_PATH]:
				_set_color_to(Global.game_color[Global.CHECKING_TILE])
		T_STATE_MOVE_CHECKING: 
			if current_state != T_STATE_NONE:
				state_order.append(current_state)
			_set_color_to(Global.game_color[Global.MOVE_CHECKING_TILE])
		T_STATE_SPECIAL:
			if current_state != T_STATE_NONE:
				state_order.append(current_state)
			state_color = Global.game_color[Global.SPECIAL_TILE]
			mesh.get_surface_override_material(0).emission_enabled = true
	current_state = new_state
