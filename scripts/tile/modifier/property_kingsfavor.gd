class_name PropertyKingsFavor
extends TileModifier

func _init():
	flag = ModifierType.PROPERTY_KINGSFAVOR

func on_piece_enter(board, piece, from_tile, to_tile) -> void:
	if piece == null:
		return
	if not piece.data.can_promote:
		return

	board._perform_promotion(piece)
