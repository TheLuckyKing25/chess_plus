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
		match character:
			"p":
				new_piece = PiecePawn.new(Board.player_two)
				Board.player_two.add_piece(new_piece)
			"r":
				new_piece = PieceRook.new(Board.player_two)
				Board.player_two.add_piece(new_piece)
			"b":
				new_piece = PieceBishop.new(Board.player_two)
				Board.player_two.add_piece(new_piece)
			"n":
				new_piece = PieceKnight.new(Board.player_two)
				Board.player_two.add_piece(new_piece)
			"q":
				new_piece = PieceQueen.new(Board.player_two)
				Board.player_two.add_piece(new_piece)
			"k":
				new_piece = PieceKing.new(Board.player_two)
				Board.player_two.add_piece(new_piece)
			"P":
				new_piece = PiecePawn.new(Board.player_one)
				Board.player_one.add_piece(new_piece)
			"R":
				new_piece = PieceRook.new(Board.player_one)
				Board.player_one.add_piece(new_piece)
			"B":
				new_piece = PieceBishop.new(Board.player_one)
				Board.player_one.add_piece(new_piece)
			"N":
				new_piece = PieceKnight.new(Board.player_one)
				Board.player_one.add_piece(new_piece)
			"Q":
				new_piece = PieceQueen.new(Board.player_one)
				Board.player_one.add_piece(new_piece)
			"K":
				new_piece = PieceKing.new(Board.player_one)
				Board.player_one.add_piece(new_piece)
			"1","2","3","4","5","6","7","8","9":
				tile_num += character.to_int()
				continue
			_:
				continue
		new_piece.controller = BoardController.PIECE_SCENE.instantiate()
		new_piece.movement.set_max_distance(maxi(Board.file_count,Board.rank_count))
		var tile_index = tile_num%Board.file_count + (Board.rank_count - (tile_num/Board.file_count)-1)*Board.file_count
		Board.tile_array[tile_index].controller.add_child(new_piece.controller,true)
		Board.tile_array[tile_index].occupant = new_piece
		Board.piece_location[tile_index] = new_piece
		tile_num += 1


func set_active_player():
	match active_player:
		"w":
			Player.current = Board.player_one
		"b":
			Player.current = Board.player_two


func set_castling_availability():
	if Board.piece_location[63] and Board.piece_location[63].controller.is_in_group("Rook"):
		Board.piece_location[63].has_moved = true
	if Board.piece_location[56] and Board.piece_location[56].controller.is_in_group("Rook"):
		Board.piece_location[56].has_moved = true
	if Board.piece_location[7] and Board.piece_location[7].controller.is_in_group("Rook"):
		Board.piece_location[7].has_moved = true
	if Board.piece_location[0] and Board.piece_location[0].controller.is_in_group("Rook"):
		Board.piece_location[0].has_moved = true
	for character in castling_availability:
		match character:
			"K":
				if Board.piece_location[7] and Board.piece_location[7].controller.is_in_group("Rook"):
					Board.piece_location[7].has_moved = false
			"Q":
				if Board.piece_location[0] and Board.piece_location[0].controller.is_in_group("Rook"):
					Board.piece_location[0].has_moved = false
			"k":
				if Board.piece_location[63] and Board.piece_location[63].controller.is_in_group("Rook"):
					Board.piece_location[63].has_moved = false
			"q":
				if Board.piece_location[56] and Board.piece_location[56].controller.is_in_group("Rook"):
					Board.piece_location[56].has_moved = false


func set_en_passant_target_tile():
	if en_passant_target_tile != "-":
		Tile.en_passant = Board.tile_array[en_passant_target_tile.to_int()]
		if en_passant_target_tile.to_int() > Board.rank_count * Board.file_count:
			Piece.en_passant = Board.piece_location[en_passant_target_tile.to_int()-Board.file_count]
		elif en_passant_target_tile.to_int() < Board.rank_count * Board.file_count:
			Piece.en_passant = Board.piece_location[en_passant_target_tile.to_int()+Board.file_count]
