class_name PropertyButton
extends TileModifier

@export_range(1, 8, 1, "or_greater") var radius: int = 1

var last_trigger_piece: PieceObject = null

func _init():
	flag = ModifierType.PROPERTY_BUTTON

func on_turn_end(board,tile) -> void:
	if tile == null or tile.occupant == null:
		last_trigger_piece = null
		return

	if tile.occupant == last_trigger_piece:
		return

	print("BUTTON fired on tile ", tile.data.board_position, " radius=", radius)
	last_trigger_piece = tile.occupant
	modifier_activated.emit(radius)
