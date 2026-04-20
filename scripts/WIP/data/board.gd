class_name Board extends Resource

var tilemap: Array[Tile] = []
var piece_placement: Array[Piece] = []

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

var en_passant: Dictionary[Tile, Piece] = {}

var halfmove_clock: int = 0

var fullmove_counter: int = 0
#endregion

var rank_count: int = 8
var file_count: int = 8


func generate_board_representation():
	for index in range(rank_count*file_count):
		board_representation[tilemap[index]] = piece_placement[index]
