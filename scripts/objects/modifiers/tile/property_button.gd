class_name PropertyButton
extends TileModifier

func _init():
	name = "Button"
	flag = ModifierType.PROPERTY_BUTTON
	components[ActivationRadiusComponent.NAME] = ActivationRadiusComponent.new()

func on_piece_enter(piece, from_tile, to_tile) -> void:
	if to_tile == null:
		return

	Match.board._toggle_gates_in_radius(to_tile, components[ActivationRadiusComponent.NAME].value)
