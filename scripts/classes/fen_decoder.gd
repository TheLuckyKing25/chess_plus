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
	var tile_num = 0
	var new_piece
	for character in FEN_board_position.piece_placement:
		new_piece = board.PIECE_SCENE.instantiate()
		match character:
			"p":
				new_piece.data = PiecePawn.new(board.data.player_two)
				board.data.player_two.add_piece(new_piece)
			"r":
				new_piece.data = PieceRook.new(board.data.player_two)
				board.data.player_two.add_piece(new_piece)
			"b":
				new_piece.data = PieceBishop.new(board.data.player_two)
				board.data.player_two.add_piece(new_piece)
			"n":
				new_piece.data = PieceKnight.new(board.data.player_two)
				board.data.player_two.add_piece(new_piece)
			"q":
				new_piece.data = PieceQueen.new(board.data.player_two)
				board.data.player_two.add_piece(new_piece)
			"k":
				new_piece.data = PieceKing.new(board.data.player_two)
				board.data.player_two.add_piece(new_piece)
			"P":
				new_piece.data = PiecePawn.new(board.data.player_one)
				board.data.player_one.add_piece(new_piece)
			"R":
				new_piece.data = PieceRook.new(board.data.player_one)
				board.data.player_one.add_piece(new_piece)
			"B":
				new_piece.data = PieceBishop.new(board.data.player_one)
				board.data.player_one.add_piece(new_piece)
			"N":
				new_piece.data = PieceKnight.new(board.data.player_one)
				board.data.player_one.add_piece(new_piece)
			"Q":
				new_piece.data = PieceQueen.new(board.data.player_one)
				board.data.player_one.add_piece(new_piece)
			"K":
				new_piece.data = PieceKing.new(board.data.player_one)
				board.data.player_one.add_piece(new_piece)
			"1","2","3","4","5","6","7","8","9":
				tile_num += character.to_int()
				continue
			_:
				continue
		new_piece.data.movement.set_max_distance(maxi(board.data.file_count,board.data.rank_count))
		var tile_index = tile_num%board.data.file_count + (board.data.rank_count - (tile_num/board.data.file_count)-1)*board.data.file_count
		board.data.tile_array[tile_index].add_child(new_piece,true)
		board.data.tile_array[tile_index].occupant = new_piece
		board.data.piece_location[tile_index] = new_piece
		new_piece.data.index = tile_index
		tile_num += 1

func set_active_player(board: BoardObject):
	match FEN_board_position.active_player:
		"w":
			Player.current = board.data.player_one
		"b":
			Player.current = board.data.player_two


func set_castling_availability(board: BoardObject):
	var piece_array = board.data.piece_location

	if piece_array[63] and piece_array[63].is_in_group("Rook"):
		piece_array[63].data.has_moved = true
	if piece_array[56] and piece_array[56].is_in_group("Rook"):
		piece_array[56].data.has_moved = true
	if piece_array[7] and piece_array[7].is_in_group("Rook"):
		piece_array[7].data.has_moved = true
	if piece_array[0] and piece_array[0].is_in_group("Rook"):
		piece_array[0].data.has_moved = true
	for character in FEN_board_position.castling_availability:
		match character:
			"K":
				if piece_array[7] and piece_array[7].is_in_group("Rook"):
					piece_array[7].data.has_moved = false
			"Q":
				if piece_array[0] and piece_array[0].is_in_group("Rook"):
					piece_array[0].data.has_moved = false
			"k":
				if piece_array[63] and piece_array[63].is_in_group("Rook"):
					piece_array[63].data.has_moved = false
			"q":
				if piece_array[56] and piece_array[56].is_in_group("Rook"):
					piece_array[56].data.has_moved = false


func set_en_passant_target_tile(board: BoardObject):
	if FEN_board_position.en_passant_target_tile != "-":
		TileObject.en_passant = board.tile_array[FEN_board_position.en_passant_target_tile.to_int()]
		if FEN_board_position.en_passant_target_tile.to_int() > board.rank_count * board.file_count:
			PieceObject.en_passant = board.piece_location[FEN_board_position.en_passant_target_tile.to_int()-board.file_count]
		elif FEN_board_position.en_passant_target_tile.to_int() < board.rank_count * board.file_count:
			PieceObject.en_passant = board.piece_location[FEN_board_position.en_passant_target_tile.to_int()+board.file_count]
