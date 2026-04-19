class_name CastlingMove
extends Move

func perform_castling_move(castling_tile: TileObject) -> void:
	var middle_file_value: float = (Match.board.data.file_count/2) - 1
	var castling_rook_index: int
	var destination_index: int

	# kingside castling
	if castling_tile.data.file > middle_file_value:
		castling_rook_index = Match.get_board_index(
				castling_tile.data.rank,
				Match.board.data.file_count-1
				)

		destination_index = Match.get_board_index(
				castling_tile.data.rank,
				castling_tile.data.file-1
				)
		Match.board.perform_move(Move.new(TileObject.selected, castling_tile, Move.Outcome.CASTLING_KINGSIDE))

	# queenside castling
	elif castling_tile.data.file < middle_file_value:
		castling_rook_index = Match.get_board_index(castling_tile.data.rank,0)
		destination_index = Match.get_board_index(
				castling_tile.data.rank,
				castling_tile.data.file+1
				)
		Match.board.perform_move(Move.new(TileObject.selected, castling_tile, Move.Outcome.CASTLING_QUEENSIDE))

	var castling_rook_destination = Match.board.data.tile_array[destination_index]

	Match.board.perform_move(Move.new(Match.board.data.tile_array[castling_rook_index],castling_rook_destination,Move.Outcome.IGNORE))
