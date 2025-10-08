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

enum State {
		NONE = 0,
		SELECTED = 1,
		THREATENED = 2,
		CAPTURED = 3,
		CHECKED = 4,
		CHECKER = 5,
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
				outline.visible = false
				tile_parent.state = tile_parent.State.NONE
				state_order.clear()
			State.SELECTED:
				if state != State.NONE:
					state_order.append(state)
				outline.visible = true
				outline.material_override.albedo_color = Global.COLOR_SELECT_PIECE
				tile_parent.state = tile_parent.State.SELECTED
				for tile in valid_movements:
					tile.state = tile.State.VALID
				for tile in valid_threatening_movements:
					tile.state = tile.State.THREATENED
					tile.occupant.state = tile.occupant.State.THREATENED
			State.THREATENED:
				if state != State.NONE:
					state_order.append(state)
				outline.visible = true
				outline.material_override.albedo_color = Global.COLOR_THREATENED_PIECE
				tile_parent.state = tile_parent.State.THREATENED
			State.CAPTURED:
				if state != State.NONE:
					state_order.append(state)
				collision.disabled = true
				object_piece.visible = false
				object_piece.translate(Vector3(0,-5,0)) 
			State.CHECKED: 
				if state != State.NONE:
					state_order.append(state)
				outline.visible = true
				outline.material_override.albedo_color = Global.COLOR_CHECKED_PIECE
				tile_parent.state = tile_parent.State.CHECKED
			State.CHECKER: 
				if state != State.NONE:
					state_order.append(state)
				outline.visible = true
				outline.material_override.albedo_color = Global.COLOR_CHECKER_PIECE
				tile_parent.state = tile_parent.State.CHECKER
		state = new_state
		
func _init(player: Player, tile: Tile, piece_object: Node3D) -> void:
	object_piece = piece_object
	player_parent = player
	tile_parent = tile
	
func calculate_movements():
	valid_movements = []
	valid_threatening_movements = []
	for direction in movement_direction:
		var outward_movement: Array[Tile] = []
		for distance in range(1,movement_distance+1):
			var new_position = tile_parent.relative_position + (direction * distance * parity)
			var new_tile = Global.find_tile_from_position(new_position)
			if not new_tile: 
				break
			if not new_tile.occupant:
				if self is Pawn and direction != movement_direction[0]:
					break
				valid_movements.append(new_tile)
				outward_movement.append(new_tile)
			elif new_tile.occupant:
				if Global.is_same_team(self, new_tile.occupant) or (
						self is Pawn and direction == movement_direction[0]
					):
					break
				elif not Global.is_same_team(self, new_tile.occupant) and new_tile.occupant == Global.opponent(player_parent).king:
					print(Global.players[(Global.player_turn + 1) % 2].king)
					outward_movement.append(new_tile)
					Global.threaten_king_tiles += outward_movement
					Global.threaten_king_pieces.append(self)
				valid_threatening_movements.append(new_tile)
				break
	return
