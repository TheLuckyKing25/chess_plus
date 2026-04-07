class_name PropertyPromote
extends TileModifier

func _init():
	name = "Promote"
	flag = ModifierType.PROPERTY_PROMOTE

func on_piece_enter(piece, from_tile, to_tile) -> void:
	if piece == null:
		return
	if not piece.data.can_promote:
		return

	Match.board_object._perform_promotion(piece)
