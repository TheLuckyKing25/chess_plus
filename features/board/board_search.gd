class_name BoardSearch

var pseudo_legal_moves: Dictionary[PieceObject,Dictionary] = {}

func _find_moves_of_piece(board_data: BoardObject, piece:PieceObject) -> Dictionary[TileObject,StringName]:
	var movement: Dictionary[TileObject,StringName] = {}
	var starting_tile: TileObject = board_data.tile_grid.get_tile_at_position(piece.position_vector)
	movement = piece.movement_component.movement.generate_movement_map(starting_tile, board_data, piece)
	piece.movement_component.reset_movement()
	return movement


func generate_pseudo_legal_moves(board_data: BoardObject):
	var destinations: Dictionary[PieceObject,Dictionary] = {}

	var selectable_pieces: Array = board_data.valid_selections.filter(
		func(item:Object) -> bool: return (item is PieceObject)
	)

	for piece:PieceObject in selectable_pieces:
		var valid_moves_of_piece: Dictionary[TileObject,StringName] = _find_moves_of_piece(board_data, piece)
		destinations.set(piece, valid_moves_of_piece)

	pseudo_legal_moves = destinations
	#_filter_legal_moves(board_data)


func _filter_legal_moves(board_data:BoardObject) -> void:
	var move_list: Array = []
	for piece:PieceObject in pseudo_legal_moves.keys():
		var occupied_tile: TileObject = board_data.tile_grid.find_tile_occupied_by(piece)
		for tile:TileObject in pseudo_legal_moves.get(piece):
			var constructed_move:BoardChange = board_data.construct_move(occupied_tile,tile)
			move_list.append(constructed_move.change_data)
	#Debug.Printer.print_pretty_json("Legal Moves",move_list)


static func search(board_data: BoardObject, depth:int = 1):
	var board_search: BoardSearch = BoardSearch.new()
	board_search.generate_pseudo_legal_moves(board_data)
	return board_search.pseudo_legal_moves
