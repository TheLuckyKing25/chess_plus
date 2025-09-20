# Script contains global variables which can be accessed and changed from any other script.
extends Node
#==============[Debug Settings]==============

var enable_restricted_movement = true #should piece movement be restricted to the designated tiles

#==============[Movement]==============
# Vector( Row , Column )
var rook_movement = [Vector2(1,0), Vector2(0,1), Vector2(-1,0), Vector2(0,-1)]

var bishop_movement = [Vector2(1,1), Vector2(-1,1), Vector2(1,-1), Vector2(-1,-1)]

var pawn_movement = Vector2(1,0)
var pawn_movement_first = [Vector2(1,0), Vector2(2,0)]
var pawn_movement_capture = [Vector2(1,1), Vector2(1,-1)]

var knight_movement = [Vector2(1,2), Vector2(2,1), Vector2(-1,2), Vector2(-2,1), Vector2(1,-2), Vector2(2,-1), Vector2(-1,-2),Vector2(-2,-1)]
#==============[Colors]==============
var player1_color = Color(0.9, 0.9, 0.9) #White
var player2_color = Color(0.1, 0.1, 0.1) #Black

var light_tile_color = Color(1.0, 0.77, 0.58) #White
var dark_tile_color = light_tile_color.darkened(0.5) #Black

var selected_outline_color = Color(0, 0.9, 0.9) #Cyan
var threatened_outline_color = Color(0.9, 0, 0) #Red

var tile_move_highlight_color = Color(0.25, 0.75, 0.25) #Light Green
var tile_capture_highlight_color = Color(0.75, 0.25, 0.25) #Light Red

var board_object = null
var board = null
# sets the variables to the objects selected, allowing them to be addressed in other scripts.
var piece_selected = null
var tile_selected = null
var piece_movement_tile_names = []
var moved_pawns = []

func _ready() -> void:
	board_object = $"/root/Node3D/Board"
	board = Board.new(board_object)
	
func _process(delta: float) -> void:
	# Moves the selected piece the the selected tile by setting the piece's XZ coordinates to 
	# the tile's XZ coordinates while keeping the piece's Y coordinate.	
	if enable_restricted_movement and tile_selected != null and tile_selected.name not in piece_movement_tile_names:
		board.selected_tile = null

	if board.selected_piece != null \
	and board.selected_tile != null and board.is_valid_move():
		print(board.selected_piece.object.name + " moves from " + board.selected_piece.object.get_parent().name + " to " + board.selected_tile.object.name)
		board.move_piece(board.selected_piece, board.selected_tile)
