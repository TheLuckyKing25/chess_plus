extends Node

#region SpecialMovement and Check
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
#endregion

# Settings that may or may not be implimented as game options
#region Setting Variables
var setting_debug_restrict_movement: bool = false

# Show the path that a piece uses to check a king
var setting_show_checker_piece_path: bool = true
# Show the piece that checks a king
var setting_show_checker_piece: bool = true

var setting_piece_outline_thickness: float = 0.1

# You must move the first piece you select
var setting_touch_move: bool = false #Not implimented

const setting_board_length: int = 8 #Not implimented
const setting_board_width: int = 8 #Not implimented
#endregion

# Colors for all objects.
#region Color Constants and Variables
# Base colors for the tiles
const COLOR_TILE: Color = Color(0.75, 0.5775, 0.435) 
const COLOR_TILE_LIGHT: Color = COLOR_TILE * 4/3
const COLOR_TILE_DARK: Color = COLOR_TILE * 2/3

# Highlight color for valid moves
# Color(0.25, 0.75, 0.25)
const COLOR_MOVEMENT_TILE: Color = Color(0.6, 1, 0.6)

# Color for threatened tiles and threatened piece outlines
const COLOR_THREATENED_PIECE: Color = Color(0.9, 0, 0) 
const COLOR_THREATENED_TILE: Color = Color(1, 0.2, 0.2) 

const COLOR_CHECKER_PIECE: Color = Color(0.9, 0.45, 0)
const COLOR_CHECKER_TILE: Color = Color(1, 0.65, 0.25)

# Color for selected piece outlines and parent tiles
const COLOR_SELECT_PIECE: Color = Color(0, 0.9, 0.9)
const COLOR_SELECT_TILE: Color = Color(0.1, 1, 1)

const COLOR_CHECKED_PIECE: Color = COLOR_THREATENED_PIECE
const COLOR_CHECKED_TILE: Color = COLOR_THREATENED_TILE

const PLAYER_COLOR: Array[Color] = [
	Color(0.9, 0.9, 0.9), 
	Color(0.1, 0.1, 0.1),
	]
#endregion

#region Piece Movement Direction and Distance Constants
enum MovementDistance{
	PAWN_INITIAL = 2,
	PAWN = 1,
	BISHOP = 8,
	KNIGHT = 1,
	ROOK = 8,
	QUEEN = 8,
	KING = 1,
}


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

# Variables that are frequently changed and accessed by other scripts
#region Gameplay Variables
var player_turn: int = 0

var board: Board = null
var players: Array[Player] = []
var tiles: Array[Tile] = []
var pieces: Array[Piece] = []

var selected_tile: Tile = null
var selected_piece: Piece = null

var threaten_king_tiles: Array[Tile] = []
var threaten_king_pieces: Array[Piece] = []
var threaten_king_movement: Array[Tile] = []
#endregion

func opponent(player: Player) -> Player:
	if player == players[0]:
		return players[1]
	elif player == players[1]:
		return players[0]
	else:
		return null

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

## Checks if a selected tile is within the valid movement of the piece
func is_valid_move() -> bool: 
	return (
		selected_tile in selected_piece.full_valid_movements 
		or (
			not setting_debug_restrict_movement 
			and not selected_tile.occupant in players[player_turn].pieces
		)
	)


func clear_movement():
	for tile in selected_piece.full_valid_movements:
		tile.state = tile.State.NONE
		if (
				tile.occupant 
				and tile.occupant in opponent(players[player_turn]).pieces
		):
			tile.occupant.state = tile.occupant.State.NONE
	selected_piece.state = selected_piece.State.NONE

func unselect_piece(unselected_piece: Piece):
	for tile in unselected_piece.full_valid_movements:
		tile.previous_state()
		if (
				tile.occupant 
				and tile.occupant in opponent(players[player_turn]).pieces
		):
			tile.occupant.previous_state()
	unselected_piece.previous_state()

## Selects the given piece while unselecting the previously selected piece
func select_piece(new_selected_piece: Piece) -> void:
	# unselect piece by clicking on it again
	if selected_piece == new_selected_piece:
		unselect_piece(selected_piece)
		selected_piece = null
		return
	# select tile by clicking an opponent piece
	elif selected_piece and new_selected_piece in opponent(players[player_turn]).pieces: 
		selected_tile = new_selected_piece.tile_parent
		return
	# select a piece
	elif new_selected_piece in players[player_turn].pieces: 
		if selected_piece:
			unselect_piece(selected_piece)
	
		selected_piece = new_selected_piece
		selected_piece.state = selected_piece.State.SELECTED
	
## Sets up the next turn
func new_turn() -> void:
	
	selected_piece = null
	selected_tile = null
	
	# switched the board color and increments the turn number
	player_turn = (player_turn + 1) % 2
	board.color = PLAYER_COLOR[player_turn]
	
	# Clear the states of all the tiles
	for tile in tiles:
		tile.state = tile.State.NONE
	
	# Clear the states of all the pieces and players
	for player in players:
		for piece in player.pieces:
			piece.state = piece.State.NONE

  	# Recalculate piece movements and if check has occured
	for player in players:
		player.king.calculate_all_movements()
		player.king.validate_movements()
	
	threaten_king_movement = []
			
	for player in players:
		threaten_king_tiles = []
		threaten_king_pieces = []
		for piece in player.pieces:
			if piece is not King:
				piece.calculate_all_movements()
				piece.validate_movements()
			
		if threaten_king_tiles and threaten_king_pieces:
			for tile in threaten_king_tiles:
				tile.state = tile.State.CHECKER
			for piece in threaten_king_pieces:
				piece.state = piece.State.CHECKER
			opponent(player).king.state = opponent(player).king.State.CHECKED

## Moves the given piece to the given tile, 
## and captures opponent pieces if tile is occupied.
func move_piece(piece: Piece, destination_tile: Tile) -> void:
	if is_valid_move():
		clear_movement()
		
		if destination_tile.occupant:
			destination_tile.occupant.state = destination_tile.occupant.State.CAPTURED
		
		# Parents the piece to the new tile in the node tree.
		piece.object_piece.reparent(destination_tile.object_tile)
		piece.object_piece.set_owner(destination_tile.object_tile)
		piece.object_piece.global_position = (
				destination_tile.object_tile.global_position 
				* Vector3(1,0,1)
				+ piece.object_piece.global_position 
				* Vector3(0,1,0)
		)
		
		# Adjusts tile and piece class values
		var old_tile = piece.tile_parent
		piece.tile_parent = destination_tile
		piece.tile_parent.occupant = piece
		old_tile.occupant = null
		
		if piece is Pawn and !piece.has_moved:
			piece.movement_distance = MovementDistance.PAWN
		piece.has_moved = true

		new_turn()


			
	
	
	
	
	
	
	
	
	
