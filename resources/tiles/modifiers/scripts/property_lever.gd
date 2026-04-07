class_name PropertyLever
extends TileModifier

@export_range(1, 8, 1, "or_greater") var radius: int = 1

func _init():
	name = "Lever"
	flag = ModifierType.PROPERTY_LEVER

func on_piece_enter(piece, from_tile, to_tile) -> void:
	if to_tile == null:
		return

	Match.board_object._toggle_gates_in_radius(to_tile, radius)

func activate(tile) -> void:
	Match.board_object._toggle_gates_in_radius(tile, radius)
