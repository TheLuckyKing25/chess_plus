@tool
class_name Board extends Resource

var rank_count: int = 8
var file_count: int = 8

var fen:FEN = FEN.new("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")



#region FEN DATA
@export var board_representation: Dictionary[Tile,Piece]


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

@export_tool_button("Generate") var call = Callable(self,"generate_board")

func generate_board():
	generate_tiles()
	assign_tile_neighbors()
	generate_pieces()

func generate_tiles():
	board_representation.clear()
	for index in range(rank_count*file_count):
		var new_tile = Tile.new()
		new_tile.set_position_data(index,Vector2i(index/file_count, index%file_count))
		board_representation.set(new_tile,null)

func generate_pieces():
	var piece_locations: Dictionary[int,Piece]

	var max_distance: int = maxi(file_count,rank_count)
	var tile_num:int = 0
	var new_piece: Piece
	for character in fen.piece_placement:
		var tile_index = tile_num%file_count + (rank_count - (tile_num/file_count)-1)*file_count
		match character:
			"p":
				new_piece = Piece.new_piece(preload("uid://bih6lr0cwxuk"), max_distance, tile_index)
			"r":
				new_piece = Piece.new_piece(preload("uid://csqiux6uupcb2"), max_distance, tile_index)
			"b":
				new_piece = Piece.new_piece(preload("uid://b7mqdwuvfi3nh"), max_distance, tile_index)
			"n":
				new_piece = Piece.new_piece(preload("uid://cgvt2kihfm4em"), max_distance, tile_index)
			"q":
				new_piece = Piece.new_piece(preload("uid://oqdygo3fdmd2"), max_distance, tile_index)
			"k":
				new_piece = Piece.new_piece(preload("uid://bfy5ow4fdbo1l"), max_distance, tile_index)
			"P":
				new_piece = Piece.new_piece(preload("uid://bih6lr0cwxuk"), max_distance, tile_index)
			"R":
				new_piece = Piece.new_piece(preload("uid://csqiux6uupcb2"), max_distance, tile_index)
			"B":
				new_piece = Piece.new_piece(preload("uid://b7mqdwuvfi3nh"), max_distance, tile_index)
			"N":
				new_piece = Piece.new_piece(preload("uid://cgvt2kihfm4em"), max_distance, tile_index)
			"Q":
				new_piece = Piece.new_piece(preload("uid://oqdygo3fdmd2"), max_distance, tile_index)
			"K":
				new_piece = Piece.new_piece(preload("uid://bfy5ow4fdbo1l"), max_distance, tile_index)
			"1","2","3","4","5","6","7","8","9":
				tile_num += character.to_int()
				continue
			_:
				continue
		piece_locations.set(tile_index,new_piece)
		tile_num += 1

	for tile in board_representation.keys():
		if tile.position.index in piece_locations.keys():
			board_representation.set(tile,piece_locations[tile.position.index])

func assign_tile_neighbors():
	var tile_position_dict: Dictionary[Vector2i,Tile]
	for tile:Tile in board_representation.keys():
		tile_position_dict.set(tile.position.vector,tile)

	for tile_pos:Vector2i in tile_position_dict.keys():
		var tile: Tile = tile_position_dict[tile_pos]
		for direction:AbstractMovement.Direction in range(8):
			var next_tile_position: Vector2i = (tile_pos + AbstractMovement.neighboring_tiles[direction as Movement.Direction])


			tile.neighbors[direction] = tile_position_dict.get(next_tile_position, null)
