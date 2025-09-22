# Script contains global variables which can be accessed and changed from any other script.
extends Node

var board_object = null
var board = null

func _ready() -> void:
	board_object = $"/root/Node3D/BoardBottom/Board"
	board = Board.new(board_object)
	
func _process(delta: float) -> void:
	# Moves the selected piece the the selected tile by setting the piece's XZ coordinates to 
	# the tile's XZ coordinates while keeping the piece's Y coordinate.	

	if board.selected_piece != null \
	and board.selected_tile != null and board.is_valid_move():
		print(board.selected_piece.object.name + " moves from " + board.selected_piece.object.get_parent().name + " to " + board.selected_tile.object.name)
		board.move_piece(board.selected_piece, board.selected_tile)
