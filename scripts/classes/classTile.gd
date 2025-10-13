
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

enum State {
		NONE = 0,
		SELECTED = 1,
		VALID = 2,
		THREATENED = 3,
		CHECKED = 4,
		CHECKER = 5,
		MOVE_CHECKER = 6,
	}

var state_order: Array[State] = [State.NONE]

func previous_state():
	if len(state_order) > 0:
		state = state_order.pop_back()
	else:
		state = State.NONE

var state: State:
	set(new_state):
		match new_state:
			State.NONE: 
				mesh.get_surface_override_material(0).albedo_color = color
				state_order.clear()
			State.SELECTED: 
				if state != State.NONE:
					state_order.append(state)
				if state != State.CHECKED:
					mesh.get_surface_override_material(0).albedo_color = color * Global.COLOR_SELECT_TILE
			State.VALID:
				if state != State.NONE:
					state_order.append(state)
				if state != State.CHECKER and state != State.MOVE_CHECKER:
					mesh.get_surface_override_material(0).albedo_color = color * Global.COLOR_MOVEMENT_TILE
			State.THREATENED:
				if state != State.NONE:
					state_order.append(state)
				mesh.get_surface_override_material(0).albedo_color = color * Global.COLOR_THREATENED_TILE
			State.CHECKED: 
				if state != State.NONE:
					state_order.append(state)
				mesh.get_surface_override_material(0).albedo_color = color * Global.COLOR_CHECKED_TILE
			State.CHECKER: 
				if state != State.NONE:
					state_order.append(state)
				if Global.setting_show_checker_piece_path:
					mesh.get_surface_override_material(0).albedo_color = color * Global.COLOR_CHECKER_TILE
			State.MOVE_CHECKER: 
				if state != State.NONE:
					state_order.append(state)
				mesh.get_surface_override_material(0).albedo_color = color * Global.COLOR_CHECKER_TILE
		state = new_state

func _init(tile_position: Vector2i, tile_object: Node3D) -> void:
	relative_position = tile_position
	object_tile = tile_object
	match (tile_position[0] + tile_position[1]) % 2:
		0: 
			color = Global.COLOR_TILE_LIGHT 
		1: 
			color = Global.COLOR_TILE_DARK
	
