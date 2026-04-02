@icon ("uid://d2dnk5daptu4d")
class_name PieceKnight
extends PieceData

func _init(
		new_player:Player,
		_name:String = "Knight",
		_algebraic_notation: String = "N",
		_description: String = "PLACEHOLDER",
		_object_mesh: Mesh = preload("uid://co538rh6q5c02"),
		_movement:Movement = preload("uid://q2y1s24qkute"),
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
