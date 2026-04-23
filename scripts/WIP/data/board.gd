class_name Board extends Resource

var rank_count: int = 8
var file_count: int = 8

#region FEN DATA
var board_representation: Dictionary[Tile,Piece]


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


func generate_tiles():
	for index in range(rank_count*file_count):
		board_representation[Tile.new()] = null

func generate_pieces():
	pass
