extends Node

var board_object = null
var board = null

func _ready() -> void:
	board_object = $"/root/Node3D/BoardBottom/Board"
	board = Board.new(board_object)
	
func _process(delta: float) -> void:
	if board.selected_piece != null \
	and board.selected_tile != null and board.is_valid_move():
		print(
			"%10s" % board.selected_piece.object_piece.name 
			+ " moves from " 
			+ board.selected_piece.tile_parent.object_tile.name 
			+ " to " 
			+ board.selected_tile.object_tile.name
		)
		board.move_piece(board.selected_piece, board.selected_tile)
