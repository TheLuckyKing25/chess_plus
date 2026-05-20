# this is a state of a board.
# should be seperate from the Board Object
class_name BoardData
extends Resource

enum {
	TILE_DATA = 0,
	PIECE_DATA = 1,
}


var rank_count: int = GameData.match_settings.board_size.rank
var file_count: int = GameData.match_settings.board_size.file


var max_length: int:
	get:
		return maxi(file_count,rank_count)


var assigned_object: BoardObject


#region FEN Data
var board_representation: Dictionary[Vector2i, Dictionary] = {
	# vector: {TILE_DATA: TileData, PIECE_DATA: PieceData},
}


var tiles: Array[TileDataChess] = []


var pieces: Array[PieceData] = []


var player_to_move: Player


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

	return board


func _init(ranks:int = 8, files:int = 8) -> void:
	GameData.player.white.promotion_rank = rank_count - 1
	GameData.player.black.promotion_rank = 0
	rank_count = ranks
	file_count = files


func _generate_position_vectors() -> void:
	for index in range(rank_count*file_count):
		board_representation.set(Vector2i(index/file_count, index%file_count),{})


func _generate_tile_data() -> void:
	for index in range(rank_count*file_count):
		var new_tile = TileDataChess.new()
		var position_vector = Vector2i(index/file_count, index%file_count)
		tiles.append(new_tile)
		new_tile.set_position_data(index,position_vector)
		board_representation[position_vector][TILE_DATA] = new_tile
		new_tile.resource_name = "Tile " + new_tile.algebraic_notation


func _assign_tile_neighbors() -> void:
	for tile:TileDataChess in tiles:
		for direction:Constants.Direction in range(0,8):
			var neighbor_position: Vector2i = (
					tile.board_position
					+ Constants.direction_vector[direction]
				)

			if (
					neighbor_position.x > rank_count-1
					or neighbor_position.y > file_count-1
					or neighbor_position.x < 0
					or neighbor_position.y < 0
				):
				tile.neighbors[direction] = null
				continue

			tile.neighbors[direction] = board_representation.get(neighbor_position).get(TILE_DATA)


func _get_from_vector(vector: Vector2i) -> Dictionary:
	return board_representation.get(vector)


func _generate_pieces():
	var piece_placement: Dictionary[int,PieceData]

	var tile_num:int = 0
	var new_piece: PieceData
	var fen:FEN = FEN.new("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")

	for character:String in fen.piece_placement:
		var tile_index = tile_num%file_count + (rank_count - (tile_num/file_count)-1)*file_count

		var position_vector = Vector2i(tile_index/file_count, tile_index%file_count)
		match character.to_lower():
			"p":
				new_piece = PieceData.new_piece(load("uid://bih6lr0cwxuk"), max_length, tile_index)
			"r":
				new_piece = PieceData.new_piece(load("uid://csqiux6uupcb2"), max_length, tile_index)
			"b":
				new_piece = PieceData.new_piece(load("uid://b7mqdwuvfi3nh"), max_length, tile_index)
			"n":
				new_piece = PieceData.new_piece(load("uid://cgvt2kihfm4em"), max_length, tile_index)
			"q":
				new_piece = PieceData.new_piece(load("uid://oqdygo3fdmd2"), max_length, tile_index)
			"k":
				new_piece = PieceData.new_piece(load("uid://bfy5ow4fdbo1l"), max_length, tile_index)
			"1","2","3","4","5","6","7","8","9":
				tile_num += character.to_int()
				continue
			_:
				continue
		#new_piece.base_movement.set_max_distance(max_length)
		match character:
			"p","r","b","n","q","k":
				new_piece.assign_player("black")
			"P","R","B","N","Q","K":
				new_piece.assign_player("white")

		# ADD ERROR DETECTION FOR IF POSITION VECTOR DOES NOT EXIST
		var board_rep_position = board_representation.get(position_vector,{})
		board_rep_position.set(PIECE_DATA,new_piece)
		pieces.append(board_rep_position.get(PIECE_DATA))
		board_rep_position.get(TILE_DATA,{}).occupant = new_piece
		new_piece.board_position = position_vector

		tile_num += 1

	for tile in tiles:
		if tile.index in piece_placement.keys():
			board_representation.set(tile,piece_placement[tile.index])











var tile_array: Array[TileObject] = []
var piece_array: Array[PieceObject] = []

var legal_moves: MoveList


var FEN_board_state: FEN


func find_tile_using_vector(vector: Vector2i) -> TileObject:
	for tile in tile_array:
		if tile.data.board_position == vector:
			return tile

	return null # tile not found

func assign_tile_neighbors():
	for tile in tile_array:
		for direction in range(0,8):
			direction = direction as Constants.Direction
			var next_tile_position: Vector2i = (
					tile.data.board_position
					+ Constants.direction_vector[direction]
					)

			if (	next_tile_position > Vector2i(rank_count-1,file_count-1)
					or next_tile_position < Vector2i(0,0)
					):
				tile.neighbors[direction] = null
				continue

			tile.neighbors[direction] = tile_array[Match.get_board_index(next_tile_position.x,next_tile_position.y)]
