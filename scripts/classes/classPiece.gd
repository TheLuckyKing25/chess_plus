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
		parity = 1 if player.color != Global.PLAYER_COLOR[0] else -1

var parity: int # determines which direction is the front

## Directions the piece can move in.
var movement_direction: Array[Vector2i] = []
## The distance covered by the movement directions.
var movement_distance: int = 1

var all_movements = []
var pawn_threatening_movement: Array[Tile] = []

var valid_movements: Array[Tile] = []
var valid_threatening_movements: Array[Tile] = []

var full_valid_movements: Array[Tile]:
	get: 
		return valid_movements + valid_threatening_movements

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
				outline_color = Global.COLOR_SELECT_PIECE
				tile_parent.state = tile_parent.State.SELECTED

				for tile in valid_movements:
					if self is King and tile in Global.threaten_king_movement:
						tile.state = tile.State.MOVE_CHECKER
					else:
						tile.state = tile.State.VALID
				for tile in valid_threatening_movements:
					tile.state = tile.State.THREATENED
					tile.occupant.state = tile.occupant.State.THREATENED
			State.THREATENED:
				if state != State.NONE:
					state_order.append(state)
				outline.visible = true
				outline_color = Global.COLOR_THREATENED_PIECE
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
				outline_color = Global.COLOR_CHECKED_PIECE
				tile_parent.state = tile_parent.State.CHECKED
			State.CHECKER: 
				if state != State.NONE:
					state_order.append(state)
				outline.visible = true
				outline_color = Global.COLOR_CHECKER_PIECE
				tile_parent.state = tile_parent.State.CHECKER
		state = new_state
		
func _init(player: Player, tile: Tile, piece_object: Node3D) -> void:
	object_piece = piece_object
	player_parent = player
	tile_parent = tile

func calculate_all_movements():
	pawn_threatening_movement = []
	all_movements = []
	for direction in movement_direction:
		var path: Array[Tile] = []

		for distance in range(1,movement_distance+1):
			var new_position = tile_parent.relative_position + (direction * distance * parity)
			var new_tile = Global.find_tile_from_position(new_position)
			
			if not new_tile: 
				break
			
			if self is Pawn and direction != movement_direction[0]:
				pawn_threatening_movement.append(new_tile)
				break
			path.append(new_tile)
		all_movements.append(path)

func validate_movements():
	valid_movements = []
	valid_threatening_movements = []
	
	if self is Pawn:
		for tile in all_movements[0]:
			if tile.occupant:
				break
			else:
				valid_movements.append(tile)
				
		for tile in pawn_threatening_movement:
			if tile.occupant:
				if tile.occupant in Global.opponent(player_parent).pieces:
					if tile.occupant in player_parent.pieces:
						break
					elif tile.occupant == Global.opponent(player_parent).king:
						Global.threaten_king_tiles.append(tile)
						Global.threaten_king_pieces.append(self)
						break
					valid_threatening_movements.append(tile)
					break
			elif not tile.occupant:
				if tile in Global.opponent(player_parent).king.full_valid_movements:
					Global.threaten_king_movement.append(tile)
				continue
	elif self is Knight:
		for path in all_movements:
			for tile in path:
				if tile.occupant:
					if tile.occupant in player_parent.pieces:
						break
					elif tile.occupant in Global.opponent(player_parent).pieces:
						if tile.occupant == Global.opponent(player_parent).king:
							Global.threaten_king_tiles.append(tile)
							Global.threaten_king_pieces.append(self)
							continue
						valid_threatening_movements.append(tile)
				elif not tile.occupant:
					if tile in Global.opponent(player_parent).king.full_valid_movements:
						Global.threaten_king_movement.append(tile)
				valid_movements.append(tile)
				
	else:
		for path in all_movements:
			var valid_path: Array[Tile] = []
			var king_check = false
			for tile in path:	
				if tile.occupant:
					if tile.occupant in player_parent.pieces:
						break
					elif tile.occupant in Global.opponent(player_parent).pieces and not king_check:
						if tile.occupant == Global.opponent(player_parent).king:
							Global.threaten_king_tiles += valid_path
							Global.threaten_king_movement.append(valid_path.back())
							Global.threaten_king_pieces.append(self)
							king_check = true
							continue
						valid_threatening_movements.append(tile)
						break
				elif not tile.occupant:
					if king_check:
						Global.threaten_king_movement.append(tile)
						break
					elif tile in Global.opponent(player_parent).king.full_valid_movements:
						Global.threaten_king_movement.append(tile)
						break
					valid_path.append(tile)
					continue
			valid_movements += valid_path
