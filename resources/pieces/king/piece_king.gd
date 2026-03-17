@icon ("res://resources/pieces/king/icon_king_light.tres")
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
		_object_mesh: Mesh = preload("res://resources/pieces/king/mesh_king.obj"),
		_movement:Movement = preload("res://resources/pieces/king/movement_king.tres"),
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
