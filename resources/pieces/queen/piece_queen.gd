class_name PieceQueen
extends Piece

static var name:String = "Queen"

@export var algebraic_notation: String = "Q"

@export_multiline var description: String

@export var object_mesh: Mesh = preload("res://resources/pieces/queen/mesh_queen.obj")

## This piece can be promoted.
@export var can_promote: bool = false

## Allow this piecetype to be an option for promoting pieces to be promoted to.
@export var promotion_option: bool = true



func _init(new_player:Player,_movement:Movement = preload("res://resources/pieces/queen/movement_queen.tres")):
	resource_local_to_scene = true
	player = new_player
	movement = _movement
