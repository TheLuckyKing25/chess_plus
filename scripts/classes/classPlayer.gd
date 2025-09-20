class_name Player
extends Node

var number: int
var color: Color
var pieces: Array[Piece] = []

func _init(player_number: int, piece_color: Color):
	set_player_number(player_number)
	set_color(piece_color)

func get_color() -> Color: return color
func get_player_number() -> int: return number
func get_pieces() -> Array[Piece]: return pieces

func apply_color_to_pieces():	
	if len(pieces) != 0: for piece in pieces:
		piece.set_base_color(color)

func set_color(piece_color: Color): 
	color = piece_color
	apply_color_to_pieces()
func set_player_number(player_number: int): number = player_number

func add_piece(piece: Piece): 
	pieces.append(piece)
func remove_piece(piece: Piece): pieces.erase(piece)
