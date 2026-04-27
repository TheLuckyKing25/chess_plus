@tool
class_name Board extends Resource

static var current_board: Board

var white_pieces: Dictionary[String,Array] = {}
var black_pieces: Dictionary[String,Array] = {}

@export_range(4,16,1) var rank_count: int = 8
@export_range(4,16,1) var file_count: int = 8

var max_length: int:
	get:
		return maxi(file_count,rank_count)

var fen:FEN = FEN.new("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")

var tile_vector_dict: Dictionary[Vector2i,Tile]

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

@export_tool_button("Generate") var call = Callable(self,"new_board")

#region TOOLS - DO NOT USE IN ACTUAL FUNCTIONS
var pieces: Array[String]
@export var selected_piece: String:
	set(value):
		for tile:Tile in board_representation.keys():
			if tile.position.algebraic_notation == value.left(2):
				selected_piece_movement = MoveTree.new()
				selected_piece_movement.convert_movement_to_tree(tile,board_representation[tile].current_movement)
		selected_piece = value

@export var selected_piece_movement: MoveTree


func _validate_property(property: Dictionary) -> void:
	if property.name == "selected_piece":
		var options = ",".join(pieces)
		property.hint = PROPERTY_HINT_ENUM
		property.hint_string = options


func generate_pieces_array():
	pieces.clear()
	for tile:Tile in board_representation.keys():
		if board_representation[tile]:
			pieces.append(tile.position.algebraic_notation + " " + board_representation[tile].name)
	notify_property_list_changed()
#endregion


static func new_board():
	current_board = Board.new()
	current_board.generate_tiles()
	current_board.assign_tile_neighbors()
	current_board.generate_pieces()
	current_board.generate_pieces_array() #tool
	for tile in current_board.board_representation.keys():
		current_board.tile_vector_dict[tile.position.vector] = tile


func generate_tiles():
	board_representation.clear()
	for index in range(rank_count*file_count):
		var new_tile = Tile.new()
		new_tile.set_position_data(index,Vector2i(index/file_count, index%file_count))
		board_representation.set(new_tile,null)


func generate_pieces():
	var piece_placement: Dictionary[int,Piece]

	var tile_num:int = 0
	var new_piece: Piece
	for character:String in fen.piece_placement:
		var tile_index = tile_num%file_count + (rank_count - (tile_num/file_count)-1)*file_count
		match character.to_lower():
			"p":
				new_piece = Piece.new_piece(preload("uid://bih6lr0cwxuk"), max_length, tile_index)
			"r":
				new_piece = Piece.new_piece(preload("uid://csqiux6uupcb2"), max_length, tile_index)
			"b":
				new_piece = Piece.new_piece(preload("uid://b7mqdwuvfi3nh"), max_length, tile_index)
			"n":
				new_piece = Piece.new_piece(preload("uid://cgvt2kihfm4em"), max_length, tile_index)
			"q":
				new_piece = Piece.new_piece(preload("uid://oqdygo3fdmd2"), max_length, tile_index)
			"k":
				new_piece = Piece.new_piece(preload("uid://bfy5ow4fdbo1l"), max_length, tile_index)
			"1","2","3","4","5","6","7","8","9":
				tile_num += character.to_int()
				continue
			_:
				continue
		piece_placement.set(tile_index,new_piece)
		new_piece.base_movement.set_max_distance(max_length)
		match character:
			"p","r","b","n","q","k":
				new_piece.assign_player("black",black_pieces)
			"P","R","B","N","Q","K":
				new_piece.assign_player("white",white_pieces)
		tile_num += 1

	for tile in board_representation.keys():
		if tile.position.index in piece_placement.keys():
			board_representation.set(tile,piece_placement[tile.position.index])


func assign_tile_neighbors():
	var tile_position_dict: Dictionary[Vector2i,Tile]
	for tile:Tile in board_representation.keys():
		tile_position_dict.set(tile.position.vector,tile)

	for tile_pos:Vector2i in tile_position_dict.keys():
		var tile: Tile = tile_position_dict[tile_pos]
		for direction:AbstractMovement.Direction in range(8):
			var next_position: Vector2i = (tile_pos + AbstractMovement.direction_vector[direction as Movement.Direction])


			tile.neighbors[direction] = tile_position_dict.get(next_position, null)
