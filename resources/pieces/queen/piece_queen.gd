class_name PieceQueen
extends PieceData

func _init(
		new_player:Player,
		_name:String = "Queen",
		_algebraic_notation: String = "Q",
		_description: String = "PLACEHOLDER",
		_object_mesh: Mesh = preload("res://resources/pieces/queen/mesh_queen.obj"),
		_movement:Movement = preload("res://resources/pieces/queen/movement_queen.tres"),
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
