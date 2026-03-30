class_name PropertyLever
extends TileModifier

@export_range(1, 8, 1, "or_greater") var radius: int = 1

func _init():
	flag = ModifierType.PROPERTY_LEVER

func on_piece_enter(board, piece, from_tile, to_tile) -> void:
	if to_tile == null:
		return

	board._toggle_gates_in_radius(to_tile, radius)
