class_name PieceBishop
extends Piece

func _init(
		new_player:Player,
		_name:String = "Bishop",
		_algebraic_notation: String = "B",
		_description: String = "PLACEHOLDER",
		_object_mesh: Mesh = preload("res://resources/pieces/bishop/mesh_bishop.obj"),
		_movement:Movement = preload("res://resources/pieces/bishop/movement_bishop.tres"),
		_can_promote: bool = true,
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
