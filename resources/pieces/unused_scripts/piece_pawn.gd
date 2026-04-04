@icon ("uid://lepc2qnq7lph")
class_name PiecePawn
extends PieceData

func _init(
		new_player:Player,
		_name:String = "Pawn",
		_algebraic_notation: String = "P",
		_description: String = "PLACEHOLDER",
		_object_mesh: Mesh = preload("uid://bhpxj4ybm00m3"),
		_movement:Movement = preload("uid://dl1o3ayyjvnlf"),
		_can_promote: bool = true,
		_promotion_option: bool = false
		) -> void:
	resource_local_to_scene = true

	player = new_player
	name = _name
	algebraic_notation = _algebraic_notation
	description = _description
	object_mesh = _object_mesh
	movement = _movement
	can_promote = _can_promote
	promotion_option = _promotion_option
