# decodes Forsyth–Edwards Notation and generates a board state
class_name FENDecoder
extends RefCounted

var FEN_board_position: FEN


func _init(FEN_board_position:FEN):
	self.FEN_board_position = FEN_board_position


func apply():
	place_pieces()
	set_active_player()
	set_castling_availability()
	set_en_passant_target_tile()


func place_pieces():
	GameController.player.white.pieces = {}
	GameController.player.black.pieces = {}
	var max_distance: int = maxi( Match.board.data.file_count,Match.board.data.rank_count)
	var tile_num:int = 0
	var new_piece: PieceObject
	for character in FEN_board_position.piece_placement:
		var tile_index = tile_num% Match.board.data.file_count + (Match.board.data.rank_count - (tile_num/Match.board.data.file_count)-1)*Match.board.data.file_count
		match character:
			"p":
				new_piece = PieceObject.new_piece(preload("uid://dn8nakb8feeww"),GameController.player.black, max_distance, tile_index)
			"r":
				new_piece = PieceObject.new_piece(preload("uid://b5r63cf4oeak3"),GameController.player.black, max_distance, tile_index)
			"b":
				new_piece = PieceObject.new_piece(preload("uid://b12vykyoafcox"),GameController.player.black, max_distance, tile_index)
			"n":
				new_piece = PieceObject.new_piece(preload("uid://brd0i5dnuyf6l"),GameController.player.black, max_distance, tile_index)
			"q":
				new_piece = PieceObject.new_piece(preload("uid://bccbxx63wac0s"),GameController.player.black, max_distance, tile_index)
			"k":
				new_piece = PieceObject.new_piece(preload("uid://qs2xxm48mer5"),GameController.player.black, max_distance, tile_index)
			"P":
				new_piece = PieceObject.new_piece(preload("uid://dn8nakb8feeww"),GameController.player.white, max_distance, tile_index)
			"R":
				new_piece = PieceObject.new_piece(preload("uid://b5r63cf4oeak3"),GameController.player.white, max_distance, tile_index)
			"B":
				new_piece = PieceObject.new_piece(preload("uid://b12vykyoafcox"),GameController.player.white, max_distance, tile_index)
			"N":
				new_piece = PieceObject.new_piece(preload("uid://brd0i5dnuyf6l"),GameController.player.white, max_distance, tile_index)
			"Q":
				new_piece = PieceObject.new_piece(preload("uid://bccbxx63wac0s"),GameController.player.white, max_distance, tile_index)
			"K":
				new_piece = PieceObject.new_piece(preload("uid://qs2xxm48mer5"),GameController.player.white, max_distance, tile_index)
			"1","2","3","4","5","6","7","8","9":
				tile_num += character.to_int()
				continue
			_:
				continue
		Match.board.data.tile_array[tile_index].add_child(new_piece,true)
		Match.board.data.tile_array[tile_index].occupant = new_piece
		Match.board.data.piece_array[tile_index] = new_piece
		tile_num += 1

func set_active_player():
	match FEN_board_position.active_player:
		"w":
			Player.current = GameController.player.white
		"b":
			Player.current = GameController.player.black


func set_castling_availability():
	GameController.player.white.pieces["King"][0].data.set_meta("is_castling_kingside_valid", false)
	GameController.player.white.pieces["King"][0].data.set_meta("is_castling_queenside_valid", false)
	GameController.player.black.pieces["King"][0].data.set_meta("is_castling_kingside_valid", false)
	GameController.player.black.pieces["King"][0].data.set_meta("is_castling_queenside_valid", false)
	for character in FEN_board_position.castling_availability:
		match character:
			"K":
				GameController.player.white.pieces["King"][0].data.set_meta("is_castling_kingside_valid", true)
			"Q":
				GameController.player.white.pieces["King"][0].data.set_meta("is_castling_queenside_valid", true)
			"k":
				GameController.player.black.pieces["King"][0].data.set_meta("is_castling_kingside_valid", true)
			"q":
				GameController.player.black.pieces["King"][0].data.set_meta("is_castling_queenside_valid", true)


func set_en_passant_target_tile():
	if FEN_board_position.en_passant_target_tile != "-":
		TileObject.en_passant = Match.board_object.tile_array[FEN_board_position.en_passant_target_tile.to_int()]
		if FEN_board_position.en_passant_target_tile.to_int() > Match.board_object.rank_count * Match.board_object.file_count:
			PieceObject.en_passant = Match.board_object.piece_array[FEN_board_position.en_passant_target_tile.to_int()-Match.board_object.file_count]
		elif FEN_board_position.en_passant_target_tile.to_int() < Match.board_object.rank_count * Match.board_object.file_count:
			PieceObject.en_passant = Match.board_object.piece_array[FEN_board_position.en_passant_target_tile.to_int()+Match.board_object.file_count]
