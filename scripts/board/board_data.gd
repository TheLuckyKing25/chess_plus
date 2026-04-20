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


func assign_tile_neighbors():
	for tile in tile_array:
		for direction in range(0,8):
			direction = direction as Movement.Direction
			var next_tile_position: Vector2i = (
					tile.data.board_position
					+ Movement.neighboring_tiles[direction]
					)

			if (	next_tile_position > Vector2i(rank_count-1,file_count-1)
					or next_tile_position < Vector2i(0,0)
					):
				tile.neighbors[direction] = null
				continue

			tile.neighbors[direction] = tile_array[Match.get_board_index(next_tile_position.x,next_tile_position.y)]
