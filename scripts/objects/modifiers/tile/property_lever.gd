class_name PropertyLever
extends TileModifier

func _init():
	name = "Lever"
	flag = ModifierType.PROPERTY_LEVER
	components["activation_radius"] = ActivationRadiusComponent.new()

func on_piece_enter(piece, from_tile, to_tile) -> void:
	if to_tile == null:
		return

	Match.board._toggle_gates_in_radius(to_tile, components["activation_radius"].value)

func activate(tile) -> void:
	Match.board._toggle_gates_in_radius(tile, components["activation_radius"].value)
