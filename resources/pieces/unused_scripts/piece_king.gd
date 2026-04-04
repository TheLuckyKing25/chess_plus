@icon ("uid://t8lfyd4522e8")
class_name PieceKing
extends PieceData

@warning_ignore("unused_private_class_variable")
var _castling_queenside_valid := true

@warning_ignore("unused_private_class_variable")
var _castling_kingside_valid := true

func _init(
		new_player:Player,
		_name:String = "King",
		_algebraic_notation: String = "K",
		_description: String = "PLACEHOLDER",
		_object_mesh: Mesh = preload("uid://cl7rh34wkwp71"),
		_movement:Movement = preload("uid://xk6w8bj7uf8k"),
		_can_promote: bool = false,
		_promotion_option: bool = false
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
