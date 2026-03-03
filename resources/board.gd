class_name Board
extends Resource

static var player_one:Player = load("res://resources/players/player_one.tres")
static var player_two:Player = load("res://resources/players/player_two.tres")

static var rank_count: int = 8

static var file_count: int = 8

static var tile_array: Array[Tile] = []

static var piece_location: Array[Piece] = []

static var legal_moves: Array[Move]

static var FEN_board_state: FEN

static var controller: BoardController

static func generate_virtual_board():
	tile_array.resize(file_count * rank_count)
	piece_location.resize(file_count * rank_count)
	
	for tile_num in range(rank_count * file_count):
		var new_tile_controller = BoardController.TILE_SCENE.instantiate()
		var new_tile = Tile.new()
		new_tile.index = tile_num
		new_tile.controller = new_tile_controller
		new_tile_controller.translate(Vector3(
				new_tile.file-(float(file_count)/2)+0.5, 
				0.1, 
				(float(rank_count)/2)-new_tile.rank-0.5
			))
		tile_array[tile_num] = new_tile
	for tile in tile_array:
		print(tile.controller)


static func decode_FEN(FE_notation:FEN):
	FEN_board_state = FE_notation
	for tile in tile_array:
		tile.clear_states()
	
	FE_notation.apply()
	generate_legal_moves()
	
	clear_check()
	detect_check()


static func detect_check():
	var player_king: Piece = Player.current.pieces["King"][0]
	var player_king_tile: Tile = tile_array[player_king.index]
	
	var opponent_moves: Array[Move] = generate_all_moves(get_opponent_of(Player.current))
	
	for move in opponent_moves:
		if move.destination_tile.occupant and move.destination_tile.occupant.is_in_group("King") and move.destination_tile.occupant.is_in_group(Player.current.name):
			player_king_tile._set_check()
			break


static func clear_check():
	for tile in tile_array:
		if tile.is_checked:
			tile._unset_check()


static func get_opponent_of(player: Player):
	if player == player_one:
		return player_two
	elif player == player_two:
		return player_one


static func set_en_passant(clicked_tile: Tile):
	Piece.en_passant = Piece.selected
	var en_passant_tile_rank = Tile.selected.rank + (clicked_tile.rank - Tile.selected.rank)/2
	var en_passant_tile_file = Tile.selected.file
	Tile.en_passant = tile_array[Tile.get_index(en_passant_tile_rank,en_passant_tile_file)]
	Player.en_passant = Player.current


static func clear_en_passant():
	Piece.en_passant = null
	Tile.en_passant = null


static func generate_all_moves(player: Player):
	var moves: Array[Move] = []
	for piece in player.all_pieces:
		moves.append_array(generate_moves_from_piece(piece))
	return moves


static func generate_legal_moves():
	var pseudo_legal_moves: Array[Move] = generate_all_moves(Player.current)

	for move in pseudo_legal_moves:
		var is_legal:bool = true
		move.make_virtual_move()
		
		var opponent_moves:Array[Move] = generate_all_moves(get_opponent_of(Player.current))
		for opposing_move in opponent_moves:
			if opposing_move and opposing_move.destination_tile.occupant == Player.current.pieces["King"][0]:
				is_legal = false
				break
		
		if is_legal:
			legal_moves.append(move)
		
		move.unmake_virtual_move()


static func generate_moves_from_piece(piece:Piece):
	var moveset:Movement = piece.movement
	#moveset.set_purpose_type(Movement.Purpose.GENERATE_ALL_MOVES)
	
	if moveset.distance == 0 and moveset.is_branching:
		var moves: Array[Move] = Movement.extract_moves_from_movement(piece, moveset, tile_array[piece.index])
		return moves
