# decodes Forsyth–Edwards Notation and generates a board state
class_name FENDecoder


var FEN_board_position: FEN


func _init(FEN_board_position:FEN):
	self.FEN_board_position = FEN_board_position


func apply(board: BoardObject):
	place_pieces(board)
	set_active_player(board)
	set_castling_availability(board)
	set_en_passant_target_tile(board)


func place_pieces(board: BoardObject):
	board.data.player_one.pieces = {}
	board.data.player_two.pieces = {}
	var max_distance: int = maxi(board.data.file_count,board.data.rank_count)
	var tile_num = 0
	var new_piece
	for character in FEN_board_position.piece_placement:
		var tile_index = tile_num%board.data.file_count + (board.data.rank_count - (tile_num/board.data.file_count)-1)*board.data.file_count
		match character:
			"p":
				new_piece = PieceObject.new_piece(preload("uid://dn8nakb8feeww"),board.data.player_two, max_distance, tile_index)
			"r":
				new_piece = PieceObject.new_piece(preload("uid://b5r63cf4oeak3"),board.data.player_two, max_distance, tile_index)
			"b":
				new_piece = PieceObject.new_piece(preload("uid://b12vykyoafcox"),board.data.player_two, max_distance, tile_index)
			"n":
				new_piece = PieceObject.new_piece(preload("uid://brd0i5dnuyf6l"),board.data.player_two, max_distance, tile_index)
			"q":
				new_piece = PieceObject.new_piece(preload("uid://bccbxx63wac0s"),board.data.player_two, max_distance, tile_index)
			"k":
				new_piece = PieceObject.new_piece(preload("uid://qs2xxm48mer5"),board.data.player_two, max_distance, tile_index)
			"P":
				new_piece = PieceObject.new_piece(preload("uid://dn8nakb8feeww"),board.data.player_one, max_distance, tile_index)
			"R":
				new_piece = PieceObject.new_piece(preload("uid://b5r63cf4oeak3"),board.data.player_one, max_distance, tile_index)
			"B":
				new_piece = PieceObject.new_piece(preload("uid://b12vykyoafcox"),board.data.player_one, max_distance, tile_index)
			"N":
				new_piece = PieceObject.new_piece(preload("uid://brd0i5dnuyf6l"),board.data.player_one, max_distance, tile_index)
			"Q":
				new_piece = PieceObject.new_piece(preload("uid://bccbxx63wac0s"),board.data.player_one, max_distance, tile_index)
			"K":
				new_piece = PieceObject.new_piece(preload("uid://qs2xxm48mer5"),board.data.player_one, max_distance, tile_index)
			"1","2","3","4","5","6","7","8","9":
				tile_num += character.to_int()
				continue
			_:
				continue
		board.data.tile_array[tile_index].add_child(new_piece,true)
		board.data.tile_array[tile_index].occupant = new_piece
		board.data.piece_array[tile_index] = new_piece
		tile_num += 1

func set_active_player(board: BoardObject):
	match FEN_board_position.active_player:
		"w":
			Player.current = board.data.player_one
		"b":
			Player.current = board.data.player_two


func set_castling_availability(board: BoardObject):
	board.data.player_one.pieces["King"][0].data.set_meta("is_castling_kingside_valid", false)
	board.data.player_one.pieces["King"][0].data.set_meta("is_castling_queenside_valid", false)
	board.data.player_two.pieces["King"][0].data.set_meta("is_castling_kingside_valid", false)
	board.data.player_two.pieces["King"][0].data.set_meta("is_castling_queenside_valid", false)
	for character in FEN_board_position.castling_availability:
		match character:
			"K":
				board.data.player_one.pieces["King"][0].data.set_meta("is_castling_kingside_valid", true)
			"Q":
				board.data.player_one.pieces["King"][0].data.set_meta("is_castling_queenside_valid", true)
			"k":
				board.data.player_two.pieces["King"][0].data.set_meta("is_castling_kingside_valid", true)
			"q":
				board.data.player_two.pieces["King"][0].data.set_meta("is_castling_queenside_valid", true)


func set_en_passant_target_tile(board: BoardObject):
	if FEN_board_position.en_passant_target_tile != "-":
		TileObject.en_passant = board.tile_array[FEN_board_position.en_passant_target_tile.to_int()]
		if FEN_board_position.en_passant_target_tile.to_int() > board.rank_count * board.file_count:
			PieceObject.en_passant = board.piece_array[FEN_board_position.en_passant_target_tile.to_int()-board.file_count]
		elif FEN_board_position.en_passant_target_tile.to_int() < board.rank_count * board.file_count:
			PieceObject.en_passant = board.piece_array[FEN_board_position.en_passant_target_tile.to_int()+board.file_count]
