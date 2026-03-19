class_name TileModifier
extends Resource

@export var flag: int

func modify_moves(board, piece, tile, moves):
	return moves
	
func modify_moveset(board, piece, tile, moveset):
	return moveset

func modify_threats(board, piece, tile, threats):
	return threats

func on_piece_enter(board, piece, from_tile, to_tile) -> void:
	pass

func on_turn_end(board, tile) -> void:
	pass

func blocks_movement(board, piece, tile) -> bool:
	return false
