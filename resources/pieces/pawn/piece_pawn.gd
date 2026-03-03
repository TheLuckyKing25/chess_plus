class_name PiecePawn
extends Piece

func _init(
		new_player:Player,
		_name:String = "Pawn",
		_algebraic_notation: String = "P",
		_description: String = "PLACEHOLDER",
		_object_mesh: Mesh = preload("res://resources/pieces/pawn/mesh_pawn.obj"),
		_movement:Movement = preload("res://resources/pieces/pawn/movement_pawn_initial.tres"),
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


func _moved(state:bool):
	if state:
		movement = load("res://resources/pieces/pawn/movement_pawn.tres")
		controller.add_to_group("has_moved")
	else:
		movement = load("res://resources/pieces/pawn/movement_pawn_initial.tres")
		controller.remove_from_group("has_moved")
		
