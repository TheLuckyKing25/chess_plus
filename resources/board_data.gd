class_name BoardData
extends Resource

const CAMERA_ROTATION_SPEED:int = 5
const TURN_TRANSITION_DELAY_MSEC:int = 500 # time to wait before starting transition
const MAX_TURN_TRANSITION_LENGTH_MSEC:float = 2000 # 2 Seconds
const TURN_TRANSITION_SPEED: float = CAMERA_ROTATION_SPEED/MAX_TURN_TRANSITION_LENGTH_MSEC


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
	Match.player_one.promotion_rank = rank_count - 1
	Match.player_two.promotion_rank = 0
	self.rank_count = rank_count
	self.file_count = file_count


func get_index(rank:int,file:int) -> int:
	return (file) + ((rank) * file_count)


func get_board_position(index: int) -> Vector2i:
	return Vector2i(index/file_count, index%file_count)
