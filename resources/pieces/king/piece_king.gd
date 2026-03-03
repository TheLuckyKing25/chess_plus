class_name PieceKing
extends Piece

static var name:String = "King"

@export var algebraic_notation: String = "K"

@export_multiline var description: String

@export var object_mesh: Mesh = preload("res://resources/pieces/king/mesh_king.obj")

## This piece can be promoted.
@export var can_promote: bool = false

## Allow this piecetype to be an option for promoting pieces to be promoted to.
@export var promotion_option: bool = false

func _init(new_player:Player,_movement:Movement = preload("res://resources/pieces/king/movement_king.tres")):
	resource_local_to_scene = true
	player = new_player
	movement = _movement
