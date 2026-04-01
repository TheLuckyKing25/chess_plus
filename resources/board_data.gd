class_name BoardData
extends Resource

const CAMERA_ROTATION_SPEED:int = 5
const TURN_TRANSITION_DELAY_MSEC:int = 500 # time to wait before starting transition
const MAX_TURN_TRANSITION_LENGTH_MSEC:float = 2000 # 2 Seconds
const TURN_TRANSITION_SPEED: float = CAMERA_ROTATION_SPEED/MAX_TURN_TRANSITION_LENGTH_MSEC


var player_one:Player
var player_two:Player


var rank_count: int = 8
var file_count: int = 8


var tile_array: Array[TileObject] = []
var piece_array: Array[PieceObject] = []


var legal_moves: MoveList


var FEN_board_state: FEN


var is_match_timed: bool = false


func _init(
		player_one:Player = load("res://resources/players/player_one.tres"),
		player_two:Player = load("res://resources/players/player_two.tres"),
		rank_count:int = 8,
		file_count:int = 8,
		) -> void:
	player_one.promotion_rank = rank_count - 1
	player_two.promotion_rank = 0
	self.player_one = player_one
	self.player_two = player_two
	self.rank_count = rank_count
	self.file_count = file_count


func get_opponent_of(player: Player) -> Player:
	if player == player_one:
		return player_two
	elif player == player_two:
		return player_one
	else:
		return null

func get_index(rank:int,file:int) -> int:
	return (file) + ((rank) * file_count)


func get_board_position(index: int) -> Vector2i:
	return Vector2i(index/file_count, index%file_count)
