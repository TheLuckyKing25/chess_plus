class_name Board
extends Node

## Settings that may or may not be implimented as game options
var setting_restrict_movement: bool = true
var setting_show_threatened: bool = true
var setting_board_size: Vector2i = Vector2i(8,8)

## Node containing the tiles and pieces
var object_board: Node3D
## Tiles of the board
var board_tiles: Array[Tile] = []
## Pieces on the board
var board_pieces: Array[Piece] = []

## Base colors for the tiles
var color_tile_base: Color = Color(0.75, 0.5775, 0.435)
var color_tile_light: Color = color_tile_base * 4/3
var color_tile_dark: Color = color_tile_base * 2/3

## Highlight color for valid moves
var color_tile_valid_move: Color = Color(0.25, 0.75, 0.25)
## Color for threatened tiles and threatened piece outlines
var color_threatened: Color = Color(0.9, 0, 0)
## Color for selected piece outlines and parent tiles
var color_select: Color = Color(0, 0.9, 0.9)

## Player classes for the board
var board_players: Array[Player] = []
var player_color: Array[Color] = [
	Color(0.9, 0.9, 0.9), 
	Color(0.1, 0.1, 0.1)
	]
var player_turn: int = 0

## Tile that has been clicked on and selected
var selected_tile: Tile = null
## Piece that has been clicked on and selected
var selected_piece: Piece = null
## Movement of the selected piece
var selected_movement: Array[Tile] = []

func _init(new_board_object: Node3D) -> void:
	set_board_object(new_board_object)
	board_players.append(Player.new(1,player_color[0]))
	board_players.append(Player.new(2,player_color[1]))
	
	for object_tile in object_board.find_children("Tile_*","",false):
		var tile_row = object_tile.name.substr(6,1).to_int()
		var tile_column = object_tile.name.substr(8,1).to_int()
		match (tile_row + tile_column) % 2:
			0: board_tiles.append(Tile.new(color_tile_light,Vector2i(tile_row,tile_column),object_tile))
			1: board_tiles.append(Tile.new(color_tile_dark,Vector2i(tile_row,tile_column),object_tile))
	
	for tile in board_tiles:
		if tile.is_occupied(): 
			match tile.get_occupant().get_object().name.get_slice("_", 1):
				"P1": 
					board_players[0].add_piece(tile.get_occupant())
				"P2": 
					tile.get_occupant().object_piece.find_child("Collision*").disabled = true
					board_players[1].add_piece(tile.get_occupant())
	
	for player in board_players:
		board_pieces += player.get_pieces()
		player.color_pieces()

## returns the classes of the board tiles 
func get_board_tiles() -> Array[Tile]: return board_tiles
## returns the node for the board
func get_board_object() -> Node3D: return object_board

## Compare two pieces
## Returns true if they are on the same team
func is_same_team(piece1: Piece, piece2: Piece) -> bool: 
	return piece1.object_piece.name.get_slice("_", 1) == piece2.object_piece.name.get_slice("_", 1)
## Checks if a selected tile is within the valid movement of the piece
func is_valid_move() -> bool: 
	return selected_tile in selected_movement
## Sets the node of the board
func set_board_object(new_board_object: Node3D) -> void: object_board = new_board_object

## Returns the tile class of the given tile object.
## Returns null if no tile class can be found.
func find_tile_from_object(tile_object: Node3D) -> Tile:
	for tile in board_tiles: if tile.get_object() == tile_object:
		return tile
	return null
## Returns the tile class with an object that has the given name.
## Returns null if no tile class can be found.
func find_tile_from_name(tile_name: String) -> Tile:
	for tile in board_tiles: if tile.get_object().name == tile_name:
		return tile
	return null
## Returns the tile class at the given position.
## Returns null if no tile class can be found.
func find_tile_from_position(tile_position: Vector2i) -> Tile:
	for tile in board_tiles: if tile.get_position() == tile_position:
		return tile
	return null
## Returns the piece class of the given piece object.
## Returns null if no piece class can be found.
func find_piece_from_object(piece_object: Node3D) -> Piece:
	for piece in board_pieces: if piece.get_object() == piece_object:
		return piece
	return null

## Mixes the current color of the tiles with the specified color.
func highlight_tiles(tiles: Array[Tile], color: Color) -> void:
	for tile in tiles: 
		tile.set_color(tile.color * color)
		
## Sets the current color of the tiles to the specified color.	
func color_tiles(tile_objects: Array[Tile], tile_color: Color) -> void:
	for tile_object in tile_objects: tile_object.set_color(tile_color)

## Sets the color of all tiles to their standard color.	
func reset_tile_colors() -> void:
	for tile in board_tiles: 
		match (int(tile.get_position()[0]) + int(tile.get_position()[1])) % 2:
			0: tile.set_color(color_tile_light)
			1: tile.set_color(color_tile_dark)

## Sets up the next turn
func new_turn() -> void:
	for piece in board_players[player_turn].get_pieces():
		piece.object_piece.find_child("Collision").disabled = true
	player_turn = (player_turn + 1) % 2
	for piece in board_players[player_turn].get_pieces():
		piece.object_piece.find_child("Collision").disabled = false
	object_board.get_parent().get_surface_override_material(0).albedo_color = player_color[player_turn]	

## Selects the given piece while unselecting the previously selected piece
func select_piece(new_selected_piece: Piece) -> void:
	if selected_piece:
		reset_tile_colors()
		for tile in selected_movement:
			if tile.is_occupied() and not is_same_team(selected_piece, tile.occupant):
				tile.occupant.unthreaten()
		selected_piece.unselect()
	
	new_selected_piece.set_color_outline(color_select)
	highlight_tiles([new_selected_piece.tile_parent],color_select)
	new_selected_piece.select()
	selected_piece = new_selected_piece
	selected_movement = calculate_moves(selected_piece)

## Calculates the moves of a given piece. Highlights the tiles accordingly and returns an array of valid tiles.
func calculate_moves(piece:Piece) -> Array[Tile]:
	var move_directions = piece.get_movement_directions()
	var move_distance = piece.get_movement_distance() + 1
	var position = piece.tile_parent.get_position()
	var pawn_parity = 1
	
	var valid_tiles: Array[Tile] = []
	var threatened_tiles: Array[Tile] = []
	
	if piece is Pawn and piece.base_color == player_color[0]:
		pawn_parity = -1
			
	for direction in move_directions:
		for n in range(1,move_distance):
			var new_position = position + (direction * n * pawn_parity)
			var new_tile = find_tile_from_position(new_position)
			if not new_tile: break
			if not new_tile.is_occupied():
				if piece is Pawn and direction != move_directions[0]: 
					break	
				valid_tiles.append(find_tile_from_position(new_position))
			elif new_tile.is_occupied():
				if is_same_team(piece, new_tile.occupant) \
				or (piece is Pawn and direction == move_directions[0]): 
					break					
				threatened_tiles.append(find_tile_from_position(new_position))
				break
			
	if len(valid_tiles) != 0:
		highlight_tiles(valid_tiles, color_tile_valid_move)
	if len(threatened_tiles) != 0:
		highlight_tiles(threatened_tiles, color_threatened)
		for tile in threatened_tiles:
			tile.occupant.set_color_outline(color_threatened)
			tile.occupant.threaten()
	
	return valid_tiles + threatened_tiles 
	
## Moves the given piece to the given tile, captures opponent pieces if tile is occupied.
func move_piece(piece: Piece, piece_destination_tile: Tile) -> void:
	if is_valid_move():
		reset_tile_colors()
		for tile in selected_movement:
			if tile.is_occupied() and not is_same_team(selected_piece, tile.occupant):
				tile.occupant.unthreaten()
		
		if piece_destination_tile.is_occupied():
			# PLACEHOLDER: CAPTURE MECHANIC
			piece_destination_tile.occupant.capture()
			
		piece.object_piece.reparent(piece_destination_tile.object_tile)
		piece.object_piece.set_owner(piece_destination_tile.object_tile)
		piece.object_piece.global_position = piece_destination_tile.object_tile.global_position * Vector3(1,0,1) + piece.object_piece.global_position * Vector3(0,1,0)
		
		var old_tile = piece.get_parent_tile()
		piece.set_parent_tile(piece_destination_tile)
		piece.get_parent_tile().set_occupant(piece)
		old_tile.set_occupant(null)
		
		if piece is Pawn and !piece.has_moved():
			piece.set_movement_distance(1)
			piece.moved = true
		
		selected_piece.object_piece.find_child("Outline").visible = false
		selected_piece = null
		selected_tile = null
		selected_movement = []
		new_turn()
