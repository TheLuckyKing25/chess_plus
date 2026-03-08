# Used for simulating moves
class_name VirtualBoard


var duplicated_board: BoardData = null


var virtual_tiles: Array[TileObject]
var virtual_pieces: Array[PieceObject]


func _init(board_data: BoardData) -> void:
	duplicated_board = board_data.duplicate()
	duplicated_board.tile_array = board_data.tile_array.duplicate()
	duplicated_board.piece_location = board_data.piece_location.duplicate()
	reset()


func reset():
	virtual_tiles = duplicated_board.tile_array
	virtual_pieces = duplicated_board.piece_location


func make_move(move:Move):
	move.destination_tile.occupant = move.starting_tile.occupant
	move.starting_tile.occupant = null


func unmake_move(move:Move):
	move.starting_tile.occupant = move.destination_tile.occupant
	move.destination_tile.occupant = duplicated_board.piece_location[move.destination_tile.data.index]


func get_virtual_board_data() -> BoardData:
	var new_board_data: BoardData = duplicated_board.duplicate()
	new_board_data.tile_array = virtual_tiles
	new_board_data.piece_location = virtual_pieces
	return new_board_data
