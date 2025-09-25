extends Node3D


var board_object = null
var board = null
	
func _ready() -> void:
	# Pass the Board node to the global singleton
	board_object = $"/root/Node3D/BoardBottom/Board"
	Global.board = Board.new(board_object)
	print("Board initialized from Game scene")
