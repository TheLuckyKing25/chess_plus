extends Node

#region SpecialMovement and Check
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
enum {
	# Debug settings
	DEBUG_RESTRICT_MOVEMENT,
	
	# Game settings
	SHOW_CHECKING_PIECE_PATH, # Show the path that a piece uses to check a king
	SHOW_CHECKING_PIECE, # Show the piece that is checking a king
	TOUCH_MOVE, # You must move the first piece you select
	
	# Player settings
	PIECE_OUTLINE_THICKNESS,	
}

var setting: Dictionary = {
	DEBUG_RESTRICT_MOVEMENT: true,
	SHOW_CHECKING_PIECE_PATH: true,
	SHOW_CHECKING_PIECE: true,
	PIECE_OUTLINE_THICKNESS: 0.1,
	TOUCH_MOVE: false, #Not implimented
}

#endregion

# Colors for all objects.
#region Color Constants and Variables
# Base colors for the tiles
enum {
	TILE_LIGHT,
	TILE_DARK,
	VALID_TILE,
	THREATENED_PIECE,
	THREATENED_TILE,
	CHECKING_PIECE,
	CHECKING_TILE,
	SELECT_PIECE,
	SELECT_TILE,
	CHECKED_PIECE,
	CHECKED_TILE,
	MOVE_CHECKING_TILE,
	SPECIAL_PIECE,
	SPECIAL_TILE,
	PLAYER,
}

const COLOR_TILE: Color = Color(0.75, 0.5775, 0.435) 

const game_color: Dictionary = {
	TILE_LIGHT: COLOR_TILE * 4/3,
	TILE_DARK: COLOR_TILE * 2/3,
	
	VALID_TILE: Color(0.6, 1, 0.6), 
	
	THREATENED_PIECE: Color(0.9, 0, 0),
	THREATENED_TILE: Color(1, 0.2, 0.2),
	
	CHECKING_PIECE: Color(0.9, 0.9, 0),
	CHECKING_TILE: Color(1, 1, 0.25),
	
	SELECT_PIECE: Color(0, 0.9, 0.9),
	SELECT_TILE: Color(0.1, 1, 1),
	
	CHECKED_PIECE: Color(0.9, 0, 0),
	CHECKED_TILE: Color(1, 0.2, 0.2),
	
	MOVE_CHECKING_TILE: Color(1, 0.65, 0.25),
	
	SPECIAL_PIECE: Color(1,1,1),
	SPECIAL_TILE: Color(1,1,1),
	
	PLAYER: [
		Color(0.9, 0.9, 0.9), 
		Color(0.1, 0.1, 0.1),
	],
}
#endregion

#region Piece Movement Direction and Distance Constants
enum {
	PAWN,
	BISHOP,
	KNIGHT,
	ROOK,
	QUEEN,
	KING,
}

var distance:Dictionary = {
	PAWN: [2,1],
	BISHOP: 8,
	KNIGHT: 1,
	ROOK: 8,
	QUEEN: 8,
	KING: 1,
}

var direction:Dictionary = {
	PAWN: [
		[Vector2i(1,0)],
		[Vector2i(1,1),Vector2i(1,-1)]
		],
	BISHOP: [
		Vector2i(1,1), 
		Vector2i(1,-1),
		Vector2i(-1,-1),
		Vector2i(-1,1),
		],
	KNIGHT: [
		Vector2i(1,2),  
		Vector2i(2,1),
		Vector2i(2,-1), 
		Vector2i(1,-2), 
		Vector2i(-1,2), 
		Vector2i(-2,-1),
		Vector2i(-2,1), 
		Vector2i(-1,-2),
		],
	ROOK: [
		Vector2i(1,0), 
		Vector2i(0,1), 
		Vector2i(-1,0), 
		Vector2i(0,-1),
		],
	QUEEN: [
		Vector2i(1,0), 
		Vector2i(1,1), 
		Vector2i(0,1), 
		Vector2i(1,-1), 
		Vector2i(0,-1), 
		Vector2i(-1,-1), 
		Vector2i(-1,0), 
		Vector2i(-1,1),
		],
	KING: [
		Vector2i(1,0), 
		Vector2i(1,1), 
		Vector2i(0,1), 
		Vector2i(1,-1), 
		Vector2i(0,-1), 
		Vector2i(-1,-1), 
		Vector2i(-1,0), 
		Vector2i(-1,1),
		],
}
#endregion

# Variables that are frequently changed and accessed by other scripts
#region Gameplay Variables
var player_turn: int = 0

var current_player: Player

var board: Board = null
var players: Array[Player] = []
var tiles: Array[Tile] = []
var pieces: Array[Piece] = []

var selected_piece: Piece = null
var selected_tile: Tile = null

var checking_tiles: Array[Tile] = []
var checking_pieces: Array[Piece] = []
var checked_king_moveset: Array[Tile] = []

var king_rook_relation = []
#endregion

func _clear_all_piece_states() -> void:
	# Clear the states of all the pieces and players
	for player in players:
		for piece in player.pieces:
			piece.set_state(piece.P_STATE_NONE)

func _clear_all_tile_states() -> void:
	# Clear the states of all the tiles
	for tile in tiles:
		tile.set_state(tile.T_STATE_NONE)

func _reparent_piece_to_new_tile(piece:Node3D, tile:Node3D) -> void:
		piece.reparent(tile)
		piece.set_owner(tile)
		piece.global_position = (
				tile.global_position 
				* Vector3(1,0,1)
				+ piece.global_position 
				* Vector3(0,1,0)
		)

func _set_check_states(checking_player: Player) -> void:
	var opponent_king = opponent(checking_player).king
	
	for tile in checking_tiles:
		tile.set_state(tile.T_STATE_CHECKING)
	for piece in checking_pieces:
		piece.set_state(piece.P_STATE_CHECKING)

	opponent_king.set_state(opponent_king.P_STATE_CHECKED)

func create_players() -> void:
	players.append(Player.new(1,game_color[PLAYER][0]))
	players.append(Player.new(2,game_color[PLAYER][1]))

func is_castling_legal(piece1: King, piece2: Rook) -> bool:
	var piece_check = piece1.is_castling_valid() and piece2.is_castling_valid()

	if !piece_check:
		return false
		
	var tile_check = true
	var position1 = piece1.tile_parent.board_position
	var position2 = piece2.tile_parent.board_position
	var position_difference = abs(position1 - position2)
	
	var x = position1.x
	var lesser_y = position2.y if position1 > position2 else position1.y

	for y in range(1,position_difference.y):
		var between_tile = tile_from_position(Vector2i(x,y+lesser_y))
		if between_tile.occupant or between_tile.is_threatened_by(opponent(current_player)):
			tile_check = false
			break
	return piece_check and tile_check

## Moves the given piece to the given tile, 
## and captures opponent pieces if tile is occupied.
func move_piece(piece: Piece, new_tile: Tile) -> void:
	if new_tile.is_valid_move(piece, current_player):
		
		if new_tile.occupant:
			new_tile.occupant.set_state(new_tile.occupant.P_STATE_CAPTURED)
		
		# Parents the piece to the new tile in the node tree.
		_reparent_piece_to_new_tile(piece.object, new_tile.object_tile)
		
		# Adjusts tile and piece class values
		var starting_tile = piece.tile_parent
		piece.tile_parent = new_tile
		piece.tile_parent.occupant = piece
		starting_tile.occupant = null
		
		if piece is Pawn and !piece.has_moved:
			piece.movement_distance = distance[PAWN][1]
		piece.has_moved = true
		
		if piece is King and new_tile in piece.castling_moveset:
			for relation in king_rook_relation:
				if relation["King_Destination_Tile"] == new_tile:
					var rook = relation["Rook"]
					var rook_position = rook.tile_parent.board_position
					var distance = abs(rook_position - new_tile.board_position)
					var new_position
					if distance.y == 2:
						new_position = rook_position + Vector2i(0,3)
					elif distance.y == 1:
						new_position = rook_position + Vector2i(0,-2)
					var rook_new_tile = tile_from_position(new_position)
					move_piece(rook,rook_new_tile)
		else:
			new_turn()

## Sets up the next turn
func new_turn() -> void:
	
	selected_piece = null
	selected_tile = null
	king_rook_relation.clear()
	checked_king_moveset.clear()
	
	# increments the turn number and switches the board color
	player_turn = (player_turn + 1) % 2
	board.color = game_color[PLAYER][player_turn]
	current_player = players[player_turn]

	_clear_all_tile_states()
	_clear_all_piece_states()
	
  	# Recalculate piece movements and if check has occured
	for player in players:
		player.king.calculate_complete_moveset()
		player.king.generate_valid_moveset()
	

	for player in players:
		checking_tiles.clear()
		checking_pieces.clear()
		for piece in player.pieces:
			if piece is King: 
				continue
			piece.calculate_complete_moveset()
			piece.generate_valid_moveset()
			
		player.compile_threatened_tiles()
		
		if checking_tiles and checking_pieces:
			_set_check_states(player)

func opponent(player: Player) -> Player:
	if player == players[0]:
		return players[1]
	elif player == players[1]:
		return players[0]
	else:
		return null

## Returns the piece class of the given piece object.
## Returns null if no piece class can be found.
func piece_from_object(piece_object: Node3D) -> Piece:
	for piece in pieces: 
		if piece.object == piece_object:
			return piece
	return null

func print_move() -> void:
		print(
			"%10s" % selected_piece.object.name 
			+ " moves from " 
			+ selected_piece.tile_parent.object_tile.name 
			+ " to " 
			+ selected_tile.object_tile.name
		)

## Selects the given piece while unselecting the previously selected piece
func select_piece(new_selected_piece: Piece) -> void:
	# unselect piece by clicking on it again
	if selected_piece and selected_piece.is_same_piece(new_selected_piece):
		unselect_piece(selected_piece)
		selected_piece = null

	# select tile by clicking an opponent piece
	elif selected_piece and new_selected_piece.is_opponent_piece_of(current_player): 
		selected_tile = new_selected_piece.tile_parent

	# unselect the current piece and select the new piece
	elif selected_piece and new_selected_piece.is_friendly_piece_of(current_player): 
		unselect_piece(selected_piece)
	
		selected_piece = new_selected_piece
		selected_piece.set_state(selected_piece.P_STATE_SELECTED)
		
	# select the newly selected piece
	elif not selected_piece and new_selected_piece.is_friendly_piece_of(current_player): 
		selected_piece = new_selected_piece
		selected_piece.set_state(selected_piece.P_STATE_SELECTED)
	
	
	if selected_piece and selected_piece is King:
		for rook in current_player.rooks:
			if not is_castling_legal(selected_piece,rook):
				continue
			rook.set_state(rook.P_STATE_SPECIAL)
			var king_position = selected_piece.tile_parent.board_position
			var rook_position = rook.tile_parent.board_position
			var new_position
			if king_position > rook_position:
				new_position = king_position + Vector2i(0,-2)
			elif king_position < rook_position:
				new_position = king_position + Vector2i(0,2)
				
			var king_new_tile = tile_from_position(new_position)
			king_new_tile.set_state(king_new_tile.T_STATE_SPECIAL)
			selected_piece.castling_moveset.append(king_new_tile)
			king_rook_relation.append(
				{
				"Rook": rook, 
				"King_Destination_Tile": king_new_tile
				})


## Returns the tile class with an object that has the given name.
## Returns null if no tile class can be found.
func tile_from_name(tile_name: String) -> Tile:
	for tile in tiles: 
		if tile.object_tile.name == tile_name:
			return tile
	return null

## Returns the tile class of the given tile object.
## Returns null if no tile class can be found.
func tile_from_object(tile_object: Node3D) -> Tile:
	for tile in tiles: 
		if tile.object_tile == tile_object:
			return tile
	return null


## Returns the tile class at the given position.
## Returns null if no tile class can be found.
func tile_from_position(tile_position: Vector2i) -> Tile:
	for tile in tiles: 
		if tile.board_position == tile_position:
			return tile
	return null

func unselect_piece(unselected_piece: Piece) -> void:
	for tile in unselected_piece.possible_moveset:
		tile.previous_state()
		if tile.is_occupied_by_opponent_piece_of(current_player):
			tile.occupant.previous_state()
	for relation in king_rook_relation:
		relation["Rook"].previous_state()
	king_rook_relation.clear()
	unselected_piece.previous_state()
