class_name Player
extends Node

var number: int
var pieces: Array[Piece] = []
var color: Color:
	set(new_color):
		color = new_color
		color_pieces()
		

func _init(player_number: int, piece_color: Color) -> void:
	number = player_number
	color = piece_color


func color_pieces() -> void:	
	if len(pieces) != 0: 
		for piece in pieces:
			piece.mesh_color = color


func add_piece(piece: Piece) -> void: 
	pieces.append(piece)
	
	
func remove_piece(piece: Piece) -> void: 
	pieces.erase(piece)
