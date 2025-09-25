extends Node

#region SpecialMovement and Check
# Allow players to click on a threatened piece to capture it
# instead of having them click on the tile
# * Would have to change the implimentation of limiting piece selection

# Castling is permitted provided all of the following conditions are met:
# * Neither the king nor the rook has previously moved.
# * There are no pieces between the king and the rook.
# * The king is not currently in check.
# * The king does not pass through 
#   or finish on a square that is attacked by an enemy piece.

# The conditions for a pawn to capture an enemy pawn en passant are as follows:
# * the enemy pawn advanced two squares on the previous turn;
# * the capturing pawn attacks the square that the enemy pawn passed over.

# Promotion:
# * Remove the Pawn from the board.
# * Create an instance of the piece the pawn is promoted to.
# * Parent the piece to the Pawn's tile and color it the players color
# * Create a class for the new piece. 

# Calculating Check:
# * Calculate the kings movement as if it has the movements of every piece.
# * If the king can threaten a piece in this way, and that piece can 
#   replicate the movement, then the king is in check
#endregion

# Settings that may or may not be implimented as game options
#region Setting Variables
var setting_restrict_movement: bool = true #Not implimented

var setting_show_threatened: bool = true #Not implimented

# You must move the first piece you select
var setting_touch_move: bool = false #Not implimented

var setting_board_size: Vector2i = Vector2i(8,8) #Not implimented

var setting_piece_outline_thickness: float = 0.1 
#endregion

# Colors for all objects.
#region Color Constants and Variables
# Base colors for the tiles
const COLOR_TILE_BASE: Color = Color(0.75, 0.5775, 0.435) 
var color_tile_light: Color = COLOR_TILE_BASE * 4/3
var color_tile_dark: Color = COLOR_TILE_BASE * 2/3

# Highlight color for valid moves
const COLOR_TILE_VALID_MOVE: Color = Color(0.25, 0.75, 0.25) 

# Color for threatened tiles and threatened piece outlines
const COLOR_THREATENED: Color = Color(0.9, 0, 0) 

# Color for selected piece outlines and parent tiles
const COLOR_SELECT: Color = Color(0, 0.9, 0.9)
const PLAYER_COLOR: Array[Color] = [
	Color(0.9, 0.9, 0.9), 
	Color(0.1, 0.1, 0.1),
	]
#endregion

#region Piece Movement Direction Constants
const PAWN_MOVEMENT_DIRECTIONS: Array[Vector2i] = [
		Vector2i(1,0), 
		Vector2i(1,1), # Capture
		Vector2i(1,-1), # Capture
		]
const BISHOP_MOVEMENT_DIRECTIONS: Array[Vector2i] = [
		Vector2i(1,1), 
		Vector2i(-1,1), 
		Vector2i(1,-1), 
		Vector2i(-1,-1),
		]
const KNIGHT_MOVEMENT_DIRECTIONS: Array[Vector2i] = [
		Vector2i(1,2), 
		Vector2i(2,1), 
		Vector2i(-1,2), 
		Vector2i(-2,1), 
		Vector2i(1,-2), 
		Vector2i(2,-1), 
		Vector2i(-1,-2),
		Vector2i(-2,-1),
		]
const ROOK_MOVEMENT_DIRECTIONS: Array[Vector2i] = [
		Vector2i(1,0), 
		Vector2i(0,1), 
		Vector2i(-1,0), 
		Vector2i(0,-1),
		]
const QUEEN_MOVEMENT_DIRECTIONS: Array[Vector2i] = [
		Vector2i(1,0), 
		Vector2i(1,1), 
		Vector2i(0,1), 
		Vector2i(-1,1), 
		Vector2i(-1,0), 
		Vector2i(1,-1), 
		Vector2i(0,-1), 
		Vector2i(-1,-1),
		]
const KING_MOVEMENT_DIRECTIONS: Array[Vector2i] = [
		Vector2i(1,0), 
		Vector2i(1,1), 
		Vector2i(0,1), 
		Vector2i(-1,1), 
		Vector2i(-1,0), 
		Vector2i(1,-1), 
		Vector2i(0,-1), 
		Vector2i(-1,-1),
		]
#endregion

# Variables that are frequently changed and accessed by many other scripts
#region GameplayVariables
var player_turn: int = 0

var board: Board = null
var players: Array[Player] = []
var tiles: Array[Tile] = []
var pieces: Array[Piece] = []

var selected_tile: Tile = null
var selected_piece: Piece = null
var selected_movement: Array[Tile] = []
#endregion

## Returns the tile class of the given tile object.
## Returns null if no tile class can be found.
func find_tile_from_object(tile_object: Node3D) -> Tile:
	for tile in tiles: 
		if tile.object_tile == tile_object:
			return tile
	return null


## Returns the tile class with an object that has the given name.
## Returns null if no tile class can be found.
func find_tile_from_name(tile_name: String) -> Tile:
	for tile in tiles: 
		if tile.object_tile.name == tile_name:
			return tile
	return null


## Returns the tile class at the given position.
## Returns null if no tile class can be found.
func find_tile_from_position(tile_position: Vector2i) -> Tile:
	for tile in tiles: 
		if tile.relative_position == tile_position:
			return tile
	return null


## Returns the piece class of the given piece object.
## Returns null if no piece class can be found.
func find_piece_from_object(piece_object: Node3D) -> Piece:
	for piece in pieces: 
		if piece.object_piece == piece_object:
			return piece
	return null


## Compare two pieces
## Returns true if they are on the same team
func is_same_team(piece1: Piece, piece2: Piece) -> bool: 
	return (piece1.object_piece.name.get_slice("_", 1) 
			== piece2.object_piece.name.get_slice("_", 1))


## Checks if a selected tile is within the valid movement of the piece
func is_valid_move() -> bool: 
	return selected_tile in selected_movement


func clear_movement():
	for tile in selected_movement:
		tile.highlighted = false
		if (
				tile.occupant 
				and not is_same_team(selected_piece, tile.occupant)
		):
			tile.occupant.threatened = false
	selected_piece.selected = false
	selected_movement = []


## Selects the given piece while unselecting the previously selected piece
func select_piece(new_selected_piece: Piece) -> void:
	if selected_piece:
		clear_movement()
	
	selected_piece = new_selected_piece
	selected_piece.selected = true
	selected_movement = calculate_moves(selected_piece)


## Calculates the moves of a given piece. 
## Highlights the tiles accordingly and returns an array of valid tiles.
func calculate_moves(piece:Piece) -> Array[Tile]:
	var move_directions: Array[Vector2i] = piece.movement_direction
	var move_distance: int = piece.movement_distance + 1
	var position: Vector2i = piece.tile_parent.relative_position
	var pawn_parity: int = 1 # determines which direction the pawn moves
	
	var valid_tiles: Array[Tile] = []
	var threatened_tiles: Array[Tile] = []
	
	if (
			piece is Pawn 
			and piece.mesh_color == PLAYER_COLOR[0]
	):
		pawn_parity = -1
			
	for direction in move_directions:
		for n in range(1,move_distance):
			var new_position = position + (direction * n * pawn_parity)
			var new_tile = find_tile_from_position(new_position)
			if not new_tile: 
				break
			if not new_tile.occupant:
				if (
						piece is Pawn 
						and direction != move_directions[0]
				): 
					break	
				valid_tiles.append(find_tile_from_position(new_position))
			elif new_tile.occupant:
				if (
						is_same_team(piece, new_tile.occupant) 
						or (piece is Pawn 
						and direction == move_directions[0])
				): 
					break
				threatened_tiles.append(find_tile_from_position(new_position))
				break
			
	if len(valid_tiles) != 0:
		for tile in valid_tiles:
			tile.highlight_color = COLOR_TILE_VALID_MOVE

	if len(threatened_tiles) != 0:
		for tile in threatened_tiles:
			tile.occupant.threatened = true
	
	return valid_tiles + threatened_tiles 


## Sets up the next turn
func new_turn() -> void:
	for piece in players[player_turn].pieces:
		piece.collision.disabled = true
		
	player_turn = (player_turn + 1) % 2
	
	for piece in players[player_turn].pieces:
		piece.collision.disabled = false
		
	board.color = PLAYER_COLOR[player_turn]	


## Moves the given piece to the given tile, 
## and captures opponent pieces if tile is occupied.
func move_piece(piece: Piece, piece_destination_tile: Tile) -> void:
	if is_valid_move():
		clear_movement()
		
		if piece_destination_tile.occupant:
			piece_destination_tile.occupant.captured = true
		
		piece.object_piece.reparent(piece_destination_tile.object_tile)
		piece.object_piece.set_owner(piece_destination_tile.object_tile)
		piece.object_piece.global_position = (
				piece_destination_tile.object_tile.global_position 
				* Vector3(1,0,1)
				+ piece.object_piece.global_position 
				* Vector3(0,1,0)
		)
		
		var old_tile = piece.tile_parent
		piece.tile_parent = piece_destination_tile
		piece.tile_parent.occupant = piece
		old_tile.occupant = null
		
		if (
				piece is Pawn 
				and !piece.has_moved
		):
			piece.movement_distance = 1
			piece.has_moved = true
		
		selected_piece.selected = false
		selected_piece = null
		selected_tile = null
		new_turn()
