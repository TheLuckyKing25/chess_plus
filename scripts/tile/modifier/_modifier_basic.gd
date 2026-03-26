class_name TileModifier
extends Resource

@export var flag: int

static func apply_modifiers_to_moveset(context, tile, piece, moveset):
	var result = moveset
	for modifier in tile.data.modifier_order:
		result = modifier.modify_moveset(context, piece, tile, result)
	return result

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

func blocks_passage(context, piece, tile, movement) -> bool:
	return false
