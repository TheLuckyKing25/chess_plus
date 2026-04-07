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
	Match.player_one.pieces = {}
	Match.player_two.pieces = {}
	var max_distance: int = maxi(Match.board_data.file_count,Match.board_data.rank_count)
	var tile_num:int = 0
	var new_piece: PieceObject
	for character in FEN_board_position.piece_placement:
		var tile_index = tile_num%Match.board_data.file_count + (Match.board_data.rank_count - (tile_num/Match.board_data.file_count)-1)*Match.board_data.file_count
		match character:
			"p":
				new_piece = PieceObject.new_piece(preload("uid://dn8nakb8feeww"),Match.player_two, max_distance, tile_index)
			"r":
				new_piece = PieceObject.new_piece(preload("uid://b5r63cf4oeak3"),Match.player_two, max_distance, tile_index)
			"b":
				new_piece = PieceObject.new_piece(preload("uid://b12vykyoafcox"),Match.player_two, max_distance, tile_index)
			"n":
				new_piece = PieceObject.new_piece(preload("uid://brd0i5dnuyf6l"),Match.player_two, max_distance, tile_index)
			"q":
				new_piece = PieceObject.new_piece(preload("uid://bccbxx63wac0s"),Match.player_two, max_distance, tile_index)
			"k":
				new_piece = PieceObject.new_piece(preload("uid://qs2xxm48mer5"),Match.player_two, max_distance, tile_index)
			"P":
				new_piece = PieceObject.new_piece(preload("uid://dn8nakb8feeww"),Match.player_one, max_distance, tile_index)
			"R":
				new_piece = PieceObject.new_piece(preload("uid://b5r63cf4oeak3"),Match.player_one, max_distance, tile_index)
			"B":
				new_piece = PieceObject.new_piece(preload("uid://b12vykyoafcox"),Match.player_one, max_distance, tile_index)
			"N":
				new_piece = PieceObject.new_piece(preload("uid://brd0i5dnuyf6l"),Match.player_one, max_distance, tile_index)
			"Q":
				new_piece = PieceObject.new_piece(preload("uid://bccbxx63wac0s"),Match.player_one, max_distance, tile_index)
			"K":
				new_piece = PieceObject.new_piece(preload("uid://qs2xxm48mer5"),Match.player_one, max_distance, tile_index)
			"1","2","3","4","5","6","7","8","9":
				tile_num += character.to_int()
				continue
			_:
				continue
		Match.board_data.tile_array[tile_index].add_child(new_piece,true)
		Match.board_data.tile_array[tile_index].occupant = new_piece
		Match.board_data.piece_array[tile_index] = new_piece
		tile_num += 1

func set_active_player():
	match FEN_board_position.active_player:
		"w":
			Player.current = Match.player_one
		"b":
			Player.current = Match.player_two


func set_castling_availability():
	Match.player_one.pieces["King"][0].data.set_meta("is_castling_kingside_valid", false)
	Match.player_one.pieces["King"][0].data.set_meta("is_castling_queenside_valid", false)
	Match.player_two.pieces["King"][0].data.set_meta("is_castling_kingside_valid", false)
	Match.player_two.pieces["King"][0].data.set_meta("is_castling_queenside_valid", false)
	for character in FEN_board_position.castling_availability:
		match character:
			"K":
				Match.player_one.pieces["King"][0].data.set_meta("is_castling_kingside_valid", true)
			"Q":
				Match.player_one.pieces["King"][0].data.set_meta("is_castling_queenside_valid", true)
			"k":
				Match.player_two.pieces["King"][0].data.set_meta("is_castling_kingside_valid", true)
			"q":
				Match.player_two.pieces["King"][0].data.set_meta("is_castling_queenside_valid", true)


func set_en_passant_target_tile():
	if FEN_board_position.en_passant_target_tile != "-":
		TileObject.en_passant = Match.board_object.tile_array[FEN_board_position.en_passant_target_tile.to_int()]
		if FEN_board_position.en_passant_target_tile.to_int() > Match.board_object.rank_count * Match.board_object.file_count:
			PieceObject.en_passant = Match.board_object.piece_array[FEN_board_position.en_passant_target_tile.to_int()-Match.board_object.file_count]
		elif FEN_board_position.en_passant_target_tile.to_int() < Match.board_object.rank_count * Match.board_object.file_count:
			PieceObject.en_passant = Match.board_object.piece_array[FEN_board_position.en_passant_target_tile.to_int()+Match.board_object.file_count]
