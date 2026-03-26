class_name PropertyPoison
extends TileModifier

@export_range(-1, 1000, 1.0, "suffix: turns") var duration: int = 3

func _init():
	flag = ModifierEnums.TileModifierFlag.PROPERTY_POISON

func on_piece_enter(board, piece, from_tile, to_tile) -> void:
	piece.data.is_poisoned = true
	piece.data.poison_turn_applied = board._turn_num
	piece.data.poison_duration = duration
