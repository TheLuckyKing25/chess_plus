class_name PropertyButton
extends TileModifier

@export_range(1, 8, 1, "or_greater") var radius: int = 1

func _init():
	name = "Button"
	flag = ModifierType.PROPERTY_BUTTON

func on_piece_enter(piece, from_tile, to_tile) -> void:
	if to_tile == null:
		return

	Match.board_object._toggle_gates_in_radius(to_tile, radius)
