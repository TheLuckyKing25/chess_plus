@icon ("uid://bc3lgf0m3b26c")
class_name PieceRook
extends PieceData

func _init(
		new_player:Player,
		_name:String = "Rook",
		_algebraic_notation: String = "R",
		_description: String = "PLACEHOLDER",
		_object_mesh: Mesh = preload("uid://047i1asw03nw"),
		_movement:Movement = preload("uid://b0ucks7w4ums8"),
		_can_promote: bool = false,
		_promotion_option: bool = true
		):
	resource_local_to_scene = true

	player = new_player
	name = _name
	algebraic_notation = _algebraic_notation
	description = _description
	object_mesh = _object_mesh
	movement = _movement
	can_promote = _can_promote
	promotion_option = _promotion_option
