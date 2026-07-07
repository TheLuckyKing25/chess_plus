class_name BoardSearch
extends Resource

func search(board_data: BoardData, depth:int = 1):
	DebugPrinter.print_pretty(board_data.valid_destinations)
	var player_pieces: Array[PieceData] = board_data.valid_destinations.keys()
	for piece:PieceData in player_pieces:
		DebugPrinter.print_pretty(piece)
		var position_vector: Vector2i = piece.position_vector
		for destiniation_tile in board_data.valid_destinations.get(piece).keys():
			var board: BoardData = board_data.duplicate_deep()
			var board_rep:Dictionary = board.board_representation
			var starting_tile:TileDataChess = board_rep.get(position_vector).get(BoardData.TILE_DATA_INDEX)
			board.process_change(starting_tile,destiniation_tile)
			DebugPrinter.print_pretty(board.valid_destinations, false)
