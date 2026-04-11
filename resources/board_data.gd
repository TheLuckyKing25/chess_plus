class_name BoardData
extends Resource

var rank_count: int = 8
var file_count: int = 8


var tile_array: Array[TileObject] = []
var piece_array: Array[PieceObject] = []


var legal_moves: MoveList


var FEN_board_state: FEN


func _init(
		rank_count:int = 8,
		file_count:int = 8,
		) -> void:
	Match.players.white.promotion_rank = rank_count - 1
	Match.players.black.promotion_rank = 0
	self.rank_count = rank_count
	self.file_count = file_count


func get_index(rank:int,file:int) -> int:
	return (file) + ((rank) * file_count)


func get_board_position(index: int) -> Vector2i:
	return Vector2i(index/file_count, index%file_count)
