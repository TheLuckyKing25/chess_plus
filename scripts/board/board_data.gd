# this is a state of a board.
# should be seperate from the Board Object
class_name BoardData
extends Resource


var rank_count: int = 8
var file_count: int = 8

var max_length: int:
	get:
		return maxi(file_count,rank_count)

var assigned_object: BoardObject

#region FEN Data
var board_representation: Dictionary[TileDataChess,PieceData]

var tiles: Array[TileDataChess]:
	get():
		return board_representation.keys()

var pieces: Array[PieceData]:
	get():
		return board_representation.values().filter(
				func(piece:PieceData): return piece != null
			)

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
# we do not want to generate new tiles.
static func create_board(ranks:int = 8, files:int = 8) -> BoardData:
	var board:BoardData = BoardData.new(ranks,files)

	if board.board_representation.is_empty():
		board._generate_tile_data()

	board._assign_tile_neighbors()
	board._generate_pieces()

	return board


func _init(ranks:int = 8, files:int = 8) -> void:
	GameController.player.white.promotion_rank = rank_count - 1
	GameController.player.black.promotion_rank = 0
	rank_count = ranks
	file_count = files


func _generate_tile_data() -> void:
	for index in range(rank_count*file_count):
		var new_tile = TileDataChess.new()
		new_tile.set_position_data(index,Vector2i(index/file_count, index%file_count))
		board_representation[new_tile] = null
		new_tile.resource_name = "Tile " + new_tile.algebraic_notation


func _assign_tile_neighbors() -> void:
	for tile:TileDataChess in tiles:
		for direction:AbstractMovement.Direction in range(0,8):
			var neighbor_position: Vector2i = (
					tile.board_position
					+ AbstractMovement.direction_vector[direction]
				)

			if (
					neighbor_position > Vector2i(rank_count-1,file_count-1)
					or neighbor_position < Vector2i(0,0)
				):
				tile.neighbors[direction] = null
				continue

			tile.neighbors[direction] = _find_tile_using_vector(neighbor_position)


func _find_tile_using_vector(vector: Vector2i) -> TileDataChess:
	for tile:TileDataChess in tiles:
		if tile.board_position == vector:
			return tile
	return null # tile not found


func _generate_pieces():
	var piece_placement: Dictionary[int,PieceData]

	var tile_num:int = 0
	var new_piece: PieceData
	var fen:FEN = FEN.new("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")

	for character:String in fen.piece_placement:
		var tile_index = tile_num%file_count + (rank_count - (tile_num/file_count)-1)*file_count
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
		piece_placement.set(tile_index,new_piece)
		#new_piece.base_movement.set_max_distance(max_length)
		match character:
			"p","r","b","n","q","k":
				new_piece.assign_player("black")
			"P","R","B","N","Q","K":
				new_piece.assign_player("white")
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
			direction = direction as AbstractMovement.Direction
			var next_tile_position: Vector2i = (
					tile.data.board_position
					+ AbstractMovement.direction_vector[direction]
					)

			if (	next_tile_position > Vector2i(rank_count-1,file_count-1)
					or next_tile_position < Vector2i(0,0)
					):
				tile.neighbors[direction] = null
				continue

			tile.neighbors[direction] = tile_array[Match.get_board_index(next_tile_position.x,next_tile_position.y)]
