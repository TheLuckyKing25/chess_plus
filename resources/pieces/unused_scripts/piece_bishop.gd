@icon ("uid://ctj7t3c1hhtqh")
class_name PieceBishop
extends PieceData

func _init(
		new_player:Player,
		_name:String = "Bishop",
		_algebraic_notation: String = "B",
		_description: String = "PLACEHOLDER",
		_object_mesh: Mesh = preload("uid://bh6148leh6x14"),
		_movement:Movement = preload("uid://5k73t3ur6po5"),
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
