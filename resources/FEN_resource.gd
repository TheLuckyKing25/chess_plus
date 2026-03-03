class_name FEN
extends Resource


var FE_notation: String


var piece_placement: String:
	get(): return FE_notation.split(" ")[0]
	
	
var active_player: String:
	get(): return FE_notation.split(" ")[1]
	
	
var castling_availability: String:
	get(): return FE_notation.split(" ")[2]
	
	
var en_passant_target_tile: String:
	get(): return FE_notation.split(" ")[3]
	
	
var halfmove_clock: String:
	get(): return FE_notation.split(" ")[4]
	
	
var fullmove_number: String:
	get(): return FE_notation.split(" ")[5]
	

func _init(layout:String):
	FE_notation = layout 


func apply():
	place_pieces()
	set_active_player()
	set_castling_availability()
	set_en_passant_target_tile()

func place_pieces():
	var tile_num = 0
	var new_piece
	for character in piece_placement:
		new_piece = BoardController.PIECE_SCENE.instantiate()
		match character:
			"p":
				new_piece.stats = PiecePawn.new(Board.player_two)
				Board.player_two.add_piece(new_piece)
			"r":
				new_piece.stats = PieceRook.new(Board.player_two)
				Board.player_two.add_piece(new_piece)
			"b":
				new_piece.stats = PieceBishop.new(Board.stats.player_two)
				Board.stats.player_two.add_piece(new_piece)
			"n":
				new_piece.stats = PieceKnight.new(Board.stats.player_two)
				Board.stats.player_two.add_piece(new_piece)
			"q":
				new_piece.stats = PieceQueen.new(Board.stats.player_two)
				Board.stats.player_two.add_piece(new_piece)
			"k":
				new_piece.stats = PieceKing.new(Board.stats.player_two)
				Board.stats.player_two.add_piece(new_piece)
			"P":
				new_piece.stats = PiecePawn.new(Board.stats.player_one)
				Board.stats.player_one.add_piece(new_piece)
			"R":
				new_piece.stats = PieceRook.new(Board.stats.player_one)
				Board.stats.player_one.add_piece(new_piece)
			"B":
				new_piece.stats = PieceBishop.new(Board.stats.player_one)
				Board.stats.player_one.add_piece(new_piece)
			"N":
				new_piece.stats = PieceKnight.new(Board.stats.player_one)
				Board.stats.player_one.add_piece(new_piece)
			"Q":
				new_piece.stats = PieceQueen.new(Board.stats.player_one)
				Board.stats.player_one.add_piece(new_piece)
			"K":
				new_piece.stats = PieceKing.new(Board.stats.player_one)
				Board.stats.player_one.add_piece(new_piece)
			"1","2","3","4","5","6","7","8","9":
				tile_num += character.to_int()
				continue
			_:
				continue
		new_piece.stats.movement.set_max_distance(maxi(Board.stats.file_count,Board.stats.rank_count))
		var tile_index = tile_num%Board.stats.file_count + (Board.stats.rank_count - (tile_num/Board.stats.file_count)-1)*Board.stats.file_count
		Board.stats.tile_array[tile_index].add_child(new_piece,true)
		Board.stats.tile_array[tile_index].occupant = new_piece
		Board.stats.piece_location[tile_index] = new_piece
		tile_num += 1


func set_active_player():
	match active_player:
		"w":
			Player.current = Board.stats.player_one
		"b":
			Player.current = Board.stats.player_two



func set_castling_availability():
	if Board.stats.piece_location[63] and Board.stats.piece_location[63].is_in_group(PieceRook.name):
		Board.stats.piece_location[63].stats.has_moved = true
	if Board.stats.piece_location[56] and Board.stats.piece_location[56].is_in_group(PieceRook.name):
		Board.stats.piece_location[56].stats.has_moved = true
	if Board.stats.piece_location[7] and Board.stats.piece_location[7].is_in_group(PieceRook.name):
		Board.stats.piece_location[7].stats.has_moved = true
	if Board.stats.piece_location[0] and Board.stats.piece_location[0].is_in_group(PieceRook.name):
		Board.stats.piece_location[0].stats.has_moved = true
	for character in castling_availability:
		match character:
			"K":
				if Board.stats.piece_location[7] and Board.stats.piece_location[7].is_in_group(PieceRook.name):
					Board.stats.piece_location[7].stats.has_moved = false
			"Q":
				if Board.stats.piece_location[0] and Board.stats.piece_location[0].is_in_group(PieceRook.name):
					Board.stats.piece_location[0].stats.has_moved = false
			"k":
				if Board.stats.piece_location[63] and Board.stats.piece_location[63].is_in_group(PieceRook.name):
					Board.stats.piece_location[63].stats.has_moved = false
			"q":
				if Board.stats.piece_location[56] and Board.stats.piece_location[56].is_in_group(PieceRook.name):
					Board.stats.piece_location[56].stats.has_moved = false

func set_en_passant_target_tile():
	if en_passant_target_tile != "-":
		Tile.en_passant = Board.stats.tile_array[en_passant_target_tile.to_int()]
		if en_passant_target_tile.to_int() > Board.stats.rank_count * Board.stats.file_count:
			Piece.en_passant = Board.stats.piece_location[en_passant_target_tile.to_int()-Board.stats.file_count]
		elif en_passant_target_tile.to_int() < Board.stats.rank_count * Board.stats.file_count:
			Piece.en_passant = Board.stats.piece_location[en_passant_target_tile.to_int()+Board.stats.file_count]
