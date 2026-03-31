class_name PropertySmokey
extends TileModifier

@export var is_active: bool = false
var activated_by_player = null # Track which side to spawn smoke

func _init():
	flag = ModifierType.PROPERTY_SMOKEY

func on_piece_enter(board, piece, from_tile, to_tile) -> void:
	is_active = not is_active
	if is_active:
		activated_by_player = piece.data.player
	else:
		activated_by_player = null
	board._update_smokey_visuals()
