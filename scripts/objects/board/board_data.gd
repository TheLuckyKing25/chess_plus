# this is a state of a board.
# should be seperate from the Board Object
class_name BoardData
extends Resource


signal player_to_move_changed(new_player_data: PlayerData)
signal board_representation_changed()


enum {
	TILE_DATA = 0,
	PIECE_DATA = 1
	}


var rank_count: int = GameData.match_settings.board_size.rank
var file_count: int = GameData.match_settings.board_size.file


var max_length: int:
	get: return maxi(file_count,rank_count)


@export_custom(
		PROPERTY_HINT_NONE,
		"",
		PROPERTY_USAGE_NEVER_DUPLICATE
	) var assigned_object: BoardObject


var tiles: Array[TileDataChess] = []
var pieces: Array[PieceData] = []


var valid_selections: Array = []
var valid_destinations: Dictionary[PieceData,Dictionary] = {
	#PieceData: {TileData: ObjectStateComponent.Type, ...}
}


var fen:FEN = FEN.new("rnbqkbnr/pppppppp/8/7B/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")


#region Data
var board_representation: Dictionary[Vector2i, Array] = {
	# Vector2i: [TileData, PieceData],
}:
	set(value):
		board_representation = value
		board_representation_changed.emit()


var player_to_move: PlayerData:
	set(value):
		player_to_move_changed.emit(value)
		player_to_move = value


var castling_rights: Dictionary = {
	"white": {
		"kingside": true,
		"queenside": true,
	},
	"black": {
		"kingside": true,
		"queenside": true,
	},
}


# Defines the Tile a pawn must land on to capture Piece.
# Piece is not on Tile.
var en_passant: Dictionary = {
	"tile": null,
	"piece": null
}


var halfmove_clock: int = 0


var fullmove_counter: int = 0
#endregion

# This is not run through the _init function because there are some cases where
# we do not want to generate new tiles when creating a new board.
static func create_board(ranks:int = 8, files:int = 8) -> BoardData:
	var board:BoardData = BoardData.new(ranks,files)

	if board.board_representation.is_empty():
		board._generate_position_vectors()
		board._generate_tile_data()

	board._assign_tile_neighbors()
	board._generate_pieces()
	board._set_player_to_move()

	return board


func _init(ranks:int = 8, files:int = 8) -> void:
	rank_count = ranks
	file_count = files

	GameData.players.white.data.promotion_rank = rank_count - 1
	GameData.players.black.data.promotion_rank = 0

	player_to_move_changed.connect(_on_player_to_move_changed)


func _generate_position_vectors() -> void:
	for index in range(rank_count*file_count):
		board_representation.set(Vector2i(index/file_count, index%file_count),[])


func _generate_tile_data() -> void:
	for index in range(rank_count*file_count):
		var new_tile: TileDataChess = TileDataChess.new()
		tiles.append(new_tile)

		var position_vector: Vector2i = Vector2i(index/file_count, index%file_count)
		new_tile.set_position_data(index,position_vector)
		board_representation.set(position_vector, [new_tile,null])

		new_tile.resource_name = "Tile " + new_tile.algebraic_notation


func _assign_tile_neighbors() -> void:
	for tile:TileDataChess in tiles:
		for direction:Constants.Direction in range(0,8):
			var neighbor_position: Vector2i = (
					tile.position_vector
					+ Constants.DIRECTION_VECTOR.get(direction)
				)

			if _is_out_of_bounds(neighbor_position):
				tile.neighbors.set(direction, null)
				continue

			tile.neighbors.set(direction, board_representation.get(neighbor_position).get(TILE_DATA))


func _is_out_of_bounds(postition: Vector2i) -> bool:
	return (
			postition.x > rank_count-1
			or postition.y > file_count-1
			or postition.x < 0
			or postition.y < 0
		)


func _generate_pieces() -> void:
	var tile_count: int = 0
	var new_piece: PieceData
	var piece_config_lookup: Dictionary[String, String] = {
		"p": Constants.piece_config.get(Constants.TypePiece.PAWN),
		"r": Constants.piece_config.get(Constants.TypePiece.ROOK),
		"b": Constants.piece_config.get(Constants.TypePiece.BISHOP),
		"n": Constants.piece_config.get(Constants.TypePiece.KNIGHT),
		"q": Constants.piece_config.get(Constants.TypePiece.QUEEN),
		"k": Constants.piece_config.get(Constants.TypePiece.KING),
	}

	for character:String in fen.piece_placement:
		var tile_index: int = tile_count%file_count + (rank_count - (tile_count/file_count)-1)*file_count
		var new_piece_func: Callable = PieceData.new_piece.bind(max_length, tile_index)
		var piece_config_uid: String = ""
		match character.to_lower():
			"p","r","b","n","q","k":
				piece_config_uid = piece_config_lookup.get(character.to_lower())
				new_piece = new_piece_func.call(load(piece_config_uid))
			"1","2","3","4","5","6","7","8","9":
				tile_count += character.to_int()
				continue
			_:
				continue

		match character:
			"p","r","b","n","q","k":
				new_piece.assign_player("black")
			"P","R","B","N","Q","K":
				new_piece.assign_player("white")

		# ADD ERROR DETECTION FOR IF POSITION VECTOR DOES NOT EXIST
		var position_vector: Vector2i = Vector2i(tile_index/file_count, tile_index%file_count)
		var board_rep_position = board_representation.get(position_vector)
		board_rep_position[PIECE_DATA] = new_piece
		pieces.append(new_piece)
		board_rep_position[TILE_DATA].occupant = new_piece
		new_piece.position_vector = position_vector

		tile_count += 1


func _set_player_to_move() -> void:
	match fen.active_player:
		"w": player_to_move = GameData.players.white.data
		"b": player_to_move = GameData.players.black.data


func _on_player_to_move_changed(new_player_data:PlayerData) -> void:
	valid_selections.clear()
	_find_all_valid_selections(new_player_data)

	valid_destinations.clear()
	_find_all_valid_destinations()


func _find_all_valid_selections(new_player_data:PlayerData) -> void:
	var piece_filter:Callable = func(piece: PieceData): if piece.player == new_player_data: return piece
	var selectable_piece_objects:Array[PieceData] = pieces.filter(piece_filter)
	valid_selections.append_array(selectable_piece_objects)

	var tile_filter:Callable = func(tile: TileDataChess): if selectable_piece_objects.has(tile.occupant): return tile
	var selectable_tile_object: Array[TileDataChess] = tiles.filter(tile_filter)
	valid_selections.append_array(selectable_tile_object)


func _find_all_valid_destinations() -> void:
	var destinations: Dictionary[PieceData,Dictionary] = {}

	var selectable_pieces: Array = valid_selections.filter(
			func(item): return true if item is PieceData else false
		)
	#DebugPrinter.print_pretty(selectable_pieces)
	for piece in selectable_pieces:
		destinations.set(piece,_find_movement_of_piece(piece))

	#filter out moves

	#DebugPrinter.print_pretty(destinations)
	valid_destinations = destinations


func _find_movement_of_piece(piece:PieceData) -> Dictionary[TileDataChess,ObjectStateComponent.Type]:
	var movement: Dictionary[TileDataChess,ObjectStateComponent.Type] = {}
	var starting_tile: TileDataChess = board_representation.get(piece.position_vector).get(TILE_DATA)
	movement = piece.current_movement.apply_movement(starting_tile, self)
	piece.reset_current_movement()
	return movement


func process_move(from: TileDataChess, to: TileDataChess) -> void:
	var new_change: BoardChange = BoardChange.new()

	var move: Dictionary = {
		to.position_vector: [to, from.occupant],
		from.position_vector: [from, null],
	}

	new_change.add_change("board_representation", move)
	new_change.add_change("player_to_move", GameData.opponent(player_to_move))
	if is_instance_valid(to.occupant):
		new_change.add_change("captured", [to.occupant])

	# check Game Rules and add changes to BoardChange.

	BoardChange.apply_change(new_change,self)

	var new_changes: Array[BoardChange] = []
	for piece:PieceData in pieces:
		new_changes.append(piece.evaluate_rules())
	var new_changes_filtered: Array[BoardChange] = new_changes.filter(
			func(item): return is_instance_valid(item)
		)
	#DebugPrinter.print_pretty(new_changes_filtered)
	BoardChange.apply_change(BoardChange.merge_changes(new_changes_filtered,true),self)






# ===============================================================================
# ============================== [END OF REFACTOR] ==============================
# ===============================================================================



var tile_array: Array[TileObject] = []
var piece_array: Array[PieceObject] = []

var legal_moves: MoveList


var FEN_board_state: FEN


func _get_from_vector(vector: Vector2i) -> Dictionary:
	return board_representation.get(vector)


func find_tile_using_vector(vector: Vector2i) -> TileObject:
	for tile in tile_array:
		if tile.data.position_vector == vector:
			return tile

	return null # tile not found
