class_name PieceRook
extends Piece

func _init(
		new_player:Player,
		_name:String = "Rook",
		_algebraic_notation: String = "R",
		_description: String = "PLACEHOLDER",
		_object_mesh: Mesh = preload("res://resources/pieces/rook/mesh_rook.obj"),
		_movement:Movement = preload("res://resources/pieces/rook/movement_rook.tres"),
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
