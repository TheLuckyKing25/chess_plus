class_name BoardData
extends Resource

var player_one:Player = load("res://resources/players/player_one.tres")
var player_two:Player = load("res://resources/players/player_two.tres")

var rank_count: int = 8
var file_count: int = 8

var tile_array: Array[TileObject] = []
var piece_location: Array[PieceObject] = []

var legal_moves: Array[Move]

var FEN_board_state: FEN

func _init(
		player_one:Player, 
		player_two:Player,
		rank_count:int = 8, 
		file_count:int = 8, 
		):
	self.player_one = player_one
	self.player_two = player_two
	self.rank_count = rank_count
	self.file_count = file_count

func get_index(rank:int,file:int) -> int:
	return (file) + ((rank) * file_count)

func get_board_position(index: int) -> Vector2i:
	return Vector2i(index/file_count, index%file_count)
